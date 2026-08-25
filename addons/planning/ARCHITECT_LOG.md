# ARCHITECT_LOG — outcomes and reasoning, so `ARCHITECT_INBOX.md` stays input

_Opened 2026-08-21. One entry per resolved question (from the inbox) or per design decision taken
with Battlewrath in conversation. **Each entry: the question · the outcome · the reasoning · what it
cites · where it LANDED (the governing doc that now carries it) · whose word it was.** The log never
carries the ruling's body — that lives in the doc named under "landed"; the log is why, and where.
Read newest first._

    ENTRY FORM    AL-N · date · from (inbox AI-N | conversation) · QUESTION · OUTCOME · REASONING ·
                  CITES · LANDED IN · WORD (Battlewrath | architect, with the rule applied)

---

## AL-61 · 2026-08-25 · from inbox AI-35 (the Analyst's law pass, RI-79) — FOLDED: primitives first, L21 compressed, the collision decided
- **QUESTION** the pass came back; the fold is the architect's. Its measured finding shaped it: of 22 laws
  ONE has been fought over (L21: 16 citations, 5 boundary/strike lines; twenty laws: none) — so the
  utility is 22 primitives a reader checks FIRST plus one real boundary section, not 22 essays.
- **OUTCOME** four folds: (1) **§5 opens with THE PRIMITIVES** — one line per law, checked before any
  clause; a reach the primitive does not cover stops there. (2) **L21 compressed** — the draft's one
  structural recommendation, taken: L14's own primitive turned on L21; the forced consequence and the
  MEANING/SUBJECT boundary moved to §4d (their home), the §5 entry pointing. (3) **The L-number collision
  decided:** bare L-N inside this product's docs means THIS series; any cross-product citation carries the
  product name (`landmark_design.md` has its own series; renaming ours would break the citations for a
  fault qualification fixes). (4) **The draft renamed to `audit/law_pass_2026-08-25.md`** — the pass
  RECORD: instances, relates-to citations, the L10/L17 border note, and L15's recovery-not-reach note stay
  there, not in §5.
- **NOT FOLDED, deliberately:** L14 is not widened — the primitive ("one home per fact") already carries
  the generality the Analyst's three outside-the-briefs instances show; the law's wording stays, the
  instances stay evidence in the pass record. L22's single gloss stays in §5 — the trajectory warning is
  noted and the gloss is one; it moves to the home the day it is two. No negative scope was authored —
  twenty "none yet" lines held RI-79's rule.
- **CITES** AI-35 · `audit/law_pass_2026-08-25.md` · RI-79 · his form ("Relates to; Does not relate to;
  Lesson…" → "Or just a primitive") · L14 · AL-48/58/60.
- **LANDED IN** `driver_architecture.md` §5 (the primitives table · L21 compressed) · §4d (the moved
  clauses) · the renamed audit file.
- **WORD** Battlewrath (the form and the primitive refinement); Analyst (the pass, measured before drafted);
  architect (the fold and the collision decision).

## AL-60 · 2026-08-25 · from inbox AI-34 (Addon creator) — subject vs space: NOT ruled; the guard is a CHECK the fold brings
- **THE NEED, plain, his words (the answer is given in this register on his instruction):** *"Each subject
  type gets its own contents and controls to match their content, or display to match their display. And
  the pane / tab is just the rendering space."* A subject brings its contents and controls; a pane is the
  space they render in; selecting a different subject rebuilds the content; the pane never changes
  identity or job. Recorded here as the plain statement — AL-58's boundary already says it from the
  control side.
- **THE ASK** should *"did the subject change, or did the space?"* be ruled anywhere, or stay a bench note
  on `concepts/row.md`?
- **OUTCOME** **NO — it stays a bench note.** One measured surface (the object pane) is not a basis for a
  law; the bench's own preference was no; and L21 does not contain it — his strike stands: L21 is about a
  SETTER auto-selecting, row.md's rule is about a control's NEIGHBOURS; *"both dislike 'the UI changed
  under me'"* is a family resemblance, not a shared law. A second surface producing the fault re-raises it.
- **AND THE REAL CONFLICT IS HANDLED WITHOUT A LAW.** row.md forbids PAIRED BY FIT; AceGUI `Flow` pairs by
  fit as its whole mechanism; `widget.lua`'s footer holds its line only by declared relative widths that
  NOTHING checks. A rule nothing checks is violated silently — so the guard is a **CHECK, not a passage**:
  *same neighbours in every state* is a property the offline model can assert (render the states, compare
  who sits beside whom). **Whoever folds the object pane onto Flow brings the neighbour check with the
  fold.** That names who and when; it rules nothing today. The separate mechanism question (is
  pair-by-declared-relation expressible in AceGUI, or does it want a layout of our own) stays the bench's
  to measure, admitted through `concepts/type-or-feature.md` as the item itself said.
- **ON THE REGISTER** his tension is upheld and the item already carried the correction: the need was
  written as an argument with ✗/✓ pairs and the bench then reasoned from its own framing — *"the response
  is a symptom of the wording."* This entry answers in the plain form and the note in row.md should read
  that way too.
- **CITES** AI-34 · his words (the need · the strike · "the lawyer discussion making the question harder
  to parse") · `concepts/row.md` · `interface/object.md:63` · `object.lua:577-582` · AL-58 · L21.
- **LANDED IN** this entry; row.md keeps its note (the bench's, demoted at §668, stands as filed).
- **WORD** Battlewrath (the need, the strike, the register); Addon creator (the honest filing against its
  own assertion); architect (the NO and the check-at-the-fold).

## AL-59 · 2026-08-25 · conversation — L22 lands with his affordance gloss; the map's right-click spawn RETIRED
- **QUESTION** L22 put premise-first (AI-31's generalisation); his "Yes", with two additions.
- **OUTCOME** **L22 on the basis (§5):** used together, one surface — a tab may only separate things used
  apart; the test is the interaction, not the widget kind. **With his gloss:** dock/undock is the
  AFFORDANCE the law leaves room for — Promoter and Object in view, Object undocked to the side — and
  **the default is tab swapping**; an affordance, never the norm. **And his retirement:** *"One thing to
  retire from Map now is the right click objects pane spawn. With a future light version to replace it."*
  ⟶ the map's right-click objects-pane spawn is RETIRED — removed whole, never parked
  (half-formed-code-invites-building-on-it); the LIGHT replacement is a named future item, unspecified,
  not built until it earns its spec. Routed to the bench as RI-78 (the code is theirs; the interface
  registers are the Analyst's to reconcile).
- **REASONING** the law closes the question that returned three times (AL-13 → AL-47 → AL-49) by naming
  the criterion once; the gloss keeps the escape valve without letting it become the norm; the retirement
  follows the law it just landed under — the objects pane spawned OVER the map competed with steering it.
- **CITES** AI-31 · his words (the yes, the gloss, the retirement) · A10.9 · AL-49 · `map.lua:1018-1019`
  (the right-click ownership the retirement touches).
- **LANDED IN** `driver_architecture.md` §5 L22 · RI-78.
- **WORD** Battlewrath (all three); Addon creator (the generalisation's filing); architect (the law text).

## AL-58 · 2026-08-25 · from inbox AI-33 (Addon creator) — L21 carries the MEANING/SUBJECT boundary
- **QUESTION** can PER SELECTION carry the boundary in its own text, so it does not read as forbidding
  data-driven rebuilds? (The bench filed against L21's proposal; L21 had already landed at §587 — the ask
  applies to the landed text.)
- **OUTCOME** **yes — L21 amended on the basis:** the law governs a CONTROL'S MEANING, never a pane's
  SUBJECT. Different subject → the rebuild is the honest response (a route's fields shown for a run would
  be the defect). Same subject, control means something else because of what is beside it → the fault, his
  "whack a mole". Record/Export by loaded type · the roster · dock/undock are law-2 rebuilds, named in the
  law so the three things the architecture depends on are visibly outside its blast radius.
- **REASONING** the bench's collapse is right and cheap: one mechanism (pick a subtree, tear down,
  rebuild), three selectors (a clicked tab · the loaded TYPE · the dock state) — A10.1a's subtree choice
  paying out a third time. A user describes both changes as "the UI changed under me"; the law must name
  which one is the fault or it will be read as forbidding the mechanism.
- **CITES** AI-33 · L21 (§587) · `pane-build` law 2 · A10.1a · `AceConfigDialog-3.0.lua:1086-1272` (the
  bench's read of the vendored copy: the table decides shape, get/set decide values).
- **LANDED IN** `driver_architecture.md` §5 L21 (the boundary clause).
- **WORD** Battlewrath (the collapse, "same tab principle"); Addon creator (the three-selector table and
  the boundary); architect (the amendment).

## AL-57 · 2026-08-25 · from inbox AI-32 (his placement) — metadata on the EXPORT surface: RESERVED, and ruled travelling from the start
- **QUESTION** two: does the record say the surface is RESERVED rather than existing? and are the metadata
  fields ruled under travelling-data-NAMES-never-SUPPLIES from the start rather than after the first import?
- **OUTCOME** **both yes.** His placement banked into AP-3 (the route-metadata proposal it extends): load
  to export → meta + author comments → export; a PUBLISHING concern — a fourth WHEN beside authoring ·
  running · steering; NOT a fourth authoring lane. The AP-3 text now says RESERVED in so many words (no
  Export exists; A4.2's owed round-trip cited) — description never prescription. And the fields are ruled
  travelling from the start: capped, escaped, consumed as DATA; `ROW_ARG_RULE`'s `source="user"` cap
  extends. The bench's own argument sealed it: metadata authored at export is BY DEFINITION for a
  recipient, so all of it travels — the surface that knows the data is leaving is where the boundary gets
  drawn, and there is no second candidate.
- **REASONING** ruling the boundary at specification time costs one sentence; adding it after the first
  import costs an incompatible wire format. AI-18/AL-30's open half ("the ARG side leaks") gets its
  answer for this surface before the surface exists.
- **CITES** AI-32 · his words · AP-3 · A4.2/A8.5 · travelling-data-NAMES-never-supplies · ROW_ARG_RULE.
- **LANDED IN** AP-3 (the placement + both rulings) · the WHEN note at AL-49.
- **WORD** Battlewrath (the placement); Addon creator (both concerns, the measured no-Export); architect
  (the two yeses).

## AL-56 · 2026-08-25 · from inbox AI-31 (his ruling + the bench's collision) — STEERING is a third WHEN; `args.run` → `args.curate`
- **QUESTION** part 1 none — his ruling landed: the map CONTROLLER does not enter the unified pane; *"it's
  steering the map that would compete with also authoring. And using the UI shouldn't be whack a mole
  until you get what you want."* Part 2, phrased yes/no by the bench: does `args.run` become a curation-
  named key, so the lanes read as AL-49's structure?
- **OUTCOME** part 1: **steering is the third WHEN** (authoring → the pane · running → the remote ·
  steering → with the thing it steers), supplying the why A10.9's "Map and its controls are ONE SURFACE"
  stated without. Noted at AL-49 as an extension, not a supersession. The generalisation (used-apart may
  be tabs; used-together must share a surface) is drafted as L22 and put to Battlewrath premise-first in
  chat — not landed by this entry. Part 2: **yes — `args.run` → `args.curate`** (verb form, matching
  `promote`; the displayed names already differ from keys). The bench executes (`options.lua` is theirs);
  A10.1a's structural check and the acceptance rows that cite the key ride the same change — the Analyst
  reconciles the rows; free while every lane is empty, not free after the first fold, which is why now.
- **REASONING** one word naming opposite sides of the authoring/running split is the shift-and-renumber
  fault waiting for the fold; the collision was found before it cost anything because the bench checked
  the key against AL-49 before filling it.
- **CITES** AI-31 · his ruling · AL-49 · A10.9 · A10.1a · `options.lua:113-131`.
- **LANDED IN** the extension note at AL-49 · this entry (the rename yes). L22 pending his word.
- **WORD** Battlewrath (the ruling); Addon creator (the collision and the yes/no framing); architect (the
  rename answer and the L22 draft).

## AL-55 · 2026-08-24 · from inbox AI-29 (his catch) — the curation gate said where act 3 will read it
- **QUESTION** does AP-13 (6) gain the two-file split and the number/meaning line explicitly? (A wording
  amendment — (2) always carried the gate; (6) was the paragraph a reader reaches first.)
- **OUTCOME** yes, in (6) itself: consultation EMITS a findings file (OBSERVED, machine-emitted, re-runs
  free); the REGISTRY holds SETTLED, hand-curated; between them HIS curation, never a pipe. NUMBER findings
  apply as improvements with citation; MEANING findings file as challenges — instance count is not
  authority over UL-6/UL-15.
- **REASONING** the mechanical one is his and decisive: one shared file means every re-run overwrites
  curation or costs a hand merge — a tool that makes the work harder — and the census is the artifact
  guaranteed to re-run. Structural second: shared files make no entry's instances auditable.
- **CITES** AI-29 · his words · AP-13 (2) · machines-do-the-mechanical-work.
- **LANDED IN** AP-13 (6) rewritten.
- **WORD** Battlewrath (the catch and both halves); UI specialist (the mechanical argument); architect (the wording).

## AL-54 · 2026-08-24 · from inbox AI-30 (the specialist, against its own item; his stop) — the SWEEP is withdrawn
- **QUESTION** his: *"a stop / reframe to determine what this work buys us"* — busy work or value?
- **OUTCOME** **as a sweep, busy work; the stop is adopted.** AL-51's redirect is withdrawn (dated note
  below at AL-51): the field is consulted AT ADMISSION, on a candidate we already have; the seat's next
  work comes from a live problem. `prior_art_ace_field_2026-08-21.md` (230 addons, re-runnable, cited) is
  the standing answer and gets EXTENDED when a question outruns it. **Ask 2 answered, not waved off:** the
  one class that file cannot answer is pixel-space measurement from captured geometry — that names a
  TARGETED probe's scope when a spacing question actually arises, and today none is waiting.
- **REASONING** the hole in AL-51's inference is real and the specialist named it against its own filing:
  "our code has no types yet" implies the bench is YOUNG, not that the field holds our types; a second
  instance of our own arrives with our why attached. The evidence: the field has only ever validated
  (collapse, tabs — built on the sheet first, cited at admission), the one field-only finding was a
  targeted question, and a probe whose shape moved four times in three exchanges had no question behind
  it. ★ A test that can stop its own author's redirect is the loop working — the same property AI-28
  claimed for the admission test ("a test that only ever bites the other seat is not a test").
- **CITES** AI-30 · his stop quoted · `prior_art_ace_field_2026-08-21.md` §2f · UL-16/UL-18 · AL-51.
- **LANDED IN** AP-13 (6) rewritten · the dated note at AL-51. Rule 3 of `concepts/type-or-feature.md`
  unchanged (two sources, ours OR the field) — only WHEN the field is consulted moved.
- **WORD** Battlewrath (the stop); UI specialist (the case, against its own item); architect (the adoption
  and the ask-2 answer).
- ★ **HIS WHY, given after the landing (2026-08-24):** *"I know I want training data. But our path was too
  lossy, too broad and about to over-write the work we've already proven."* ⟶ The WANT stands banked —
  training data — and the stop named the three faults any future path must not have: lossy (the census
  kept counts, not whys) · broad (no question behind it) · overwriting proven work (the gate AL-55 now
  guards). AP-13 (6) as rewritten is the path that has none of them.

## AL-53 · 2026-08-24 · from inbox AI-27 (UI specialist; his ruling same day) — the doorway lives in a REACHABLE section
- **QUESTION** where does a doorway live, if not in GOVERNING? His ruling had already withdrawn the listed-
  under-GOVERNING ask: a doorway, not a mandate; the registry grows from use.
- **OUTCOME** `DRIVER_BASIS.md` gains a three-line **REACHABLE** section after BASIS-GRADE REFERENCE — a
  THIRD KIND beside governing and evidence: settled work you build WITH, offered. One entry, the door
  (`UI_FOR_THE_BENCH.md`); the door names the nine. Chosen over the shelf and boot because DRIVER_BASIS is
  the one file the creator must read — visible at the reading moment; the other routes may add pointers
  from the bench side without this ruling.
- **REASONING** "not listed" meant "invisible", and GOVERNING would harden what he said not to harden. A
  new named kind states the offer's status once, instead of a mislabelled row under evidence.
- **CITES** AI-27 · his ruling quoted · `UI_FOR_THE_BENCH.md` · DRIVER_BASIS's own opening rule.
- **LANDED IN** `DRIVER_BASIS.md` REACHABLE · AP-13 (8).
- **WORD** Battlewrath (doorway-not-mandate, the loop); UI specialist (the door itself); architect (where it lives).

## AL-52 · 2026-08-24 · from inbox AI-26 (his words + his correction) — the registry holds UNITS; the entry carries the RECIPE
- **QUESTION** none to rule — his extension and his correction, landed: registry = single units · grouped
  units · user intent · the recipe; and *"isn't the code snippet needed to be the store to select from?"* —
  yes, so the entry carries a DECLARATION the builder executes, never pasted source.
- **OUTCOME** AP-13 (7), with his definition verbatim: Ace = the wiring points; how they sit together and
  how the behaviour is shaped = OUR PRODUCT; purpose = the Addon creator does not re-derive settled work.
  Recipe in panespec's vocabulary — selectable, constructible, checkable offline, binds NAMED from the
  closed list (travelling-data-NAMES-never-supplies). First three entries already exist and are cited.
- **REASONING** a token answers how far apart; a unit answers what this is and how it behaves — the second
  register cannot be derived from the first, and the week's input-commit work was already in unit shape.
- **CITES** AI-26 · `ui_panespec_borrows_spec.md` §4–§5 · `concepts/input-commit.md` · `sheet_decl.lua`.
- **LANDED IN** AP-13 (7).
- **WORD** Battlewrath (the extension, the correction, the definition); UI specialist (the form argument);
  architect (the banking).

## AL-51 · 2026-08-24 · from inbox AI-28 (UI specialist) — the census FEEDS the registry; the three-way test is ADOPTED
- ⚠ **SUPERSEDED IN PART (2026-08-24, AL-54):** the REDIRECT (census as the seat's next work) is withdrawn on his stop — the field is consulted AT ADMISSION, never swept; the ADMISSION TEST and the two guards stand unchanged. See AL-54/AL-55 and AP-13 (6) as rewritten.
- **QUESTION** two, both AP-13's: does the capture shape gain the admission test? does the census finding
  change the sequencing?
- **OUTCOME** **both adopted — AP-13 (6).** The census is the registry's first content (the bespoke
  inventory found NO types, for the structural reason: building twice by hand is what a type prevents; the
  field and repetition feed the register, our code checks it). The three-way test — TYPE / FEATURE /
  CAPABILITY with both guards (citable absence; ONE CALLER marked permanently, DEFINED not OBSERVED) —
  becomes AP-13's admission rule; it has run four times and bit both seats, which is what a real test does.
  ⟶ **THE REDIRECT, stated plainly:** the UI specialist's next work is the 254-addon capture AP-13 always
  specified (UL-0 act 3), not prototyping our own units. The two days were not waste — they produced the
  admission test and the unit shape — but the looking was in the wrong place, and the seat said so itself.
  Battlewrath saw the sequencing note and this read in chat the same turn.
- **REASONING** AP-13's own sentence arriving as a measurement: "derived from a captured census rather than
  authored cold." Draining AI-28 before AI-26 was the specialist's sequencing note, honoured: what gets in
  and from where settles before what an entry looks like.
- **CITES** AI-28 · `ui_custom_controls_inventory.md` · UI-2 (the creator's test) · UL-18 (rules 3–4) · his
  capability word · `concepts/type-or-feature.md`.
- **LANDED IN** AP-13 (6); the redirect is the seat's to act on.
- **WORD** Battlewrath (the third outcome); Addon creator (rules 1–2); UI specialist (rules 3–4, the census
  finding); architect (the adoption and the redirect).

## AL-50 · 2026-08-24 · from inbox AI-25 (UI specialist) — the remote's strip: SAME TEXTURE, FIXED TABS, the exception NAMED
- **QUESTION** is the remote's two-tab strip the same LANGUAGE as the unified pane's (undockable, return
  band) or a plain strip? Blocks the board of a 240-wide widget.
- **OUTCOME** **Same texture grammar, FIXED tabs — no undock, no return band.** The remote's two tabs are
  MODES of one widget (capture · test), not two panes sharing a frame. AL-13's dock/undock grammar is
  SCOPED to the unified pane's groups, and the scoping is a NAMED exception to its "nothing is one-way"
  reassurance — recorded here, never silent. The 240 carries a strip and no band.
- **REASONING** three of his own facts separate the options, so this is ruled rather than asked: (1) his
  16px-inset reason — *"the remote is more compact by nature"* — and chrome is what that argues against;
  (2) AL-7 put the remote beside the flight precisely so it does not claim UI — undocking a mode creates
  the third floating thing the remote exists to avoid; (3) his 2026-08-24 structure groups surfaces by WHO
  is using them and WHEN — running the route is one activity, and splitting its modes into windows re-opens
  the decision the grouping closed. ⚠ Architect's ruling on the scope of his own reassurance — **his to
  overturn**, presented in chat the same turn. ★ CONFIRMED by Battlewrath, 2026-08-24 ("That all
  tracks. Confirmed.") — the scoping and AL-49's application both carry his word.
- **CITES** AI-25 · AL-13 blank 2 · AL-7 · `interface/remote.md` (the 16px reason) · AI-24 (the structure).
- **LANDED IN** this entry; the grammar's scoping travels to the Analyst as RI-76 for the records that cite
  AL-13's grammar.
- **WORD** architect (the scoping, from his cited reasons); Battlewrath (every fact it stands on).

## AL-49 · 2026-08-24 · from inbox AI-24 (UI specialist) — AL-47's application superseded by his surface structure
- ★ **EXTENDED (2026-08-25, AL-56/AL-57):** the WHENs are now four — authoring → the pane · running → the remote · STEERING → with the thing it steers (his ruling, AI-31: the map controller never enters the pane) · PUBLISHING → the export surface (his placement, AI-32: metadata at the moment it leaves). The rule is unchanged; the list grew.
- **QUESTION** none — his words of 2026-08-24, applied: *"Remote is the Run widget. That stays on it's own."*
  · *"Run and Test drive will live tabbed on the remote. (Capture and test route)"* · *"Map as it's own
  pane."* · *"Bolton unified pane, Curation, Promotion, Object."*
- **OUTCOME** the dated part-supersession written at AL-47 (below), exactly as AL-47 wrote one at AL-13:
  the RULE (membership derived, never counted) survives; the APPLICATION over-reached by pushing every
  individual pane into ONE container. His structure derives membership PER SURFACE, grouped by who is using
  it and when: authoring → the unified pane (THREE: Curation · Promotion · Object) · running → the remote
  (TWO tabs: Run capture · Test drive — drive is the remote's second tab, not the pane's fourth) · the map
  its own pane, never docks. AL-7 restated one level up.
- **REASONING** the decisive evidence predated the question and was already on record twice — his decoded
  sketch of 2026-08-18 (three Tab chips on the pane, two on Remote) and `options.lua:10-13`'s prose + three
  built lanes. The specialist named that honestly; the lesson is the standing one: the basis includes what
  the record already carries.
- **CITES** AI-24 · `audit/ui_drawio_model_decoded.xml` · `options.lua:10-13,113-131` · AL-47 · AL-7.
- **LANDED IN** the supersession note at AL-47 · RI-76 (the register corrections that are the Analyst's).
- **WORD** Battlewrath (the structure); UI specialist (the filing and both citations); architect (the note).

## AL-48 · 2026-08-24 · from inbox AI-20 (Addon creator; his words applied at §540/§541) — L21: PER SELECTION
- **QUESTION** does "per selection" become an L-law? Premise put to Battlewrath first, then the draft; his
  "Yes", with a refinement.
- **OUTCOME** **L21 landed on the basis (§5):** an offer is a function of the picked word, never of context —
  every default, ghost value, pre-selection, enablement; tab scoped to itself; enforcement structural
  (`OfferedTrigger(action)`'s one-argument signature + the smoke that asserts a second argument changes
  nothing); the law fixes what is OFFERED, never what is CHOSEN. **Plus his refinement, the first forced
  consequence:** *"Per tab, it's selection of action carries a latch state. Logically sense would have to
  sit below Action if 'Once' 'everytime' is intended to have a natural state."* ⟶ an offer shows only below
  the word that fixes it: the tab's authoring order is action first, latch offer with it, sense below. The
  wire order `sense:action:arg` is untouched — this orders the SURFACE, the same forced-not-chosen shape as
  UL-6's text-before-control.
- **REASONING** the #1 design rule read from the other end: flattening encodes the rule; L21 adds the
  encoding must be LEARNABLE — a context-varying default is not one decision fewer, it is one decision
  replaced by a thing the author has to watch. Predictable beats locally-optimal. Cost stated: a fixed offer
  is sometimes locally wrong (the note on a boss retry); the override is one act. The struck note-argument
  (bench, §540) is the proving instance: the argument was about a NODE, the control belongs to a TAB.
- **CITES** AI-20 (the bench's filing, the guard, the smoke) · `routes.lua` (the struck argument kept as a
  record) · UL-6 (order forced, not chosen) · plays-by-flattening-decisions.
- **LANDED IN** `driver_architecture.md` §5 L21.
- **WORD** Battlewrath (the law's substance and the ordering consequence); Addon creator (the application and
  the guard); architect (the law text).

## AL-47 · 2026-08-24 · from inbox AI-21 (UI specialist) — a dockable group is DERIVED by a rule, never counted
- ⚠ **SUPERSEDED IN PART (2026-08-24, AL-49):** the RULE stands (membership derived, never counted); the APPLICATION over-reached. His structure of 2026-08-24: the unified pane holds THREE (Curation · Promotion · Object); the REMOTE stays its own widget with TWO tabs (Run capture · Test drive) — `drive` folds into the REMOTE, not the pane; the map is its own pane. Membership derives PER SURFACE, grouped by who is using it and when. See AL-49.
- **QUESTION** is a dockable group a LANE (three, as `options.lua` builds) or an INTERFACE SURFACE (four, as
  AL-13 derived)? Where do `remote` and `drive` sit? Concretely: how many tabs does the unified strip hold?
- **OUTCOME** **Battlewrath's definition, his words:** *"Everything that is a individual widget / pane now, is
  a tab in the unified pane. And when it comes out of being a tab, it is a better form of the panes that
  exist today."* ⟶ Membership is DERIVED: any individual pane belongs; docked = a tab; undocked = a BETTER
  FORM of today's pane, never the old window back. Applied to the item's sources (the application is the
  architect's, marked): `curation`·`promotion`·`object` are already tabs · **`drive` is the one individual
  pane in the addon now → owed a fold-in; its 280×206 UIParent window (`drive.lua:396-398`) is the legacy
  form its undocked form supersedes** · `remote` has no code — nothing is a pane before it is built, so it
  is BORN a tab when built · the map stays outside (the native map's overlay; AL-13's exclusion stands).
  **The strip: four today by the model (three built + drive owed), five when remote exists — a MEMBERSHIP,
  never an asserted constant.** A10.1a's "three groups at the root" becomes a membership check and moves
  when drive folds in. The undock mechanic the code comment carries survives whole: the same subtree in two
  containers (`options.lua:10-13`).
- **REASONING** the three enumerations disagreed because each COUNTED a different frozen snapshot; a derived
  membership makes all three readable: the option table holds what has folded in, the folder holds registers
  (built or not), AL-13's four counted registers rather than panes. ⚠ AL-13's count is superseded on that
  point — dated note owed at AL-13 itself (same-turn, below).
- **CITES** `options.lua:113-131,:10-13` · `drive.lua:396-398` · the item's greps (dock ×1, remote ×0) ·
  AL-13.
- **LANDED IN** this entry · a dated supersession note at AL-13. No architecture passage — the unified pane
  is the bench's surface; the model's word here is the definition, and it is recorded.
- **WORD** Battlewrath (the definition); architect (the application to the seven files, marked).

## AL-46 · 2026-08-24 · from inbox AI-23 (UI specialist; his framing) — the Ace3 posture: YES, scoped to the plumbing
- **QUESTION** is the default now "use Ace unless we have a stated reason not to", each remaining custom
  module owing that reason in writing?
- **OUTCOME** **YES — scoped.** For the plumbing (comm · serialisation · DB · lifecycle · events · timers ·
  hooks · console) the default is USE; hand-rolled equivalents owe a written reason and adopt ON TOUCH,
  never as a migration sprint. The default does NOT extend to the layout/offline domain — frame model,
  panespec, coordinate space, driver, route contract — which is the product, not custom code on trial.
  Obligations a yes created and the gap already discharged or bounded: AceBucket is REJECTED for the hot
  path on a capability fact (arg1-only, lossy) so the latency measurement is moot; every adoption checks
  the SHIPPED fork copy first (era gate + §580's LibStub load-order fact). AceComm becomes the default for
  route sharing before any of it is written.
- **REASONING** Battlewrath, ruling: *"Our ability to code is not limited. Knowing what form the code needs
  to take to operate in WoW has just been handed to us whole sale."* The framework's advertised purpose is
  the plumbing; we had adopted the widget half and hand-rolled the half Ace is for — the inversion of every
  other embedder on the client. The flip changes what needs justifying, and the residue list keeps the
  product ours.
- **CITES** `audit/ace3_gap_2026-08-24.md` (verdicts, feature survey, era gate) · `audit/ace3_scope_2026-08-24.md`
  (supply against demand) · `prior_art_ace_field_2026-08-21.md` §6a/§6b · §580 (LibStub load order).
- **LANDED IN** `driver_architecture.md` §7 (the posture passage) · this entry.
- **WORD** Battlewrath (the posture and the why); UI specialist (the filing and the residue list); architect
  (the scope cut and the gap).

## AL-45 · 2026-08-23 · from inbox AI-22 (UI specialist) — a cell whose height is MEASURED: yes, one kind, bounded
- **QUESTION** may `Spec` gain a cell kind whose height is measured rather than looked up — a `note` cell that
  owns its row, spans the content column, reports its wrapped height to the row? F·29 on Battlewrath's
  screenshot: `☐ move`, the wrapped description and `Delete` on one y, sized for the checkbox.
- **OUTCOME** **YES.** One kind, and the bound is the specialist's own cost made explicit: (a) a pane that
  declares no measured cell stays a pure function of its spec and every geometry check keeps that guarantee;
  (b) only rows carrying the measured kind take their strings as an input; (c) offline, such a row is
  reported as UL-1 reports text — measured, quantised, MARKED — never asserted exact; in-client the number
  is `GetStringHeight()` after `SetWidth()`. Shape = the WeakAuras idiom the item cites: full-width,
  wrapping, beneath what it explains, owning its row. Nothing past that is ruled (no line cap, no second
  kind) — those are the bench's when an instance asks.
- **REASONING** the law "a row is as tall as its tallest cell" is already about content; it lacked a cell
  whose content could vary. Wrapped height is a function of three facts the renderer holds at draw time —
  string, width, font — so measuring it is L18 (load-bearing ⟹ sourceable), not a dependency a checker
  should fear. The NO path — descriptions budgeted to one line, shortened to fit — drops what the author
  wrote, silently: interpretation, the expensive wrong. The checker cost is real and is paid exactly where
  the kind is used, nowhere else.
- **CITES** `panespec.lua:61,:238-239` · `ui_overhaul_scope.md` (the row law) · `UI_LOG.md` UL-1 (text
  extent measured, quantised) · L18 · `reference/weakauras_idioms.md`.
- **LANDED IN** this entry (a mechanism ruling for the bench; no governing-doc passage changes — the row law
  stands). Battlewrath told in chat the same turn; a best working model, his to overturn.
- **WORD** architect, applying the row law and L18; the bound is the UI specialist's cost, kept.

## AL-44 · 2026-08-23 · conversation + two research passes + one probe — AP-13 parts 3–5 and two audits
- **QUESTION** his: the job axis ("their formed UI is an echo of what the addon is") · cut the bucketing on the
  industry's terms · is a Lua-emulator-rendered-on-Electron smoke harness feasible and useful.
- **OUTCOME** AP-13 (3) job is the third field (his list: information · display · presentation; authoring
  added as ours, marked) · (4) the capture's shape in source vocabulary — bucket (Curtis: inset · stack ·
  inline · gutter · size · type role · surface · border) · tier (reference → system → component) · job · his
  why — YES 2026-08-23 · (5) the harness is FEASIBLE, proven by probe: client font + BLP textures read from
  `locale-enUS.MPQ` with tools already installed; text extent computable offline, approximate until one
  `task_geom` width check. Two audits filed: `audit/prior_art_ui_tooling_2026-08-23.md` (no 3.3.5 headless
  runner exists; wowless draws without text; our linter has no precedent; ElvUI-WotLK Toolkit = the client's
  de-facto token set; tekkub tag 3.3.5 = FrameXML authority) · `audit/prior_art_ui_vocabulary_2026-08-23.md`
  (the terms, each marked established or stretch).
- **REASONING** source vocabulary over ours, the driver's own rule; a name with a why beats a number; the
  harness's whole value is the one number the model could not know, so it is worth exactly the cost of one
  client check. ⚠ The research agent could not fetch Material's own pages; M3 names come from Google's
  secondary docs, consistent with each other — stated in the file.
- **LANDED IN** `ARCHITECT_PROPOSALS.md` AP-13 (3)(4)(5) · two audit files. Not on the driver basis.
- **WORD** Battlewrath (the job axis · yes on the capture · opening the feasibility read); architect (the cut,
  the probe, the verdict).

## AL-43 · 2026-08-23 · conversation — UI as a system: bucketed tokens with their why; capture annotated in DevDump
- **QUESTION** how to give the agents a lead on UI without every question being A:B in the client.
- **OUTCOME** AP-13. Three of the four moves in the sketch he brought (layout abstraction · structural
  linter · evaluator) are already on the bench (AceGUI · `frames.lua` · `draw_geom`/PaneBoard); the gap is the
  TOKEN REGISTRY, and it is derived from a captured census rather than authored cold. His two refinements:
  tokens live in BUCKETS and carry WHY they work; the capture is a `COA_DevDump` widget that takes his note
  at capture time.
- **REASONING** copying style copies answers without questions — the same fault as a name search. A measured
  census with the designer's reason attached is fact + basis, and the registry becomes UI's one reasoning
  element. Client time collapses to the FontString measuring run.
- **LANDED IN** `ARCHITECT_PROPOSALS.md` AP-13. Not on the driver basis — tooling.
- **WORD** Battlewrath (buckets · why · the DevDump widget); architect (the pipeline shape, held).

## AL-42 · 2026-08-22 · conversation (drained 2026-08-23, the trunk stopped) — AP-8..AP-12 and G30's order
- **QUESTION** the evening's thinking with Battlewrath: pulling settled data from other addons · two stores ·
  the sample-lite · where the filter sits · what travels.
- **OUTCOME** drained verbatim into `ARCHITECT_PROPOSALS.md`: AP-8 (recognised neighbours, normalised,
  attributed, shown on selection) · AP-9 (runs per character, parsed-against in global; the one cost named —
  an alt cannot author against the main's runs) · AP-10 (the sample-lite as the run's portable form; the
  debug log never ships) · AP-11 (the filter is at the EMIT; pruning is step two, never a product) · AP-12
  (what travels is agnostic — where the pressure was, never who caused it). ONE thing landed on the basis,
  because it is an ORDER he gave rather than a feature: G30 now reads emit first, prune second.
- **REASONING** his: *"I wasn't comfortable with 'use my addon, now you have to store a 40 MB file because you
  play the game and contribute to the ecosystem.'"* The reader stores kilobytes; the capturer's heavy file is
  their own to discard once parsed. It is emit-don't-interpret at the store level, and AP-6's facts-never-
  judgements applied to what a sample may carry.
- **LANDED IN** `ARCHITECT_PROPOSALS.md` AP-8..12 · architecture §6 G30 (the order only).
- **WORD** Battlewrath (the shapes and the order); architect (the banking).

## AL-41 · 2026-08-22 · conversation — a PROPOSALS bank, kept off the factual basis
- **QUESTION** today's later thinking (the native-map overlay · the fit and floors travelling with the route ·
  opt-in route metadata · floor-transition markers · the tracker as absolute position · pre-population as
  the authoring principle · the editor's functions over the record) — land it, or hold it?
- **OUTCOME** Battlewrath: *"keep these off the factual basis. Proposals / feature enrichment to drain when
  we are stable to do so."* ⟶ `ARCHITECT_PROPOSALS.md`, AP-1..AP-7, governing nothing, cited by nothing that
  builds; status on the entry; drained into the architecture with a log entry when stable, none before the
  proof (§6b) is green.
- **REASONING** the architecture is the factual basis the Analyst reconciles against; enrichment that has not
  earned a row would read as prescription (the fault drill 3 named) and pull the bench off the heading.
- **LANDED IN** `ARCHITECT_PROPOSALS.md` · architecture §7 (one pointer) · the basis (one line, non-governing).
- **WORD** Battlewrath.

## AL-40 · 2026-08-22 · conversation — the heading now: the proof
- **QUESTION** Battlewrath: "we need to prove that the instruction / table of a Route is enough to drive the
  manager, and that the manager can meaningfully use the sensor to determine and schedule."
- **OUTCOME** written as architecture §6b — four claims with their homes: records → bucket (A12.2d–f, the
  isolation demonstration) · bucket → manager on synthetics (A12.1–A12.9 with the latches, Next, the seed,
  the refusals) · the sensor's schedule is meaningful (throttle · changed set · floor set · W7.2 · the
  poll-floor guarantee) · the client evidence (a named test run in the debug log, AL-25). E-0's wiring is
  off the path by AL-12. First: the build-state emitter must run again.
- **LANDED IN** architecture §6b · the basis NEXT (the Analyst grades; the bench builds per claim).
- **WORD** Battlewrath (the heading); architect (its decomposition).

## AL-39 · 2026-08-22 · conversation — the community input, read against G29/G30
- **QUESTION** Battlewrath shared two Discord threads (`addons/Materials/Addons_Dungeon_run_Community/`) and a
  boon tooltip screenshot as the broadening behind the shipping constraints.
- **OUTCOME** banked as §6 G31 (the broadening, grouped: capture-suite telemetry · authoring asks that touch
  the closed list · route characterisation · confirmations) and G32 (a route's scope under split keys).
  Nothing decided; two flagged for a later word — `percent` as a verb (a completion on a threshold, not a
  place) and the route's scope beside MapID. The screenshot's fact: the boon prefix "Mythical Boon:" is
  capturable by name.
- **REASONING** every ask lands on the capture suite first ("it starts with capturing" — his own line in
  the thread), which is where G29/G30 put the cost; bucket-before-clearing matters more with every sensor.
  The community's rejection of a mini-map is the reader's two panes confirmed from the user side.
- **CITES** the two material files · G29/G30 · AL-36 (many runs per map) · AL-7 (two panes) · AL-31 (say).
- **METHOD (Battlewrath, same day):** capture by CADENCE — combat start registers the unit-died listener
  (name + % per death), combat end unregisters; the buff is read on the 1 Hz sample by whichever API surfaces
  it, position by time, the custom marker making it stand out. Into G31.
- **LANDED IN** architecture §6 G31/G32.
- **WORD** architect, banking; his and the community's input.

## AL-38 · 2026-08-22 · conversation — shipping constraints on Run: runtime impact, storage, compaction
- **QUESTION** Battlewrath: as Run ships, (1) runtime impact — "we'd always flag that a run loads performance,
  but knowing by what degree once the full capture suite is developed" (community engagement is expanding
  the need); (2) storage — a handful of runs is already a few MB; how to prune around direct paths, or at
  least the motion curve/shape, to lighten the stored sample.
- **OUTCOME** banked as §6 G29/G30 (measurements before designs, L19). G29: the suite's listeners are the cost;
  the manager's register/unregister + index-at-load rule reused; the debug log measures frame-time per sensor;
  the flag becomes a measured figure. G30: retention (no loss) → compaction by GPS-track simplification (RDP)
  at a tolerance ≤ the band → never prune the meaning; **his addition: BUCKET BEFORE CLEARING** — events (mob
  deaths, pins, floor swaps) are folded into the segment they happened on before raw samples go. Compaction is
  the USER's explicit, told act on a run — never capture's, never silent (capture's law: never clean, merge or
  dedupe a point). Routes never back-reference runs, so nothing breaks. He will share the community input
  that shows the broadening.
- **CITES** W4.1 (1 Hz) · capture.lua's law · AL-25 (the debug log) · prior_art_isolation §5 (index at load;
  AceDB strips at logout) · routes.lua:11-22 (promotion copies).
- **LANDED IN** architecture §6 G29/G30 · two measurements owed to the bench / the desk.
- **WORD** Battlewrath (the constraints and the bucketing order); architect (the shape, proposed).

## AL-37 · 2026-08-22 · conversation — boot.py gains the analyst and architect lanes
- **QUESTION** AI-2's side-finding A8: two of four seats could not run `py operations/boot.py` as their own
  role. Battlewrath: "No one owns that. So long as it's needed, it can be updated."
- **OUTCOME** two aliases (`analyst` → `addons/planning/ANALYST_LOG.md`, `architect` →
  `addons/planning/ARCHITECT_LOG.md`) and a `lane_path` helper so an alias may carry a repo-relative path;
  the WHY clock now measures from the seat's own log. All three lanes run; the addons lane unchanged.
- **LANDED IN** `operations/boot.py` · architecture §0 (the side-finding closed).
- **WORD** Battlewrath (permission); architect (the edit).

## AL-36 · 2026-08-22 · conversation (walked) — G27: the picker with no run; the surface basis; the no-run condition
- **QUESTION** what feeds the boss / mark picker on a route with no run loaded (RI-60 → G27).
- **OUTCOME** walked from the design basis and met in the middle. Battlewrath: a RUN is the surface basis
  (no geometry exposed; XY truth ≠ Z truth in layered dungeons; kill X is bound in all axes); meaning is
  assigned from run data; the load order is run → route → beacon → behaviour; **a route is bound to a MapID,
  not a run — many runs sample for one route**; the no-run condition (cleared data; a wiped store takes runs
  AND routes; import — the EXPECTED case) → **position locked, behaviour editable**; the map gets its own
  known-map picker, **run and route always win**; and the boundary: all of this is the CUSTOM MAP construct in
  Dungeon Run — Dungeon Routes may use the NATIVE map in lite terms for addon-conflict safety, its content
  already reduced to actionables. ⟶ G27 CLOSED: picker source = every run on the MapID ∪ the route's own NAMES
  table; a new name with no run is TOLD; nothing typed ever enters.
- **REASONING** his basis widened the architect's draft ("the loaded run" → every run on the map) and the
  import case forced the lock/edit split; the product boundary keeps Routes from inheriting the editor's map.
- **CITES** RI-60 · A3.1 (the picker fed from the run) · RI-4 (import re-mints) · §4c · AL-31 (no free text).
- **LANDED IN** architecture §4c′ (new) · §6 G27 · the bench: the picker's two sources; the lock; the known-map
  picker · the Analyst: rows for the no-run condition and the picker's sources.
- **WORD** Battlewrath.

## AL-35 · 2026-08-22 · conversation — the node-level latch is AUTHORED; per-tab defaults are OFFERED, flip-able
- **QUESTION** (AL-29's flagged read) is the node-level latch derived from the tabs, never surfaced?
- **OUTCOME** Battlewrath: *"I'd lean in authored. They have different use cases."* Per tab — boss: Every time
  WANTED (you can safely wipe and retry), Once unwanted; say "/p LoS!": Once WANTED (no running across making
  the character speak; in a wipe that is the last instruction carried to the group, the play fresh in memory),
  Every time unwanted. *"Why not derive from boss action? Questionable. But that hides the setters, which is
  not programmatic. We can flip and offer, WeakAuras-like."* ⟶ BOTH latches AUTHORED; each action word carries
  an OFFERED DEFAULT (boss → Every time · say → Once · note → the bench proposes, the author flips); the
  node-level control stays and is owed. The architect's derived read is STRUCK; the code's authored branch
  (`bucket.lua` reading `Routes.TriggerOf`) was right.
- **REASONING** his: a hidden setter is a derivation the author cannot see or overturn; an offered default is
  the same convenience with the setter in view — the WA idiom, and the #1 rule (encode the rule, never add a
  choice) satisfied by the DEFAULT rather than by removing the control.
- **CITES** AL-23 · AL-29 · `bucket.lua` trigger resolve · `routes.lua` TRIGGERS · plays-by-flattening-decisions.
- **LANDED IN** architecture §4d · the bench: per-action offered defaults as a declaration the picker reads ·
  the Analyst: A10.3 rows (the default shown; flipping it is one click; the node control owed).
- **WORD** Battlewrath.

## AL-34 · 2026-08-22 · conversation — DRILL 3: the architecture tested against the governing set and the code
- **QUESTION** Battlewrath: "we have our own doc to test against the governing docs to see what needs updating
  or still stands."
- **OUTCOME** `audit/drill3_architecture_2026-08-22.md`. Nine architecture drifts and ten internal
  contradictions FIXED in #0 the same day (the posed tab's shape — `fn` is never on it; binding is checked at
  arm and resolved at dispatch · Trigger is on the tab AND the node · the cursor is the manager's · Set(N)
  clamps · G16 closed · the LED TO tick exists · `mark` and the constructed `say` said consistently · the
  action list stated as prescription, naming RI-58 as L20's first instance). **The status column is RETIRED**:
  the manager, ledger, escapement, test drive and debug log had all shipped while the cells said ✗ — §7's
  rule applied, counts and dead line cites removed. ⚠ The checker §7 delegates to REFUSES on one bad cite
  (a table the collector cannot see) — bench's. Governing docs BEHIND the log (B1–B9) handed to the Analyst
  and the bench on RI-42; RI-57 drained; two new gaps (G27 the picker with no run loaded — Battlewrath's;
  G28 icon and Place/Unplace — bench to name). Fourteen load-bearing claims verified as standing.
- **REASONING** §7's direction rule, run against the code rather than remembered; the one pattern worth
  the line: five of the last rulings (AL-19/25/30/31/32) had a home ONLY in #0, which carries no mechanics
  by its own law — the handing-down is the fix, not more text here.
- **CITES** the audit file · AL-17..33 · §7.
- **LANDED IN** #0 (marked "drill 3") · RI-42 (the handed-down list) · RI-57 (drained) · §6 G27/G28 · `concepts/next.md`.
- **WORD** architect, measurement.

## AL-33 · 2026-08-22 · inbox AI-16 (Creator) — nothing retires a vocabulary
- **QUESTION** `Routes.ACTIONS = { "supertrack" }` sat live in a shipped pane after the word was retired;
  `DropRetired` sweeps stored FIELDS and has no counterpart for OFFERED lists. Should a retired term be
  mechanically detectable?
- **OUTCOME** **YES — L20: a vocabulary is retired the way a field is.** ONE source of truth per offered
  list, retirement STAMPED on the entry (term · retired-on · by which ruling) rather than the entry deleted
  from one list and left in another; the pane reads the live set from that source; `DropRetired` gains a
  sibling that reports an offered retired word. `Routes.ACTIONS` goes.
- **REASONING** half-formed code invites building on it; a half-retired vocabulary invites AUTHORING on
  it, and an offered word is the one an author touches. The project's discipline for data (removed, not
  parked, with a sweeper) applies one level up. Load-bearing ⟹ sourceable (L18): the list is the source.
- **CITES** AI-16 · RI-58 · `Routes.DropRetired` · AL-19 · L18.
- **LANDED IN** architecture §5 L20 · the bench: the single source + the sweeper · the Analyst: A5.x row
  (an offered retired word reds the checker).
- **WORD** architect.

## AL-32 · 2026-08-22 · inbox AI-13 (Creator, with Battlewrath's refinement) — the floor gate
- **QUESTION** should the sense rule gain a floor test, given the node most likely to need it is the
  doorway, where the label flaps (20% A→B→A in the corpus, at running speed only)? Measured: both ends
  hold `floor`, the bucket's whitelist drops it, nothing reads it. Battlewrath's refinement: *"what floor
  precedes and is next (and current) — a 3-tile listen, more importantly before and current, as the
  sequence to reaching that location will most likely be a 2-pattern match across waypoints."*
- **OUTCOME** **Q1 YES**, as a SET test: a positioned node listens on `{preceding, current, next}`,
  DERIVED at build from the sequence (the bucket knows the order — the same place `ledTo` and `trigger`
  resolve) and riding the characteristic record; the runtime test is membership on two or three
  integers; PERMISSIVE — a sample with no floor falls through (only a missing mapID refuses). **Q2 is
  dissolved** by the set: a flap between adjacent floors is inside it by construction. The wrinkle
  the bench named — no predecessor for zero nodes — resolves the way they suspected: zero nodes
  (step 0 · stage 0) do not floor-gate, so the floor-gated set IS the led-to set (structure, not luck).
  **Q3 answered honestly:** no overlapping-area false fire has been observed; this buys correctness not
  yet needed, at one carried field and a membership test — cheap enough to take on the field's idiom
  (GatherMate2). Plumbing: `floor` joins the bucket's whitelist. The "at speed" flap rate is unmeasured
  (L19: a measurement, the bench's, when a fast transition is in the corpus).
- **REASONING** his set removes at BUILD time a problem the bench's four options patched at runtime;
  a permissive membership test cannot create a silent stall; and the rule stays pure (no sticky state).
- **CITES** AI-13 · RI-57 · `rule.lua:83-104` · `bucket.lua:475-509` (the whitelist) · `routes.lua:69` ·
  `store.lua:187` · driver_neighbours §GatherMate2 · AL-19 (led-to set).
- **LANDED IN** architecture §4b (THE FLOOR SET) · the bench: the field through the bucket, the set
  derivation, the membership test · the Analyst: A11.2 row + fixtures (the flap fixture passes; a
  floor outside the set refuses; nil falls through; zero nodes never gate) · RI-57 drains citing this.
- **WORD** architect, on Battlewrath's refinement.

## AL-31 · 2026-08-22 · conversation — the actor is opt-in; `say` is constructed; no free text meets an executable path
- **QUESTION** AL-30's carried word: a travelling route can make a reader's character speak — opt-in?
- **OUTCOME** Battlewrath: *"Actor is opt in on the user's config. And we might have the say be from
  construction. Type: /p /s /raid /shout against a list of terms and stand-ins. List of terms along the
  axis of co-ordination — 'LoS pull', 'Focus X', 'Danger: Curse X' — where each X is because we have
  enough data collection from a run to offer it. Then the only dangling free text is on the user's own
  notes, and never meets an executable path (bar sitting in Lua and being handled)."* ⟶ (1) the ACTOR is
  OPT-IN in the reader's config; (2) `say`'s arg is CONSTRUCTED from three closed sources — a CHANNEL
  (/p /s /raid /shout) · a TERM from the coordination list · a STAND-IN picked from the run — identifiers
  only, like every other arg; (3) the only free text in the system is the user's notes, data that is
  displayed and never executed.
- **REASONING** "names, never supplies" applied to the last place it leaked: the say arg. A constructed
  line bounds what a stranger's route can make a reader's character say to what the coordination
  vocabulary allows, with names bounded by the run. The note table was already display-only.
- **CITES** AL-30 · AL-17 (the posed tab's arg rule) · RI-18 (identifiers and numbers only) ·
  [[travelling-data-names-never-supplies]].
- **LANDED IN** architecture §3b (the actor row) · §4b (the posed tab's args) · the bench: the term list
  and stand-in picker are declarations; the actor's opt-in; `say → a string` struck from ROW_ARG · the
  Analyst: A-rows (opt-in default off; a typed say refused at build; a term outside the list refused).
- **WORD** Battlewrath.

## AL-30 · 2026-08-22 · inbox AI-18 (Creator, on Battlewrath's proposal) — the ACTOR module
- **QUESTION** Battlewrath: *"an actor module that specifically handles the output — chat and player
  behaviour, such as marking a target by name (raid markers)."* The bench measured: the binder's seam is
  open and its only occupant is the test drive's harness; raid-marker APIs exist on the fork but take a
  UNIT TOKEN, and there is no name→unit lookup — GuardianPlates already solved it with a nameplate
  index; marking is reachable only for what has a plate on screen; permission and range fail SILENTLY.
  Design owes: the closed verb list (`mark`? picked or typed?) · what `say` means · ours or the reader's.
- **OUTCOME** **YES.** The actor is the binder's shipped occupant, the one owner of output, the emit seam
  of AL-27, and his security sentence as a module — a route NAMES a verb from the closed list the actor
  publishes; the actor owns what it does and whether it is permitted. (1) **`mark` joins the list**, its
  arg PICKED from the run's names like `boss` (bounded by what the game named — the arg leak closed by
  construction); the actor resolves name → token through a nameplate index (GuardianPlates' shape, with
  its recorded finding that one name may resolve to two tokens) and **REPORTS when it cannot act** (no
  plate · no permission) to the debug log — never a silent no-op; the permission behaviour on this fork
  is PROBED live, never assumed. (2) **`say` = /say**, the author's channel to the party (his own word for
  the verb); the test-drive twin PRINTS — the rehearsal flag is which actor is loaded, not a switch inside
  one. (3) **Dungeon Routes ships the real actor; Dungeon Run ships the test-drive twin**; the boundary is
  the published verb list + each verb's declared arg type and source — never shared code. ⚠ **ONE WORD
  CARRIED TO BATTLEWRATH:** `say`'s arg is the one free text that reaches the reader's CLIENT — a
  travelling route can make a stranger's character speak in chat. Does the reader's actor require an
  OPT-IN for `say` (per route, or a setting), with `say` otherwise performed as a note?
- **REASONING** three open things close structurally: AI-17's chat conflict stops existing (the manager
  names an act, never a surface); RI-58..60's unmeaning verbs get a home; the security boundary becomes a
  module. "Names, never supplies" — and its own warning that the ARG side leaks — is why `mark`'s arg is
  picked and why `say` needs his word.
- **CITES** AI-18 · AL-17 (the closed list) · AL-25 (the debug log) · AL-27 (one seam) · `COA_GuardianPlates/Core.lua:195`
  · the API census (SetRaidTarget) · [[travelling-data-names-never-supplies]].
- **LANDED IN** architecture §3b (THE ACTOR) · §4b step 4 · the bench: the actor's skeleton, the verb
  declarations (type + source), the nameplate index, the live permission probe · the Analyst: A-rows for
  the actor (report-never-no-op; picked args; the twin prints).
- **WORD** architect on 1–3; Battlewrath's on the `say` opt-in.

## AL-29 · 2026-08-22 · inbox AI-15 (Creator) — the author's vocabulary: chosen · derived · never shown
- **QUESTION** the consumer tier implements thirteen terms (stage · ordinal/step · step 0 · lone · ledTo ·
  trigger ×2 · Next · three sense-words · action · arg · R · band); nothing has asked how many an author
  must hold, and "the spec is the pane" currently names the RUNTIME's spec — the wiring pass would bake
  all thirteen in by default. Which does an author CHOOSE, which are DERIVED, which never surface?
- **OUTCOME** decided in architecture §4d: **CHOSEN per node** — stage slot · step slot or the "no order"
  tick · led to · Next (from the offer, default shown) · reach · band (a slider; the ceiling is a
  measurement the author never sees); **CHOSEN per tab** — sense-word · action · arg · trigger;
  **DERIVED and never shown** — step 0 (it is the tick) · lone · led-to on tray 0 · "nothing follows" ·
  stage:step · the address · the bucket · the manifest · every latch's state. **Six choices per node,
  four per tab, all with defaults; seven terms the pane never names.** ⚠ Architect's read for his word:
  the NODE-LEVEL latch (AL-23's second Once | Every time) is DERIVED — a node stays offered iff any tab
  is Every time — and never surfaces; one control fewer, nothing it could say the tabs don't.
- **REASONING** the #1 design rule (reduce decision load; encode the rule; never add a choice) applied
  to the SUM rather than to each term; the two good patterns already shipped (step 0 as a tick, ledTo
  as a default-on tick) are the shape the rest follows. Cheaper now than after the pane is wired.
- **CITES** AI-15 · §4d · AL-4 (slots) · AL-18 (the seed) · AL-19 (led to) · AL-22/23 (trigger, the
  latch) · AL-21 (no outcome derived) · plays-by-flattening-decisions.
- **LANDED IN** architecture §4d · the Analyst: A10.3's rows read §4d's list; the bench: the wiring pass
  (RI-58..71) targets it.
- **WORD** architect; the node-level latch's derivation awaits Battlewrath.

## AL-28 · 2026-08-22 · inbox AI-14 (Creator) — the taste budget is going to the wrong lane
- **QUESTION** two measured instances: the band's upper limit asked of Battlewrath and answered hedged
  with a physical reason ("~10 yd — floor-above clipping"), i.e. a measurement routed to taste; and a
  six-pixel overlap found by eye and fixed on a board, when `remote.md`'s own outstanding line says the
  content-box check would have caught it the day it was written.
- **OUTCOME** **L19: a hedged answer carrying a physical reason is a SPEC FOR A MEASUREMENT** — the bench
  measures (the band's ceiling is the first: the distance between standable surfaces in the corpus);
  asking him again is the wrong lane. **The content-box check is BUILT on this word** — it is tooling,
  in the programmers' domain, and it buys attention back: the 16/18 margin and the gap of 6 become
  arithmetic the checker holds, so his taste goes to what a surface SAYS.
- **REASONING** the R floor (derived, nobody asked him) and the R ceiling (a judgement, correctly his)
  show the two lanes working; the band's ceiling was the one routed wrong, and the tell is the hedge
  plus the reason. Per pane, the unchecked content box costs a deploy, a screenshot and a board session.
- **CITES** AI-14 · `remote.md`'s ☐ · §144/§145 · AL-26 (load-bearing ⟹ sourceable).
- **LANDED IN** architecture §5 L19 · the bench: the content-box check; the band-ceiling measurement ·
  RI-56 (the band's ceiling) reads L19.
- **WORD** architect (tooling); the rule from his own pattern.

## AL-27 · 2026-08-22 · inbox AI-17 (Creator) — A10.8c and the manager disagree, and the code does not say so
- **QUESTION** A10.8c rules the manager EMITS, never in chat; `manager.lua` has six `say()` sites landing in
  chat because no reader's pane exists yet (A10.8 is written ahead). Mark it in code, or accept the
  brief's framing as enough?
- **OUTCOME** **Mark it — and collapse the six into ONE emit seam** at the same cost, the seam's comment
  citing A10.8c ("borrowed: chat until the note pane exists"). A builder then meets one door, not six
  chat calls with no note. Which module OWNS the seam is AI-18's question (the actor module); this
  resolves only that there is one.
- **REASONING** the project's standing complaint is a doc that reads as description when it is
  prescription; a ruling's reach belongs where the builder will meet it. Six sites with one note each
  is six copies of the note; one seam is one.
- **CITES** AI-17 · A10.8c · AL-7 (the two panes) · AI-18.
- **LANDED IN** the bench: the seam + its comment · the Analyst: A10.8c's row cites the seam.
- **WORD** architect.

## AL-26 · 2026-08-22 · inbox AI-19 (Analyst) — load-bearing ⟹ sourceable: a derived literal, and concept homes
- **QUESTION** from the reconcile seat: (1) `Routes.R_FLOOR = 5` is arithmetic (`MAX_CLOSING_SPEED ×
  POLL_MIN / 2`) stored as a literal in another file from its inputs — change either and the floor
  silently stops being one, and the literal reads like taste; expressed or stored? (2) no document is
  a concept's home — `Next` is 36 mentions across six briefs organised by SEAT, and three of its seven
  rounds were spent re-establishing what the records jointly said; a home, or keep paying the
  reconcile per concept?
- **OUTCOME** **Battlewrath ruled both the same day, one law: LOAD-BEARING ⟹ SOURCEABLE** — *"a home is
  better than a run-time cost, as it's greppable and inspectable. Same with a derived: settled pairing.
  Inventiveness is useful in the macro / prose, but when something is load bearing it earns being
  sourceable."* ⟶ now **L18**. (1) The LITERAL STAYS (greppable; no load-order cost); the PAIRING is
  ASSERTED at test time — `assert(Sensor.MAX_CLOSING_SPEED * Sensor.POLL_MIN / 2 == Routes.R_FLOOR)` —
  the one line the bench adds; the same read for any other derived-and-stored number (`BAND_DEFAULT`
  is not one — a judgement, correctly a literal with its reason). (2) CONCEPT HOMES are built:
  `concepts/<concept>.md`, one short page — what it is, its closed list, pointers to every document
  that rules or grades it; an index, never a copy. The architect wrote the template and the first,
  `concepts/next.md`; `trigger` · `arg` · `r-and-band` are the Analyst's next, from the reconcile seat.
  Checkable: a home names every document the vocabulary appears in.
- **REASONING** his: the premise we have worked the client on — read the fork, cite the file, never
  recall — turned inward on our own records. A runtime expression is LESS inspectable than a literal
  with an assertion; a home that points is the same shape as `DRIVER_BASIS.md`, which indexes thirteen
  documents and has never competed with them.
- **CITES** AI-19 · `routes.lua` R_FLOOR · `smoke_dungeonrunroutes.lua` · ROW_ARG_RULE ("a copy drifts, a
  read cannot") · RI-72 · `emit_divergence`.
- **LANDED IN** architecture §5 L18 · §7 (homes) · `concepts/next.md` · the bench: the assertion · the
  Analyst: three homes.
- **WORD** Battlewrath.

## AL-25 · 2026-08-22 · inbox AI-11 (Creator) — how a client-only seam is accepted
- **QUESTION** the tracker adapter (ten lines handing the manager's seam to `SetSuperTrackedPosition`)
  cannot be proven on synthetic rows; is a thin adapter accepted by a named deploy-and-look, or must
  it stay unbuilt until a harness can prove it?
- **OUTCOME** Battlewrath, by method rather than by yes/no: **(1) compare what has worked** — COA_DevDump's
  chain test advanced per arrival at a location in the client, so "timing plus non-hard-coded
  instructions reaching the game" has a shipped precedent the adapter is measured against; **(2) an
  IN-GAME DEBUG LOG, its own module** — *"so the project isn't built as a test suite"* — that logs and
  captures background behaviour as it runs: *"I test a route, it captures what differed, when not
  noisy — sensor as buckets instead of per second, but shows its throttle."* ⟶ A client-only seam is
  accepted by the LOG OF A NAMED TEST RUN showing the adapter did what the manager decided — a record,
  not a look. The thin adapter is built (no branching; `capture.lua`'s guard and `pcall`); the smoke
  proves everything up to the door; the log proves the door.
- **REASONING** AL-21 already required the manager to emit its derived decisions in its own record for
  auditability; the debug log is that record's home in the client. Buckets, not per-second lines, is
  the same discipline as the readout (A11.5: never diagnostics in flight) — the log is for the tester,
  off the reader's screen. Capability makes inspection cheap: a look-back becomes an audit.
- **CITES** AI-11 · AL-12 (prove on synthetics) · AL-21 (the manager's record) · A11.5 · COA_DevDump.
- **LANDED IN** architecture §3c (new part: the DEBUG LOG) · §7 (the acceptance rule for client-only
  seams) · the Analyst: an acceptance shape "verified by the log of run ⟨name⟩, by Battlewrath, date" ·
  the bench: the module, the adapter, the manager's emit.
- **WORD** Battlewrath.

## AL-24 · 2026-08-22 · inbox AI-10 (Creator) — can an ordinalled node complete without advancing?
- **QUESTION** the no-outcome derivation (AL-21 addendum) has one shape it cannot express: an ordinalled
  node that completes but must not advance. Is there a route that wants it? The bench could construct
  none and filed UNKNOWN rather than NO, having been wrong once this week about a zero node's powers.
- **OUTCOME** **NO — by definition, not by failure of imagination.** An ordinal is a position in a sequence;
  completing a position IS the hand-off — the constant lives in the ordinal input (R7, AL-13: the node's
  constant on completion is the step). "Completes but must not advance" asks a step to be in the sequence
  and not in it. Every candidate collapses: *wait here until X* = a step whose tabs complete at X, then
  it advances; *do something here without moving the sequence* = a zero node in the same stage (the
  tray exists for it); *finish here without finishing the stage* = a last step whose tabs include what
  the stage waits for. ⟶ A node that should complete without moving the sequence is not in the
  sequence: give it no ordinal. The derivation is total; `Next` keeps three types; §479 stands.
- **REASONING** the rule falls out of R8 ("a stage is a beacon; a beacon with children becomes a stage
  with steps — get you into the room, then guide you through it"): a step that does not guide onward
  is not a step. The one line worth keeping is so the next reader does not re-find the "hole".
- **CITES** AI-10 · AL-13 (the constant lives in the ordinal) · R7 · R8 · AL-21 addendum · §479.
- **LANDED IN** architecture §4b (one sentence beside the no-outcome rule) · the Analyst: a line in A12
  closing the gap as not-a-gap.
- **WORD** architect, applying R7/R8/AL-13.

## AL-23 · 2026-08-22 · conversation — the latch: per action row, released by the sense, re-armed by Trigger
- **QUESTION** (the two words AL-22 left standing) does a completed node's Next re-fire; does Set regress.
- **OUTCOME** Battlewrath: *"Yes. It's a latch. So it has to complete before it is released and can be
  re-armed. And a sensible follow-on is each action needs its own latch. A boss room isn't one chance to
  kill it or our system breaks. At the same time we don't want to spam LoS every time you run over it."*
  ⚠ Then corrected by him the same turn: release-on-sense alone repeats LoS on every run-past while the node
  is still listed (repeated wipes). ⟶ and corrected once more ("that flattened my meaning — choice, per tab, on its latch type"): TWO
  LATCHES, each with the authored choice Once | Every time — PER TAB (Once = fires once, spent until the
  node re-arms; Every time = released on sense drop) and PER STEP/STAGE (Once = leaves the offered list on
  completion; Every time = maintained). A row latches on completion; the boss row never latches on a wipe,
  so it re-arms on re-entry. NEXT is a latch one
  level up — once per arming, released only by re-arming — and **`Set(N)` = max(current, N)**, never
  regressing (his "yes"). Node completion = every row latched at least once; the ledger keeps first
  latches for the arming.
- **REASONING** one mechanism gives both cases: the latch-while-held stops the spam; the release-on-drop
  gives the boss its second chance; Trigger decides only the re-arm. "Every time" means every
  QUALIFICATION, never every poll — the latch is what makes that true.
- **CITES** AL-22 · AL-18 (every armed row carries its escapement) · A2.7 · the ratchet (S6; "can't regress").
- **LANDED IN** architecture §4b · the Analyst: A12 rows (per-row latch · release · re-arm · Set max) ·
  the bench: the ledger as per-row latches; `Set` clamps.
- **WORD** Battlewrath.

## AL-22 · 2026-08-22 · inbox AI-12 (Creator, from Battlewrath's correction) — Trigger, ruled on what it does
- **QUESTION** A12.4b marked `Trigger` RULED on a quotation that was about `Next`'s opt-out. The bench
  reframed on his words ("repeat is a function of the manager to re-state or not"; "one time COMPLETE,
  not one time sense") and flattened to: does a completed node re-run its Next when it re-qualifies?
  The architect took it slowly at his ask and decomposed "repeat" into completion · consequence (Next)
  · re-statement (the action), proposing re-statement as a property of the action word.
- **OUTCOME** **Battlewrath ruled Trigger on what it DOES, and as the author's choice per node — not per
  action:** *"Once or every time. That means the manager will send it to the sensor once, to be complete,
  or maintain it in the list. If say is repeated or not is author choice — Stage 0 · sense within ·
  action /say · arg 'LoS!' · trigger every time · Next: none."* ⟶ ONCE = offered once, completes, leaves
  the offered list; EVERY TIME = maintained in the list after completion, re-stating on every
  re-qualification. Completion is once per arming (the ledger). The sensor stays blind; "spent" is the
  manager's meaning. A12.4b is rewritten with the right attribution and date. The architect's per-action
  read is WITHDRAWN (superseded by his word). Standing beside it, the architect's rule until overturned:
  a completed node's Next fires once per arming whatever its Trigger. STILL HIS: whether `Set(N)` can
  regress, or is max(current, N) — the ratchet's "can't regress" applied to recovery.
- **REASONING** his: base the word on what it does. It keeps the field on the node (the contract already
  declares it), gives the manager one rule over the offered list, needs no new vocabulary, and keeps
  the sensor from learning meaning. The per-action read would have taken a choice from the author that
  his own example shows the author making.
- **CITES** AI-12 · §484/§485 · A12.4b · A2.7 · AL-18's frame · AL-21's no-outcome landing.
- **LANDED IN** architecture §4b (Trigger, in the order of effects) · the Analyst: A12.4b rewritten —
  ruled 2026-08-22, meaning as above, code term the bench's; A12 rows for the offered-list rule and
  once-per-arming completion · the bench: `armCurrent` filters the offered list by Trigger + ledger.
- **WORD** Battlewrath on Trigger; architect on Next-once (standing); Set-regress open, his.

## AL-21 · 2026-08-21 · inbox AI-9 (Analyst, closing RI-49) — `Next` is a field the store owes; what `role` is
- **QUESTION** RI-49 had four readings and no measurement. Now measured: `contract.lua` DECLARES
  `nextType`/`nextArg` on the characteristic record; `routes.lua` has neither (it has `ROLES =
  {start, update, complete, set}`, `child.role`, `child.setStage`); `bucket.lua` carries neither;
  `Manager.NodeDone` reads only `lone` and `step`. Proposal: `Next(Type, arg)` is a field the store owes
  and does not have; `role` + `setStage` are not that field under another name — editor-side, and they
  stay. Yes / no?
- **OUTCOME** **YES on the substance** — `Next(Type, arg)` joins the store (the declaration exists), gets
  an authoring door (the Next picker, A2.9: Step · Stage · Set N, the offer following what exists), and
  `NodeDone` gains its one branch; §4b's recovery escapement (`Set N` on the tray) becomes authorable.
  **ONE CORRECTION to the reading:** `role` is not "a separate concern that stays." It is the OLD PANE's
  spelling of what the new model expresses through Next and the ordinal — `complete` = "my Next is
  Stage", `set` + `setStage` = "my Next is Set(N)", `start`/`update` = positions (ordinal 1 / no
  ordinal). It is editor-side and LIVE only because the old pane reads it through `AcceptanceOf`, and
  A10.2a already lists `role` among the controls A10.3 REPLACES. So: it stays until the replacement
  lands, then the store hook MIGRATES it deterministically into Next and the ordinal, told — it is
  never a second vocabulary kept beside the first. The Analyst's own check ("it is read") was right
  to stop the removal; the reason it is read is the reason it is temporary.
- **REASONING** the no-second-copy law: two fields for one fact (`role=complete` and `Next=Stage`) can
  disagree. The Analyst's reading B describes the code today; L17's reading describes where the field
  belongs; both are true, in sequence. `bucket.lua` re-implementing `AcceptanceOf`'s rule instead of
  calling it (one rule, two bodies) is the bench's, as filed.
- **CITES** AI-9 · RI-49 · `contract.lua` CHARACTERISTIC · A2.9 · A10.2a · AL-4 (the picker) · AL-18
  (the tray-0 seed needs an authored Set N).
- **LANDED IN** RI-49 (drained to this) · architecture §4d (Next on the surface; `role` named as the
  replaced spelling) · the bench: `nextType`/`nextArg` in the store, the door, the `NodeDone` branch, the
  migration mapping · the Analyst: A12 rows for Next's three types and the migration.
- **ADDENDUM (Battlewrath asked whether "how does a step-0 child complete without pushing a step"
  showed in this text — it did not; folded now):** RI-49's later half, the bench's landing at his ask
  (§479), is TAKEN as the rule — `Next` ABSENT is NO OUTCOME, the default DERIVED from position (ordinalled
  → Step; zero node → nothing follows; explicit → the instruction); no fourth word, no degenerate Set;
  the manager records the derived decision. ⟶ It CORRECTS AL-18's "tray-0 seed incomplete until Next is
  authored": a zero node's absent Next is never Stage, so an unauthored tray-0 beacon is an updater and
  a recovery beacon is one given Set N. Architecture §4b corrected in place.
- **WORD** architect, applying A2.9 / A10.2a / the no-second-copy law.

## AL-20 · 2026-08-21 · inbox AI-7 (Analyst) — six stale build-state claims in the architect's files
- **QUESTION** nothing but the edit: the sensor row's today/owed split inverted (the owed half is
  built); G18 a stale BLOCKER; G19b citing a header note that no longer exists; G6's "fourteen
  refusals, none for this" (sixteen, one of them this); the basis's "nothing in the manager is built"
  (sixteen functions landed §461); three counts wrong the day they were typed; and the `AddBeacon`
  precondition quoting a source comment that lied (S7 landed beneath it).
- **OUTCOME** all six edited at their cites, each marked "(AI-7, re-measured 2026-08-21)". And the
  Analyst's read taken as the rule for these files: **a governing doc asserts build state only as a
  pointer to the checker that derives it** (`emit_built_state.py`) — the sensor row and the manager
  entry now say so; the three counts were REMOVED, not updated (a count decays the instant it is
  typed); the dead `routes.lua:474` comment is the bench's to remove. (The `ReachOf` "one production
  call site" claim lives in the Analyst's own files, not mine — theirs, already corrected.)
- **REASONING** the audit's own number: zero ghosts on the guarded axis (39/39 `grades` cites
  resolve) against ~31 of ~55 drifted line numbers on the unguarded ones — a guard beat a convention
  on one afternoon. The architecture's §3 status column was always meant to be re-measured at
  boundaries (§7); it is now derived on demand instead.
- **CITES** AI-7 · `audit/staleness_2026-08-21.md` · `sensor.lua` · `bucket.lua` · `manager.lua:1` ·
  `routes.lua:474-491`.
- **LANDED IN** architecture §3b (sensor) · §6 (G6, G18, G19b) · basis #12 and the RI-23 block · §7's
  standing rule.
- **WORD** architect; edits only.

## AL-19 · 2026-08-21 · inbox AI-8 (Creator, from Battlewrath's reading) — `supertrack` is a characteristic
- **QUESTION** Battlewrath: *"Way point can't be a choice via the sense / act / what to act. The super
  tracker is what gets the player TO the sense site. So if it is an option, it lives in the character,
  not behaviour."* The bench measured: a `whenOn:supertrack` row can only fire after the reader has
  arrived where it would have pointed them — incoherent since A2.6 made supertrack name only itself;
  and the manager already writes the entry lure (A12.3c), so two mechanisms did one job. Proposal: a
  node characteristic, a tick, default on. Open: per node, or a route-level default with override?
- **OUTCOME** **YES — and Battlewrath made it the GENERAL RULE, now L17: a capability sits in the layer
  where it has meaning.** `supertrack` leaves the closed action list (it shrinks — the safe direction
  for the security boundary) and becomes the node's **LED TO** tick: on by default; ticking off is the
  author's choice; **tray-0 nodes are UNTICKED and do not surface the choice** (recovery never lures —
  AL-6 from the other side). Per NODE. The "When on / When off to lure them back" argument
  *dissolved* in his words: *"that's to get the player back to a location, which the user can already
  do with re-pin stage. The mechanism is in user control, not keep luring them in."* The §471
  migration branch converts a stored `supertrack` row into the tick; the node takes the arrival seed.
  The action list is boss · note · say · open.
- **REASONING** the architect's framing, which he confirmed as the rule: behaviour is what happens
  when the player is HERE; a thing with meaning before the sense (getting them here) or after it
  (where the route goes next) is character. `set`/`ratchet` fell to it for firing too early (→ Next);
  `supertrack` falls to it for firing too late (→ led to). The seed gets cleaner: "no action" is purely
  reached.
- **CITES** AI-8 · A2.6 · A12.3c · RI-42 · AL-6 · AL-18 · `routes.lua:1267`.
- **LANDED IN** architecture §5 L17 · §4b (the tick, the dissolved argument, the migration) · §4d (LED TO
  in character; action list) · the bench: ROW_ACTIONS loses `supertrack`, the characteristic gains the
  tick, the migration branch, the tray-0 rule · the Analyst: A12/A13 rows (the manager reads the tick at
  entry; tray 0 never lures — already A11.9's) · data model row for the characteristic record.
- **WORD** Battlewrath.

## AL-18 · 2026-08-21 · inbox AI-6 (Analyst) — the seed row: a fourth sense-word? and what its action is
- **QUESTION** a beacon is placed before its behaviour is decided; AL-17 says a runnable node always
  carries a materialised row and an empty node is refused — so the seed must exist and must not stall.
  Q1: add a fourth sense-word meaning *satisfied as soon as the gate opens* as the seed's sense? Q2: what
  is the seeded row's ACTION — S1 "the pair is the unit" (a terminating sense carries no action, read
  from a declaration) or S2 a no-op verb in the closed list? Facing word already Battlewrath's: "Select
  a sense type" — a prompt, not a state.
- **OUTCOME** **Q1 NO.** The seed's sense is `When on` — ARRIVAL — because arrival IS the behaviour of a
  placed node: a stage is *"get you into the room"* (R8). "Nothing to wait for" describes no node we have
  (a lure, a recovery beacon, a skip's landing all wait for the player); a term for it would be an
  invention with no instance, and a placed node that completed the moment its stage opened would be a
  waypoint nobody has to reach. The closed set of three stands. **Q2 — S1's MECHANISM with a plainer
  meaning:** a row's ACTION is OPTIONAL — `When on` with no action means REACHED, and an action is what
  ELSE happens there; the arg guard runs only when an action is present (the same read-a-declaration
  shape as `ROW_ARG.supertrack = nil`, already shipped); no no-op enters the closed capability list. A
  row the author ADDS starts with its sense unset — the prompt — and is INCOMPLETE, told, until picked;
  the seed row is never unset, so the prompt never shows on a freshly placed node. The
  `routes.lua:1308` comment sits between two lists and names neither — the bench's, one blank line.
- **REASONING** the Analyst's argument that self-termination is about WHEN is right; the answer to
  "when" for a placed node is *when the player gets there*, which is a word we have. Adding a member
  to a closed set for a case with no instance is the extension-past-the-evidence shape; making the
  action optional adds no vocabulary and matches the model's own default ("sense: reach here · what I
  do: nothing · Next: Stage"). Everything else in AI-6 stands as filed: the facing word, the owed
  adaptor row, B4/B1/B3 independent.
- **CITES** AI-6 · AL-17 · R8 (a stage is a beacon) · A2.6's default · `bucket.lua:287` (ROW_ARG read) ·
  `routes.lua:1304-1320`.
- **LANDED IN** architecture §4b (THE SEED) · the Analyst: B0's content and B2's guard; an A-row for
  "added row unset = incomplete, told" · the bench: action optional in both doors; the comment re-seated.
- **FRAME (Battlewrath, same day, on reading this):** *"the waiting is the manager with a row that has no
  escapement when no instruction is set."* ⟶ the rule stated from the manager's side, and it is the one
  §4b now carries: every armed row carries its own escapement; the seed's is arrival; a row with no
  instruction has none and is never armed.
- **CHECKED AGAINST THE FRAME (Battlewrath: "does AL-18 solve that tension?") — PARTLY, then completed:**
  (1) added the missing sentence *a row with no action completes the instant its sense fires* — without
  it the seed had no escapement in the ledger's own terms ("a tab completes when its action finishes");
  (2) found the case it did NOT solve: a TRAY-0 seed's default Next (Stage → next present = stage 1)
  would reset a passing reader; so a tray-0 node is INCOMPLETE until its Next is authored (Set N) —
  told, refused at build. Both in §4b.
- **"Does the structure need a hidden escapement — an else, move on?" (Battlewrath) — NO:** a timeout or
  auto-skip is a false advance by construction and hides stalls; the escapements are visible and
  authored (per tab · per stage · the tray's recovery · the remote's correct-when-lost). Added the one
  sentence the question exposed: an Every-time row completes on its first fire; later fires re-run the
  action without touching the ledger. §4b.
- **WORD** architect; Battlewrath's facing word applied, not re-asked; his frame landed as the rule.

## AL-17 · 2026-08-21 · inbox AI-5 (Creator) — the posed payload, defined; the empty node; the arg's type
- **QUESTION** Battlewrath gave the behaviour ("in-bucket replace the flat form with the function-call
  handling, so when stage and step are true and the sense is met, the payload is already posed") and
  declined to let it be built from the giving: *"better is getting it defined upstream so we're not
  designing by flight."* After his own correction (three of five already answered by the data model),
  what remained: the CONVERSION (flat → rows: convert at build, or migrate once?) · the EMPTY NODE
  (refuse, naming it?) · and his SECURITY constraint — *"it could be a window for arbitrary code …
  owned by the user's own addon, not what the authoring addon states is capable"* — measured by the
  bench: the verb side holds (closed list), the arg side does not (untyped payload).
- **OUTCOME** **The posed tab is DEFINED** (architecture §4b): `{ address · gate · sense · fn · arg }`,
  one per behaviour record — the gate composed from the node (AL-10); sense from a closed set; `fn`
  the consuming addon's own callable, resolved through the closed list it publishes, the resolver
  consulted AFTER that check and never instead of it (the bypass the bench found is closed by
  definition); `arg` a typed VALUE, refused by name when not the declared type, the guard READING the
  declaration. Next and Trigger stay the node's; completion stays the ledger's. **The flat form is
  MIGRATED ONCE** by the store's hook, told — never converted at build — because `child.rows` IS the
  instruction set and the pane moves onto it at L1.4 (so L1.2/L1.4 is a migration). **The empty node
  is REFUSED at build, by name — YES, today**: it can never complete and stalls in silence, the exact
  class row 24 exists to prevent; defaults are materialised as real rows at authoring time so a
  runnable node always has one.
- **REASONING** his security line is the boundary the model already carried as an implementation
  note ("functions it already has") — written now as the rule: *travelling data NAMES a capability
  from a closed list the consumer publishes; it never supplies what it does.* The verb side was closed;
  the arg side leaked because a typed promise in prose is not a check — so the check reads the
  declaration. Converting at build would keep two authored truths alive (the flat fields and the rows)
  — the second-copy fault; migrating once leaves one. Refusing the empty node costs one line and
  turns a silent stall into a named refusal.
- **CITES** AI-5 (the bench's hostile-route measurement) · data model A1.1/A1.2/A1.4a · RI-42 · A12.2c ·
  `bucket.lua:44` seam note · `manager.lua:276` · L3 · row 24.
- **LANDED IN** architecture §4b (the definition) · the bench: `Bucket.Build` gains the empty-node
  refusal and the arg-type guard; `known()` checks the closed list before the resolver; the store hook
  migrates flat → rows · the Analyst: A12 rows for the posed tab (fields, refusals, the closed-list
  order) and RI-49's `Next` as a build question. Memory: [[travelling-data-names-never-supplies]].
- **WORD** architect on the definition and the conversion; Battlewrath's on security and "define
  upstream"; the empty-node guard is a guard, taken.

## AL-16 · 2026-08-21 · conversation — the field's Ace3 idioms, a census of every launcher addon
- **QUESTION** Battlewrath: "how do people use Ace, and how can we."
- **OUTCOME** `audit/prior_art_ace_field_2026-08-21.md` (230 addons; counts re-runnable; cited) → §4f.
  Headlines: tabs-as-data is the common tongue; TSM built our structure (strip + per-tab builder + one
  layout pass + auto-height + a selection path + a theme registry); fold = hide-and-announce or an
  accordion whose row owns its height; "add another" = `args[key]` + `NotifyChange`; dock/undock is NOT a
  convention (reparent + restore suppressed chrome + sentinel, raw frames); two-level visibility is the
  collapsed strip; position = a status table, not LibWindow. Two build facts: **AceGUI 41 will be the live
  copy** (AI_VoiceOver serves it; r960 is the floor) and **ScrollFrame is missing** from our widget set.
  One read, the architect's, for the bench to take unless Battlewrath objects: **adopt AceDB for UI state**
  (fold · selection · dock · geometry) — every other Ace3 embedder on the client does, and "reference what
  is proven" says so; adopting later costs more than now.
- **REASONING** L16 / AL-11: reference what is proven, invent no handling where it buys little. Where the
  field has a convention (tabs as data, NotifyChange, status tables, AceDB) we take it; where it has none
  (dock/undock) the client's own map-with-panel (AL-15) is the reference and we are knowingly inventing.
- **LANDED IN** §4f · the audit · RI-42 (bench: ScrollFrame; AceGUI 41 floor; AceDB read).
- **WORD** architect, measurement. **AceDB for UI state: Battlewrath, same day — "Sure. Go for it. We're
  still learning how to use Ace."** ⟶ a ruling, with its reason: take the field's convention while we learn.

## AL-15 · 2026-08-21 · conversation — the client's own map-with-panel, measured as prior art for A10.9
- **QUESTION** Battlewrath: the default game has this shape (map vs map with quests). What does it do,
  and what transfers?
- **OUTCOME** `audit/prior_art_worldmap_2026-08-21.md` — the fork's `WorldMapFrame` measured from the
  extracted FrameXML. Nine idioms transfer (ruler frame · bolt-on by one anchor, never re-anchored ·
  one number = mode = scale · presence derived from content, persist only the chosen axis · proxy
  frame for undocked position · ID-based selection · texture set per mode) and two are named as
  anti-patterns (hand-listed Show/Hide ×4; two owners of one widget). Folded into `driver_architecture.md`
  §4e; A10.9's rows cite it (Analyst).
- **REASONING** the client's convention is the one users already know; where it is derived-state it
  matches A10.9 exactly, and where it is imperative it shows precisely why A10.9 insists on derivation.
- **LANDED IN** §4e · the audit file · A10.9 (Analyst cites).
- **WORD** architect, measurement.

## AL-14 · 2026-08-21 · inbox AI-4 (Creator) — the record/surface join, and `trigger`'s control
- **QUESTION** the join of `contract.lua`'s fields against `interface/object.md`'s 37 controls: 9
  stored-and-surfaced · 4 stored-not-surfaced (`trigger`; position, deliberately map-side) · 5
  surfaced-not-stored (`role · shape · match · unseen · answers`) — 14 of 37 controls carry no record
  field. Does `trigger` get its control in the A10.3 pass?
- **OUTCOME** **YES — in the A10.3 pass, with the node's other fields, never separately.** It is a
  NODE field (`contract.lua:87-90`); its user label is already ruled (*Trigger*: One time · Every time,
  adaptor row); its CODE TERM is the bench's the day it lands (the adaptor row reserves it). And the
  join is TAKEN AS THE INVENTORY'S INPUT: the authoring surface is nine fields, one owed control, and
  position on the map — the 14 no-record controls are the "different levels of completeness" made
  countable, and A10.2a's "replaced, not folded" now has its mechanical reason (they are not in the
  record). The emitting tool stays NEGATIVE as Battlewrath ruled.
- **REASONING** his frame: *what we store as functions · what we need to surface · to get to what we
  have today* — the pane is DERIVED from the record and the authoring need. A design instinct and a
  mechanical fact arriving at one answer independently is the strongest corroboration the project
  gets. The surface this implies is written as `driver_architecture.md` §4d.
- **CITES** AI-4 · `contract.lua` CHARACTERISTIC/BEHAVIOUR · A10.2a · A10.3 · adaptor `Trigger` row.
- **LANDED IN** `driver_architecture.md` §3a (node editor row: the numbers) · §4d THE AUTHORING SURFACE
  (new) · A10.3 (Analyst adds `trigger` to the node fields).
- **WORD** architect, applying rules on record.

## AL-13 · 2026-08-21 · inbox AI-3 (Creator) — dock / undock is NOW; four blanks
- ⚠ **SUPERSEDED IN PART (2026-08-24, AL-47):** the "four dockable groups" here counted REGISTERS, not panes. Membership is now DERIVED (Battlewrath): every individual pane is a tab; undocked = a better form of today's pane. See AL-47.
- **QUESTION** A10.9 rules the behaviour (every visibility DERIVED from one piece of state per group);
  unstated: what a GROUP is · how an undocked group RETURNS · where dock state LIVES · the undocked
  TEMPLATES.
- **OUTCOME**
  **Blank 1 — a group is one interface surface, YES, with the map excluded:** the six interface files
  are the only enumeration that exists and `check_interface` already reconciles them 1:1; Battlewrath's
  structure makes *the map and its controls ONE surface* that never docks — so the dockable groups are
  the other four (remote · curation · promotion · object), and a LANE is a GROUP (A10.1a's three lanes
  were the first three of them; the remote is the fourth). `Spec` declarations for the three undeclared
  groups are owed AS EACH PANE FOLDS (one pane at a time), not all at once.
  **Blank 3 — account-wide, beside the other UI preferences, YES:** dock state is a preference about the
  tool, not about a route; RI-24's law (nothing about the author's setup travels) decides it, and a
  route-scoped state would travel on export. One field.
  **Blank 4 — a re-ARRANGEMENT of the same declaration, YES:** one declaration per group, two
  arrangements (docked column · undocked window). A10.9f's parity law then holds BY CONSTRUCTION —
  same cells, same get/set, same adaptor labels — and its parity mutation becomes structurally
  impossible rather than graded. Two declarations would be the second copy that can disagree.
  **Blank 2 — ANSWERED BY BATTLEWRATH, same day:** *"A strip that shows as 'collapsed' — a different
  pane that gives a DOCK-ALL restore path, in the same texture grammar as the bolt-on had, so same
  styling. And each undocked item gets a PER-TAB return path, occupying the same band space the tabs
  lived on, so it's one language. A drawer behaviour in illusion is how I mean the collapse strip."*
  ⟶ TWO return paths, ONE language: the strip (dock all) and the per-tab band on each undocked window
  (dock this). The container never disappears; nothing is one-way. A10.9d's "maybe" is now a ruling.
- **REASONING** blanks 1/3/4 are decided by rules already on record (the existing enumeration; RI-24;
  one-declaration-two-arrangements = the no-second-copy law) — no product behaviour invented. Blank 2
  is product taste (what the author sees when everything is undocked) and the record names it his.
- **CITES** A10.9a–f · A10.1a · RI-24 · `panespec.lua` `Spec.SUBJECTS` · `check_interface` ·
  Battlewrath's structure quote (A10.9 head).
- **LANDED IN** A10.9 (Analyst adds: group = interface surface minus the map; state account-wide; one
  declaration two arrangements) · `driver_architecture.md` §3a (Primary frame row) · blank 2 → his word.
- **WORD** architect for 1/3/4; Battlewrath for 2 (answered 2026-08-21).

## AL-12 · 2026-08-21 · RI-44 — the development order's pace, and the sequence note that governs it
- **QUESTION** both chains now, the live defect today, the engine proven on synthetic rows first —
  yes / no?
- **OUTCOME** **Yes — with one sequence note that outranks the pacing:** *"There is a tension between
  what we handle and what can be handled. Push the editor to richness before worrying about export and
  Dungeon Routes. The bench can synthetic as it needs to prove rather than A/B client testing. Dungeon
  Routes earns everything Dungeon Run proves — not that Dungeon Run cannot test drive; it is that
  deciding how we present information assumes the information is structured enough to reach them."*
  ⟶ Chain 1 (the author's side) LEADS; Chain 2 runs as far as PROVING needs, on synthetic rows; Chain 3
  (the reader's screen) waits until the information is structured enough to reach it.
- **REASONING** his: presentation decisions made before the structure exists are decisions about
  information that cannot yet arrive. Proof on synthetics is cheaper and truer than A/B in the client
  and needs no deployment; the consumer inherits what the producer has proven rather than proving it
  twice. The architect's pacing stands inside that frame: the defect today; the engine's small items
  (sample · refusals · previous in-set) as proof, not as a product.
- **LANDED IN** RI-44 (drained) · `driver_architecture.md` §7 (the build principle).
- **WORD** Battlewrath.

## AL-11 · 2026-08-21 · conversation — where care goes: the hot path, and "reference what is proven"
- **QUESTION** (implicit, after the prior-art check) how much handling to design around the
  arm / re-arm swap versus the sensor's dispatch.
- **OUTCOME** Battlewrath: *"I trust your input. I am not the expert and we're referencing what is
  proven. We don't need to invent a handling where it buys us little. The sensor and action patch is
  the hot one. The stage steps has travel time between."* → **L16**: the hot path is sensor → action;
  a stage or step change has travel time on either side, so the swap is a rebuild by eviction (the
  field's shape) and is never optimised; A6's wording and F2's sequencing stand on the architect's word.
- **REASONING** cost follows cadence: the sensor polls at 0.1 s on approach and dispatch must follow
  the transition the same tick; a stage change is separated from the next by seconds of walking, so
  rebuilding the whole manifest there is free in effect and simplest in fact (WA rebuilds its load
  index by eviction; AceDB consumers rebuild on a profile switch — prior art §5).
- **LANDED IN** `driver_architecture.md` §5 L16 (home §4b · A11.4 · the manager's acceptance).
- **WORD** Battlewrath.

## AL-10 · 2026-08-21 · F1 (from the AI-2 audit) — R2 vs RI-23: does the behaviour record carry the gate?
- **QUESTION** R2 (21st): every record opens with the gate. RI-23 (19th): node fields appear once.
  The behaviour record today carries no stage/step.
- **OUTCOME** **Battlewrath: the IDENTITY / BEHAVIOUR claim stands — the behaviour record carries the
  ADDRESS only, stage and step ride the characteristic record once per node, the bucket composes the
  gate per row at build — ON CONDITION THAT THE SEQUENCE IS PROPERLY DEMONSTRATED.** Then *"the
  instruction set becomes the MANIFEST"*: the built tick list is the list of what can be true right
  now, for ONE route on ONE map. RI-23 stands; R2 is satisfied by the manifest, not by repetition.
- **REASONING (his, with the condition's reason)** saved variables load WHOLESALE — no part can be
  loaded into memory; the instruction set exists *"to isolate in run-time what can be true, so that
  many tables with similar-looking data cannot be confused."* So isolation cannot come from loading
  less; it must come from BUILDING FROM ONE RID ONLY, keyed by address. He is "not the expert or the
  programmer" and points at prior art: WeakAuras (many characters · many auras · many load
  conditions · many triggers/events) and the "profile" addons — *"our profile is a route, and it's
  whole."*
- **THE DEMONSTRATION (what "properly" means — the Analyst writes it as A-rows):** (1) two routes on
  one map with lookalike records → the bucket built for RID A contains no record of RID B, by
  address; (2) the gate the bucket composes for each behaviour row equals the prefix its
  characteristic record carries — the same manifest a combined line would have produced, so nothing
  is lost by not repeating; (3) a record whose address resolves to no characteristic is REFUSED at
  build, named — never a silent orphan.
- **PRIOR-ART CHECK — DONE the same day:** `audit/prior_art_isolation_2026-08-21.md`, measured on
  the installed WeakAuras 5.21.2 and AceDB-3.0 with citations. Fourteen shapes transfer (eligibility
  as an index rebuilt by eviction · the active selection a pointer destroyed on switch · consumers
  rebuild · one persisted key · identity by unique key, collisions regenerate · zero footprint unarmed)
  and ONE counter-example to avoid (WA never unregisters its trigger frame — disarm must). ★ The
  answer to his wholesale-load concern: a shared wholesale store isolated by a computed subset is the
  field's normal shape; isolation is the ARM step, not a second file.
- **CITES** R2 · RI-23 · model rows 3–4 · `contract.lua` BEHAVIOUR · data model §6 (SV wholesale) ·
  AL-3 (the tick list is built).
- **LANDED IN** `driver_architecture.md` §2 (the manifest; F1 resolved) · RI-42 (the bench: contract
  unchanged; the Analyst: the three demonstration rows) · `audit/` (the prior-art check, to follow).
- **WORD** Battlewrath, conditional on the demonstration.

## AL-9 · 2026-08-21 · inbox AI-2 (Analyst) — the reconcile audit's 20 corrections to the architecture
- **QUESTION** do I take the 20 corrections (16 architecture, 4 false closures) in
  `audit/reconcile_architecture_2026-08-21.md` myself, so the Analyst proceeds on B and E in parallel?
- **OUTCOME** **YES — all 20 landed in `driver_architecture.md`, each marked "(AI-2 audit, corrected
  2026-08-21)".** The ones that needed judgement: **A6** — "Stage → +1" was a defect in the accepted
  wording: an exposed gap (stages 1,2,5) is legal under L3 and +1 arms a stage that resolves to bucket 0
  alone, stalling the run with only recovery armed; now reads *the next stage PRESENT in the route*
  (architect's correction; Battlewrath may overturn). **C1/G6** — "cannot be authored" was true by
  design and false at both ends in build; marked CLOSED BY DESIGN, OPEN IN BUILD, and **F2 decided: the
  bucket's duplicate-stage refusal (D3, one named line) is SEQUENCED BEFORE the manager (D6)** — the
  window is closed at the cost of one refusal before the part that relies on it exists. **C2/G18** —
  same mark; zero code behind the previous in-set. **C3** — G19 and G3 split into a/b, the unanswered
  halves re-listed. **C4** — the zone ruling was stranded in struck text; it is now law **L15** (the
  MapID is the highest identity of location) with A11.2a as its home for the Analyst to cite. **A8** —
  §0 retitled THE SEATS: duties a thread cites, not self-labels (PROTOCOL §1); `boot.py`'s missing
  `analyst`/`architect` lanes reported to Battlewrath. **A10** — the personal-note PLANE is built
  (store · routes · map layer); only the per-role dimension and the pane are not. **A12/A13** — sensor
  ◐, readout ✗, stated against the code as it is.
- **REASONING** §7's direction rule: where this file disagrees with a mechanics doc or the code, this
  file has drifted. Two fault SHAPES earned rules, now in §7: *closed means built* (designed-but-unbuilt
  is "closed by design, open in build") and *a multi-part gap is struck only when every part has its
  citation*. The audit's own restraint — E-0 reclassified from alarm to sequence position on
  Battlewrath's word — is the model of how a measurement should travel.
- **CITES** the audit file A1–A16, C1–C4, D3, D6, F2 · L3 · model §A1.4a (two gates) · AL-8.
- **LANDED IN** `driver_architecture.md` §0 · §2 · §3a · §3b · §3c · §4 · §4b · §5 L15 · §6 · §7.
- **WORD** architect, on §7's rule; A6's wording and F2's sequencing are the architect's and stand
  until Battlewrath overturns. **F1 is his and is carried to him** (see AL-10 when answered).

## AL-8 · 2026-08-21 · inbox AI-1 (Analyst) — may the Route Manager rely on one-beacon-per-stage before the pickers exist?
- **QUESTION** A10.3e (the pickers) is ✗; three doors (`promoter.lua:530` free-text stageBox ·
  `routes.lua:432` AddBeacon · `routes.lua:1483` SetStage) still accept a duplicate stage; AL-4 says
  duplicates "cannot be authored" and the manager gets one anchor per stage "for free". Is A10.3e a
  PRECONDITION the manager may assume, its acceptance citing A10.3e as the guard?
- **OUTCOME** **YES — and the guarantee has TWO sides, not one.** The picker is the AUTHOR-TIME side
  (tell-and-trust: a swap, never a refusal). The BUCKET is the RUNTIME side, and it exists today:
  `Bucket.Build` already refuses loudly with named reasons; a second anchor at one stage is its next
  named refusal — *"two beacons at stage N — re-slot in the editor"* — never tolerance, never a
  shared cursor. So the manager never meets a duplicate whether or not the pickers have landed; RI-41
  stays dissolved; and the Analyst's window ("unenforced until A10.3e") is enforced at load from the
  day the refusal lands — one line in the bench's existing refusal list, no interim refusal in the
  editor. Routes imported from before the slot meet the same refusal (A2.3's surviving tell at load).
- **REASONING** a direction may be relied on before its author-side enforcer exists when (a) the data
  is measured empty of the case — it is: six stores carry stages, none a duplicate; (b) the enforcer
  is on the build order — A10.3e is; (c) the runtime has its own guard so the assumption cannot be
  broken from outside the editor — the bucket's refusal, which is the law already written for it:
  *bucket may fail and should fail loudly; stage may not.* Tolerating a duplicate at run time (the NO
  branch) would make the tray an authoring convenience and re-open RI-41; refusing at build keeps it
  structural at zero cost.
- **CITES** AL-4 · A2.10 · data model row 24 (bucket refuses loudly) · RI-41 · A2.3 (superseded, tell at
  load survives) · the Analyst's measurement (6/12 stores carry stages, 0 duplicates).
- **LANDED IN** the manager's acceptance (Analyst writes it citing A10.3e as the author-side guard and
  the bucket refusal as the runtime guard) · `Bucket.Build`'s refusal list (bench; one named reason) ·
  A2.10 gains the sentence "the bucket refuses a duplicate stage at load".
- **WORD** architect, applying rules already on record; no word from Battlewrath needed.

## AL-7 · 2026-08-21 · conversation (R10 moment 4) — the reader's two panes
- **QUESTION** what select · arm looks like to the reader (G9).
- **OUTCOME** two panes: the NOTE PANE (stage / step · the note — information and direction; all that
  shows when things go well) and the REMOTE (select · Arm ↔ Stop · correct-when-lost, collapsible to a
  media-player-like corrector).
- **REASONING** Battlewrath: "that lets the flight and the steering be placed separately and not
  control so much of the user's UI. If all is going well they just need information and direction."
  Supersedes his own earlier "one surface" — a flattening of the screen, not a reversal.
- **LANDED IN** `driver_architecture.md` §4c 4 · RI-42 note for A10.5's reader-side counterpart.
- **WORD** Battlewrath.

## AL-6 · 2026-08-21 · conversation (R10) — the reader's first run, moments 1–3, 5–8
- **OUTCOME** receive = the community string into a personal route inventory (an in-game sync channel
  named for later) · see enough to want it · offer by current map · stage 1 loads and lures, recovery
  never uses the supertracker · one fixed display (stage / step · note), emitted never in chat, no
  in-flight diagnostics · own note retired for this heading · end = "Route complete", re-run = leave
  and re-enter.
- **REASONING** his, moment by moment; the test-drive readout is the author's diagnostics, not the
  reader's display; tray-0 items never write the arrow because the reader observes and corrects.
- **LANDED IN** §4c · G10/G11/G12 closed, G14 retired · RI-42 note for A10.5 / A11.5 / A11.9.
- **WORD** Battlewrath.

## AL-5 · 2026-08-21 · conversation (R8) — what Step is scoped to
- **OUTCOME** "A stage is a beacon. A beacon with children becomes a stage with steps." Step = the
  child's position in its stage's sequence, restarting each stage; `stage.step` is the whole address.
- **REASONING** answered by meaning, not mechanics: stage = one intent (into the room · the jump · the
  boss), steps = how it guides you through it. R7's one-beacon-per-slot had already merged the
  beacon-scope and stage-scope readings; this names why.
- **LANDED IN** model §1 · architecture §4 · G7 closed · RI-42 (mirror into `contract.lua`).
- **WORD** Battlewrath.

## AL-4 · 2026-08-21 · conversation (R7) — slots per stage, slots per route
- **OUTCOME** a route is a tray: stage slots hold one beacon each (0 = the open tray), step slots one
  child each; the picker shows what is current plus +1 (next whole / next decimal) or swaps with a
  chosen occupant; no shift, no renumber; duplicates cannot be authored.
- **REASONING** his direction change: conflict resolved AT AUTHOR TIME by the slot beats soft prompts
  in the wild; it dissolves RI-41 / G6 and A2.3 by construction, and the manager's bucket gets one
  anchor per stage for free. Tell-and-trust holds (a swap is told, nothing refused). The architect's
  "displace to the tray" act was dropped — the picker is the whole act.
- **LANDED IN** model §1 SLOTS · A2.10 (A2.3 superseded) · A10.3e · basis line struck · G6 closed.
- **WORD** Battlewrath.

## AL-3 · 2026-08-21 · conversation (R2) — function + arg on the instruction set?
- **OUTCOME** on the BEHAVIOUR record, once per tab; on the gate list, never. The tick list is BUILT at
  load from the records and never exported.
- **REASONING** a tab IS a function and its arg, so they can live nowhere else; every record opens
  with the gate so any record stands alone; a view that travels is a copy that can disagree. R2's
  "per-ID table with tabs laid out for the bucket" is the behaviour records; "the ordered gate list"
  is the bucket. WeakAuras says the same from the other side (authored table per aura, load-time
  index per event); the flight-controller review is kept as a check, not a decision.
- **LANDED IN** architecture §2 · RI-42.
- **WORD** architect's answer to his question; he took it.

## AL-2 · 2026-08-21 · conversation (G1/G2 → R4) — the Route Manager and the order of effects
- **OUTCOME** one stateful owner of an Active Route — the offer and the one selection, current stage
  and step, the ledger, firing Next, the bucket swap, the three tracker writes, listeners, the stage
  line, the terminal state, one saved slot (selected RID, never progress). Order of effects 0–9.
- **REASONING** nothing held `currentStage` and nothing called `Designate`; a completion had no owner;
  the sensor could not be the designator without changing its own input mid-poll (row 26). One owner
  closes G1, G2, G3, G5, G13, G18, G19, G21 at once; reload becomes one overwritten slot with no
  progress saved (zero garbage), and recovery lands the reader after a re-arm.
- **LANDED IN** architecture §3b (new part) · §4b · RI-42 (the runtime tier handed to the bench).
- **WORD** architect's proposal; Battlewrath: "Yes. That matches."

## AL-1 · 2026-08-21 · conversation (R1, R3, R11) — wording and terms
- **OUTCOME** a stage advances when its conditions are met (boss, pull, transition, skip) · a RUN is the
  Run side's capture, an ACTIVE ROUTE is the Routes side's live route · "pre-load" retired for
  ingest → bucket → arm.
- **REASONING** accuracy and self-describing names: "if a word needs a gloss, the gloss is the name."
- **LANDED IN** architecture §1 · §4 · G26 closed.
- **WORD** Battlewrath.
