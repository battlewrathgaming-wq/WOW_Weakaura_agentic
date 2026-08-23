# PRIOR ART — how the field uses Ace3 on this client (a census of every launcher addon, 2026-08-21)

_Design architect, 2026-08-21, at Battlewrath's direction: "I have downloaded every addon the game launcher
offers, so we can inspect for style / method trends with Ace — how do people use it and how can we." A
read-only survey by an `Explore` agent of `Interface/AddOns/` (254 entries, 230 third-party addons);
every count re-runnable, every claim cited. **This file rules nothing.** §5 (what transfers) and §6 (two
facts that bear on our build) are the deliverable. Extends `audit/ui_wa_grammar.md` and
`history/UI_findings_ace_XML.md`; where it corrects them it says ★ EXTENDS. Reproduced from the agent's
report as delivered (its transcript file was empty); cites are `path:line` relative to the AddOns root._

---

## Scope and method

Root: `F:\games\Ascension_wow\resources\ascension-live\Interface\AddOns\` — 254 entries: 22 `Blizzard_*`
stubs, 2 files, **230 third-party addon directories**. Counts: `find` per directory for
AceGUI-3.0.lua / AceConfig-3.0.lua / AceDB-3.0.lua / LibStub.lua; `grep 'MAJOR, MINOR'` in each library
file; `grep 'AceGUI:Create('` excluding library-internal paths; `grep -c 'CreateFrame('`.

# 1. CENSUS

## 1a. Addons that EMBED Ace3

`AceGUI` = minor of AceGUI-3.0.lua; `ACD` = AceConfigDialog minor; `ADB` = AceDB minor. "GUI-direct" =
calls `AceGUI:Create(...)` from its own code. Lua = total .lua files incl. libs; CF = `CreateFrame(` count.

| addon | AceGUI | ACD | ADB | GUI-direct | AceConfig table | other UI libs | Lua / CF |
|---|---|---|---|---|---|---|---|
| **TradeSkillMaster** | consumes | consumes | — | **YES (31)** | no | LSM, LDB, DBIcon, ScrollingTable | 87 / 135 |
| **Skada** | 33 | 50 | 27 | **YES (10)** | yes (+Bliz, +SelectGroup) | LSM, LDB, DBIcon, DualSpec, SharedMediaWidgets | 104 / 127 |
| **AdiBags** | 33 | 54 | 22 | **YES (2)** | yes (+Bliz, +Open) | LSM, LDB, DualSpec | 112 / 138 |
| **AI_VoiceOver** | **41** | **78** | 21 | YES (1) | yes (+Bliz, +Open) | LDB, DBIcon, DualSpec | 54 / 91 |
| **ElvUI_OptionsUI** | **41** | **79** (-ElvUI) | — | YES (9) | yes (+Open) | LSM | 63 / 85 |
| **Bartender4** | 33 | 48 | 20 | YES (8) | yes | LDB, DBIcon, DualSpec, **LibWindow-1.1** | 88 / 99 |
| Recount | 33 | 54 | 21 | no | yes | LSM, DualSpec | 77 / 233 |
| PitBull4 | 33 | 49 | 21 | no | yes | LSM, LDB, DBIcon, DualSpec, SharedMediaWidgets | 88 / 98 |
| ShadowedUF_Options | 33 | 48 | — | no | yes | LSM | 35 / 75 |
| PlateBuffs · Quartz · Collectinator · SilverDragon · Kui_Nameplates · Decursive · ESN_Rare | 33 | 49–50 | 21–27 | no | yes | LSM/LDB/DBIcon/LibQTip/DualSpec variously | — |
| DiminishingReturns · Omen · RatingBuster | **30** | 43–45 | 19–20 | no | yes | LSM, SharedMediaWidgets (Omen) | — |
| DRTracker | **25** | **34** | 15 | no | yes | LSM, DualSpec | 46 / 87 |
| VuhDo | **16** | **25** | — | YES (1) | no | LSM, LDB | 92 / 72 |
| **COA_DungeonRun** (ours) | **33** | 49 | **—** | YES (3) | yes (+Open) | — | 33 / — |

★ **EXTENDS `UI_findings_ace_XML.md` §1.** AceGUI **rev 41** exists on this client in two places —
`AI_VoiceOver/Libs/AceGUI-3.0/AceGUI-3.0.lua:28` and `ElvUI_OptionsUI/Libraries/Ace3/AceGUI-3.0/AceGUI-3.0.lua:28`
— and AceConfigDialog minor 78/79. LibStub keeps the highest minor loaded; ElvUI's renames itself
`AceConfigDialog-3.0-ElvUI` (`...AceConfigDialog-3.0.lua:10`) so does not contend, but **AI_VoiceOver's does
not rename and will win both AceGUI (41) and AceConfigDialog (78).** ⚠ Shipping our own r960 makes r960 the
FLOOR, not the copy that runs (F1's open question in its practical form).

## 1b. Addons that USE Ace3 without embedding AceGUI/AceConfig
`RegisterOptionsTable` callers with no AceGUI of their own: Asc_Gathermate2, Asc_MacroBank, Chatter,
ClearQuests (pure AceGUI, 0 CF), Details (518 CF), GatherHud, GatherMate2, MountLeash, Passloot, PastLoot,
PetLeash, Routes, TomTom, XanAscTweaks, WeakAurasOptions (157 CF), LootRememberer (15 AceGUI:Create),
COA_DungeonRun. AceDB without AceGUI: ElvUI (27), ShadowedUnitFrames (21), ProfessionMenu (21), Grid.

## 1c. Other UI libraries
| library | consumers | verdict |
|---|---|---|
| LibSharedMedia-3.0 | **51** | the universal convention (fonts/textures/sounds) |
| LibDataBroker-1.1 | 33 | universal launcher object |
| LibDBIcon-1.0 | 22 | minimap button |
| LibDualSpec-1.0 | 20 | profile-per-spec; pairs with AceDB |
| AceGUI-3.0-SharedMediaWidgets | 5 | rare |
| LibQTip-1.0 | 4 | tooltips |
| LibScrollingTable | 11 (all TSM) | single family |
| **LibWindow-1.1** | **3 only** (Bartender4, Details, Details_Streamer) | ⚠ RARE — not a convention here; position saving is by hand (§2e) |

## 1d. Everything else
Bagnon, DBM (~30 dirs, own GUI), XPerl (25), PitBull4 modules (33, option tables only), ZOMGBuffs, Details
plugins, AtlasLoot, TSM modules (9, AceGUI-direct via TSM's widgets), pfQuest, WIM, MSBT, MoveAnything, OPie,
Outfitter, Clique, TurboPlates, SignalFire, LibellusLeti, MancerLedger, Auctionator, Storyline, PowerAuras,
Grid, TrinketMenu, ArenaSpectator, ~40 data-only packs.

**Headline:** of 230 dirs, **22 embed Ace3**, **~37 author AceConfig option tables**, and **only 9 non-WA
addons drive AceGUI widgets directly** (TSM + modules, Skada, AdiBags, AI_VoiceOver, ElvUI_OptionsUI,
Bartender4, ClearQuests, LootRememberer, VuhDo). Everyone else writes option tables and lets
AceConfigDialog draw, or builds raw frames.

# 2. IDIOMS — how the AceGUI-direct addons structure panes

## 2a. Tabs vs tree — split by authorship level
**Convention (~20 addons, 66 occurrences):** you do not create a TabGroup; you write
`childGroups = "tab" | "tree" | "select"` on a `type="group"` and AceConfigDialog builds it. **Tab-in-tab is
a known shape**: `ShadowedUF_Options/config.lua:479, 3454, 3465, 3525` (tree in tab in tab);
`ElvUI_OptionsUI/UnitFrames.lua` (tree → tab per unit → tree per element, `:1, :279, :509, :538, :568`);
`PitBull4/Options/LayoutEditor/Other.lua` (`childGroups="tab"` at two levels). Always as `childGroups`,
never two hand-built TabGroups. **Hand-built `AceGUI:Create("TabGroup")`: exactly two addons** —
WeakAurasOptions (`OptionsFrames/OptionsFrame.lua:1201`) and TSM (`GUI/TSMWidgets/TSMTabGroup.lua`, its own
re-skinned clone). Hand-built TreeGroup: WA's code review picker and TSM. DropdownGroup direct: WA's
TexturePicker only.

## 2b. TSM is the one addon that built the thing we are building
`TradeSkillMaster/GUI/` is a declarative-page layer over AceGUI — the closest structural match in the corpus.

**One frame, a strip of tabs, panes swapped in** — `TSMMainFrame` (`GUI/TSMWidgets/TSMMainFrame.lua`):
two icon rails + a content frame; clicking an icon:
```
GUI/TSMWidgets/TSMMainFrame.lua:192-200
if #self.children > 0 then self:ReleaseChildren() end
self:SetTitle(btn.title); btn.info.loadGUI(self); self.selected = btn; self:UpdateSelected()
```
**`ReleaseChildren()` + a per-tab builder callback is the whole tab mechanism.** Registration:
`TSM:RegisterMainFrameIcon(displayName, icon, loadGUI, moduleName, side)` (`GUI/MainFrame.lua:49-71`) —
a module hands over a name, an icon and a BUILD FUNCTION; the frame owns the rail.

**Selection state is addressable:** `TSM:GetTSMFrameSelectionPath()` (`GUI/MainFrame.lua:134-140`) walks
`frame.children[1]` recursively and emits a serialisable path `{Icon → TreeGroup → TabGroup}`
(`FramePathHelper` `:124-133` reads `status.selected` / `localstatus.selected`). ★ The mechanism a per-tab
return band needs: capture the path on undock, replay on redock.

**`TSMAPI:BuildPage(container, pageTable)`** (`GUI/BuildPage.lua:405-434`) — recursive declarative builder,
`PauseLayout / recursive / ResumeLayout / DoLayout` per container (**one layout pass per container, not per
child**); dispatch table `:222-396` (InlineGroup, SimpleGroup, ScrollFrame, Label, Button, EditBox,
CheckBox, Slider, Dropdown, ColorPicker, Icon, Image, GroupBox, GroupItemList, MacroButton, MultiLabel,
InteractiveLabel, **Spacer**, **HeadingLine**). `container.Add` is injected onto every TSM container in three
lines (`GUI/TSMWidgets/TSMSimpleGroup.lua:14-19`) — the cheapest "universal pane" primitive.

**Sizing:** TSM never calls `SetPoint` for content; widths are `relativeWidth` (`BuildPage.lua:206-214`,
`:171-176`); only Spacer and HeadingLine exist as fillers (`:383-395`) — the same two devices WA uses.
**Auto-height:** `TSMTabGroup.lua:261-264` `LayoutFinished → SetHeight(height + 30)`; `OnWidthSet/OnHeightSet`
subtract fixed chrome (`:239-259`). **`LayoutFinished` + a chrome constant is the whole auto-sizing contract.**

## 2c. Collapsible / fold-in-fold-out
**No AceGUI widget collapses.** Three live answers:
1. **WA — visibility, not structure:** header `execute` with `control="WeakAurasExpand"`; every body option's
   `hidden` wrapped as `collapsedFunc() or oldHidden()`; the dialog's re-feed after any set makes it live
   (`CommonOptions.lua:91-316`). No hand-written rebuild.
2. **AdiBags — hide the frame, announce a layout change:** `AdiBags/widgets/Section.lua:181-192`
   `SetCollapsed` → `db.char.collapsedSections[key]` → `Hide()/Show()` → `SendMessage('AdiBags_LayoutChanged')`.
   State per character, keyed by a stable section key; the container's layout pass reflows.
3. **LibellusLeti — a real accordion with computed height:** `LibellusLeti/Hub.lua:393-413` `row:SetExpanded`
   flips a chevron, shows/hides `body`, calls `UpdateHeight` (`:493-516`: header + optional body lines ×
   line height + pads); `onToggle → host.onLayout()` (`:536-540`, `:598-601`). **The closest thing in the corpus
   to a fold-in/out universal pane**, raw frames.
4. DBM — `CreateArea` + `SetMyOwnHeight` (§4), not collapsible, same height contract.
⚠ No addon collapses an AceGUI container by `ReleaseChildren()` + re-add. Two techniques: *hide + reflow*
(hand-built AceGUI) or *`hidden` closure + let the dialog re-feed* (AceConfigDialog).

## 2d. "Add another" repeating groups
Nobody outside WA does Trigger 1 / add trigger / Trigger 2. What exists:
- **Skada — a create-form:** `Skada/Core/Options.lua:222-273` inline group "Create Window": `input` name +
  `select` display + `execute` Create, disabled until both filled; the new window becomes its own group under
  `args.windows`. The cleanest AceConfig "add an object" idiom.
- **`args[key] = <group>` then `NotifyChange` — the universal "one more of these":** Bartender4
  (`Options/Options.lua:275-280`), Grid (`GridCore.lua:125-130`), Omen (`Omen.lua:1901`), Chatter,
  Kui_Nameplates, MountLeash, PetLeash, ElvUI_OptionsUI; 15 addons call `NotifyChange`.
- TSM — a tree rebuilt (`Core/Groups.lua:883`).
→ **Action 1 · add action · Action 2** = WA-shaped (per-object `__meta`, `__order = i*10`) with Skada's
create-form ergonomics if the new object needs identity first.

## 2e. Dock / undock / detach
⚠ **No AceGUI addon on this client detaches a container to a standalone window.** The answers:
1. **LibellusLeti — a genuine embed/detach pair, raw frames:** `Hub:DetachMinionSheet()` (`Hub.lua:1444-1479`):
   hide → `RestoreStandaloneStyle()` → `SetParent(UIParent)` → `ClearAllPoints` → `SetPoint("CENTER")` →
   re-enable movable/mouse/drag → strata DIALOG → re-show title/subtitle/close → clear the sentinel
   `frame._mancerHubEmbedded`. Mirror `Hub:EmbedMinionSheet()` (`:1481+`). ★ **The chrome (title, close,
   drag) is state on the frame the container SUPPRESSED; undock is "put it back." A sentinel flag names
   which state it is in.**
2. **Skada — docking as configured DATA, not drag:** `Window:SetChild(win)` (`Core/Core.lua:641-655`), an
   option group with a cycle-excluding `values` function (`Core/Options.lua:1298-1341`); teardown
   (`Core.lua:1180-1181`).
3. Chat dock — the shape every WoW user knows; only ElvUI touches it here (`Chat.lua:1258`).
4. TrinketMenu — explicit dock API on raw frames (`:86, :96, :109, :703`).
**Position persistence:** AceGUI `SetStatusTable` is used by TSM only, and only for selection; geometry is a
hand-rolled 4-field status table with `SetPoint("TOP", UIParent, "BOTTOM", 0, top)` +
`SetPoint("LEFT", UIParent, "LEFT", left, 0)` (`TSMMainFrame.lua:240-258`, `TSMWindow.lua:78-90`) — survives
UIParent resizing. ★ EXTENDS: LibWindow is NOT the local convention (3 addons).

## 2f. Where UI state is kept
| store | who | what |
|---|---|---|
| `db.profile.<x>Status` | TSM | tree/tab selection, scroll offsets |
| `db.profile.design.*` | TSM | theme colours, edge size |
| `db.char.collapsedSections[key]` | AdiBags | fold state, per character |
| `db.profile` window records | Skada | per-window geometry + docking |
| in-memory | WeakAuras | fold state, discarded on reload |
| `db.global.optionsTreeStatus` | TSM modules | selection shared across characters |
★ **Selection → profile or global; fold state → char or memory; geometry → profile.** Nobody puts fold state
in `db.profile.ui`; a single namespace would be our own declared choice.

# 3. STYLE — tone
**Default AceGUI skin, unmodified, is what almost everyone ships** (Skada, AdiBags, Bartender4, ClearQuests,
LootRememberer, AI_VoiceOver, VuhDo). ⚠ **ElvUI_AddOnSkins does NOT skin Ace3 on this build** — its only
Ace hook is `SkinAceAddon20` (Ace2, `Skins/Libs.lua:430, :998`); an ElvUI user does not restyle our pane.
**Two addons re-skin properly, both by cloning widgets:** WeakAurasOptions (30 widget types) and TSM (22
widgets, mostly WRAPPERS — `AceGUI:Create("<stock>")` then re-brand). TSM's theme is a registry, not a
constant: `GUI/Design.lua:34-45` `SetFrameColor(obj, colorKey)` reads `db.profile.design.frameColors`,
remembers the frame in `coloredFrames`, applies backdrop + border; semantic accessors (`SetContentColor`,
`SetTitleTextColor`, `GetInlineColor("category"|"link"|"advanced")`); fonts from LSM. **This is the
"WA-like tone" mechanism: one colour/font table in the DB, a semantic accessor per role, a registry so a
change re-themes live.**
**Collapse-to-a-strip / minimise:** Recount does not minimise (the texture is reused for small buttons).
**Skada hides whole windows remembering per-window intent** — `Skada:ToggleWindow()` (`Core/Core.lua:1238-1259`)
flips a master `db.profile.hidden` while each `win.db.hidden` survives; `Window:Toggle()` (`:851-856`) gates on
both. ★ **Two-level visibility — a master switch that does not destroy per-item state — is what "a
collapsed strip that restores all" needs.** TSM's icon rail IS a persistent strip (51 px buttons, a dark
overlay on the unselected, `TSMMainFrame.lua:151-160`). AdiBags' section headers are the fold strip.

# 4. COMPUTED LAYOUT
**A. AceGUI layouts + `relativeWidth` (TSM)** — zero content `SetPoint` (`BuildPage.lua:206-214`, `:171-176`).
**B. Distribute-with-remainder (TSM icon rail)** — `TSMMainFrame.lua:96-105`: spacing derived from container
width and item count, with a degrade branch when it will not fit. `(i-1)*stride` appears, but stride and
spacing are DERIVED — the test that separates computed layout from hand-placed arithmetic.
**C. Chain-to-previous-sibling (DBM)** — `DBM-GUI/DBM-GUI.lua:149-155` `autoplace`; a `lastobject` cursor
(`:162-173`); heights roll UP from children (`SetMyOwnHeight` `:581-597`, `AutoSetDimension` `:561-579`).
★ Computed padding with no library, in the addon every raider on this fork already knows.
**D. Running-y accumulator, absolute placement (LibellusLeti)** — `Hub.lua:546-591`, under the comment
*"Absolute Y layout — does not chain row-to-row BOTTOMLEFT (avoids stuck overlaps)"*: the child reports its
own height first (`row:UpdateHeight()`), the parent only accumulates; surplus pooled rows are hidden, not
released; the trailing gap is subtracted so the host height is exact.
**E. Plain running-y** — Details (`window_options2_sections.lua`, 18 sites), TurboPlates (one named stride for
a homogeneous list — legitimate).

**The anti-pattern, by name** — literal `SetPoint(..., C - (i-1)*K, ...)` with both constants typed in:
`COA_DungeonRun/object.lua:831` (`-276 - (i-1)*22`) and `:836` (`-272 - (i-1)*22`) — ⚠ **different base
constants for the same row**, a 4 px baseline offset baked into two literals nothing links ·
`map.lua:2314, 2316` · `promoter.lua:569` · `COA_Landmarks/editor.lua:155` · SignalFire (11 sites) · Details ·
AtlasLoot · LibellusLeti/StatPriority. ★ Our four sites sit in the same list as SignalFire's eleven.

# 5. WHAT TRANSFERS

| idiom | best example | maps to ours | how common |
|---|---|---|---|
| Tabbed bolt-on panel: one container, `ReleaseChildren()` + per-tab build callback | `TSMMainFrame.lua:192-200`; `GUI/MainFrame.lua:49-71` | the side panel of TABS; each docked group registers `{name, icon, buildPane}` | RARE hand-built (TSM, WA) — the RESULT looks like every tabbed addon |
| Tabs declared as data (`childGroups`), the dialog builds them | `ShadowedUF_Options/config.lua:479…`; `ElvUI_OptionsUI/UnitFrames.lua` | tab-in-tab (Object options → Beacon/child → Action N) if routed through AceConfigDialog | **VERY COMMON** — 66 uses / 22 addons |
| Declarative page table → widget tree, one layout pass | `BuildPage.lua:405-434` | the UNIVERSAL PANE — one `BuildPane(container, spec)` | RARE (TSM) but 434 lines |
| Container gets an `Add` in 3 lines | `TSMSimpleGroup.lua:14-19` | our pane primitive without forking AceGUI | RARE |
| Fold-in/out = hide + announce; state keyed by section id | `AdiBags/widgets/Section.lua:181-192` | fold sections on a hand-built pane | COMMON gesture |
| Fold-in/out = `hidden` closure + dialog re-feed | WA `CommonOptions.lua:91-316` | same, via AceConfigDialog — no rebuild code | RARE (WA) |
| Accordion row owns its height; host accumulates | `LibellusLeti/Hub.lua:393-413, 493-516, 546-591` | COMPUTED PADDING for the fold-out body | RARE, best local model |
| Auto-height from `LayoutFinished` + chrome constant | `TSMTabGroup.lua:239-264` | the tabbed container sizes itself | RARE |
| Children roll their height up | `DBM-GUI.lua:561-597, 149-173` | same contract in raw frames | FAMILIAR look (DBM) |
| Distribute-with-remainder across a strip | `TSMMainFrame.lua:96-105` | the COLLAPSED STRIP and the tab rail | RARE |
| "Add another" = create-form | `Skada/Core/Options.lua:222-273` | add action when identity comes first | COMMON in spirit |
| "Add another" = `args[key]=group` + `NotifyChange` | Bartender4 `:275-280`; Grid; Omen | Action 1 · add action · Action 2 if AceConfig-driven | **VERY COMMON** (15 addons) |
| Dock/undock = reparent + restore suppressed chrome + sentinel | `LibellusLeti/Hub.lua:1444-1479, 1481+` | DOCK/UNDOCK per group; the return band is the chrome suppressed when docked | RARE (2) — **we are largely inventing it** |
| Docking as configured data with a cycle guard | `Skada Core.lua:641-655`; `Options.lua:1298-1341` | the option-table face of docking | RARE |
| Two-level visibility: master toggle preserving per-item state | `Skada Core.lua:1238-1259, 851-856` | the COLLAPSED STRIP that restores all | RARE, exactly right |
| Serialisable selection path across nested containers | `GUI/MainFrame.lua:124-140` | the PER-TAB RETURN BAND | RARE (TSM) |
| Programmatic jump to a group | `Skada Options.lua:866-871` (`ACD:SelectGroup`) | the return band's click | COMMON API |
| Position: 4-field status table, TOP-from-BOTTOM anchor | `TSMMainFrame.lua:240-258`; `TSMWindow.lua:78-90` | undocked window geometry | COMMON (LibWindow is NOT) |
| Theme registry: DB colours + semantic accessors + live re-theme | `GUI/Design.lua:20, 34-80` | WA-like TONE without forking every widget | RARE (TSM, WA) |
| Spacer / HeadingLine as the only fillers | `BuildPage.lua:383-395` | matches WA's blank-description device — two addons converged | the convergence is the signal |

**UNVERIFIED:** that TSM's selection path was built for restore (it is read by diagnostics) — the mechanism
transfers regardless · AdiBags' `db.char` choice being deliberate · `LayoutFinished` auto-height identical
under AceGUI 41 vs 33 · whether AI_VoiceOver's AceGUI 41 wins at runtime (load order; F1).

# 6. Two facts that bear directly on our build
**6a. Our shipped widget set is short of what AceConfigDialog constructs.** Our AceConfigDialog (minor 49)
names 17 widget types; we ship 13. **Missing and load-bearing: `ScrollFrame`** — every AceGUI-direct addon
uses it for a pane taller than its frame, and AceConfigDialog wraps option roots in one. Missing and
conditional: TreeGroup / DropdownGroup (only if `childGroups` is ever written), ColorPicker, Icon,
Keybinding, BlizOptionsGroup, MultiLineEditBox. We also ship no `AceConfig-3.0.lua` (registry-only is
workable but a divergence from every other addon here) and no AceDB.
**6b. Ours is the only Ace3-embedding addon with zero AceDB.** All 20 other embedders carry AceDB (15–27),
20 carry LibDualSpec. If UI state (fold, selection, dock, geometry) is to persist per profile, the local
convention is AceDB profiles — and adopting it later costs more than now.

---

## ★ ADDENDUM — two UNVERIFIED lines resolved (UI specialist, 2026-08-23)

_Added while calibrating the offline text model, on Battlewrath's steer: *"we're using Ace for the UI
behaviour. Not bare defaults. Check audits, WA and other addons that use Ace and where they use Ace."*
Evidence only; §5 and §6 above are untouched._

### 1. r33 and r41 are NOT interchangeable — they differ on the accessor, and on every widget checked
    r33  COA_DungeonRun/Libs/.../AceGUIWidget-Label.lua:54    height = label:GetHeight()
    r41  AI_VoiceOver/Libs/.../AceGUIWidget-Label.lua:58       height = label:GetStringHeight()
`diff` on the two copies: **Button · Label · EditBox · CheckBox · Dropdown · Heading ALL DIFFER.** So
the version gap is systemic rather than one widget, and *"`LayoutFinished` auto-height identical under
41 vs 33"* should not be assumed for anything.

⟶ **Consequence for the offline model, already applied:** `smoke/frames.lua` now answers BOTH
`GetHeight` and `GetStringHeight` from the same wrap model. It previously answered only the first, and
would have been calibrated against the copy that does not run.

### 2. ★★★ "WHICH COPY WINS" IS NOT ABOUT VERSION AT ALL ON THIS FORK — IT IS LOAD ORDER
`COA_DevDump/task_sheet.lua:285-297` records the fact and every landed capture confirms it: **every Ace
minor on this client reads as `1.#INF`.** All four of `AceGUI-3.0` · `AceConfig-3.0` ·
`AceConfigDialog-3.0` · `AceConfigRegistry-3.0` come back infinite.

★ LibStub replaces a library only when `oldminor < minor`. With both sides infinite that comparison is
**false**, so:

> **the FIRST Ace copy to load wins, and no later copy can ever displace it — regardless of version.**

⟶ The audit's open question *"whether AI_VoiceOver's AceGUI 41 wins at runtime (load order; F1)"* is
answered in its parenthesis: **load order, and nothing else.** ⚠ And §6a's implication changes shape —
shipping a *higher* minor cannot help us; only loading earlier can, which is not a version decision.

⚠ **NOT established here:** why the minors are infinite (a fork patch to LibStub, or the libraries'
own declarations), and which addon actually loads first in Battlewrath's enabled set. Both are one
in-client probe away and neither is assumed above.
