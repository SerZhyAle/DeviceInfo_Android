package com.sza.deviceinfo.wear.ui.common

import android.content.Context
import android.content.ContextWrapper
import android.content.res.Configuration
import android.content.res.Resources
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.Density
import dagger.hilt.android.qualifiers.ApplicationContext
import timber.log.Timber
import javax.inject.Inject
import javax.inject.Singleton
import kotlin.math.roundToInt

/**
 * The one interface scale of the watch app (S0023, exception E1; UI-SIZING 1.2 section 2 rules 2-4).
 *
 * The supported range is four steps, 100 (the ordinary baseline), 115, 130 and 150 percent. There is no compact step:
 * rule 4 asks for an owner-declared compact floor before a product exposes compact mode, and none is declared, so the
 * range only grows from the baseline and a target never falls under the 48 dp of the size profile. The scale is
 * independent of the text enlargement of the system font scale, which stays whatever the wearer chose: the scale
 * multiplies the density, so typography, glyphs, padding, gaps and targets grow together (rule 3), and the font scale
 * applies on top of that without being replaced or cancelled.
 *
 * The phone app has its own copy of the steps (`InterfaceScale`): the two apps share no source, so what both must
 * agree on exists twice, and each module's test holds the same steps.
 */
object WearInterfaceScale {
    /** The supported steps, in percent. Every other stored or requested value reads as [DEFAULT_PERCENT]. */
    val STEPS: List<Int> = listOf(100, 115, 130, 150)

    const val DEFAULT_PERCENT = 100

    /** A value that is not a supported step must not produce a zero-size or shrinking interface (rule 4). */
    fun normalize(percent: Int): Int = if (percent in STEPS) percent else DEFAULT_PERCENT

    /** The step after [percent], and the first step after the last one. */
    fun next(percent: Int): Int = STEPS[(STEPS.indexOf(normalize(percent)) + 1) % STEPS.size]

    fun factor(percent: Int): Float = normalize(percent) / 100f

    /**
     * The configuration a display of the scaled density would report: the same pixels, so fewer dp across and down,
     * at a larger densityDpi. [base] is not modified.
     */
    fun scaledConfiguration(base: Configuration, percent: Int): Configuration {
        val factor = factor(percent)
        return Configuration(base).apply {
            if (base.densityDpi != Configuration.DENSITY_DPI_UNDEFINED) {
                densityDpi = (base.densityDpi * factor).roundToInt()
            }
            screenWidthDp = shrunkDp(base.screenWidthDp, factor)
            screenHeightDp = shrunkDp(base.screenHeightDp, factor)
            smallestScreenWidthDp = shrunkDp(base.smallestScreenWidthDp, factor)
        }
    }

    private fun shrunkDp(dp: Int, factor: Float): Int =
        if (dp == Configuration.SCREEN_WIDTH_DP_UNDEFINED) dp else (dp / factor).toInt()
}

/**
 * Remembers the chosen step across launches. The state is observable, so choosing a step re-composes the screen under
 * the new scale at once.
 */
@Singleton
class WearInterfaceScaleStore @Inject constructor(@ApplicationContext context: Context) {

    private val preferences = context.getSharedPreferences("wear_interface_scale", Context.MODE_PRIVATE)

    var percent: Int by mutableIntStateOf(
        WearInterfaceScale.normalize(preferences.getInt(KEY_PERCENT, WearInterfaceScale.DEFAULT_PERCENT))
    )
        private set

    fun select(requested: Int) {
        val chosen = WearInterfaceScale.normalize(requested)
        Timber.d("S0023: wear interface scale selected=%d", chosen)
        percent = chosen
        preferences.edit().putInt(KEY_PERCENT, chosen).apply()
    }

    /** One tap on the watch moves to the next step; the last step wraps to the baseline. */
    fun cycle() = select(WearInterfaceScale.next(percent))

    private companion object {
        const val KEY_PERCENT = "percent"
    }
}

/** The store as seen from composition. Null means no choice is offered. */
val LocalWearInterfaceScale = staticCompositionLocalOf<WearInterfaceScaleStore?> { null }

/** Keeps the real context for everything but the resources, so an activity found through it stays an activity. */
private class ScaledResourcesContext(base: Context, private val scaled: Resources) : ContextWrapper(base) {
    override fun getResources(): Resources = scaled
}

/**
 * Draws [content] at the chosen interface scale: a density provider around the theme. The density, the configuration
 * and the resources a composable reads (`dimensionResource` among them) all move together, so a 48 dp declaration
 * is 48 dp of the scaled interface and the measured width in dp is what the scaled display really has. At the
 * baseline it adds nothing at all, so the default path is the unscaled path.
 */
@Composable
fun WearInterfaceScaleScope(percent: Int, content: @Composable () -> Unit) {
    val chosen = WearInterfaceScale.normalize(percent)
    if (chosen == WearInterfaceScale.DEFAULT_PERCENT) {
        content()
        return
    }
    val baseContext = LocalContext.current
    val baseConfiguration = LocalConfiguration.current
    val baseDensity = LocalDensity.current
    val scaledConfiguration = remember(baseConfiguration, chosen) {
        WearInterfaceScale.scaledConfiguration(baseConfiguration, chosen)
    }
    val scaledContext = remember(baseContext, scaledConfiguration) {
        ScaledResourcesContext(baseContext, baseContext.createConfigurationContext(scaledConfiguration).resources)
    }
    val scaledDensity = remember(baseDensity, chosen) {
        Density(baseDensity.density * WearInterfaceScale.factor(chosen), baseDensity.fontScale)
    }
    CompositionLocalProvider(
        LocalContext provides scaledContext,
        LocalConfiguration provides scaledConfiguration,
        LocalDensity provides scaledDensity,
        content = content
    )
}
