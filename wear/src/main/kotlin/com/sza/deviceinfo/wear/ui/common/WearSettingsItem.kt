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
 *
 * [keys] are the item's stable identities for viewport memory (S0023): derived from resource entry names, never from
 * the position, and empty for items that are not worth returning to, such as dividers. An item that stands for
 * several things, such as a run of collapsed group headers, lists each of them.
 */
data class WearSettingsItem(
    val fullWidth: Boolean = false,
    val keys: List<String> = emptyList(),
    val content: @Composable (narrow: Boolean) -> Unit
)
