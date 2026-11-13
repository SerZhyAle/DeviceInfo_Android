package com.sza.deviceinfo.data.local.preferences

import android.content.Context
import dagger.hilt.android.qualifiers.ApplicationContext
import javax.inject.Inject

/**
 * Remembers how far the notification permission request has gone, so the screen never asks twice.
 *
 * Two facts, kept apart because they unlock different things: the explanation shown on the first open
 * is skippable and must not return by itself, while the menu entry still has to know whether the system
 * prompt was ever answered (a refused system prompt cannot be raised again, only the settings can).
 */
interface NotificationPromptStore {

    /** True once the user answered the explanation dialog, by either button or by dismissing it. */
    var explained: Boolean

    /** True once the system permission prompt was answered, granted or refused. */
    var systemPromptAnswered: Boolean

    companion object {
        const val NAMESPACE = "notification_prompt_state"
    }
}

/** Default [NotificationPromptStore] backed by SharedPreferences. */
class SharedPreferencesNotificationPromptStore @Inject constructor(
    @ApplicationContext context: Context,
) : NotificationPromptStore {

    private val prefs = context.applicationContext
        .getSharedPreferences(NotificationPromptStore.NAMESPACE, Context.MODE_PRIVATE)

    override var explained: Boolean
        get() = prefs.getBoolean(KEY_EXPLAINED, false)
        set(value) = prefs.edit().putBoolean(KEY_EXPLAINED, value).apply()

    override var systemPromptAnswered: Boolean
        get() = prefs.getBoolean(KEY_SYSTEM_PROMPT_ANSWERED, false)
        set(value) = prefs.edit().putBoolean(KEY_SYSTEM_PROMPT_ANSWERED, value).apply()

    private companion object {
        const val KEY_EXPLAINED = "explained"
        const val KEY_SYSTEM_PROMPT_ANSWERED = "system_prompt_answered"
    }
}
