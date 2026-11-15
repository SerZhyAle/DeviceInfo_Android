# S0037_bugfix-battery-header-unit-test

**Status:** Implemented
**Status note:** no compile command (commands.compileCheck absent in .sza-profile.json); test-only edit of GatherSystemInfoUseCaseTest.kt not compiled in this pass. Static: spec_catalog/validate 10 OK, check-docs PASS, release-queue OK. RELEASE, not run: .\gradlew.bat :phone:testStoreDebugUnitTest :phone:testRestrictedDebugUnitTest --tests com.sza.deviceinfo.domain.usecase.GatherSystemInfoUseCaseTest (expected 0 failures). Assumed (unattended, 2026-11-14): battery broadcast supplied by a test context, see section 3.2.
**Created:** 2026-11-14
**Complexity:** light - one test file, no product code, no new file, no new public type, no DI, no schema; rung confirmed at the spec pass of 2026-11-14 (primitive)

## 0. Owner request (verbatim)

Found by the release-tier run of S0023 on 2026-11-14 (`.\gradlew.bat :phone:testStoreDebugUnitTest :phone:testRestrictedDebugUnitTest :wear:testDebugUnitTest --continue`): one phone test is red in both flavors, 80 tests with 1 failure (store) and 84 tests with 1 failure (restricted). It is not part of S0023.

Test: `GatherSystemInfoUseCaseTest > invoke contains localized battery detail field headers`, `AssertionError at GatherSystemInfoUseCaseTest.kt:104`, message `summary must contain battery header 'Status'`.

Evidence read the same day: the test and `BatteryDetailsCollector` have not changed since the initial import (c12f2d4), so the test has been red since the tree was first run. Under Robolectric no sticky `ACTION_BATTERY_CHANGED` broadcast exists, so `GatherSystemInfoUseCase` takes its fallback at lines 279 and 331 and emits only `Level: unknown`; the headers Status, Current, Power, Battery saver, Capacity estimate, Charge time and Discharge time are never produced, and the test expects all eight.

Decision for the spec pass: give the test a battery broadcast (a shadow or a sticky intent registered in the Robolectric context) so it exercises the full path, or split it into the always-present header and the broadcast-dependent ones. Do not weaken the check silently.


## 1. Problem

The phone unit test that checks the battery field headers has been red since the first import of this tree.
Under the test runtime no battery broadcast is present, so the report takes its no-battery branch, which
carries the Level row and six battery rows marked as unavailable, but no Status row. The test expects eight
headers and stops at the first missing one, Status. Correction to the owner's evidence in section 0: that branch
does not emit only the Level row; re-read on 2026-11-14 it emits Level plus six unavailable rows, so Status is the
only one of the eight that is missing. The check stays as strict as it is. The test has to supply the battery
state that a device supplies.

## 2. Done criteria

Each criterion is a command to run or an observation to repeat, so that "done" is something the next
reader can check rather than something the author believes.

- `pwsh -NoProfile -File tools/harness.ps1 spec_catalog/validate` exits 0 after the status moves (fast tier).
- `pwsh -NoProfile -File tools/docs/check-docs.ps1` exits 0, or reports nothing beyond `tools/docs/baseline.txt` (this ticket file is in the corpus; fast tier).
- Observation, by reading the diff: the battery test still asserts the same eight `R.string` headers with the same message text; no assertion is removed or made optional.
- RELEASE item (not run between releases): `.\gradlew.bat :phone:testStoreDebugUnitTest :phone:testRestrictedDebugUnitTest --tests "com.sza.deviceinfo.domain.usecase.GatherSystemInfoUseCaseTest"` exits 0 with 0 failures; expected: `invoke contains localized battery detail field headers` passes in both flavors. Not built and not run until the release.

## 3. Approach

### 3.1 Scope

In: the phone unit test `GatherSystemInfoUseCaseTest`, one file, test-only. The test hands the use case and the
battery collector a context that answers the sticky battery lookup with a battery intent, so the full battery path
runs; the eight-header check and its message stay as they are.

Out: the use case, the battery collector, the string resources, the wear module, and the no-battery branch. The
no-battery branch also omits the Plug, Health, Temperature, Voltage and Technology rows and the extended battery
rows. That is a product-side observation, not changed here and not ticketed; the owner may decide whether it is a
defect.

### 3.2 Open questions

None open. The owner's either-or (a battery broadcast or a split) is settled under Assumed below.

### Assumed (unattended, 2026-11-14)

- **Taken:** the test supplies the battery broadcast through a test context that answers the sticky lookup of
  `ACTION_BATTERY_CHANGED` with a battery intent (level, scale, status, plugged, voltage). The eight-header check
  is unchanged. This runs the same battery path a device runs.
- **Alternative 1, not taken:** a Robolectric shadow for a sticky broadcast. Read from the public API of the pinned
  shadows-framework 4.16.1 with `javap`: `ShadowContextWrapper` exposes `getBroadcastIntents` and
  `getBroadcastOptions` and no sticky API, so this route needs more shadow work than a test-only change.
- **Alternative 2, not taken:** split the test into the always-present header and the broadcast-dependent ones.
  It drops the check of seven headers from the full path; the owner asked that the check not be weakened.
- **Compile:** `commands.compileCheck` is absent from `.sza-profile.json`, so this repository declares no compile
  command. The edit is not compiled in this pass.
- **Owner may overrule.**

### 3.3 Owner inputs (Approval gate)

- **Related tickets:** S0023 is the release-tier run that found this red and names S0037 as its known red; a mention, not a blocker.

## Last Audit

**Date:** 26-11-14 16:06 | **Mode:** static | **Outcome:** Verified (static); status stays Implemented
**Counts:** PASS 6 | WARN 0 | FAIL 0 | MANUAL 0 | UNCHECKABLE 0 | EXEMPT 0 | RELEASE 1

### Action items
1. None open between releases. The RELEASE item below closes at the release-tier run.

### Checks (this run)
- `pwsh -NoProfile -File tools/harness.ps1 spec_catalog/validate` - exit 0, expected OK | actual "Summary: 10 OK, 0 WARN, 0 FAIL".
- `pwsh -NoProfile -File tools/docs/check-docs.ps1` - exit 0, expected PASS | actual "docs-check: PASS (30 records, 90 corpus files, 74 Markdown, 7 links, 18 asset citations, 0 baselined)".
- `pwsh -NoProfile -File tools/harness.ps1 spec_catalog/release-queue -Validate` - exit 0, expected OK | actual "release-queue: OK - 40 ticket(s), no drift".
- Static read of the test diff: the battery test still asserts the eight battery headers (9 matches of the header
  resource names and the battery message in the file = 8 headers + 1 message); no assertion removed.
- Probe invariant: no `S0037` in `phone/src`; the ticket is not in a needs-manual-test status.
- Hygiene: no long dash or ellipsis in the test file or the ticket.

### Why Implemented and not Verified
The one behaviour check (the Robolectric run) is a RELEASE item and has not run. The scoring table would permit
Verified with a RELEASE item, but the test has not passed anywhere yet, so the ticket records Implemented until the
release-tier run shows 0 failures. Owner may overrule.

### RELEASE item
`.\gradlew.bat :phone:testStoreDebugUnitTest :phone:testRestrictedDebugUnitTest --tests "com.sza.deviceinfo.domain.usecase.GatherSystemInfoUseCaseTest"` - expected: exit 0, `invoke contains localized battery detail field headers` passes in both flavors. Not built and not tested until the release.
