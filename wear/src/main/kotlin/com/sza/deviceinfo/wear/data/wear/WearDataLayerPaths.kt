package com.sza.deviceinfo.wear.data.wear

/**
 * Path constants for the Wear OS Data Layer - watch side mirror.
 *
 * String values are identical to the phone-side WearDataLayerPaths to guarantee path matching.
 * Mirrored verbatim from `com.sza.deviceinfo.service.WearDataLayerPaths`;
 * a unit test asserts that both files declare the exact same constant map.
 */
object WearDataLayerPaths {

    /**
     * Message, watch -> phone. Carries the watch's own system-information report as flat text.
     */
    const val SYSTEM_INFO_REPORT = "/deviceinfo/watch/system_info_report"

    /**
     * Message, phone -> watch. Answers one system-information report - stored, or refused with a reason.
     */
    const val SYSTEM_INFO_REPORT_ACK = "/deviceinfo/phone/system_info_report_ack"
}
