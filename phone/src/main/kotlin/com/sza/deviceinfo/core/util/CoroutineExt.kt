package com.sza.deviceinfo.core.util

import kotlinx.coroutines.CancellationException
import timber.log.Timber

/**
 * Re-throws this throwable when it represents coroutine cancellation, otherwise returns normally.
 */
fun Throwable.rethrowIfCancellation() {
    if (this is CancellationException) throw this
}

/**
 * Log [message] at warning level - unless this throwable is coroutine cancellation, which is rethrown instead.
 */
fun Throwable.warnUnlessCancellation(message: String, vararg args: Any?) {
    rethrowIfCancellation()
    Timber.w(this, message, *args)
}

