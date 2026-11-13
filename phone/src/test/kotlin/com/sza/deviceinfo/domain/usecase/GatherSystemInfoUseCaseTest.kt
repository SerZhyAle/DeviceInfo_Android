package com.sza.deviceinfo.domain.usecase

import android.content.Context
import com.sza.deviceinfo.BuildConfig
import com.sza.deviceinfo.R
import com.sza.deviceinfo.core.systeminfo.BatteryDetailsCollector
import com.sza.deviceinfo.core.systeminfo.MediaAudioDiagnosticsCollector
import com.sza.deviceinfo.core.systeminfo.PlatformDetailsCollector
import com.sza.deviceinfo.core.systeminfo.SensorsDiagnosticsCollector
import com.sza.deviceinfo.data.camera.CameraHardwareDataSource
import com.sza.deviceinfo.data.repository.DischargeRateBatteryRuntimeEstimator
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class GatherSystemInfoUseCaseTest {

    private val context: Context = RuntimeEnvironment.getApplication()
    private val useCase = GatherSystemInfoUseCase(
        context,
        emptySet(),
        GatherCameraDiagnosticsUseCase(context, CameraHardwareDataSource(context)),
        BatteryDetailsCollector(context, DischargeRateBatteryRuntimeEstimator()),
        PlatformDetailsCollector(context),
        SensorsDiagnosticsCollector(context),
        MediaAudioDiagnosticsCollector(context),
    )

    @Test
    fun `invoke returns non-blank summary`() {
        val summary = useCase().maskedText

        assertTrue("summary must not be blank", summary.isNotBlank())
    }

    @Test
    fun `invoke contains localized section headers`() {
        val summary = useCase().maskedText

        listOf(
            R.string.sysinfo_section_device,
            R.string.sysinfo_section_user,
            R.string.sysinfo_section_os,
            R.string.sysinfo_section_app,
            R.string.sysinfo_section_memory,
            R.string.sysinfo_section_storage,
            R.string.sysinfo_section_display,
            R.string.sysinfo_section_locale,
            R.string.sysinfo_section_time,
            R.string.sysinfo_section_sensors,
            R.string.sysinfo_section_media_audio,
        ).forEach { resId ->
            val header = context.getString(resId)
            assertTrue("summary must contain section header '$header'", summary.contains(header))
        }
    }

    @Test
    fun `invoke contains app version name`() {
        val summary = useCase().maskedText

        assertTrue(
            "summary must contain app version name",
            summary.contains(BuildConfig.VERSION_NAME),
        )
    }

    @Test
    fun `invoke with no contributors keeps masked equal to full`() {
        val report = useCase()

        assertTrue("masked must equal full when no contributor is present", report.maskedText == report.fullText)
        assertTrue("hasSensitive must be false when no contributor is present", !report.hasSensitive)
    }

    @Test
    fun `invoke benchmark section formats throughput without stray tilde brackets`() {
        val summary = useCase().maskedText

        assertFalse("summary must not contain stray tilde in brackets '(~)'", summary.contains("(~)"))
    }

    @Test
    fun `invoke contains localized battery detail field headers`() {
        val summary = useCase().maskedText

        listOf(
            R.string.sysinfo_field_battery_level,
            R.string.sysinfo_field_battery_status,
            R.string.sysinfo_field_battery_current,
            R.string.sysinfo_field_battery_power,
            R.string.sysinfo_field_battery_saver,
            R.string.sysinfo_field_battery_capacity_estimate,
            R.string.sysinfo_field_battery_charge_time,
            R.string.sysinfo_field_battery_discharge_time,
        ).forEach { resId ->
            val header = context.getString(resId)
            assertTrue("summary must contain battery header '$header'", summary.contains(header))
        }
    }

    @Test
    fun `invoke contains the extended metric field headers of the base sections`() {
        val summary = useCase().maskedText

        listOf(
            R.string.sysinfo_field_brand,
            R.string.sysinfo_field_form_factor,
            R.string.sysinfo_field_package_name,
            R.string.sysinfo_field_hw_features,
            R.string.sysinfo_field_first_day_of_week,
            R.string.sysinfo_field_uptime,
            R.string.sysinfo_field_webview,
            R.string.sysinfo_field_bench_cpu_single,
            R.string.sysinfo_field_bench_cpu_multi,
        ).forEach { resId ->
            val header = context.getString(resId)
            assertTrue("summary must contain extended field header '$header'", summary.contains(header))
        }
    }

    @Test
    fun `invoke contains the sensor and media sections with their key fields`() {
        val summary = useCase().maskedText

        listOf(
            R.string.sysinfo_field_sensors_count,
            R.string.sysinfo_field_sensors_key,
            R.string.sysinfo_field_drm_widevine,
            R.string.sysinfo_field_audio_outputs,
            R.string.sysinfo_field_audio_capabilities,
        ).forEach { resId ->
            val header = context.getString(resId)
            assertTrue("summary must contain field header '$header'", summary.contains(header))
        }
    }
}
