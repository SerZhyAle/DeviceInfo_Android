# DeviceInfo for Android & Wear OS

DeviceInfo shows everything Android tells an app about the device it runs on: the system, the hardware and the
processor, the display, the memory and storage, the battery with its charge speed and estimated runtime, the sensors, the
cameras, the network state and diagnostics. It comes as an app for phones and an app for Wear OS watches, in English,
Russian and Ukrainian.

- **Phone:** grouped, collapsible report sections that remember how you left them; copy, save or share the report or one
  section. Values that identify the device in a network are hidden in the default copy.
- **Watch:** glanceable sections of the watch itself, and **Send to phone**, which hands the watch report to the paired
  phone.
- **Private by construction:** no server, no account, no telemetry, and no internet permission in either package. The
  [privacy policy](site/privacy.html) is also available in [Russian](site/privacy-ru.html) and
  [Ukrainian](site/privacy-uk.html).

It is distributed on Google Play, phone and watch in one listing, under the application id `com.sza.deviceinfo`.
The code is released under the [MIT License](LICENSE); third-party components are listed in
[THIRD-PARTY-NOTICES.txt](phone/src/main/assets/THIRD-PARTY-NOTICES.txt). What changed is in [CHANGELOG.md](CHANGELOG.md).

## Building

The commands, the toolchain and the verification tiers are in `CLAUDE.md` (sections 6 and 7); the release procedure, with
the signing key, the version pin and the checks, is in [docs/RELEASE.md](docs/RELEASE.md).

## Origin and project records

The device information feature comes from the System Info sub-application of FastMediaSorter, ported under the rules of
`docs/BOOTSTRAP_HANDOFF.md`; work is tracked in `PLAN/` with `tools/harness.ps1`.
