# Reverse-port baseline - 2026-11-14

This is the first local destination baseline. The destination hashes in `port-ledger.jsonl` were computed on
2026-11-14 from the files present that day; they are not the bytes or a history recovered from the original port.
Consequently a clean local-divergence check only covers changes after that baseline. It cannot establish that every
older difference was found. The entries below classify the known product-specific features, based on their ticket
records and a fresh comparison of the named source files. They do not claim device or release-test proof.

| Feature or change | Classification | Basis and source action |
| --- | --- | --- |
| Restricted and store variants, seven extended diagnostics sections (S0009) | deliberate | The standalone product's packaging and distribution choice; `ExtendedDiagnostics.kt` and `GatherSystemInfoUseCase.kt` document the distinction. FastMediaSorter already has its own `noLegal` contributor, so its flavor structure is not a reverse port. |
| S0010 sensor, media/audio, battery, camera and benchmark additions | not applicable except the next row | S0010 carries FastMediaSorter S4543; S0013 subsequently carries upstream changes. The source already supplies those ported metrics. |
| S0010 step-counter presence in the key-sensor summary | candidate for FMS_A | `SensorsDiagnosticsCollector.kt` has the adjacent KDoc and `TYPE_STEP_COUNTER` presence check; the current upstream equivalent lacks that entry. Tracked as `RP-0001`. It reports presence, not a live activity reading. |
| S0011 notification explanation, request and settings recovery | candidate for FMS_A | The source watch-report receiver refuses when notifications are off; DeviceInfo adds a recovery flow. FastMediaSorter has other notification-permission flows, so whether and where it needs this change is an investigation in `RP-0002`, not a claim that the source has no such flow anywhere. |
| Independent app ids, activity/application entry points, Hilt wiring and the `/deviceinfo/` Data Layer namespace | deliberate | Standalone isolation is a product decision; the local `WearDataLayerPaths.kt` KDoc records the namespace difference. FastMediaSorter keeps its own identity and namespace. |
| S0017 phone payload constructor default and source parity test | not applicable | The local default mirrors the watch source declaration; the JSON wire shape remains version 1 and Gson does not use the Kotlin default during parsing. This is not a user-visible change to carry as a function. |
| Standalone support code without ledger rows | not applicable except S0011 above | App and screen scaffolds, local logging and notification ids/icons, the DeviceInfo Data Layer repository and paths, `ViewExtensions`, and the watch refusal helper are product-specific integration; the notification coordinator, policy and store are covered by `RP-0002`. New standalone-only features still need a feature-level review: the file hash checker only watches ledger destinations. |

`reverse-port-notices.jsonl` is the durable notice store. `open` means recorded here, not filed with FMS_A. The owner
orders the FMS_A capture separately. Once the owner supplies the resulting `fms-a:Sxxxx` id, a notice can be marked
`handed-over`, then `accepted` or `declined`; retain the source ticket id and the reason for a decline in that record.
The catalog's FUNCTION-PARITY 0.1 rules 4 and 5 describe the target function-level flow; the register itself and this
product's columns are handled separately by S0021 and S0025.
