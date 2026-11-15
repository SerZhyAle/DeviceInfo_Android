package com.sza.deviceinfo.ui.help

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import java.io.File

/**
 * The resolver against the real shipped map (`assets/help/help-map.json`), plus the pure helpers of the page address.
 * Gradle runs a module's unit tests with the module directory as the working directory.
 */
class HelpResolverTest {

    private val shipped = File("src/main/assets/help/help-map.json").readText()
    private val resolver = HelpResolver(HelpMap.parse(shipped))

    @Test
    fun `the report window resolves to the top of its page when nothing has the focus`() {
        assertEquals(HelpTarget("system-info", null), resolver.resolve(HelpSurfaces.SYSTEM_INFO))
    }

    @Test
    fun `F1 on an element with its own entry goes to that entry`() {
        assertEquals(
            HelpTarget("system-info", "search"),
            resolver.resolve(HelpSurfaces.SYSTEM_INFO, listOf("systemInfoSearchView")),
        )
    }

    @Test
    fun `the innermost element on the way up from the focus wins`() {
        val names = listOf("tvFieldValue", "rowSystemInfoField", "systemInfoRecyclerView")
        assertEquals(HelpTarget("system-info", "field"), resolver.resolve(HelpSurfaces.SYSTEM_INFO, names))
    }

    @Test
    fun `the help action itself opens the top, never its own entry`() {
        assertEquals(HelpTarget("system-info", null), resolver.resolve(HelpSurfaces.SYSTEM_INFO, listOf("action_help")))
    }

    @Test
    fun `a view the map does not know opens the top`() {
        assertEquals(HelpTarget("system-info", null), resolver.resolve(HelpSurfaces.SYSTEM_INFO, listOf("unknown_view")))
    }

    @Test
    fun `a surface that is none has no help and so does an unknown surface`() {
        assertNull(resolver.resolve("launcher"))
        assertNull(resolver.resolve("help-viewer"))
        assertNull(resolver.resolve("notifications-prompt"))
        assertNull(resolver.resolve("no-such-surface"))
    }

    @Test
    fun `the watch row points at the watch page`() {
        assertEquals(HelpTarget("watch-system-info", null), resolver.resolve("watch-system-info"))
    }

    @Test
    fun `an inherit row answers with the parent page at its own anchor`() {
        val map = HelpMap.parse(
            """
            {"locales":["en"],"siteRoot":"https://example.invalid/help/","surfaces":[
              {"id":"main","form":"page","help":"main"},
              {"id":"rename","form":"inherit","parent":"main","anchor":"rename","reason":"x"},
              {"id":"preview","form":"inherit","parent":"main","ask":"off","reason":"x"},
              {"id":"orphan","form":"inherit","parent":"missing","reason":"x"}
            ]}
            """.trimIndent(),
        )
        val resolverUnderTest = HelpResolver(map)
        assertEquals(HelpTarget("main", "rename"), resolverUnderTest.resolve("rename"))
        assertNull(resolverUnderTest.resolve("preview"))
        assertNull(resolverUnderTest.resolve("orphan"))
    }

    @Test
    fun `every element of the map has its anchor in every shipped page of its surface`() {
        val map = HelpMap.parse(shipped)
        val surface = checkNotNull(map.surface(HelpSurfaces.SYSTEM_INFO))
        assertTrue(surface.elements.isNotEmpty())
        for (locale in map.locales) {
            val page = File("src/main/assets/help/$locale/${surface.help}.html").readText()
            for (element in surface.elements) {
                assertTrue("$locale page has no anchor ${element.id}", page.contains("id=\"${element.id}\""))
            }
        }
    }

    @Test
    fun `the page set exists in every shipped locale`() {
        val map = HelpMap.parse(shipped)
        for (locale in map.locales) {
            for (page in listOf("index", "system-info", "watch-system-info")) {
                assertTrue("missing $locale/$page.html", File("src/main/assets/help/$locale/$page.html").isFile)
            }
        }
    }

    @Test
    fun `the page language follows the app and falls back to the source language`() {
        val shippedLocales = HelpMap.parse(shipped).locales
        assertEquals("uk", HelpPages.localeFor("uk", shippedLocales))
        assertEquals("ru", HelpPages.localeFor("ru", shippedLocales))
        assertEquals("en", HelpPages.localeFor("de", shippedLocales))
        assertEquals("en", HelpPages.localeFor("", shippedLocales))
    }

    @Test
    fun `page addresses carry the locale, the help id and the anchor`() {
        assertEquals("file:///android_asset/help/ru/system-info.html", HelpPages.assetUrl("ru", "system-info", null))
        assertEquals("file:///android_asset/help/en/system-info.html#search", HelpPages.assetUrl("en", "system-info", "search"))
        val siteRoot = HelpMap.parse(shipped).siteRoot
        assertEquals("https://serzhyale.github.io/DeviceInfo_Android/help/", siteRoot)
        assertEquals(
            "https://serzhyale.github.io/DeviceInfo_Android/help/uk/system-info.html",
            HelpPages.siteUrl(siteRoot, "uk", "system-info"),
        )
        assertNotNull(HelpPages.assetUrl("en", "index", null))
    }

    @Test
    fun `only the shipped pages stay in the viewer`() {
        assertTrue(HelpPages.isInternal("file:///android_asset/help/en/index.html"))
        assertTrue(!HelpPages.isInternal("https://serzhyale.github.io/DeviceInfo_Android/"))
        assertTrue(!HelpPages.isInternal("file:///sdcard/other.html"))
    }
}
