package com.sza.deviceinfo.wear.domain.systeminfo

import com.sza.deviceinfo.wear.domain.model.WearSystemInfoSection

class FakeWearSystemInfoContributor(
    override val order: Int,
    private val answer: List<WearSystemInfoSection> = emptyList(),
    private val failure: Throwable? = null
) : WearSystemInfoContributor {

    override suspend fun sections(): List<WearSystemInfoSection> {
        failure?.let { thrown -> throw thrown }
        return answer
    }
}
