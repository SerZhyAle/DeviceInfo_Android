# S0038_declare-compile-gate-and-fix-test-command

**Status:** Implemented
**Status note:** Compile check declared as commands.compileCheck and measured under the Build lock: exit 0, BUILD SUCCESSFUL in 10s, 10.2 s wall, a pass-level gate. Compiled, not tested: no compiled source edited; the unit tests and the compile after a larger source change are RELEASE items R1 and R2 of the audit. Audit Verified with RELEASE items open; the ticket stays Implemented.
**Created:** 2026-11-14
**Complexity:** light - one profile key, the phone test command in two documents, and one compile-only command measured at 10.2 s (a pass-level gate, not a fast-tier one)

## 0. Owner request (verbatim)

Found by the release-tier run of S0023 on 2026-11-14: the committed tree did not compile. `.\gradlew.bat :phone:assembleDebug :wear:assembleDebug` failed with three groups of errors that were already in HEAD: `kotlinx.coroutines.tasks.await` unresolved in phone `WearableDataLayerRepositoryImpl` and in wear `AndroidWearSystemInfoDataSource` and `AndroidWearSystemInfoReportSender` (no `kotlinx-coroutines-play-services` in the catalog or the module files, while the upstream FastMediaSorter declares it); `androidx.compose.material.icons` unresolved in wear `SystemInfoScreen` (no `material-icons-core`); and `@color/white` and `@color/black` not found for 20 phone vector drawables. The S0023 pass added the three missing catalog entries and the two colors (the minimum that lets the tree build); it did not judge or review the tickets that ported those files.

Cause: `.sza-profile.json` declares no `commands.compileCheck` and CLAUDE.md section 6 declares no compile-only command, so source from S0003 to S0024 accumulated with every ticket noting "compiled, not tested" and none ever meeting a compiler.

Second finding, same run: CLAUDE.md section 6 and `docs/UI_CONFORMANCE.md` name `.\gradlew.bat :phone:testDebugUnitTest`, which Gradle refuses as ambiguous because the phone module has the `distribution` flavors (candidates `testRestrictedDebugUnitTest` and `testStoreDebugUnitTest`). The working commands are `:phone:testStoreDebugUnitTest :phone:testRestrictedDebugUnitTest :wear:testDebugUnitTest`.

Wanted: declare a compile-only command in `.sza-profile.json` (`commands.compileCheck`) and in CLAUDE.md section 6 with its measured time (the full `assembleDebug` of both modules measured 67 s on 2026-11-14, so a compile-only form is to be measured, not assumed; if it is over 5 s it stays a pass-level gate, not a fast-tier one), and correct the phone test command in CLAUDE.md section 6 and the sentence about `testDebugUnitTest` there.


## 1. Problem

The committed tree did not compile when the release-tier run of S0023 built it on 2026-11-14: three groups of errors were already in the previous commit. The repository declared no compile-only command, so source written from S0003 to S0024 was reported as compiled-not-tested and never met a compiler. Separately, the phone unit-test command written in the project's verification section names a task that Gradle refuses as ambiguous under the phone's build flavors, so the documented command does not run. The owner wants a compile-only command declared and measured, and the test command corrected.

## 2. Done criteria

Each criterion is a command to run or an observation to repeat, so that "done" is something the next
reader can check rather than something the author believes.

- C1 - `.sza-profile.json` declares `commands.compileCheck` as a non-empty command. Check: `pwsh -NoProfile -File tools/harness.ps1 spec_catalog/validate` exits 0, and `(Get-Content .sza-profile.json -Raw | ConvertFrom-Json).commands.compileCheck` returns the command.
- C2 - the declared command exits 0 under the Build lock, and its wall time is written into CLAUDE.md section 6. Check: the exit code and the `BUILD SUCCESSFUL` line are cited in the audit block; CLAUDE.md section 6 holds the 2026-11-14 measurement. A compile after a larger source change is not measured here; it stays a release-tier item.
- C3 - CLAUDE.md section 6 no longer says that no compile-only command is declared. Check: `Select-String -Path CLAUDE.md -Pattern 'No compile-only command is declared'` returns no hit.
- C4 - no working command in CLAUDE.md section 6 or `docs/RELEASE.md` is the bare phone unit-test task; the remaining mentions say that it is ambiguous. Check: a search for `:phone:testDebugUnitTest` returns only those mentions.
- C5 - the internal documentation gate holds after the edits. Check: `pwsh -NoProfile -File tools/docs/check-docs.ps1` exits 0 and its last stdout line is the verdict line.
- C6 - RELEASE: the corrected phone and wear test commands run and report. Command: `.\gradlew.bat :phone:testStoreDebugUnitTest :phone:testRestrictedDebugUnitTest :wear:testDebugUnitTest`, under the Build lock. Not run in this pass; the same command ran on 2026-11-14 in the S0023 pass, and its record names one parked failure per phone flavor (`docs/UI_CONFORMANCE.md`).

## 3. Approach

### 3.1 Scope

In scope: the `commands.compileCheck` key of `.sza-profile.json`; section 6 of `CLAUDE.md` (the compile-only declaration with its measured time, the phone test command and its report directories, and the note on the fast filter); and `docs/RELEASE.md` step 2, which names the same stale phone test command.

Out of scope: any source, Gradle, resource or manifest edit; the compilation of the unit-test sources (the release-tier test run compiles them); the test runs themselves; `docs/UI_CONFORMANCE.md`, whose mention of the bare task explains the ambiguity and already names the working tasks; the historical ticket and archive records, which keep the commands they were written with; the canon's per-project record `rules/contrib/deviceinfo_mob.md` in the canon repository, whose CONFIRM line says that no compile command is declared. That record is stale after this ticket; a canon session re-syncs it, and this repository does not edit it.

Shared-contract boundary: none. The change declares this repository's own verification commands; no format, wire shape or algorithm is touched, so no catalog amendment is needed. Behaviour change (S0021): none; `docs/PARITY_MATRIX.md` is not touched.

### 3.2 Open questions

Each question is answered here, or handed to a `Carrier:` token naming the ticket that will answer it.
A ticket does not close while a question is neither.

- No question is open. The compile-only check covers the main Kotlin sources and the resource tasks of both modules, not the unit-test sources: decided under the assumptions below.
- The compile time after a larger source change is not measured here and is not assumed to be under 5 s. It is a release-tier item in CLAUDE.md section 6, not an open question, and no `Carrier:` token is needed.

### 3.3 Owner inputs (Approval gate)

- **Related tickets:** none

### Assumed (unattended, 2026-11-14)

- **Compile set:** the declared check compiles the main Kotlin sources of both modules, runs the resource tasks of each variant, and leaves out the unit-test sources. Alternative: add the unit-test compile tasks of both flavors. Owner may overrule. Reason: the cost of the gate; the test run compiles those sources itself; neither module has main Java sources, so no javac task is needed.
- **Second stale command:** `docs/RELEASE.md` step 2 names the same bare phone task, so it is corrected in the same edit. Alternative: leave it to a later ticket. Owner may overrule.
- **Flavored fast filter:** the fast-filter line now names the store flavor task, and its 2.3 s figure is marked as measured before the flavor split and not re-measured. Alternative: run the filter now. Not done: a second Gradle run is outside this pass, whose one Gradle run is the compile check.
- **Status:** the ticket stays `Implemented`, not `Verified`, while its RELEASE item is open. Alternative: `Verified` on the audit's zero-WARN, zero-FAIL verdict. Owner may overrule.

## Last Audit

**Date:** 26-11-14 16:12 | **Mode:** static | **Outcome:** Verified
**Counts:** PASS 5 | WARN 0 | FAIL 0 | MANUAL 0 | UNCHECKABLE 0 | EXEMPT 1 | RELEASE 2

### Checks (command, exit code, expected | actual)
- C1 - `pwsh -NoProfile -File tools/harness.ps1 spec_catalog/validate`, exit 0 | expected: no FAIL, profile declares `commands.compileCheck` | actual: `Summary: 10 OK, 0 WARN, 0 FAIL`, exit 0; the key reads back as the declared command.
- C2 - `.\gradlew.bat :phone:compileStoreDebugKotlin :phone:compileRestrictedDebugKotlin :phone:processStoreDebugResources :phone:processRestrictedDebugResources :wear:compileDebugKotlin :wear:processDebugResources --continue` under the Build lock, exit 0 | expected: `BUILD SUCCESSFUL` | actual: `BUILD SUCCESSFUL in 10s`, `61 actionable tasks: 10 executed, 51 up-to-date`, `compileCheck exit=0 wall=10.2s`.
- C3 - `Select-String` for `No compile-only command is declared` in CLAUDE.md | expected: 0 hits | actual: 0 hits.
- C4 - `Select-String` for `:phone:testDebugUnitTest` in CLAUDE.md and docs/RELEASE.md | expected: only the ambiguity notes | actual: CLAUDE.md:64 and docs/RELEASE.md:76, each stating that the bare task is ambiguous.
- C5 - `pwsh -NoProfile -File tools/docs/check-docs.ps1`, exit 0 | expected: verdict `PASS` | actual: `docs-check: PASS (30 records, 90 corpus files, 74 Markdown, 7 links, 18 asset citations, 0 baselined)`, exit 0.

### Action items
1. none - FAIL 0, WARN 0.

### Manual / on-target
- none. No user-visible behaviour changed and no device check is owed.

### RELEASE items
- R1 (C6): `.\gradlew.bat :phone:testStoreDebugUnitTest :phone:testRestrictedDebugUnitTest :wear:testDebugUnitTest` - the corrected test commands, not run in this pass. Not built, not tested until the release.
- R2: `.\gradlew.bat :phone:compileStoreDebugKotlin :phone:compileRestrictedDebugKotlin :phone:processStoreDebugResources :phone:processRestrictedDebugResources :wear:compileDebugKotlin :wear:processDebugResources --continue` - the declared compile check at the release start, after the release's source changes; the compile time after a larger source change is not measured here.

### EXEMPT
- The canon's per-project record `rules/contrib/deviceinfo_mob.md` (canon repository, outside this tree) still reads that no compile command is declared; a canon session re-syncs it.
