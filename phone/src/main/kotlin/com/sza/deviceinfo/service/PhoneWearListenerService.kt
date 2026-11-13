package com.sza.deviceinfo.service

import com.google.android.gms.wearable.MessageEvent
import com.google.android.gms.wearable.WearableListenerService
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import timber.log.Timber
import javax.inject.Inject

@AndroidEntryPoint
class PhoneWearListenerService : WearableListenerService() {

    private val serviceScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)

    @Inject
    lateinit var wearSystemInfoReportReceiver: WearSystemInfoReportReceiver

    override fun onDestroy() {
        super.onDestroy()
        serviceScope.cancel()
    }

    override fun onMessageReceived(event: MessageEvent) {
        Timber.d("Wear message received: %s from %s", event.path, event.sourceNodeId)
        when (event.path) {
            WearDataLayerPaths.SYSTEM_INFO_REPORT -> {
                handleSystemInfoReport(event.sourceNodeId, event.data)
            }
        }
    }

    private fun handleSystemInfoReport(nodeId: String, data: ByteArray) {
        serviceScope.launch {
            wearSystemInfoReportReceiver.handle(nodeId, data)
        }
    }
}
