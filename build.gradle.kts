import com.sza.deviceinfo.buildlogic.VersionStamp
import java.time.LocalDateTime

// Plugins are put on the root classpath once, with their versions, and applied per module.
plugins {
    alias(libs.plugins.android.application) apply false
    alias(libs.plugins.kotlin.compose) apply false
    alias(libs.plugins.ksp) apply false
    alias(libs.plugins.hilt) apply false
}

// PACKAGE-VERSIONING rule 6: one clock reading for the whole invocation, taken here before either module is
// configured, so the phone app and the watch app built together cannot straddle a minute boundary.
extra[VersionStamp.BUILD_INSTANT] = VersionStamp.clockInstant(LocalDateTime.now())
