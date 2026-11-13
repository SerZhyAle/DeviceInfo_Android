package com.sza.deviceinfo.util

import android.view.View
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.updatePadding

/**
 * Applies system bar inset padding to this view to ensure edge-to-edge support.
 */
fun View.applySystemBarInsetPadding(
    applyLeft: Boolean = true,
    applyTop: Boolean = true,
    applyRight: Boolean = true,
    applyBottom: Boolean = true,
) {
    val initialLeft = paddingLeft
    val initialTop = paddingTop
    val initialRight = paddingRight
    val initialBottom = paddingBottom

    ViewCompat.setOnApplyWindowInsetsListener(this) { v, insets ->
        val systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
        val cutout = insets.getInsets(WindowInsetsCompat.Type.displayCutout())

        val left = if (applyLeft) maxOf(systemBars.left, cutout.left) else 0
        val top = if (applyTop) maxOf(systemBars.top, cutout.top) else 0
        val right = if (applyRight) maxOf(systemBars.right, cutout.right) else 0
        val bottom = if (applyBottom) maxOf(systemBars.bottom, cutout.bottom) else 0

        v.updatePadding(
            left = initialLeft + left,
            top = initialTop + top,
            right = initialRight + right,
            bottom = initialBottom + bottom,
        )
        insets
    }
}
