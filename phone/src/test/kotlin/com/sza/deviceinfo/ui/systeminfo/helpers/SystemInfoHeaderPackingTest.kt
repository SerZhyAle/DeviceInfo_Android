package com.sza.deviceinfo.ui.systeminfo.helpers

import com.sza.deviceinfo.ui.systeminfo.model.SystemInfoListItem
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class SystemInfoHeaderPackingTest {

    @Test
    fun `the grid has one span per dp of usable width and never fewer than one`() {
        assertEquals(360, SystemInfoHeaderPacking.spanCountFor(usableWidthPx = 1080, density = 3f))
        assertEquals(1, SystemInfoHeaderPacking.spanCountFor(usableWidthPx = 0, density = 3f))
        assertEquals(1, SystemInfoHeaderPacking.spanCountFor(usableWidthPx = 1080, density = 0f))
        assertEquals(1, SystemInfoHeaderPacking.spanCountFor(usableWidthPx = 2, density = 3f))
    }

    @Test
    fun `a header takes the spans its content needs, rounded up`() {
        // 1080 px over 360 spans: three pixels per span.
        assertEquals(100, SystemInfoHeaderPacking.spanSize(naturalWidthPx = 300, usableWidthPx = 1080, spanCount = 360))
        assertEquals(101, SystemInfoHeaderPacking.spanSize(naturalWidthPx = 301, usableWidthPx = 1080, spanCount = 360))
    }

    @Test
    fun `headers of different lengths get different widths instead of equal tiles`() {
        val short = SystemInfoHeaderPacking.spanSize(naturalWidthPx = 330, usableWidthPx = 1080, spanCount = 360)
        val long = SystemInfoHeaderPacking.spanSize(naturalWidthPx = 600, usableWidthPx = 1080, spanCount = 360)

        assertTrue(short < long)
        assertTrue(short + long < 360)
    }

    @Test
    fun `a header wider than the row takes the whole row and is never below one span`() {
        assertEquals(360, SystemInfoHeaderPacking.spanSize(naturalWidthPx = 5000, usableWidthPx = 1080, spanCount = 360))
        assertEquals(1, SystemInfoHeaderPacking.spanSize(naturalWidthPx = 0, usableWidthPx = 1080, spanCount = 360))
    }

    @Test
    fun `before the width is known the grid is one span and a header fits it`() {
        assertEquals(1, SystemInfoHeaderPacking.spanSize(naturalWidthPx = 300, usableWidthPx = 0, spanCount = 1))
        assertEquals(1, SystemInfoHeaderPacking.spanSize(naturalWidthPx = 300, usableWidthPx = 1080, spanCount = 1))
    }

    @Test
    fun `an item is found by its group and label and not by its position`() {
        val items = listOf(
            header("device"),
            field("device", "Model"),
            field("device", "Brand"),
            header("battery"),
            field("battery", "Level"),
        )

        assertEquals(2, items.indexOfAnchor("f:device/Brand"))
        assertEquals(3, items.indexOfAnchor("h:battery"))
        assertNull(SystemInfoListItem.EmptyState("nothing").anchorKey())
    }

    @Test
    fun `a field that is no longer listed falls back to its group and a retired group restores nothing`() {
        val items = listOf(header("device"), field("device", "Model"), header("a/b"))

        assertEquals(0, items.indexOfAnchor("f:device/Brand"))
        assertEquals(2, items.indexOfAnchor("f:a/b/Label"))
        assertEquals(-1, items.indexOfAnchor("f:retired/Label"))
        assertEquals(-1, items.indexOfAnchor("h:retired"))
    }

    private fun header(stateKey: String) =
        SystemInfoListItem.SectionHeader(title = stateKey, stateKey = stateKey, count = 2, isExpanded = true, iconRes = null)

    private fun field(sectionKey: String, label: String) =
        SystemInfoListItem.Field(sectionKey = sectionKey, label = label, value = "v", isShaded = false)
}
