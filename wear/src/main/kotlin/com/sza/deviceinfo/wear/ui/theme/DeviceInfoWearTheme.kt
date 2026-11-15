package com.sza.deviceinfo.wear.ui.theme

import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.wear.compose.material.Colors
import androidx.wear.compose.material.MaterialTheme

/*
 * The product identity on the watch (S0022). The values are the night members of the tokens in
 * docs/design/tokens.json: Compose for Wear has no light palette and the display is black glass, so the watch
 * carries one dark palette. The phone carries the same tokens as identity_* color resources, and
 * tools/design/check-tokens.ps1 holds the three equal. Change a value in tokens.json, then here and in the phone
 * colors, in one edit.
 */
internal val IdentityAccent = Color(0xFF64B5F6)
internal val IdentityOnAccent = Color(0xFF00315F)
internal val IdentityAccentContainer = Color(0xFF0D47A1)
internal val IdentityOnSurface = Color(0xFFE3E2E6)
internal val IdentitySurfaceVariant = Color(0xFF2B3138)
internal val IdentityOnSurfaceVariant = Color(0xFFC3C7CF)
internal val IdentityError = Color(0xFFFFB4AB)
internal val IdentityOnError = Color(0xFF690005)

/** The one display background that is not a token: pure black on an OLED watch (tokens.json, watchOverrides). */
private val WatchBackground = Color(0xFF000000)

private val DeviceInfoWearColors = Colors(
    primary = IdentityAccent,
    primaryVariant = IdentityAccentContainer,
    secondary = IdentityAccent,
    secondaryVariant = IdentityAccentContainer,
    background = WatchBackground,
    surface = IdentitySurfaceVariant,
    error = IdentityError,
    onPrimary = IdentityOnAccent,
    onSecondary = IdentityOnAccent,
    onBackground = IdentityOnSurface,
    onSurface = IdentityOnSurface,
    onSurfaceVariant = IdentityOnSurfaceVariant,
    onError = IdentityOnError
)

/** The watch app's Material theme: the product palette over the toolkit's default typography and shapes. */
@Composable
fun DeviceInfoWearTheme(content: @Composable () -> Unit) {
    MaterialTheme(colors = DeviceInfoWearColors, content = content)
}
