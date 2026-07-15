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

The buckets in plain language; no WA words. Multi-pick — each choice becomes its own group.

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
| the HTML shell's client-side JS encode (deflate+b64) | ✗ the picker build proper |

**Naming — values, not questions (settled 2026-07-15):** no naming screens. Group `id` derived —
`"COA — <Spec> <bucket> (<scope>)"` — shown at Q5 as an EDITABLE PREFILL (optional text box; invisible cost to
whoever doesn't care). Member `id` = spell family name under the group. The **"COA —" namespace prefix** dodges
collisions with the user's handmade auras AND makes the pack findable/deletable as a block (law 6 made practical).
**Identity is DETERMINISTIC, not random**: uid + suffix derived from class:spec:bucket:scope, so re-running the
wizard re-produces the same identity → WA's import offers "update existing" → the wizard is RE-RUNNABLE (change
answers, re-import, the pack updates in place instead of breeding duplicates). A randomizer would solve collision
but cost idempotence.
**The group name is a SEAT label, not a content claim (Battlewrath):** "Lich DoTs (target)" = *the DoT tracker
that shows while you play Lich* (its class+spec load) — NOT "DoTs of the Lich tree." Contents = whatever families
the user picked, cross-tree, growing by the end (Q4.5 widens). Only MEMBERS name content — one family per member.
This is why identity keys on class:spec:bucket:scope and never on contents: membership grows across re-runs while
the group stays the same group.

**Output specifics (Battlewrath, 2026-07-15):**
- **Placement:** a `dynamicgroup` needs NONE — grow/arrange is its job. A static `group` gets basic steps:
  each member one to the right of the last — offset = member width + a pixel gap (HxW+px). Dumb arithmetic,
  never layout intelligence.
- **Styling:** we print BASIC styling only; the group's style is the user's to edit in-game (law #6).
- **Load:** every pressed aura carries **class + spec load** — the contract's existing shape, applied always.

## The side door — the explorable inventory (opportunity shopping)

The walked path is the front door, but the ID inventory stays BROWSABLE alongside it: class:spec spell families,
names + icons, open shelves. For the user who doesn't know what they want until they see it — discovery feeds the
wizard (spot something → "track this" drops them into the flow at Q4 with the pick made). The original
shelves-first design survives here as a MODE, not the navigation.

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
