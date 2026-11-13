package com.sza.deviceinfo.diagnostics

import android.content.Context
import com.sza.deviceinfo.core.systeminfo.ExtendedDiagnosticsContributor
import com.sza.deviceinfo.core.systeminfo.ExtendedDiagnosticsSection
import dagger.hilt.android.qualifiers.ApplicationContext
import timber.log.Timber
import javax.inject.Inject
import javax.inject.Singleton

/**
 * The [ExtendedDiagnosticsContributor] of the restricted build (S0009, owner decision: all seven sections in a
 * restricted build, the public build carries none). Lives in `src/restricted`, so it is never compiled into the
 * `store` flavor, which injects the empty set declared by `ExtendedDiagnosticsModule`. Produces the seven
 * sections through [RestrictedDiagnosticsCollectors], whose fields each degrade to "unknown" / "n/a".
 *
 * Differs from the upstream `NoLegalExtendedDiagnosticsContributor` in one place: each section builder is
 * guarded here, so a builder that fails as a whole (an unreadable title, say) drops that one section and logs,
 * instead of dropping every extended section through the guard of the use case.
 */
@Singleton
class RestrictedExtendedDiagnosticsContributor @Inject constructor(
    @ApplicationContext private val context: Context,
) : ExtendedDiagnosticsContributor {

    private val collectors = RestrictedDiagnosticsCollectors(context)

    override fun sections(): List<ExtendedDiagnosticsSection> = listOfNotNull(
        guarded("OS and security") { collectors.osSecurity() },
        guarded("permissions") { collectors.permissions() },
        guarded("installer and signature") { collectors.installerSignature() },
        guarded("runtimes") { collectors.runtimes() },
        guarded("mounts") { collectors.mounts() },
        guarded("network") { collectors.network() },
        guarded("process resources") { collectors.processResources() },
    )

    @Suppress("TooGenericExceptionCaught")
    private inline fun guarded(name: String, build: () -> ExtendedDiagnosticsSection): ExtendedDiagnosticsSection? =
        try {
            build()
        } catch (e: Exception) {
            Timber.w(e, "Restricted diagnostics: the $name section failed as a whole")
            null
        }
}
