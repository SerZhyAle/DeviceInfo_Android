package com.sza.deviceinfo.wear.ui.apps.systeminfo

import androidx.annotation.DrawableRes
import androidx.annotation.StringRes
import com.sza.deviceinfo.wear.R

/**
 * The glyph shown before the title of every header `SectionDisclosure` draws: the nine report sections and the Help
 * row at the end of the list (S0022, S0035).
 *
 * The headers are one sibling set, so every one of them has a glyph (ICON-RENDER 0.25 section 25 rule 1). The same
 * meaning carries the same glyph and the same drawable name on both sides where the phone has it: the phone's
 * `SystemInfoGroupIcons` is the other half, and `docs/design/tokens.json` is the one table both are held to by
 * `tools/design/check-tokens.ps1`. Device, Health and Environment have no phone group of their own; they take the
 * watch's own glyphs from the table's `watchOnly` rows (`ic_watch`, `ic_sysinfo_health`, `ic_sysinfo_environment`, the
 * three meanings proposed in the shared catalog), and Help takes the phone's `ic_help_outline`. The same check fails
 * when a title string drawn as a header is missing here.
 */
internal object WearSectionIcons {

    private val ICONS: Map<Int, Int> = mapOf(
        R.string.system_info_section_device to R.drawable.ic_watch,
        R.string.system_info_section_app to R.drawable.ic_apps,
        R.string.system_info_section_health to R.drawable.ic_sysinfo_health,
        R.string.system_info_section_sensors to R.drawable.ic_compass,
        R.string.system_info_section_environment to R.drawable.ic_sysinfo_environment,
        R.string.system_info_section_memory to R.drawable.ic_sysinfo_memory,
        R.string.system_info_section_storage to R.drawable.ic_storage,
        R.string.system_info_section_radio to R.drawable.ic_wifi,
        R.string.system_info_section_phone to R.drawable.ic_profile_personal_smartphone,
        R.string.system_info_help_title to R.drawable.ic_help_outline,
    )

    @DrawableRes
    fun iconFor(@StringRes titleRes: Int): Int? = ICONS[titleRes]
}
