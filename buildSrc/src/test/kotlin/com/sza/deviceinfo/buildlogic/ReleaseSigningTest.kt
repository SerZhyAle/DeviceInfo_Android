package com.sza.deviceinfo.buildlogic

import java.io.File
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertThrows
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder

/** The upload key reader: absent is null, half-configured is an error, complete is read as written. */
class ReleaseSigningTest {

    @get:Rule
    val folder = TemporaryFolder()

    private fun keystoreProperties(directory: File, text: String) =
        File(directory, ReleaseSigning.FILE_NAME).writeText(text, Charsets.UTF_8)

    @Test
    fun thePropertyWinsOverTheEnvironmentAndBlankCountsAsUnset() {
        assertNull(ReleaseSigning.directory(null, null))
        assertNull(ReleaseSigning.directory("  ", ""))
        assertEquals(File("a"), ReleaseSigning.directory("a", "b"))
        assertEquals(File("b"), ReleaseSigning.directory("", "b"))
    }

    @Test
    fun noDirectoryOrNoFileMeansNoKey() {
        assertNull(ReleaseSigning.load(null))
        assertNull(ReleaseSigning.load(folder.root))
    }

    @Test
    fun aHalfConfiguredFileIsAnErrorThatNamesTheMissingKeys() {
        keystoreProperties(folder.root, "storeFile=upload.jks\nkeyAlias=upload\n")
        val error = assertThrows(IllegalArgumentException::class.java) { ReleaseSigning.load(folder.root) }
        assertTrue(error.message, error.message!!.contains("storePassword"))
        assertTrue(error.message, error.message!!.contains("keyPassword"))
    }

    @Test
    fun aKeyStoreThatDoesNotExistIsAnError() {
        keystoreProperties(
            folder.root,
            "storeFile=missing.jks\nstorePassword=x\nkeyAlias=upload\nkeyPassword=y\n",
        )
        assertThrows(IllegalArgumentException::class.java) { ReleaseSigning.load(folder.root) }
    }

    @Test
    fun aCompleteFileIsReadWithARelativeStoreFileResolvedAgainstTheDirectory() {
        val store = folder.newFile("upload.jks")
        keystoreProperties(
            folder.root,
            "storeFile=upload.jks\nstorePassword=store-secret\nkeyAlias=upload\nkeyPassword=key-secret\n",
        )
        val config = ReleaseSigning.load(folder.root)!!
        assertEquals(store, config.storeFile)
        assertEquals("store-secret", config.storePassword)
        assertEquals("upload", config.keyAlias)
        assertEquals("key-secret", config.keyPassword)
    }

    @Test
    fun anAbsoluteStoreFileIsKeptAsIs() {
        val store = folder.newFile("elsewhere.jks")
        keystoreProperties(
            folder.root,
            "storeFile=${store.absolutePath.replace("\\", "/")}\nstorePassword=a\nkeyAlias=b\nkeyPassword=c\n",
        )
        assertEquals(store.canonicalFile, ReleaseSigning.load(folder.root)!!.storeFile.canonicalFile)
    }

    @Test
    fun theRefusalNamesTheModuleTheDirectoryPropertyAndTheEnvironmentVariable() {
        val message = ReleaseSigning.missingKeyMessage("phone")
        assertTrue(message.contains(":phone"))
        assertTrue(message.contains(ReleaseSigning.DIRECTORY_PROPERTY))
        assertTrue(message.contains(ReleaseSigning.DIRECTORY_ENV))
    }

    @Test
    fun aggregateAndPerVariantReleasePackagingTasksNeedTheKey() {
        listOf(
            "assembleRelease", "bundleRelease", "packageRelease", "packageReleaseBundle", "signReleaseBundle",
            "assembleStoreRelease", "bundleStoreRelease", "packageStoreRelease", "packageStoreReleaseBundle",
            "signStoreReleaseBundle",
        ).forEach { assertTrue("$it must need the key", ReleaseSigning.isPackagingTask(it)) }
    }

    @Test
    fun debugAndNonPackagingTasksNeedNoKey() {
        listOf(
            "assembleDebug", "assembleStoreDebug", "assembleRestrictedDebug", "bundleStoreDebug",
            "testStoreDebugUnitTest", "testDebugUnitTest", "compileStoreReleaseKotlin", "packageStoreReleaseResources",
            "lintVitalStoreRelease", "bundleStoreReleaseClasspath",
        ).forEach { assertFalse("$it must not need the key", ReleaseSigning.isPackagingTask(it)) }
    }
}
