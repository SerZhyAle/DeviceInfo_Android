package com.sza.deviceinfo.wear.ui.common

import android.app.Application
import android.content.Context
import com.sza.deviceinfo.wear.R
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34], application = Application::class)
class WearSectionExpansionStoreTest {
    private lateinit var context: Context

    @Before
    fun clearPreferences() {
        context = RuntimeEnvironment.getApplication()
        context.getSharedPreferences("wear_section_expansion", Context.MODE_PRIVATE).edit().clear().commit()
    }

    @Test
    fun `choices survive a new store and remain independent by screen and group`() {
        val first = WearSectionExpansionStore(context)
        assertFalse(first.isExpanded("apps/systeminfo", R.string.system_info_title))
        first.toggle("apps/systeminfo", R.string.system_info_title)
        first.toggle("apps/systeminfo/fields", R.string.system_info_title)

        val restored = WearSectionExpansionStore(context)
        assertTrue(restored.isExpanded("apps/systeminfo", R.string.system_info_title))
        assertTrue(restored.isExpanded("apps/systeminfo/fields", R.string.system_info_title))
        assertFalse(restored.isExpanded("apps/systeminfo", R.string.system_info_refresh))
        restored.clear("apps/systeminfo")

        val afterClear = WearSectionExpansionStore(context)
        assertFalse(afterClear.isExpanded("apps/systeminfo", R.string.system_info_title))
        assertTrue(afterClear.isExpanded("apps/systeminfo/fields", R.string.system_info_title))
    }
}
