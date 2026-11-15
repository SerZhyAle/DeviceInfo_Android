package com.sza.deviceinfo.ui.common

import android.app.Application
import android.content.Context
import android.content.res.Configuration
import com.sza.deviceinfo.R
import org.junit.Assert.assertEquals
import org.junit.Assert.assertSame
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.annotation.Config

/** S0023, exception E1: the one interface scale of the phone app (UI-SIZING 1.2 section 2 rules 2-4). */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34], application = Application::class)
class InterfaceScaleTest {
    private lateinit var context: Context

    @Before
    fun clearPreferences() {
        context = RuntimeEnvironment.getApplication()
        context.getSharedPreferences("interface_scale", Context.MODE_PRIVATE).edit().clear().commit()
    }

    @Test
    fun `the supported steps are the baseline and three larger ones and no compact step`() {
        assertEquals(listOf(100, 115, 130, 150), InterfaceScale.STEPS)
        assertTrue("no step may shrink below the baseline", InterfaceScale.STEPS.all { it >= InterfaceScale.DEFAULT_PERCENT })
    }

    @Test
    fun `an unsupported value reads as the baseline and never as zero or a shrinking scale`() {
        listOf(-50, 0, 1, 99, 101, 149, 151, 1000, Int.MIN_VALUE, Int.MAX_VALUE).forEach { odd ->
            assertEquals("value $odd", InterfaceScale.DEFAULT_PERCENT, InterfaceScale.normalize(odd))
            assertEquals("factor for $odd", 1f, InterfaceScale.factor(odd), 0f)
        }
        InterfaceScale.STEPS.forEach { step -> assertEquals(step, InterfaceScale.normalize(step)) }
    }

    @Test
    fun `density grows with the step and the baseline leaves it alone`() {
        assertEquals(320, InterfaceScale.scaledDensityDpi(320, 100))
        assertEquals(368, InterfaceScale.scaledDensityDpi(320, 115))
        assertEquals(416, InterfaceScale.scaledDensityDpi(320, 130))
        assertEquals(480, InterfaceScale.scaledDensityDpi(320, 150))
        assertEquals(320, InterfaceScale.scaledDensityDpi(320, 77))
    }

    @Test
    fun `nothing stored reads as the baseline and a stored choice survives a read`() {
        assertEquals(InterfaceScale.DEFAULT_PERCENT, InterfaceScale.read(context))
        InterfaceScale.write(context, 130)
        assertEquals(130, InterfaceScale.read(context))
        InterfaceScale.write(context, 7)
        assertEquals("an unsupported write is stored as the baseline", 100, InterfaceScale.read(context))
        context.getSharedPreferences("interface_scale", Context.MODE_PRIVATE).edit().putInt("percent", 12345).commit()
        assertEquals("an unsupported stored value reads as the baseline", 100, InterfaceScale.read(context))
    }

    @Test
    fun `the baseline returns the very same context`() {
        assertSame(context, InterfaceScale.wrap(context))
    }

    @Test
    fun `a chosen step scales the density of the resources and leaves the font scale as it was`() {
        val before = context.resources.displayMetrics.density
        val fontScaleBefore = context.resources.configuration.fontScale
        InterfaceScale.write(context, 130)

        val wrapped = InterfaceScale.wrap(context)

        assertEquals(before * 1.3f, wrapped.resources.displayMetrics.density, before * 0.02f)
        assertEquals(
            "the system text enlargement stays the user's own (UI-SIZING 1.2 section 2 rule 3)",
            fontScaleBefore,
            wrapped.resources.configuration.fontScale,
            0f
        )
        assertEquals(
            "the app context itself is not changed",
            before,
            context.resources.displayMetrics.density,
            0f
        )
    }

    @Test
    fun `a 48 dp declaration grows with the scale`() {
        val base = context.resources.getDimension(R.dimen.system_info_group_copy_button_width)
        InterfaceScale.write(context, 150)

        val scaled = InterfaceScale.wrap(context).resources.getDimension(R.dimen.system_info_group_copy_button_width)

        assertTrue("48 dp must not shrink: $base -> $scaled", scaled >= base)
        assertEquals(base * 1.5f, scaled, base * 0.03f)
    }

    @Test
    fun `wrapping does not change a copy of the configuration it was given`() {
        val original = Configuration(context.resources.configuration)
        InterfaceScale.write(context, 115)

        InterfaceScale.wrap(context)

        assertEquals(original.densityDpi, context.resources.configuration.densityDpi)
    }
}
