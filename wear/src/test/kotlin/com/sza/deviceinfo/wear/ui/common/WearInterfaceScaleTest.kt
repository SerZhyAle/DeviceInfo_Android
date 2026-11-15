package com.sza.deviceinfo.wear.ui.common

import android.app.Application
import android.content.Context
import android.content.res.Configuration
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotSame
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.annotation.Config

/** S0023, exception E1: the one interface scale of the watch app (UI-SIZING 1.2 section 2 rules 2-4, section 6). */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34], application = Application::class)
class WearInterfaceScaleTest {
    private lateinit var context: Context

    @Before
    fun clearPreferences() {
        context = RuntimeEnvironment.getApplication()
        context.getSharedPreferences("wear_interface_scale", Context.MODE_PRIVATE).edit().clear().commit()
    }

    @Test
    fun `the supported steps are the baseline and three larger ones and no compact step`() {
        assertEquals(listOf(100, 115, 130, 150), WearInterfaceScale.STEPS)
        assertTrue("no step may shrink below the baseline", WearInterfaceScale.STEPS.all { it >= WearInterfaceScale.DEFAULT_PERCENT })
    }

    @Test
    fun `an unsupported value reads as the baseline and never as zero or a shrinking scale`() {
        listOf(-50, 0, 1, 99, 101, 149, 151, 1000, Int.MIN_VALUE, Int.MAX_VALUE).forEach { odd ->
            assertEquals("value $odd", WearInterfaceScale.DEFAULT_PERCENT, WearInterfaceScale.normalize(odd))
            assertEquals("factor for $odd", 1f, WearInterfaceScale.factor(odd), 0f)
        }
        WearInterfaceScale.STEPS.forEach { step -> assertEquals(step, WearInterfaceScale.normalize(step)) }
    }

    @Test
    fun `one tap moves to the next step and the last step wraps to the baseline`() {
        assertEquals(115, WearInterfaceScale.next(100))
        assertEquals(130, WearInterfaceScale.next(115))
        assertEquals(150, WearInterfaceScale.next(130))
        assertEquals(100, WearInterfaceScale.next(150))
        assertEquals("an unsupported value cycles from the baseline", 115, WearInterfaceScale.next(77))
    }

    @Test
    fun `the store starts at the baseline, remembers a choice across launches and ignores an unsupported one`() {
        assertEquals(100, WearInterfaceScaleStore(context).percent)

        val first = WearInterfaceScaleStore(context)
        first.cycle()
        assertEquals(115, first.percent)
        first.select(130)
        assertEquals(130, WearInterfaceScaleStore(context).percent)

        first.select(7)
        assertEquals(100, first.percent)
        assertEquals(100, WearInterfaceScaleStore(context).percent)

        context.getSharedPreferences("wear_interface_scale", Context.MODE_PRIVATE).edit().putInt("percent", 12345).commit()
        assertEquals(100, WearInterfaceScaleStore(context).percent)
    }

    @Test
    fun `the scaled configuration keeps the pixels, so it has fewer dp across and a larger density`() {
        val base = Configuration().apply {
            densityDpi = 320
            screenWidthDp = 200
            screenHeightDp = 200
            smallestScreenWidthDp = 200
        }

        val scaled = WearInterfaceScale.scaledConfiguration(base, 150)

        assertEquals(480, scaled.densityDpi)
        assertEquals(133, scaled.screenWidthDp)
        assertEquals(133, scaled.screenHeightDp)
        assertEquals(133, scaled.smallestScreenWidthDp)
        assertEquals("the base configuration is not modified", 320, base.densityDpi)
        assertEquals(200, base.screenWidthDp)
    }

    @Test
    fun `the baseline configuration is equal in every dimension and an undefined size stays undefined`() {
        val base = Configuration().apply {
            densityDpi = 320
            screenWidthDp = 192
            screenHeightDp = 192
        }

        val same = WearInterfaceScale.scaledConfiguration(base, 100)
        assertNotSame(base, same)
        assertEquals(320, same.densityDpi)
        assertEquals(192, same.screenWidthDp)
        assertEquals(192, same.screenHeightDp)

        val unknown = WearInterfaceScale.scaledConfiguration(Configuration(), 150)
        assertEquals(Configuration.SCREEN_WIDTH_DP_UNDEFINED, unknown.screenWidthDp)
        assertEquals(Configuration.SMALLEST_SCREEN_WIDTH_DP_UNDEFINED, unknown.smallestScreenWidthDp)
    }

    @Test
    fun `a 48 dp declaration grows with the scaled resources the scope hands to composition`() {
        val base = context.resources.getDimension(com.sza.deviceinfo.wear.R.dimen.system_info_touch_target_min)
        val scaledResources = context
            .createConfigurationContext(WearInterfaceScale.scaledConfiguration(context.resources.configuration, 130))
            .resources

        val scaled = scaledResources.getDimension(com.sza.deviceinfo.wear.R.dimen.system_info_touch_target_min)

        assertTrue("48 dp must not shrink: $base -> $scaled", scaled >= base)
        assertEquals(base * 1.3f, scaled, base * 0.03f)
    }
}
