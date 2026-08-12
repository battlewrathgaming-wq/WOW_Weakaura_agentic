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
| `note` | user text, may be empty [L4] |
| `sticker` | user-chosen, may be empty |
| `arrivalTier` | one of three [L14] |
| `scope` | `character` or `account` [§9 walk stop 2] |

**AC-2 [L1, L2]** — position is captured **where the player stood** and is **never rewritten**.
No edit path may relocate a landmark. Renaming, re-noting, re-stickering and re-tiering are all
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
note, sticker or tier.

---

## 4. Capture

**AC-6 [L1, L3]** — a landmark can only be born **where the player is standing**. There is no
path that creates one by clicking the map.

**AC-7 [L4]** — capture **asks nothing**. No dialog, no note prompt, no sticker picker, no tier
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

**AC-16 [P]** — the widget must be **movable and hideable**, and its position must persist.
Standard for any always-visible frame; not covered by a law.

---

## 6. Beacon control — the slot discipline

This section carries the sharpest failure modes. **F38's guard is the single criterion most
likely to be skipped and most damaging if it is.**

**AC-17 [F24]** — set the beacon **only** via `SuperTrackerUtil.SetSuperTrackedPosition(x,y,z,mapID)`.
Calling `C_SuperTrack.SetSuperTrackedPosition` directly bypasses the client's priority ladder;
it appears to work and is then silently overwritten by the next re-evaluation.

**AC-18 [F24]** — we keep **our own copy** of the pinned landmark. `SUPER_TRACKED_POSITION` is
the client's global and it **nils it** whenever `showInGameNavigation` is off. Our intent must
survive that.

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

**AC-21 [O]** — `QUEST_TURNED_IN` calls `SelectQuestLogEntry` **unconditionally**, so a naive
yield-hook drops the pin on every hand-in. Two settled options: **(a)** accept it — turn-in is
quest-flow activity; **(b)** yield only when the selected questID actually *changed* — change
detection, not intent detection. **Battlewrath leaned (a)** on the grounds that questing and
scrapbook use are different modes that take turns [L17]. Recorded as [O] pending a final word.

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

**AC-32 [L10, and the icon census]** — the open-world landmark icon is
**`questbonusobjective-supertracked`**, 64×64, `interface\minimap\objecticonsatlas`
(`AtlasInfo.lua:657`). Stickers are **32×32** — half size, so they read as annotation *on* a
thing rather than *a* thing.

**AC-33 [L11]** — hover shows the note via **`WorldMapTooltip`** [F15]. The note is **pulled,
never pushed** [L12].

**AC-34** — pins render **only for the map currently displayed**, matched on `mapID`.

**AC-35 [prior art: GatherMate, scoped down]** — the pin layer does **nothing while the world
map is hidden**, and rebuilds **on event, not on a timer**. No per-frame reposition loop.
*(Pooling is explicitly NOT required — out of bounds.)*

**AC-36 [P]** — **clicking a pin sets it as the widget's held landmark and pins the beacon.**
`MapPoiPinMixin` supports a per-pin `OnClickFunction` [F15], and this is the natural retrieval
gesture — *find on the map, click, go*. **Proposed, not derived from a law.**

---

## 8. Notes and stickers

**AC-37 [L11]** — a note is **free text about meaning**. The product stores no entity data, no
spawn tables, no drop indices. We may one day *consume* such data from those who own it
[consumer-contract pattern]; we never author it.

**AC-38 [§9 delta 3]** — stickers are a **palette the user chooses from**, unlike the marker
symbol which context decides. They are **indicators, not per-entity nodes** — a farming sticker
says *this area is a farm spot*, not *this herb spawns here*.

**AC-39** — two stickers ship, both free, both 32×32 `objecticonsatlas`:
`vehicle-trap-gold` (farming, `AtlasInfo.lua:296`) · `housing-decor-vendor_32` (favoured vendor,
`:697`).

**AC-40 [O]** — **where the arrival tier is set.** Capture asks nothing [L4], so it needs a
default plus an edit. Undecided between a **fixed default** and **the sticker implying it**
(vendor → interact, farm → zone area). The latter removes a decision but is inference, and
inference makes plausible wrongs.

**AC-41 [O]** — the widget's `Zone` line: zone, or subzone when one exists
(*"Winterspring — Everlook"*)? One line, real effect on a vendor pin.

**AC-42 [RESOLVED — Battlewrath, 2026-08-12]** — note, sticker, tier and name are edited in
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

**AC-44 [O — HELD, NOT DESIGNED]** — behaviour when `showInGameNavigation` is off.

**Basis only, per Battlewrath (2026-08-12): *"Record the basis not the proposition."*** The
facts, and nothing built on them:

- The CVar is the **master switch for the entire supertrack system**, tested above the priority
  ladder — so the quest arrow and corpse arrow go with it [F40]. It is a user-facing checkbox in
  the Display options panel.
- Turning it off makes the client **clear the supertracker**, which nils `SUPER_TRACKED_POSITION`
  [F24 ②] — **read in source, never observed.**
- **The off path is unmeasured** [F41]: all three probe runs ran with it on. `NavigationState`
  values `Occluded` (1) and `Disabled` (3) have never been seen in 1,758 samples.

**No criterion is written here until the probe runs** (§7 of the ledger carries the exact test).
Designing for an unobserved path is how a plausible wrong gets built.

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

| | |
|---|---|
| ~~AC-4~~ | **RESOLVED** — `<subzone> <n>`, monotonic counter, rename in widget or from the pin |
| ~~AC-42~~ | **RESOLVED** — curation happens in the widget and on the map pin; no separate panel |
| ~~the addon's name~~ | **RESOLVED** — `COA_Landmarks` |
| **AC-36 [P]** | pin click → hold + pin the beacon |
| **AC-40 [O]** | where the arrival tier is set |
| **AC-41 [O]** | `Zone` vs `Zone — Subzone` on the widget line |
| **AC-21 [O]** | the `QUEST_TURNED_IN` yield |
| **AC-16 [P]** | widget movability |
| **AC-44 [O]** | CVar-off behaviour — **held pending measurement**, basis recorded, nothing designed |
