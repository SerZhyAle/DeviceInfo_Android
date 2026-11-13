package com.sza.deviceinfo.ui.systeminfo.helpers

import android.os.Build

/** What the "Turn on notifications" menu entry does when tapped. */
enum class NotificationMenuAction {
    /** The system permission prompt: Android 13 or later, and it was never answered. */
    REQUEST_PERMISSION,

    /** The app's notification settings: the prompt was answered, or there is no run-time permission. */
    OPEN_SETTINGS,
}

/**
 * Decides when the System info screen asks for notifications. Pure, so the rules are tested without a device.
 *
 * The watch's Send to phone is declined while notifications are off, so the app asks itself: the receiver
 * runs in a listener service with no Activity and cannot show a prompt.
 */
object NotificationPromptPolicy {

    /**
     * Whether the screen raises the explanation by itself. Only on Android 13 or later (below it the
     * permission does not exist), only while notifications are off, and only until the user answered the
     * explanation or the system prompt once.
     */
    fun shouldExplainOnOpen(
        sdkInt: Int,
        notificationsEnabled: Boolean,
        explained: Boolean,
        systemPromptAnswered: Boolean,
    ): Boolean = hasRuntimePermission(sdkInt) && !notificationsEnabled && !explained && !systemPromptAnswered

    /** The menu entry exists exactly while notifications are off. */
    fun isMenuEntryVisible(notificationsEnabled: Boolean): Boolean = !notificationsEnabled

    /**
     * Android never shows the system prompt again after a refusal, so once it was answered the entry
     * goes to the settings; a prompt nobody answered yet is still worth raising directly.
     */
    fun menuAction(sdkInt: Int, systemPromptAnswered: Boolean): NotificationMenuAction =
        if (hasRuntimePermission(sdkInt) && !systemPromptAnswered) {
            NotificationMenuAction.REQUEST_PERMISSION
        } else {
            NotificationMenuAction.OPEN_SETTINGS
        }

    private fun hasRuntimePermission(sdkInt: Int): Boolean = sdkInt >= Build.VERSION_CODES.TIRAMISU
}
