package com.sza.deviceinfo.wear.data.wear

import com.google.gson.Gson
import com.google.gson.annotations.SerializedName

/**
 * The system-information report one watch-to-phone message carries.
 *
 * Its own type rather than a generic report payload: the reports are stored under specific names and
 * announced with specific words on the phone.
 *
 * The version travels inside the payload rather than in the path: a phone that does not know a newer
 * shape still parses the version, refuses by name and says why, instead of staying silent.
 */
data class WearSystemInfoReportPayload(
    @SerializedName("requestId") val requestId: String,
    @SerializedName("formatVersion") val formatVersion: Int = FORMAT_VERSION,
    @SerializedName("appVersionName") val appVersionName: String,
    @SerializedName("appVersionCode") val appVersionCode: Long,
    @SerializedName("deviceModel") val deviceModel: String,
    @SerializedName("androidRelease") val androidRelease: String,
    @SerializedName("capturedAtEpochMillis") val capturedAtEpochMillis: Long,
    @SerializedName("reportText") val reportText: String
) {

    companion object {

        /** Bumped whenever a field changes meaning; the phone refuses anything it does not know. */
        const val FORMAT_VERSION: Int = 1
    }
}

/** The phone's answer to one system-information report. */
data class WearSystemInfoReportAck(
    @SerializedName("requestId") val requestId: String,
    @SerializedName("accepted") val accepted: Boolean,
    @SerializedName("reason") val reason: String? = null
)

/** Turns a report into the bytes of one Data Layer message. */
object WearSystemInfoReportCodec {

    /**
     * HTML escaping off: the injected Gson escapes `=`, `<` and `'` into six-byte sequences,
     * and a report full of `=` would serialise to several times its size for a wire that is not a web page.
     */
    fun serialize(payload: WearSystemInfoReportPayload, gson: Gson): ByteArray =
        gson.newBuilder().disableHtmlEscaping().create()
            .toJson(payload.copy(formatVersion = WearSystemInfoReportPayload.FORMAT_VERSION))
            .toByteArray()
}
