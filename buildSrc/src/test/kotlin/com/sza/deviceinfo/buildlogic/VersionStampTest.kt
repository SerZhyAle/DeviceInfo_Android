package com.sza.deviceinfo.buildlogic

import com.sza.deviceinfo.buildlogic.PackageFamily.PHONE
import com.sza.deviceinfo.buildlogic.PackageFamily.WEAR
import java.io.File
import java.time.LocalDateTime
import java.util.Properties
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertThrows
import org.junit.Assert.assertTrue
import org.junit.Test

/**
 * PACKAGE-VERSIONING section 4, rung 2: the contract's own example instant rendered by rules 1 to 3 and
 * compared with the expected strings, plus the partition, ordering, pin and sentinel obligations.
 * The same vectors are checked by tools/release/check-version-parity.ps1 (the second toolchain, rule 8).
 */
class VersionStampTest {

    private fun instantOf(year: Int, month: Int, day: Int, hour: Int, minute: Int) =
        VersionStamp.clockInstant(LocalDateTime.of(year, month, day, hour, minute))

    @Test
    fun theContractExampleRendersTheRegisteredStrings() {
        // 2026-09-26 23:22, the example of PACKAGE-VERSIONING rule 2 and the registered codes of rule 3.
        assertEquals(VersionStamp.Stamp("2.60.9262.322", 260926232), VersionStamp.fromInstant("2609262322", PHONE))
        assertEquals(VersionStamp.Stamp("2.60.9262.322", 260926237), VersionStamp.fromInstant("2609262322", WEAR))
    }

    @Test
    fun theClockRendersTheSameStamp() {
        val instant = VersionStamp.clockInstant(LocalDateTime.of(2026, 9, 26, 23, 22, 59))
        assertEquals("2609262322", instant)
        assertEquals("2.60.9262.322", VersionStamp.fromInstant(instant, PHONE).name)
    }

    @Test
    fun theNameIsOneInstantInBothFamilies() {
        for (minute in 0..59) {
            val instant = instantOf(2026, 11, 13, 8, minute)
            assertEquals(
                VersionStamp.fromInstant(instant, PHONE).name,
                VersionStamp.fromInstant(instant, WEAR).name,
            )
        }
    }

    @Test
    fun thePhoneBandIsZeroToFiveInTenMinuteSlots() {
        val expected = mapOf(0 to 0, 9 to 0, 10 to 1, 19 to 1, 20 to 2, 29 to 2, 30 to 3, 39 to 3, 40 to 4, 49 to 4, 50 to 5, 59 to 5)
        for ((minute, band) in expected) {
            assertEquals("minute $minute", 261113080 + band, VersionStamp.fromInstant(instantOf(2026, 11, 13, 8, minute), PHONE).code)
        }
    }

    @Test
    fun theWatchBandIsSixToNineInFifteenMinuteSlots() {
        val expected = mapOf(0 to 6, 14 to 6, 15 to 7, 29 to 7, 30 to 8, 44 to 8, 45 to 9, 59 to 9)
        for ((minute, band) in expected) {
            assertEquals("minute $minute", 261113080 + band, VersionStamp.fromInstant(instantOf(2026, 11, 13, 8, minute), WEAR).code)
        }
    }

    @Test
    fun theTwoFamiliesNeverRepeatACodeUnderOneId() {
        for (minute in 0..59) {
            val instant = instantOf(2026, 11, 13, 8, minute)
            val phone = VersionStamp.fromInstant(instant, PHONE).code
            val wear = VersionStamp.fromInstant(instant, WEAR).code
            assertNotEquals("minute $minute", phone, wear)
            assertTrue("phone band, minute $minute", phone % 10 in 0..5)
            assertTrue("watch band, minute $minute", wear % 10 in 6..9)
        }
    }

    @Test
    fun aLaterSlotAlwaysOrdersAboveAnEarlierOneAcrossEveryBoundary() {
        // Slot, hour, day, month, year and leap-day boundaries, each pair a later slot after an earlier one.
        val pairs = listOf(
            "2611130809" to "2611130810",
            "2611130859" to "2611130900",
            "2611132359" to "2611140000",
            "2611302359" to "2612010000",
            "2612312359" to "2701010000",
            "2802282359" to "2802290000",
            "2802292359" to "2803010000",
        )
        for (family in PackageFamily.values()) {
            for ((earlier, later) in pairs) {
                // Inside one slot the code is equal (one release); across a slot boundary it is strictly greater.
                val before = VersionStamp.fromInstant(earlier, family).code
                val after = VersionStamp.fromInstant(later, family).code
                assertTrue("$family $earlier -> $later", after >= before)
            }
        }
        assertTrue(VersionStamp.fromInstant("2611130810", PHONE).code > VersionStamp.fromInstant("2611130809", PHONE).code)
        assertTrue(VersionStamp.fromInstant("2611130815", WEAR).code > VersionStamp.fromInstant("2611130814", WEAR).code)
        assertTrue(VersionStamp.fromInstant("2612312359", PHONE).code < VersionStamp.fromInstant("2701010000", PHONE).code)
    }

    @Test
    fun anInstantThatIsNotARealDateAndTimeIsRefused() {
        val refused = listOf(
            "260926232",    // nine digits
            "26092623222",  // eleven digits
            "26a9262322",   // not a digit
            "2613010000",   // month 13
            "2600010000",   // month 0
            "2611310000",   // 31 November
            "2602290000",   // 2026 is not a leap year
            "2611132400",   // hour 24
            "2611130860",   // minute 60
        )
        for (instant in refused) {
            assertThrows(instant, IllegalArgumentException::class.java) { VersionStamp.fromInstant(instant, PHONE) }
        }
        assertEquals("2.80.2290.000", VersionStamp.fromInstant("2802290000", PHONE).name) // 2028 is a leap year
    }

    @Test
    fun aPairThatDescribesOneInstantOfEachFamilyIsAccepted() {
        val phone = VersionStamp.fromPin(PHONE, "2.60.9262.322", "260926232", "260926237")
        val wear = VersionStamp.fromPin(WEAR, "2.60.9262.322", "260926232", "260926237")
        assertEquals(VersionStamp.Stamp("2.60.9262.322", 260926232), phone)
        assertEquals(VersionStamp.Stamp("2.60.9262.322", 260926237), wear)
    }

    @Test
    fun nothingPinnedIsNotAPin() {
        assertNull(VersionStamp.fromPin(PHONE, null, null, null))
    }

    @Test
    fun aOneSidedPinIsRefused() {
        assertThrows(IllegalArgumentException::class.java) { VersionStamp.fromPin(PHONE, "2.60.9262.322", null, null) }
        assertThrows(IllegalArgumentException::class.java) { VersionStamp.fromPin(PHONE, null, "260926232", "260926237") }
        assertThrows(IllegalArgumentException::class.java) { VersionStamp.fromPin(WEAR, "2.60.9262.322", "260926232", null) }
        assertThrows(IllegalArgumentException::class.java) { VersionStamp.fromPin(WEAR, "2.60.9262.322", null, "260926237") }
    }

    @Test
    fun aPairThatDoesNotDescribeOneInstantIsRefused() {
        // A code that is not the formula's.
        assertThrows(IllegalArgumentException::class.java) { VersionStamp.fromPin(PHONE, "2.60.9262.322", "260926233", "260926237") }
        // A code of the other family's band in the wrong slot: the phone code in the watch place and the reverse.
        assertThrows(IllegalArgumentException::class.java) { VersionStamp.fromPin(PHONE, "2.60.9262.322", "260926237", "260926232") }
        // A name that is not Y.YM.MDDH.Hmm, and one that is not a real instant.
        assertThrows(IllegalArgumentException::class.java) { VersionStamp.fromPin(PHONE, "2.60.9262", "260926232", "260926237") }
        assertThrows(IllegalArgumentException::class.java) { VersionStamp.fromPin(PHONE, "2.61.3010.000", "261301000", "261301006") }
    }

    @Test
    fun aDebugInvocationCarriesTheSentinelAndAReleaseInvocationStampsItself() {
        val props = sentinelProperties()
        val instant = "2611130822"

        val debugPhone = VersionStamp.select(PHONE, listOf(":phone:assembleDebug"), props.lookup(), instant)
        assertEquals(VersionStamp.Stamp("2.61.1100.000", 261110000), debugPhone)
        val debugWear = VersionStamp.select(WEAR, listOf(":wear:assembleDebug"), props.lookup(), instant)
        assertEquals(VersionStamp.Stamp("2.61.1100.000", 261110006), debugWear)

        val releasePhone = VersionStamp.select(PHONE, listOf(":phone:bundleRelease"), props.lookup(), instant)
        assertEquals(VersionStamp.Stamp("2.61.1130.822", 261113082), releasePhone)
        val releaseWear = VersionStamp.select(WEAR, listOf("assembleRelease"), props.lookup(), instant)
        assertEquals(VersionStamp.Stamp("2.61.1130.822", 261113087), releaseWear)
    }

    @Test
    fun aPinWinsOverTheSentinelAndTheClock() {
        val props = sentinelProperties().apply {
            setProperty(VersionStamp.PIN_NAME, "2.60.9262.322")
            setProperty(VersionStamp.PIN_CODE_PHONE, "260926232")
            setProperty(VersionStamp.PIN_CODE_WEAR, "260926237")
        }
        assertEquals(260926232, VersionStamp.select(PHONE, listOf(":phone:assembleDebug"), props.lookup(), "2611130822").code)
        assertEquals(260926237, VersionStamp.select(WEAR, listOf(":wear:bundleRelease"), props.lookup(), "2611130822").code)
    }

    @Test
    fun theCheckedInSentinelsAreTheFormulaAppliedToTheirInstant() {
        // Rules 7 and 8: gradle.properties is read from the repository root, one level above buildSrc.
        val props = Properties()
        File("../gradle.properties").reader(Charsets.UTF_8).use { props.load(it) }
        val phone = VersionStamp.sentinel(PHONE, props.lookup())
        val wear = VersionStamp.sentinel(WEAR, props.lookup())
        val instant = phone.name.replace(".", "")
        assertEquals(VersionStamp.fromInstant(instant, PHONE), phone)
        assertEquals(VersionStamp.fromInstant(instant, WEAR), wear)
        assertEquals("2611100000", instant)
        assertEquals(wear.name, phone.name)
    }

    @Test
    fun releaseTasksAreRecognisedByTheirNames() {
        assertTrue(VersionStamp.isReleaseTask(":phone:bundleRelease"))
        assertTrue(VersionStamp.isReleaseTask("assembleRelease"))
        assertTrue(VersionStamp.isReleaseTask(":wear:packageReleaseBundle"))
        assertTrue(!VersionStamp.isReleaseTask(":phone:assembleDebug"))
        assertTrue(!VersionStamp.isReleaseTask(":phone:testDebugUnitTest"))
    }

    private fun Properties.lookup(): (String) -> String? = { key -> getProperty(key) }

    private fun sentinelProperties(): Properties = Properties().apply {
        setProperty(VersionStamp.SENTINEL_NAME, "2.61.1100.000")
        setProperty(VersionStamp.SENTINEL_CODE_PHONE, "261110000")
        setProperty(VersionStamp.SENTINEL_CODE_WEAR, "261110006")
    }
}
