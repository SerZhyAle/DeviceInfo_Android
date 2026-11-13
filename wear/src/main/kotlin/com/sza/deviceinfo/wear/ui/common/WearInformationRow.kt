package com.sza.deviceinfo.wear.ui.common

import androidx.annotation.StringRes
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalClipboardManager
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.wear.compose.material.MaterialTheme
import androidx.wear.compose.material.Text

private val INFORMATION_ROW_VERTICAL_PADDING = 2.dp

/**
 * What one information row's two gestures do, when either differs from the default.
 */
data class WearInformationRowGestures(
    val onClick: (() -> Unit)? = null,
    val copyText: String? = null
)

/**
 * A compact caption-value pair for watch-sized information screens.
 */
@OptIn(ExperimentalFoundationApi::class)
@Composable
fun WearInformationRow(
    @StringRes labelRes: Int,
    value: String,
    modifier: Modifier = Modifier,
    accessibilitySuffix: String? = null,
    accentColor: Color? = null,
    narrow: Boolean = false,
    gestures: WearInformationRowGestures = WearInformationRowGestures()
) {
    val label = stringResource(labelRes)
    val pair = "$label: $value"
    val description = listOfNotNull(pair, accessibilitySuffix).joinToString(". ")
    val clipboard = LocalClipboardManager.current
    val haptic = LocalHapticFeedback.current

    val copy = {
        clipboard.setText(AnnotatedString(gestures.copyText ?: pair))
        haptic.performHapticFeedback(HapticFeedbackType.LongPress)
    }
    val interactionModifier = modifier.combinedClickable(
        onClick = gestures.onClick ?: copy,
        onLongClick = copy
    )

    val commonModifier = interactionModifier
        .fillMaxWidth()
        .padding(vertical = INFORMATION_ROW_VERTICAL_PADDING)
        .semantics(mergeDescendants = true) { contentDescription = description }

    if (narrow) {
        Column(
            modifier = commonModifier,
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = label,
                style = MaterialTheme.typography.caption2,
                color = MaterialTheme.colors.onSurfaceVariant,
                textAlign = TextAlign.Center
            )
            Text(
                text = value,
                style = MaterialTheme.typography.body2,
                color = accentColor ?: Color.Unspecified,
                textAlign = TextAlign.Center
            )
        }
    } else {
        Row(
            modifier = commonModifier,
            horizontalArrangement = Arrangement.spacedBy(INFORMATION_ROW_VERTICAL_PADDING)
        ) {
            Text(
                text = label,
                style = MaterialTheme.typography.caption2,
                color = MaterialTheme.colors.onSurfaceVariant,
                textAlign = TextAlign.End,
                modifier = Modifier
                    .weight(1f)
                    .alignByBaseline()
            )
            Text(
                text = value,
                style = MaterialTheme.typography.body2,
                color = accentColor ?: Color.Unspecified,
                textAlign = TextAlign.Start,
                modifier = Modifier
                    .weight(1f)
                    .alignByBaseline()
            )
        }
    }
}
