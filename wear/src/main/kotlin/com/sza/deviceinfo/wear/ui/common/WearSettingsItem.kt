package com.sza.deviceinfo.wear.ui.common

import androidx.compose.runtime.Composable

/**
 * One settings control as it is handed to the row layout.
 *
 * [fullWidth] is declared by the caller and never derived from the touch-target rule.
 *
 * [content] is told whether it ended up sharing its row, because an item marked narrow can still be
 * handed the whole width by the odd-group rule, and the narrow and full-width forms of a control are
 * different shapes rather than one shape at two sizes.
 */
data class WearSettingsItem(
    val fullWidth: Boolean = false,
    val content: @Composable (narrow: Boolean) -> Unit
)
