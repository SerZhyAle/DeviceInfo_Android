package com.sza.deviceinfo.wear

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.wear.compose.material.MaterialTheme
import com.sza.deviceinfo.wear.ui.apps.systeminfo.SystemInfoScreen
import dagger.hilt.android.AndroidEntryPoint
import timber.log.Timber

@AndroidEntryPoint
class MainActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Timber.d("S0005: MainActivity created")
        setContent {
            MaterialTheme {
                SystemInfoScreen()
            }
        }
    }
}
