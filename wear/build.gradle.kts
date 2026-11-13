import com.sza.deviceinfo.buildlogic.PackageFamily
import com.sza.deviceinfo.buildlogic.ReleaseSigning
import com.sza.deviceinfo.buildlogic.VersionStamp
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.compose)
    alias(libs.plugins.ksp)
    alias(libs.plugins.hilt)
}

// PACKAGE-VERSIONING, Android profile: the pair a release orchestrator pins wins (rule 5), an invocation that
// builds a release variant stamps itself from the one clock reading of the build (rule 6), and a device-debug
// build carries the checked-in sentinel (rule 7). The watch app owns band 6..9 of the last code digit, so it never
// repeats a code of the phone app that shares its application id. The derivation is in buildSrc.
val stamp = VersionStamp.select(
    family = PackageFamily.WEAR,
    taskNames = gradle.startParameter.taskNames,
    property = { providers.gradleProperty(it).orNull },
    instant = rootProject.extra[VersionStamp.BUILD_INSTANT] as String,
)

// The upload key of the release variant (Play App Signing). Read only when a release variant is requested, so a
// debug build never depends on key material.
val releaseRequested = gradle.startParameter.taskNames.any { VersionStamp.isReleaseTask(it) }
val releaseSigning: ReleaseSigning.Config? = if (releaseRequested) {
    ReleaseSigning.load(
        ReleaseSigning.directory(
            providers.gradleProperty(ReleaseSigning.DIRECTORY_PROPERTY).orNull,
            providers.environmentVariable(ReleaseSigning.DIRECTORY_ENV).orNull,
        ),
    )
} else {
    null
}

android {
    // The code namespace keeps the .wear segment; only the install identity has to match the phone.
    namespace = "com.sza.deviceinfo.wear"
    compileSdk = libs.versions.compile.sdk.get().toInt()

    defaultConfig {
        // FROZEN with the first shipped package (owner decision of S0008). MUST stay identical to the phone's
        // applicationId: the Data Layer routes by (package name, signing certificate) and drops anything whose
        // package name differs across the two devices, below the app - a mismatch is invisible to both sides.
        // Declared once in gradle.properties; no applicationIdSuffix on any build type.
        applicationId = providers.gradleProperty("deviceinfo.applicationId").get()
        minSdk = libs.versions.min.sdk.wear.get().toInt()
        targetSdk = libs.versions.target.sdk.get().toInt()
        versionCode = stamp.code
        versionName = stamp.name
    }

    signingConfigs {
        releaseSigning?.let { key ->
            create("release") {
                storeFile = key.storeFile
                storePassword = key.storePassword
                keyAlias = key.keyAlias
                keyPassword = key.keyPassword
            }
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            releaseSigning?.let { signingConfig = signingConfigs.getByName("release") }
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    buildFeatures {
        compose = true
        buildConfig = true
    }
}

kotlin {
    compilerOptions {
        jvmTarget = JvmTarget.JVM_17
        freeCompilerArgs.add("-Xannotation-default-target=param-property")
    }
}

dependencies {
    implementation(libs.androidx.activity.compose)
    implementation(platform(libs.androidx.compose.bom))
    implementation(libs.androidx.compose.ui)
    implementation(libs.androidx.wear.compose.foundation)
    implementation(libs.androidx.wear.compose.material)
    implementation(libs.androidx.hilt.navigation.compose)

    implementation(libs.timber)
    implementation(libs.gson)
    implementation(libs.google.gms.play.services.wearable)

    implementation(libs.dagger.hilt.android)
    ksp(libs.dagger.hilt.android.compiler)

    testImplementation(libs.junit)
    testImplementation(libs.kotlinx.coroutines.test)
}

// A release variant is never packaged without the upload key: an unsigned bundle is useless to Play and the
// refusal says what to configure instead of failing later in the signing task.
gradle.taskGraph.whenReady {
    val packaging = allTasks.any { it.path.startsWith(":wear:") && ReleaseSigning.isPackagingTask(it.name) }
    if (packaging && releaseSigning == null) {
        throw GradleException(ReleaseSigning.missingKeyMessage("wear"))
    }
}
