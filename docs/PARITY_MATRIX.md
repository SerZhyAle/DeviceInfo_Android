# PARITY_MATRIX - which function the phone app and the watch app carry (S0021)

The owner's rule for this product is that a new or fixed function reaches the phone app and the watch
app in parallel (the owner's order of 2026-11-13, quoted in every ticket of the S0016 to S0027 set).
This matrix is the one place where that rule can be checked: every information category and feature of
the Device Info function set is a row, with one cell for the phone and one for the watch, so a
deliberate absence is distinguishable from a forgotten port. It is this product's private map, written
in the row and cell vocabulary of `FUNCTION-PARITY` 0.1 so that it moves into the family register
unchanged when the owner adds DeviceInfo's columns (ticket S0025 carries the registration).

The matrix records what the code of each app carries today. It is not a device-verified claim: a
scenario that has not run on a device or an emulator stays an open manual check in its ticket
(CLAUDE.md section 2, rule 4). The mechanical guard against a forgotten *port* is the port scope check
(`tools/port-ledger/check-scope.ps1`, S0018); this matrix is the cross-form-factor view on top of it.

## 1. Vocabulary (FUNCTION-PARITY 0.1, rule 1)

A cell is exactly one of:

- `offered` - the function is present in the code of that side. The register grammar allows a
  `since <version or date>` stamp; no release exists yet (the version properties carry the
  non-releasable sentinels, S0008), so the cells carry no stamp; the first release tags it.
- `planned <repo-key>:<ticket>` - an open ticket owns bringing it. This private matrix carries only
  this repository's tickets (`deviceinfo-mob:<Sxxxx>`); a capture into another product's queue belongs
  in the family register, not here.
- `not offered: <reason class>` - a deliberate absence. The reason classes:
  - `os-only` - the platform does not provide it on that form factor: a hardware or OS capability the
    device class lacks (a camera on a watch).
  - `form-factor` - the platform provides it, but the screen or the interaction model cannot carry it
    (a share chooser on a watch).
  - `owner-declined (YYYY-MM-DD)` - a recorded owner decision, with the decision's date.
  - `subset` - outside the form factor's charter: the corresponding FastMediaSorter sub-app does not
    carry it and nothing about the form factor forces the absence. Stated once here per column, as
    rule 2 of the contract prescribes: **each column carries the System Info functions of its form
    factor's FastMediaSorter sub-app** (the owner's order of 2026-11-13 scopes the product to the
    functionality implemented in FastMediaSorter's phone and watch Device Information sub-apps), so a
    cell that reads `not offered: subset` means the upstream sub-app of that form factor never carried
    the function and no counterpart is proposed. A counterpart would be new scope beyond the charter;
    the owner can order one, and the cell then flips to `planned`.

The columns: **Phone** describes the phone app - the `store` distribution flavor, the public build
(the `restricted` build is not a release channel; the rows it alone carries read
`not offered: owner-declined`, with the note). **Watch** describes the wear app.

The check: `pwsh -NoProfile -File tools/parity/check-matrix.ps1` (fast tier, CLAUDE.md section 6). It
reads this file and `PLAN/spec-catalog.jsonl` and fails when a row has no cell value, a cell is outside
the grammar above, or a `planned` cell names a ticket that is closed or missing. A row where both sides
read `not offered` is legitimate - PM-029 is one: the phone declines by owner decision, the watch by
charter.

## 2. The matrix

| Id | Function | Group | Contract | Phone | Watch |
| --- | --- | --- | --- | --- | --- |
| PM-001 | Device identity (manufacturer, model, device name) | Device | none | offered | offered |
| PM-002 | OS version and API level | OS | none | offered | offered |
| PM-003 | SoC name, CPU core count, ABIs | Hardware | none | offered | offered |
| PM-004 | Kernel, OpenGL ES version, max heap, process bits | Hardware | none | offered | not offered: subset |
| PM-005 | Build facts (security patch, fingerprint, tags, build type) | System | none | offered | not offered: subset |
| PM-006 | Installer and install/update dates | System | none | offered | not offered: subset |
| PM-007 | User account name | User | none | offered | not offered: subset |
| PM-008 | App version and build number | App | none | offered | offered |
| PM-009 | Battery status basics (level, health, power source, status, technology) | Battery | none | offered | offered |
| PM-010 | Advanced battery details (current, power, saver, estimated capacity, time to full charge, estimated time remaining) | Battery | none | offered | not offered: subset |
| PM-011 | Battery wear metrics (cycle count, charging mode, average current) | Battery | none | offered | not offered: subset |
| PM-012 | Battery charge counter | Battery | none | offered | offered |
| PM-013 | RAM total and available | Memory | none | offered | offered |
| PM-014 | Storage (phone: volume total and available; watch: app data and cache) | Storage | none | offered | offered |
| PM-015 | Display facts (resolution, density, refresh rate, HDR, gamut, diagonal) | Display | none | offered | not offered: subset |
| PM-016 | Active network state (transport, metered, VPN, airplane mode, IP) | Network | none | offered | not offered: subset |
| PM-017 | Wi-Fi connection details (SSID, link speed, DNS, bandwidth, captive portal, IPv6) | Network | none | offered | not offered: subset |
| PM-018 | Wi-Fi capability (supported bands and standards) | Network | none | offered | offered |
| PM-019 | Bluetooth and NFC state | Network | none | offered | not offered: subset |
| PM-020 | Camera hardware inventory (level, apertures, flash, stabilization, max video, RAW and 10-bit) | Cameras | none | offered | not offered: os-only |
| PM-021 | Sensors (phone: count, key sensors, light/pressure/magnetic snapshot; watch: the sensor list) | Sensors | none | offered | offered |
| PM-022 | Environment readings (light, pressure, magnetic field, silent mode) | Environment | none | not offered: subset | offered |
| PM-023 | Media and audio (Widevine level, codecs, audio outputs) | Media & audio | none | offered | not offered: subset |
| PM-024 | Uptime and boot count | Health | none | offered | offered |
| PM-025 | Thermal state | Health | none | not offered: owner-declined (2026-11-13) | offered |
| PM-026 | Doze exemption and background limiting | Health | none | not offered: owner-declined (2026-11-13) | offered |
| PM-027 | Locale, time and timezone | Time | none | offered | not offered: subset |
| PM-028 | Benchmarks (memory and storage throughput, CPU single and multi thread) | Benchmarks | none | offered | not offered: subset |
| PM-029 | The seven extended diagnostics sections (OS security, permissions, installer signature, runtimes, mounts, network diagnostics, process resources) | Extended diagnostics | none | not offered: owner-declined (2026-11-13) | not offered: subset |
| PM-030 | Watch-to-phone system info report with acknowledgement | Data layer | DATA-LAYER-PAIR | offered | offered |
| PM-031 | Phone link (paired node name and id, this watch) | Phone link | none | not offered: subset | offered |
| PM-032 | Report notification on the phone | Notifications | none | offered | not offered: subset |
| PM-033 | Run-time notification permission request | Notifications | none | offered | not offered: subset |
| PM-034 | Sensitive-value masking (masked view until revealed) | Report | none | offered | not offered: subset |
| PM-035 | Copy to clipboard (phone: the whole report; watch: one row) | Report | none | offered | offered |
| PM-036 | Save report to file | Report | none | offered | not offered: subset |
| PM-037 | Share report | Report | none | offered | not offered: form-factor |
| PM-038 | Collapsible sections with persisted expansion | UI | UNIFIED-UI | offered | offered |
| PM-039 | In-app help (phone: the Help action and F1 open a help page; watch: a Help row at the end of the list shows a short text, and the phone page names the watch screen) | Help | CONTEXT-HELP | offered | offered |
| PM-040 | Product identity: color tokens, section header treatment (S0022; `docs/design/IDENTITY.md`) | UI | ICON-RENDER | offered | offered |
| PM-041 | Group glyphs before section titles (S0022; the watch carries the glyphs of the groups it shares with the phone and, S0035, its own glyph on Device, Health, Environment and the Help row, so every header has one) | UI | ICON-SET | offered | offered |
| PM-042 | Interface size: one app-wide scale of 100, 115, 130 and 150 percent, independent of the system text size (S0023; phone: a choice in the overflow menu that re-creates the screen; watch: a button at the end of the list that steps to the next size) | UI | UI-SIZING | offered | offered |

Where a row's two sides read the same category with different data, the difference is named in the row
(PM-014, PM-021, PM-035); the sections behind each cell are named in the notes below. The contract
column names the shared contract the row is governed by, or `none`; the pointers live in
`docs/contracts/`.

## 3. The scope decisions of the past tickets (the standing rule applied backwards)

CLAUDE.md section 4 carries the standing rule: a ticket that changes user-visible behavior names its
scope - phone, wear or both - and a one-sided change records why the other side does not get it. The
four one-sided tickets this product already had, applied to the matrix:

- **S0006** (battery details and power metrics, 2026-11-11/12) - phone. The advanced battery details
  of FastMediaSorter S4529 touched only the phone upstream (`app_v2`), and the watch app's parity with
  the upstream watch was already complete through `HealthInfoContributor` (thermal state, battery
  temperature, voltage, charge counter, doze exemption) - S0006's disposition 2. The watch cells of
  PM-010 and PM-011 read `not offered: subset` for that reason; the charge counter is the one item the
  watch carries (PM-012). The details, one by one: section 4.
- **S0009** (extended diagnostics sections, decided 2026-11-13) - phone, restricted build only. The
  owner's quiz answer put all seven upstream `noLegal` sections in a restricted build and none in the
  public build, and the restricted build is not a release channel (its release variant is disabled).
  PM-029 records it; the two rows the seven sections also touch are PM-025 (thermal status, in the
  process resources section) and PM-026 (battery optimization, in the permissions section).
- **S0010** (extended device info metrics, Sensors, Media & Audio; 2026-11-12) - phone. The
  FastMediaSorter S4543 port expanded the phone's base sections and added the Sensors and Media & Audio
  sections; the watch got nothing from it, because the upstream watch carries its own sections. The
  one-by-one classification: section 5. The rows: PM-011 (battery wear metrics), PM-017 to PM-019 (the
  network extras), PM-020 (camera hardware inventory), PM-022 (the phone's sensor snapshot is the
  counterpart the phone has for the watch's Environment readings), PM-023, PM-028.
- **S0011** (run-time notification permission request, 2026-11-13) - phone. `POST_NOTIFICATIONS` is
  requested by the phone screen only; the watch app posts no notifications, so there is nothing for it
  to request, and its refusal text ("Phone notifications are off") stays as is (S0011's assumed item
  4). The rows: PM-032, PM-033.
- **S0022** (visual identity, 2026-11-14) - both. The color tokens, the header treatment and the group
  glyphs reach the phone and the watch from one source (`docs/design/tokens.json`). The watch shows the
  phone's glyph where it shares a group with the phone (App, Sensors, Memory, Storage, Wi-Fi as the phone's
  Network, and the paired Phone). S0035 (2026-11-14, the owner's answer: a glyph on every header) gives the
  other headers of the same list a glyph too, because a set of headers draws a glyph on every member or on
  none (ICON-RENDER 0.25 section 25 rule 1): Device, Health and Environment take the watch's own glyphs
  (`device.watch`, `system.health` and `system.environment`, all proposed in the catalog), and the Help row
  takes `app.help`. The phone is unchanged: its 24 groups already carry a glyph. The rows: PM-040, PM-041.
- **S0024** (in-app help, 2026-11-14) - both, in the form each side can carry. The phone: the Help action and F1
  of the report window open a help page in the app (`HelpActivity`), the same pages the site publishes. The watch:
  no button and no key (a watch has no keyboard and no top app bar; CONTEXT-HELP 0.4 item L), but its own entry, a Help
  row at the end of the list that shows a short text, because the watch app can run without a phone; the phone page
  `watch-system-info` names every watch screen. The row: PM-039, which flips from `planned` to `offered` on both
  sides.
- **S0032** (help page screenshots, 2026-11-14) - both. The two help pages (the phone report window and the watch
  screen) carry a picture of the real screen with numbered pins, per locale and per theme (the watch app has one
  theme, so its page has one picture), captured on a device by `tools/help/capture-help.ps1`. One page set serves
  both sides, so the change is not one-sided. The row: PM-039 stays `offered` on both sides; no cell flips.
- **S0023** (UI conformance, 2026-11-14) - both for the interface size (exception E1): the phone and the watch carry
  the same four steps and the same rule that an unsupported value reads as 100 percent; each side offers the choice in
  the form it can carry (an overflow-menu item with a dialog on the phone, a button that steps to the next size on the
  watch, which has no menu). The row: PM-042. The rest of S0023 is one-sided by what each side draws: the wrapping
  action buttons (E2) are watch only, because the phone's actions are toolbar items drawn by the toolkit app bar; the
  content-sized packing of collapsed headers and the search disclosure (E3) are phone only, because the watch already
  flowed collapsed headings at their own widths and has no search; the viewport memory and the activated-header
  anchor (E3) are on both sides. PM-038 is unchanged: its function, collapsible sections with persisted expansion, is
  unchanged on both.

## 4. The S0006 battery details, one by one

| S0006 item | Phone | Watch | Class | Why |
| --- | --- | --- | --- | --- |
| Battery current | offered | not offered: subset | subset | Upstream S4529 is phone-only; the watch's parity with the upstream watch is complete without it (S0006 disposition 2). |
| Battery power | offered | not offered: subset | subset | Same as the row above. |
| Battery saver | offered | not offered: subset | subset | Same as the row above. |
| Estimated capacity | offered | not offered: subset | subset | Same as the row above. |
| Time to full charge | offered | not offered: subset | subset | Same as the row above; the charge counter the watch does carry is PM-012. |
| Estimated time remaining | offered | not offered: subset | subset | Same as the row above. |

No watch counterpart is proposed: the charter scopes the watch app to the upstream watch sub-app, and
none of these was ever in it. The owner can order one, and the cells flip to `planned`.

## 5. The S0010 metrics, one by one

| S0010 item | Phone | Watch | Class | Why |
| --- | --- | --- | --- | --- |
| Sensors section (count, key sensors, light/pressure/magnetic snapshot) | offered | offered | - | The watch's Sensors section lists the sensors (PM-021); the live readings are the watch's Environment section (PM-022), which the phone deliberately has no counterpart for. |
| Media & Audio section (Widevine, codecs, audio outputs) | offered | not offered: subset | subset | The upstream watch sub-app has no such section (PM-023). |
| Camera hardware inventory (8 fields) | offered | not offered: os-only | os-only | Watches carry no camera hardware (PM-020). |
| Battery wear metrics (cycle count, charging mode, charge counter, average current) | offered | offered for the charge counter, not offered: subset for the rest | subset | The charge counter is PM-012 (also in the watch Health section, S0006); the other three follow the S4529 scope decision above (PM-011). |
| CPU benchmark rows (single, multi thread) | offered | not offered: subset | subset | The Benchmarks section is a phone sub-app function (PM-028). |
| Base-section expansions (the extra fields of the 12 base sections: Wi-Fi details and capabilities, BT/NFC, IPv6, bandwidth, DNS, display diagonal and refresh range, locales list, hour format, boot count, security patch, fingerprint, tags, build type, installer, install dates, device name, input method) | offered | offered for the categories the watch carries (PM-001 to PM-003, PM-008, PM-012, PM-018, PM-021, PM-024), not offered: subset for the rest | subset | The upstream watch sub-app carries its own field set per section. |

## 6. First-pass result and maintenance

The first pass (2026-11-14) filled the matrix from the code of both modules and found **no unowned
gap**: every absence is classified by design with its reason, and the only planned cells were the two
in-app-help cells of PM-039, which ticket S0024 flipped to `offered` on 2026-11-14 (no planned cell remains). The `system_info_section_extended` string of the
wear module is unused in the code of this repository and unused in the upstream wear module - a
faithful port of a dead upstream string, kept so the port scope check stays green; it is not a row.

Maintenance, per the standing rule (CLAUDE.md section 4):

- A ticket that changes user-visible behavior names its scope (phone, watch or both) and a one-sided
  change records why the other side does not get it; the ticket updates the rows it concerns in the
  same step, and its audit checks both.
- A function newly `offered` on a side flips that cell from `planned` or `not offered`; the `since`
  stamp is left for the release that first ships it.
- A new function gets its row in the same step it is specified (`FUNCTION-PARITY` rule 3), with both
  cells filled: `planned` with the ticket, or `not offered` with its reason.
- `pwsh -NoProfile -File tools/parity/check-matrix.ps1` runs after any matrix edit and at every
  release start; it fails on an unfilled cell, a cell outside the grammar, and a `planned` cell whose
  ticket is closed or missing.
