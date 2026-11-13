# S0001 - Complete canon adoption and project foundation

**Ticket:** S0001
**Status:** Verified
**Priority:** 80
**Tier:** 3 - Moderate
**Complexity:** medium - assessed at the spec pass: bounded adoption work across the stamp, two agent files, the day-0 scaffold and one record in the canon repository; no code, and the only decision is one recorded exemption. Read against the plan: the level stands.

## Goal

Complete a truthful, independently maintainable project foundation for DeviceInfo. `docs/BOOTSTRAP_HANDOFF.md` and FastMediaSorter S4528 are the starting record; FastMediaSorter `app_v2` and `wear` System Info sub-applications are the upstream feature sources.

## Scope and acceptance

- Reconcile the bootstrap stamp and agent contracts against the current SZA canon for an Android overlay B product with phone and wear modules.
- Validate the shared harness, catalog and release queue in this project; keep PLAN tracked and secrets outside the project. Keep DeviceInfo's independent root and release boundary.
- Record actual checks and unresolved owner decisions. Do not select published identifiers, signing, license, remote or distribution channel by assumption.

### 3.3 Owner inputs (Approval gate)

- **Related tickets:** FastMediaSorter S4528; FastMediaSorter System Info sub-application is upstream. DeviceInfo S0002 follows.
- **Owner decisions this ticket records and does not take:** application id, signing key, license, public remote, distribution channel, site and privacy page, store name - n/a here, carried to S0008 (see the open questions).
- **Contract boundary:** n/a - the product holds no shared contract today; no catalog amendment is owed.

## Spec pass (2026-11-10)

- **Rung:** complex pipeline. Forced upward by the primitive test: more than three files change and new files are created (the stamp, both agent files, the scaffold's launchers, plan files and template, the spec command forwarders, one record in the canon repository).
- **Baseline measured before any edit:** the canon compliance gate exited 1 with 3 errors and 0 warnings (`SZA-LAY01` no `LICENSE`; `SZA-RULES02` no canon pointer in `AGENTS.md` and in `CLAUDE.md`); `spec_catalog/validate` exited 0 with 10 OK; `spec_catalog/release-queue -Validate` exited 0 ("OK - 8 ticket(s), no drift"); the stamp's core digest equals the installed canon's, so nothing is re-synced and no version is written by hand (the stamp reads 2026.11.09.1, the canon 2026.11.10.1: a version moved without a digest change, REPO-STAMP rule 8).
- **Settled without asking** (the records answer them): the unattended children's permission mode is the registry's recorded choice, `bypassPermissions` (`pq list -Json`), equal to the scaffold default; the product is already in the portfolio as key `deviceinfo-mob`, rank 130 (`pq list`); the product holds no shared contract (a case-insensitive search of the catalog at `P:\Contracts` for "deviceinfo", "device information", "device_info" and "System Info" finds nothing, and the registry has no row for it); the phone-to-watch Data Layer pair stays inside one application id, so it is not a cross-product boundary today; the ticket id scheme is the harness default `Sxxxx`; `PLAN/` stays tracked because the scope says so.
- **License:** the only compliance error that needs an owner decision. The scope forbids choosing it, so it becomes a dated exemption in the stamp, not a file.
- **Observed, carried:** this tree is not a git repository (no `.git`); the sibling Android products have one. Creating it is the owner's call, not this ticket's.

## Done criteria

Each is a command to run or a file to read.

1. The canon compliance gate, run from the installed plugin root, exits 0 with 0 errors.
2. `tools/harness.ps1 spec_catalog/validate` exits 0 with 0 FAIL, and `spec_catalog/release-queue -Validate` exits 0.
3. `r0.ps1 -DryRun` exits 0 and lists S0001 as the one open ticket.
4. `CLAUDE.md` names the canon, the overlay, the model `reference` and the contrib record; `AGENTS.md` is the delegating stub; neither carries a restated universal rule (the gate's `SZA-RULES03` is silent).
5. `.gitignore` ignores `temp/` and the signing-material globs and carries no pattern that matches `PLAN/`.
6. No decision is taken by assumption: no `LICENSE` file, no `applicationId`, no signing file, no remote in the tree, and the open list in `CLAUDE.md` names each one with the ticket that needs it.
7. The contrib record exists in the canon repository and carries a dated adoption section.

## Plan

Coverage inventory - scope bullet 1 (reconcile stamp and agent contracts) -> phases A, D; bullet 2 (validate harness, catalog and release queue; PLAN tracked; secrets outside; independent root) -> phase B for the day-0 files, phase A for the ignore-list reading, phase E for the runs; bullet 3 (record checks and unresolved decisions, none by assumption) -> phases A (open list), C (record), E (audit). Constraint "upstream checkout untouched" -> phase E (no write outside this tree except the one record in phase C). Done criteria 1-7 -> phases A (4, 5, 6), B (3), C (7), D and E (1, 2). Spec-pass findings: contract boundary none -> phase C record (CONFIRM) and `CLAUDE.md` section 5. Out-of-scope: any build or test command (S0002 builds and records them).

Produces/consumes - A produces `CLAUDE.md` and `AGENTS.md` and names the record path as text only; B consumes nothing from A; C consumes the facts measured in the spec pass and in A and B; D consumes the record path produced by C (the stamp's `contribRecord` names a file that exists); E consumes everything. No phase consumes what a later one produces.

- **A. Agent contracts** - files: `CLAUDE.md`, `AGENTS.md`. `.gitignore` is read, not edited: the gate reports no leak-glob finding. Check: `CLAUDE.md` names the plugin `sza-unified-rules`, the model `reference`, overlay B and `contrib/deviceinfo_mob.md`; `AGENTS.md` equals the delegating stub; criteria 4, 5 and 6.
- **B. Day 0 of the task flow** - the harness scaffold (plan files, stores, template, launchers) and the spec-command registration; `pq register` is run to prove it is idempotent. Check: the printed `created` lines, `r0.ps1 -DryRun`, eight forwarders in `.claude/commands/`, criterion 3.
- **C. Contrib record** - `rules/contrib/deviceinfo_mob.md` in the canon repository, the one write the canon allows from here. Check: the file exists and carries a dated `## Canon adoption` section; criterion 7.
- **D. Stamp** - file: `.sza-canon.json` (`schemaVersion`, `$comment`, `reconciledOn`, `contribRecord`, the LICENSE exemption with `until`). Version and digest are not touched. Check: the gate reads it with no `SZA-CANON` error.
- **E. Evidence** - criteria 1, 2, 3, 5 and 6 run fresh, exit codes read, then the self-audit.

Read against the plan: the level stands, no decision is hidden in it.

## Open questions

1. **Application id (one id shared by phone and wear) and its freeze.** Status: Open. The owner has not chosen it; S0002 builds under explicit provisional ids that are not anchors. Carrier: S0008
2. **Signing key, its location outside this tree, Play signing mode.** Status: Open. Not chosen; nothing signed or created. Carrier: S0008
3. **License.** Status: Open. `LICENSE` is absent on purpose; the `SZA-LAY01` exemption lapses on 2027-02-10 and S0008 adds the file or renews the entry. Carrier: S0008
4. **Public remote, distribution channel or channels, site and privacy page, store name and branding.** Status: Open. None chosen. Carrier: S0008
5. **Form of the parity inventory against the FastMediaSorter System Info sub-applications** (a committed port ledger with a SHA-256 drift check as in StreamsPlayer_mob and Tourist_mob, or another). Status: Open. Depends on a fresh inventory of the upstream. Carrier: S0003
6. **Package versioning contract declaration** (Android profile, one application id for phone and wear). Status: Open. It binds a build that does not exist yet; the registry row and `docs/contracts/` come with the first declared contract. Carrier: S0002
7. **Input parity, in-app help and the unified UI contract declarations.** Status: Open. They bind screens that do not exist yet. Carrier: S0004
8. **Is the phone-to-watch Data Layer pair a contract boundary?** Status: Open. Inside one application id it is internal; it becomes a boundary only if another product reads or writes it. Carrier: S0005
9. **A local git repository for this tree.** Status: Open. None exists; the owner decides whether and when to create one (a remote stays an owner decision, item 4). Carrier: S0002
10. **Does the product hold a shared contract today?** Status: Resolved - no. A case-insensitive search of the catalog finds none of the product's names, and the registry has no row for it.
11. **Permission mode of the unattended children.** Status: Resolved - `bypassPermissions`, the registry's recorded choice (`pq list -Json`), equal to the scaffold default.

## Last Audit

**Date:** 26-11-10 22:17 | **Mode:** static | **Outcome:** Verified
**Counts:** PASS 12 | WARN 0 | FAIL 0 | MANUAL 0 | UNCHECKABLE 0 | EXEMPT 3 | RELEASE 0

Evidence, each run fresh in this pass (expected | actual):

1. Compliance gate from the installed plugin: exit 0, 0 errors | exit 0, 0 error(s), 1 warning(s); before the work: exit 1, 3 error(s), 0 warning(s). PASS.
2. `spec_catalog/validate`: exit 0, 0 FAIL | exit 0, Summary 10 OK, 0 WARN, 0 FAIL. PASS.
3. `spec_catalog/release-queue -Validate`: exit 0 | exit 0, "OK - 8 ticket(s), no drift"; `-List -Ready` exit 0 on the empty ready file. PASS.
4. Day 0 of the task flow: scaffold `created` lines for the plan files, the stores, the template and `r0`-`r3`, `rs`, `rm`, `rw`; `register-spec-commands` "wrote 8"; `pq register` "already registered deviceinfo-mob"; `r0.ps1 -DryRun` exit 0, "1 open ticket(s)", S0001 the one | all four as expected. The first dry run exited 2 ("command 'claude' not found": the tool shell's PATH lacks the folder that holds `claude.exe`) and exited 0 with that folder on PATH; recorded as a candidate core edit in the contrib record. PASS.
5. `CLAUDE.md` carries the canon plugin name, the model `reference`, overlay B and the contrib record; `AGENTS.md` is the delegating stub; `SZA-RULES02` and `SZA-RULES03` silent | confirmed by a search for the four tokens and by both gate runs (items 1 and 8). PASS.
6. `.gitignore`: `temp/` and the signing globs ignored, no pattern that matches `PLAN/` | `temp/` on line 8, the globs on lines 11-17, no `PLAN` pattern. Rung is a read of the ignore list: this tree is not a git repository, so `git check-ignore` has nothing to run on. PASS.
7. No decision by assumption: no `LICENSE`, no signing file, no `applicationId` or signing configuration outside the ticket store, no remote | file listing and a search over the tree found none; there is no `.git`. `CLAUDE.md` section 3 names each open decision with its ticket. PASS.
8. Contrib record in the canon repository with a dated adoption section | present, `## Canon adoption 2026-11-10` at line 55; the gate run from the canon checkout (same core digest `9abe1d23..`): exit 0, 0 error(s), 0 warning(s). PASS.
9. Probe invariant: no ticket-id probe in source | the four source folders are empty and `check-probe-absent` printed PASS. PASS.
10. Scope purity: edits inside the plan | `CLAUDE.md`, `AGENTS.md`, `.sza-canon.json`, the scaffold output, this spec, and the one allowed record in the canon repository; the upstream checkout was not touched; nothing parked; the active ticket never switched. PASS.
11. House style in the prose written | no `...`, long dash or ellipsis in `CLAUDE.md`, `AGENTS.md`, the stamp or the record. PASS.
12. Doc sync: `CLAUDE.md` and the contrib record affected; `README.md` (a bootstrap that does not build) and `docs/BOOTSTRAP_HANDOFF.md` unchanged and still accurate; no document registry is declared. PASS.
13. Hygiene gates on the diff: no source code changed, so the comment, catch, colour and logging gates have nothing to scan. EXEMPT: out-of-scope, no code in this ticket.
14. Installed-plugin warning `SZA-CANON06` (the record resolves under the installed canon). EXEMPT: the installed plugin updates only when the canon repository publishes the record, which a project session does not do; the record exists and resolves from the canon checkout (item 8).
15. No application build exists, so no build or test command ran. EXEMPT: out-of-scope, the skeleton and the first build are S0002; not built, not tested.

### Action items

None for this ticket. Carried, each with its carrier in the open questions: the owner decisions (S0008), the local git repository (S0002), the parity inventory form (S0003), the contract declarations (S0002, S0004, S0005). For a canon session: the candidate core edits listed in the contrib record, and the publication of that record.

### Manual / on-target

None open.
