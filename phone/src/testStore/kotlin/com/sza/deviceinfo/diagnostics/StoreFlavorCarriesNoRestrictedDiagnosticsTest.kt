package com.sza.deviceinfo.diagnostics

import com.sza.deviceinfo.R
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Assert.fail
import org.junit.Test

/**
 * Not a port. S0009, owner decision: the seven extended diagnostics sections live in the `restricted` flavor only
 * and the public `store` flavor carries none. This proves the build keeps its word: none of the restricted classes
 * and none of its section-title strings exist in the `store` variant. The same class names are asserted to exist in
 * `src/testRestricted`, so a misspelled name here cannot make this test pass for nothing.
 */
class StoreFlavorCarriesNoRestrictedDiagnosticsTest {

    private val restrictedClasses = listOf(
        "com.sza.deviceinfo.diagnostics.RestrictedExtendedDiagnosticsContributor",
        "com.sza.deviceinfo.diagnostics.RestrictedDiagnosticsCollectors",
        "com.sza.deviceinfo.di.RestrictedExtendedDiagnosticsModule",
    )

    private val restrictedStringKeys = listOf(
        "sysinfo_section_os_security",
        "sysinfo_section_permissions",
        "sysinfo_section_installer",
        "sysinfo_section_runtimes",
        "sysinfo_section_mounts",
        "sysinfo_section_network_diagnostics",
        "sysinfo_section_process",
    )

    @Test
    fun `no restricted class is compiled into the store flavor`() {
        restrictedClasses.forEach { name ->
            try {
                Class.forName(name)
                fail("$name must not exist in the store flavor")
            } catch (expected: ClassNotFoundException) {
                // The restricted class is absent, as the owner's decision requires.
            }
        }
    }

    @Test
    fun `no restricted section title is among the store resources`() {
        val keys = R.string::class.java.declaredFields.map { it.name }

        assertTrue("the base keys are there, so this check is not vacuous", keys.contains("sysinfo_section_device"))
        restrictedStringKeys.forEach { assertFalse("$it must not exist in the store flavor", keys.contains(it)) }
    }
}
