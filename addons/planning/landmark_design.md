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

**Reading order for anyone arriving cold: THIS FILE FIRST — it is the spec.** Reach for
`satnav_ledger.md` (19 laws, F1–F41) only when a criterion's *why* is in question; every
criterion cites it by `[Ln]`/`[Fn]`. `satnav_prior_art.md` covers the three addons inspected.
**§12 is what we are actually building now.**

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
| `mapC`, `mapZ` | `GetCurrentMapContinent/Zone()` — **which map the fraction belongs to.** `mapID` is the continent (F30), not the zone the world map draws, so without these every landmark on a continent would render on every zone map in it (AC-34) |
| `alias` | the **display** name, user-editable — defaults to `subzone int` (AC-4) |
| `what`, `why` | two free-text fields, either may be empty [L4, AC-37] |
| `icon` | user-chosen from a palette; defaults by context [AC-38] |
| `tags` | a plain comma-separated string, **as typed** (AC-54) |
| `tier` | one of three [L14]. *(Stored as `tier`; the UI calls it "Beacon hide" — AC-40.)* |
| `owner` | **one field, two forms**: `"global"` or a character name (AC-46) |

**★ `id` is the TABLE KEY, not a field in the record.** `landmarks["Winterspring-Everlook-7"]`
— it is not stored inside, because a key and a copy of the key can disagree. AC-47 governs its
form.

**AC-2 [L1, L2]** — position is captured **where the player stood** and is **never rewritten**.
No edit path may relocate a landmark. Renaming, re-noting, changing the icon and re-tiering are all
permitted; moving is not.

**AC-3** — `mapID` is stored but **must never be treated as a zone**. Any code comparing
"same place" uses `mapID` for *map identity* and `zone` only for *display* [F30].

**AC-4 [RESOLVED — Battlewrath, 2026-08-12] — the ALIAS is auto-generated at capture, and it
carries ONLY WHAT WE KNOW.** Capture asks nothing [L4] but the widget shows a name, so one must
exist without a prompt.

**Alias format: `<subzone> <n>`** — *"Everlook 7"*. Subzone when present, **else the zone**.

> **★ THE ALIAS IS NOT THE IDENTITY (Battlewrath):** *"We bespoke a unique name.
> Zone-subzone-int. We present an alias of subzone-int, and it's that alias that can be renamed,
> the unique identity survives."* The user renames the **alias**; the `id` (AC-47) never
> changes. Everything below governs the alias.

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

**AC-5a [Battlewrath, 2026-08-12 — the three scope questions, answered]**

| His question | Answer |
|---|---|
| **1. Are they global stored or character specific?** | **Both, and it is not a contradiction.** ONE account-wide file (AC-46), with `owner` on each record. **Stored** globally; **scoped** per character by the field. Default is the capturing character |
| **2. The user cannot set global or character specific** | **Correct — that was the gap.** §12 deferred the *control*, never the field. `Store.SetOwner` has worked since v0.1.0; there was simply no way to reach it. **Now shipped as a dropdown**, the same stock `UIDropDownMenu` the client's own bug-report selector uses (`BugReportFrameMixin.lua:69`) |
| **3. Do they render in line with that? Global when global. Character when character + global** | **Already built, and it is the only visibility rule in the addon.** `Store.VisibleToMe` → `owner == "global" or owner == me`. Every surface reads it — pins, `/lm list`, the minimap count, and the tag pool — so there is one definition and nothing can drift from it |

**★ WHY A BINARY AND NOT A PER-CHARACTER LIST (Battlewrath):** *"cuts the noise from 'every
character I have' (10 max) to 'is it specific to this character or not'."*

A visibility **list** would be a ten-checkbox matrix on every landmark. The binary is not a
simplification of that — **it is the question the player actually asks**: *is this mine, or
everyone's?* Nobody holds "this is for my rogue and my mage but not my priest" in their head,
and a UI that offers it invites them to invent a taxonomy they do not have. **That is the
cataloguing failure mode again** (§11's exhaustiveness test), arriving through a settings
screen instead of through the data.

**Do not turn this into a multi-select.** If a real case ever appears it is one landmark
duplicated, not a matrix on all of them.

**★ HANDING A LANDMARK TO ANOTHER CHARACTER — the detour, and why it is ACCEPTED
(Battlewrath, 2026-08-12):** *"I found this spot for my druid to herb at, so I make it global,
log my druid, make it specific. But I think in a way that fits. This is a process of curation.
Not mapping the world."*

Three steps: promote to global · log in as the other character · demote, which claims it
(AC-46). **Accepted, and recorded as accepted so it is not later "fixed".**

His reason is proportionality — curation is a considered act, not a bulk operation — and there
is a second, stronger one:

> **★ THE ALTERNATIVE WOULD REQUIRE US TO KNOW YOUR CHARACTERS.** A "give this to…" picker
> needs a **roster**: a stored list of your alts that goes stale on deletes, renames and
> transfers, that nothing prunes, and that **we would own**. That is the tag-registry problem
> (AC-54d) wearing different clothes.
>
> **The detour needs no roster at all.** The character **claims itself by being logged in** —
> `UnitName("player")` is always current and always correct. The addon never learns who your
> alts are, and therefore can never be wrong about them.

**★★ AC-5b — ORPHANED RECORDS, and the recovery path (Battlewrath, 2026-08-12).** *"When you
delete a character. The items still exist, just no one has the ID to see them. So on the map
editor UI, we probably need a admin tick, and a way to load all."*

**A real defect, and the exact price of holding no roster.** Delete a character and its
landmarks keep an `owner` nothing will ever match again — present in the file, unreachable,
unrecoverable. **We cannot detect this**: not knowing your characters is the deliberate choice
that keeps us from owning a list that rots (AC-5a). So the answer is **not detection, it is a
way to STOP FILTERING**.

**v1 ships `/lm all`** — a toggle that unfilters. Orphans appear, the pin tooltip and `/lm list`
**name the owner** (that being the whole reason you are looking), and the edit form's
`Visible to` claims one back. **Session-only, off at every login:** it is a recovery mode, not
a view preference, and "everything on the account" is not how you look at your own landmarks.

**The admin tick belongs in V2's editor** (§14) where there is a surface for it; the slash
toggle is the v1-sized version of the same thing.

> **★ Why this is the RIGHT shape rather than a workaround:** it needs no roster, no detection,
> no cleanup pass and no stored state. It does not learn that a character is gone — it just
> stops hiding things, and lets the person who knows do the deciding. Every alternative
> (prune orphans, track characters, warn on deletion) requires us to know something we
> deliberately do not.

**★ AND THE FIX COST A FILTER, NOT A FEATURE (Battlewrath):** *"the same global or me gets to
be re-used for free."* Recovery needed only **visibility** — the *claim* was already there.
`owner` now does three jobs with **one field write and no new verb**:

| Job | Mechanism |
|---|---|
| who can see it | `owner == "global" or owner == me` |
| handing it to an alt | promote → log in → demote, which claims it |
| rescuing an orphan | show-all → demote, which claims it |

**This is AC-46's "one field, two forms" paying off later than it was decided.** Collapsing
`scope` and `owner` into a single value meant every scope-shaped problem since has had the same
answer — and the third one arrived without needing anything built for it.

Asserted in the smoke: an orphan is invisible normally, surfaced by show-all, and claimable.
Mutation-tested — removing the unfilter fails with *"show-all did not surface the orphan"*.

**★★ AC-5c — THE TRANSFER CONTROL, and why the identity format is LEFT ALONE (Battlewrath,
2026-08-12).** On same-name-different-realm collision: *"cross realm is very niche whilst
predictable. And lives in the editor as a transfer option."* Shape given:
`[Old name with autocomplete](Built from record instead of construction)[Me]`

**`owner` stays a bare character name.** Switching to `name-realm` would orphan every existing
record to fix something rare and, when it happens, obvious. **An escape hatch beats a
migration.**

- **The source list is BUILT FROM THE RECORD** — `Store.KnownOwners()` returns the distinct
  owners actually present, excluding `global` and yourself (neither is a transfer *source*).
  **The same rule the tag pool follows (AC-54a): mirror the data, assemble nothing.** We still
  never learn who your characters are — only who owns something *here*, a smaller claim.
- **Bulk, not per-landmark.** A deleted character may have left thirty. One click, not thirty.
- **Shown ONLY in the show-all recovery view** (AC-5b). It is an admin tool; the normal edit
  form never carries it.
- **Built as a SELECTOR, not free-text-with-autocomplete** — judgment call, stated. The set is
  small and known from the records, and a typo in a bulk reassign is worse than a click.

**★ TARGET IS ME **OR** GLOBAL, which wraps two jobs into one control (Battlewrath):** *"maybe
the new owner is Me or Global. Then it wraps up both transfer and delete recovery."* `[to me]`
`[to all]` — **the same two forms `owner` has always had (AC-46)**, so no third state was
needed. Recovering a deleted character's landmarks *for everyone* is one click rather than a
claim followed by promoting each.

*(A button reads "me" where the dropdown above reads "Only Gravekeeper". Not an inconsistency:
the dropdown **displays stored state** about a record that may not be yours, so it must resolve
the name; a button you are pressing has an unambiguous actor.)*

**★ AND THE CROSS-REALM CONCERN RETIRES rather than defers (Battlewrath):** *"same-name cross
server has no place, as we capture name not server so it will work out the box."* A collision
makes two characters **share** — nothing is lost and nothing is orphaned. It is an unusual
outcome, not a failure mode. And if the sharing is unwanted, **the transfer control is already
the valve.** No `name-realm` migration, and no follow-up owed.


**★ One consequence made VISIBLE rather than left to be discovered:** demoting a global
**claims it for whoever is standing there** (AC-46: "demotion assigns the current character").
So the dropdown reads **"Only Gravekeeper"**, not "this character" — the label states the
outcome. L18: show what will happen, do not explain it afterwards.

**AC-5 [§9 walk stop 2, mechanised by AC-46]** — `owner` defaults to the **capturing character**
and moves **both ways** by rewriting that one field: promote by setting it to `"global"`, demote
by setting it back to a character name. Neither direction touches anything else, so neither can
lose the note, icon or tier.

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

**★ `What` is a LINE; `Why` is a PAGE.** `What` is a short label — *"Bank + reagent vendor"*.
`Why` is a **multi-line free area**, and it is therefore the free-hand section: prompted with
the question that matters, but not rationed once you are writing. That is both halves of the
governing metaphor at once — law 18 says *why* is the thing that gets lost, so it earns the
prompt; *"a page doesn't really know what you've drawn"* says the space should not be measured
out.

**No third field in v1.** Two are a *prompt*, not a schema; a third labelled box people do not
need turns the form into paperwork, and empty boxes invite guilt. If use shows otherwise,
adding a field is a `schemaVersion` bump — **which is exactly what AC-48 was built for**, so
this is a decision we need to be able to *change*, not to get right now.

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

**AC-54 [Battlewrath, 2026-08-12] — `tags`: a plain comma-separated string, stored AS TYPED,
with NO tag registry.** *"I'd have tags as markdown… Tags:<string>,<string>,<string>, and the
filter can detect strings and offer them."*

- **Stored raw — exactly the characters the user typed.** We never normalise on write, never
  reorder, never de-duplicate. Splitting on `,` and trimming happens **at read time**. That is
  AC-49 (readable without our code) and the inert principle: *a page doesn't know what you
  drew*.
- **★ NO TAG REGISTRY, and this is the load-bearing part.** There is no managed vocabulary, no
  "edit your tags" screen, no predefined set. **The filter discovers tags by scanning the
  records and offers back what it finds.** We never own the list — the user's typing *is* the
  list.
- **The FIELD ships in v1; the FILTER is V2** (§14). Same pattern as AC-5's `owner`: adding a
  field later means migrating someone's landmarks, adding it now costs a line. And a v1 that
  accepts tags **tells us whether anyone tags at all**, which is the evidence that decides
  whether V2's filter is worth building.
- **★ WE NEVER ALTER OR CLEAN UP TAGS (Battlewrath):** *"I wouldn't alter or clean up tags…
  it's their tagging. They can use it how they wish."* No trimming on write, no case-folding,
  no merging near-duplicates, no rejecting odd ones. If someone uses tags as a to-do list, a
  rating, or something we would not have thought of, that is the point — *a page doesn't know
  what you've drawn*.

**AC-54a — AUTOCOMPLETE from tags the user has already made, and it is the OTHER HALF of not
normalising.** *"We can offer auto complete once they've made a tag else where."*

**Without it, "we never clean up" means tags drift into uselessness. With it, they converge on
their own.** Type `vendor` once and you are offered `vendor` next time and will probably take
it — so duplicates fall away **without us ever policing them. The fix is affordance, not
enforcement**, and it answers the case-and-duplicates question better than a rule would.

- **It OFFERS; it never CORRECTS.** Decline the suggestion and type something new and nothing
  argues. It never rewrites what you typed and never merges `Vendor` into `vendor`.
- **★ THE METHOD IS INLINE COMPLETION WITH A HIGHLIGHT (Battlewrath, 2026-08-12, after using
  v0.1.0):** *"Both the add friend, and mail-box create - add name, used in-line text suggestion
  with a highlight and match fine."* Type `ven`, the box reads `vendor` with `dor` highlighted;
  keep typing and the proposal is replaced; leave it and it is accepted. **No chips, no
  dropdown, no extra surface** — the box completes itself rather than offering something to
  click, which is L18 applied to an input.
  - The client's own mechanism cannot be reused: `AutoComplete_Update` /
    `GetAutoCompleteResults` is a C API that returns **player names only**, and this fork's
    `AutoCompleteInputMixin` is a **dropdown list** (the Bug Report search box), not this. The
    behaviour is **replicated, not borrowed**.
  - **Complete only when the user ADDED characters.** Completing on a delete makes the box
    fight you — backspace, get the letter handed back, forever.
  - **Exclude the record being EDITED from the scan.** Tags save on every keystroke (stored as
    typed), so without this the half-word in the box is already stored and the suggestion is
    the user's own typing handed back. Found live in v0.1.0; now a smoke regression.
- **Same mechanism as the filter (AC-54), pointed at input instead of output:** scan the
  records, offer back what is there. **We still own no vocabulary.**
- **★ It ships WITH the tag input, in v1** — not with the V2 filter. The two halves of this
  decision have to land together: shipping "never normalise" without autocomplete is shipping
  the drift and none of the cure, and it would pollute the very A:B signal the field exists to
  produce. The scan is a loop over tens of records (AC-50).

**AC-54d — A TAG EXISTS ONLY WHILE SOMETHING CARRIES IT. Deleting the last landmark holding a
tag removes it from the pool.** Observed by Battlewrath, 2026-08-12: *"I made a tag, then
deleted the item, then tried to call that tag else where, and it wasn't found."*

**Working as designed, and the design is AC-54's own:** there is no registry, because we own no
vocabulary — the user's typing *is* the list. `KnownTags()` scans the landmarks. No carrier, no
tag.

> **★ RECORDED BECAUSE IT LOOKS LIKE A BUG AND IS NOT.** The obvious "fix" is a table of
> previously-seen tags. That is **a vocabulary we own** — precisely what AC-54 refuses — and it
> brings everything that follows: it outlives the data, it rots, nothing ever prunes it, and it
> offers words for things that no longer exist. It also fails the governing metaphor outright:
> tear out the page and the word does not persist somewhere else. **Do not add a tag registry.**

The cost is real but small: delete a landmark and immediately re-tag another the same way, and
you type the word again. Weighed against a store that quietly accumulates dead vocabulary, that
is the better side.

**AC-54c — GHOST TEXT on the tags field: `separate with ,  or press enter / tab`**
(Battlewrath, 2026-08-12). Shown only while the field is **empty** — including while focused,
which is exactly when someone about to type needs the format. Erases itself on the first
keystroke.

**The failure it prevents is SILENT:** *"I can see a case where users write `vendors pvp get
50k honor` and not know how to use the tags."* That becomes **one long tag**, the filter never
groups anything, and nothing ever says why. His fix, and his reasoning for the form: *"Seeing
this across land marks will engrain it."*

> **★ THIS IS THE BOUNDARY OF LAW 18, AND IT IS WORTH KNOWING WHERE IT IS.** L18 asks whether
> we can **DO** the thing instead of **TELLING** — and here **we cannot**. Inserting commas at
> spaces would be altering the user's input, which AC-54 forbids outright. **With no
> behavioural fix available and a silent failure on the other side, a label at the point of use
> is the honest answer.**
>
> The bar it must clear, and does: **in situ · self-erasing · zero persistent noise · taught by
> repetition, not by a tutorial.** It is a field label, not a lesson — nobody reads a form's
> placeholder as instruction. Anything that fails those tests is back on the wrong side of L18.

> **⚠ This is NOT the third note field rejected in AC-37.** That was a third place to write
> **prose**, and it was refused because two labelled boxes are a prompt while three are
> paperwork. **A tag is not prose — it is a label for retrieval.** Different job, and it is the
> legitimate exception to law 19 flagged in §14: nothing keys off the **icon** because an icon
> is chosen for how it *looks*; tags exist **to be keyed off**, because the user authored them
> as categories.

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

Tags:  [vendor, winterspring, alt        ]
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

---

## 12. v1 BUILD SCOPE (Battlewrath, 2026-08-12)

**Audience: him.** *"Build it for me. If we later get adoption and improvement. Great."* So v1
is not a release — it is the thing we use to find out whether the design is right. That lowers
the bar on polish and **raises it on honesty**: a v1 that misbehaves teaches us about the
misbehaviour, not about the design.

**Three systems, his words:**

1. **The widget**
2. **A manifest / system to handle each landmark**
3. **A basic in-map click landmark edit option**

**All per character, with scalability into per account in mind.**

### In scope

| Block | Criteria |
|---|---|
| **The manifest** — record, storage, add/remove/lookup | AC-1, 2, 3, 4, 4a, 4b, 5† |
| **Capture** | AC-6, 7, 8, 9, 9a |
| **The widget** | AC-10, 11, 12, 13, 14, 14a, 14b, 15, 16 |
| **Beacon control** — the slot discipline | AC-17, 18, 19, 20, 20a, 21 |
| **Arrival** | AC-22, 23, **24**, 25, **26**, 27, 28, 29, 30 |
| **Map pins + click-to-edit** | AC-31, 32, 33, 34, 35, 36, 36a, 40a, 42 |
| **Notes** | AC-37, 41, **54, 54a** (the `tags` field, its input line and autocomplete — the FILTER is V2) |
| **Standing rules** | AC-38c, 40b, 43, **45** |

† **AC-5 in v1 means the `owner` FIELD, not the promote/demote UI.** Per character now; the field and the
storage shape carry account-level from day one, because adding a field later means migrating
someone's landmarks. *"Scalability into per account in mind."*

**★ Arrival is in scope even though he did not name it** — it follows from what he did name: the
edit form (system 3) carries `Beacon hide` (AC-40a), which is meaningless without arrival
detection, and law 14 says arrival always wipes. Without it the beacon never clears itself and
F6's engine behaviour stands unopposed. **Flagged rather than assumed silently.**

**★ Why the whole slot discipline is in v1 despite being invisible when correct:** its wrongness
**corrupts the feedback**. An addon that steals the quest arrow, or fires *arrived* on zoning
into a dungeon, generates reports about the bug and teaches us nothing about the design.
**AC-24 and AC-26 fail silently** — a v1 without them looks fine and quietly teaches us wrong
things. They are the two that must be asserted directly in the smoke (AC-45).

### Deferred to the A:B loop

| | Why it is safe to hold |
|---|---|
| ~~AC-5's promotion toggle~~ | **SHIPPED v0.1.6** — he asked for it directly, which answers the "does anyone want account scope?" question the deferral was waiting on (AC-5a) |
| **AC-38, 38a, 38b, 39** — the icon **palette** | law 19 made icons pure data, so this is the **cheapest thing in the design to iterate**. v1 ships the **default icon only**; the edit form gains an icon row when the palette does |
| **AC-44** — the CVar-off tick | rare path, now measured, lands whenever |

**Nothing else is deferred.** `[Map]` (AC-14) and the dynamic `Zone` line (AC-41) are each a few
lines — tracking them as deferred work would cost more than building them.

### ★ THE GAP THIS EXPOSED — v1 must choose a DEFAULT TIER

Capture asks nothing (AC-7), so **every new landmark is created with a `Beacon hide` value, and
the brief never says which.** Found by the 2026-08-12 audit.

**DECIDED (Battlewrath, 2026-08-12): `Interact with`. *"Baseline, match the game. Within 6-5
yards."*** The default is not a tuning choice — it is **the game's own interaction range**, so a
landmark behaves like everything else you walk up to and use.

**★ THREE INDEPENDENT THINGS AGREE ON ~5 yd, and they were arrived at separately:**
1. **The game's interact range** — his reason, and the one that matters, because it is the
   distance a player's hands already know.
2. **Law 14's tier**, chosen on taste **before any of it was measured**.
3. **The engine's own arrival radius — 5.46–5.59 yd**, bracketed from 1,857 samples across two
   runs (F31, F37).

Our 5 sits just **inside** the engine's boundary, which is the correct side: we fire marginally
**later** than the engine would, never earlier.

Supporting reason for erring tight, kept because it generalises: **the failure modes are not
symmetric — a beacon that lingers slightly too long is invisible, while one that vanishes early
reads as broken.** And it is the cheapest thing to learn from, since the first tier he changes
hands us the real answer.

### What v1 is FOR — the questions it answers by being used

Named before building, because they decide what is worth watching:

- **Does `Why` get filled in, or only `What`?** Tests law 18's central premise directly.
- **Which tier gets set most?** Hands us the default above, from evidence.
- **Does he rename, or live with `Everlook 7`?** Tests AC-4.
- **How many landmarks accumulate?** Decides whether retrieval ever needs more than the map —
  §9 delta 2's *find* problem is currently theoretical.
- **★ Does the beacon-vs-quest contention actually occur?** Law 17's *"different modes take
  turns"* is reasoning, not evidence, and **AC-21's accept-it rests on it**. v1 makes it
  evidence.

### ★ HOW TO READ THE SIGNAL — a usage pattern has TWO readings (Battlewrath, 2026-08-12)

*"Or evidence they need to use another addon. We can't compete in that problem. The questing
addon has a whole data base. So does gathermate (can be imported.) and I'm not interested in
competing. This is the gap of personal knowledge and style."*

**This is the rule that keeps an A:B loop from eating the product.** Every observation above can
be read two ways, and the second reading is the one that is easy to miss:

| Observed | Reading 1 | ★ Reading 2 |
|---|---|---|
| `Why` fills with route hints | we need a third field | **they want a routing addon** — ours later, or pfQuest now |
| landmarks pile up per-node | retrieval needs search | **they want GatherMate**, which has the database and *can be imported* |
| people log what spawns where | add structure for it | **that is `what exists`, not `how I play`** [L11] |

### ★ THE TEST IS EXHAUSTIVENESS, NOT SUBJECT (Battlewrath, 2026-08-12)

*"The line I'm fine with walking is rare spawns and the like. But that's in the personal
interest scope. So that fits. If it's all rare spawns. That's another addon."*

**No subject is out of bounds. Completeness is.**

| | |
|---|---|
| a rare you camp, marked because you care | **how I play** — fits, and always did |
| **every** rare in the zone, marked systematically | **what exists** — a catalogue, and someone else's |

Same subject, different mode. **You can only be exhaustive about things that exist
independently of you** — which is why completeness, not topic, is the signature of *what
exists*. It is also a kinder rule: it forbids nothing a player might care about, and only
names the point at which they have started cataloguing rather than playing.

**⚠ This governs how WE read feedback — NOT how the addon behaves.** The addon never inspects
content, counts categories, or notices patterns; it stays inert (see the governing metaphor's
architectural half). We would only ever learn this by **talking to a user**, and the response is
to name a better-suited addon — never to detect it in code and say something.

**Default to reading 2 when the pattern is DATA-SHAPED.** pfQuest ships a full quest and unit
database; GatherMate ships a node database and an import path. Those are real answers already
built by people with far bigger records. **The honest response to a user reaching for one of
them is to name the addon, not to grow toward it.**

Growing toward it would also cost us the thing we have: *this is the gap of **personal knowledge
and style***, and that gap only stays visible while we refuse the data problem next to it.

---

## 13. STORAGE — the mechanical spine (Battlewrath, 2026-08-12)

*"My main interest is the storage over the UI feel. We can tinker with the feel, but the
mechanical systems should be well developed / defined. Or a willingness to re-write when we
need to. Rather than building on patches."*

**★ THE PRINCIPLE THAT FALLS OUT: what is expensive to change is what is PERSISTED.** UI is
free — a widget can be redrawn on a whim and nobody loses anything. A stored shape carries
someone's landmarks, so getting it wrong means either a migration or a loss. **§3 is a field
list; this is the design.** §3's `AC-1` remains the authority on *which* fields exist; this
section says how they live.

**Nothing in §13 is derived from a law** — no law covers storage. Every decision below is marked
**[P]**, and the two marked **[P!]** are the ones that are **hard to reverse**.

### AC-46 [P!] — ONE account-wide SavedVariables, with `owner` ON THE RECORD

```
## SavedVariables: COA_LandmarksDB
```

**Not** `SavedVariablesPerCharacter`. Everything lives in the **same file**; visibility is a
read-time filter on `owner`.

**★ `owner` is ONE FIELD WITH TWO FORMS (Battlewrath), not a `scope` plus an `owner`:**

| `owner` | Meaning |
|---|---|
| `"global"` | visible to every character on the account |
| `"Gravekeeper"` | visible to that character only |

Promotion and demotion are **the same operation** — write the field. Demotion assigns the
**current** character.

**Why this is the decision that matters (his words):** *"it's that what we change, instead of
file movement where it can deform."* If character data lived in a per-character file, promotion
would be a **migration between two files** — read from one, write to the other, and be correct
about failing halfway through. **A half-completed migration deforms the data; a half-completed
field write cannot happen.**

Cost of the choice, stated: every character loads every character's landmarks. At tens of
records this is nothing, and if it ever is not, the fix is a read-time index rather than a
change of shape.

### AC-47 [P!] — IDENTITY is a bespoke `zone-subzone-int`, and the ALIAS is what gets renamed

**`id` = `zone-subzone-int`** — e.g. `Winterspring-Everlook-7`. Composed once at capture,
**immutable for the life of the record**. Uniqueness comes from the `int` (AC-4's account-wide
monotonic counter, never reused — AC-51); the `zone-subzone` prefix is there to make the stored
file **legible to a human reading it**, which is AC-49's whole point.

**`alias` = `subzone int`** — *"Everlook 7"* — is what the widget and the pin show, and **the
only thing a rename touches** (AC-4b). *"The unique identity survives."*

**★ THE ID IS OPAQUE TO CODE; THE FIELDS ARE THE LOOKUP (Battlewrath).** *"It should still
hold, as you do, MapID, zone and sub-zone as the look up records."* The composed id exists for
**uniqueness and legibility** — *"to keep the names more unique than not. Less chance of a wrong
read."* **Every lookup reads the stored `mapID` / `zone` / `subZone` fields**, never a substring
of the id.

Same rule as AC-3 (`mapID` is never treated as a zone), and for the same reason: the moment
something parses the id, the fallback case (no subzone → `zone-int`, two parts not three)
becomes a crash. **This is also why those fields are stored separately rather than derived** —
they are not duplication of the id, they are the index.

**Two things that can never be identity:** the **alias**, because the user renames it; and the
**position**, because it is frozen (AC-2) but not unique — two landmarks may share a spot, and
comparing floats for equality is a bug waiting to happen.

### AC-48 [P!] — a `schemaVersion` on the DB, from the first line of code

```lua
COA_LandmarksDB = {
  schemaVersion = 1,
  nextId        = 8,
  landmarks     = {
    ["Winterspring-Everlook-7"] = {
      alias = "Everlook 7", owner = "Gravekeeper",
      what = "", why = "", icon = "questbonusobjective-supertracked",
      arrivalTier = "interact",
      x = ..., y = ..., z = ..., mapID = 1, mapX = ..., mapY = ...,
      zone = "Winterspring", subZone = "Everlook",
    },
  },
}
```

**This is what makes "willingness to re-write" mechanically possible rather than aspirational.**
A rewrite is only cheap if the new code can *recognise* and *read* the old data. Without a
version stamp, the choice at rewrite time is guess-the-shape or discard-the-user's-work — which
is precisely the patching-on-patches he is refusing.

**Rule: the loader reads any version it knows and refuses cleanly on one it does not** (AC-43:
no silent anything). It must never *guess* at an unversioned or future shape.

### AC-49 [P] — the persisted record is DATA ONLY

No functions, no frames, no derived values, no caches. A landmark is a flat table of the AC-1
fields plus its `id`. **Nothing in the file may require code to interpret it** — that is what
lets a future version read it, and what lets us read it with `py` from a landed record.

Corollary of law 19: **the `icon` is a plain atlas-name string.** Nothing keys off it, so it
persists as a name and nothing more.

### AC-50 [P] — NO index. Iterate the flat list.

Rendering pins for the displayed map (AC-34) means "landmarks where the **`mapID` field**
matches" (AC-47 — the field, never the id). At tens of records that is a loop.

**★ The scale is bounded by the product, not by optimism (Battlewrath):** *"This is regions of
activity, not per-node tracking... the total pool and data store will never be that heavy."*
A per-entity spawn database would be tens of thousands of rows and would need real indexing;
**that is explicitly other addons' work** [L11]. Ours is the handful of places one player
cares about. **A `mapID`-keyed index would be a second structure to keep
consistent with the first**, and consistency bugs outlive the performance they buy.

Same reasoning as the pooling decision (§2): do not import a solution to a problem we do not
have. If the loop ever costs anything measurable, `task_perf` measures it and we revisit with
numbers.

### AC-51 [P] — deletion is a hard delete; the counter never rewinds

Remove the record. **No tombstones** — nothing in v1 syncs or shares, so nothing needs to know a
record once existed. `nextId` **never** decreases, so a deleted landmark's id is never handed
to a different one, and AC-4's freshness ordering survives deletion.

### AC-52 [P] — what is NEVER persisted

The held landmark, the beacon state, pin frames, the supertrack slot, anything read from the
client at runtime. **Session state dies with the session** — AC-15 and law 13 already require
this for the beacon; AC-52 generalises it so nothing else quietly acquires persistence.

### ★ AC-53 [P] — THE REWRITE CONTRACT

His stance — *rewrite rather than patch* — is only affordable if three things hold, so they are
criteria rather than good intentions:

1. **The persisted shape is versioned** (AC-48) and **readable without our code** (AC-49).
2. **Storage is reachable through one module.** Everything else — widget, pins, beacon, capture
   — goes through it and never touches `COA_LandmarksDB` directly. A rewrite then replaces one
   file, not a search across the addon.
3. **The smoke asserts the STORED SHAPE, not just behaviour** (AC-45). A test that only checks
   "the widget shows the right name" passes happily while the file rots underneath it.

**Read together: we may throw the UI away at any time, and we may throw the storage away
deliberately — but never accidentally, and never without being able to read what was there.**

---

## 14. V2 SKETCH — the editor UI (Battlewrath, 2026-08-12) — NOT DESIGNED

**Parked deliberately. Nothing here is a criterion and nothing here is built in v1.** Recorded
so it is not lost and, more importantly, so nobody builds *toward* it while building v1.

His sketch, verbatim in shape:

> **Light tagging.** *"But that is V2. When we get into the editor UI."*
>
> **— REVISED same day: the `tags` FIELD lands in v1 (AC-54); only the FILTER is V2.**
>
> A **bespoke interface** — summons maps **free of noise**, shows **just our items**. With a
> panel of:
> ```
> [Search]
> [Filter]
> Map
>   zone
>     Subzone
>       - items
> ```

**What it is:** the **retrieval** surface. §9 delta 2 said the primary verb changes from *follow*
to *find*; v1 answers *find* with the game's own world map and our pins on it, which is enough
to learn from. V2 gives *find* a purpose-built room — and a map showing **only** our landmarks,
free of quest POIs, flight points and every other addon's pins, is the calm-UI instinct applied
to the map itself.

### ★ Two things this validates about v1, and one caution

1. **The panel's tree — Map → zone → subzone → items — is EXACTLY AC-47's lookup fields.** That
   is not a coincidence: *"MapID, zone and sub-zone as the look up records."* **The v1 storage
   shape already supports V2's browser with no change**, which is the storage design paying for
   itself before V2 exists.
2. ~~Tagging is a new field, which is precisely what `schemaVersion` was built for.~~
   **Overtaken by AC-54: the field ships in v1**, so V2's filter needs no migration at all —
   it reads data v1 has been collecting. `schemaVersion` (AC-48) still stands as the insurance;
   this simply spends less of it.
3. **⚠ Caution — tags are NOT icons, and law 19 must not be read as forbidding them.** Law 19
   says nothing keys off the **icon**, because an icon is chosen for **how it looks**. A tag is
   authored **as a category**, explicitly so that filtering can key off it. Different jobs, and
   the distinction is what keeps both rules intact. Do not let "nothing keys off the icon"
   quietly become "nothing keys off anything".

---

## 15. v1 IS LIVE — build log and what the live test taught (2026-08-12)

**`COA_Landmarks` v0.1.3 is deployed and working.** Capture, widget, map pins, the note
readout, beacon control and the edit form all confirmed in the wild by Battlewrath.

He reported bugs by **writing them into the fields they relate to**, which made the
SavedVariables the bug report — `py`-readable, in place, with no separate channel. Worth
keeping as the method.

| Reported | Cause | Fix |
|---|---|---|
| *"recommends what you type as you type"* | **our own AC-54 decision**: tags save on every keystroke, so the half-word was already stored and got suggested back | exclude the record being edited from the scan |
| *"No mid texture, Name: field has it correct"* | `InputBoxTemplate`'s `$parentMiddle` anchors to its siblings **BY NAME**; every box was created nameless, so the anchors failed and only the 8px end caps drew | name every `InputBoxTemplate` box — **confirmed fixed** |
| *"Doesn't auto-complete on tab or enter"* | no handlers — the proposal sat there uncommitted | Tab accepts and opens the next tag; Enter accepts and drops focus — **confirmed working** |

**All four closed.** Battlewrath: *"A clear yes on the visual element. The auto-complete
works."*

**RESOLVED (Battlewrath): BOTH keys end in `", "`.** *"So the user can't be caught out. We
have to assume they don't know how tags work. And it should be — type away, not learn our
system."*

**★ That last clause is the test, and it generalises: a difference between two keys is a rule
that exists only inside our addon, and the user has to LEARN it to avoid being surprised.**
Consistency beats tidiness — the dangling separator is harmless (`SplitTags` drops empties),
whereas an inconsistency is a thing to memorise. L18 applied to an input.

Tab and Enter now do the same thing; the only difference is that Enter drops focus, which is
what Enter means everywhere else. The AC-54 tension below evaporated with it — nothing is
stripped, so nothing is altered.

<details><summary>The question as originally raised</summary>

**Open, trivial, and it touches AC-54 so it is HIS call:** Tab ends the value with `", "` and
Enter does not — deliberate (Tab means *next tag*, Enter means *done*), but **Tab-then-Enter
leaves a dangling `", "` in the stored string**. Reading is unaffected (`SplitTags` drops
empties); it is only scruffy in a file we made legible on purpose. Stripping it on the *done*
path would tidy it, but **AC-54 says we never alter or clean up tags** — the argument for
allowing it is that a trailing separator is not content, it is **our own scaffolding from the
Tab affordance**, and removing what we put there is not touching what the user wrote. A real
reading of the law rather than an obvious one, so it is not taken unilaterally.

</details>
| map pins | — | **worked**; the explicit tex-coord path (v0.1.2) stands |

### ★ The lesson, and it is a bench one: ABSENCE OF ERROR IS NOT SUCCESS

**Two of the three failed SILENTLY, in the same shape** — they drew nothing and said nothing:

- a **`pcall`** around `SetAtlas` with a constant (`Const.TextureKit`) that is **not defined
  anywhere in the extracted SharedXML**. It swallowed its own failure.
- a **template anchor** resolving `$parentLeft` against a nameless frame. No error is raised;
  the texture simply never positions.

Both were found by a human looking at a screen, not by any check we had. **The countermeasure
is not more `pcall` — it is fewer:** wrap only what you expect to fail, and say something when
it does (AC-43). `pins.lua` now reports a missing atlas once, loudly, rather than drawing
nothing.

### KNOWN ISSUE — the beacon holds a stale target on re-pin (Battlewrath, 2026-08-12)

*"I tested just the beacon. It does update. If already selected and changed, it holds the stale
value. But reselecting it updates. That is more a polish concern… not to be over-considered.
The dungeon work will do a lot of work on the beacon behaviour I imagine."*

**Parked on his instruction. Recorded, not chased.**

Observed: pinning a landmark works. Pinning a **different** one while a pin is already live
leaves the beacon on the old target; pinning again takes.

**Where I would start, so the next person does not begin from nothing** — none of this is
verified, and it is written as candidates rather than a diagnosis:
- **A `SetSuperTrackedPosition` onto an ALREADY-OCCUPIED slot may be a no-op engine-side.** The
  standard remedy is clear-then-set. One line in `Beacon.Pin`, but it briefly hands the slot to
  the ladder (a quest could take it for a frame), so it wants proving rather than assuming.
- **It may be RENDER staleness, not data staleness.** `SuperTracker` shows/hides on
  `SUPER_TRACKING_CHANGED`; if that event does not fire when a position replaces a position,
  the beacon keeps projecting the old point while `GetSuperTrackedPosition` already returns the
  new one. **`task_satnav` distinguishes these in one run** — pin A, pin B, and read whether the
  distance jumps to B while the beacon still draws at A.

**Deliberately NOT fixed speculatively.** `beacon.lua` is where the two silent-failure criteria
live (AC-24, AC-26); an unverified change there is the one place guessing is most expensive.

### ★ BEACON vs QUEST — the contention question, ANSWERED BY USE (Battlewrath, 2026-08-12)

§12 named this as the one that would turn law 17's *reasoning* into *evidence*. It has.

| Observed | Verdict |
|---|---|
| *"Opening the journal flips the beacon to the current active quest"* | **our AC-20 yield working.** The client auto-selects on open → our `SelectQuestLogEntry` hook fires → we clear → the ladder resolves to Quest |
| *"Pressing show on the quest / selecting a quest repeats this"* | same path, same yield |
| *"Accepting a quest doesn't auto-flip"* | **stock, and conditional.** `QuestLogFrame.lua:274` only calls `SelectQuestLogEntry` when the log is **closed AND nothing is selected** — with a quest already selected, neither branch fires, so nothing disturbs us |
| the quest it flipped to was out of map, so no beacon drew | stock; nothing to do with us |

**★ AND THE SIGNAL WORRY IS GONE (F42):** the engine draws a **different icon per tracking
type** — tapered diamond for a quest, square for a position. Sharing the slot never risked the
player mistaking a landmark for a quest.

**One thing worth carrying, same class as AC-21:** the yield fires on **opening the journal**,
not only on deliberately picking a quest — because the client selects for you on open. That is
more eager than AC-20's wording ("on user quest selection") suggests. It stays **consistent with
law 17** (opening your quest log is a mode switch) and the cost is one `repin` click, so it is
recorded rather than changed. If it ever grates, it is the same question AC-21 answered: which
selections count as intent.

### Still open — the A:B questions §12 named

None of these are bugs; they are what v1 exists to answer, and they need **use**, not a fix:
does `Why` get filled in or only `What` · which tier gets set most · rename or live with
`Everlook 7` · how many landmarks accumulate. ~~Does the beacon-vs-quest contention occur?~~ —
**ANSWERED above.**
