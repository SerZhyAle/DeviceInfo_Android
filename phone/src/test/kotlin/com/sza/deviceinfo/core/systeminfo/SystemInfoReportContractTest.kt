package com.sza.deviceinfo.core.systeminfo

import android.content.Context
import com.sza.deviceinfo.data.camera.CameraHardwareDataSource
import com.sza.deviceinfo.data.repository.DischargeRateBatteryRuntimeEstimator
import com.sza.deviceinfo.domain.usecase.GatherCameraDiagnosticsUseCase
import com.sza.deviceinfo.domain.usecase.GatherSystemInfoUseCase
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.annotation.Config
import java.io.IOException

/**
 * Not a port: the upstream tests never reach the extended-diagnostics path, because the one contributor lives in
 * a flavor they do not build. This proves the contract that path rests on - masking, the sensitive flag, the
 * empty-section rule, the state key and the access classifier - with fake contributors, in both flavors; the real
 * contributor of the restricted flavor is proven in `src/testRestricted`.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class SystemInfoReportContractTest {

    private val context: Context = RuntimeEnvironment.getApplication()

    private fun useCaseWith(vararg contributors: ExtendedDiagnosticsContributor) = GatherSystemInfoUseCase(
        context,
        contributors.toSet(),
        GatherCameraDiagnosticsUseCase(context, CameraHardwareDataSource(context)),
        BatteryDetailsCollector(context, DischargeRateBatteryRuntimeEstimator()),
        PlatformDetailsCollector(context),
        SensorsDiagnosticsCollector(context),
        MediaAudioDiagnosticsCollector(context),
    )

    private class FakeContributor(private val provided: List<ExtendedDiagnosticsSection>) : ExtendedDiagnosticsContributor {
        override fun sections(): List<ExtendedDiagnosticsSection> = provided
    }

    private class ThrowingContributor : ExtendedDiagnosticsContributor {
        override fun sections(): List<ExtendedDiagnosticsSection> = error("contributor failed")
    }

    private val secretSection = ExtendedDiagnosticsSection(
        title = "Fake diagnostics",
        fields = listOf(
            ExtendedDiagnosticsField("Open field", "visible-value"),
            ExtendedDiagnosticsField("Secret field", "secret-value", sensitive = true),
        ),
        group = SystemInfoGroup.OS_SECURITY,
    )

    @Test
    fun `masked text hides a sensitive value that full text shows`() {
        val report = useCaseWith(FakeContributor(listOf(secretSection))).invoke()

        assertTrue("full text must carry the real value", report.fullText.contains("secret-value"))
        assertFalse("masked text must not carry the real value", report.maskedText.contains("secret-value"))
        assertTrue("masked text must carry the placeholder", report.maskedText.contains(REDACTED))
        assertTrue("a non-sensitive value stays visible when masked", report.maskedText.contains("visible-value"))
    }

    @Test
    fun `hasSensitive is true only when a contributed field is sensitive`() {
        val open = ExtendedDiagnosticsSection("Open only", listOf(ExtendedDiagnosticsField("A", "1")))

        assertTrue(useCaseWith(FakeContributor(listOf(secretSection))).invoke().hasSensitive)
        assertFalse(useCaseWith(FakeContributor(listOf(open))).invoke().hasSensitive)
    }

    @Test
    fun `contributed sections are appended after the base sections`() {
        val report = useCaseWith(FakeContributor(listOf(secretSection))).invoke()

        assertEquals("Fake diagnostics", report.sections.last().title)
        assertEquals(SystemInfoGroup.OS_SECURITY, report.sections.last().group)
    }

    @Test
    fun `a throwing contributor degrades to the base report`() {
        val report = useCaseWith(ThrowingContributor()).invoke()

        assertTrue("the base report must survive", report.maskedText.isNotBlank())
        assertFalse(report.hasSensitive)
        assertEquals(report.maskedText, report.fullText)
    }

    @Test
    fun `rendering skips sections without fields`() {
        val text = listOf(
            SystemInfoSection("Empty", emptyList()),
            SystemInfoSection("Full", listOf("a" to "1", "b" to "2")),
        ).renderSystemInfo()

        assertEquals("Full\n  a: 1\n  b: 2", text)
    }

    @Test
    fun `state key falls back to the title without a group`() {
        assertEquals("device", SystemInfoSection("Device", emptyList(), SystemInfoGroup.DEVICE).stateKey)
        assertEquals("Custom", SystemInfoSection("Custom", emptyList()).stateKey)
    }

    @Test
    fun `access classifier accepts denials and refuses other failures`() {
        assertTrue(SystemInfoAccessClassifier.isExpectedAccessDenial(SecurityException("no")))
        assertTrue(SystemInfoAccessClassifier.isExpectedAccessDenial(IOException("open failed: EACCES (Permission denied)")))
        assertTrue(SystemInfoAccessClassifier.isExpectedAccessDenial(RuntimeException(SecurityException("wrapped"))))
        assertFalse(SystemInfoAccessClassifier.isExpectedAccessDenial(IOException("disk full")))
        assertFalse(SystemInfoAccessClassifier.isExpectedAccessDenial(IllegalStateException("bug")))
        assertFalse(SystemInfoAccessClassifier.isExpectedAccessDenial(null))
    }
}
