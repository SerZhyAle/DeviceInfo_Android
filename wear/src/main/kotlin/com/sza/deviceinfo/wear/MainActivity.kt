package com.sza.deviceinfo.wear

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.runtime.CompositionLocalProvider
import com.sza.deviceinfo.wear.ui.apps.systeminfo.SystemInfoScreen
import com.sza.deviceinfo.wear.ui.common.LocalWearInterfaceScale
import com.sza.deviceinfo.wear.ui.common.WearInterfaceScaleScope
import com.sza.deviceinfo.wear.ui.common.WearInterfaceScaleStore
import com.sza.deviceinfo.wear.ui.theme.DeviceInfoWearTheme
import dagger.hilt.android.AndroidEntryPoint
import timber.log.Timber
import javax.inject.Inject

@AndroidEntryPoint
class MainActivity : ComponentActivity() {

    @Inject lateinit var interfaceScale: WearInterfaceScaleStore

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Timber.d("S0005: MainActivity created")
        setContent {
            // S0023, exception E1: one interface scale around the whole screen (UI-SIZING 1.2 section 2).
            CompositionLocalProvider(LocalWearInterfaceScale provides interfaceScale) {
                WearInterfaceScaleScope(interfaceScale.percent) {
                    DeviceInfoWearTheme {
                        SystemInfoScreen()
                    }
                }
            }
        }
    }
}
