import com.sza.deviceinfo.buildlogic.PackageFamily
import com.sza.deviceinfo.buildlogic.ReleaseSigning
import com.sza.deviceinfo.buildlogic.VersionStamp
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.ksp)
    alias(libs.plugins.hilt)
}

// PACKAGE-VERSIONING, Android profile: the pair a release orchestrator pins wins (rule 5), an invocation that
// builds a release variant stamps itself from the one clock reading of the build (rule 6), and a device-debug
// build carries the checked-in sentinel (rule 7). The derivation and its fixed-instant vectors are in buildSrc.
val stamp = VersionStamp.select(
    family = PackageFamily.PHONE,
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
    // The code namespace is not an install identity; only applicationId below is shared with the watch app.
    namespace = "com.sza.deviceinfo"
    compileSdk = libs.versions.compile.sdk.get().toInt()

    defaultConfig {
        // FROZEN since the Play Console app was created with it (2026-11-13). MUST stay identical to the watch app's
        // applicationId: the Data Layer drops messages whose package name differs across the two devices.
        // Declared once in gradle.properties; no applicationIdSuffix on any build type.
        applicationId = providers.gradleProperty("deviceinfo.applicationId").get()
        minSdk = libs.versions.min.sdk.phone.get().toInt()
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

    // S0009 (owner decision, option 1): the seven extended diagnostics sections exist only in the `restricted`
    // flavor (src/restricted); `store` is the public build and the only one that is ever released. Neither flavor
    // sets an applicationIdSuffix or a version suffix: the id is one for phone and watch (see defaultConfig).
    flavorDimensions += "distribution"
    productFlavors {
        create("store") { dimension = "distribution" }
        create("restricted") { dimension = "distribution" }
    }

    buildFeatures {
        // The System info report prints the app's own version name and code.
        buildConfig = true
        viewBinding = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    testOptions {
        unitTests {
            // Robolectric reads the real string resources: the report tests assert localized section headers.
            isIncludeAndroidResources = true
        }
    }
}

androidComponents {
    // A restricted release variant is never created: S0008 decided Google Play only and no sideload channel, so
    // `bundleRelease`, `assembleRelease` and every other release task cover `store` alone, and a restricted
    // package cannot be signed, stamped from the clock or uploaded by the documented release command.
    beforeVariants { variant ->
        if (variant.buildType == "release" && variant.productFlavors.any { it.second == "restricted" }) {
            variant.enable = false
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = JvmTarget.JVM_17
        // The ported classes annotate constructor properties (`@ApplicationContext private val`) and are written
        // for this target; FastMediaSorter builds with the same flag, so the annotations land on the same elements.
        freeCompilerArgs.add("-Xannotation-default-target=param-property")
    }
}

dependencies {
    implementation(libs.androidx.appcompat)
    implementation(libs.google.material)

    implementation(libs.timber)
    implementation(libs.gson)
    implementation(libs.google.gms.play.services.wearable)
    implementation(libs.kotlinx.coroutines.play.services)

    implementation(libs.dagger.hilt.android)
    ksp(libs.dagger.hilt.android.compiler)

    testImplementation(libs.junit)
    testImplementation(libs.robolectric)
    testImplementation(libs.kotlinx.coroutines.test)
}

// A release variant is never packaged without the upload key: an unsigned bundle is useless to Play and the
// refusal says what to configure instead of failing later in the signing task.
gradle.taskGraph.whenReady {
    val packaging = allTasks.any { it.path.startsWith(":phone:") && ReleaseSigning.isPackagingTask(it.name) }
    if (packaging && releaseSigning == null) {
        throw GradleException(ReleaseSigning.missingKeyMessage("phone"))
    }
}
