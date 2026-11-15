# Changelog

All notable changes to DeviceInfo for Android and Wear OS are recorded in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and the product follows
[Package Versioning](docs/contracts/PACKAGE-VERSIONING.md): a release is named by its build instant, never by a
semantic version.

## [Unreleased]

## [2.61.1151.340] - 2026-11-15

First release on Google Play: phone versionCode 261115134, watch versionCode 261115138, one listing
`com.sza.deviceinfo`.

### Added
- The phone app shows the full information of the device in grouped, collapsible sections - App, Battery, Cameras,
  Device, Display, Hardware, Locale, Media and audio, Memory, Network, OS, Sensors, Storage, System, Time and User - and
  remembers which groups you left open.
- The Battery section reports the charge speed in mA and watts, the power profile, the nominal profile, the estimated
  time to a full charge and the estimated runtime left, and says plainly when the device does not expose a value.
- Copy, save and share the report, or copy one section. Values that identify the device in a network - the signature
  hash, local addresses and mount paths - are hidden in the default copy and included only after you confirm copying the
  full report.
- The phone app and the watch app share one look: the same blue accent, the same section header - a band with an
  accent marker and glyph and a plain title - and the same glyph before the title of the groups they have in common
  (App, Sensors, Memory, Storage, Wi-Fi and the paired phone on the watch). Every header of the watch list carries a
  glyph: a watch for Device, a pulse trace for Health, a leaf for Environment and a question mark for the Help row.
  The phone follows the light and dark themes; the watch uses the dark palette.
- The watch app shows glanceable information of the watch - Device, App, Memory, Storage, Phone connection, Health,
  Sensors, Wi-Fi and Environment - and **Send to phone** hands its report to the paired phone, which stores it and shows a
  notification that opens or shares it.
- On Android 13 and later the phone app asks once, with a short explanation, for permission to show the "Watch report
  received" notification, so **Send to phone** works from the first use; while notifications are off the menu offers
  **Turn on notifications**, which leads to the system prompt or to the app's notification settings.
- Help in the phone app and on the watch. On the phone the **Help** button of the report window, or **F1** on a keyboard,
  opens a page that explains every control of the window and what to do in what order; **F1** on a control opens that
  control's entry. The pages work with no network and are also published on the site. On the watch the **Help** row at the
  end of the list shows a short text, and the phone's help has a page for the watch screen. Each page shows the real screen
  with a number on every part it explains, in the light and the dark theme where the app has both, and says which version
  the pictures were taken from. English, Russian and Ukrainian.
- Interface size on the phone and on the watch: 100, 115, 130 or 150 percent for text, pictures, spacing and touch
  targets together, separate from the Android text size, which still applies on top. On the phone **Interface size** is
  in the overflow menu and the screen reopens at the new size; on the watch one button at the end of the list steps
  through the sizes. The choice is remembered. Touch targets never fall under 48 dp.
- English, Russian and Ukrainian interface on the phone and on the watch.
- A launcher icon for both apps, a privacy policy in English, Russian and Ukrainian, and `THIRD-PARTY-NOTICES.txt` inside
  both packages.
- A product page in English, Russian and Ukrainian, beside the privacy policy: what the app does, five scenarios, the way to
  get it on Google Play, help and support, and the other tools of the family.
- Neither package declares the internet permission; the app holds only the permissions its sections need, and Android
  backup is switched off.

### Changed
- The application id of both apps is `com.sza.deviceinfo`, one id for the phone and the watch.
- Report groups show their expanded state on the phone and watch; the watch remembers which groups you left open.
- Closed groups on the phone sit side by side at their own widths and wrap when a row is full; a group header tapped
  during a search closes and reopens that group; the tapped header keeps its place on the screen; and both apps return to
  the place in the report where you left them. The watch's **Refresh** and **Send to phone** are rectangular buttons that
  take the width their text needs and grow with larger text.
