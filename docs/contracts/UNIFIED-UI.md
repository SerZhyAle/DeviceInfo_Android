# Unified UI - pointers

| Id | Version read | Home | Role |
| --- | --- | --- | --- |
| UI-SIZING | 1.2 | `ui-sizing/` | consumer |
| BUTTONS | 2.2 | `buttons/` | consumer |
| COLLAPSIBLE-GROUP | 1.3 | `collapsible-group/` | consumer |

Read 2026-11-15. `COLLAPSIBLE-GROUP` was read at 1.3 (section 8 in full); `UI-SIZING` 1.2 and `BUTTONS` 2.2 are unchanged since their read of 2026-11-13. Adopts `UI-SIZING` (touch target minimums, density-independent dimensions), `BUTTONS` (focus ring on keyboard/D-pad navigation, accessible touch targets), and `COLLAPSIBLE-GROUP` (collapsible group header and remembered expansion state).

Version steps since the pointer was last read (2026-11-11):

- BUTTONS 2.1 (2026-11-12, clarification): the touch naming sentence binds every icon-only command on a touch surface - the accessible name is the assistive-technology route and a `title` is not a touch route.
- BUTTONS 2.2 (2026-11-13, clarification): the contract binds Wear OS app surfaces; the toolkit's chips and buttons are a permanent variant of section 3 rule 2.
- UI-SIZING 1.2 (2026-11-13, clarification): the contracts bind Wear OS app surfaces under a watch profile; toolkit chips, buttons and lists on a round display are a permanent variant recorded in the product's size-profile record.
- COLLAPSIBLE-GROUP 1.2 (2026-11-13, clarification): on a Wear OS round display the marker stands at the reading-start side of the toolkit's safe area, and the header keeps whole-header activation at the touch baseline.
- COLLAPSIBLE-GROUP 1.3 (2026-11-15, clarification): section 8 items B and C - the group headings of one page draw a leading topic glyph on every heading or on none (`ICON-RENDER` section 25), the state triangle is not that glyph and is drawn on every heading, and a header and the rows under it are two sets. Read against the tree on 2026-11-15, both surfaces are in conformity by static reading and nothing in the product changes: the phone draws the triangle (`csh_chevron`), then the topic glyph (`csh_icon`), then the title on every report group header, and `SystemInfoGroupIcons` maps all 24 `SystemInfoGroup` values; the watch's `SectionDisclosure` draws the marker, the glyph and the title on all ten headers (nine report sections and the Help row), under the ten-member set of ticket S0035. Rule 2 is unchanged by the item: the marker stays at the extreme reading-start side and the glyph stands after it. Not measured on a rendered screen: the order and spacing on a device are open checks of S0007.

Registry rows: `UI-SIZING`, `BUTTONS` and `COLLAPSIBLE-GROUP | DeviceInfo Android`, role C, reading 1.2, 2.2 and 1.3, declared 2026-11-14 (ticket S0025), `COLLAPSIBLE-GROUP` read again 2026-11-15 (ticket S0044; this pointer, the register and that row moved together), verification `pending`. The three contracts' `consumers` lines bind every Android application, so no consumer entry is proposed. The Wear OS clauses of these versions came from this product's three proposals of 2026-11-13 (`PROPOSAL-2026-11-13-deviceinfo-wear-os-profile.md`, `-wear-os-chips.md`, `-wear-os-group-header.md`), accepted the same day. Exceptions E1 to E4, recorded by S0023 and dated 2026-12-31, are in the registry's exceptions table; the product's size-profile record is `docs/UI_CONFORMANCE.md`.
