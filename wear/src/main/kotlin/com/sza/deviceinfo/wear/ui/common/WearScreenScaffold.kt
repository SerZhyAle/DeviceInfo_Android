package com.sza.deviceinfo.wear.ui.common

import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.wear.compose.foundation.ExperimentalWearFoundationApi
import androidx.wear.compose.foundation.HierarchicalFocusCoordinator
import androidx.wear.compose.foundation.lazy.ScalingLazyListState
import androidx.wear.compose.material.PositionIndicator
import androidx.wear.compose.material.Scaffold

@Composable
@OptIn(ExperimentalWearFoundationApi::class)
fun WearScreenScaffold(
    modifier: Modifier = Modifier,
    contentPadding: PaddingValues = PaddingValues(0.dp),
    scrollState: ScalingLazyListState? = null,
    positionIndicator: @Composable () -> Unit = {
        scrollState?.let { PositionIndicator(it) }
    },
    content: @Composable () -> Unit
) {
    HierarchicalFocusCoordinator(requiresFocus = { true }) {
        Scaffold(
            modifier = modifier.fillMaxSize(),
            positionIndicator = positionIndicator
        ) {
            content()
        }
    }
}
