package com.sza.deviceinfo.ui.systeminfo

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.KeyEvent
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import com.sza.deviceinfo.R
import com.sza.deviceinfo.databinding.ActivitySystemInfoBinding
import com.sza.deviceinfo.ui.common.InterfaceScale
import com.sza.deviceinfo.ui.help.HelpLauncher
import com.sza.deviceinfo.ui.help.HelpSurfaces
import com.sza.deviceinfo.ui.systeminfo.helpers.SystemInfoWindowManager
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.launch
import timber.log.Timber
import javax.inject.Inject

/**
 * Host for the full System information screen.
 *
 * S0024 deliberate difference from upstream: F1 and the Help action open the in-app help through [HelpLauncher]
 * (CONTEXT-HELP rules 1 and 3). Upstream reserved F1 for a help viewer that was never written and swallowed the key.
 */
@AndroidEntryPoint
class SystemInfoActivity : AppCompatActivity() {

    @Inject lateinit var systemInfoWindowManager: SystemInfoWindowManager
    private lateinit var binding: ActivitySystemInfoBinding

    // S0023, exception E1: the screen is created at the interface scale the user chose (UI-SIZING 1.2 section 2).
    override fun attachBaseContext(newBase: Context) {
        super.attachBaseContext(InterfaceScale.wrap(newBase))
    }

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

    override fun onPause() {
        systemInfoWindowManager.saveViewport()
        super.onPause()
    }

    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        if (keyCode == KeyEvent.KEYCODE_F1) {
            // A held key repeats; only the first press asks. The focused view picks the element's entry (rule 3).
            if (event?.repeatCount == 0) HelpLauncher.open(this, HelpSurfaces.SYSTEM_INFO, currentFocus)
            return true
        }
        return super.onKeyDown(keyCode, event)
    }

    override fun dispatchKeyShortcutEvent(event: KeyEvent): Boolean {
        if (event.action == KeyEvent.ACTION_DOWN && event.hasModifiers(KeyEvent.META_CTRL_ON)) {
            when (event.keyCode) {
                KeyEvent.KEYCODE_F -> {
                    binding.systemInfoSearchView.requestFocus()
                    return true
                }
                KeyEvent.KEYCODE_S -> {
                    binding.systemInfoToolbar.menu.performIdentifierAction(R.id.action_system_info_save, 0)
                    return true
                }
            }
        }
        return super.dispatchKeyShortcutEvent(event)
    }

    companion object {
        fun createIntent(context: Context): Intent = Intent(context, SystemInfoActivity::class.java)
    }
}
