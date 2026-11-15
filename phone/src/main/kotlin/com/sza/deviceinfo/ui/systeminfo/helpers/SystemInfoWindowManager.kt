package com.sza.deviceinfo.ui.systeminfo.helpers

import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.widget.SearchView
import androidx.appcompat.widget.TooltipCompat
import androidx.core.view.MenuItemCompat
import androidx.lifecycle.lifecycleScope
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.sza.deviceinfo.R
import com.sza.deviceinfo.core.clipboard.copyTextToClipboard
import com.sza.deviceinfo.core.systeminfo.SystemInfoReport
import com.sza.deviceinfo.core.systeminfo.SystemInfoSection
import com.sza.deviceinfo.core.systeminfo.renderSystemInfo
import com.sza.deviceinfo.core.util.rethrowIfCancellation
import com.sza.deviceinfo.databinding.ActivitySystemInfoBinding
import com.sza.deviceinfo.di.IoDispatcher
import com.sza.deviceinfo.domain.repository.SystemInfoGroupStateRepository
import com.sza.deviceinfo.ui.help.HelpLauncher
import com.sza.deviceinfo.ui.help.HelpSurfaces
import com.sza.deviceinfo.ui.systeminfo.adapter.SystemInfoAdapter
import com.sza.deviceinfo.ui.systeminfo.model.SystemInfoListItem
import com.sza.deviceinfo.util.applySystemBarInsetPadding
import com.sza.deviceinfo.util.queryIntentActivitiesCompat
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import timber.log.Timber
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import javax.inject.Inject

/**
 * Keeps report gathering, rendering and export behaviour out of the screen host.
 *
 * S0024 deliberate difference from upstream: the Help action opens the in-app help through [HelpLauncher] and carries
 * the accessible name and tooltip "Help (F1)"; upstream left its branch empty.
 */
class SystemInfoWindowManager @Inject constructor(
    private val systemInfoDialogManager: SystemInfoDialogManager,
    private val notificationPermission: NotificationPermissionCoordinator,
    @ApplicationContext private val appContext: Context,
    groupStateRepository: SystemInfoGroupStateRepository,
    private val viewportStore: SystemInfoViewportStore,
    @IoDispatcher private val ioDispatcher: CoroutineDispatcher,
) {
    private var currentReport: SystemInfoReport? = null
    private var systemInfoAdapter: SystemInfoAdapter? = null
    private val expansionState = SystemInfoExpansionState(groupStateRepository)
    private var currentQuery: String = ""

    private var recyclerView: RecyclerView? = null
    private var gridLayoutManager: GridLayoutManager? = null

    /**
     * Groups the user closed while a search is showing (COLLAPSIBLE-GROUP 1.2 section 4 rule 2: a search expands the
     * groups that hold matches, but activating a header still toggles it). It belongs to one search text and is
     * dropped when the text changes. Nothing here is remembered across launches: a search is a view of the report,
     * not a change to the groups' own state.
     */
    private val searchCollapsed = mutableSetOf<String>()
    private var searchedText: String = ""

    /** The saved viewport is applied once per screen instance, after the first list is on screen. */
    private var viewportPending = true

    suspend fun gather(context: Context): SystemInfoReport = systemInfoDialogManager.gather(context)

    /** Raises the one-time notification explanation once the report is on screen. */
    fun onScreenShown(activity: AppCompatActivity) = notificationPermission.onScreenShown(activity)

    /** Re-reads whether notifications are on, so the menu entry follows a return from the system settings. */
    fun onResume(binding: ActivitySystemInfoBinding) = notificationPermission.refreshMenu(binding)

    fun bind(activity: AppCompatActivity, binding: ActivitySystemInfoBinding) {
        notificationPermission.bind(activity, binding)
        binding.root.applySystemBarInsetPadding()
        binding.systemInfoToolbar.setUpNavigation(activity)
        binding.systemInfoToolbar.setOnMenuItemClickListener { item -> onAction(activity, binding, item.itemId) }
        binding.systemInfoToolbar.menu.findItem(R.id.action_system_info_save)?.let {
            MenuItemCompat.setTooltipText(it, activity.getString(R.string.sysinfo_save_shortcut_tooltip))
        }
        // CONTEXT-HELP rule 2: the Help action is named "Help (F1)" for the eye and for a screen reader.
        binding.systemInfoToolbar.menu.findItem(R.id.action_help)?.let {
            val name = activity.getString(R.string.sysinfo_help_shortcut_tooltip)
            MenuItemCompat.setTooltipText(it, name)
            MenuItemCompat.setContentDescription(it, name)
        }
        TooltipCompat.setTooltipText(binding.systemInfoSearchView, activity.getString(R.string.sysinfo_search_shortcut_tooltip))

        systemInfoAdapter = SystemInfoAdapter(
            onToggleSection = { stateKey -> onToggleSection(binding, stateKey) },
            onCopySection = { stateKey -> onCopySection(stateKey) },
            onCopyField = { label, value -> onCopyField(label, value) },
        )

        val list = binding.systemInfoRecyclerView
        val density = activity.resources.displayMetrics.density
        // Content-sized packing: one span per dp of usable width; see SystemInfoHeaderPacking.
        val manager = GridLayoutManager(activity, 1)
        manager.spanSizeLookup = object : GridLayoutManager.SpanSizeLookup() {
            override fun getSpanSize(position: Int): Int {
                val spanCount = manager.spanCount
                val item = systemInfoAdapter?.currentList?.getOrNull(position) ?: return spanCount
                return when (item) {
                    is SystemInfoListItem.SectionHeader ->
                        if (item.isExpanded) {
                            spanCount
                        } else {
                            val natural = systemInfoAdapter?.collapsedHeaderCellWidthPx(list.context, item) ?: 0
                            SystemInfoHeaderPacking.spanSize(
                                naturalWidthPx = natural + (SPAN_SLACK_DP * density).toInt(),
                                usableWidthPx = usableWidthPx(list),
                                spanCount = spanCount,
                            )
                        }
                    is SystemInfoListItem.Field -> spanCount
                    is SystemInfoListItem.EmptyState -> spanCount
                }
            }
        }
        list.addOnLayoutChangeListener { _, _, _, _, _, _, _, _, _ ->
            val count = SystemInfoHeaderPacking.spanCountFor(usableWidthPx(list), density)
            if (manager.spanCount != count) manager.spanCount = count
        }
        recyclerView = list
        gridLayoutManager = manager

        list.apply {
            layoutManager = manager
            adapter = systemInfoAdapter
        }

        binding.systemInfoSearchView.setOnQueryTextListener(object : SearchView.OnQueryTextListener {
            override fun onQueryTextSubmit(query: String?): Boolean {
                currentQuery = query.orEmpty()
                filterAndSubmit(currentQuery)
                return true
            }

            override fun onQueryTextChange(newText: String?): Boolean {
                currentQuery = newText.orEmpty()
                filterAndSubmit(currentQuery)
                return true
            }
        })
    }

    private fun onAction(activity: AppCompatActivity, binding: ActivitySystemInfoBinding, itemId: Int): Boolean {
        val report = currentReport
        when (itemId) {
            R.id.action_system_info_copy -> report?.let(::copyReport)
            R.id.action_system_info_save -> report?.let { activity.lifecycleScope.launch { saveReport(it) } }
            R.id.action_system_info_share -> report?.let { share(activity, it.fullText) }
            R.id.action_system_info_expand_collapse -> toggleExpandCollapseAll(binding)
            R.id.action_system_info_notifications -> notificationPermission.onMenuAction(activity)
            R.id.action_system_info_interface_size -> InterfaceScalePicker.show(activity)
            R.id.action_help -> HelpLauncher.open(activity, HelpSurfaces.SYSTEM_INFO)
            else -> return false
        }
        return true
    }

    fun render(binding: ActivitySystemInfoBinding, report: SystemInfoReport) {
        currentReport = report
        updateExpandCollapseIcon(binding)
        filterAndSubmit(currentQuery)
    }

    private fun toggleExpandCollapseAll(binding: ActivitySystemInfoBinding) {
        val sections = nonEmptySections() ?: return
        expansionState.setAll(sections, expanded = !expansionState.allExpanded(sections))
        searchCollapsed.clear()
        updateExpandCollapseIcon(binding)
        filterAndSubmit(currentQuery)
    }

    /**
     * Activating a header opens or closes its group. While a search is showing the groups that hold matches are
     * open, so the activation only closes or reopens that group for this search and leaves the remembered state
     * alone. Either way the activated header stays the viewport anchor.
     */
    private fun onToggleSection(binding: ActivitySystemInfoBinding, stateKey: String) {
        val anchor = captureHeaderAnchor(stateKey)
        if (currentQuery.isSearching()) {
            if (!searchCollapsed.add(stateKey)) searchCollapsed.remove(stateKey)
        } else {
            expansionState.toggle(stateKey)
        }
        updateExpandCollapseIcon(binding)
        filterAndSubmit(currentQuery, anchor)
    }

    private fun String.isSearching(): Boolean = trim().isNotEmpty()

    private fun usableWidthPx(list: RecyclerView): Int = list.width - list.paddingLeft - list.paddingRight

    /** Where the activated header sits now, so it can be put back at the same height after the list reflows. */
    private fun captureHeaderAnchor(stateKey: String): SystemInfoViewportAnchor? {
        val list = recyclerView ?: return null
        val position = systemInfoAdapter?.currentList
            ?.indexOfFirst { it is SystemInfoListItem.SectionHeader && it.stateKey == stateKey }
            ?: return null
        if (position < 0) return null
        val view = list.layoutManager?.findViewByPosition(position) ?: return null
        return SystemInfoViewportAnchor("h:$stateKey", view.top - list.paddingTop)
    }

    /**
     * Puts the anchor's item back at its offset once, after the list that holds it is committed. The activity does
     * not scroll to the first child, the top or the end of the group; a boundary keeps the closest feasible position
     * because the layout manager clamps the offset instead of retrying.
     */
    private fun restoreAnchor(items: List<SystemInfoListItem>, anchor: SystemInfoViewportAnchor) {
        val position = items.indexOfAnchor(anchor.key)
        if (position >= 0) gridLayoutManager?.scrollToPositionWithOffset(position, anchor.offsetPx)
    }

    /**
     * Remembers the first visible item and its offset (COLLAPSIBLE-GROUP 1.2 section 4 rule 7). A search is only a
     * view of the report, so its scroll position is not remembered, and nothing is saved before a list is shown.
     */
    fun saveViewport() {
        val list = recyclerView ?: return
        val manager = gridLayoutManager ?: return
        if (currentQuery.isSearching()) return
        val position = manager.findFirstVisibleItemPosition()
        if (position == RecyclerView.NO_POSITION) return
        val key = systemInfoAdapter?.currentList?.getOrNull(position)?.anchorKey() ?: return
        val view = manager.findViewByPosition(position) ?: return
        viewportStore.save(SystemInfoViewportAnchor(key, view.top - list.paddingTop))
    }

    private fun nonEmptySections(): List<SystemInfoSection>? =
        currentReport?.sections?.filter { it.fields.isNotEmpty() }

    private fun updateExpandCollapseIcon(binding: ActivitySystemInfoBinding) {
        val sections = nonEmptySections() ?: return
        val item = binding.systemInfoToolbar.menu.findItem(R.id.action_system_info_expand_collapse) ?: return
        if (expansionState.allExpanded(sections)) {
            item.setIcon(R.drawable.ic_expand_less)
            item.setTitle(R.string.sysinfo_action_collapse_all)
        } else {
            item.setIcon(R.drawable.ic_expand_more)
            item.setTitle(R.string.sysinfo_action_expand_all)
        }
    }

    private fun filterAndSubmit(query: String, anchor: SystemInfoViewportAnchor? = null) {
        val report = currentReport ?: return
        val items = mutableListOf<SystemInfoListItem>()
        val trimmedQuery = query.trim()
        val isSearch = trimmedQuery.isNotEmpty()
        if (trimmedQuery != searchedText) {
            searchedText = trimmedQuery
            searchCollapsed.clear()
        }

        report.sections.filter { it.fields.isNotEmpty() }.forEach { section ->
            val matchingFields = if (isSearch) {
                section.fields.filter { (label, value) ->
                    label.contains(trimmedQuery, ignoreCase = true) ||
                        value.contains(trimmedQuery, ignoreCase = true) ||
                        section.title.contains(trimmedQuery, ignoreCase = true)
                }
            } else {
                section.fields
            }

            if (matchingFields.isNotEmpty()) {
                val isExpanded = if (isSearch) {
                    section.stateKey !in searchCollapsed
                } else {
                    expansionState.isExpanded(section.stateKey)
                }
                items.add(
                    SystemInfoListItem.SectionHeader(
                        title = section.title,
                        stateKey = section.stateKey,
                        count = matchingFields.size,
                        isExpanded = isExpanded,
                        iconRes = SystemInfoGroupIcons.iconFor(section.group),
                    )
                )
                if (isExpanded) {
                    matchingFields.forEachIndexed { index, (label, value) ->
                        items.add(
                            SystemInfoListItem.Field(
                                sectionKey = section.stateKey,
                                label = label,
                                value = value,
                                isShaded = index % 2 == 1,
                            )
                        )
                    }
                }
            }
        }

        if (items.isEmpty() && isSearch) {
            items.add(
                SystemInfoListItem.EmptyState(
                    message = appContext.getString(R.string.sysinfo_search_empty),
                )
            )
        }

        systemInfoAdapter?.submitList(items) {
            val restore = anchor ?: savedViewportOnce(isSearch)
            if (restore != null) restoreAnchor(items, restore)
        }
    }

    /** The remembered viewport, handed out once per screen instance and never while a search is showing. */
    private fun savedViewportOnce(isSearch: Boolean): SystemInfoViewportAnchor? {
        if (!viewportPending || isSearch) return null
        viewportPending = false
        return viewportStore.load()
    }

    private fun onCopySection(stateKey: String) {
        val section = currentReport?.sections?.firstOrNull { it.stateKey == stateKey } ?: return
        val text = listOf(section).renderSystemInfo()
        appContext.copyTextToClipboard("System info ${section.title}", text)
        val message = appContext.getString(R.string.sysinfo_toast_section_copied, section.title)
        Toast.makeText(appContext, message, Toast.LENGTH_SHORT).show()
    }

    private fun onCopyField(label: String, value: String) {
        val textToCopy = "$label: $value"
        appContext.copyTextToClipboard(label, textToCopy)
        Toast.makeText(appContext, textToCopy, Toast.LENGTH_SHORT).show()
    }

    private fun copyReport(report: SystemInfoReport) = appContext.copyTextToClipboard("System info", report.fullText)

    private fun share(activity: AppCompatActivity, text: String) {
        val shareIntent = Intent(Intent.ACTION_SEND).apply {
            type = "text/plain"
            putExtra(Intent.EXTRA_TEXT, text)
        }
        if (activity.packageManager.queryIntentActivitiesCompat(shareIntent, 0).isEmpty()) {
            currentReport?.let(::copyReport)
            Toast.makeText(activity, R.string.export_logs_no_share_target, Toast.LENGTH_LONG).show()
        } else {
            activity.startActivity(
                Intent.createChooser(
                    shareIntent,
                    activity.getString(R.string.share)
                )
            )
        }
    }

    private suspend fun saveReport(report: SystemInfoReport) {
        val name = "device_info_${SimpleDateFormat("yyyyMMdd_HHmmss", Locale.US).format(Date())}.txt"
        try {
            withContext(ioDispatcher) { writeReport(name, report.fullText) }
            val message = appContext.getString(R.string.s0116_toast_saved_to_downloads, name)
            Toast.makeText(appContext, message, Toast.LENGTH_SHORT).show()
        } catch (@Suppress("TooGenericExceptionCaught") e: Exception) {
            e.rethrowIfCancellation()
            Timber.w(e, "SystemInfoWindowManager: saving the report to Downloads failed")
            Toast.makeText(appContext, R.string.system_info_save_failed, Toast.LENGTH_LONG).show()
        }
    }

    private fun writeReport(name: String, text: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val values = ContentValues().apply {
                put(MediaStore.Downloads.DISPLAY_NAME, name)
                put(MediaStore.Downloads.MIME_TYPE, "text/plain")
            }
            val resolver = appContext.contentResolver
            val uri = checkNotNull(resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)) {
                "MediaStore refused the Downloads entry"
            }
            checkNotNull(resolver.openOutputStream(uri)) { "No output stream for $uri" }
                .use { it.write(text.toByteArray()) }
        } else {
            @Suppress("DEPRECATION")
            File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS), name)
                .writeText(text)
        }
    }

    private companion object {
        /** Absorbs rounding between the measured header and the span grid so a header's title does not wrap by a hair. */
        const val SPAN_SLACK_DP = 2
    }
}
