package com.sza.deviceinfo.core.logging

import android.content.Context
import java.io.File

object LoggingHelper {
    const val WATCH_SYSTEM_INFO_PREFIX = "watch_sysinfo_"
    const val WATCH_SYSTEM_INFO_SUFFIX = ".txt"
    const val MAX_LOG_FILES = 10
    private const val LOG_DIR_NAME = "logs"

    fun getLogsDirectory(context: Context): File =
        File(context.getExternalFilesDir(null) ?: context.filesDir, LOG_DIR_NAME)

    fun pruneLogFiles(
        directory: File,
        namePrefix: String,
        nameSuffix: String,
        keep: Int = MAX_LOG_FILES
    ) {
        val files = directory.listFiles { file ->
            file.isFile && file.name.startsWith(namePrefix) && file.name.endsWith(nameSuffix)
        }?.sortedByDescending { it.name } ?: emptyList()
        files.drop(keep).forEach { file -> file.delete() }
    }
}
