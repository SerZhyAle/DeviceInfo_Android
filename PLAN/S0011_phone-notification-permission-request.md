# S0011_phone-notification-permission-request

**Status:** BlockNeedUserTest
**Status note:** no compile command, not built, not tested until the release; device check owed: fresh Android 13+ install shows the notification explanation, system prompt, refusal snackbar and the Turn on notifications menu entry (Manual in Last Audit)
**Created:** 2026-11-13
**Complexity:** medium (rewritten at the spec pass 2026-11-13, confirmed against the plan) - one phone screen gains a run-time permission flow (a pure policy, a preferences store, one coordinator, one menu item), resources in three locales, the permission inventory row and the three hosted privacy pages; no shared contract, no schema, no new screen, no wire change

## 0. Owner request (verbatim)

Found at S0008 (2026-11-13, release preparation, static reading of phone/src/main).

The phone app declares POST_NOTIFICATIONS and WearSystemInfoReportReceiver posts the "Watch report received" notification, but no code of the phone module requests the permission at run time (no requestPermissions, no ActivityResult launcher, no rationale; grep of phone/src/main for POST_NOTIFICATIONS finds the manifest line and one log message only). On Android 13 and later (targetSdk is 36) a fresh install has notifications off for the app, so WearSystemInfoReportReceiver.store() sees areNotificationsEnabled() == false, keeps the report but answers the watch with accepted = false and the reason notifications_off, and the watch shows "Phone notifications are off. Turn them on and try again" with no in-app way to do it. The headline flow Send to phone from the watch therefore fails on every fresh install on Android 13+ until the user finds the system notification settings alone.

Open for the spec pass: where and when the app asks (a plain-language rationale before the system prompt, at the first launch of the phone app or when the first watch report arrives), what the phone does after a refusal (a link to the app's notification settings), the three-locale strings, and the permission inventory row in docs/SECURITY_INVENTORY.md that today says "not requested at run time". Upstream FastMediaSorter is read-only; check how it asks before deciding.


## 1. Problem

On a fresh install on Android 13 or later the phone app has notifications switched off, and nothing in the app lets the user switch them on. The watch's **Send to phone** is therefore refused every time ("Phone notifications are off"), and the only way out is for the user to find the phone's system notification settings alone. The phone app must ask for the notification permission itself, at a moment the user can understand, say in plain words why it asks, and after a refusal keep a one-tap way to the app's notification settings, so that the headline flow of the watch works on a fresh install.

## 2. Done criteria

- **D1 - the policy is decided once, in a pure function.** `NotificationPromptPolicy` answers, from the SDK level, whether notifications are enabled and what was already asked: show the explanation when the screen opens, show the menu entry, and which action the menu entry runs. Checked by `NotificationPromptPolicyTest` (static count of `@Test`; run at the release).
- **D2 - the first open explains, then asks.** On Android 13 or later with notifications off, the first time the System information screen has rendered, a dialog explains in three locales why the app wants notifications, with **Continue** (opens the system permission prompt) and **Not now**. It appears once: both buttons and a back-press cancel record it, a rotation while it is open does not. Checked by reading `NotificationPermissionCoordinator.onScreenShown` and the policy test; the on-device run is MANUAL.
- **D3 - a refusal leaves a way back.** After the system prompt is answered with a refusal, a snackbar says notifications are off and the watch cannot send reports, with a **Settings** action that opens the app's notification settings; the toolbar menu keeps a **Turn on notifications** entry while notifications are off. The entry opens the system prompt when it was never answered (Android 13+) and the app's notification settings otherwise (also on Android 12 and earlier, where no run-time permission exists). Checked statically; on-device MANUAL.
- **D4 - nothing nags.** No dialog appears when notifications are already on, below Android 13, after the explanation was answered once, or after the system prompt was answered. The menu entry is hidden while notifications are on, and refreshed on every resume so a return from the system settings hides it. Checked by the policy test and `refreshMenu` in `onResume`.
- **D5 - one source of truth, every surface.** `docs/SECURITY_INVENTORY.md` row `POST_NOTIFICATIONS` no longer says "not requested at run time"; the hosted privacy pages (en, ru, uk), the changelog and the phone strings (`values`, `values-ru`, `values-uk`) say the same thing in one edit. Checked by grep: `Parked as S0011` and `Not requested at run time` do not occur for `POST_NOTIFICATIONS`; every new string key is present in all three locale files.
- **D6 - no wire change, no new permission.** `WearSystemInfoReportReceiver`, the Data Layer paths and payloads, and both manifests are unchanged (`POST_NOTIFICATIONS` is already declared). Checked by inspection: those files are not in the edit list.
- **D7 - the compile gate.** `.sza-profile.json` declares no `commands.compileCheck`, so no compile command is declared; the note says "no compile command", and the build and the unit tests are RELEASE items (`.\gradlew.bat :phone:assembleDebug :wear:assembleDebug`, `.\gradlew.bat :phone:testDebugUnitTest`).

## 3. Approach

### 3.1 Scope

In: the phone module's System information screen (it is the only screen; `MainActivity` redirects to it); a preferences store for two flags; a pure policy; one coordinator owning the launcher, the dialog and the snackbar; one overflow menu item; strings in three locales; the inventory row, the three privacy pages and the changelog.

Out: the receiver and the ack (`accepted = false`, reason `notifications_disabled` stays: it is the truth when the user declines); the watch's wording (Assumed 4); a notification channel settings screen of the app (the system's is used); any other permission; the restricted flavor (it inherits the screen).

Why the screen and not the receiver: the receiver runs in a listener service with no Activity and cannot show a prompt; the upstream does the same (FastMediaSorter asks for `POST_NOTIFICATIONS` only inside the screens that need it, and links to `ACTION_APP_NOTIFICATION_SETTINGS` from a settings button, `PlaybackSettingsFragment`; its wear app records "asked once" and asks on the first phone command it handles while the app is open, `AskNotificationPermissionEffect`, S1961). DeviceInfo's phone has one screen, so the first open is the moment the user is in the app and knows why it exists.

### 3.2 Open questions

None open. The choices below were each taken as a researched, ticket-reversible default; see `### Assumed (unattended, 2026-11-13)`.

### 3.3 Owner inputs (Approval gate)

None required. The on-device run of the flow (a fresh install on an Android 13 or later device, and a watch for the end-to-end send) is a post-implementation manual check, listed in `## Last Audit`.

- **Related tickets:** S0007 (the parity and device check carries the on-device run of this flow), S0008 (found it; the release surfaces it touches are the privacy pages and the changelog). Neither blocks this ticket.

### Assumed (unattended, 2026-11-13)

Each was taken as a researched, ticket-reversible choice; the owner may overrule any of them.

1. **Ask at the first open of the phone app, with an explanation dialog first.** Taken: after the first render of the System information screen, an explanation, then the system prompt. Alternative: ask when the first watch report arrives. Rejected because that moment has no Activity (the receiver is a service), and the watch's first send would already have failed. Owner may overrule.
2. **The explanation is skippable and shown once.** Taken: **Not now** records it and the screen never raises it again by itself; the menu entry stays. Alternative: ask on every open until answered. Rejected as nagging; a user who declined once has said so. Owner may overrule.
3. **The menu entry sits in the overflow and exists only while notifications are off.** Taken: `showAsAction="never"`, hidden while notifications are on. Alternative: an always-visible toolbar icon, or a persistent banner above the list. Rejected: the toolbar already carries four actions and the banner needs a layout change in portrait and landscape. Owner may overrule.
4. **The watch's refusal text is left unchanged.** Taken: "Phone notifications are off. Turn them on and try again" stays as it is; it is the wear module and no flow of this ticket needs it. Alternative: name the phone app in it ("open DeviceInfo on the phone"). A wording change in the wear module and its two locale files, owned by a separate decision. Owner may overrule.
5. **No Settings fallback chain beyond one.** Taken: `ACTION_APP_NOTIFICATION_SETTINGS` for the app, and `ACTION_APPLICATION_DETAILS_SETTINGS` when no activity answers it. Alternative: also handle a missing application-details screen with a toast. The second intent exists on every Android build the app supports (minSdk of the module); a failure is logged. Owner may overrule.

## Plan (2026-11-13)

Coverage inventory (every goal, constraint and criterion to a phase):

| Line | Phase |
| --- | --- |
| Where and when the app asks (first open, explanation first) | A policy, B coordinator, C screen wiring |
| What the phone does after a refusal (settings link) | B coordinator, C menu item |
| Three-locale strings | D resources |
| Permission inventory row, privacy pages, changelog | E surfaces |
| Upstream check | done at the spec pass (3.1) |
| Receiver, paths, payload, manifests untouched | out-of-scope: no edit, D6 |
| Watch wording | out-of-scope: Assumed 4 |

Topology (no phase consumes what a later one produces): A produces `NotificationPromptPolicy` and the store; B consumes A, produces `NotificationPermissionCoordinator`; C consumes B and D's resource ids; D produces the string keys and the menu id; E consumes nothing of the code. Phase order D, A, B, C, E keeps every consumed symbol defined first.

- **D. Resources.** `menu_system_info.xml` gains `action_system_info_notifications` (overflow); `strings_systeminfo.xml` in `values`, `values-ru`, `values-uk` gain `notifications_prompt_title`, `notifications_prompt_message`, `notifications_prompt_continue`, `notifications_prompt_later`, `notifications_denied_message`, `notifications_open_settings`, `sysinfo_action_notifications`. Check: each key occurs once per locale file; the menu id occurs in the menu and in `SystemInfoWindowManager`.
- **A. Policy and store.** `data/local/preferences/NotificationPromptStore.kt` (interface, `SharedPreferencesNotificationPromptStore`, two flags: `explained`, `systemPromptAnswered`), bound in `SystemInfoModule`; `ui/systeminfo/helpers/NotificationPromptPolicy.kt` (pure). Check: symbols declared; the binding exists.
- **B. Coordinator.** `ui/systeminfo/helpers/NotificationPermissionCoordinator.kt`: `bind(activity)` registers the `RequestPermission` launcher, `onScreenShown(activity)`, `onMenuAction(activity)`, `refreshMenu(binding)`, the dialog, the snackbar, the settings intent with its fallback. Check: symbols declared.
- **C. Screen wiring.** `SystemInfoWindowManager` injects the coordinator, binds it in `bind`, routes the menu id in `onAction`; `SystemInfoActivity` calls `onScreenShown` after the first render and `refreshMenu` in `onResume`. Status-bound probes `Timber.d("S0011: ..")` at the flow entries (the last code edits). Check: grep the call sites.
- **E. Tests and surfaces.** `NotificationPromptPolicyTest` in `phone/src/test`. `docs/SECURITY_INVENTORY.md`, `site/privacy.html`, `privacy-ru.html`, `privacy-uk.html`, `CHANGELOG.md`. Check: grep as in D5.

Plan self-review: every inventory line maps to a phase or an out-of-scope reason; every symbol a phase consumes is declared in an earlier phase of the order D, A, B, C, E; every step ends in a static check.

## Last Audit

**Date:** 26-11-13 | **Mode:** static | **Outcome:** Partial
**Counts:** PASS 11 | WARN 0 | FAIL 0 | MANUAL 1 | UNCHECKABLE 0 | EXEMPT 1 | RELEASE 2

Evidence, each run fresh in this pass (expected | actual):

1. D1, the policy: declarations `shouldExplainOnOpen`, `isMenuEntryVisible`, `menuAction` in `NotificationPromptPolicy.kt` | 3 found, one each; `NotificationPromptPolicyTest.kt` | 9 `@Test` (static count, not run). PASS (the run is item 8).
2. D2, explain once: `NotificationPermissionCoordinator.onScreenShown` reads the policy with `store.explained` and `store.systemPromptAnswered`, shows the dialog, and sets `explained` in the Continue handler, the Not now handler and `setOnCancelListener`; a rotation dismisses the dialog through the lifecycle observer without setting it. `SystemInfoActivity` calls `onScreenShown` after the first render. PASS statically; the device run is item 13 (MANUAL).
3. D3, refusal: `onSystemPromptAnswered` stores the answer, refreshes the menu and shows the snackbar with a Settings action on a refusal; `onMenuAction` sends to the system prompt or `openNotificationSettings`, which falls back to `ACTION_APPLICATION_DETAILS_SETTINGS` on `ActivityNotFoundException`. `SystemInfoWindowManager.onAction` routes `R.id.action_system_info_notifications`. PASS statically.
4. D4, no nagging: the five policy rules (below Android 13, already on, explained, answered, menu hidden while on) are the cases of the nine tests; `SystemInfoActivity.onResume` calls `SystemInfoWindowManager.onResume`, which calls `refreshMenu`. PASS.
5. D5, surfaces: `Select-String 'Parked as S0011|Not requested at run time'` over `docs/SECURITY_INVENTORY.md` and `site/privacy*.html` | 0 hits; 7 string keys x 3 locale files, each exactly once; `values`, `values-ru`, `values-uk`, the menu and both manifests parse as XML. The inventory row, the three privacy pages (permission row and the stored-data bullet, since the app now keeps a second flag), the manifest comment and `CHANGELOG.md` say the same thing. `docs/play/PLAY_DATA_SAFETY.md` and `PLAY_LISTING.md` need no change (no data collected or shared; the runtime permission is the one they already name). PASS.
6. D6, no wire change: `WearSystemInfoReportReceiver.kt`, `WearDataLayerPaths.kt`, the payload and ack classes, and `phone/src/main/AndroidManifest.xml` permissions | not in the edit list; the manifest changed in one comment only. PASS.
7. D7 and compile: no `commands.compileCheck` in `.sza-profile.json`, so no compile command is declared; this pass edited compiled source (Kotlin, resources, menu) and ran none. Compiled: no. RELEASE: `.\gradlew.bat :phone:assembleDebug :wear:assembleDebug` under the Build lock (Hilt and KSP see the new `@Binds` and the injected coordinator).
8. Tests: not run. RELEASE: `.\gradlew.bat :phone:testDebugUnitTest` (9 new tests; the shared suite now runs once per flavor).
9. Fast tier: `spec_catalog/validate` | exit 0, "Summary: 10 OK, 0 WARN, 0 FAIL" (812 ms); `spec_catalog/release-queue -Validate` | exit 0, "13 ticket(s), no drift" (760 ms); canon compliance gate | exit 0, 0 errors, 1 warning `SZA-CANON03` (stale adoption stamp, present before this ticket, known). PASS.
10. Probe invariant: the ticket sits at `BlockNeedUserTest` and three lines `Timber.d("S0011: ..")` are in `NotificationPermissionCoordinator` (the explanation, the menu tap, the system answer). PASS (they are deleted when the ticket leaves that status).
11. Scope purity: every edit lies in plan phases D, A, B, C, E; the only addition beyond the plan is the stored-data bullet of the privacy pages and the matching manifest comment, which the second preference flag made necessary (invariant 14). Nothing outside scope found; nothing parked. PASS.
12. Phase-boundary pass (P0/P1 by reading): no main-thread I/O beyond the `SharedPreferences` read the existing `CollapsibleSectionStore` also does; the dialog is dismissed and the launcher released in `onDestroy`; the launcher is registered in `onCreate` through `bind`. No P0 or P1 found. PASS.
13. Persona and reach: the explanation says in plain words what the notification is for, has a skip, and a refusal leaves a one-tap path to the settings; `minSdk` 26, `targetSdk` 36, ABIs, countries and age rating are untouched. PASS.
14. Contract boundary: no shared contract read or written by this change (Data Layer path and payload untouched). EXEMPT.
15. The headline flow (a fresh Android 13+ install, Send to phone from the watch accepted) needs a device and a paired watch: see Manual. MANUAL.

### Action items

1. First compile of the new Kotlin - `NotificationPermissionCoordinator.kt`, `NotificationPromptPolicy.kt`, `NotificationPromptStore.kt`, `SystemInfoModule.kt`, `SystemInfoWindowManager.kt`, `SystemInfoActivity.kt` - checked by static inspection only; the release-tier build is its first compile, and a failure there reopens this ticket.
2. The watch's refusal text still says only "Turn them on and try again" (Assumed 4); naming the phone app in it is a wear-module wording change, owner call.
3. S0007's device check carries the end-to-end run of this flow with a paired watch.

### Manual / on-target

- [ ] On an Android 13 or later device or emulator, install `phone-store-debug.apk` fresh and open the app. After the report renders, the dialog "Allow notifications?" shows with **Continue** and **Not now** (check English, Russian and Ukrainian); **Continue** opens the system prompt; **Allow** raises no snackbar and no overflow entry stays. With a paired watch, **Send to phone** is accepted and the notification "Watch report received" appears and opens the share sheet.
- [ ] Fresh install again, tap **Not now**: the dialog does not return on the next open; the overflow shows **Turn on notifications** and opens the system prompt; **Deny** shows the snackbar "Notifications are off.." with **Settings**, which opens the app's notification settings; enabling them there and returning hides the overflow entry.
- [ ] On Android 12 or earlier (or an API 31 emulator): no dialog; with notifications switched off in the system settings the overflow entry opens the app's notification settings.
- Not covered: OEM skins that restyle the permission prompt, rotation while the dialog is open, the snackbar's position over the gesture bar in portrait and landscape, and the watch-to-phone round trip (S0007).
