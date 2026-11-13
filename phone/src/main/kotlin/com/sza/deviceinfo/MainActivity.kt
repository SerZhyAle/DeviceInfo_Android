package com.sza.deviceinfo

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.sza.deviceinfo.ui.systeminfo.SystemInfoActivity
import timber.log.Timber

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Timber.d("S0007: MainActivity created")
        startActivity(SystemInfoActivity.createIntent(this))
        finish()
    }
}
