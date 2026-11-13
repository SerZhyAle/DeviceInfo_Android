package com.sza.deviceinfo.wear.domain.usecase

import com.sza.deviceinfo.wear.domain.model.WearSystemInfoSection
import com.sza.deviceinfo.wear.domain.repository.WearSystemInfoReportOutcome
import com.sza.deviceinfo.wear.domain.repository.WearSystemInfoReportSender
import javax.inject.Inject

/**
 * Sends the report the screen is already showing to the paired phone.
 *
 * Takes the gathered sections rather than gathering its own: the screen holds a report the user has
 * read and may have refreshed, and a second gather would send a different one from the one on screen.
 */
class SendWearSystemInfoReportUseCase @Inject constructor(
    private val sender: WearSystemInfoReportSender
) {

    suspend operator fun invoke(sections: List<WearSystemInfoSection>): WearSystemInfoReportOutcome =
        sender.send(sections)
}
