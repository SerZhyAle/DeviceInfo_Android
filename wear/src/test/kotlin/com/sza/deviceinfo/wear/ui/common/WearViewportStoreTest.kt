package com.sza.deviceinfo.wear.ui.common

import android.app.Application
import android.content.Context
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34], application = Application::class)
class WearViewportStoreTest {
    private lateinit var context: Context

    @Before
    fun clearPreferences() {
        context = RuntimeEnvironment.getApplication()
        context.getSharedPreferences("wear_viewport", Context.MODE_PRIVATE).edit().clear().commit()
    }

    @Test
    fun `an anchor survives a new store and stays separate by screen`() {
        WearViewportStore(context).save("apps/systeminfo", WearViewportAnchor("section:sysinfo_group_hardware", 12))

        val restored = WearViewportStore(context)
        assertEquals(WearViewportAnchor("section:sysinfo_group_hardware", 12), restored.load("apps/systeminfo"))
        assertNull(restored.load("apps/other"))
    }

    @Test
    fun `an anchor is found by identity in whichever row now holds it and a retired anchor restores nothing`() {
        val rowKeys = listOf(
            listOf("section:a", "section:b"),
            emptyList(),
            listOf("field:a/x", "field:a/y"),
        )

        assertEquals(0, findAnchorRow(rowKeys, "section:b"))
        assertEquals(2, findAnchorRow(rowKeys, "field:a/y"))
        assertEquals(-1, findAnchorRow(rowKeys, "section:retired"))
    }

    @Test
    fun `a row answers to the keys of every item it holds`() {
        val row = listOf(
            WearSettingsItem(keys = listOf("field:a/x")) { },
            WearSettingsItem { },
            WearSettingsItem(keys = listOf("field:a/y", "field:a/z")) { },
        )

        assertEquals(listOf("field:a/x", "field:a/y", "field:a/z"), rowAnchorKeys(row))
    }
}
