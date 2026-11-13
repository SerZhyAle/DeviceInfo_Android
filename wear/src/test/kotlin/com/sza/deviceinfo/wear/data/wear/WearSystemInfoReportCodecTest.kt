package com.sza.deviceinfo.wear.data.wear

import com.google.gson.Gson
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

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
}
