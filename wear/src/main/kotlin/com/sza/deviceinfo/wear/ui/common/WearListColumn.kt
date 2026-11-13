package com.sza.deviceinfo.wear.ui.common

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.wear.compose.foundation.lazy.ScalingLazyColumn
import androidx.wear.compose.foundation.lazy.ScalingLazyListScope
import androidx.wear.compose.foundation.lazy.ScalingLazyListState
import androidx.wear.compose.foundation.lazy.rememberScalingLazyListState

@Composable
fun WearListColumn(
    modifier: Modifier = Modifier,
    state: ScalingLazyListState = rememberScalingLazyListState(),
    verticalArrangement: Arrangement.Vertical = Arrangement.spacedBy(4.dp),
    content: ScalingLazyListScope.() -> Unit
) {
    ScalingLazyColumn(
        modifier = modifier,
        state = state,
        verticalArrangement = verticalArrangement,
        content = content
    )
}

@Composable
fun rememberWearListState(
    initialCenterItemIndex: Int = 1,
    initialCenterItemScrollOffset: Int = 0,
    positionKey: String? = null
): ScalingLazyListState = rememberScalingLazyListState(
    initialCenterItemIndex = initialCenterItemIndex,
    initialCenterItemScrollOffset = initialCenterItemScrollOffset
)
