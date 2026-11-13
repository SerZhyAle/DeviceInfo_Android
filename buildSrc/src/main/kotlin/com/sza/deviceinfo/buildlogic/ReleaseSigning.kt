package com.sza.deviceinfo.buildlogic

import java.io.File
import java.util.Properties

/**
 * Reads the upload key of the release variant. The key material lives outside this repository (owner decision
 * of S0008: Play App Signing, the product's own key imported as the app signing key, a separate upload key
 * that signs the bundles); only a directory is configured, never a secret.
 *
 * The directory comes from the Gradle property `deviceinfo.signing.dir` (put it in
 * `%USERPROFILE%\.gradle\gradle.properties`, like the build JDK) or from the environment variable
 * `DEVICEINFO_SIGNING_DIR`. It holds `keystore.properties` with `storeFile` (absolute, or relative to that
 * directory), `storePassword`, `keyAlias` and `keyPassword`.
 */
object ReleaseSigning {
    const val DIRECTORY_PROPERTY = "deviceinfo.signing.dir"
    const val DIRECTORY_ENV = "DEVICEINFO_SIGNING_DIR"
    const val FILE_NAME = "keystore.properties"

    /**
     * The tasks that package a release variant: the aggregates (`assembleRelease`, `bundleRelease`) and the per-variant
     * ones a flavor adds (`bundleStoreRelease`, `packageStoreReleaseBundle`, `signStoreReleaseBundle`); each of them
     * needs the upload key, so an invocation that names a variant task directly cannot slip past the refusal.
     */
    private val PACKAGING_TASK = Regex("^(assemble|bundle|package|sign)([A-Z][A-Za-z0-9]*)?Release(Bundle)?$")

    fun isPackagingTask(taskName: String): Boolean = PACKAGING_TASK.matches(taskName)

    private val REQUIRED_KEYS = listOf("storeFile", "storePassword", "keyAlias", "keyPassword")

    data class Config(val storeFile: File, val storePassword: String, val keyAlias: String, val keyPassword: String)

    /** The configured directory; the property wins over the environment, blank counts as unset. */
    fun directory(property: String?, environment: String?): File? =
        (property?.trim()?.takeIf { it.isNotEmpty() } ?: environment?.trim()?.takeIf { it.isNotEmpty() })?.let(::File)

    /**
     * The upload key, or null when no directory is configured or it holds no `keystore.properties`. A file that
     * is there but incomplete, or that names a key store that does not exist, is an error: a half-configured
     * key must not look like an absent one.
     */
    fun load(directory: File?): Config? {
        if (directory == null) return null
        val file = File(directory, FILE_NAME)
        if (!file.isFile) return null
        val properties = Properties()
        file.reader(Charsets.UTF_8).use { reader -> properties.load(reader) }
        return parse(directory, properties)
    }

    fun parse(directory: File, properties: Properties): Config {
        val missing = REQUIRED_KEYS.filter { properties.getProperty(it).isNullOrBlank() }
        require(missing.isEmpty()) { "$FILE_NAME in $directory has no value for: ${missing.joinToString()}." }
        val declared = File(properties.getProperty("storeFile").trim())
        val store = if (declared.isAbsolute) declared else File(directory, declared.path)
        require(store.isFile) { "$FILE_NAME in $directory names the key store $store, which does not exist." }
        return Config(
            storeFile = store,
            storePassword = properties.getProperty("storePassword"),
            keyAlias = properties.getProperty("keyAlias").trim(),
            keyPassword = properties.getProperty("keyPassword"),
        )
    }

    /** The refusal printed when a release is packaged without the upload key. */
    fun missingKeyMessage(module: String): String =
        "Release packaging of :$module is refused: no upload key is configured. Set -P$DIRECTORY_PROPERTY=<directory> " +
            "(or the environment variable $DIRECTORY_ENV) to the directory that holds $FILE_NAME - the owner's key " +
            "directory outside this repository. Debug builds need none."
}
