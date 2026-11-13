package com.sza.deviceinfo.diagnostics

import android.content.ContentResolver
import android.content.Context
import android.content.ContextWrapper
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import com.sza.deviceinfo.R
import com.sza.deviceinfo.core.systeminfo.BatteryDetailsCollector
import com.sza.deviceinfo.core.systeminfo.ExtendedDiagnosticsSection
import com.sza.deviceinfo.core.systeminfo.MediaAudioDiagnosticsCollector
import com.sza.deviceinfo.core.systeminfo.PlatformDetailsCollector
import com.sza.deviceinfo.core.systeminfo.REDACTED
import com.sza.deviceinfo.core.systeminfo.SensorsDiagnosticsCollector
import com.sza.deviceinfo.core.systeminfo.SystemInfoGroup
import com.sza.deviceinfo.data.camera.CameraHardwareDataSource
import com.sza.deviceinfo.data.repository.DischargeRateBatteryRuntimeEstimator
import com.sza.deviceinfo.domain.usecase.GatherCameraDiagnosticsUseCase
import com.sza.deviceinfo.domain.usecase.GatherSystemInfoUseCase
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.annotation.Config

/**
 * Not a port: the upstream has no test for its extended-diagnostics contributor. Proves, for the real contributor
 * of the `restricted` flavor (S0009): the seven sections and their order, the absence of the five rows that
 * describe FastMediaSorter-only components, the degradation of every context-dependent field to "unknown" when
 * its source fails, and that the ten sensitive fields are masked in the masked text and shown in the full text.
 * The `store` flavor carrying none of it is proven in `src/testStore`.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class RestrictedExtendedDiagnosticsContributorTest {

    private val context: Context = RuntimeEnvironment.getApplication()

    /** A context whose system services, settings, package manager and application info all fail. */
    private class FailingSourcesContext(base: Context) : ContextWrapper(base) {
        override fun getSystemService(name: String): Any = error("system service failed")
        override fun getContentResolver(): ContentResolver = error("content resolver failed")
        override fun getPackageManager(): PackageManager = error("package manager failed")
        override fun getApplicationInfo(): ApplicationInfo = error("application info failed")
    }

    private val expectedGroups = listOf(
        SystemInfoGroup.OS_SECURITY,
        SystemInfoGroup.PERMISSIONS,
        SystemInfoGroup.INSTALLER_SIGNATURE,
        SystemInfoGroup.RUNTIMES,
        SystemInfoGroup.MOUNTS,
        SystemInfoGroup.NETWORK_DIAGNOSTICS,
        SystemInfoGroup.PROCESS_RESOURCES,
    )

    private val expectedSensitiveLabels = setOf(
        "Signature SHA-256",
        "APK & split layout",
        "Mount points",
        "DNS servers",
        "VPN interfaces",
        "Active interfaces & MTU",
        "Wi-Fi SSID & BSSID",
        "Wi-Fi link & gateway",
        "Bluetooth & bonded devices",
        "Cellular & SIM state",
    )

    private fun values(sections: List<ExtendedDiagnosticsSection>): Map<String, List<String>> =
        sections.flatMap { it.fields }.groupBy({ it.label }, { it.value })

    @Test
    fun `the contributor yields the seven sections in upstream order with localized titles`() {
        val sections = RestrictedExtendedDiagnosticsContributor(context).sections()

        assertEquals(expectedGroups, sections.map { it.group })
        assertEquals(
            listOf(
                R.string.sysinfo_section_os_security,
                R.string.sysinfo_section_permissions,
                R.string.sysinfo_section_installer,
                R.string.sysinfo_section_runtimes,
                R.string.sysinfo_section_mounts,
                R.string.sysinfo_section_network_diagnostics,
                R.string.sysinfo_section_process,
            ).map { context.getString(it) },
            sections.map { it.title },
        )
        sections.forEach { assertTrue("${it.title} has fields", it.fields.isNotEmpty()) }
    }

    @Test
    fun `the rows of FastMediaSorter-only components are absent`() {
        val labels = RestrictedExtendedDiagnosticsContributor(context).sections().flatMap { it.fields }.map { it.label }

        listOf("Python (Chaquopy)", "yt-dlp", "ffmpeg/ffprobe", "Tesseract data", "XR runtime").forEach {
            assertFalse("$it must not be carried", labels.contains(it))
        }
        assertTrue("the runtimes rows that are ported are there", labels.containsAll(listOf("Supported ABIs", "WebView provider")))
    }

    @Test
    fun `every context-dependent field degrades to unknown when its source fails`() {
        val sections = RestrictedExtendedDiagnosticsContributor(FailingSourcesContext(context)).sections()

        assertEquals("a failing source must not drop a section", expectedGroups, sections.map { it.group })
        val byLabel = values(sections)
        listOf(
            "Root markers", "Developer options", "ADB enabled", "ADB Wi-Fi & USB state",
            "QUERY_ALL_PACKAGES", "REQUEST_INSTALL_PACKAGES", "Step counter (since boot)", "Step detector & motion",
            "Body & health sensors", "ACCESS_FINE_LOCATION", "BLUETOOTH_CONNECT", "POST_NOTIFICATIONS",
            "Battery optimization ignored", "Accessibility services", "Notification listeners",
            "Installer package", "Install source details", "Signature SHA-256", "Alternative stores",
            "Visible packages (user/sys)", "Default launcher & browser", "APK & split layout", "App version",
            "First install", "Private & wake-up sensors", "Removable volumes", "DNS servers", "Wi-Fi SSID & BSSID",
            "Wi-Fi link & gateway", "Bluetooth & bonded devices", "Cellular & SIM state", "Private DNS",
            "Active transport", "Metered", "Total RAM", "Thermal status",
        ).forEach { label ->
            val found = byLabel[label]
            assertNotNull("$label is a row of the report", found)
            assertEquals("$label degrades to unknown", listOf("unknown"), found)
        }
    }

    @Test
    fun `exactly the ten upstream sensitive fields are flagged sensitive`() {
        val flagged = RestrictedExtendedDiagnosticsContributor(context).sections()
            .flatMap { it.fields }.filter { it.sensitive }.map { it.label }

        assertEquals(expectedSensitiveLabels, flagged.toSet())
        assertEquals("no sensitive label is repeated", expectedSensitiveLabels.size, flagged.size)
    }

    @Test
    fun `sensitive values are masked in the masked text and shown only in the full text`() {
        val report = useCaseWith(RestrictedExtendedDiagnosticsContributor(context)).invoke()

        assertTrue(report.hasSensitive)
        val restricted = report.sections.filter { it.group in expectedGroups }
        assertEquals(expectedGroups.size, restricted.size)
        expectedSensitiveLabels.forEach { label ->
            val value = restricted.flatMap { it.fields }.single { it.first == label }.second
            assertTrue("$label is redacted in the masked text", report.maskedText.contains("  $label: $REDACTED"))
            assertFalse("$label value must not be in the masked text", report.maskedText.contains("  $label: $value"))
            assertTrue("$label value is in the full text", report.fullText.contains("  $label: $value"))
            assertFalse("$label is not redacted in the full text", report.fullText.contains("  $label: $REDACTED"))
        }
    }

    private fun useCaseWith(contributor: RestrictedExtendedDiagnosticsContributor) = GatherSystemInfoUseCase(
        context,
        setOf(contributor),
        GatherCameraDiagnosticsUseCase(context, CameraHardwareDataSource(context)),
        BatteryDetailsCollector(context, DischargeRateBatteryRuntimeEstimator()),
        PlatformDetailsCollector(context),
        SensorsDiagnosticsCollector(context),
        MediaAudioDiagnosticsCollector(context),
    )

    @Test
    fun `the restricted classes resolve here, so the store flavor test is not vacuous`() {
        listOf(
            "com.sza.deviceinfo.diagnostics.RestrictedExtendedDiagnosticsContributor",
            "com.sza.deviceinfo.diagnostics.RestrictedDiagnosticsCollectors",
            "com.sza.deviceinfo.di.RestrictedExtendedDiagnosticsModule",
        ).forEach { Class.forName(it) }
    }
}
