package com.sza.deviceinfo.ui.help

/** Where a surface's help is: a help id (a page of the shipped set) and optionally an element anchor on it. */
data class HelpTarget(val helpId: String, val anchor: String?)

/**
 * The one resolver of CONTEXT-HELP rule 17: it takes a surface id and, optionally, the resource names of the views
 * around the focus, and returns the target. Every F1 handler and every help action goes through it
 * ([HelpLauncher]); no window carries help code of its own.
 *
 * - `none` has no help and resolves to nothing.
 * - `inherit` answers with the parent's help, at the anchor its own row names or at the top (0.2 item A).
 * - A row with `ask: "off"` wires neither key nor button, so it resolves to nothing (0.2 item B).
 * - Otherwise F1 pressed on an element that has its own entry goes to that entry's anchor (rule 3); anywhere else, and
 *   for the help button itself, the answer is the top of the page (0.3 item K): the help button is in no row's
 *   `elements`, so its view never matches.
 */
class HelpResolver(private val map: HelpMap) {

    /** [focusedViewNames] is ordered from the focused view outwards, so the innermost element wins. */
    fun resolve(surfaceId: String, focusedViewNames: List<String> = emptyList()): HelpTarget? {
        val surface = map.surface(surfaceId) ?: return null
        if (surface.ask == ASK_OFF) return null
        return when (surface.form) {
            FORM_NONE -> null
            FORM_INHERIT -> {
                val parentHelp = surface.parent?.let(map::surface)?.help ?: return null
                HelpTarget(parentHelp, surface.anchor)
            }
            else -> {
                val helpId = surface.help ?: return null
                val anchor = focusedViewNames.firstNotNullOfOrNull { name ->
                    surface.elements.firstOrNull { it.view == name }?.id
                }
                HelpTarget(helpId, anchor)
            }
        }
    }

    private companion object {
        const val FORM_NONE = "none"
        const val FORM_INHERIT = "inherit"
        const val ASK_OFF = "off"
    }
}
