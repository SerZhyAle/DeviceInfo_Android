package com.sza.deviceinfo.wear.ui.apps.systeminfo

import androidx.annotation.StringRes
import androidx.compose.foundation.background
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.sizeIn
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.Send
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.runtime.snapshotFlow
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.res.dimensionResource
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.stateDescription
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.LayoutDirection
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.wear.compose.foundation.lazy.ScalingLazyListState
import androidx.wear.compose.foundation.lazy.itemsIndexed
import androidx.wear.compose.material.CircularProgressIndicator
import androidx.wear.compose.material.Icon
import androidx.wear.compose.material.MaterialTheme
import androidx.wear.compose.material.PositionIndicator
import androidx.wear.compose.material.Text
import com.sza.deviceinfo.wear.R
import com.sza.deviceinfo.wear.domain.model.WearSystemInfoField
import com.sza.deviceinfo.wear.domain.model.WearSystemInfoSection
import com.sza.deviceinfo.wear.domain.model.WearSystemInfoValue
import com.sza.deviceinfo.wear.ui.common.LocalWearInterfaceScale
import com.sza.deviceinfo.wear.ui.common.LocalWearSectionExpansion
import com.sza.deviceinfo.wear.ui.common.LocalWearTileEven
import com.sza.deviceinfo.wear.ui.common.WearActionButton
import com.sza.deviceinfo.wear.ui.common.WearInformationRow
import com.sza.deviceinfo.wear.ui.common.WearInformationRowGestures
import com.sza.deviceinfo.wear.ui.common.WearListColumn
import com.sza.deviceinfo.wear.ui.common.WearReportDivider
import com.sza.deviceinfo.wear.ui.common.WearScreenScaffold
import com.sza.deviceinfo.wear.ui.common.WearInterfaceScaleStore
import com.sza.deviceinfo.wear.ui.common.WearSectionExpansionStore
import com.sza.deviceinfo.wear.ui.common.WearSettingsItem
import com.sza.deviceinfo.wear.ui.common.WearSettingsRow
import com.sza.deviceinfo.wear.ui.common.WearViewportAnchor
import com.sza.deviceinfo.wear.ui.common.WearViewportStore
import com.sza.deviceinfo.wear.ui.common.findAnchorRow
import com.sza.deviceinfo.wear.ui.common.packSettingsRows
import com.sza.deviceinfo.wear.ui.common.rememberWearListState
import com.sza.deviceinfo.wear.ui.common.rowAnchorKeys
import kotlinx.coroutines.flow.filter
import timber.log.Timber

private const val SYSTEM_INFO_SCREEN_KEY = "apps/systeminfo"
private const val SYSTEM_INFO_FIELDS_KEY = "apps/systeminfo/fields"

/** List items before the report rows: the title, then the loading indicator or the two actions. */
private const val LEADING_ITEMS = 2

private const val TWO_COLUMN_MIN_SCREEN_WIDTH_DP = 225

private val TITLE_BOTTOM_PADDING = 8.dp

/** Inset on each side of the main title, so its wrapped lines stay inside the round screen (S0043). */
private val TITLE_HORIZONTAL_INSET = 12.dp
private val ROW_VERTICAL_PADDING = 4.dp
private val CHIP_GAP = 8.dp
private val CHIP_CORNER = 4.dp
private val CHIP_HORIZONTAL_PADDING = 8.dp
private val CHIP_VERTICAL_PADDING = 6.dp
private val DISCLOSURE_MARKER_SIZE = 16.dp
private val DISCLOSURE_MARKER_GAP = 8.dp
private val SECTION_GLYPH_SIZE = 16.dp
private val SECTION_GLYPH_GAP = 6.dp

/**
 * What the watch can say about itself, in the same shape the phone's report uses: a section title, then
 * name-value pairs.
 */
@Composable
fun SystemInfoScreen(
    viewModel: SystemInfoViewModel = hiltViewModel(),
    listState: ScalingLazyListState = rememberWearListState(positionKey = SYSTEM_INFO_SCREEN_KEY)
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    val context = LocalContext.current.applicationContext
    val expansion = LocalWearSectionExpansion.current ?: remember(context) { WearSectionExpansionStore(context) }
    val interfaceScale = LocalWearInterfaceScale.current
    val configuration = LocalConfiguration.current
    val columns = if (configuration.screenWidthDp >= TWO_COLUMN_MIN_SCREEN_WIDTH_DP) 2 else 1
    val entryName: (Int) -> String = remember(context) { { id -> context.resources.getResourceEntryName(id) } }
    var activatedKey by remember { mutableStateOf<String?>(null) }
    val rows = packSettingsRows(
        reportItems(uiState.sections, expansion, entryName) { key -> activatedKey = key },
        columns
    )
    val rowKeys = rows.map(::rowAnchorKeys)
    val viewportStore = remember(context) { WearViewportStore(context) }
    var viewportRestored by remember { mutableStateOf(false) }

    // The activated header stays the anchor (COLLAPSIBLE-GROUP 1.2 section 4 rule 2): after its group opens or
    // closes, the row that now holds it is brought to the middle of the list so it cannot drift out of view.
    LaunchedEffect(activatedKey, rowKeys) {
        val key = activatedKey ?: return@LaunchedEffect
        val index = findAnchorRow(rowKeys, key)
        if (index >= 0) {
            listState.scrollToItem(index + LEADING_ITEMS)
        }
        activatedKey = null
    }

    // Rule 7: the viewport comes back as an anchor plus an offset once the report is on screen, and a missing
    // anchor restores nothing. Restoring is not an edit and writes nothing.
    LaunchedEffect(rowKeys, uiState.loading) {
        if (viewportRestored || uiState.loading || rowKeys.isEmpty()) return@LaunchedEffect
        viewportRestored = true
        val anchor = viewportStore.load(SYSTEM_INFO_SCREEN_KEY) ?: return@LaunchedEffect
        val index = findAnchorRow(rowKeys, anchor.key)
        if (index >= 0) {
            listState.scrollToItem(index + LEADING_ITEMS, anchor.offset)
        }
    }

    // The anchor is the row at the center of the list once scrolling settles.
    LaunchedEffect(listState, rowKeys) {
        snapshotFlow { listState.isScrollInProgress }
            .filter { settled -> !settled }
            .collect {
                val key = rowKeys.getOrNull(listState.centerItemIndex - LEADING_ITEMS)?.firstOrNull()
                if (key != null) {
                    viewportStore.save(SYSTEM_INFO_SCREEN_KEY, WearViewportAnchor(key, listState.centerItemScrollOffset))
                }
            }
    }

    WearScreenScaffold(
        contentPadding = PaddingValues(0.dp),
        scrollState = listState,
        positionIndicator = { PositionIndicator(listState) }
    ) {
        WearListColumn(
            modifier = Modifier.fillMaxSize(),
            state = listState,
            verticalArrangement = Arrangement.spacedBy(4.dp)
        ) {
            item {
                Text(
                    text = stringResource(R.string.system_info_title),
                    style = MaterialTheme.typography.title2,
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = TITLE_HORIZONTAL_INSET)
                        .padding(bottom = TITLE_BOTTOM_PADDING),
                    textAlign = TextAlign.Center,
                    onTextLayout = { layout ->
                        Timber.d("S0043: wear system info title lines=%d", layout.lineCount)
                    }
                )
            }
            if (uiState.loading) {
                item {
                    Column(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        CircularProgressIndicator(
                            modifier = Modifier.size(24.dp),
                            strokeWidth = 2.dp
                        )
                        Text(
                            text = stringResource(R.string.system_info_loading),
                            style = MaterialTheme.typography.caption1,
                            modifier = Modifier.padding(top = ROW_VERTICAL_PADDING),
                            textAlign = TextAlign.Center
                        )
                    }
                }
            } else {
                item {
                    ActionButtons(
                        refreshEnabled = !uiState.refreshing,
                        onRefresh = viewModel::refresh,
                        sendEnabled = !uiState.sending && uiState.sections.isNotEmpty(),
                        sending = uiState.sending,
                        outcomeRes = uiState.sendOutcomeRes,
                        onSend = viewModel::sendToPhone
                    )
                }
            }
            itemsIndexed(rows) { rowIndex, row ->
                WearSettingsRow(row = row, rowIndex = rowIndex)
            }
            if (interfaceScale != null) {
                item {
                    InterfaceScaleEntry(interfaceScale)
                }
            }
            item {
                WearHelpEntry()
            }
        }
    }
}

/**
 * The interface size entry (S0023, exception E1): a button at the end of the report that moves the whole app to the
 * next step of the one interface scale, 100, 115, 130, 150 percent and back to 100 (UI-SIZING 1.2 section 2). The label
 * carries the current step, so the state is in the visible and the spoken name. It sits after the report rows, like the
 * Help row, so their viewport keys keep their positions.
 */
@Composable
private fun InterfaceScaleEntry(store: WearInterfaceScaleStore) {
    Column(modifier = Modifier.fillMaxWidth(), horizontalAlignment = Alignment.CenterHorizontally) {
        WearActionButton(
            label = stringResource(R.string.system_info_interface_scale, store.percent),
            icon = null,
            enabled = true,
            onClick = store::cycle
        )
    }
}

/**
 * The watch's own help entry: a row at the end of the list that opens a short text.
 *
 * S0024 deliberate difference from upstream: CONTEXT-HELP 0.4 item L (reading A) gives a Wear OS screen no button and
 * no key, and a watch app with no companion carries its own entry from a row at the end of its list. The app declares
 * `com.google.android.wearable.standalone`, so the row stands even with no phone; the full help is the phone's
 * `watch-system-info` page, also published on the site. The row is drawn as the group headers are, a disclosure with
 * the same state description, and it sits after the report rows so their viewport keys keep their positions.
 */
@Composable
private fun WearHelpEntry() {
    var open by remember { mutableStateOf(false) }
    Column(modifier = Modifier.fillMaxWidth(), horizontalAlignment = Alignment.CenterHorizontally) {
        SectionDisclosure(
            titleRes = R.string.system_info_help_title,
            hiddenCount = null,
            open = open,
            onToggle = {
                open = !open
                Timber.d("S0024: watch help row toggled, open=%b", open)
            },
            modifier = Modifier.fillMaxWidth()
        )
        if (open) {
            Text(
                text = stringResource(R.string.system_info_help_text),
                style = MaterialTheme.typography.caption2,
                color = MaterialTheme.colors.onSurfaceVariant,
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = ROW_VERTICAL_PADDING),
                textAlign = TextAlign.Center
            )
        }
    }
}

/**
 * The two screen actions in one content-sized flow (S0023, exception E2): they share a row when the screen is wide
 * enough for both captions and wrap to separate rows when it is not or when the text is enlarged.
 */
@OptIn(ExperimentalLayoutApi::class)
@Composable
private fun ActionButtons(
    refreshEnabled: Boolean,
    onRefresh: () -> Unit,
    sendEnabled: Boolean,
    sending: Boolean,
    outcomeRes: Int?,
    onSend: () -> Unit
) {
    Column(modifier = Modifier.fillMaxWidth(), horizontalAlignment = Alignment.CenterHorizontally) {
        FlowRow(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(CHIP_GAP, Alignment.CenterHorizontally),
            verticalArrangement = Arrangement.spacedBy(CHIP_GAP)
        ) {
            WearActionButton(
                label = stringResource(R.string.system_info_refresh),
                icon = Icons.Default.Refresh,
                enabled = refreshEnabled,
                onClick = onRefresh
            )
            WearActionButton(
                label = stringResource(
                    if (sending) R.string.system_info_send_sending else R.string.system_info_send_to_phone
                ),
                icon = Icons.AutoMirrored.Filled.Send,
                enabled = sendEnabled,
                onClick = onSend
            )
        }
        if (outcomeRes != null && !sending) {
            Text(
                text = stringResource(outcomeRes),
                style = MaterialTheme.typography.caption3,
                color = MaterialTheme.colors.onSurfaceVariant,
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(top = ROW_VERTICAL_PADDING),
                textAlign = TextAlign.Center
            )
        }
    }
}

/** The stable identity of a group header: the group's resource entry name, never its position. */
private fun sectionKey(entryName: (Int) -> String, section: WearSystemInfoSection) =
    "section:${entryName(section.titleRes)}"

/**
 * The report as list items. Every item that is worth returning to carries its stable keys, and [onActivated]
 * receives the key of the header a user activated, so the screen can keep that header in view after the group
 * opens or closes and can remember the viewport as an anchor plus an offset.
 */
private fun reportItems(
    sections: List<WearSystemInfoSection>,
    expansion: WearSectionExpansionStore,
    entryName: (Int) -> String,
    onActivated: (String) -> Unit
): List<WearSettingsItem> = buildList {
    val collapsed = mutableListOf<WearSystemInfoSection>()

    fun toggle(section: WearSystemInfoSection) {
        expansion.toggle(SYSTEM_INFO_SCREEN_KEY, section.titleRes)
        onActivated(sectionKey(entryName, section))
    }

    fun divide() {
        if (isNotEmpty()) {
            add(WearSettingsItem(fullWidth = true) { WearReportDivider() })
        }
    }

    fun flushCollapsed() {
        if (collapsed.isEmpty()) {
            return
        }
        val cloud = collapsed.toList()
        collapsed.clear()
        divide()
        add(
            WearSettingsItem(fullWidth = true, keys = cloud.map { sectionKey(entryName, it) }) {
                SectionChipCloud(
                    sections = cloud,
                    onToggle = { titleRes -> cloud.firstOrNull { it.titleRes == titleRes }?.let { toggle(it) } }
                )
            }
        )
    }

    sections.forEach { section ->
        if (!expansion.isExpanded(SYSTEM_INFO_SCREEN_KEY, section.titleRes)) {
            collapsed += section
            return@forEach
        }
        flushCollapsed()
        divide()
        add(
            WearSettingsItem(fullWidth = true, keys = listOf(sectionKey(entryName, section))) {
                SectionTitle(
                    titleRes = section.titleRes,
                    hiddenCount = null,
                    open = true,
                    onToggle = { toggle(section) }
                )
            }
        )
        addAll(sectionBody(section, expansion, entryName))
    }
    flushCollapsed()
}

private fun sectionBody(
    section: WearSystemInfoSection,
    expansion: WearSectionExpansionStore,
    entryName: (Int) -> String
): List<WearSettingsItem> = buildList {
    val sectionEntry = entryName(section.titleRes)
    val emptyReasonRes = section.emptyReasonRes
    if (section.fields.isEmpty() && emptyReasonRes != null) {
        add(WearSettingsItem(fullWidth = true, keys = listOf("empty:$sectionEntry")) { SectionEmptyReason(emptyReasonRes) })
    }
    section.fields.forEach { field ->
        val fieldKeys = listOf("field:$sectionEntry/${entryName(field.labelRes)}")
        val enumerated = field.value as? WearSystemInfoValue.Enumerated
        if (enumerated == null) {
            add(
                WearSettingsItem(fullWidth = false, keys = fieldKeys) { narrow ->
                    SystemInfoRow(field = field, narrow = narrow)
                }
            )
        } else {
            add(
                WearSettingsItem(fullWidth = true, keys = fieldKeys) { narrow ->
                    EnumeratedRow(
                        field = field,
                        entries = enumerated.entries,
                        open = expansion.isExpanded(SYSTEM_INFO_FIELDS_KEY, field.labelRes),
                        onToggle = { expansion.toggle(SYSTEM_INFO_FIELDS_KEY, field.labelRes) },
                        narrow = narrow
                    )
                }
            )
        }
    }
}

@Composable
private fun EnumeratedRow(
    field: WearSystemInfoField,
    entries: List<String>,
    open: Boolean,
    onToggle: () -> Unit,
    narrow: Boolean = false
) {
    val hint = stringResource(
        if (open) R.string.system_info_collapse_hint else R.string.system_info_expand_hint
    )
    Column(modifier = Modifier.fillMaxWidth()) {
        WearInformationRow(
            labelRes = field.labelRes,
            value = entries.size.toString(),
            accessibilitySuffix = hint,
            accessibilityState = stringResource(
                if (open) R.string.sysinfo_group_expanded else R.string.sysinfo_group_collapsed
            ),
            accentColor = accentColor(field),
            narrow = narrow,
            gestures = WearInformationRowGestures(
                onClick = onToggle,
                copyText = entries.joinToString(separator = "\n")
            )
        )
        if (open) {
            entries.forEach { entry ->
                Text(
                    text = entry,
                    style = MaterialTheme.typography.caption3,
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(top = ROW_VERTICAL_PADDING),
                    textAlign = TextAlign.Center
                )
            }
        }
    }
}

@Composable
private fun SectionEmptyReason(@StringRes reasonRes: Int) {
    Text(
        text = stringResource(reasonRes),
        style = MaterialTheme.typography.caption2,
        color = MaterialTheme.colors.onSurfaceVariant,
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = ROW_VERTICAL_PADDING),
        textAlign = TextAlign.Center
    )
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
private fun SectionChipCloud(sections: List<WearSystemInfoSection>, onToggle: (Int) -> Unit) {
    FlowRow(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(CHIP_GAP, Alignment.CenterHorizontally),
        verticalArrangement = Arrangement.spacedBy(CHIP_GAP)
    ) {
        sections.forEach { section ->
            SectionChip(
                titleRes = section.titleRes,
                hiddenCount = section.fields.size,
                onToggle = { onToggle(section.titleRes) }
            )
        }
    }
}

@Composable
private fun SectionChip(titleRes: Int, hiddenCount: Int, onToggle: () -> Unit) {
    SectionDisclosure(titleRes, hiddenCount, open = false, onToggle = onToggle)
}

@Composable
private fun SectionTitle(titleRes: Int, hiddenCount: Int?, open: Boolean, onToggle: () -> Unit) {
    SectionDisclosure(titleRes, hiddenCount, open, onToggle, Modifier.fillMaxWidth())
}

/**
 * A section's disclosure header: marker, group glyph, title.
 *
 * S0022 deliberate difference from upstream: a header shows the glyph of its meaning before its title
 * (`WearSectionIcons`, `docs/design/tokens.json`); the marker and the glyph take the accent role and the title takes the
 * on-surface role, the header treatment the phone's `CollapsibleSectionHeader` follows. S0035: the headers are one
 * sibling set, so every one of them, the Help row included, has a glyph (ICON-RENDER 0.25 section 25 rule 1); the
 * `null` branch below is only the guard for a title string the table does not know, which `tools/design/check-tokens.ps1`
 * reports.
 */
@Composable
private fun SectionDisclosure(
    titleRes: Int,
    hiddenCount: Int?,
    open: Boolean,
    onToggle: () -> Unit,
    modifier: Modifier = Modifier
) {
    val title = stringResource(titleRes)
    val state = stringResource(if (open) R.string.sysinfo_group_expanded else R.string.sysinfo_group_collapsed)
    val minimumTarget = dimensionResource(R.dimen.system_info_touch_target_min)
    val markerColor = MaterialTheme.colors.primary
    val glyphRes = WearSectionIcons.iconFor(titleRes)
    val rtl = LocalLayoutDirection.current == LayoutDirection.Rtl
    Row(
        modifier = Modifier
            .then(modifier)
            .clip(RoundedCornerShape(CHIP_CORNER))
            .background(MaterialTheme.colors.surface)
            .clickable(role = Role.Button, onClick = onToggle)
            .sizeIn(minWidth = minimumTarget, minHeight = minimumTarget)
            .padding(horizontal = CHIP_HORIZONTAL_PADDING, vertical = CHIP_VERTICAL_PADDING)
            .semantics { stateDescription = state },
        verticalAlignment = Alignment.CenterVertically
    ) {
        Canvas(modifier = Modifier.size(DISCLOSURE_MARKER_SIZE)) {
            val triangle = Path().apply {
                if (open) {
                    moveTo(0f, size.height * 0.25f)
                    lineTo(size.width, size.height * 0.25f)
                    lineTo(size.width / 2f, size.height * 0.75f)
                } else if (rtl) {
                    moveTo(size.width * 0.75f, 0f)
                    lineTo(size.width * 0.25f, size.height / 2f)
                    lineTo(size.width * 0.75f, size.height)
                } else {
                    moveTo(size.width * 0.25f, 0f)
                    lineTo(size.width * 0.75f, size.height / 2f)
                    lineTo(size.width * 0.25f, size.height)
                }
                close()
            }
            drawPath(triangle, markerColor)
        }
        Spacer(Modifier.width(DISCLOSURE_MARKER_GAP))
        if (glyphRes != null) {
            Icon(
                painter = painterResource(glyphRes),
                contentDescription = null,
                modifier = Modifier.size(SECTION_GLYPH_SIZE),
                tint = markerColor
            )
            Spacer(Modifier.width(SECTION_GLYPH_GAP))
        }
        Text(
            text = if (hiddenCount == null) title else "$title ($hiddenCount)",
            style = if (open) {
                MaterialTheme.typography.title3.copy(fontWeight = FontWeight.Bold)
            } else {
                MaterialTheme.typography.caption2
            },
            color = MaterialTheme.colors.onSurface
        )
    }
}

@Composable
private fun valueOf(field: WearSystemInfoField): String = when (val fieldValue = field.value) {
    is WearSystemInfoValue.Text -> fieldValue.text
    is WearSystemInfoValue.Label -> stringResource(fieldValue.res)
    is WearSystemInfoValue.Enumerated -> fieldValue.entries.size.toString()
}

@Composable
private fun accentColor(field: WearSystemInfoField): Color? =
    if (field.accentHint) MaterialTheme.colors.error else null

@Composable
private fun SystemInfoRow(field: WearSystemInfoField, narrow: Boolean = false) {
    val isEven = LocalWearTileEven.current ?: true
    val backgroundColor = if (isEven) {
        MaterialTheme.colors.surface
    } else {
        MaterialTheme.colors.onSurface.copy(alpha = 0.08f)
    }
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(8.dp))
            .background(backgroundColor)
            .padding(horizontal = 6.dp, vertical = 4.dp)
    ) {
        WearInformationRow(
            labelRes = field.labelRes,
            value = valueOf(field),
            accentColor = accentColor(field),
            narrow = narrow
        )
    }
}
