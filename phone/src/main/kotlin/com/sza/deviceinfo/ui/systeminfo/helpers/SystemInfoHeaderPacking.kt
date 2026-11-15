package com.sza.deviceinfo.ui.systeminfo.helpers

import kotlin.math.ceil

/**
 * Content-sized packing of collapsed group headers (COLLAPSIBLE-GROUP 1.2 section 4 rules 3-4, S0023 exception E3).
 *
 * The list is a grid with one span per density-independent pixel of usable width, and a collapsed header takes the
 * number of spans its content needs, so consecutive collapsed headers share a row at their own widths and wrap to the
 * next row when the row is full. Spare width stays empty instead of being divided into equal tiles. An expanded
 * header, a field and the empty state always take the whole row, which keeps an expanded header in its place in group
 * order with its body directly below.
 *
 * Pure on purpose: no Android types, so the arithmetic is testable without a device.
 */
object SystemInfoHeaderPacking {

    /** One span per dp of [usableWidthPx], at least one, so widths follow content to within a dp. */
    fun spanCountFor(usableWidthPx: Int, density: Float): Int {
        if (usableWidthPx <= 0 || density <= 0f) return 1
        return (usableWidthPx / density).toInt().coerceAtLeast(1)
    }

    /**
     * Spans for a cell that needs [naturalWidthPx] on a grid of [spanCount] spans over [usableWidthPx]: rounded up so
     * the content fits, never below one span and never above the whole row.
     */
    fun spanSize(naturalWidthPx: Int, usableWidthPx: Int, spanCount: Int): Int {
        if (spanCount <= 1 || usableWidthPx <= 0) return spanCount.coerceAtLeast(1)
        val spans = ceil(naturalWidthPx.toDouble() * spanCount / usableWidthPx).toInt()
        return spans.coerceIn(1, spanCount)
    }
}
