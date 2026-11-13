# Security posture inventory

Reconciled 2026-11-13 (S0008) against `phone/src/main/AndroidManifest.xml`, `wear/src/main/AndroidManifest.xml` and the
code of both modules. The hosted privacy pages (`site/privacy*.html`), the in-app wording and the Play Data safety answers
(`docs/play/PLAY_DATA_SAFETY.md`) are renders of these two inventories; a change here moves all three in one edit.

## 1. Permission inventory

| Package | Declared in | Permission | Consumer | One-sentence justification | Shown when requested |
| --- | --- | --- | --- | --- | --- |
| Phone | `phone/src/main/AndroidManifest.xml` | `ACCESS_NETWORK_STATE` | `PlatformDetailsCollector`, the Network section | Tells whether the device is online, on Wi-Fi or mobile data, metered or behind a VPN. | Normal permission, granted at install; nothing is requested at run time. |
| Phone | `phone/src/main/AndroidManifest.xml` | `POST_NOTIFICATIONS` | `WearSystemInfoReportReceiver.postNotification` | Shows the notification "Watch report received" when the watch sends a report. | Requested at run time on Android 13 and later, once, on the first open of the System information screen, after a dialog that says why (S0011): **Continue** opens the system prompt, **Not now** records the answer and the screen never asks by itself again. While notifications are off the toolbar overflow shows **Turn on notifications**, which raises the system prompt if it was never answered and opens the app's notification settings otherwise (also below Android 13, where no run-time permission exists); a refusal of the system prompt shows a snackbar with a **Settings** action. With notifications off the watch says "Phone notifications are off". |
| Watch | `wear/src/main/AndroidManifest.xml` | `ACCESS_WIFI_STATE` | `AndroidWearHardwareDataSource`, the Wi-Fi section | Names the Wi-Fi bands and standards the radio of the watch supports. | Normal permission, granted at install; nothing is requested at run time. |

Dropped at the release preparation (S0008), because the consumer of the permission cannot be named:

- Watch `WAKE_LOCK`: the upstream FastMediaSorter watch manifest declares it for its `WearPowerManager`, which this
  product did not port; no class of `wear/src/main` acquires a wake lock.
- Watch `ACCESS_NETWORK_STATE`: no class of `wear/src/main` reads `ConnectivityManager` or `NetworkCapabilities`.

Not permissions, and listed so the inventory is complete: the phone manifest's `<queries>` entry for
`com.google.android.gms` (package visibility, so the OS section can name the installed version of Google Play services),
and the `FileProvider` of the phone app (`exported="false"`, temporary grants only for a report the user shares).

Neither package declares `INTERNET`, location, contacts, storage, camera or microphone permissions. The merged release
manifests are read back from the built packages by `tools/release/read-package-info.ps1 -AllowedPermissions ..`, which
refuses `INTERNET` and every permission outside the list; that check is part of the release (`docs/RELEASE.md`).

## 2. Network-surface inventory

| Surface | On by default | What turns it on | How long it lives | What leaves, and to where |
| --- | --- | --- | --- | --- |
| Listening port | none exists | - | - | Nothing: neither package opens a listening port. |
| Outbound connection | none exists | - | - | Nothing: neither package declares `INTERNET` and neither links a networking, analytics, advertising or tracking library. |
| Wearable Data Layer message, watch to phone (`/deviceinfo/watch/system_info_report`) | off | The user taps **Send to phone** on the watch. | One message per tap. | The text of the watch report, to the paired phone, through Google Play services. |
| Wearable Data Layer message, phone to watch (`/deviceinfo/phone/system_info_report_ack`) | off | A report arrived from the watch. | One short answer per report. | An accepted or refused flag with a reason code, to the watch that sent the report. |
| Android share sheet (`ACTION_SEND`) | off | The user taps **Share**, or taps the "Watch report received" notification. | One intent. | The text of the report, or the stored report file through a temporary `FileProvider` grant, to the app the user picks. |
| Clipboard | off | The user taps **Copy** or **Copy section**. | Until the clipboard is replaced. | The text of the report or of one section, to whatever the user pastes it into. A full copy that includes sensitive values asks for confirmation first. |
| Downloads folder | off | The user taps **Save**. | One file. | A text file on the phone; nothing leaves the device. |

Third-party loader on an owned page: none. The hosted pages carry no analytics, advertising or tracking script; their only
scripts are the inline theme and language switchers.

The claim "no telemetry" is proven by the dependency set, not by the page saying so: the release run reads
`:phone:dependencies --configuration storeReleaseRuntimeClasspath` and `:wear:dependencies --configuration
releaseRuntimeClasspath` and finds every group id of them in `THIRD-PARTY-NOTICES.txt` (`docs/RELEASE.md`, step 4).

## 3. The restricted build (S0009) - what it reads, and why the store text does not change

The phone module has two flavors (`distribution` dimension). `store` is the public build, the only one with a release
variant, and everything above describes it. `restricted` is a developer build: it shares the frozen application id, has no
release variant (so no store, site or channel ever receives it) and adds the seven extended diagnostics sections of
`phone/src/restricted` (owner decision, S0009, option 1). The Play listing, the Data safety answers and the privacy page
describe `store`; they do not change because of `restricted`. If a channel is ever chosen for it (S0008's decision to
revisit first), this section is the list its permission list, privacy text and Data safety answers start from.

| What the restricted build adds | Where | What it reads or declares |
| --- | --- | --- |
| Permissions | `phone/src/restricted/AndroidManifest.xml` | None. It never requests a permission at run time; a row that needs one (location, Bluetooth connect, phone state, activity recognition) reports the state as denied and degrades. |
| Package visibility, narrowly (`<queries>`, API 30+) | same | Seven packages, by name: Magisk, KernelSU, APatch (root markers), F-Droid, Aurora Store, Amazon Appstore, Huawei AppGallery (alternative stores); and the handlers of the launcher, home and https-view intents (launchable-app count, default launcher and browser). It does not hold `QUERY_ALL_PACKAGES`. |
| Installer and signature section | `RestrictedDiagnosticsCollectors.installerSignature` | The installer and install-source package names of this app, the SHA-256 of its signing certificate and its APK layout (both masked until revealed), the count of launchable apps split user and system, the default launcher and browser package names. |
| OS and security section | `.osSecurity` | Root-marker files and the seven packages above, SELinux mode, developer-options and ADB settings, Xposed presence, build tags and type, bootloader and verified-boot properties, OEM skin, encryption state, the first line of `/proc/version`, uptime. |
| Special permissions section | `.permissions` | The grant state of ten permissions and special accesses for this app, whether battery optimization is ignored, the accessibility-service and notification-listener counts, one step-counter sample of at most 80 ms when activity recognition is granted, the presence of step, motion, heart-rate and off-body sensors. |
| Runtimes section | `.runtimes` | ABIs, WebView provider, GPU driver and ART heap properties, Widevine security level, TLS provider names, vendor-private and wake-up sensor counts. |
| Mounts section | `.mounts` | `/proc/mounts` (mount points masked until revealed), file-system types of four mounts, zram and I/O scheduler sysfs values, partition sizes, external-storage state, removable-volume count. |
| Network diagnostics section | `.network` | DNS servers, VPN interfaces, active interfaces with MTU, Wi-Fi SSID and BSSID, Wi-Fi link and gateway, Bluetooth state and bonded-device names, SIM state and operator names (all masked until revealed); HTTP proxy, active transport, private-DNS mode, metered flag. |
| Process resources section | `.processResources` | PID, UID, process SELinux context, heap, PSS and VmRSS, file-descriptor and thread counts, CPU governor and frequencies, thermal status and sysfs thermal zones, battery sysfs values. |

Ten fields are flagged sensitive and masked in the on-screen text, on a normal copy and on share until the user reveals them
(signature SHA-256, APK and split layout, mount points, DNS servers, VPN interfaces, active interfaces and MTU, Wi-Fi SSID
and BSSID, Wi-Fi link and gateway, Bluetooth and bonded devices, cellular and SIM state). Nothing of this leaves the device:
the restricted build declares no `INTERNET` permission either.
