# PACKAGE-VERSIONING - pointer

| Field | Value |
| --- | --- |
| **Id** | `PACKAGE-VERSIONING` |
| **Version read** | 0.8, draft (shared contracts catalog, `package-versioning/`, read 2026-11-13) |
| **Home** | shared contracts catalog, `package-versioning/` |
| **Owner** | FastMediaSorter Android |
| **Role here** | consumer - Android profile, two package families under one application id: the phone app and the watch app |

What this repository owes:

- **The profile (section 2, rules 1 to 8).** The Android profile: versionName `Y.YM.MDDH.Hmm` and a 9-digit versionCode `yyMMddHH * 10 + p` from one instant. The phone app owns band 0..5 of the last digit and the watch app band 6..9, because both install under one application id.
- **The sentinels (rules 6 and 7).** Until a release is stamped, debug builds carry a checked-in non-releasable pair for the instant `2611100000`: versionName `2.61.1100.000`, versionCode `261110000` (phone) and `261110006` (watch app), in the root `gradle.properties`. They never leave the developer's devices.
- **Built (S0008, 2026-11-13).** One Kotlin implementation, `buildSrc/src/main/kotlin/com/sza/deviceinfo/buildlogic/VersionStamp.kt`: the phone family takes band 0..5 in 10-minute slots, the watch family band 6..9 in 15-minute slots. Its fixed-instant vectors (`VersionStampTest`, section 4 rung 2) render the contract's own example `2609262322` as `2.60.9262.322` with the codes `260926232` (phone) and `260926237` (watch), prove the two bands disjoint for every minute, and read the checked-in sentinels from `gradle.properties` to prove they are the formula applied to their instant. The vectors are written and statically reviewed; they run at the release (`.\gradlew.bat -p buildSrc test`).
- **Who stamps (rules 5 to 7).** A debug invocation carries the sentinels, each held to the formula by `VersionStamp.sentinel`. An invocation that builds a release variant stamps itself from one clock reading, taken once on the root project so the two modules cannot straddle a minute (rule 6), or takes the pin (rule 5): three Gradle properties passed together or not at all - the versionName and one code per family, `deviceinfo.pin.*` in `gradle.properties` - each code checked against its own family's partition, so a code of one family can never reach the other.
- **The parity gate (rule 8).** `tools/release/check-version-parity.ps1` is the PowerShell implementation of the formula (`tools/release/VersionStamp.ps1`) held against the contract's vectors, the sentinels and the vectors the Kotlin test carries; it runs in under a second. `tools/release/new-version-pin.ps1` prints the pin and the tag for an instant, and `tools/release/read-package-info.ps1` reads a built package back (P5).
- **The registry row.** `PACKAGE-VERSIONING | DeviceInfo Android` exists (role C, Android profile, two families): added by the catalog owner with the fold of 0.7 on 2026-11-13, re-read at 0.8 on 2026-11-14 (S0025), verification `pending` until the vectors and the read-back run at the release.

Version steps since the pointer was last read (0.6, read 2026-11-10):

- 0.7 (2026-11-13, additive): this product's band table accepted into rule 3 - the phone `com.sza.deviceinfo` band 0..5 and the watch app `com.sza.deviceinfo` (shared id) band 6..9 registered before the first package ships. The proposal the pointer named as open is folded in; the bands the local formula implements are the contract's own.
- 0.8 (2026-11-13, additive): Filler Android's two families registered the same way - no rule text change and no duty change for this product.

Adoption state is recorded in the catalog registry (the row above); the register of everything this product consumes is `README.md` in this directory.
