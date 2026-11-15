package com.sza.deviceinfo.ui.common

import android.content.Context
import android.content.res.Configuration
import timber.log.Timber
import kotlin.math.roundToInt

/**
 * The one interface scale of the phone app (S0023, exception E1; UI-SIZING 1.2 section 2 rules 2-4).
 *
 * The supported range is four steps, 100 (the ordinary baseline), 115, 130 and 150 percent. There is no compact step:
 * rule 4 asks for an owner-declared compact floor before a product exposes compact mode, and none is declared, so the
 * range only grows from the baseline and a target never falls under the 48 dp of the size profile. The scale is
 * independent of the text enlargement of the system font scale, which stays whatever the user chose: the scale
 * multiplies the density of the app's own resources, so typography, glyphs, padding, gaps and targets grow together
 * (rule 3), and the font scale applies on top of that without being replaced or cancelled.
 *
 * The watch app has its own copy of the steps (`WearInterfaceScale`): the two apps share no source, so what both must
 * agree on exists twice, and each module's test holds the same steps.
 *
 * The choice is read when an activity is created ([wrap], called from `attachBaseContext`), so a change takes effect by
 * re-creating the screen, never mid-interaction, and an activity that does not call [wrap] simply stays at the baseline.
 */
object InterfaceScale {
    /** The supported steps, in percent. Every other stored or requested value reads as [DEFAULT_PERCENT]. */
    val STEPS: List<Int> = listOf(100, 115, 130, 150)

    const val DEFAULT_PERCENT = 100

    private const val PREFERENCES = "interface_scale"
    private const val KEY_PERCENT = "percent"

    /** A value that is not a supported step must not produce a zero-size or shrinking interface (rule 4). */
    fun normalize(percent: Int): Int = if (percent in STEPS) percent else DEFAULT_PERCENT

    fun factor(percent: Int): Float = normalize(percent) / 100f

    /** The density a screen at [percent] reports, for a base density in dots per inch. */
    fun scaledDensityDpi(baseDensityDpi: Int, percent: Int): Int = (baseDensityDpi * factor(percent)).roundToInt()

    /** The step the user chose; the baseline when nothing, or something unsupported, is stored. */
    fun read(context: Context): Int =
        normalize(
            context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE).getInt(KEY_PERCENT, DEFAULT_PERCENT)
        )

    fun write(context: Context, percent: Int) {
        context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
            .edit()
            .putInt(KEY_PERCENT, normalize(percent))
            .apply()
    }

    /**
     * [base] with its resources at the chosen scale. At the baseline it returns [base] itself, so the default path is
     * the unscaled path and nothing is wrapped.
     */
    fun wrap(base: Context): Context {
        val percent = read(base)
        Timber.d("S0023: InterfaceScale.wrap percent=%d", percent)
        if (percent == DEFAULT_PERCENT) return base
        val configuration = Configuration(base.resources.configuration)
        configuration.densityDpi = scaledDensityDpi(configuration.densityDpi, percent)
        return base.createConfigurationContext(configuration)
    }
}
