package com.sza.deviceinfo.service

/**
 * Path constants for the Wear OS Data Layer - phone side.
 *
 * This product uses its own `/deviceinfo/` prefix, disjoint from FastMediaSorter's `/fms/`,
 * so the two products cannot collide on a device where both are installed.
 * Mirrored verbatim in the watch module's `com.sza.deviceinfo.wear.data.wear.WearDataLayerPaths`;
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
