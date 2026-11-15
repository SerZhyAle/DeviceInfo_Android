package com.sza.deviceinfo.wear.ui.common

import android.content.Context
import timber.log.Timber

/** Where a screen was scrolled to: the stable id of the list row at the center and the offset within it. */
data class WearViewportAnchor(val key: String, val offset: Int)

/**
 * Remembers each screen's viewport as an anchor plus an offset (COLLAPSIBLE-GROUP 1.2 section 4 rule 7), never as
 * a row index or an absolute pixel position, so a changed translation, screen size or retired group moves the
 * viewport to the nearest surviving anchor instead of an unrelated place. A missing or unknown anchor restores
 * nothing; restoring is not an edit and writes nothing.
 */
class WearViewportStore(context: Context) {

    private val preferences = context.applicationContext.getSharedPreferences("wear_viewport", Context.MODE_PRIVATE)

    private fun keyName(screenKey: String) = "${screenKey.length}:$screenKey:anchor"

    private fun offsetName(screenKey: String) = "${screenKey.length}:$screenKey:offset"

    fun load(screenKey: String): WearViewportAnchor? {
        val key = preferences.getString(keyName(screenKey), null) ?: return null
        Timber.d("S0023: wear viewport load, anchor=%s", key)
        return WearViewportAnchor(key, preferences.getInt(offsetName(screenKey), 0))
    }

    fun save(screenKey: String, anchor: WearViewportAnchor) {
        preferences.edit()
            .putString(keyName(screenKey), anchor.key)
            .putInt(offsetName(screenKey), anchor.offset)
            .apply()
    }
}

/**
 * The identities a packed row answers to: the keys of every item it holds, in order. Pure and free of Compose
 * types so the anchor rules are testable without a composition.
 */
fun rowAnchorKeys(row: List<WearSettingsItem>): List<String> = row.flatMap { it.keys }

/**
 * Index of the first row that answers to [anchorKey], or -1 when none does. Rows are searched whole because the
 * same item may land in a different row once the screen width changes the packing.
 */
fun findAnchorRow(rowKeys: List<List<String>>, anchorKey: String): Int =
    rowKeys.indexOfFirst { anchorKey in it }
