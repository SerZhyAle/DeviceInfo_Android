package com.sza.deviceinfo.ui.help

/**
 * Where a help page is, in the app and on the site (CONTEXT-HELP rules 12, 13 and 15). The pages are the app's own
 * assets: `assets/help/<locale>/<help id>.html`, the same bytes the site publishes under `help/<locale>/`.
 */
object HelpPages {
    const val SOURCE_LOCALE = "en"
    private const val ASSET_URL_ROOT = "file:///android_asset/help"

    /** The page language: the app's language when a page set exists for it, the source language otherwise. */
    fun localeFor(language: String, shipped: List<String>): String =
        if (language in shipped) language else SOURCE_LOCALE

    fun assetUrl(locale: String, helpId: String, anchor: String?): String {
        val page = "$ASSET_URL_ROOT/$locale/$helpId.html"
        return if (anchor.isNullOrEmpty()) page else "$page#$anchor"
    }

    /** The same page on the product's site, for the "Open on the site" action. */
    fun siteUrl(siteRoot: String, locale: String, helpId: String): String = "$siteRoot$locale/$helpId.html"

    /** A link inside the shipped pages stays in the viewer; every other address leaves for the system browser. */
    fun isInternal(url: String): Boolean = url.startsWith("$ASSET_URL_ROOT/")
}
