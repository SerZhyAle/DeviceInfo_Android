# Bootstrap handoff - DeviceInfo for Android & Wear OS

The starting brief for this repository, written on 2026-11-10 by the session that created the repository
boundary (FastMediaSorter ticket S4528, `P:\ANDROID\FastMediaSorter_mob_v2\PLAN\S4528_device-information-application.md`).
It is an input, not a living document: once this repository has its own ticket store, the open items
below become tickets here, and this file is kept as the record of where the product came from.

"DeviceInfo" (or "Device Information") is the working name.

## 1. Decision

- DeviceInfo for Android & Wear OS lives in this separate repository (`P:\ANDROID\deviceinfo_mob`), by the precedent of
  Tourist (`P:\ANDROID\Tourist_mob`), StreamsPlayer (`P:\ANDROID\StreamsPlayer_mob`), and Filler (`P:\ANDROID\filler_mob`).
- Installable packages: phone app and Wear OS app (one shared application id, one Data Layer pair).
- Coupling to FastMediaSorter: none. No shared code, no shared Gradle module, no shared release.
- Why not a module inside FastMediaSorter: independent lifecycle, dedicated release cadence, and clean single-purpose product scope.

## 2. Product

Goals:

1. A standalone phone app displaying full device information: OS, hardware, SoC, display, storage, sensors, cameras,
   battery, network, and diagnostics.
2. A standalone Wear OS app: glanceable device info tiles, hardware telemetry, sensors, battery status, and Data Layer sync
   with the phone companion.
3. Advanced battery information (carried from FastMediaSorter S4529): charge speed, power profile, nominal profile,
   calculated time to charge, calculated runtime left before switch-off.
4. Independent release: own application id, own signing key, own release cycle.
5. Porting from FastMediaSorter: phone classes (`ui/systeminfo/`, `core/systeminfo/`, `GatherSystemInfoUseCase`) and
   wear classes (`ui/apps/systeminfo/`, `domain/systeminfo/`, `data/wear/AndroidWearSystemInfo*`).

Non-goals:

- Media sorting, playback, cloud storage, SMB/SFTP sync - DeviceInfo is purely a diagnostic and system information tool.
- Immediate removal of System Info from FastMediaSorter.

## 3. Architecture & Modules

- Multi-module Gradle structure:
  - `phone/` - Phone application module.
  - `wear/` - Wear OS companion application module.
- Tooling: canon-shipped harness forwarder (`tools/harness.ps1`) adopting the `sza` canon plugin.
- Portfolio integration: registered under key `deviceinfo-mob` in `pq.ps1`.

## 4. Initial Backlog

- S0001: Complete canon adoption and project foundation
- S0002: Android multi-module skeleton (phone + wear)
- S0003: Core device info domain and collectors port
- S0004: Phone UI and presentation port
- S0005: Wear OS app & Data Layer sync port
- S0006: Advanced battery details & power metrics (FastMediaSorter S4529 port)
- S0007: Device check and parity verification
- S0008: Independent release preparation & packaging
