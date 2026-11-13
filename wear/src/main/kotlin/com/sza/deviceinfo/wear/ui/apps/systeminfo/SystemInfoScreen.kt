package com.sza.deviceinfo.wear.ui.apps.systeminfo

import androidx.annotation.StringRes
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.Send
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.wear.compose.foundation.lazy.ScalingLazyListState
import androidx.wear.compose.foundation.lazy.itemsIndexed
import androidx.wear.compose.material.ChipDefaults
import androidx.wear.compose.material.CircularProgressIndicator
import androidx.wear.compose.material.CompactChip
import androidx.wear.compose.material.Icon
import androidx.wear.compose.material.MaterialTheme
import androidx.wear.compose.material.PositionIndicator
import androidx.wear.compose.material.Text
import com.sza.deviceinfo.wear.R
import com.sza.deviceinfo.wear.domain.model.WearSystemInfoField
import com.sza.deviceinfo.wear.domain.model.WearSystemInfoSection
import com.sza.deviceinfo.wear.domain.model.WearSystemInfoValue
import com.sza.deviceinfo.wear.ui.common.LocalWearSectionExpansion
import com.sza.deviceinfo.wear.ui.common.LocalWearTileEven
import com.sza.deviceinfo.wear.ui.common.WearInformationRow
import com.sza.deviceinfo.wear.ui.common.WearInformationRowGestures
import com.sza.deviceinfo.wear.ui.common.WearListColumn
import com.sza.deviceinfo.wear.ui.common.WearReportDivider
import com.sza.deviceinfo.wear.ui.common.WearScreenScaffold
import com.sza.deviceinfo.wear.ui.common.WearSectionExpansionStore
import com.sza.deviceinfo.wear.ui.common.WearSettingsItem
import com.sza.deviceinfo.wear.ui.common.WearSettingsRow
import com.sza.deviceinfo.wear.ui.common.packSettingsRows
import com.sza.deviceinfo.wear.ui.common.rememberWearListState

private const val SYSTEM_INFO_SCREEN_KEY = "apps/systeminfo"
private const val SYSTEM_INFO_FIELDS_KEY = "apps/systeminfo/fields"

private const val TWO_COLUMN_MIN_SCREEN_WIDTH_DP = 225

private val TITLE_BOTTOM_PADDING = 8.dp
private val SECTION_TOP_PADDING = 14.dp
private val SECTION_TITLE_BOTTOM_PADDING = 10.dp
private val ROW_VERTICAL_PADDING = 4.dp
private val CHIP_GAP = 4.dp
private val CHIP_CORNER = 4.dp
private val CHIP_HORIZONTAL_PADDING = 8.dp
private val CHIP_VERTICAL_PADDING = 6.dp
private val ACTION_ICON_SIZE = 16.dp

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
    val expansion = LocalWearSectionExpansion.current ?: remember { WearSectionExpansionStore() }
    val configuration = LocalConfiguration.current
    val columns = if (configuration.screenWidthDp >= TWO_COLUMN_MIN_SCREEN_WIDTH_DP) 2 else 1
    val rows = packSettingsRows(reportItems(uiState.sections, expansion), columns)

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
                        .padding(bottom = TITLE_BOTTOM_PADDING),
                    textAlign = TextAlign.Center
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
                    RefreshChip(enabled = !uiState.refreshing, onClick = viewModel::refresh)
                }
                item {
                    SendToPhoneChip(
                        enabled = !uiState.sending && uiState.sections.isNotEmpty(),
                        outcomeRes = uiState.sendOutcomeRes,
                        sending = uiState.sending,
                        onClick = viewModel::sendToPhone
                    )
                }
            }
            itemsIndexed(rows) { rowIndex, row ->
                WearSettingsRow(row = row, rowIndex = rowIndex)
            }
        }
    }
}

@Composable
private fun RefreshChip(enabled: Boolean, onClick: () -> Unit) {
    CompactChip(
        onClick = onClick,
        enabled = enabled,
        label = { Text(stringResource(R.string.system_info_refresh)) },
        icon = {
            Icon(
                imageVector = Icons.Default.Refresh,
                contentDescription = null,
                modifier = Modifier.size(ACTION_ICON_SIZE)
            )
        },
        modifier = Modifier.fillMaxWidth(),
        colors = ChipDefaults.secondaryChipColors()
    )
}

@Composable
private fun SendToPhoneChip(
    enabled: Boolean,
    outcomeRes: Int?,
    sending: Boolean,
    onClick: () -> Unit
) {
    Column(modifier = Modifier.fillMaxWidth(), horizontalAlignment = Alignment.CenterHorizontally) {
        CompactChip(
            onClick = onClick,
            enabled = enabled,
            label = {
                Text(
                    stringResource(
                        if (sending) R.string.system_info_send_sending else R.string.system_info_send_to_phone
                    )
                )
            },
            icon = {
                Icon(
                    imageVector = Icons.AutoMirrored.Filled.Send,
                    contentDescription = null,
                    modifier = Modifier.size(ACTION_ICON_SIZE)
                )
            },
            modifier = Modifier.fillMaxWidth(),
            colors = ChipDefaults.secondaryChipColors()
        )
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

private fun reportItems(
    sections: List<WearSystemInfoSection>,
    expansion: WearSectionExpansionStore
): List<WearSettingsItem> = buildList {
    val collapsed = mutableListOf<WearSystemInfoSection>()

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
            WearSettingsItem(fullWidth = true) {
                SectionChipCloud(
                    sections = cloud,
                    onToggle = { titleRes -> expansion.toggle(SYSTEM_INFO_SCREEN_KEY, titleRes) }
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
            WearSettingsItem(fullWidth = true) {
                SectionTitle(
                    titleRes = section.titleRes,
                    hiddenCount = null,
                    open = true,
                    onToggle = { expansion.toggle(SYSTEM_INFO_SCREEN_KEY, section.titleRes) }
                )
            }
        )
        addAll(sectionBody(section, expansion))
    }
    flushCollapsed()
}

private fun sectionBody(
    section: WearSystemInfoSection,
    expansion: WearSectionExpansionStore
): List<WearSettingsItem> = buildList {
    val emptyReasonRes = section.emptyReasonRes
    if (section.fields.isEmpty() && emptyReasonRes != null) {
        add(WearSettingsItem(fullWidth = true) { SectionEmptyReason(emptyReasonRes) })
    }
    section.fields.forEach { field ->
        val enumerated = field.value as? WearSystemInfoValue.Enumerated
        if (enumerated == null) {
            add(WearSettingsItem(fullWidth = false) { narrow -> SystemInfoRow(field = field, narrow = narrow) })
        } else {
            add(
                WearSettingsItem(fullWidth = true) { narrow ->
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
    val title = stringResource(titleRes)
    val hint = stringResource(R.string.system_info_expand_hint)
    Box(
        modifier = Modifier
            .clip(RoundedCornerShape(CHIP_CORNER))
            .background(MaterialTheme.colors.surface)
            .clickable(onClick = onToggle)
            .padding(horizontal = CHIP_HORIZONTAL_PADDING, vertical = CHIP_VERTICAL_PADDING)
            .semantics { contentDescription = "$title. $hint" }
    ) {
        Text(
            text = "$title ($hiddenCount)",
            style = MaterialTheme.typography.caption2,
            color = MaterialTheme.colors.primary,
            maxLines = 1,
            textAlign = TextAlign.Center
        )
    }
}

@Composable
private fun SectionTitle(titleRes: Int, hiddenCount: Int?, open: Boolean, onToggle: () -> Unit) {
    val title = stringResource(titleRes)
    val hint = stringResource(
        if (open) R.string.system_info_collapse_hint else R.string.system_info_expand_hint
    )
    Text(
        text = if (hiddenCount == null) title else "$title ($hiddenCount)",
        style = MaterialTheme.typography.title3,
        color = MaterialTheme.colors.primary,
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onToggle)
            .padding(top = SECTION_TOP_PADDING, bottom = SECTION_TITLE_BOTTOM_PADDING)
            .semantics { contentDescription = "$title. $hint" },
        textAlign = TextAlign.Center
    )
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
