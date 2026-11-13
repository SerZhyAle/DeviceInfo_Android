package com.sza.deviceinfo.buildlogic

import java.time.LocalDateTime
import java.time.YearMonth
import java.time.format.DateTimeFormatter

/**
 * The two package families of this product. Both install under one application id, so they own disjoint
 * bands of the last digit of the versionCode (PACKAGE-VERSIONING rule 3): the phone app owns 0..5 in
 * 10-minute slots, the watch app owns 6..9 in 15-minute slots.
 */
enum class PackageFamily(private val firstBand: Int, private val slotMinutes: Int) {
    PHONE(firstBand = 0, slotMinutes = 10),
    WEAR(firstBand = 6, slotMinutes = 15);

    /** The family's map of a minute (0..59) into its band of the last versionCode digit. */
    fun partition(minute: Int): Int = firstBand + minute / slotMinutes
}

/**
 * PACKAGE-VERSIONING, Android profile (rules 1 to 7), for the phone and the watch app.
 *
 * One instant, `yyMMddHHmm` of the build machine's local wall clock, renders both fields: versionName
 * `Y.YM.MDDH.Hmm` is those ten digits with a dot after the first, third and seventh; versionCode is
 * `yyMMddHH * 10 + p`, where `p` is the family's partition of the minute. Nothing is typed by hand and
 * nothing is parsed out of a version except to check a pair that somebody pinned or checked in.
 */
object VersionStamp {
    /** The two renderings of one instant. */
    data class Stamp(val name: String, val code: Int)

    /** Rule 5: the pinned pair, passed together or not at all; the watch app needs its own code. */
    const val PIN_NAME = "deviceinfo.pin.versionName"
    const val PIN_CODE_PHONE = "deviceinfo.pin.versionCode.phone"
    const val PIN_CODE_WEAR = "deviceinfo.pin.versionCode.wear"

    /** Rule 7: the checked-in, non-releasable sentinels (gradle.properties). */
    const val SENTINEL_NAME = "deviceinfo.sentinel.versionName"
    const val SENTINEL_CODE_PHONE = "deviceinfo.sentinel.versionCode.phone"
    const val SENTINEL_CODE_WEAR = "deviceinfo.sentinel.versionCode.wear"

    /** Rule 6: the one clock reading of an invocation, stored once on the root project. */
    const val BUILD_INSTANT = "deviceinfo.buildInstant"

    private val INSTANT = Regex("""\d{10}""")
    private val NAME = Regex("""\d\.\d{2}\.\d{4}\.\d{3}""")
    private val RELEASE_TASK = Regex("release", RegexOption.IGNORE_CASE)
    private val CLOCK_FORMAT = DateTimeFormatter.ofPattern("yyMMddHHmm")

    /** `yyMMddHHmm` of a local wall-clock reading. */
    fun clockInstant(now: LocalDateTime): String = now.format(CLOCK_FORMAT)

    /** Both fields of one family for a `yyMMddHHmm` instant; a string that is not a real date and time is refused. */
    fun fromInstant(instant: String, family: PackageFamily): Stamp {
        require(INSTANT.matches(instant)) { "The instant must be ten digits, yyMMddHHmm; got '$instant'." }
        val year = 2000 + instant.substring(0, 2).toInt()
        val month = instant.substring(2, 4).toInt()
        val day = instant.substring(4, 6).toInt()
        val hour = instant.substring(6, 8).toInt()
        val minute = instant.substring(8, 10).toInt()
        require(month in 1..12) { "The instant '$instant' has no month $month." }
        require(day in 1..YearMonth.of(year, month).lengthOfMonth()) {
            "The instant '$instant' has no day $day in $year-$month."
        }
        require(hour in 0..23) { "The instant '$instant' has no hour $hour." }
        require(minute in 0..59) { "The instant '$instant' has no minute $minute." }

        val name = "${instant[0]}.${instant.substring(1, 3)}.${instant.substring(3, 7)}.${instant.substring(7)}"
        val code = instant.substring(0, 8).toInt() * 10 + family.partition(minute)
        return Stamp(name, code)
    }

    /**
     * Checks that a versionName and a versionCode describe one instant of the family's partition, and returns
     * the stamp. Used for the pinned pair and for the sentinels, so both are held to the formula.
     */
    fun verifiedPair(family: PackageFamily, name: String, code: String): Stamp {
        require(NAME.matches(name)) { "The versionName must be Y.YM.MDDH.Hmm; got '$name'." }
        val expected = fromInstant(name.replace(".", ""), family)
        require(code == expected.code.toString()) {
            "The ${family.name.lowercase()} pair does not describe one instant of its partition: versionName " +
                "$name implies versionCode ${expected.code}, got '$code'."
        }
        return expected
    }

    /**
     * Rule 5: the orchestrator pins versionName and both family codes together or not at all, and the pair
     * always wins over the clock. Every pinned code is checked against its own family, so a code of one
     * family can never reach the other. Returns null when nothing is pinned.
     */
    fun fromPin(family: PackageFamily, name: String?, phoneCode: String?, wearCode: String?): Stamp? {
        if (name == null && phoneCode == null && wearCode == null) return null
        require(name != null && phoneCode != null && wearCode != null) {
            "$PIN_NAME, $PIN_CODE_PHONE and $PIN_CODE_WEAR are pinned together or not at all."
        }
        val phone = verifiedPair(PackageFamily.PHONE, name, phoneCode)
        val wear = verifiedPair(PackageFamily.WEAR, name, wearCode)
        return if (family == PackageFamily.PHONE) phone else wear
    }

    /** Rule 7: the checked-in sentinel of a family, held to the formula so it cannot drift. */
    fun sentinel(family: PackageFamily, property: (String) -> String?): Stamp {
        val name = requireNotNull(property(SENTINEL_NAME)) { "gradle.properties has no $SENTINEL_NAME." }
        val codeKey = if (family == PackageFamily.PHONE) SENTINEL_CODE_PHONE else SENTINEL_CODE_WEAR
        val code = requireNotNull(property(codeKey)) { "gradle.properties has no $codeKey." }
        return verifiedPair(family, name, code)
    }

    /** True for a task name that builds a release variant (`assembleRelease`, `:phone:bundleRelease`, ..). */
    fun isReleaseTask(taskName: String): Boolean = RELEASE_TASK.containsMatchIn(taskName)

    /**
     * The stamp one module of one invocation carries: the pin when there is one (rule 5), else the clock reading
     * of the invocation when a release variant is requested (rule 6), else the sentinel of a device-debug build
     * that never leaves the developer's devices (rules 6 and 7).
     */
    fun select(
        family: PackageFamily,
        taskNames: List<String>,
        property: (String) -> String?,
        instant: String,
    ): Stamp {
        fromPin(family, property(PIN_NAME), property(PIN_CODE_PHONE), property(PIN_CODE_WEAR))?.let { return it }
        return if (taskNames.any { isReleaseTask(it) }) fromInstant(instant, family) else sentinel(family, property)
    }
}
