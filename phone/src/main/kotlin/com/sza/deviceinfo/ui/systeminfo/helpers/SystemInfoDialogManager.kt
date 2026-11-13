package com.sza.deviceinfo.ui.systeminfo.helpers

import android.content.Context
import androidx.appcompat.app.AlertDialog
import com.google.android.material.dialog.MaterialAlertDialogBuilder
import com.sza.deviceinfo.R
import com.sza.deviceinfo.core.clipboard.copyTextToClipboard
import com.sza.deviceinfo.core.systeminfo.SystemInfoReport
import com.sza.deviceinfo.domain.usecase.GatherSystemInfoUseCase
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import javax.inject.Inject

/**
 * Turns a [Context] into a gathered or shown system-information report.
 */
class SystemInfoDialogManager @Inject constructor(
    private val gatherSystemInfoUseCase: GatherSystemInfoUseCase
) {

    /** Collects the report off the main thread. */
    suspend fun gather(context: Context): SystemInfoReport {
        return withContext(Dispatchers.IO) {
            gatherSystemInfoUseCase()
        }
    }

    /** Shows [report] in a scrollable dialog. */
    fun show(context: Context, report: SystemInfoReport): AlertDialog? {
        val builder = MaterialAlertDialogBuilder(context)
            .setTitle(R.string.settings_system_info_title)
            .setMessage(report.maskedText)
            .setPositiveButton(android.R.string.ok, null)

        if (report.hasSensitive) {
            builder.setNeutralButton(R.string.system_info_copy_full_report) { _, _ ->
                confirmAndCopyFullReport(context, report.fullText)
            }
        }

        return builder.show()
    }

    private fun confirmAndCopyFullReport(context: Context, fullText: String) {
        MaterialAlertDialogBuilder(context)
            .setTitle(R.string.system_info_reveal_confirm_title)
            .setMessage(R.string.system_info_reveal_confirm_message)
            .setPositiveButton(R.string.system_info_copy_full_report) { _, _ ->
                context.copyTextToClipboard("System info", fullText)
            }
            .setNegativeButton(R.string.cancel, null)
            .show()
    }
}
