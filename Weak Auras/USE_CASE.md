# WeakAuras use case & scope

Captures why this work exists and what "good" looks like, before any aura
gets built. Written during the posturing phase (2026-07-02) - no auras have
been built with an agent yet, no reference examples existed in-project, and
none of this had been written down.

## The actual goal

Not "track more abilities." The goal is **UI replacement**: minimize the
default Blizzard UI (action bars, unit frames, whatever else can go) and
replace it with a custom WeakAuras layout that matches Battlewrath's own
taste - not a generic rotation-helper icon strip bolted onto the default UI.

This matters for scope. The existing pipeline (`Docs/WEAKAURA_INDEX.md`,
`necromancer_weakaura_index.json`) only covers **ability-based** opportunities
(cooldowns, procs, buffs, stacks) pulled from Spell.dbc. A real UI
replacement also touches things that pipeline doesn't classify at all:
health/power bars as a HUD element (not just a resource *aura*), party/raid
frame replacement, casting bars, minimap/objective clutter. Treat the
ability-index pipeline as one input among several, not the whole picture.

## What "good" looks like - reference research (external, 2026-07-02)

Two broad design archetypes, per community consensus (Binkenstein's
[Weak Aura Design Philosophy](https://binkenstein.wordpress.com/2017/10/12/weak-aura-design-philosophy/)
is the clearest writeup found):

- **Icon-set / rotation-helper** - abilities shown as a row of icons,
  usually under the character model. Requires actively looking at the set
  to extract information. This is the "typical" WeakAuras setup and what
  most Wago.io uploads default to.
- **HUD approach** - default game textures/positions are kept or adapted,
  but made to carry more information (e.g. a proc icon that also indicates
  a *different* ability is now optimal). Goal: keep visual focus on the
  character/world, let the aura grab attention only when a decision point
  arrives, rather than requiring constant reading.

Given the stated goal (custom taste, UI minimization), the HUD approach is
the closer fit, not the icon-strip default. Worth deciding this explicitly
per aura rather than defaulting to "put it in the icon row."

Cross-cutting design principles worth carrying forward (from the same
source plus the [WeakAuras2 wiki](https://github.com/WeakAuras/WeakAuras2/wiki)):

- **Narrow, specific triggers.** Define exactly when an aura should
  activate - vague triggers are the main source of clutter.
- **Prioritize by frequency.** More-frequent decision points get higher
  visual priority (bigger, more central, glow) than rare ones.
- **Use the Load tab aggressively.** Restricting an aura to spec/class/zone/
  combat-state isn't just tidiness - unloaded auras cost zero CPU and keep
  the sidebar navigable. Relevant here given 21 custom classes: every aura
  should almost certainly be class- and spec-scoped.
- **Groups / Dynamic Groups for structure**, not just visual containers -
  this is how a large layout (21-class scope, eventually) stays manageable
  instead of becoming one flat list.
- **Resources first.** When Binkenstein walks through his own build order,
  primary/secondary power and stacking "resource-like" buffs (e.g. combo
  points, charges) get designed before cooldowns or procs - they're
  glanced at constantly and set the anchor point for everything else
  layered around them. Worth adopting as the build order here too once
  actual auras get made: resource bars -> cooldown/proc/buff layer -> polish.

## Primitives from Wago UI Packs (checked 2026-07-02)

Browsed [uipacks.wago.io/search](https://uipacks.wago.io/search) for structural
primitives, not importable content. Two findings:

- **No WotLK-specific catalog entry exists.** The Game Version filter only
  offers Retail, Classic Era (vanilla), Burning Crusade Classic, and Mists
  Classic - nothing for 3.3.5/Wrath. Confirms nothing here is directly
  importable for Ascension; treat everything as conceptual reference only.
- **[Fojji WeakAuras \[Classic\]](https://uipacks.wago.io/pack/fojji-weakauras-classic)**
  is the closest structural analogue found - a pure-WeakAuras (not full-UI)
  pack, split into exactly two tiers:
  - **General** (class-agnostic, loaded regardless of class): a
    trash/bag-cleanup helper, raid auto-marker, clickable pull-timer,
    consumable/flask-and-food uptime bar, a core "essentials" bundle, a
    Sunder Armor-style debuff stack counter, and a pre-pull "did you
    consume/prep" checklist helper.
  - **Class Packs**: one dedicated file per class (Druid, Hunter, Mage,
    Paladin, Priest, Rogue, Shaman, Warlock, Warrior UI), anchored off a
    shared "Class Pack Anchors" positioning file.

  This two-tier shape (shared general layer + per-class layer anchored to
  one shared position system) is a reasonable template to borrow for a
  21-custom-class project: build the anchor/positioning system once, then
  one class file at a time, rather than one flat pile of auras.

  Two categories surfaced here aren't in the current four opportunity
  types at all: **consumable/prep tracking** (flask/food/pre-pull
  checklist - not tied to a spellId, tied to buff-presence-before-combat)
  and **utility automation** (auto-marker, trash deleter - not a display
  concern, arguably out of WeakAuras' proper scope and more of an addon
  concern). Worth keeping distinct from the ability-tracking pipeline
  rather than forcing them into `cooldown_tracker`/`buff_uptime`/etc.

## Scale, readability, and material quality (checked 2026-07-02)

Follow-up research after the `Template_shadow` scaffold discussion raised
scale/readability and "what already looks nice" as the two open areas.
Checked the WeakAuras community's actual current conventions rather than
guessing - concrete numbers below, sourced from a currently-maintained
integration guide (ToxiUI, a large modern UI addon that documents exactly
how it tunes imported WeakAuras packages) plus general LibSharedMedia/
Masque research.

- **Icons are not square in practice.** ToxiUI's own guide
  ([toxiui.com/resources/guide/weakauras-guide](https://toxiui.com/resources/guide/weakauras-guide/))
  gives its actual per-category icon dimensions: Dynamic Effects 40x30,
  Core 48x36, Overflow 44x33, Utility 40x30, Maintenance 40x30 - all a
  4:3 width:height ratio, none square. `Template_shadow`'s current 25x25
  slots are uniform squares - worth treating "should tiers be non-square"
  as a real, concrete option rather than an unquestioned default, not just
  a scale (bigger/smaller) question.
- **Borders and spacing read as "clean" when thin and tight**, not thick.
  Same guide: border size 1 (not 2+), icon spacing 2px. Chunkier borders/
  gaps were not what a widely-used current pack reaches for.
  **Independently corroborated, 2026-07-02:** Luxthos Mage's actual live
  `DynamicGroup` spacing (`space=2`, `columnSpace=1`, `rowSpace=1` on
  48px icons) lands in the same small range - now promoted to a standing
  cross-cutting rule in `HUD_DESIGN.md` (small fixed gap, not a
  percentage of icon size) after `Template_shadow.py`'s own
  percentage-based gap formula read as too loose once tested live.
- **Resource bars are thin, not bulky.** Bar height ~10px versus icons at
  30-48px tall - a bar reads as an accent strip, not a visually heavy
  block. Relevant to Tier 4/HP-Resources: don't assume the resource bars
  need equal visual weight to the icon tiers to read as important.
- **Two-font convention, not one.** The primary resource's number gets its
  own distinct, larger/bolder font (ToxiUI uses a dedicated font at size
  24 for exactly this), separate from the general label font used
  everywhere else. Suggests numeric readouts that matter most (primary
  resource, maybe stack counts) deserve their own type treatment rather
  than inheriting whatever the rest of the tier uses.
- **Group Scale as the single sizing lever.** Rather than resizing each
  icon/bar individually per resolution, the convention is one group-level
  Scale multiplier tuned once for the target resolution, with per-element
  sizes fixed relative to each other. Matches the "decide relative sizing
  once, then scale the whole thing" framing from the scaffold discussion.
- **WeakAuras has native circular icon skinning - no third-party addon
  needed.** Searched for how packs get a Masque-style rounded/skinned
  icon look; Masque itself only skins action bars/bags, not WeakAuras
  regions. WeakAuras ships its own equivalent - Mask Textures on the icon
  region type - so a polished icon look (rounded corners, custom border
  art) is a built-in option, not a dependency to add.
- **Fonts: "Expressway" is the most commonly cited go-to** for WeakAuras
  specifically in the wider community (frequently bundled via
  LibSharedMedia-type addons alongside dozens of others) - a reasonable
  default to reach for rather than the Blizzard default font, though not
  verified against this project's own visual taste yet.
- **No living WotLK-specific "gold standard" pack to copy.** Checked
  Luxthos (the most popular per-class WeakAuras author across every
  version by install count) specifically for a Wrath of the Lich King
  line - it existed at one point (`luxthos.com/category/weakauras-wrath-
  of-the-lich-king/`) but is now empty ("no posts found"); their currently
  maintained lines are Classic Era and the current retail expansion only.
  Reinforces that this project's build has to synthesize conventions from
  adjacent versions rather than clone a maintained WotLK-specific example
  - consistent with the earlier uipacks.wago.io finding that no WotLK
  catalog entry exists there either.

## Tracking non-directly-controlled pets (researched 2026-07-02)

Raised by Battlewrath as a research-only topic (can't be proven live yet -
no server-up characters to test against): Necromancer and Tinker both
summon creatures that aren't a standard Hunter/Warlock-style single pet,
and the question was whether a real HP-based low-health warning is
possible for them, as opposed to the purely time-based "Wild Imp" pattern
WeakAuras uses in modern retail (Affliction Warlock) - which just counts
down a known summon duration rather than reading actual creature HP.

**The general API constraint, confirmed first.** `UnitHealth("pet")` and
similar unit-token queries only work for the player's one Blizzard-defined
pet relationship (Hunter pet, Warlock demon, DK's ghoul-as-pet). When a
spec drops multiple simultaneous summons at once - Affliction's Wild Imps,
Unholy's Army of the Dead ghouls - those extras are not individually
addressable via any unit token the addon API exposes. That's exactly why
WeakAuras' Wild Imp tracking is count-plus-countdown rather than a real
health bar: there's nothing to query. This is a hard engine limitation,
not a WeakAuras gap.

**Necromancer: confirmed to be the same case, via a real community aura.**
Found and decoded `db.ascension.gg`'s "Necromancer Temp-Summon Tracker"
(by Walmartpjs) - a real, currently-used aura for this exact server. It
tracks five distinct summon spells (Animate: Rotling, Black Hook, Animate:
Knight of Decay, Animate: Plaguefather, Animate: Tomb King) plus a
stacking "Foul remnant" mechanic - confirming Necromancer plays as a
multi-simultaneous zombie/skeleton swarm, not one persistent pet. Every
tracker group triggers on `Cooldown Progress (Spell)` keyed to the
`SPELL_..._SUMMON` combat-log event with a hardcoded duration per minion
type (15s/30s/35s) - the identical count-plus-countdown pattern, not a
live health query. The author's own note confirms the limitation
directly: *"minions dying before their duration is up is not indicated
(idk lua, sue me)."* One group does set `"unit": "pet"`, but inspection
shows it's watching for a fake buff ("Atonement") on that unit as a
progress-bar trick, gated by the same summon event - not a genuine
per-minion health feed. **Conclusion: Necromancer minions have no stable
per-minion unit token, same as Wild Imps/Army of the Dead ghouls. A real
HP-based low-health warning isn't possible with the standard API - the
best available signal is time-since-summon, which is what the community
aura already does.**

**Correction/addition (2026-07-06): this conclusion still holds for
per-minion HP specifically, but a real, better alternative exists for the
*count* question.** Battlewrath found that summoning a guardian applies a
stacking buff to the *player* (not the minion), confirmed real: **805016**
("Skeletal Warrior" per `db.ascension.gg`, Battlewrath's "Lesser Skeletal
Warrior") is `Apply Area Aura: Pet Owner` - a genuine WoW mechanic that
maintains a stacking owner-side aura for as long as the pet exists, one
stack per simultaneous summon. Battlewrath confirmed 2 stacks with 2
Lesser Skeletal Warriors up. **This means the current LIVE COUNT of a
minion type (not its HP) is directly readable via a plain `aura2`
stack-count trigger on the player** - a real status query, not an
estimate - which is strictly better than the count-plus-countdown pattern
above for the counting half of the problem (it self-corrects immediately
if a minion dies early, unlike a duration guess, closing exactly the gap
the community aura's own author admitted: "minions dying before their
duration is up is not indicated"). **Not yet confirmed whether every
minion type has an equivalent owner-buff** - only Skeletal Warrior checked
so far (see `Necromancer/spell_index.md`). If they all do, this should
replace the summon-event-plus-duration approach for counting purposes
across the board; HP-per-minion remains unavailable either way. Worth
reusing that exact pattern (SPELL_SUMMON
combat-log trigger + known duration) rather than re-deriving it, if a
Necromancer aura gets built later.

**Tinker: inconclusive, needs an in-game check later.** `db.ascension.gg`'s
Tinker class page and the Fandom wiki page are both JS-rendered client-side
- couldn't extract structured data via fetch. Search snippets describe
turrets, landmines, remote-detonation mines, and a "Shredder" mechsuit as
the class's summon-adjacent kit, but nothing confirms turret count,
duration, or whether they'd behave like a real pet-tokened unit vs. a
Wild-Imp-style timed summon. No existing community WeakAura for Tinker
turrets turned up in searches either - this class may simply not have one
built yet. **Left open, to be settled once the server is up**: cast a
turret ability on a live Tinker character, open WeakAuras' own trigger
picker, and check whether `pet`/`pet1`/nameplate-based unit tokens
populate for it. That single live check will settle Tinker the way the
Necromancer community aura already settled Necromancer.

**Follow-up, same day: death-alert design (Necromancer, event-only, no
HP estimation), simplified to a single self-observable signal.**
Battlewrath scoped this down deliberately - not a damage-accumulation HP
bar (too approximate, needs an unverified max-HP baseline per minion
type), just a small transient fly-out reacting to *a minion died*.
Confirmed intended presentation: transient, not fixed-address - "we don't
know whose minion it was, but one has [died] - check yours." That's a
deliberate, acknowledged exception to the "fixed channels" cross-cutting
rule in `HUD_DESIGN.md` (which normally forbids appear/disappear
elements): a one-shot "go look" nudge is a different kind of thing than a
persistent state indicator competing for a permanent glance-position.

Two designs were considered; the second, simpler one is the one to build:

- *Combat-log approach (superseded).* Cross-reference `UNIT_DIED`'s
  generic `destName` against a fixed-magnitude change in a personal
  "Life Force" debuff to corroborate ownership. Works, but depends on
  catching two separate signals (a combat-log death event plus a debuff
  change) and on this custom server reliably firing a standard
  `SPELL_SUMMON`/`UNIT_DIED` pair for these custom-scripted Animate
  spells in the first place.
- **Debuff-delta approach (current design, Battlewrath's simplification).**
  Skip combat log and `UNIT_DIED` entirely. Watch only the player's own
  Life Force debuff value, self-observable regardless of whether any
  combat-log event ever fires cleanly for these custom spells:
  1. Custom trigger reads the Life Force value each update and compares
     it to the last-seen value (stored across evaluations).
  2. Value **decreased** - a normal summon cost was just paid. Update the
     stored value, no alert.
  3. Value **increased** - Life Force was refunded, which only happens on a
     minion dying/expiring. Fire "Pet died +N LF" (N = the delta) as the
     fly-out text, and update the stored value.
  4. **Scope, clarified by Battlewrath: the aura names nothing, ever -
     it only reports the budget-state change.** The alert's whole
     output is the raw delta number ("+N LF") plus optionally the
     resulting available total - nothing about minion type or identity
     is part of the design or its output. Any inference about *which*
     minion type that number corresponds to (Abomination = 3, Skeleton
     Warrior = 1, per Battlewrath - not yet independently verified
     against the full class kit) is the player's own mental step, done
     entirely outside the aura, using knowledge the aura doesn't have
     and was never asked to have. This is a deliberate scope boundary,
     not a limitation to fix later.
  5. Multiple simultaneous minions (up to the "4-5 Foul remnants" the
     community tracker's notes reference) still just produce one
     fly-out per death event reporting that event's delta, not a roster
     or a running tally - "information not demand" tone, a calm
     short-lived nudge, not an alarm.

**Settled visual form, confirmed by Battlewrath: styled like Blizzard's
own floating combat text, not a WeakAuras icon/bar element.** "+N LF"
spawns, rises/fades, and disappears - the same visual grammar players
already read unconsciously for damage/healing numbers, reused here for a
pet-death signal instead of a combat one. Placed somewhere in peripheral
vision the player can choose to keep half an eye on, rather than a UI
list of live minions they'd have to actively check - this is the
"answer a question before you consciously ask it" idea from the top of
this doc's companion `HUD_DESIGN.md`, applied to pet state specifically:
passive peripheral awareness standing in for active monitoring.

**Framing as a gain, not a loss - deliberate, confirmed by Battlewrath.**
"+N LF" reads as budget regained/an opportunity to act (essence is free,
go summon something) rather than "Skeleton Warrior died" or "-1 minion,"
which would read as a loss/failure notification. Same underlying fact,
opposite emotional framing - and the gain framing is the one that fits
`HUD_DESIGN.md`'s existing "information, not demand" rule: no alarm
energy, nothing that reads as a penalty or a mistake to feel bad about,
just a plain fact stated in the most neutral-to-positive available
phrasing. Worth carrying this same instinct forward to any other alert
built later - default to whatever phrasing of the same fact reads as
calmest/most opportunity-shaped, not just whatever's technically most
direct.

**A second, non-transient element falls out of this for free: available
Life Force as a persistent readout.** The same value being watched for
deltas is also just a plain resource number, no extra logic needed to
show it. Note: as of 2026-07-05, Battlewrath has since confirmed
Necromancer's actual Resources-tier pair is Mana + Runic Power (see
`Necromancer/slot_assignment.md`) - Life Force has its own native in-game
UI element already and is **not** a Resources-tier slot, so this
"candidate for the second slot" framing is superseded; Life Force stays a
pet-tracking fly-out only, per `Necromancer/BUILD_METHOD.md`.

**Not yet placed in the five-tier model (the fly-out half only).** The
"Pet died +N LF" fly-out doesn't fit any of the five tiers as written -
it's a pet-state signal, not a self-state readiness/resource/prep signal,
and it's explicitly transient rather than fixed-address. The
available-LF readout half is a candidate for a small standalone element
near the fly-out (not a Resources-tier slot - see note above). Flagged as
an open question in `HUD_DESIGN.md`.

**Redesign, 2026-07-06 - two changes, both scope-narrowing.**

1. **The per-minion-type guardian-count buff idea (this doc's own
   "Correction/addition" above, `Necromancer/spell_index.md`'s 805016
   entry) is shelved, per Battlewrath: "We might not be able to track
   it."** The mechanism (a stacking `Apply Area Aura: Pet Owner` buff per
   minion type) is still real and confirmed for Skeletal Warrior, but
   whether it's reliably usable/exists for every minion type is uncertain
   enough that it's not the basis for anything built now. Not deleted from
   the record - a real finding, just not load-bearing for this design
   until (if ever) it's independently re-confirmed.
2. **Explicit rule, stated directly by Battlewrath: don't compete with
   Life Force's own native UI element for tracking/count display.** This
   generalizes the earlier "not a Resources-tier slot" decision - it's not
   just that Life Force skips the Resources tier specifically, it's that
   this project shouldn't build *any* persistent count/tracker for it at
   all, full stop. The native element already owns that job.

**What this project builds instead: a transient combat-text alert on
budget CHANGE, not a persistent tracker, and not a raw delta number.**
Per Battlewrath: *"What is the budget available? = Suggest the highest
value summon for that budget. Bring attention that the state has
changed."* Redesigned content and trigger, replacing the "+N LF" delta
design above (which is superseded by this, not literally deleted - the
mechanism it was built on, watching Life Force's own value change, still
applies):

- **Trigger: any change in available Life Force budget** - not just the
  refund-on-death case the original design covered, but any state change
  (cost paid, refund, a talent shifting max) - still the same
  self-observable "watch the value, compare to last-seen" mechanism from
  the design above, just firing on change generally rather than only on
  increase.
- **Content, mechanism refined 2026-07-06 - a DynamicGroup of what
  currently fits, not one ranked pick.** Battlewrath's own follow-up
  replaces "surface the single highest-value minion" above with something
  more elegant: a small DynamicGroup showing every minion whose cost
  currently fits the available Life Force stack, each icon's own state
  (shown/glowing vs not) driven by a plain per-minion comparison of that
  minion's fixed cost against the current stack value.
  **Comparison direction - SETTLED (same day, follow-up): it's a plain
  ladder.** The debuff's own stack value *is* the available budget,
  directly - debuff absent (or at 0) means zero budget, nothing
  affordable; stack 1 means a budget of 1 (Skeletal Mage/Ghoul, cost 1,
  fit); stack 2 adds Banshee (cost 2); stack 3 adds Abomination/Gargoyle
  (cost 3); and so on as talents raise the max. So the actual comparison
  is simply **a minion fits when its own fixed cost <= the current debuff
  stack value** - confirmed, not the open question the earlier phrasing
  left it as. One edge case worth remembering once building this for
  real: "debuff not present at all" and "debuff present at stack 0" need
  to be treated as the same zero-budget state by whatever trigger reads
  this, since WoW auras don't normally sit at a real, present 0-stack
  state - absence itself likely *is* the zero case, not a separate one.
  **This resolves the priority-ranking gap below by sidestepping it
  entirely**: instead of picking one "best" option (which needed a
  subjective ranking, since
  Abomination and Gargoyle both cost 3), just show every objectively
  fitting option and let the player pick - no ranking required at all.
  **Talent-scaling falls out for free**: since the comparison always reads
  Life Force's own live current value (not a hardcoded base of 3), a
  talent that raises max Life Force (Summoning Adept, Master Animator -
  `spell_index.md`) is automatically reflected without any extra logic -
  "as the total pool grows with talents," per Battlewrath.
- **Purpose stays exactly the "information, not demand" framing already
  established**: the point is to bring attention to the fact that the
  state changed (something is newly worth considering), not to nag or
  demand immediate action - still transient, still appears-then-fades
  rather than a docked element, same "gain-framed, calm, one-shot"
  instincts as the original "+N LF" design, just richer content (a small
  icon cluster instead of one line of text).

## Open items (not yet resolved)

- **Injection stability: tested, confirmed negative.** Direct file-level
  authoring does not work. Test performed on `Weakauratest` /
  `Area 52 - Free-Pick` (2026-07-02): a real in-game aura ("Test") was
  cloned by hand directly inside `WeakAurasSaved` in the account-level
  `WTF/Account/BATTLEWRATH/SavedVariables/WeakAuras.lua` (edited while the
  client was closed), renamed, and given a visibly different appearance
  (color, offset, text). After relogging, and separately after disabling
  and re-enabling the addon, the clone never appeared anywhere - not in
  the WeakAuras options list, not on screen. Re-checking the file after
  that session showed the clone entry gone entirely and the original
  entry's fields reordered - the signature of WeakAuras' own serializer
  having rewritten the file from its in-memory state on logout. Conclusion:
  WeakAuras does not trust the `displays` table blindly at load; a
  hand-added entry that didn't go through its own creation/registration
  path gets silently dropped rather than erroring, and is then
  permanently erased the next time the addon saves.
  **Implication:** hand-editing `SavedVariables` directly is not a viable
  authoring path. The likely real path is generating a proper **WeakAuras
  import string** (the same mechanism Wago-hosted auras use) and having it
  pasted into the in-game Import dialog, since that goes through
  WeakAuras' actual API instead of being read as inert saved data.
  **Follow-up (same day):** read `Transmission.lua` directly and confirmed
  this build's import-string pipeline is `"!WA:2!" + EncodeForPrint(
  CompressDeflate(LibSerialize.Serialize(table)))`. Built
  `weakaura_codec.py` (in this folder) - a standalone Python port of that
  exact pipeline.
  **Follow-up (same day, later): decode path confirmed against real addon
  output.** Exported the actual in-game "Test" aura and captured both the
  resulting import string and WeakAuras' own debug-table dump. Decoding
  that real string with `weakaura_codec.py` reproduces the debug-table
  dump exactly, field-for-field. This also resolves the missing-libraries
  concern below - Export demonstrably works on this client regardless of
  what `IsLibsOK()` would report, so `Transmission.lua` is not
  short-circuiting. Along the way, found and fixed a real bug: the codec's
  encoder wasn't wrapping the aura table in the `{"m": "d", "d": ...,
  "v": ..., "s": ...}` envelope that real Export/Import actually use -
  confirmed required by reading `WeakAuras.Import` directly, and now fixed
  and re-validated.
  **Encode path confirmed live (2026-07-02, same day): fully resolved.**
  The import string generated by `weakaura_codec.py`'s own encoder
  (`encode_import_string(EXAMPLE_TEST_AURA)`) was pasted into WeakAuras'
  in-game Import dialog on `Weakauratest`. It imported cleanly as "Test",
  was not malformed, and survived being deleted and reimported a second
  time. **The full round trip - agent-authored Python data structure to
  a real WeakAuras aura in-game - is now proven end to end.**
  Hand-editing `SavedVariables` directly remains confirmed non-viable (see
  above); the import-string path is the validated way in.
  **Follow-up, same day: group support added.** `weakaura_codec.py` now
  has `encode_group_import_string`/`decode_group_import_string` for FLAT
  groups (one parent, plain leaf children, no nesting) - built and
  validated against a real group exported from this project's own client
  ("Example_group", 4 icon children: Test, Test 2, Test 3, Test 4).
  Reading `Transmission.lua`'s actual `DisplayToString`/`WeakAuras.Import`
  confirmed the mechanics precisely: a group export's children live in a
  sibling top-level `c` array (not nested in `d`), and for a flat group
  (version 1421) `WeakAuras.Import` completely ignores whatever
  `controlledChildren`/`parent` fields you hand it and rebuilds them
  itself from `c`'s order - meaning a flat group only needs the right
  child ids to hand-build correctly, confirmed by the real capture (the
  transmitted `d` has `controlledChildren` stripped, and none of the 4
  children carry a `parent` field). Nested groups (a group containing
  another group, version 2000) are NOT supported - `WeakAuras.Import`
  trusts the encoded topology directly in that case instead of
  reconstructing it, which is a lot more to get right without live
  testing. Decode is proven byte-for-byte against the real capture, and
  encode is now live-validated too: a codec-generated group string (1
  group + 4 icon children) was pasted into WeakAuras' Import dialog and
  imported with no malformation. Both encode/decode paths - single-aura
  and flat group - are confirmed working end to end, in-game. (Original
  missing-libraries note, now resolved: this WeakAuras install is missing
  several libraries its own `Init.lua` checks for - `AceSerializer-3.0`,
  `AceComm-3.0`, `LibCompress`, `LibSerialize` itself - confirmed absent
  from `Interface/AddOns`, only `LibStub`, `LibDeflate`, and
  `LibCustomGlow` are actually bundled. Despite this, real Export/Import
  works, so this risk did not materialize.)
  **Correction (2026-07-02, live-tested): `controlledChildren` IS
  load-bearing for updates to an existing aura, even though it's genuinely
  ignored for a fresh import.** The claim above (`WeakAuras.Import`
  rebuilds it from `c`'s order) is accurate for `Transmission.lua`'s core
  import engine, but incomplete - `WeakAurasOptions`'s separate update/
  merge flow (`OptionsFrames/Update.lua`) is a different code path, used
  whenever the pasted string looks like an update to something already
  present, and its `BuildUidMap` function reads `d.controlledChildren`
  directly to build its structural map (confirmed by reading
  `Update.lua` line ~349) - entries in `c` that aren't listed there are
  invisible to it. Real incident: `Template_shadow.py` v0.9 added 2 new
  children by starting from a previously-decoded group table (which
  still carried the OLD `controlledChildren` of 24 ids) - `c` ended up
  with 26 entries but `controlledChildren` only claimed 24. Pasting that
  in-game threw `attempt to index local 'pendingPickData' (a nil value)`
  in `Update.lua:1867` - the structural mismatch pushed the update-diff
  logic into a branch that never assigns `pendingPickData`, which gets
  indexed unconditionally a few lines later (a real bug in that addon
  build, only reachable because of the malformed input). Fixed in
  `weakaura_codec.py`'s `encode_group_import_string`: it now always
  regenerates `controlledChildren` from the actual children being
  encoded, unconditionally, rather than only filling it in when absent.
  **Practical workaround if this class of error resurfaces for any other
  reason:** delete the existing aura in-game first, then import fresh,
  rather than pasting over/updating an existing same-named one - a
  genuinely fresh import (`Update.lua`'s `"import"` mode) always sets
  `pendingPickData` regardless of this particular mismatch.
- **In-project reference examples: proof of concept done.** Built
  `reference_library.py` (2026-07-02) from a single free, public
  community export - Fojji's "Class Pack Anchors [Classic]"
  (https://wago.io/FojjiClassAnchors-Classic) - rather than continuing to
  design every anchor/section pattern from first principles. Findings fed
  straight back into `HUD_DESIGN.md`: a real 15-section taxonomy to
  compare against our five tiers (surfaced two real gaps - cast bars and
  a swing timer have no tier yet, and routine-vs-rare procs may deserve a
  two-tier split rather than one), a `"DON'T MOVE - ..."` anchor-naming
  convention worth adopting directly, and an alternate texture-region
  proc-glow technique distinct from the icon+subglow approach already
  used in `weakaura_codec.py`'s own example. Also surfaced a real gap in
  `weakaura_codec.py` itself: group-aura exports use a different envelope
  shape (a sibling top-level `c` children array) than the single-aura
  envelope the codec currently handles - confirmed by reading
  `Transmission.lua`'s actual `DisplayToString`/`WeakAuras.Import`
  functions, not yet built. Single-source at the time (proof of concept)
  - **superseded 2026-07-04: this server's custom classes now have real
    reference examples of their own**, found via db.ascension.gg's own
  "Conquest of Azeroth" category (14 real, currently-installed entries -
  see `reference_library.py` section 9). Everything in this bullet's
  first paragraph remains generic retail/Classic community knowledge; the
  phase-2 findings below are the first confirmed-against-this-server
  evidence.

  **Scoped as one of the next major developments (2026-07-04), three
  phases in order:**
  1. **Capability inventory - done, first pass (2026-07-04).** What
     WeakAuras actually lets us do, systematically, rather than
     discovering trigger/region/animation options one at a time as a
     specific build happens to need them. Research packet and findings:
     **[CAPABILITY_INVENTORY.md](CAPABILITY_INVENTORY.md)** - real file
     paths under this build's actual addon source, all 11 region types +
     9 sub-region types + 43 trigger types + 5 animation tracks read at
     least once.
  2. **Prior art survey - done, first pass (2026-07-04).** How other real
     packs/authors have used those capabilities. Expanded past the single
     Fojji source into: general community conventions for imp/pet
     management, target cast bars, resource management, and rotation
     helpers (all corroborate existing HUD_DESIGN.md decisions rather
     than surfacing new techniques); two Ascension-native auras decoded
     in structural depth (a Druid class pack, a stat tracker); and the
     full 14-entry catalog of db.ascension.gg's own "Conquest of
     Azeroth"-tagged WeakAuras - the same ruleset this project targets.
     Full write-up: `reference_library.py` section 9. Headline finding:
     the category's most-installed entry (243 installs) is a real,
     independently-built version of this project's own Resources-tier
     design (per-class resource bars shown via Load, not hand-built per
     class) - external validation, not just background color.
  3. **A reusable template code repo - done, first pass (2026-07-04).**
     Parameterized templates per region type (`Bar = options`, `Icon =
     options`, and so on), so building a new element means changing
     variables on a known-working template rather than re-deriving the
     region's field set and behavior from scratch each time. Built as
     real JSON Schema + template pairs (Battlewrath's explicit direction:
     "these should be built as JSON objects... pull the schema, plug in
     our spell ID's... and we can replicate"), one pair per row in
     `Docs/WEAKAURA_INDEX.md`'s extended opportunity taxonomy - see
     **[Templates/](Templates/)** and **[template_filler.py](template_filler.py)**.
     Classification came first, deliberately: the taxonomy table (8
     opportunity types + the settled "glow-source" mechanism for a
     Rotation icon's optional second proc/buff spell ID, modeled as a
     length-1 list so a second effect later is additive) was worked out
     and confirmed in discussion *before* any JSON was written, so the
     templates encode a settled design rather than guessing at one.
     Round-trip tested through `weakaura_codec.py`'s real encode/decode -
     not yet live-tested in-game, and the glow-source mechanism's
     `conditions` block is explicitly flagged unverified pending either a
     real captured example or a live test.
- **No resource-threshold opportunity type yet** in the ability-index
  pipeline (e.g. "alert at 80 Runic Power") - flagged already in
  `WEAKAURA_INDEX.md`, relevant here because "resources first" above
  depends on it existing.
- **Frame/HUD replacement scope is undefined.** No inventory yet of which
  default Blizzard UI elements Battlewrath actually wants gone vs. kept.
  Needs a follow-up pass once there's something to react to in-game.
- **Tinker turret/summon unit-token behavior unconfirmed.** Necromancer is
  settled (no stable per-minion token, time-based tracking is the only
  option - see above); Tinker's turrets/mechsuit couldn't be checked via
  the database (JS-rendered pages) and no reference aura exists yet.
  Needs a single live check once a Tinker character exists: cast a
  turret, see if WeakAuras' trigger picker offers a real unit token for
  it.
- **Live validation queue, stated 2026-07-05 (server went live 2026-07-04/05)
  - next session's warm start.** Everything in `Templates/` is currently
  only round-trip tested through `weakaura_codec.py`, never confirmed
  against real in-game behavior. Battlewrath's stated scope for the first
  live-testing pass: resource/stack/buff tracking, proc activation cases,
  and some concrete use cases around the Resources and Rotation tiers
  specifically (Necromancer's Mana/Runic Power bars are the first real
  candidates - see `Necromancer/slot_assignment.md`). Purpose: build up
  real reference data/ground truth for how WeakAuras actually behaves on
  this client, the same discipline already applied to the encode/decode
  pipeline and the group-import mechanics above, now extended to the
  template system's opportunity types (`resource_threshold`, `proc_alert`,
  `buff_uptime`, `stack_counter`, `cooldown_tracker`) and to the specific
  open items already flagged per-class (power-type string, Runic Power's
  manaCost/runicCost discrepancy - noted non-blocking per Battlewrath,
  Life Force's base value).
  **Tooling update (2026-07-06): use `DEV_TOOLS.md`'s `/devconsole` and
  "Show IDs in Tooltips" for this pass, not just WeakAuras' own UI.**
  `dump`/`tinspect` can read a live Lua table directly (e.g. a unit's real
  power type) - closer to ground truth than either this project's DBC
  extraction or `db.ascension.gg`, both of which had confirmed gaps this
  session (see `Necromancer/spell_index.md`'s Command-ability correction).
  **First item resolved (2026-07-06), and by an even simpler method than
  planned:** Battlewrath captured real "Mana"/"Runic power" WeakAuras
  in-game and pasted the import strings directly - decoding them via
  `weakaura_codec.py` confirmed `powertype: 0` and `powertype: 6`
  respectively (the native enum, DK-reuse hypothesis directly confirmed),
  no dev console needed for this one. Also caught a real bug this
  surfaced: `resource_threshold_aurabar.schema.json`'s `power_type` field
  was documented as a string enum name, corrected to the real raw-integer
  field. See `Necromancer/slot_assignment.md`'s change log for the full
  writeup. Remaining queue items: Runic Power/manaCost discrepancy
  (already resolved, non-blocking), Life Force's base value, and swing
  timer/player cast bar (scoped 2026-07-06 in `HUD_DESIGN.md`, not yet
  live-tested).

## How to use this doc

Read alongside `AGENT_PROMPT.md` (technical grounding: spell IDs, trigger
mappings, known data limitations) - this doc is the *why* and *what good
looks like*, that one is the *how*. Update the "Open items" section as each
gets resolved instead of leaving stale unknowns here.
