# picker_tree — the wizard's decision tree (prototype · walk-converged 2026-07-15)

_The HTML picker V1's navigation as a story: every screen is a QUESTION, every answer is a NARROWING, and every leaf
must land on a docket we can press. Talked through end-to-end with Battlewrath 2026-07-15; this file carries the
converged shape. The same script runs in the future addon shell — it just skips Q0 (spec detection is API-driven
in-game)._

**Status marks:** ✔ pressed & live-proven · ◐ basis proven, contract/recipe unbuilt · ✗ gap (ledger at bottom)

## The converged flow (one line)

**What class? → What spec? → What do you want on screen? → Watched where? (DoT/HoT only) → Which ones? →
Only-when-it-matters or always-there? (pruned per bucket) → "Add the rest with the same treatment?" → your string.**

Four questions after class/spec; some paths skip two of them. The wizard speeds up as it narrows.

## The design laws the walk settled

1. **Every answer prunes the next menu.** Class prunes specs, spec prunes spells, and the PICK prunes the look —
   the spell's nature decides what it can legally be (a DoT can be a draining bar or a swept icon; a proc is a
   moment, icon territory; a resource IS a bar). Bar/icon are mutually exclusive in places (progress on an icon
   crashes live — Icon.lua:642); the invalid combination is never warned against, it is **unaskable**.
   Constrain by construction — no runtime validation in the shipped shell.
2. **Spell before behaviour.** The pick is the parent of the look, not a sibling (Battlewrath). Concrete before
   abstract, and the behaviour menu is *bred from* the selection.
3. **The behaviour question is universal: one fork, per-bucket costumes.** Not preset shelves per bucket — ONE
   two-answer question ("show it only when it matters, or keep it always in place?") whose wording localizes per
   bucket. **Two docket fragments total** — *appear* and *persist-styled* — cover the whole tree.
4. **Styled state is ability-local.** The persistent form dims each icon for ITS OWN cooldown (`onCooldown`),
   never a compound whole-HUD state.
5. **No WA vocabulary forward of the curtain.** "Dims when it's not ready" — never "show on cooldown." The user
   answers questions; they never edit a field. Anything beyond the presets they do in WA's own UI afterwards
   (the everyman law working as intended).
6. **The wizard says what it is.** Instruct plainly: *this isn't build-your-full-UI-in-one-go* — you get packs,
   you arrange them in-game (the product is TRACKER PACKS, not a HUD). We print basic styling; the group's style
   is theirs to edit in WA's UI afterwards. Sets expectation AND hands over ownership in one line.
7. **Pick a lane, populate it (Battlewrath's crisp).** Selection is **class + spec through the whole pipeline** —
   every shelf, every offer, every load is sliced by the seat. One pass of the wizard fills ONE lane (one group,
   one string — the machine's bundle shape). After the string: *"another lane?"* loops back to Q2 with class+spec
   retained. Lanes accumulate across passes; the UI accumulates in-game, never in one sitting.
8. **Data flattening, not in-game emulation (Battlewrath).** The picker's style is TEXT — flat, honest data
   surfaces. No icon art, no aura previews, no game-look mimicry: **WA owns the "oh, look at that come alive"
   moment.** The HTML shows you the terrain; the game shows you the magic. (Also closes the icon-images gap:
   text-only, first pass and by identity — iconPath names ride the data for any later enrichment.)

---

## Q0 — "What class?"

21 crests, one click. The only question the addon shell wouldn't ask.

| backing | status |
|---|---|
| class list = the batch press's enumeration (`batch_press.py`, `Input/*_talents.json`) | ✔ |

## Q1 — "What spec?"

| backing | status |
|---|---|
| spec enumeration + member lists (`pull_target_tracker.py` spec_spells; the 110-pack slicing) | ✔ |
| `load.specialization` (index-keyed, Prototypes.lua:1075) solved; the 20 display names await the addons bench's spec-name capture | ◐ |

## Q2 — "What do you want on your screen?"

The buckets in plain language; no WA words. **Single-pick per pass** (law 7 — pick a lane, populate it); after
Q5's string, "another lane?" returns here with class+spec retained. Each lane = its own group = its own string.

| choice (user-facing) | product behind it | status |
|---|---|---|
| **My DoTs on enemies** | Target tracker / multidot (forks at Q2.5) | ✔ / ◐ |
| **My HoTs on allies** | the ally mirror (same fork, default flipped) | ◐ |
| **My cooldowns — what's ready** | Ready tracker | ✗ contract |
| **My procs — moments to react to** | Self tracker | ✗ contract |
| **My stacks — things I build up** | Self tracker (counter face; gate→payoff) | ✗ rides Self |
| **My resources** | resource-bar pack ("a pack, not a classification problem") | ◐ |
| **My pets** | guardian tracker (scaffold closure-stamped; custom Lua = addons lane) | ✔ |

_Open taste question (Battlewrath's seat): seven rows might be one too many for a first face — "procs" and "stacks"
may read alike; a fold to "Moments" is on the table. Unresolved, deliberately._

## Q2.5 — "Watched where?" (DoT/HoT only — a SCOPE fork, so it precedes the spell pick)

> - **On my current target** — what's ticking on the thing I'm hitting right now
> - **On everything I've tagged** — every DoT I've got out, each with its victim's name

- **Current target** → harmful-aura-on-target check; no name needed (the target is the context); full look menu
  stays open downstream. _Backing: the pressed Target tracker._ ✔
- **Catch-all** → born as NAMED duration-bars in a stack (a timer with no victim is noise); the look screen
  shrinks to ~sort order. _Backing: the multidot pattern (press-ready)._ ◐
- **HoT mirror:** same fork, opposite gravity — a healer's home case is catch-all ("who did I heal + what's still
  ticking"); the wizard reflects it by ordering, not smarts. ◐ recipe

## Q3 — "Which ones?"

Names + icons, checkboxes — the pressed library for that class:spec:bucket. A shelf you were walked to.

| bucket | the select behind the shelf | status |
|---|---|---|
| DoTs | batch select output (dot ID-families per class) | ✔ |
| HoTs | friendly mirror (HELPFUL, ally-target verbs) | ✗ recipe |
| cooldowns | ready-select off resolver axes (`costed`/invocation) | ✗ recipe (falls out of the Ready contract) |
| procs | behaviour-driver cut ("have proc, use spell"; weather skipped) | ✗ recipe |
| stacks | class-mechanic + talent-local stack spells | ✗ recipe |
| resources | power-type enumeration per class (cheap, finite) | ◐ |
| pets | pet-spec detection (the guardian registry names the family) | ◐ |

## Q4 — "Show it only when it matters, or keep it always in place?"

**The universal fork.** Two primitives, per-bucket costumes; menu bred from the Q3 pick (pruning law #1):

| bucket | "only when it matters" (react) | "always in place" (anticipate) |
|---|---|---|
| procs | appears when it's live, gone when it's not | fixed slot, lights up when live |
| cooldowns | **a queue of what's ready** (dynamic group; existing = pressable) | fixed grid, sweep running, **dims while cooling** (own-state only), wakes when ready |
| DoTs (current target) | appears while ticking | fixed slot, styled by remaining time |
| DoTs/HoTs (catch-all) | — (the stack of named bars IS the react read) | — |
| resources | — (skips Q4: a bar is the persistent read) | — |
| pets | — (ships as the one proven shape) | — |

For picks where bar AND icon are both legal (current-target DoTs), the look choice rides this screen as
**illustrated cards** — a picture of each look with its behaviour caption; users pick with their eyes.

**Mechanical back:** two docket fragments — *appear* (trigger show-state only) and *persist-styled*
(showAlways + ability-local condition flips). ✗ not yet written as fragments; small, high leverage.

## Q4.5 — "Add the rest with the same treatment?" (the closer)

After behaviour is decided, offer the REMAINDER of that class:spec:bucket shelf as one checkbox pass — same
behaviour pre-bound. The one screen that deliberately WIDENS: an "anything else?" at the door.
Cheap both ways: the user decides once; the shell re-renders Q3's shelf with Q4's answer attached.

**What "the rest" means, precisely (Battlewrath): same-TYPE by effect chain, flattened by ID family.**
- **Same type:** the effect chains (resolver axes / typed edges) decide membership — pick a cooldown and the
  remainder offered is cooldown-shaped abilities only, never a mixed bag. The classification already in hand IS
  the shelf filter; no new analysis.
- **Flattened by ID family:** one row per family, ranks collapsed — which is exactly what the pressed aura wants,
  since drive-from-ID matches the spell FAMILY not a rank (the match-family law). The row and the aura agree on
  what a "spell" is.

## Q5 — the string

One group, one Copy button, three lines of "open WoW → /wa → Import → paste."

| backing | status |
|---|---|
| bundling + encode (the machine, server-side: stage → gate → pickup) | ✔ |
| the HTML shell's client-side JS encode | ◐ feasibility CONFIRMED (2026-07-15); the port is the picker build proper |

**Feasibility (assessed against the codec):** the string = `"!WA:2!" + EncodeForPrint(CompressDeflate(
LibSerialize.Serialize(table)))` (`weakaura_codec.py:13`). All three layers land in self-contained JS:
LibSerialize = a PORT of our own live-proven Python reference (translation, not research); DEFLATE = native
`CompressionStream('deflate-raw')` (inline pako as old-browser fallback — still no CDN); EncodeForPrint = a
6-bit alphabet, ~20 lines. **Construction stays pipeline-lawful:** templates are pressed through the REAL
machine (gate → fill → canon) at BUILD time and ship completed inside `library.json`; the JS only substitutes
slots + places + encodes — it never authors structure. **Cross-validation:** same picks pressed both ways →
decode both strings with the existing decoder → table-diff CLEAN (decode-equivalence, not string bytes — DEFLATE
output legitimately varies per implementation). Live import = the final stamp (invariant 6).

**Naming — values, not questions (settled 2026-07-15):** no naming screens. Group `id` derived —
`"COA — <Spec> <bucket> (<scope>)"` — shown at Q5 as an EDITABLE PREFILL (optional text box; invisible cost to
whoever doesn't care). Member `id` = spell family name under the group. The **"COA —" namespace prefix** dodges
collisions with the user's handmade auras AND makes the pack findable/deletable as a block (law 6 made practical).
**ONE-TIME MINTING (Battlewrath, final):** every emission is a fresh object — identity is per-mint (seat label +
a mint randomizer on the suffix/uid). **No reloading a string to edit it; no update-in-place; the picker EMITS and
never ingests.** The game is the editor (law 6): re-run → spit out fresh → drag members into your existing groups.
Why hard: (a) any regeneration path complicates everything it touches; (b) update-matching could clobber a group
the user has since edited in-game; (c) an import surface would make us handle types we didn't make and can't
natively press. (Supersedes an earlier deterministic-identity/update-in-place design — the randomizer was the
right call; the double-import uid live-check is MOOT.)
**The group name is a SEAT label, not a content claim (Battlewrath):** "Lich DoTs (target)" = *the DoT tracker
that shows while you play Lich* (its class+spec load) — NOT "DoTs of the Lich tree." Contents = whatever families
the user picked, cross-tree, growing by the end (Q4.5 widens). Only MEMBERS name content — one family per member.

**Output specifics (Battlewrath, 2026-07-15):**
- **Placement:** a `dynamicgroup` needs NONE — grow/arrange is its job. A static `group` gets basic steps:
  each member one to the right of the last — offset = member width + a pixel gap (HxW+px). Dumb arithmetic,
  never layout intelligence.
- **Styling:** we print BASIC styling only; the group's style is the user's to edit in-game (law #6).
- **Load:** every pressed aura carries **class + spec load** — the contract's existing shape, applied always.

## The side door — the LIBRARY face (settled 2026-07-15)

Bigger than opportunity shopping: the explorable inventory is the flattened data offered **as a library rather
than a guiding**. It shows what classes exist, their **effect chains**, the **procs they spawn** — the ways we
flattened the game, browsable ID→ID→ID. Two uses:
- **Forecast** — see the terrain, decide where you'd like to start, then step into the wizard.
- **Reasoning** — enough basis to make YOUR OWN auras work in WA's UI (follow the chain: this talent → this proc
  → this consumer). The library teaches; the wizard presses.

Knowledge shows EVERYTHING (chains don't hide because a contract is unbuilt); the **"track this" action exists
only on pressed lanes** — the door renders only where it opens.

**The gap-display rule (Battlewrath, 2026-07-15):** where a chain hits an unresolved custom effect code
(`custom_N` — the codes the game's own data doesn't explain), the library prints **"not provided by CoA"** —
verbatim, no guessing dressed as knowledge. Honest boundary labeling (trace the spine, name where the data
stops), and the label itself is **subtle pressure toward dev resolution** — the public face of the gap does the
asking we have no channel for. If a code later resolves (DB probe or dev docs), the label retires row-by-row.

## The data pool — assessed READY (2026-07-15, checked on disk)

Intent: **show what we have, not rework it.** The build's data step = ONE dumb emit gear (house style): read the
sources below → `library.json` → embed in the HTML. Verbatim, provenance intact.

| need | source, as it sits | state |
|---|---|---|
| the chains (library spine) | `creator/planning/resolved.json` — 9,152 spells × axes+edges+effects; ID→ID→ID = read forward | ✔ |
| class/spec/spell cards | `Input/*_talents.json` — spellId·name·tree·**description (100% coverage)**·terms·passive·costs·grid x/y | ✔ |
| spec display names | the Input TREE names (Q1 cards covered today; the addons capture still wanted for the load INDEX map) | ✔ |
| spec landing captions | `tables/_index.json` — per-class:spec hub·shape·counts | ✔ bonus |
| DoT shelves | the batch select (fed the 110-pack press) — regenerates ID-family lists on demand | ✔ |
| icon images | not held (MPQ-resident); **closed by law 8: text-only** — `iconPath` names ride along for later | closed |

## The seams — closed (Battlewrath, 2026-07-15)

1. **One-time minting** (see the naming block): emit-only, no regeneration, no import surface. Re-run = fresh
   mint; merging = drag members in-game. Both-flavours-of-one-seat is thereby trivially fine — mint twice, drag.
2. **The side door = the library face** (above): show all knowledge, act only on pressed lanes.
3. **ONE HTML for the first pass** — 21 class files from the start is overload, not distribution. Split only if
   interest proves it. Weight management (icon strategy) = the build's problem, with real byte counts in hand.

---

## The gap ledger (ranked)

1. **Ready tracker contract** — the one structural gap: a whole mechanism column (spell-trigger/cooldown), no
   contract. Needs the spell-trigger palette + liveness harvest. Unlocks Q2-cooldowns AND Q3-cooldowns, and both
   its Q4 costumes (queue / dim-grid) are already specified above.
2. **Self tracker contract** — procs + stacks + windows ride it; mechanism known (aura2 `unit=player`, exact-id
   standing pattern), narrowing decided (the universal fork). Assembly, not invention.
3. **The two behaviour fragments** — *appear* / *persist-styled* as named docket fragments. Smaller than the
   preset shelf originally sketched; every product reuses them.
4. **Select recipes** (HoT mirror · proc behaviour-drivers · stacks) — bounded pulls off data in hand.
5. **Spec display names** — chartered to the addons bench (census mission); index wiring solved.
6. **JS-side encoder** — belongs to the picker build itself, not the tree.

**The shape:** one contract to invent (Ready), one to assemble (Self), two fragments, some recipes. The tree is
walkable end-to-end today for DoTs (both scopes) and pets; every other leaf knows exactly what it's waiting on.
