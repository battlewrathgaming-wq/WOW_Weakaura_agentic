# Necromancer spell index (Resources tier)

A pointer index, not a copy - same principle as the rest of `Weak Auras/`
(this folder's own `README.md` calls itself "a pointer layer... the
generated data lives under `Outputs/`"). Every value below is sourced from
`Outputs/dbc_preview/necromancer_abilities_reference.html` (real Spell.dbc
data, per `Display/README.md`) - re-check that file directly before
trusting a number here for anything beyond a first pass, and re-derive
nothing by hand.

Scope: only abilities relevant to the Resources tier's two real slots
(Mana, Runic Power) and the related Life Force mechanic, per
`BUILD_METHOD.md`'s stated build order. Not a full class ability index -
`Outputs/weakaura_index/necromancer_weakaura_index.json` and
`necromancer_abilities_reference.html` remain the actual full sources.

## Mana (primary/budget resource, per Battlewrath)

Confirmed real `manaCost` fields exist and carry concrete values - a
representative sample, not exhaustive:

| Ability | Spell ID | Mana cost |
|---|---|---|
| Command: Blight | 504050 | 400 |
| Command: Hook | 504316 | 300 |
| March of the Dead | 707007 | 400 |
| Ice Barrage | 801760 | 300 |
| Animate: Bone Construct | 531130 | 300 |
| Lichplague | 802132 | 300 |
| Death's Due | 807796 | 300 |

Also: **Overwhelming Force** (talent) - "Damage dealt by your Undead
minions now has a 5% chance to restore 2 Runic Power and 2% of your
maximum mana" - a real cross-resource interaction worth remembering when
Runic Power's own tracker gets built (this talent feeds both bars).

**Not yet done:** a full pass for every `manaCost`-bearing ability -
this sample was enough to confirm the mechanic is real and concrete, full
enumeration wasn't needed for the Resources-tier bar itself (which just
needs the Power status trigger, not a per-ability cost list - see
`slot_assignment.md`).

## Runic Power (spender resource, per Battlewrath)

Generation confirmed real and concrete:

| Ability | Spell ID | Effect |
|---|---|---|
| Glacial Tap | 805369 | "instantly regenerating 30 Runic Power" |
| Lich Form | (not yet pulled) | "generate 3 Runic Power every 5 sec" while active |
| Ner'zhul's Blessing | 704729 | "Increases your maximum Runic Power by 20%" |

**Spend side, per Battlewrath (2026-07-05):** spent mainly by **Command**
- a client-to-server call that makes all currently-summoned minions each
cast their own version of Command.

**CONFIRMED (2026-07-05, corrected against `db.ascension.gg`'s live spell
pages) - Battlewrath was right, this project's own indexed data was wrong.**
Cross-checking each spell ID directly against its public database page
(`db.ascension.gg/?spell=<id>`) shows all three really do cost Runic Power,
and two of the three names in this project's own data were also wrong:

| Spell ID | Real name (db.ascension.gg) | Name in `necromancer_abilities_reference.html` | Real cost | `manaCost` shown in our data |
|---|---|---|---|---|
| 504050 | **Command: Decaying Colossus** | "Command: Blight" | 30 Runic Power, 45 sec CD | 400 |
| 504316 | **Command: Abomination** | "Command: Hook" | 20 Runic Power, 35 sec CD | 300 |
| 504489 | Command: Bonefreeze (name matched) | "Command: Bonefreeze" | 30 Runic Power, 20 sec CD | 300 |

**Root cause, now confirmed rather than guessed:** `necromancer_abilities_
reference.html`'s extraction pipeline labels every ability's cost value
`manaCost` regardless of the spell's real power type - it isn't reading
each spell's own power-type field before naming the cost column. The
400/300/300 numbers were really Runic Power costs, mislabeled at extraction
time (this was flagged as the leading hypothesis before checking; now
confirmed). Worth a real pipeline fix later, but per Battlewrath the
Resources-tier bar itself doesn't need this - it just reads the game's own
live current/max value, not per-ability costs.

Also worth noting for any future lookup: `db.ascension.gg` has real,
server-rendered per-spell pages (cost, cooldown, range, effects) at
`?spell=<id>` for the exact custom IDs this server uses - this is a real,
already-existing public spell database, not something the community needs
to build from scratch. `Command: Abomination` (504316)'s page also shows a
second effect worth recording: **Effect #2 - Trigger Spell: Grave March
(500991)**, not previously in this project's index.

**Power-type value - CONFIRMED LIVE (2026-07-06).** `Glacial Tap`'s own
db.ascension.gg page (805369) already showed **"Effect #1: Give Power:
(Runic Power) Value: 25"**, corroborating the display name - but Battlewrath
then captured a real "Runic power" WeakAura in-game and pasted the import
string directly. Decoded via `weakaura_codec.py`: its Power trigger carries
`powertype: 6` - the exact native WoW `PowerType` enum value Death Knights
use. **Battlewrath's "just the DK's version, re-used" hypothesis is now
directly confirmed by real client data**, not just corroborated by a
display name. (Mana's own captured aura confirms `powertype: 0`, the
standard Mana value, for symmetry.) See `slot_assignment.md`'s open items
for the full writeup, including a real bug this caught in
`resource_threshold_aurabar.schema.json` (documented `power_type` as a
string enum name; it's actually the raw integer).

**Also worth flagging (unrelated to the above, spotted incidentally):**
`db.ascension.gg` lists Glacial Tap's cooldown as **8 seconds**, not the
12 seconds recorded in `Docs/WEAKAURA_INDEX.md`'s worked example - not yet
reconciled (could be a talent/rank modifier, a data-source version
difference, or another extraction error). Flagged for a follow-up pass,
not corrected here since the cause isn't confirmed yet.

## Life Force

Real per-minion costs confirmed in `necromancer_abilities_reference.html`
under the name **"Life Force"** - this was briefly recorded as "Life
Essence" earlier in this project; Battlewrath corrected this directly
("It must be life force. My error."), so **"Life Force" is the confirmed
name**, not an open naming question anymore.

| Summon | Spell ID | Life Force cost |
|---|---|---|
| Raise: Abomination | 500335 | 3 |
| Raise: Gargoyle | 500329 | 3 |
| Raise: Banshee | 504861 | 2 |
| Raise: Skeletal Mage | 500331 | 1 |
| Raise: Ghoul | 500971 | 1 |

Talent modifiers found:
- **Champion of Kel'Thuzad** (807937) - reduces Skeletal Mage's cost to 1
  (i.e. a no-op at base value - only meaningful if Skeletal Mage's base
  cost is ever higher via some other modifier, or this talent is really
  doing something else worth re-checking).
- **Summoning Adept** (92123) and **Master Animator** (504431) - each
  increase max Life Force by 1.

No literal "starts at 3" base-value text was found anywhere - Battlewrath's
stated starting value of 3 is not yet independently corroborated by this
data, only the per-minion consumption amounts are. This mechanic is
explicitly **not** a Resources-tier slot - see `BUILD_METHOD.md` and
`USE_CASE.md`'s existing "+N LE" fly-out design, which already covers it
as a transient signal, not a persistent bar.

**Two spell IDs, two distinct roles - CLARIFIED directly by Battlewrath
(2026-07-06).** Both real, both checked against `db.ascension.gg`,
structurally identical-looking data (same three `Dummy (127)` effects,
same icon) - genuinely ambiguous from the spell pages alone, but Battlewrath
resolved it directly rather than needing a live guess-and-check:

| Spell ID | Name | Role (per Battlewrath) |
|---|---|---|
| **525004** | "Life Force: **Visual**" | **The debuff itself** - what's actually attached to the player, i.e. the real `aura2`-trackable stack-count source for the "+N LE" fly-out design (`USE_CASE.md`). |
| **805011** | "Life Force" (no suffix) | **The counter within the native UI element** - drives the separate pre-existing in-game display Battlewrath described earlier ("Life Force has it's own native in-game UI element already"), not the debuff aura itself. |

Counterintuitive naming (the plain "Life Force" name is the UI-counter
spell, not the debuff - the "Visual" one is the actual debuff) - worth
remembering exactly this way round when wiring the fly-out, not by
assumption from the names alone. `525004` is the one to use for an `aura2`
trigger; `805011` is only relevant if this project ever needs to read or
react to the native UI element itself, not the debuff.

## Guardian count buff - a real per-minion-type stacking buff (found 2026-07-06)

Per Battlewrath: "per guardian, you get a buff" - each active summon of a
given minion type applies a stacking buff to the *player* (not just the
minion's own existence), and the stack count directly reflects how many of
that minion type are currently alive. Confirmed real via
**805016** - checked `db.ascension.gg`, named **"Skeletal Warrior"**
(Battlewrath's own term, "Lesser Skeletal Warrior," differs slightly - same
minor naming-precision gap already seen with the Command abilities).
Mechanically: `Effect #1 - Apply Area Aura: Pet Owner` (radius 200 yards) -
a real WoW mechanic that reapplies/maintains an aura on the pet's owner for
as long as the pet exists in range, and stacks independently per
simultaneous pet - exactly the behavior Battlewrath confirmed live: **2
stacks with 2 Lesser Skeletal Warriors summoned.** (Effects #2/#3 are
separate `Dummy` script effects buffing **Soulfreeze**, 801724, by 80
within 100 yards - a nearby-pet damage/proc interaction, not part of the
counting mechanic itself.)

**Shelved, 2026-07-06 - not load-bearing for now.** This looked like a
materially better pet-count mechanism than this project previously
assumed (a real, direct `aura2` stack-count status query instead of the
time-based countdown the existing community aura uses), but Battlewrath
pulled back on it directly: "We might not be able to track it." Whether
this owner-buff pattern is reliably usable/exists for every minion type
(only Skeletal Warrior confirmed so far) is uncertain enough that it
isn't the basis for anything built right now - kept here as a real,
confirmed finding, not deleted, in case it's worth re-checking later.
Separately, Battlewrath was also explicit that **this project shouldn't
compete with Life Force's own native UI element for count/tracking
display at all**, regardless of what's technically trackable - see
`USE_CASE.md`'s "Redesign, 2026-07-06" for the actual direction instead
(a transient combat-text alert on budget change, suggesting the
highest-value affordable summon, not a persistent counter of any kind).

## Cross-references

- `Outputs/dbc_preview/necromancer_abilities_reference.html` - the actual
  source of every value above.
- `Outputs/weakaura_index/necromancer_weakaura_index.json` - opportunity-
  type classification per ability (cooldown_tracker/proc_alert/etc.) -
  has no cost/resource fields itself, cross-reference by spellId against
  the file above when both are needed.
- `USE_CASE.md`'s "Tracking non-directly-controlled pets" section - the
  existing Life Force fly-out design.
- `Docs/WEAKAURA_INDEX.md`'s extended taxonomy - `resource_threshold` is
  the opportunity type both Mana and Runic Power's bars will eventually
  use for any threshold-marker work.
