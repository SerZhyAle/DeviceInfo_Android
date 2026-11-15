package com.sza.deviceinfo.ui.help

import com.google.gson.JsonArray
import com.google.gson.JsonElement
import com.google.gson.JsonObject
import com.google.gson.JsonParser

/** The surface ids of the help map that a window of this app passes to [HelpLauncher]. */
object HelpSurfaces {
    const val SYSTEM_INFO = "system-info"
}

/** A control of a surface that has its own entry on the help page: [view] is its resource entry name. */
data class HelpElement(val id: String, val view: String)

/**
 * One row of the help map (CONTEXT-HELP rule 17). Members the reader does not know are ignored (section 3 of the
 * contract), so the map can carry the product's own members, such as the watch row's `entry`.
 */
data class HelpSurface(
    val id: String,
    val form: String,
    val help: String?,
    val parent: String?,
    val anchor: String?,
    val ask: String?,
    val elements: List<HelpElement>,
)

/**
 * The shipped help map, `assets/help/help-map.json`: the one file the resolver and `tools/help/check-help-map.ps1`
 * both read. The tree API of Gson is used on purpose: nothing here is reflected over, so the release variant's
 * shrinker cannot rename a field the map depends on.
 */
class HelpMap private constructor(
    val siteRoot: String,
    val locales: List<String>,
    private val surfaces: Map<String, HelpSurface>,
) {
    fun surface(id: String): HelpSurface? = surfaces[id]

    companion object {
        const val ASSET_PATH = "help/help-map.json"

        fun parse(json: String): HelpMap {
            val root = JsonParser.parseString(json).asJsonObject
            val surfaces = root.getAsJsonArray("surfaces")
                .map { it.asJsonObject }
                .map(::surfaceOf)
                .associateBy { it.id }
            return HelpMap(
                siteRoot = root.string("siteRoot").orEmpty(),
                locales = root.getAsJsonArray("locales").map { it.asString },
                surfaces = surfaces,
            )
        }

        private fun surfaceOf(row: JsonObject): HelpSurface = HelpSurface(
            id = row.string("id").orEmpty(),
            form = row.string("form").orEmpty(),
            help = row.string("help"),
            parent = row.string("parent"),
            anchor = row.string("anchor"),
            ask = row.string("ask"),
            elements = row.getAsJsonArray("elements").orEmpty().map {
                val element = it.asJsonObject
                HelpElement(id = element.string("id").orEmpty(), view = element.string("view").orEmpty())
            },
        )

        private fun JsonObject.string(name: String): String? =
            get(name)?.takeUnless { it.isJsonNull }?.asString

        private fun JsonArray?.orEmpty(): Iterable<JsonElement> = this ?: emptyList()
    }
}
