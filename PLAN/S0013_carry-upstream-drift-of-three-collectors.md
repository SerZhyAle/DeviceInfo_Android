# S0013_carry-upstream-drift-of-three-collectors

**Status:** Implemented
**Status note:** Three collectors carried to upstream, drift check exit 0. No compile command declared (commands.compileCheck absent); not built, not tested until the release.
**Created:** 2026-11-13
**Complexity:** medium - assessed at the spec pass: three files in one layer, each edit is behaviour-neutral and visible in the upstream diff; the work was reading the diffs and deciding carry versus decision per file

## 0. Owner request (verbatim)

Found at S0008 (2026-11-13), the release-start drift check: `pwsh -NoProfile -File tools/port-ledger/check-drift.ps1` exits 1 with three uncarried upstream changes, all anchored on 2026-11-12 and changed upstream since:

- app_v2/src/main/java/com/sza/fastmediasorter/core/systeminfo/BatteryDetailsCollector.kt -> phone/src/main/kotlin/com/sza/deviceinfo/core/systeminfo/BatteryDetailsCollector.kt
- app_v2/src/main/java/com/sza/fastmediasorter/core/systeminfo/PlatformDetailsCollector.kt -> phone/src/main/kotlin/com/sza/deviceinfo/core/systeminfo/PlatformDetailsCollector.kt
- app_v2/src/main/java/com/sza/fastmediasorter/core/systeminfo/SensorsDiagnosticsCollector.kt -> phone/src/main/kotlin/com/sza/deviceinfo/core/systeminfo/SensorsDiagnosticsCollector.kt

CLAUDE.md section 2 says the check runs before any parity claim and at every release start and that an uncarried change is either carried (`record-port.ps1 -Refresh`, after reading what changed upstream and porting it with its tests) or decided (`record-port.ps1 -Decide`, a deliberate difference written next to the code). The spec pass reads the three upstream diffs, decides carry or decision per file, and ends with the check at exit 0. The FastMediaSorter checkout is read-only from here.


## 1. Problem

The upstream's System info code changed after DeviceInfo copied it, so the drift check that guards every parity claim and every release start reports three ported files as out of step and exits non-zero. Until each change is read and either carried or deliberately declined, the product cannot claim parity with the upstream and the release flow cannot start.

## 2. Done criteria

- `pwsh -NoProfile -File tools/port-ledger/check-drift.ps1` exits 0. Observed 2026-11-13 after the carry: `OK: nothing uncarried (92 in step, 0 decided)`, exit 0.
- Each of the three ported files differs from the upstream file (package names mapped) only by a difference that is recorded next to the code or by an owner-visible rule: Platform differs by nothing, Battery by the S0006 status-bound probe, Sensors by the step counter row and the header text (table in 3.1). Checked 2026-11-13 by a mapped diff of each pair.
- `ScanResultWifiStandards` and `sampleEnvironmentScalar` no longer occur anywhere under `phone/src` (grep, 2026-11-13: no hit).
- RELEASE: the edited Kotlin compiles and the unit tests stay green. Commands for the release: `.\gradlew.bat :phone:assembleDebug` and `.\gradlew.bat :phone:testDebugUnitTest`. Not run here: the repository declares no compile-only command and both runs are above 5 s.

## 3. Approach

### 3.1 Scope

What the three upstream diffs contained, read on 2026-11-13. The anchor hash of Battery is the upstream's own commit of 2026-11-12 (`03188d37f`), so its diff is exact. The anchored versions of Platform and Sensors were uncommitted working-tree states at port time and are in no upstream commit, so for those two the change was derived by comparing the current upstream file with the port line by line, which is the complete carry basis whatever the anchor held.

| File | What upstream has now | Disposition |
| --- | --- | --- |
| `BatteryDetailsCollector` | Upstream deleted its own status-bound probe line and the `Timber` import (release 48 archived its ticket). Nothing else changed since `03188d37f`. | Carried, no code change: the port never held the upstream probe. The one `Timber.d` line in the port is S0006's own probe, correct while S0006 is `BlockNeedUserTest`, and is removed by S0006's probe sweep, not by this ticket. |
| `PlatformDetailsCollector` | (a) Wi-Fi 6 and Wi-Fi 7 capability checks use the public `ScanResult.WIFI_STANDARD_11AX` and `WIFI_STANDARD_11BE` instead of a private constants object (commit `92f4f32a2`, behaviour-neutral: 6 and 8). (b) `playServicesVersion` is a `try` with `catch (_: Exception)`. (c) `fileEncryptionStatus` already uses the public instance query with an explanatory comment, which is the fix the port had made on its own. | Carried in full. The port now equals the upstream file byte for byte after the package-name mapping. The KDoc that called (c) a difference from the original is removed because it is no longer true. `compileSdk` is 37 here, so both constants exist. |
| `SensorsDiagnosticsCollector` | The scalar sampling helper is `sampleEnvironmentSensor` and the array helper is `sampleEnvironmentSensorArray`: upstream fixed the same overload ambiguity the port had fixed with the name `sampleEnvironmentScalar`. | Carried: the port takes the upstream names and the KDoc that called the overloads a difference is removed. Two differences stay and stay documented in the file header KDoc: the key-sensor row names the step counter (a presence check, no permission), and the header text says where the permission-gated sensors live in this repository. |

What deliberately did not change: wear, strings, tests, any other ported file, and the S0010 disposition table, which still names `sampleEnvironmentScalar` in its row for this helper. That row is S0010's record of a past state and is superseded by the table above; S0007's re-read of disposition tables must read it with this ticket.

### Assumed (unattended, 2026-11-13)

- **Carry, not decide, for Platform and Sensors.** Alternative: `record-port.ps1 -Decide` for the two behaviour-neutral upstream edits (constants, `catch`) and keep the port's private constants object and `runCatching`. Taken because the project law is port, do not rewrite, because both edits are one-line and neutral, and because a port that equals upstream makes the next drift diff clean. Owner may overrule.
- **Adopt upstream's helper names in Sensors.** Alternative: keep `sampleEnvironmentScalar` as a recorded difference. Taken for the same reason; the rename is private to one file and has no other reference. Owner may overrule.
- **`-Refresh` for Battery with no code change.** Alternative: `-Decide` with a note. Taken because the change upstream made, removing its probe, is already reflected in the port: the port holds no upstream probe. Owner may overrule.
- **Complexity stays `medium`.** Alternative: `light` (small edits). Kept at the higher level because the work contained a decision per file, and in doubt the higher level applies.

### 3.2 Open questions

None. Every point above was answered by reading the upstream diffs and the port.

### 3.3 Owner inputs (Approval gate)

None.

- **Related tickets:** none (S0006 owns the one probe left in `BatteryDetailsCollector`; S0010 holds the superseded row; S0007 re-reads the disposition tables. These are mentions, not blockers.)

## Last Audit

**Date:** 26-11-13 08:02 | **Mode:** static | **Outcome:** Verified
**Counts:** PASS 6 | WARN 0 | FAIL 0 | MANUAL 0 | UNCHECKABLE 0 | EXEMPT 2 | RELEASE 2

Checks, each run on 2026-11-13:

- PASS - `check-drift.ps1` exit 0, `OK: nothing uncarried (92 in step, 0 decided)`. expected: exit 0 | actual: exit 0.
- PASS - Platform: mapped diff against upstream is empty. expected: no differing line | actual: no differing line.
- PASS - Battery: mapped diff shows exactly two added lines, the `Timber` import and the S0006 probe. expected: 2 | actual: 2.
- PASS - Sensors: mapped diff shows only the header KDoc and the `Step counter` entry. expected: documented differences only | actual: documented differences only.
- PASS - no occurrence of `ScanResultWifiStandards` or `sampleEnvironmentScalar` under `phone/src`. expected: 0 | actual: 0.
- PASS - probe invariant: S0006 is `BlockNeedUserTest` and its single probe is the one `Timber.d` in `BatteryDetailsCollector`; this ticket added none and removed none. expected: probe iff status | actual: holds.
- EXEMPT - device behaviour of the Wi-Fi band row, the Play services row and the sensor rows: no behaviour changed, the device scenarios belong to S0007.
- EXEMPT - user-facing surfaces and CHANGELOG: nothing user-visible changed.
- RELEASE - compile of the edited Kotlin: `.\gradlew.bat :phone:assembleDebug`. No compile-only command is declared (`commands.compileCheck` is absent from `.sza-profile.json`) and the build is above 5 s. Not built.
- RELEASE - `.\gradlew.bat :phone:testDebugUnitTest`. Not run, above 5 s.

### Action items
1. none.

### Manual / on-target
- none for this ticket; the device scenarios stay with S0007.
