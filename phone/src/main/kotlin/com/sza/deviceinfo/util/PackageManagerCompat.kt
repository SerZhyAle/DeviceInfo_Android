package com.sza.deviceinfo.util

import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.os.Build

/**
 * Single compat seam for the [PackageManager] query APIs whose raw-int flag overloads were
 * deprecated in API 33 (Tiramisu) in favor of the type-safe `*Flags.of(Long)` overloads.
 *
 * Centralizing the one `Build.VERSION` branch here keeps call sites free of `@Suppress("DEPRECATION")`
 * and stops new code from copying the deprecated raw-int pattern. Upstream also carries compat helpers for
 * application info and intent queries; nothing on the System info path calls them, so they are not ported.
 */

fun PackageManager.getPackageInfoCompat(packageName: String, flags: Int = 0): PackageInfo =
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
        getPackageInfo(packageName, PackageManager.PackageInfoFlags.of(flags.toLong()))
    } else {
        getPackageInfo(packageName, flags)
    }

fun PackageManager.queryIntentActivitiesCompat(intent: android.content.Intent, flags: Int = 0): List<android.content.pm.ResolveInfo> =
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
        queryIntentActivities(intent, PackageManager.ResolveInfoFlags.of(flags.toLong()))
    } else {
        @Suppress("DEPRECATION")
        queryIntentActivities(intent, flags)
    }
