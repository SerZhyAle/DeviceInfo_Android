package com.sza.deviceinfo.ui.systeminfo.helpers

import androidx.appcompat.app.AppCompatActivity
import com.google.android.material.dialog.MaterialAlertDialogBuilder
import com.sza.deviceinfo.R
import com.sza.deviceinfo.ui.common.InterfaceScale
import timber.log.Timber

/**
 * The interface size choice (S0023, exception E1): a short list of the supported steps, the current one selected.
 * Choosing a step stores it and re-creates the screen, which reads it back when it is created (`InterfaceScale.wrap`),
 * so the whole screen changes at once and no target moves under an active interaction (UI-SIZING 1.2 section 2 rule 1).
 * Choosing the current step, or Cancel, changes nothing. A list of radio rows is a native control: it takes touch,
 * a hardware keyboard, D-pad and mouse like every other dialog of the app.
 */
object InterfaceScalePicker {

    fun show(activity: AppCompatActivity) {
        val current = InterfaceScale.read(activity)
        Timber.d("S0023: interface size dialog opened, current=%d", current)
        val steps = InterfaceScale.STEPS
        val labels = steps.map { activity.getString(R.string.sysinfo_interface_size_option, it) }.toTypedArray()
        MaterialAlertDialogBuilder(activity)
            .setTitle(R.string.sysinfo_action_interface_size)
            .setSingleChoiceItems(labels, steps.indexOf(current)) { dialog, which ->
                dialog.dismiss()
                val chosen = steps[which]
                if (chosen != current) {
                    InterfaceScale.write(activity, chosen)
                    activity.recreate()
                }
            }
            .setNegativeButton(android.R.string.cancel, null)
            .show()
    }
}
