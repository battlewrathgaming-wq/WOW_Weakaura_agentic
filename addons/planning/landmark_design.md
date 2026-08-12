# COA Landmarks — design brief

**Named (Battlewrath, 2026-08-12): `COA_Landmarks`, title "COA Landmarks".** It is the word the
laws already speak — law 9's *promoted nodes are personal **landmarks***, and laws 14–18
throughout — so the addon carries the design's own vocabulary with no translation layer. The
`COA_` prefix matches the bench (`COA_DevDump`, `COA_PetGrid`) and, for a community release,
truthfully says *this is for Conquest of Azeroth* — which it is, since it depends on this fork's
supertrack. It also leaves the route half its own name.

**Criteria before build.** In the shape of `callwitness_design.md`: this document says what the
thing must do and how we will know it does it, and contains **no implementation**.

**Provenance rule for this document.** Every criterion is marked:

| Mark | Meaning |
|---|---|
| **[L*n*]** / **[F*n*]** | traced to a design law or a proven fact in `satnav_ledger.md` — settled, not re-openable here |
| **[P]** | **PROPOSED by me** — a gap the laws do not cover. Needs Battlewrath's ruling before build |
| **[O]** | **OPEN** — known undecided, deliberately not designed around |

Nothing here invents on top of a settled law. Where I had to reach past the laws, it says **[P]**
and says so loudly, per the ADR (`adr-inventiveness-confined-to-contained-spaces`).

Reading order for anyone arriving cold: `satnav_ledger.md` §5 laws 1–18 and §3 F21–F39 →
`satnav_prior_art.md` → this.

---

## 1. What it is

A **self-authored scrapbook of places on the world map.** You mark somewhere that matters to
you, write why, and get back to it later.

**What the product restores [L18]** — three things, and the fourth is not ours:

| Lost | Instrument |
|---|---|
| meaning — *why this place matters* | the note, pulled on hover |
| exactly where | the beacon, inside 1,500 yd |
| which zone, roughly where | the world-map pin, and the widget's `Zone` line |
| ~~how to travel there~~ | **not ours — players already know** |

**It is not** a gathering database, a quest helper, a travel aid, or a routing tool. *Notes of
meaning, not what-where* [L11].

## 2. Surfaces — exactly three

1. **A stateful widget** [L16]
2. **The in-game beacon**, when we own the slot [L13, L14]
3. **World-map pins** [L15]

**Explicitly not a surface: the minimap** [L15]. No pins, no blips, no rotation handling.
*(A minimap **button** as a capture affordance is a different thing and is in scope — §4.)*

**Frame-lifecycle machinery is out of bounds** (Battlewrath, 2026-08-12). We drive one stateful
widget and a handful of static pins. No pooling, no per-frame reposition loop.

---

## 3. The landmark record

**AC-1 [L5, corroborated by TRP3]** — a landmark stores **both coordinate spaces** plus the map
identity, captured together at creation:

| Field | Source |
|---|---|
| `x, y, z` | `GetCurrentPlayerPosition()` — world space |
| `mapID` | same call. **This is the CONTINENT/INSTANCE map, not the zone** [F30] |
| `mapX, mapY` | `GetPlayerMapPosition("player")` — map fraction, for pin placement |
| `zone`, `subZone` | `GetRealZoneText()`, `GetSubZoneText()` |
| `name` | see AC-4 |
| `what`, `why` | two free-text fields, either may be empty [L4, AC-37] |
| `icon` | user-chosen from a palette; defaults by context [AC-38] |
| `arrivalTier` | one of three [L14] |
| `scope` | `character` or `account` [§9 walk stop 2] |

**AC-2 [L1, L2]** — position is captured **where the player stood** and is **never rewritten**.
No edit path may relocate a landmark. Renaming, re-noting, changing the icon and re-tiering are all
permitted; moving is not.

**AC-3** — `mapID` is stored but **must never be treated as a zone**. Any code comparing
"same place" uses `mapID` for *map identity* and `zone` only for *display* [F30].

**AC-4 [RESOLVED — Battlewrath, 2026-08-12] — landmarks are AUTO-NAMED at capture, and the
name carries ONLY WHAT WE KNOW.** Capture asks nothing [L4] but the widget shows a name, so one
must exist without a prompt.

**Format: `<subzone> <n>`** — *"Everlook 7"*. Subzone when present, **else the zone**.

> **★ THE RULE UNDERNEATH IT (his words): *"Freshness is the int count, but devoid of meaning
> because we don't know it. That's user curated."*** We name from the two things we actually
> possess — **where it is** and **when it was made relative to the others** — and we never guess
> at the third. This is law 11 turned on our own defaults: we do not author meaning, not even a
> plausible-sounding one.

- **`n` is a monotonic, account-wide counter**, never reused after a deletion, so comparing two
  names tells you which came first. That is the *freshness* the int carries.
- **Falls back to the zone, not to a bare "Landmark 7"**, because **the name travels where the
  widget's `Zone` line does not** — the map-pin tooltip, and any future list. The name must be
  self-sufficient. The mild repetition when zone and subzone coincide is cosmetic and cheaper
  than a name that says nothing.

**AC-4a — NO text box at capture.** Rejected on two grounds: it is a prompt, which AC-7 and
[L4] exclude; and an `EditBox` taking keyboard focus **eats movement keys** — auto-focus it
mid-run and the player stops moving and types `wwww`, the exact opposite of *returns control
immediately*. Not auto-focusing it is worse still: a box you must click is more friction than
renaming later.

**AC-4b — two rename surfaces, both existing** (Battlewrath): **click the name in the widget**,
or **edit from the map pin**. Renaming in flight is therefore already available with no new
surface, because capture selects what it captured (AC-9a) — which answers the real want behind
an in-flight box: *the meaning is freshest at capture*.

**AC-5 [§9 walk stop 2]** — `scope` defaults to `character`, and moves **both ways** cheaply
after the fact: promote to `account`, demote back to `character`. Neither direction may lose the
note, icon or tier.

---

## 4. Capture

**AC-6 [L1, L3]** — a landmark can only be born **where the player is standing**. There is no
path that creates one by clicking the map.

**AC-7 [L4]** — capture **asks nothing**. No dialog, no note prompt, no icon picker, no tier
choice. It records and returns control immediately.

**AC-8 [§9 walk stop 1]** — **three affordances, none privileged**:
- the widget's `make marker` button
- a **right-click on the minimap button** *(the button, not a minimap pin — see §2)*
- a slash command the user can bind into their own macro, short: `/<abbrev> here`

**AC-9** — capture must be safe to invoke from a macro in combat: no protected calls, no taint.

**AC-9a** — **capture sets the new landmark as the widget's held landmark.** You just made it;
it is the obvious focus. This makes `repin` immediately meaningful and makes renaming-in-flight
free (AC-4b), with no prompt and no new surface.

---

## 5. The widget

**AC-10 [L16]** — the widget is exactly:

```
Landmark name
Zone                 [Map]   <- red; shown when the BEACON CANNOT GUIDE (AC-14)
[repin] [clear]
[make marker]
```

Name and zone only. **No coordinates and no distance readout** [L16, L18].

**AC-11 [L13]** — the widget holds the **last selected landmark for the session**. It keeps
showing it **after the beacon is gone** — whether arrival wiped it [L14], a quest took the slot
[L13], or the engine refused [F38].

**AC-12 [L13]** — `repin` re-applies the held landmark. It is **always a user act**; nothing
re-pins automatically, ever.

**AC-13 [L14]** — `clear` releases the supertrack slot deliberately, the same release arrival
performs.

**AC-14 [L16, L18]** — `[Map]` is shown **whenever the beacon cannot guide the player**, in red,
and is a **button that opens the world map to that landmark's zone**. Behavioural, not
instructional [L18]. **Two triggers:**

1. the held landmark's `mapID` differs from the player's — the engine **refuses** [F38];
2. same `mapID` but **`distance > 1500`** — the client's own alpha cut [F22], where the engine
   is still tracking and still returning a true distance [F35].

**Both are "beyond beacon range", which is exactly what law 16 governs.** Keying this to the
mapID mismatch alone was narrower than the law and left a real hole: in-zone at 4,000 yd the
beacon is dark and nothing would have explained why.

**AC-14a** — the two cases are **not** distinguished to the user; the action is the same. But
note internally that **case 2 is temporary and self-resolving**: the pin is live, and the beacon
appears on its own once inside 1,500 yd. `[Map]` there means *not visible **yet***.

**AC-14b [F22]** — the `1500` threshold is **the client's Lua-side convention, not an engine
limit**, and lives in `SuperTracker.lua`. It must be a **named constant with that provenance in
a comment**, because a fork update can move it and a bare literal would rot silently.

**AC-15 [L13]** — nothing about the widget's held landmark survives **logout**. The beacon
certainly does not [L13]. *(Whether the widget's held selection is session-only or persists is
settled: session-only — "holds the last selected landmark **per session**" [L14].)*

**AC-16 [RESOLVED — Battlewrath, 2026-08-12]** — the widget is **movable and hideable**, and
its position persists **per character**.

**The minimap button carries both gestures:**

| Gesture | Effect |
|---|---|
| **left-click** | **spawns the widget in its last known state** — position, and the landmark it was holding |
| **right-click** | **capture here** — a *zone–subzone–unique-int grab* (AC-4, AC-8) |

A slash command is also required as a fallback, since some UI replacements hide minimap buttons
entirely.

---

## 6. Beacon control — the slot discipline

This section carries the sharpest failure modes. **F38's guard is the single criterion most
likely to be skipped and most damaging if it is.**

**AC-17 [F24]** — set the beacon **only** via `SuperTrackerUtil.SetSuperTrackedPosition(x,y,z,mapID)`.
Calling `C_SuperTrack.SetSuperTrackedPosition` directly bypasses the client's priority ladder;
it appears to work and is then silently overwritten by the next re-evaluation.

**AC-18 [F24, CONFIRMED BY OBSERVATION F41]** — we keep **our own copy** of the pinned
landmark. `SUPER_TRACKED_POSITION` is the client's global and it **nils it** whenever
`showInGameNavigation` is off — read in source, and now **watched happening**: 99 of 99 samples
in the CVar-off run reported `gp = -1`. Our intent must survive that.

**AC-19 [L13]** — **we never re-assert.** Once the slot is lost — to a quest, to a corpse, to
anything — we do not take it back. Only the user does, via `repin`.

**AC-20 [L13, F24]** — **we yield, and yielding IS the same-level mechanism** — not a
workaround for one.

**We already enter where the quest system enters.** `SuperTrackerUtil.SetSuperTrackedPosition`
is the client's designated door for the `Position` type, exactly as `SelectQuestLogEntry` →
`SetSuperTrackedQuestID` is the door for `Quest`. There is no lower or more polite entry point
to find: **the engine has ONE supertrack slot**, so contention is structural, and the only
question a design can answer is *who wins when*.

The contention is not us versus quests — it is **the client's own fixed precedence**, which
ranks `Position` **above** `Quest` and then never creates one (§2: the plumbing exists unused).
We are the first occupant of a high-priority slot nobody expected to be occupied.

**So the two directions are symmetric, both through the client's own API:**

| User action | Our call | Ladder resolves to |
|---|---|---|
| picks our landmark | `SuperTrackerUtil.SetSuperTrackedPosition` | **Position** |
| picks a quest | `SuperTrackerUtil.ClearSuperTrackedPosition` | **Quest** |

**AC-20a — what we must NOT do**, recorded because each is a plausible-looking shortcut:
- **Do not hook or reorder `GetHighestPrioritySuperTrackingType`.** Mutating a frame or function
  we do not own is the exact pattern the prior-art pass flagged as a warning
  (`satnav_prior_art.md` §3), and it would change behaviour for every other addon too.
- **Do not call `SetSuperTrackedQuestID`.** We have no questID, and borrowing one would
  misrepresent a landmark as a quest inside the client's own quest UI.
- **Do not leave our position set "just in case".** Passivity is not neutrality here: it wins
  indefinitely and silently blocks the player's quest arrow [F24].

**AC-21 [RESOLVED — Battlewrath, 2026-08-12: accept it]** — `QUEST_TURNED_IN` calls
`SelectQuestLogEntry` **unconditionally**, so the yield-hook fires on every hand-in and drops
the pin. **We accept that.** *"We don't want to get in the way of user flow."* Zero mechanism;
the cost is one `repin` click in a rare overlap, and the widget still holds the landmark [L17].

> **⚠ DO NOT READ "accept it" AS "no yield needed".** The question was raised as *"I thought
> the quest clears it in its own call"* — **it does not**, and this is the single most
> counterintuitive fact in the whole slot discipline. `SetToBestSuperTrackingType` runs the
> ladder, finds `SUPER_TRACKED_POSITION` **still set**, and **Position wins again**; nothing in
> the client's flow nils it. **AC-20 is therefore mandatory** — without an active clear we do
> not lose gracefully, we win permanently and the player's quest arrow never comes back [F24].
> AC-21 only decides *which* selections count as intent, not *whether* we yield.

### Arrival

**AC-22 [L14]** — arrival is **per-landmark**, from the stored tier:

| Tier | Radius |
|---|---|
| Zone area | 300 yd |
| Within approach *(renamed from "within sight", which over-claimed)* | 100 yd |
| Interact with | 5 yd |

**AC-23 [L14, F28]** — arrival is measured from the **third return of
`C_SuperTrack.GetSuperTrackedPosition()`** — engine-computed, in yards, and **3D** (mean error
0.00001 yd over 1,758 samples across three runs). We compute no distance ourselves.
**`NavigationState.InRadius` is NOT used for this** — it is the engine's own radius, unsettable,
and cannot carry a per-landmark tier [F31].

**AC-24 [F38] — ★ THE GUARD. Arrival requires BOTH:**

> `C_SuperTrack.GetTargetState() ~= Enum.NavigationState.Invalid`
> **and** `distance <= tier`

**A zero distance without a valid state is a REFUSAL, not an arrival.** Across a map boundary
the engine returns `Invalid` with **`sd = 0.00` — not nil** — while still reporting
`IsSuperTrackingAnything() == true`. Zero satisfies every tier, so distance alone fires
*arrived* the instant a player zones into any instance. **Neither obvious guard catches this.**

**AC-25 [F38]** — second invariant, cheap and meaningful on its own: **the player's current
`mapID` must equal the landmark's.** You cannot have arrived at a landmark on another map.

**AC-26 [prior art: pfQuest]** — **debounce before acting on `Invalid`.** A loading screen or a
zone transition can produce a momentary invalid state; the guard must judge a **sustained**
state, not a single frame. pfQuest waits 1 s before hiding its arrow for exactly this reason.

**AC-27 [L14]** — on arrival the beacon is **wiped**. Silently [L12] — no toast, no sound, no
chat line. The widget keeps the landmark for one-click re-pin.

**AC-28 [L17]** — on a **map-boundary refusal** we do **nothing**: do not fire arrival, do not
clear the slot, do not warn, do not restore. Attention has moved; the beacon is simply dark and
`[Map]` explains why.

**AC-29 [prior art: pfQuest]** — the arrival poll uses a **two-tier throttle**: ~1 s when the
player has not moved, with a floor of ~0.05 s when they have. Cheap when static, responsive
when moving.

**AC-30 [L16]** — distance is **never displayed** [L16]. It is polled for two internal
decisions only: **arrival** (AC-22–AC-24) and **`[Map]` visibility** (AC-14 trigger 2). No yard
count reaches the player anywhere in our UI — the beacon renders its own inside its own range
[F12], and beyond that the map is the instrument.

---

## 7. World-map pins

**AC-31 [F15]** — pins parent to **`WorldMapButton`** and position via
`SetPoint("CENTER", WorldMapButton, "TOPLEFT", x, y)` in pixel offsets — our stored map fraction
× frame size lands directly.

**AC-32 [L10, and the icon census]** — the **default** open-world landmark icon is
**`questbonusobjective-supertracked`** (`AtlasInfo.lua:657`,
`interface\minimap\objecticonsatlas`).

**All landmark pins render at ONE consistent size**, regardless of an atlas entry's native
dimensions — `Const.TextureKit.IgnoreAtlasSize` is the client's own mechanism for exactly this,
used by `WorldMapPOIMixin` and the AtlasBrowser. Native size is a hint, not a constraint.

**AC-33 [L11]** — hover shows the note via **`WorldMapTooltip`** [F15]. The note is **pulled,
never pushed** [L12].

**AC-34** — pins render **only for the map currently displayed**, matched on `mapID`.

**AC-35 [prior art: GatherMate, scoped down]** — the pin layer does **nothing while the world
map is hidden**, and rebuilds **on event, not on a timer**. No per-frame reposition loop.
*(Pooling is explicitly NOT required — out of bounds.)*

**AC-36 [RESOLVED — Battlewrath, 2026-08-12] — CLICK = GO, EDIT = I'M EDITING, NO GO.**

| Gesture | Effect |
|---|---|
| **hover** a pin | the note readout — inspection needs no click (AC-33) |
| **click** a pin | **sets the destination**: holds it in the widget and pins the beacon |
| **edit** a pin | opens the edit form (AC-40a) **and CLEARS live tracking** |

*"A simple click sets the destination, in line with how quests work."* `MapPoiPinMixin`
supports a per-pin `OnClickFunction` [F15].

**★ Why clicking may take the slot without breaching law 13:** hover already covers reading, so
**a click is a commitment gesture, not a browsing one**. Read by hovering, go by clicking.

**★ AC-36a — entering the edit form CLEARS the beacon.** You cannot be travelling to something
you are organising — those are different modes [L17], and the clear is a user act because
*opening the edit form* is one [L13]. It also removes an incoherent state where the beacon
points at a landmark whose position you are looking at in a form.

---

## 8. Notes and icons

**AC-37 [L11, refined by Battlewrath 2026-08-12] — the note is TWO FIELDS, not one blob:
`What:` and `Why:`.** Both free text, both optional [L4].

**★ Why two and not one:** law 18 says what a player loses is *the meaning and why*. A single
box invites a **label**; two boxes invite a **reason**. `Why:` is the product's core field — it
is the thing no other addon stores and the thing the player cannot reconstruct later.

The product stores no entity data, no spawn tables, no drop indices. We may one day *consume*
such data from those who own it [consumer-contract pattern]; we never author it.

**AC-38 [SIMPLIFIED — Battlewrath, 2026-08-12] — “stickers” are just LANDMARKS WITH A
DIFFERENT ICON.** There is no sticker layer. A landmark has **one icon**, chosen from a small
palette, and that is the whole of it.

**★ What this deletes:** the separate `sticker` field, the 32×32 overlay-on-a-64×64-marker idea,
and the open question of where a sticker gets chosen — the icon is a landmark property like
`what`, `why` and `Beacon hide`, so it lives in the same edit form (AC-40a). One concept fewer.

**AC-38a — CONTEXT sets the DEFAULT; the user may override it.** Law 10's context split
(open-world landmark · in-dungeon landmark · in-dungeon waypoint) still decides what you get
without choosing. Picking a palette icon replaces that default for that landmark.

> **Consequence, stated rather than assumed:** where a user overrides, the icon no longer
> carries the open-world / in-dungeon distinction. That is acceptable — **the map you are
> looking at already carries it.** The context split earns its keep on the *default*, which is
> precisely the case where nothing else distinguishes them.

**AC-38b [§9 delta 3]** — the palette stays **indicators, not per-entity nodes**. A farming icon
says *this area is a farm spot*, never *this herb spawns here* [L11].

**AC-38c [L19] — THE ICON IS PRESENTATION ONLY. Nothing keys off it.** No behaviour, filtering,
defaulting or sorting may depend on which icon a landmark carries. The `Beacon hide` tier is
already explicitly not implied by it (AC-40); **that is the general rule, not an exception**.
Changing a landmark's icon changes only what is drawn.

> Stated as a criterion because the violations sound helpful: *"a farm icon should set the farm
> tier"*, *"group the map by icon"*. Both are inference, and an icon chosen for how it **looks**
> would start deciding how the addon **behaves**.

**AC-39** — the palette ships with three entries, all census-verified free and all on
`objecticonsatlas`:

| Icon | Atlas | Registry |
|---|---|---|
| landmark *(default)* | `questbonusobjective-supertracked` | `:657` |
| farming | `vehicle-trap-gold` | `:296` |
| favoured vendor | `housing-decor-vendor_32` | `:697` |

**We curate; the user picks** [L19]. Every palette entry passes law 10's claim test against
`addons/maps/atlas/` **before it ships** — the user is never asked to judge whether an icon is
free. Adding one is a line of data plus that check.

**In-dungeon icons are out of scope for this build** (Battlewrath) — they belong to the route
half. Law 19 applies there unchanged when it comes.

**AC-40 [RESOLVED — Battlewrath, 2026-08-12] — the tier is a PROPERTY OF THE LANDMARK, set in
its edit form.** Not implied by the icon (that would have been inference, and inference makes
plausible wrongs), and not chosen at capture [L4, AC-7].

**★ The user-facing label is "Beacon hide", not "arrival tier"** — his wording, and better than
mine: it names **the visible effect** rather than our internal concept. The player sees a beacon
disappear; they never see an "arrival event". Law 18 applied to the label itself. *Code may keep
calling it arrival; the UI says Beacon hide.*

**AC-40a — the landmark edit form** (his sketch):

```
Name
What:
Why:

Beacon hide:
  ( ) Zone area        300 yd
  ( ) Within approach  100 yd
  ( ) Interact with      5 yd

Icon:  [landmark] [farming] [vendor]
```

**AC-40b — NO custom radius.** Considered and rejected:
- Each named tier carries a **meaning** — *the area* · *closing on it* · *at it*. A number carries
  none, and the user has to invent one.
- **The failure modes are asymmetric.** Without custom, someone who wanted 50 yd picks
  *Within approach* and the beacon hides slightly early — barely perceptible. With custom,
  **every** user meets a number field they must have an opinion about. That is the opposite of
  flattening decisions.
- There is a **floor** anyway: F31 brackets the engine's own arrival radius at **5.46–5.59 yd**,
  so anything under our 5 is inside the noise.

**Escape hatch if a real case appears: add a FOURTH NAMED TIER, never a number field.** That
keeps the setting a choice between meanings.

**AC-40c [RESOLVED by AC-38]** — the icon is chosen **in this form**, because it is a landmark
property rather than a separate thing laid over one.

**AC-41 [RESOLVED — Battlewrath, 2026-08-12] — the `Zone` line shows the RESOLUTION THAT IS
STILL USEFUL, and it is dynamic.** *"Resolution has utility. Out of zone? Show zone. Out of
sub-zone? Show sub-zone."*

| Where you are | Line 2 shows |
|---|---|
| a different zone | **the zone** — *"Winterspring"* |
| the right zone, wrong subzone | **the subzone** — *"Everlook"* |
| the right subzone | the subzone; you are there and the beacon has it |

**★ Same principle as `[Map]` (AC-14): say the thing that is actionable NOW, not a static
fact.** "Winterspring" is useless once you are standing in Winterspring; "Everlook" is what you
then need.

**On the apparent duplication with the name:** an un-renamed landmark reads *"Everlook 7"* /
*"Everlook"* once you are in the zone. That overlap is **transient and self-correcting** — the
name is **user-owned** and gets renamed (*"Bank alt"*), while line 2 is **system-owned** and
always accurate. The duplication only survives for landmarks the user never cared enough about
to name.

**AC-42 [RESOLVED — Battlewrath, 2026-08-12]** — note, icon, tier and name are edited in
**curation, never at capture** [L4]. **Two surfaces, both already in the design:**
1. **the widget** — click the name to rename the held landmark;
2. **the map pin** — edit a landmark from its pin.

**No separate management panel is required.** You are already looking at the map when you think
about your landmarks; that is where they are edited.

**★ This does NOT breach law 3** (*the map is an orientation surface, not an authoring
surface*), and the distinction is stated because it will otherwise read as a contradiction:
**law 3 forbids the map CREATING or RELOCATING a landmark** — position comes only from where the
player stood [L1, AC-2, AC-6]. Annotating something that already exists is not authoring a
position. The map may edit meaning; it may never edit place.

---

## 9. Honesty and failure

**AC-43 [bench standard]** — no silent truncation anywhere. If a limit is hit, it is reported.

**AC-44 [RESOLVED — Battlewrath, 2026-08-12, after measuring it]** — when
`showInGameNavigation` is off, **the map editor surfaces an easy tick to switch it on.**

**Detection is a direct CVar read** — `C_CVar.GetBool("showInGameNavigation")` — not an
inference from state. (F41 records the runtime signature for understanding: `Invalid`, tracking
**false**, `gp = -1`, **nil** distance — distinguishable from a map-boundary refusal, which keeps
tracking true, `gp = 1` and returns `0.00`.)

- **We never flip it silently.** The tick is a control the user clicks; the addon changes no
  setting on its own.
- **It lives in the map editor** — a surface the user deliberately opened while thinking about
  landmarks — not as a popup or a chat line. Behavioural, not instructional [L18].
- **Why this is proportionate:** the CVar is the master switch for the whole supertrack system
  [F40], so a player who turned it off also gave up their quest arrow and corpse arrow. They
  are not confused; they are configured. A tick where they are already working respects that,
  while a nag would not.

**AC-45 [bench standard]** — an offline smoke under `lua51` asserting every mechanical criterion
above, in `addons/tools/smoke/`, green before any deploy. **AC-24 and AC-26 must both be
directly asserted** — they are the two that fail silently in the field.

---

## 10. Explicitly out of scope

- The **route/follower half** — gated separately on the community answer [§8]. This is the
  landmark layer only, and per §9 the route becomes a load-or-share operation over the same
  understanding, **not necessarily the same code**.
- **Minimap anything** [L15].
- **Sharing, export, import** — the scrapbook is personal [§9 delta 4]. Law 7's *import wipes*
  exists for a shared artefact and may not apply here at all.
- **Any what-where database** [L11].
- **Travel assistance** [L18].
- **Frame pooling / lifecycle machinery** (Battlewrath, 2026-08-12).

## 11. What needs a ruling before build

**Nothing.** Every criterion in this document is either traced to a law or a proven fact, or
was ruled on by Battlewrath between 2026-08-12 and the close of the design pass.

| Closed in this pass | |
|---|---|
| the addon's name | `COA_Landmarks` |
| **AC-4** | auto-naming: `<subzone> <n>`, monotonic counter |
| **AC-16** | widget frame; minimap-button left = show, right = capture |
| **AC-21** | `QUEST_TURNED_IN` — accept the drop *(but AC-20 remains mandatory)* |
| **AC-36** | click = go, edit = no go |
| **AC-38** | “stickers” collapse into the landmark's icon |
| **AC-40** | tier is a landmark property, labelled *Beacon hide*, no custom radius |
| **AC-41** | `Zone` line shows the resolution still useful |
| **AC-42** | curation happens in the widget and on the pin |
| **AC-44** | CVar-off surfaces a tick in the map editor |

**Two criteria carry the sharpest risk and must be asserted directly in the smoke (AC-45):
AC-24** (arrival requires a valid state, because a refusal reports `sd = 0.00`) **and AC-26**
(debounce before acting on `Invalid`). Both fail *silently in the field*.
