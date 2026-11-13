package com.sza.deviceinfo.data.local.preferences

import android.content.Context

/**
 * Single source of truth for collapsible-section expanded state.
 *
 * Keys are caller-supplied `<screen>__<section>` strings.
 * The abstraction hides the storage medium so it can be swapped later without touching screens.
 */
interface CollapsibleSectionStore {

    fun isExpanded(key: String, default: Boolean): Boolean

    fun setExpanded(key: String, expanded: Boolean)

    companion object {
        /** Consolidated SharedPreferences namespace for collapsible section states. */
        const val NAMESPACE = "collapsible_sections_state"
    }
}

/**
 * Default [CollapsibleSectionStore] backed by SharedPreferences.
 */
class SharedPreferencesCollapsibleSectionStore(context: Context) : CollapsibleSectionStore {

    private val prefs = context.applicationContext
        .getSharedPreferences(CollapsibleSectionStore.NAMESPACE, Context.MODE_PRIVATE)

    override fun isExpanded(key: String, default: Boolean): Boolean =
        prefs.getBoolean(key, default)

    override fun setExpanded(key: String, expanded: Boolean) {
        prefs.edit().putBoolean(key, expanded).apply()
    }
}
