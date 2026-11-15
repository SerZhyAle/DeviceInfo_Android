package com.sza.deviceinfo.wear.data.wear

import com.google.gson.Gson
import com.google.gson.JsonParser
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import java.io.File

class WearSystemInfoReportCodecTest {

    private val gson = Gson()

    @Test
    fun `serialize encodes payload with format version`() {
        val payload = WearSystemInfoReportPayload(
            requestId = "req-123",
            appVersionName = "1.0.0",
            appVersionCode = 10,
            deviceModel = "Pixel Watch 3",
            androidRelease = "14",
            capturedAtEpochMillis = 1700000000000L,
            reportText = "device: Pixel Watch 3\n"
        )

        val bytes = WearSystemInfoReportCodec.serialize(payload, gson)
        val json = String(bytes, Charsets.UTF_8)

        assertTrue(json.contains("\"requestId\":\"req-123\""))
        assertTrue(json.contains("\"formatVersion\":1"))
        assertTrue(json.contains("\"deviceModel\":\"Pixel Watch 3\""))
    }

    @Test
    fun `ack parsing round trip`() {
        val ackJson = """{"requestId":"req-456","accepted":true}"""
        val ack = gson.fromJson(ackJson, WearSystemInfoReportAck::class.java)

        assertEquals("req-456", ack.requestId)
        assertTrue(ack.accepted)
        assertEquals(null, ack.reason)
    }

    @Test
    fun `ack with refusal reason parsing`() {
        val ackJson = """{"requestId":"req-789","accepted":false,"reason":"notifications_disabled"}"""
        val ack = gson.fromJson(ackJson, WearSystemInfoReportAck::class.java)

        assertEquals("req-789", ack.requestId)
        assertEquals(false, ack.accepted)
        assertEquals("notifications_disabled", ack.reason)
    }

    @Test
    fun `version one report and acknowledgement remain compatible`() {
        val reportJson = fixture("report.json")
        val report = gson.fromJson(reportJson, WearSystemInfoReportPayload::class.java)
        assertEquals(expectedV1Report(), report)
        val encoded = WearSystemInfoReportCodec.serialize(report, gson).toString(Charsets.UTF_8)
        assertEquals(JsonParser.parseString(reportJson), JsonParser.parseString(encoded))

        val ack = gson.fromJson(fixture("ack.json"), WearSystemInfoReportAck::class.java)
        assertEquals(WearSystemInfoReportAck("req-v1", accepted = true, reason = null), ack)
    }

    @Test
    fun `version one messages ignore unknown fields and default the omitted optional reason`() {
        val report = JsonParser.parseString(fixture("report.json")).asJsonObject
        report.addProperty("futureReportField", "ignored")
        assertEquals(expectedV1Report(), gson.fromJson(report, WearSystemInfoReportPayload::class.java))

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
