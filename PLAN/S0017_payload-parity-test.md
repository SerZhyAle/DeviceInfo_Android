# S0017_payload-parity-test

**Status:** Implemented
**Status note:** Parity gate and version 1 compatibility tests implemented; Gradle builds and codec suites await release.
**Created:** 2026-11-13
**Complexity:** medium - assessed during implementation: two mirrored wire models, a source gate, two codec suites and a mixed-version compatibility rule

## 0. Owner request (verbatim)

Owner's positions and order, 2026-11-13, verbatim (chat, Russian):

Positions:
"Так.
Идея этого приложения была чтобы весь функционал по суб-программы Device Infoна телефоне (любом андроид устройстве), часах , который реализован в FMS_A был представлен в виде самостоятельных приложений android,  которые могут заинтересовать пользователя, которому не интересен весь остальной функционал FMS_A
Но при этом эти приложения не только выглядят более-менее одинаково, но и развиваются вместеи новый/исправленный функционал обновляется/исправляется в них паралельно, они пересекаются по документации, принадлежат общему семейству программ и связаны канонами и контрактами.
Исследуй всё ли верно в моих мположениях?"

Order:
"Создай такие спецификации в рамках этого продукта, которые приведут его к вышеописанному заказанному состоянию"

Correction order, 2026-11-13, verbatim (chat, Russian), given after these tickets were captured:
"правильно ли я понял, что по производству всех заказаных задач
это приложение будет иметь весь функционал по соответствующей суб-программы телефона (любом андроид устройстве), часах , который реализован в FMS_A был представлен в виде самостоятельных приложений android,  которые могут заинтересовать пользователя, которому не интересен весь остальной функционал FMS_A
Но при этом эти приложения будут выглядеть более-менее одинаково, развиваться вместе и новый/исправленный функционал обновляется/исправляется в них паралельно, они пересекаются по документации, принадлежат общему семейству программ и связаны канонами и контрактами.
Поправь спецификации чтобы было именно так"

This ticket's problem and done criteria (sections 1 and 2) were written from that message. The acceptance of the whole set is ticket target-state-acceptance (S0027).

Twelve tickets were captured by the two orders: bugfix-contract-pointers-stale (S0016), payload-parity-test (S0017), upstream-new-file-inventory-check (S0018), reverse-port-divergence-ledger (S0019), ship-together-surfaces-manifest (S0020), phone-wear-feature-parity-matrix (S0021), phone-wear-visual-identity (S0022), unified-ui-conformance-evidence (S0023), in-app-help-phone-and-wear (S0024), register-product-in-contract-catalog (S0025), canon-resync-stamp (S0026), target-state-acceptance (S0027).

Agent findings below are not the owner's words. They come from the investigation of 2026-11-13; every fact cites the file it was read from.

Position this ticket serves: "развиваются вместе .. паралельно" (phone and wear).

Problem: the phone and the wear package share one application id and one Data Layer pair but no source, so the wire payload exists twice and nothing compares the two copies.

Evidence (read 2026-11-13):
- WearSystemInfoReportPayload: phone/src/main/kotlin/com/sza/deviceinfo/domain/model/ and wear/src/main/kotlin/com/sza/deviceinfo/wear/data/wear/. Each side has its own WearSystemInfoReportCodecTest (`phone/src/test/.../domain/model`, `wear/src/test/.../data/wear`).
- The only test that compares the two modules is WearDataLayerPathsParityTest (`phone/src/test/.../service`), and it covers the two path strings only. CLAUDE.md section 7 states "change the payload on both sides in the same edit" - a discipline, not a gate. No test that compares the two payload copies was found.
- The field names are the wire format (Gson reflects over them; proguard-rules.pro of each module keeps the classes whole).
- The two packages are installed from one Play listing but update independently on a phone and a watch, so a phone at version N can meet a watch at N-1. No rule for that mismatch is written down in docs/contracts/DATA-LAYER-PAIR.md.

Wanted:
1. A test that fails when the two payload copies diverge - field names, types, nullability, defaults - in the style of WearDataLayerPathsParityTest (parse both sources) or with one golden JSON fixture that both codec tests encode and decode; the plan pass picks one and says why. The test also covers the ack message if it has a payload.
2. The compatibility rule between package versions of the pair (unknown fields ignored, missing fields defaulted, a version field if the plan finds one is needed), written in docs/contracts/DATA-LAYER-PAIR.md and held by a test that decodes a payload of the previous shape.
3. CLAUDE.md section 7 updated to name the new gate next to the paths parity test.

The suite runs in the release tier (:phone:testDebugUnitTest, :wear:testDebugUnitTest); the ticket records the exact commands and anything that can run in 5 seconds or less.


## 1. Problem

The phone app and the watch app talk over a message format that is written out twice, once in each app. Nothing checks that the two copies agree, and nothing says what happens when one app is updated before the other. The owner wants the two apps to develop together; for this wire that has to be mechanical, not a habit.

## 2. Done criteria

Each criterion is a command to run or an observation to repeat, so that "done" is something the next
reader can check rather than something the author believes.

- A test of the repository fails when one copy of the payload changes (a field renamed, retyped or made nullable) and the other does not; the ticket shows the failing run against a throw-away copy of the sources, never the tree, and the passing run on the tree.
- A payload of the previous shape decodes on both sides in a test (an older watch against a newer phone and the reverse).
- docs/contracts/DATA-LAYER-PAIR.md states the rule for two apps of different versions; CLAUDE.md section 7 names the new test beside WearDataLayerPathsParityTest.
- Commands and measured times are recorded; whatever runs longer than 5 seconds is a RELEASE item with its exact command.

## 3. Approach

### 3.1 Scope

The implementation uses a source-declaration comparison rather than relying only on a golden JSON round trip: a JSON fixture alone does not expose Kotlin nullability or constructor defaults. `WearPayloadParity.java` is the single fail-closed comparison, called by `WearSystemInfoReportPayloadParityTest` and also runnable in Java source-file mode in the fast tier. It compares both `WearSystemInfoReportPayload` and `WearSystemInfoReportAck`: Kotlin and `@SerializedName` names, types, nullability, default expressions and `FORMAT_VERSION`. Unexpected syntax, duplicate fields and instance properties in class bodies fail rather than being silently skipped. The unit test also mutates the input strings to exercise one-sided drift.

The phone copy's `formatVersion` constructor default now matches the watch's `FORMAT_VERSION`; its KDoc records the deliberate difference from the upstream phone copy. This changes a Kotlin call-site default, not the version 1 JSON shape. Gson does not apply that default when a field is absent.

`phone/src/test/resources/data-layer/v1/report.json` and `ack.json` freeze the pre-ticket version 1 wire shape. The two codec suites read the same fixtures, check both objects on both sides, check unknown fields, and check the omitted optional acknowledgement reason. The phone exercises the report parser and acknowledgement writer; the watch exercises the report writer and acknowledgement reader. No package has shipped yet, so version 1 is the actual prior shape in source, not a fixture captured from an installed release. The codec tests are written but await the release-tier run.

`docs/contracts/DATA-LAYER-PAIR.md` states the N/N-1 duty: additive optional fields in version 1, safe defaults explicitly handled, retained old readers and fixtures, and a sender/negotiation strategy before an incompatible report version. The acknowledgement has no version; changing it incompatibly requires a compatible negotiation scheme. No new version field is needed for these additive changes. `CLAUDE.md` sections 6 and 7 and `docs/RELEASE.md` name the gate; no shared catalog contract or user-facing text changes.

### 3.2 Open questions

None. The existing report version is sufficient for the current additive-only format; a new incompatible format needs negotiation and old readers before it can ship.

### 3.3 Owner inputs (Approval gate)

- None.
- **Related tickets:** none

## Blocked tickets

Tickets waiting on this one (TASK-FLOW rule 69). The status tools write a line when a ticket enters
`BlockByOtherTask` and close it when that ticket is released; a moved status of this ticket triggers the check.

- Blocks: S0027 | was: Draft | since: 2026-11-14

## Last Audit

**Date:** 26-11-13 | **Mode:** fast and static | **Outcome:** Implemented; release-tier codec proof remains open
**Counts:** PASS 7 | WARN 1 | FAIL 0 | MANUAL 0 | UNCHECKABLE 0 | EXEMPT 2 | RELEASE 3

- PASS - On the source tree, `java phone/src/test/java/com/sza/deviceinfo/service/WearPayloadParity.java phone/src/main/kotlin/com/sza/deviceinfo/domain/model/WearSystemInfoReportPayload.kt wear/src/main/kotlin/com/sza/deviceinfo/wear/data/wear/WearSystemInfoReportPayload.kt`: exit 0, `PASS: report and ack fields and format version match`, 1.20 s (JDK 21).
- PASS - The Java test sources were compiled independently and the parity JUnit test was run without Gradle using the reproducing commands below: exit 0, `OK (2 tests)`, 0.93 s including compilation. This is the source-parity JUnit test, not the Kotlin codec suites.
- PASS - Six throw-away watch-source copies changed the JSON name, Kotlin name, type, nullability, acknowledgement default or format constant. The compiled source gate returned the expected exit 1 and `does not match` for every copy in 0.24-0.32 s; no source file in the tree was mutated. The reproducing source-file command below returned exit 1 with `deviceModel:String?` on wear versus `deviceModel:String` on phone, 0.69 s. The equivalent acknowledgement-default mutation returned exit 1 with `reason:String?="unknown"` versus `reason:String?=null`, 0.60 s.
- PASS - The version 1 fixtures were parsed with `ConvertFrom-Json -AsHashtable`: exit 0, `PASS: version 1 fixture keys, version and omitted optional reason`, 0.10 s. The report has the eight original field names and format 1; the acknowledgement has `requestId` and `accepted` and omits `reason`. This check does not execute the Kotlin codecs.
- PASS - `rg -n 'S0017|DATA-LAYER-PAIR|WearSystemInfoReportPayloadParityTest|Payload parity' CLAUDE.md docs/RELEASE.md docs/contracts/DATA-LAYER-PAIR.md PLAN/S0017_payload-parity-test.md`: exit 0; the contract and repository instructions name the pair rule and the new gate.
- PASS - `pwsh -NoProfile -File tools/harness.ps1 spec_catalog/validate`: exit 0, 9 OK and 1 unrelated complexity warning, 0.98 s. `pwsh -NoProfile -File tools/harness.ps1 spec_catalog/release-queue -Validate`: exit 0, `release-queue: OK - 30 ticket(s), no drift`, 0.85 s.
- PASS - `pwsh -NoProfile -File C:/Users/serzh/.claude/plugins/cache/sza-unified-rules/sza/2026.1113.8/tools/check-compliance.ps1`: exit 0, `0 error(s), 2 warning(s)`, 0.79 s.
- WARN - The compliance gate's two warnings concern the stale canon stamp and an archived ticket naming the catalog by path; they are outside S0017. The catalog validator also reports two unrelated captured complexity lines.
- EXEMPT - Device/emulator testing: this ticket adds a source gate and compatibility unit tests; end-to-end device scenarios belong to S0007.
- EXEMPT - User-facing surfaces and changelog: the wire shape and product behaviour are unchanged.
- RELEASE - Build the changed Kotlin: `.\gradlew.bat :phone:assembleDebug :wear:assembleDebug` under the Build lock. No compile-only command is declared, and a source-change build is not known to take 5 seconds or less. Not built.
- RELEASE - Run the phone suite, including the version 1 codec tests and the parity JUnit gate: `.\gradlew.bat :phone:testDebugUnitTest` under the Build lock. Not run: release tier.
- RELEASE - Run the watch suite, including version 1 report/ack decoding and encoding: `.\gradlew.bat :wear:testDebugUnitTest` under the Build lock. Not run: release tier. Until these two suites run, compatibility of the actual Kotlin codecs is not proven.

To reproduce the independent Java parity JUnit run with the cached JUnit and Hamcrest jars:

```powershell
$cache = Join-Path $env:USERPROFILE '.gradle/caches/modules-2/files-2.1'
$junit = Join-Path $cache 'junit/junit/4.13.2/8ac9e16d933b6fb43bc7f576336b8f4d7eb5ba12/junit-4.13.2.jar'
$hamcrest = Join-Path $cache 'org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar'
$classes = Join-Path (Join-Path 'temp' 'S0017') 'classes'
New-Item -ItemType Directory -Force -Path $classes | Out-Null
javac -encoding UTF-8 -cp $junit -d $classes phone/src/test/java/com/sza/deviceinfo/service/WearPayloadParity.java phone/src/test/java/com/sza/deviceinfo/service/WearSystemInfoReportPayloadParityTest.java
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
java -cp "$classes;$junit;$hamcrest" org.junit.runner.JUnitCore com.sza.deviceinfo.service.WearSystemInfoReportPayloadParityTest
```

Expected: exit 0, `OK (2 tests)`. To reproduce a failed run from a fresh throw-away copy:

```powershell
$scratch = Join-Path 'temp' 'S0017'
$changed = Join-Path $scratch 'nullability.kt'
New-Item -ItemType Directory -Force -Path $scratch | Out-Null
$wearSource = Get-Content -Raw -LiteralPath wear/src/main/kotlin/com/sza/deviceinfo/wear/data/wear/WearSystemInfoReportPayload.kt
$wearSource.Replace('val deviceModel: String', 'val deviceModel: String?') | Set-Content -NoNewline -Encoding utf8 -LiteralPath $changed
java phone/src/test/java/com/sza/deviceinfo/service/WearPayloadParity.java phone/src/main/kotlin/com/sza/deviceinfo/domain/model/WearSystemInfoReportPayload.kt $changed
```

Expected: exit 1 and `WearSystemInfoReportPayload does not match`. Use the source-tree command in the first PASS line for the passing run.

### Action items

1. At release, run the three RELEASE commands above and retain their output and exit codes.
