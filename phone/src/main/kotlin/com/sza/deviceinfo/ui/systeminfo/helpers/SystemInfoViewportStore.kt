package com.sza.deviceinfo.ui.systeminfo.helpers

import android.content.Context
import com.sza.deviceinfo.ui.systeminfo.model.SystemInfoListItem
import dagger.hilt.android.qualifiers.ApplicationContext
import timber.log.Timber
import javax.inject.Inject

/** Where the report was scrolled to: the stable id of the first visible item and its offset from the list's top. */
data class SystemInfoViewportAnchor(val key: String, val offsetPx: Int)

/**
 * The stable identity of a list item for viewport memory (COLLAPSIBLE-GROUP 1.2 section 4 rule 7): a header by its
 * group key and a field by its group key and label, never by position or by the localized group title. The empty
 * state has none, so it is never an anchor.
 */
fun SystemInfoListItem.anchorKey(): String? = when (this) {
    is SystemInfoListItem.SectionHeader -> "h:$stateKey"
    is SystemInfoListItem.Field -> "f:$sectionKey/$label"
    is SystemInfoListItem.EmptyState -> null
}

/**
 * Index of the item that answers to [anchorKey]. A field that is no longer listed falls back to its group's header,
 * and an id that is gone altogether returns -1, so a retired group or a changed translation restores nothing
 * instead of an unrelated place.
 */
fun List<SystemInfoListItem>.indexOfAnchor(anchorKey: String): Int {
    val exact = indexOfFirst { it.anchorKey() == anchorKey }
    if (exact >= 0 || !anchorKey.startsWith("f:")) return exact
    // A group key may itself contain a slash, so the owning header is found by prefix rather than by splitting.
    return indexOfFirst { it is SystemInfoListItem.SectionHeader && anchorKey.startsWith("f:${it.stateKey}/") }
}

/**
 * Remembers the report's viewport as an anchor plus an offset across launches. Restoring it is not an edit and
 * writes nothing.
 */
class SystemInfoViewportStore @Inject constructor(@ApplicationContext context: Context) {

    private val preferences = context.getSharedPreferences("system_info_viewport", Context.MODE_PRIVATE)

    fun load(): SystemInfoViewportAnchor? {
        val key = preferences.getString(KEY_ANCHOR, null) ?: return null
        Timber.d("S0023: phone viewport load, anchor=%s", key)
        return SystemInfoViewportAnchor(key, preferences.getInt(KEY_OFFSET, 0))
    }

    fun save(anchor: SystemInfoViewportAnchor) {
        preferences.edit().putString(KEY_ANCHOR, anchor.key).putInt(KEY_OFFSET, anchor.offsetPx).apply()
    }

    private companion object {
        const val KEY_ANCHOR = "anchor"
        const val KEY_OFFSET = "offset"
    }
}
