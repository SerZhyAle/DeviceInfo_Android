package com.sza.deviceinfo.service

import android.annotation.SuppressLint
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.FileProvider
import com.google.gson.Gson
import com.sza.deviceinfo.R
import com.sza.deviceinfo.core.logging.LoggingHelper
import com.sza.deviceinfo.core.notification.NotificationIcons
import com.sza.deviceinfo.core.notification.NotificationIds
import com.sza.deviceinfo.core.util.warnUnlessCancellation
import com.sza.deviceinfo.domain.model.WearSystemInfoReportAck
import com.sza.deviceinfo.domain.model.WearSystemInfoReportCodec
import com.sza.deviceinfo.domain.model.WearSystemInfoReportParseResult
import com.sza.deviceinfo.domain.model.WearSystemInfoReportPayload
import com.sza.deviceinfo.domain.repository.WearableDataLayerRepository
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import timber.log.Timber
import java.io.File
import java.time.Instant
import java.time.ZoneId
import java.time.format.DateTimeFormatter
import java.util.Locale
import javax.inject.Inject

/**
 * Takes one system-information report from the watch, stores it beside the phone's logs and answers.
 *
 * The answer goes out AFTER the notification decision, never on receipt, because a report that
 * arrives while notifications are suppressed leaves the user nothing to act on and the watch must be
 * able to say so.
 */
class WearSystemInfoReportReceiver @Inject constructor(
    @ApplicationContext private val context: Context,
    private val gson: Gson,
    private val dataLayerRepository: WearableDataLayerRepository
) {

    suspend fun handle(nodeId: String, data: ByteArray) {
        when (val parsed = WearSystemInfoReportCodec.parse(data, gson)) {
            is WearSystemInfoReportParseResult.Malformed -> {
                Timber.w("Wear system info report: payload could not be parsed")
                answer(nodeId, requestId = null, accepted = false, reason = REASON_MALFORMED)
            }

            is WearSystemInfoReportParseResult.UnsupportedVersion -> {
                Timber.w("Wear system info report: unknown format version ${parsed.version}")
                answer(nodeId, requestId = null, accepted = false, reason = REASON_UNSUPPORTED)
            }

            is WearSystemInfoReportParseResult.Parsed -> store(nodeId, parsed.payload)
        }
    }

    private suspend fun store(nodeId: String, payload: WearSystemInfoReportPayload) {
        val written = writeReport(payload)
        if (written == null) {
            answer(nodeId, payload.requestId, accepted = false, reason = REASON_NOT_STORED)
            return
        }

        val canNotify = NotificationManagerCompat.from(context).areNotificationsEnabled()
        if (canNotify) {
            postNotification(payload, written)
        }
        answer(
            nodeId = nodeId,
            requestId = payload.requestId,
            accepted = canNotify,
            reason = if (canNotify) null else REASON_NOTIFICATIONS_OFF
        )
    }

    /** Writes the report into the phone's log directory, off the main thread. */
    private suspend fun writeReport(payload: WearSystemInfoReportPayload): File? =
        withContext(Dispatchers.IO) {
            val logsDirectory = LoggingHelper.getLogsDirectory(context)
            val written = runCatching {
                val stamp = FILE_STAMP_FORMAT.format(Instant.ofEpochMilli(payload.capturedAtEpochMillis))
                val name = "${LoggingHelper.WATCH_SYSTEM_INFO_PREFIX}$stamp" +
                    LoggingHelper.WATCH_SYSTEM_INFO_SUFFIX
                val target = File(logsDirectory, name)
                target.parentFile?.mkdirs()
                target.writeText(header(payload, stamp) + payload.reportText)
                target
            }.onFailure { Timber.e(it, "Wear system info report: could not write the report") }.getOrNull()

            if (written != null) {
                LoggingHelper.pruneLogFiles(
                    logsDirectory,
                    LoggingHelper.WATCH_SYSTEM_INFO_PREFIX,
                    LoggingHelper.WATCH_SYSTEM_INFO_SUFFIX
                )
            }
            written
        }

    private fun header(payload: WearSystemInfoReportPayload, stamp: String): String = buildString {
        appendLine("device: ${payload.deviceModel} (Android ${payload.androidRelease})")
        appendLine("watch app: ${payload.appVersionName} (${payload.appVersionCode})")
        appendLine("captured: $stamp")
        appendLine()
    }

    @SuppressLint("MissingPermission")
    private fun postNotification(payload: WearSystemInfoReportPayload, written: File) {
        ensureChannel()
        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(NotificationIcons.STATUS_BAR)
            .setContentTitle(context.getString(R.string.wear_system_info_notification_title))
            .setContentText(context.getString(R.string.wear_system_info_notification_text))
            .setContentIntent(sharePendingIntent(written))
            .setAutoCancel(true)
            .build()
        runCatching { NotificationManagerCompat.from(context).notify(NOTIFICATION_ID, notification) }
            .onFailure {
                Timber.i(it, "Wear system info report: notification suppressed - POST_NOTIFICATIONS not granted")
            }
        Timber.i("Wear system info report: stored ${written.name} from ${payload.deviceModel}")
    }

    private fun sharePendingIntent(written: File): PendingIntent {
        val share = Intent(Intent.ACTION_SEND).apply {
            type = REPORT_MIME_TYPE
            uriOf(written)?.let { uri -> putExtra(Intent.EXTRA_STREAM, uri) }
            putExtra(Intent.EXTRA_SUBJECT, context.getString(R.string.wear_system_info_share_subject))
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        val chooser = Intent.createChooser(share, context.getString(R.string.wear_system_info_share_subject))
            .apply { addFlags(Intent.FLAG_ACTIVITY_NEW_TASK) }
        return PendingIntent.getActivity(
            context,
            NOTIFICATION_ID,
            chooser,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
    }

    private fun uriOf(written: File): Uri? = runCatching {
        FileProvider.getUriForFile(context, "${context.packageName}$FILE_PROVIDER_AUTHORITY_SUFFIX", written)
    }.onFailure {
        Timber.w(it, "Wear system info report: could not resolve a shareable URI")
    }.getOrNull()

    private fun ensureChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (manager.getNotificationChannel(CHANNEL_ID) != null) return
        manager.createNotificationChannel(
            NotificationChannel(
                CHANNEL_ID,
                context.getString(R.string.wear_system_info_channel_name),
                NotificationManager.IMPORTANCE_DEFAULT
            )
        )
    }

    private suspend fun answer(nodeId: String, requestId: String?, accepted: Boolean, reason: String?) {
        val ack = WearSystemInfoReportAck(requestId = requestId.orEmpty(), accepted = accepted, reason = reason)
        runCatching {
            dataLayerRepository.sendMessage(
                nodeId,
                WearDataLayerPaths.SYSTEM_INFO_REPORT_ACK,
                WearSystemInfoReportCodec.serializeAck(ack, gson)
            )
        }.onFailure { it.warnUnlessCancellation("Wear system info report: acknowledgement could not be sent") }
    }

    private companion object {
        const val CHANNEL_ID = "wear_system_info_report"
        const val NOTIFICATION_ID = NotificationIds.WATCH_SYSTEM_INFO_REPORT
        const val REASON_MALFORMED = "malformed"
        const val REASON_UNSUPPORTED = "unsupported_version"
        const val REASON_NOT_STORED = "not_stored"
        const val REASON_NOTIFICATIONS_OFF = "notifications_disabled"
        const val REPORT_MIME_TYPE = "text/plain"
        const val FILE_PROVIDER_AUTHORITY_SUFFIX = ".fileprovider"

        val FILE_STAMP_FORMAT: DateTimeFormatter =
            DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss", Locale.US).withZone(ZoneId.systemDefault())
    }
}
