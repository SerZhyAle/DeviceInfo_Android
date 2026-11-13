package com.sza.deviceinfo.data.wear

import android.content.Context
import com.google.android.gms.wearable.Wearable
import com.sza.deviceinfo.domain.repository.WearableDataLayerRepository
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.tasks.await
import timber.log.Timber
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class WearableDataLayerRepositoryImpl @Inject constructor(
    @ApplicationContext private val context: Context
) : WearableDataLayerRepository {

    override suspend fun sendMessage(nodeId: String, path: String, data: ByteArray) {
        Wearable.getMessageClient(context).sendMessage(nodeId, path, data).await()
        Timber.d("sendMessage: %s -> %s", path, nodeId)
    }
}
