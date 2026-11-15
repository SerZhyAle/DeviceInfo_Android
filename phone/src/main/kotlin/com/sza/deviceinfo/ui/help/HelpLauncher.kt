package com.sza.deviceinfo.ui.help

import android.app.Activity
import android.content.res.Resources
import android.view.View
import androidx.core.os.ConfigurationCompat
import timber.log.Timber
import java.io.IOException

/**
 * The one entry into the help from a window (CONTEXT-HELP rules 1, 3 and 17): the Help action and F1 both call [open],
 * so the key and the button give the same answer. [HelpResolver] decides what to show; [HelpActivity] shows it.
 */
object HelpLauncher {

    @Volatile
    private var cachedMap: HelpMap? = null

    /**
     * Opens the help of [surfaceId]. [focused] is the view that has the focus when F1 is pressed, so the page opens at
     * the entry of the element the user is on; the Help action passes nothing and always gets the top of the page.
     * Returns whether a help page was opened.
     */
    fun open(activity: Activity, surfaceId: String, focused: View? = null): Boolean {
        val map = loadMap(activity) ?: return false
        val target = HelpResolver(map).resolve(surfaceId, viewNamesFrom(activity.resources, focused))
        if (target == null) {
            Timber.w("HelpLauncher: surface %s has no help in the help map", surfaceId)
            return false
        }
        val language = ConfigurationCompat.getLocales(activity.resources.configuration)[0]?.language.orEmpty()
        val locale = HelpPages.localeFor(language, map.locales)
        Timber.d("S0024: help opened for %s at %s#%s in %s", surfaceId, target.helpId, target.anchor, locale)
        activity.startActivity(
            HelpActivity.createIntent(
                context = activity,
                helpId = target.helpId,
                anchor = target.anchor,
                locale = locale,
                siteUrl = HelpPages.siteUrl(map.siteRoot, locale, target.helpId),
            ),
        )
        return true
    }

    private fun loadMap(activity: Activity): HelpMap? {
        cachedMap?.let { return it }
        return try {
            val json = activity.applicationContext.assets.open(HelpMap.ASSET_PATH).bufferedReader().use { it.readText() }
            HelpMap.parse(json).also { cachedMap = it }
        } catch (e: IOException) {
            Timber.e(e, "HelpLauncher: the help map could not be read")
            null
        }
    }

    /** The resource names of [view] and of every view above it that has an id, innermost first. */
    private fun viewNamesFrom(resources: Resources, view: View?): List<String> {
        val names = mutableListOf<String>()
        var current: View? = view
        while (current != null) {
            if (current.id != View.NO_ID) {
                try {
                    names += resources.getResourceEntryName(current.id)
                } catch (e: Resources.NotFoundException) {
                    // A view whose id is not a resource of this app (a framework view) has no entry to match.
                    Timber.v(e, "HelpLauncher: no resource name for view id %d", current.id)
                }
            }
            current = current.parent as? View
        }
        return names
    }
}
