package com.sza.deviceinfo.ui.systeminfo.helpers

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class NotificationPromptPolicyTest {

    private val android12 = 32
    private val android13 = 33
    private val android16 = 36

    @Test
    fun `a fresh install on Android 13 with notifications off explains on the first open`() {
        assertTrue(explain(sdk = android13, enabled = false, explained = false, answered = false))
        assertTrue(explain(sdk = android16, enabled = false, explained = false, answered = false))
    }

    @Test
    fun `nothing is explained below Android 13 because the permission does not exist`() {
        assertFalse(explain(sdk = android12, enabled = false, explained = false, answered = false))
    }

    @Test
    fun `nothing is explained while notifications are already on`() {
        assertFalse(explain(sdk = android13, enabled = true, explained = false, answered = false))
    }

    @Test
    fun `the explanation never returns after it was answered once`() {
        assertFalse(explain(sdk = android13, enabled = false, explained = true, answered = false))
    }

    @Test
    fun `the explanation never returns after the system prompt was answered`() {
        assertFalse(explain(sdk = android13, enabled = false, explained = false, answered = true))
        assertFalse(explain(sdk = android13, enabled = false, explained = true, answered = true))
    }

    @Test
    fun `the menu entry exists exactly while notifications are off`() {
        assertTrue(NotificationPromptPolicy.isMenuEntryVisible(notificationsEnabled = false))
        assertFalse(NotificationPromptPolicy.isMenuEntryVisible(notificationsEnabled = true))
    }

    @Test
    fun `the menu raises the system prompt on Android 13 until it was answered`() {
        assertEquals(
            NotificationMenuAction.REQUEST_PERMISSION,
            NotificationPromptPolicy.menuAction(android13, systemPromptAnswered = false),
        )
    }

    @Test
    fun `the menu opens the settings once the system prompt was answered`() {
        assertEquals(
            NotificationMenuAction.OPEN_SETTINGS,
            NotificationPromptPolicy.menuAction(android13, systemPromptAnswered = true),
        )
    }

    @Test
    fun `the menu opens the settings below Android 13 whatever was answered`() {
        assertEquals(
            NotificationMenuAction.OPEN_SETTINGS,
            NotificationPromptPolicy.menuAction(android12, systemPromptAnswered = false),
        )
        assertEquals(
            NotificationMenuAction.OPEN_SETTINGS,
            NotificationPromptPolicy.menuAction(android12, systemPromptAnswered = true),
        )
    }

    private fun explain(sdk: Int, enabled: Boolean, explained: Boolean, answered: Boolean): Boolean =
        NotificationPromptPolicy.shouldExplainOnOpen(
            sdkInt = sdk,
            notificationsEnabled = enabled,
            explained = explained,
            systemPromptAnswered = answered,
        )
}
