package com.sza.deviceinfo.domain.model

import com.google.gson.Gson
import com.google.gson.JsonParser
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import java.io.File

class WearSystemInfoReportCodecTest {

    private val gson = Gson()

    @Test
    fun `parse valid report payload succeeds`() {
        val json = """
            {
                "requestId": "req-1",
                "formatVersion": 1,
                "appVersionName": "1.0",
                "appVersionCode": 1,
                "deviceModel": "Watch",
                "androidRelease": "14",
                "capturedAtEpochMillis": 123456789,
                "reportText": "test report"
            }
        """.trimIndent()

        val result = WearSystemInfoReportCodec.parse(json.toByteArray(), gson)
        assertTrue(result is WearSystemInfoReportParseResult.Parsed)
        val parsed = (result as WearSystemInfoReportParseResult.Parsed).payload
        assertEquals("req-1", parsed.requestId)
        assertEquals(1, parsed.formatVersion)
        assertEquals("test report", parsed.reportText)
    }

    @Test
    fun `parse unsupported format version returns UnsupportedVersion`() {
        val json = """
            {
                "requestId": "req-2",
                "formatVersion": 99,
                "appVersionName": "1.0",
                "appVersionCode": 1,
                "deviceModel": "Watch",
                "androidRelease": "14",
                "capturedAtEpochMillis": 123456789,
                "reportText": "test report"
            }
        """.trimIndent()

        val result = WearSystemInfoReportCodec.parse(json.toByteArray(), gson)
        assertTrue(result is WearSystemInfoReportParseResult.UnsupportedVersion)
        assertEquals(99, (result as WearSystemInfoReportParseResult.UnsupportedVersion).version)
    }

    @Test
    fun `parse malformed json returns Malformed`() {
        val result = WearSystemInfoReportCodec.parse("not json".toByteArray(), gson)
        assertTrue(result is WearSystemInfoReportParseResult.Malformed)
    }

    @Test
    fun `serializeAck roundtrip`() {
        val ack = WearSystemInfoReportAck("req-3", accepted = true, reason = null)
        val bytes = WearSystemInfoReportCodec.serializeAck(ack, gson)
        val json = String(bytes, Charsets.UTF_8)
        assertTrue(json.contains("\"requestId\":\"req-3\""))
        assertTrue(json.contains("\"accepted\":true"))
    }

    @Test
    fun `version one report and acknowledgement remain compatible`() {
        val reportJson = fixture("report.json")
        val parsed = WearSystemInfoReportCodec.parse(reportJson.toByteArray(), gson)
        assertTrue(parsed is WearSystemInfoReportParseResult.Parsed)
        assertEquals(expectedV1Report(), (parsed as WearSystemInfoReportParseResult.Parsed).payload)

        val ackJson = fixture("ack.json")
        val ack = gson.fromJson(ackJson, WearSystemInfoReportAck::class.java)
        assertEquals(WearSystemInfoReportAck("req-v1", accepted = true, reason = null), ack)
        val encoded = WearSystemInfoReportCodec.serializeAck(ack, gson).toString(Charsets.UTF_8)
        assertEquals(JsonParser.parseString(ackJson), JsonParser.parseString(encoded))
    }

    @Test
    fun `version one messages ignore unknown fields and default the omitted optional reason`() {
        val report = JsonParser.parseString(fixture("report.json")).asJsonObject
        report.addProperty("futureReportField", "ignored")
        val parsed = WearSystemInfoReportCodec.parse(report.toString().toByteArray(), gson)
        assertTrue(parsed is WearSystemInfoReportParseResult.Parsed)
        assertEquals(expectedV1Report(), (parsed as WearSystemInfoReportParseResult.Parsed).payload)

        val ack = JsonParser.parseString(fixture("ack.json")).asJsonObject
        ack.addProperty("futureAckField", "ignored")
        assertEquals(
            WearSystemInfoReportAck("req-v1", accepted = true, reason = null),
            gson.fromJson(ack, WearSystemInfoReportAck::class.java)
        )
    }

    private fun expectedV1Report() = WearSystemInfoReportPayload(
        requestId = "req-v1",
        formatVersion = 1,
        appVersionName = "1.0",
        appVersionCode = 10,
        deviceModel = "Watch",
        androidRelease = "14",
        capturedAtEpochMillis = 1700000000000L,
        reportText = "device: Watch\n"
    )

    private fun fixture(name: String): String {
        var dir: File? = File(System.getProperty("user.dir") ?: ".").absoluteFile
        while (dir != null && !File(dir, "settings.gradle.kts").isFile) dir = dir.parentFile
        val root = requireNotNull(dir) { "Could not locate repository root" }
        return File(root, "phone/src/test/resources/data-layer/v1/$name").readText(Charsets.UTF_8)
    }
}
