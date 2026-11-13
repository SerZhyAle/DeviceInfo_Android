package com.sza.deviceinfo.wear.ui.apps.systeminfo

import androidx.annotation.StringRes
import com.sza.deviceinfo.wear.domain.model.WearSystemInfoSection

/**
 * What the system-information screen draws.
 *
 * [loading] is a field of its own rather than an empty [sections] list: the watch has not been asked yet,
 * versus the watch answered nothing at all.
 *
 * [refreshing] is separate from [loading]: a re-read has a report to show already.
 *
 * [sendOutcomeRes] survives the send it describes and is cleared only by the next send:
 * the watch has no Snackbar host, so the answer stays on screen as a line of text until it is replaced.
 */
data class SystemInfoUiState(
    val loading: Boolean = true,
    val refreshing: Boolean = false,
    val sending: Boolean = false,
    @StringRes val sendOutcomeRes: Int? = null,
    val sections: List<WearSystemInfoSection> = emptyList()
)
