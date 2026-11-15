package com.sza.deviceinfo.ui.help

import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.webkit.WebResourceRequest
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.Toast
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import com.sza.deviceinfo.R
import com.sza.deviceinfo.databinding.ActivityHelpBinding
import com.sza.deviceinfo.ui.common.InterfaceScale
import com.sza.deviceinfo.util.applySystemBarInsetPadding
import timber.log.Timber

/**
 * Shows one help page (CONTEXT-HELP rule 7 and section 2.5, Android): the page is an asset of the app, shown in a
 * WebView with JavaScript off, so it opens with no network and makes no request (rule 12). Back returns to the screen
 * the help was opened from. A link to another shipped page stays here; every other address, and the "Open on the
 * site" action, leave for the system browser.
 */
class HelpActivity : AppCompatActivity() {

    private lateinit var binding: ActivityHelpBinding
    private var siteUrl: String? = null

    // S0023, exception E1: the page is shown at the interface scale the user chose (UI-SIZING 1.2 section 2).
    override fun attachBaseContext(newBase: Context) {
        super.attachBaseContext(InterfaceScale.wrap(newBase))
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
        Timber.d("S0024: HelpActivity created")
        binding = ActivityHelpBinding.inflate(layoutInflater)
        setContentView(binding.root)
        binding.root.applySystemBarInsetPadding()
        binding.helpToolbar.setUpNavigation(this)
        binding.helpToolbar.setOnMenuItemClickListener { item -> onAction(item.itemId) }

        val helpId = intent.getStringExtra(EXTRA_HELP_ID)
        val locale = intent.getStringExtra(EXTRA_LOCALE) ?: HelpPages.SOURCE_LOCALE
        siteUrl = intent.getStringExtra(EXTRA_SITE_URL)
        if (helpId == null) {
            Timber.w("HelpActivity: started without a help id")
            finish()
            return
        }
        configure(binding.helpWebView)
        // A rotation keeps the page and its scroll position instead of reloading the top of the page.
        val restored = savedInstanceState != null && binding.helpWebView.restoreState(savedInstanceState) != null
        if (!restored) {
            binding.helpWebView.loadUrl(HelpPages.assetUrl(locale, helpId, intent.getStringExtra(EXTRA_ANCHOR)))
        }
    }

    override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState)
        binding.helpWebView.saveState(outState)
    }

    override fun onDestroy() {
        binding.helpWebView.destroy()
        super.onDestroy()
    }

    private fun configure(webView: WebView) {
        with(webView.settings) {
            javaScriptEnabled = false
            allowFileAccess = false
            allowContentAccess = false
            blockNetworkLoads = true
        }
        webView.webViewClient = object : WebViewClient() {
            override fun shouldOverrideUrlLoading(view: WebView?, request: WebResourceRequest?): Boolean {
                val url = request?.url?.toString() ?: return true
                if (HelpPages.isInternal(url)) return false
                openInBrowser(url)
                return true
            }
        }
    }

    private fun onAction(itemId: Int): Boolean {
        when (itemId) {
            R.id.action_help_open_site -> siteUrl?.let(::openInBrowser)
            else -> return false
        }
        return true
    }

    /** Only web addresses leave the viewer; anything else a page might name is dropped. */
    private fun openInBrowser(url: String) {
        val uri = Uri.parse(url)
        if (uri.scheme != "https" && uri.scheme != "http") return
        try {
            startActivity(Intent(Intent.ACTION_VIEW, uri))
        } catch (e: ActivityNotFoundException) {
            Timber.w(e, "HelpActivity: no app opens %s", url)
            Toast.makeText(this, R.string.help_open_site_failed, Toast.LENGTH_LONG).show()
        }
    }

    companion object {
        private const val EXTRA_HELP_ID = "help_id"
        private const val EXTRA_ANCHOR = "help_anchor"
        private const val EXTRA_LOCALE = "help_locale"
        private const val EXTRA_SITE_URL = "help_site_url"

        fun createIntent(context: Context, helpId: String, anchor: String?, locale: String, siteUrl: String): Intent =
            Intent(context, HelpActivity::class.java)
                .putExtra(EXTRA_HELP_ID, helpId)
                .putExtra(EXTRA_ANCHOR, anchor)
                .putExtra(EXTRA_LOCALE, locale)
                .putExtra(EXTRA_SITE_URL, siteUrl)
    }
}
