package com.sza.deviceinfo.domain.model

import com.google.gson.Gson
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

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
}
