package com.sza.deviceinfo.core.clipboard

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.os.Build
import android.widget.Toast
import androidx.core.content.getSystemService
import com.sza.deviceinfo.R

/**
 * Puts text on the system clipboard.
 *
 * [label] reaches the user - the system clipboard chooser shows it beside the entry.
 */
internal fun Context.copyTextToClipboard(label: String, text: String) {
    val clipboard = getSystemService<ClipboardManager>() ?: return
    clipboard.setPrimaryClip(ClipData.newPlainText(label, text))
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
        Toast.makeText(this, R.string.copied_to_clipboard, Toast.LENGTH_SHORT).show()
    }
}
