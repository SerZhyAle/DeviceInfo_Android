package com.sza.deviceinfo.ui.systeminfo.helpers

import android.Manifest
import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.NotificationManagerCompat
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner
import com.google.android.material.dialog.MaterialAlertDialogBuilder
import com.google.android.material.snackbar.Snackbar
import com.sza.deviceinfo.R
import com.sza.deviceinfo.data.local.preferences.NotificationPromptStore
import com.sza.deviceinfo.databinding.ActivitySystemInfoBinding
import timber.log.Timber
import javax.inject.Inject

/**
 * Asks for the notification permission on the System info screen, and keeps a way back after a refusal.
 *
 * The watch's Send to phone is declined while notifications are off, and the receiver that declines it runs
 * in a listener service with no Activity, so the phone app asks for itself: once, on the first open, with a
 * plain explanation before the system prompt. After that the only entry is the overflow menu item, which
 * exists while notifications are off and goes to the system prompt or, once that was answered, to the app's
 * notification settings (Android raises the system prompt at most once after a refusal).
 *
 * One instance serves one screen: [bind] registers the permission launcher and must run in `onCreate`.
 */
class NotificationPermissionCoordinator @Inject constructor(
    private val store: NotificationPromptStore,
) {
    private var launcher: ActivityResultLauncher<String>? = null
    private var explanation: AlertDialog? = null

    fun bind(activity: AppCompatActivity, binding: ActivitySystemInfoBinding) {
        launcher = activity.registerForActivityResult(ActivityResultContracts.RequestPermission()) { granted ->
            onSystemPromptAnswered(activity, binding, granted)
        }
        activity.lifecycle.addObserver(object : DefaultLifecycleObserver {
            override fun onDestroy(owner: LifecycleOwner) {
                explanation?.dismiss()
                explanation = null
                launcher = null
            }
        })
    }

    /** Raises the explanation once, after the screen has rendered, when the policy says so. */
    fun onScreenShown(activity: AppCompatActivity) {
        if (activity.isFinishing || activity.isDestroyed) return
        val raise = NotificationPromptPolicy.shouldExplainOnOpen(
            sdkInt = Build.VERSION.SDK_INT,
            notificationsEnabled = notificationsEnabled(activity),
            explained = store.explained,
            systemPromptAnswered = store.systemPromptAnswered,
        )
        if (!raise) return
        Timber.d("S0011: explaining the notification request on the first open")
        explanation = MaterialAlertDialogBuilder(activity)
            .setTitle(R.string.notifications_prompt_title)
            .setMessage(R.string.notifications_prompt_message)
            .setPositiveButton(R.string.notifications_prompt_continue) { _, _ ->
                store.explained = true
                requestPermission()
            }
            .setNegativeButton(R.string.notifications_prompt_later) { _, _ -> store.explained = true }
            .setOnCancelListener { store.explained = true }
            .show()
    }

    /** Shows the overflow entry exactly while notifications are off; called on every resume. */
    fun refreshMenu(binding: ActivitySystemInfoBinding) {
        val item = binding.systemInfoToolbar.menu.findItem(R.id.action_system_info_notifications) ?: return
        item.isVisible = NotificationPromptPolicy.isMenuEntryVisible(notificationsEnabled(binding.root.context))
    }

    /** The overflow entry was tapped. */
    fun onMenuAction(activity: Activity) {
        val action = NotificationPromptPolicy.menuAction(Build.VERSION.SDK_INT, store.systemPromptAnswered)
        Timber.d("S0011: notifications menu entry tapped, action=%s", action)
        when (action) {
            NotificationMenuAction.REQUEST_PERMISSION -> requestPermission()
            NotificationMenuAction.OPEN_SETTINGS -> openNotificationSettings(activity)
        }
    }

    private fun requestPermission() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) return
        launcher?.launch(Manifest.permission.POST_NOTIFICATIONS)
    }

    private fun onSystemPromptAnswered(
        activity: AppCompatActivity,
        binding: ActivitySystemInfoBinding,
        granted: Boolean,
    ) {
        Timber.d("S0011: the system notification prompt was answered, granted=%b", granted)
        store.systemPromptAnswered = true
        refreshMenu(binding)
        if (granted || activity.isFinishing || activity.isDestroyed) return
        Snackbar.make(binding.root, R.string.notifications_denied_message, DENIED_MESSAGE_MILLIS)
            .setAction(R.string.notifications_open_settings) { openNotificationSettings(activity) }
            .show()
    }

    private fun openNotificationSettings(activity: Activity) {
        val appSettings = Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
            .putExtra(Settings.EXTRA_APP_PACKAGE, activity.packageName)
        try {
            activity.startActivity(appSettings)
        } catch (e: ActivityNotFoundException) {
            Timber.w(e, "NotificationPermissionCoordinator: no screen for the app notification settings")
            openApplicationDetails(activity)
        }
    }

    private fun openApplicationDetails(activity: Activity) {
        val details = Intent(
            Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
            Uri.fromParts("package", activity.packageName, null),
        )
        try {
            activity.startActivity(details)
        } catch (e: ActivityNotFoundException) {
            Timber.w(e, "NotificationPermissionCoordinator: no screen for the application details")
        }
    }

    private fun notificationsEnabled(context: Context): Boolean =
        NotificationManagerCompat.from(context).areNotificationsEnabled()

    private companion object {
        /** Long enough to read the message and reach the action; a plain LENGTH_LONG is about 2.75 s. */
        const val DENIED_MESSAGE_MILLIS = 8_000
    }
}
