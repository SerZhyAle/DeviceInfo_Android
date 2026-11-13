package com.sza.deviceinfo.domain.repository

/**
 * Repository interface for sending messages and data over the Wearable Data Layer to connected watches.
 */
interface WearableDataLayerRepository {

    /** Sends a message to a specific node over the Data Layer. */
    suspend fun sendMessage(nodeId: String, path: String, data: ByteArray)
}
