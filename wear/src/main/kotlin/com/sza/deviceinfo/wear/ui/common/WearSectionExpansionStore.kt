package com.sza.deviceinfo.wear.ui.common

import android.content.Context
import androidx.compose.runtime.mutableStateMapOf
import androidx.compose.runtime.staticCompositionLocalOf
import dagger.hilt.android.qualifiers.ApplicationContext
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Remembers independently opened groups by screen and stable resource entry name across launches.
 *
 * A missing entry means COLLAPSED. That is what makes a report open as a short list of headings
 * without a second "never opened yet" state to carry.
 */
@Singleton
class WearSectionExpansionStore @Inject constructor(@ApplicationContext private val context: Context) {

    private val preferences = context.getSharedPreferences("wear_section_expansion", Context.MODE_PRIVATE)
    private val expanded = mutableStateMapOf<String, Boolean>()

    private fun prefix(screenKey: String) = "${screenKey.length}:$screenKey:"

    private fun key(screenKey: String, id: Int) = prefix(screenKey) + context.resources.getResourceEntryName(id)

    fun isExpanded(screenKey: String, id: Int): Boolean {
        val key = key(screenKey, id)
        return expanded[key] ?: preferences.getBoolean(key, false)
    }

    fun toggle(screenKey: String, id: Int) {
        val key = key(screenKey, id)
        val next = !isExpanded(screenKey, id)
        expanded[key] = next
        preferences.edit().putBoolean(key, next).apply()
    }

    fun clear(screenKey: String) {
        val prefix = prefix(screenKey)
        expanded.keys.filter { it.startsWith(prefix) }.forEach { expanded.remove(it) }
        val editor = preferences.edit()
        preferences.all.keys.filter { it.startsWith(prefix) }.forEach { editor.remove(it) }
        editor.apply()
    }
}

/**
 * The store as seen from composition. Null means no memory is available.
 */
val LocalWearSectionExpansion = staticCompositionLocalOf<WearSectionExpansionStore?> { null }
