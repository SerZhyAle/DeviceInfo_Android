package com.sza.deviceinfo.ui.systeminfo

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.KeyEvent
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import com.sza.deviceinfo.databinding.ActivitySystemInfoBinding
import com.sza.deviceinfo.ui.systeminfo.helpers.SystemInfoWindowManager
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.launch
import timber.log.Timber
import javax.inject.Inject

/**
 * Host for the full System information screen.
 */
@AndroidEntryPoint
class SystemInfoActivity : AppCompatActivity() {

    @Inject lateinit var systemInfoWindowManager: SystemInfoWindowManager
    private lateinit var binding: ActivitySystemInfoBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
        Timber.d("S0004: SystemInfoActivity created")
        binding = ActivitySystemInfoBinding.inflate(layoutInflater)
        setContentView(binding.root)
        systemInfoWindowManager.bind(this, binding)
        lifecycleScope.launch {
            val report = systemInfoWindowManager.gather(this@SystemInfoActivity)
            if (isFinishing || isDestroyed) return@launch
            systemInfoWindowManager.render(binding, report)
            binding.systemInfoSearchView.requestFocus()
            systemInfoWindowManager.onScreenShown(this@SystemInfoActivity)
        }
    }

    override fun onResume() {
        super.onResume()
        systemInfoWindowManager.onResume(binding)
    }

    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        if (keyCode == KeyEvent.KEYCODE_F1) {
            // Reserved for in-app help viewer
            return true
        }
        return super.onKeyDown(keyCode, event)
    }

    companion object {
        fun createIntent(context: Context): Intent = Intent(context, SystemInfoActivity::class.java)
    }
}
