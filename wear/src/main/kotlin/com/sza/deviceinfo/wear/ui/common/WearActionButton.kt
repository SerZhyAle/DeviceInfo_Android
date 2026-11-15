package com.sza.deviceinfo.wear.ui.common

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.sizeIn
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.dimensionResource
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.wear.compose.material.Icon
import androidx.wear.compose.material.MaterialTheme
import androidx.wear.compose.material.Text
import com.sza.deviceinfo.wear.R
import timber.log.Timber

private val ACTION_CORNER = 4.dp
private val ACTION_HORIZONTAL_PADDING = 8.dp
private val ACTION_VERTICAL_PADDING = 6.dp
private val ACTION_ICON_SIZE = 16.dp
private val ACTION_ICON_GAP = 6.dp
private const val DISABLED_ALPHA = 0.38f

/**
 * A product-drawn action for the watch (S0023, exception E2): a rectangular control with modest corners, a
 * 48 dp minimum target on both axes, a width that follows its content and a caption that wraps instead of being
 * clipped, so a long translation or enlarged text grows the control rather than cutting its name.
 *
 * It replaces the toolkit's `CompactChip`, which fixes a 48 dp height for one line of text. Deliberate difference
 * from upstream, recorded in `docs/UI_CONFORMANCE.md`; the colors are the surface and on-surface roles the
 * secondary chip used, so the screen keeps one palette (`DeviceInfoWearTheme`). A button with no [icon] is a plain
 * text button (the interface size entry, S0023 exception E1).
 */
@Composable
fun WearActionButton(
    label: String,
    icon: ImageVector?,
    enabled: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val minimumTarget = dimensionResource(R.dimen.system_info_touch_target_min)
    Row(
        modifier = modifier
            .alpha(if (enabled) 1f else DISABLED_ALPHA)
            .clip(RoundedCornerShape(ACTION_CORNER))
            .background(MaterialTheme.colors.surface)
            .clickable(enabled = enabled, role = Role.Button) {
                Timber.d("S0023: wear action button tapped, label=%s", label)
                onClick()
            }
            .sizeIn(minWidth = minimumTarget, minHeight = minimumTarget)
            .padding(horizontal = ACTION_HORIZONTAL_PADDING, vertical = ACTION_VERTICAL_PADDING),
        verticalAlignment = Alignment.CenterVertically
    ) {
        if (icon != null) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                modifier = Modifier.size(ACTION_ICON_SIZE),
                tint = MaterialTheme.colors.primary
            )
            Spacer(Modifier.width(ACTION_ICON_GAP))
        }
        Text(
            text = label,
            style = MaterialTheme.typography.button,
            color = MaterialTheme.colors.onSurface,
            textAlign = TextAlign.Start,
            modifier = Modifier.weight(1f, fill = false)
        )
    }
}
