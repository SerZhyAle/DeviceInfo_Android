package com.sza.deviceinfo.wear.ui.common

import androidx.compose.runtime.mutableStateMapOf
import androidx.compose.runtime.staticCompositionLocalOf
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Remembers which groups of a grouped screen the user had opened, for the lifetime of the process.
 *
 * A missing entry means COLLAPSED. That is what makes a report open as a short list of headings
 * without a second "never opened yet" state to carry.
 */
@Singleton
class WearSectionExpansionStore @Inject constructor() {

    private val expanded = mutableStateMapOf<String, Set<Int>>()

    fun isExpanded(screenKey: String, id: Int): Boolean = expanded[screenKey]?.contains(id) == true

    fun toggle(screenKey: String, id: Int) {
        val current = expanded[screenKey].orEmpty()
        expanded[screenKey] = if (id in current) current - id else current + id
    }

    fun clear(screenKey: String) {
        expanded.remove(screenKey)
    }
}

/**
 * The store as seen from composition. Null means no memory is available.
 */
val LocalWearSectionExpansion = staticCompositionLocalOf<WearSectionExpansionStore?> { null }
