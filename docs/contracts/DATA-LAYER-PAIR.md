# DATA-LAYER-PAIR - declaration

| Field | Value |
| --- | --- |
| **Id** | `DATA-LAYER-PAIR` |
| **Status** | Internal wire boundary (DeviceInfo phone <-> wear) |
| **Scope** | Disjoint prefix `/deviceinfo/` |
| **Carrier** | S0005 |

The phone-to-watch Data Layer communication in DeviceInfo operates strictly within this product's shared `applicationId`. Both packages share one application id and one Data Layer pair.

Message paths:
- `/deviceinfo/watch/system_info_report`: watch -> phone report payload
- `/deviceinfo/phone/system_info_report_ack`: phone -> watch acknowledgement

Paths use the dedicated `/deviceinfo/` prefix to guarantee complete isolation from FastMediaSorter's `/fms/` and Tourist's `/tourist/` routes.

## Compatibility across package versions

Phone and watch packages update independently. The pair must keep working when either package is one release behind: the newer phone must accept the older watch's report, and the newer watch must accept the older phone's acknowledgement. Keep readers and regression fixtures for every previously written shape, and exercise both directions before release.

The report currently uses `formatVersion: 1`; the acknowledgement has no version field. Both sides pin JSON names with `@SerializedName`. Do not rename, remove, retype or change the meaning of an existing field. A compatible addition is optional and stays in version 1: older Gson readers ignore unknown fields, and newer readers must handle that field's absence. The current optional acknowledgement field `reason` defaults to `null` when absent. The version 1 report's existing fields, including `formatVersion`, remain required on the wire.

Gson constructs these classes without applying their Kotlin constructor defaults: an absent reference is `null`, and an absent primitive is `0` or `false`. A future optional field may rely on those values only if they are its intended safe defaults; any other default needs explicit decoding and tests. In particular, the Kotlin `FORMAT_VERSION` constructor default does not make an absent wire version equal to 1. Never depend on a missing required field becoming a valid value.

A phone currently refuses a report with an unknown `formatVersion`. A new incompatible report version therefore needs a receiver that retains the version 1 reader **and** a sender/negotiation strategy that still sends version 1 to an older phone; incrementing the constant alone breaks mixed-version pairs. The unversioned acknowledgement must remain backward compatible, or gain an explicitly compatible negotiation scheme. Tests must retain the previous fixtures and cover unknown fields and each newly introduced missing-field default.

The frozen version 1 report and acknowledgement fixtures are in `phone/src/test/resources/data-layer/v1/`. Both modules' `WearSystemInfoReportCodecTest` classes read them. `WearSystemInfoReportPayloadParityTest` compares the phone and wear source declarations for report and acknowledgement fields, JSON names, types, nullability, constructor defaults and the format constant; unrecognized declaration syntax or instance properties outside the constructors fail the check instead of being skipped.

Prefix settled against the upstream (2026-11-13, S0016, read-only checkout `P:\ANDROID\FastMediaSorter_mob_v2`): FastMediaSorter's own Data Layer paths files - `app_v2/src/main/java/com/sza/fastmediasorter/service/WearDataLayerPaths.kt` and `wear/src/main/java/com/sza/fastmediasorter/wear/data/wear/WearDataLayerPaths.kt` - carry every route under `/fms/`, including `SYSTEM_INFO_REPORT = "/fms/watch/system_info_report"` and `SYSTEM_INFO_REPORT_ACK = "/fms/phone/system_info_report_ack"`. No `/fastmediasorter/` route prefix exists upstream; where S0007 wrote one, S0016 corrected it.
