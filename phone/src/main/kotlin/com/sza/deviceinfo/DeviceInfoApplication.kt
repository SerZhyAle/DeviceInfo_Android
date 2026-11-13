package com.sza.deviceinfo

import android.app.Application
import dagger.hilt.android.HiltAndroidApp
import timber.log.Timber

/** Hosts the Hilt component and plants the one logging tree; release builds log nothing. */
@HiltAndroidApp
class DeviceInfoApplication : Application() {

    override fun onCreate() {
        super.onCreate()
        if (BuildConfig.DEBUG) Timber.plant(Timber.DebugTree())
    }
}
