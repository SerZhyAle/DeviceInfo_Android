# Changelog

All notable changes to DeviceInfo for Android and Wear OS are recorded in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and the product follows
[Package Versioning](docs/contracts/PACKAGE-VERSIONING.md): a release is named by its build instant, never by a
semantic version.

## [Unreleased]

### Added
- The phone app shows the full information of the device in grouped, collapsible sections - App, Battery, Cameras,
  Device, Display, Hardware, Locale, Media and audio, Memory, Network, OS, Sensors, Storage, System, Time and User - and
  remembers which groups you left open.
- The Battery section reports the charge speed in mA and watts, the power profile, the nominal profile, the estimated
  time to a full charge and the estimated runtime left, and says plainly when the device does not expose a value.
- Copy, save and share the report, or copy one section. Values that identify the device in a network - the signature
  hash, local addresses and mount paths - are hidden in the default copy and included only after you confirm copying the
  full report.
- The watch app shows glanceable information of the watch - Device, App, Memory, Storage, Phone connection, Health,
  Sensors, Wi-Fi and Environment - and **Send to phone** hands its report to the paired phone, which stores it and shows a
  notification that opens or shares it.
- On Android 13 and later the phone app asks once, with a short explanation, for permission to show the "Watch report
  received" notification, so **Send to phone** works from the first use; while notifications are off the menu offers
  **Turn on notifications**, which leads to the system prompt or to the app's notification settings.
- English, Russian and Ukrainian interface on the phone and on the watch.
- A launcher icon for both apps, a privacy policy in English, Russian and Ukrainian, and `THIRD-PARTY-NOTICES.txt` inside
  both packages.
- A product page in English, Russian and Ukrainian, beside the privacy policy: what the app does, five scenarios, the way to
  get it on Google Play, help and support, and the other tools of the family.
- Neither package declares the internet permission; the app holds only the permissions its sections need, and Android
  backup is switched off.

### Changed
- The application id of both apps is `com.sza.deviceinfo`, one id for the phone and the watch.
