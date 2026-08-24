# ARCHITECT_PROPOSALS — feature enrichment, OFF the factual basis until we are stable enough to drain it

_Opened 2026-08-22 at Battlewrath's instruction: "I'd keep these off the factual basis. Proposals / feature
enrichment to drain when we are stable to do so." **This file governs nothing and is cited by nothing that
builds.** Each entry is a shape reasoned with him in conversation, held here so it is not lost and not
mistaken for a ruling. An entry LEAVES by draining into `driver_architecture.md` (and from there to the
governing docs) with a log entry, or by being struck. Status is on the entry: `AP-N DRAINED (date, AL-N)`
or `AP-N STRUCK (date, why)`; no stamp = held._

---

## AP-1 · The tracker shows the ABSOLUTE position of the stage or step; trails are the author's
When the next node is on another floor, the supertracker still points at the node's world position; a
route that wants the reader led via the stairs has a STEP at the stairs — authored, not inferred. We surface
it better (AP-4's map line), we never re-target. Battlewrath: *"the tracker shows the absolute position of
the stage / step, and it's on the author to make that a stage or a step trail. We just surface it better."*

## AP-2 · The map↔world FIT and the floors a map expects TRAVEL WITH THE ROUTE
Calibration is captured by the run and the editing suite and shipped as a third side table beside NAMES and
NOTES — per floor, a few numbers, identifiers-and-numbers like everything on the line; repeated across
routes on one map and still light. The addon ships NO calibration of its own (shipping it would make us
maintainers where the addon can be self-serving); a data gap is corrected at authoring. The floor list the
native map expects rides the same way.

## AP-3 · Route METADATA is the route's own character — declared, opt-in, never inferred
Class (any, or a class) · affix · key rank · perhaps expected item level / difficulty. Captured where the run
already knows it (the capturer's class, the key and affix at capture) and widened by the author ("any").
**Owner-owned and opt-in, never mandatory to author.** The reader's OFFER filters on what is present and never
hides a route for lacking a field. Metadata is DECLARED, never inferred by the consumer: a route that says
nothing about class is "any"; the reader's addon does not guess from its own class.

## AP-4 · FLOOR TRANSITION points — same data, derived on editor interaction
A transition is the sample pair where the floor label changed; the editor derives a marker from it (bucket-
before-prune keeps it — a transition is an event of its segment). The reader's overlay draws a LINE on the
current floor to the transition when the next node is on a different floor — somewhere to point to.

## AP-5 · Dungeon Routes rides the NATIVE MAP as an OVERLAY that matches its state and hooks nothing
Our own frame, parented to the map's detail layer, anchored to its rect, scaled by its one mode number; floor
and mode READ from the map's own state; `WORLD_MAP_UPDATE` to redraw. Never a `SetPoint` on a Blizzard frame,
never a hook on a shared function — the two-owners-for-one-widget fault the client itself has. GatherMate /
HandyNotes draw this way and coexist. Content: actionables only (the stage's nodes · the next waypoint · the
arrow's target · AP-4's line). Needs AP-2's fit to project world → map.

## AP-6 · PRE-POPULATION is the authoring principle — facts PLACED, never judgements MADE
Authoring is the half that might bite the product (consumers of a WeakAura pack vastly outnumber its
builders). So the capture suite hands the author CANDIDATES: every boss kill, boon, floor transition, death
site and combat segment already on the map as a marker the author promotes with one act, obvious defaults
filled (the boss node's kill row and recovery Next · the boon's "pick up" note · the transition as a step);
a captured run can offer a DRAFT ROUTE. The author CURATES — selects, trims, adds the note and the
coordination line. The boundary (Battlewrath): the addon's "smart" is EXPRESSION — using the data we have to
make *"beacon goes there with X"* quick to say — never ASSESSMENT (which pull is dangerous, which route is
good, what to build); there is no agent in the game to reason, and a route that reasoned would open decisions
instead of flattening them. The capture can place the health dip; the author writes "use defensives here".

## AP-7 · The editor's FUNCTIONS over the record — readings with their basis, converging as samples pool
The capture never resolves ambiguity; the EDITOR may, as a function over the record: per unit name, the %
seen and the casts seen, with a trend that isolates clear cases by TIME signature and NAME signature (one
name dying alone at one moment is a clean reading; three names in one moment stay flagged until more samples
split them). Each reading shows its basis (L18 — grep the samples it came from); pooled samples converge into
PROFILES. A measurement handed to the author ("this unit is worth about 1.2%"), never an assessment of what
to build. The layering, one floor deeper: the RUN emits facts · the EDITOR's functions derive readings with
their basis · the AUTHOR judges · the ROUTE carries the expression.

---
## AP-8 · Run PULLS SETTLED SEGMENT DATA from neighbours it RECOGNISES — normalised, attributed, shown on selection
Battlewrath: *"letting Run pull from settled segment data from other addons, so we're not pulling heavy on the
hot path … we'd normalise / uniform the data into a usable form for us; then show segment data on selection;
then the authoring on spells cast and the like is from their own capture stream against addons we recognise we
can handle."* Three parts: (1) a CLOSED LIST of recognised sources (Details · Skada · DBM …), declared, optional
— absent source, absent reading, the run still captures what it captures itself; (2) the pull happens on
CADENCE (combat end), never per event, and is NORMALISED into our form re-bucketed on our cadence — their facts
with their timestamps, our segmentation — every reading carrying its PROVENANCE (L18); (3) SHOWN ON SELECTION:
pick a combat segment in the editor and its facts appear (what died, what was cast, the damage shape), so a
note on spells or interrupts draws from THEIR stream rather than ours. Precedent measured: WeakAuras feeds its
encounter load condition exclusively from DBM callbacks. Run-side only — Routes never reads another addon.

## AP-9 · TWO STORES: raw capture PER CHARACTER, everything parsed-against in GLOBAL
Runs → `SavedVariablesPerCharacter` (the heavy file, free to delete per character without touching a route;
login loads only that character's runs; retention gets a natural boundary; a run is already per character in
meaning — the capturer's class, key, affix). Routes · the side tables · the route inventory · UI preferences ·
the selected-RID slot → `SavedVariables` (account-wide). Two rules: (a) anything a route needs is COPIED into
the account store at promotion or export — never read from the character store at runtime (promotion already
copies; AP-2 already ships the fit and floors); (b) the one cost, said out loud: an alt cannot author against
the main's runs — "every run on the MapID" (AL-36) becomes "every run THIS character captured on the MapID".
DR-20 holds with two globals behind one module. Battlewrath's why: *"I wasn't comfortable with 'use my addon,
now you have to store a 40 MB file because you play the game and contribute to the ecosystem.'"* The reader
stores kilobytes; the capturer stores the heavy file on their own character and can throw it away the moment
it has been parsed.

## AP-10 · THE SAMPLE-LITE — a derived, compact run is the run's PORTABLE form; the debug log never ships
The DEBUG LOG is dev-only — an eye into runtime, never shipped (so it stores per character or not durably at
all). The SAMPLE-LITE is a run derived from a character's log — G30's compaction made portable — and is what a
RUN export/import would carry: a projection of the heavy store, identifiers and numbers, bucketed events on
simplified segments, versioned. It MOVES TO GLOBAL: *"the things worth surviving because we've parsed against
them."* Pooling sample-lites across players is what makes profiles possible. A big open area, a new system;
not on the proof's path.

## AP-11 · THE BINDING RULE for AP-9/AP-10 — the filter is at the EMIT; pruning is step two, never a product
*"Raw capture, data-rich, per character — deletable without losing anything that was parsed from it; what was
parsed against and is worth surviving — in global."* So: the FILTER is the emit into global, and that is the
product. Pruning the raw record is a SECOND STEP, separate, later, the user's — whether the heavy file goes at
all is their choice and nothing downstream depends on it. "First emit what is useful. Then if the record goes,
that is step 2." This REORDERS G30: emit first, prune second, prune never a product; compaction becomes a
consequence of the two stores rather than a feature to get right.

## AP-12 · WHAT TRAVELS IS AGNOSTIC — where the pressure was, never what caused it
The heavy combat-log material and the neighbours' normalised streams live per character, where the metrics
are useful to the one who captured them. What moves to global, and what a sample-lite carries, is lighter and
says only WHERE the pressure was on that run — the dip, the death site, the segment that ran long — never WHAT
caused it. Cause is a judgement (healer, tank management, a DPS pulling extra) and it is about people; a shared
sample never carries who was bad. AP-6's rule — facts placed, never judgements made — applied to the store.

## AP-13 · UI AS A SYSTEM — tokens in BUCKETS with their WHY, derived from a CAPTURED census the designer annotates
Opened 2026-08-23 from Battlewrath's framing: *"a topic around UI and how we address it as a work flow / system,
rather than pressure to 'get it done'"* — the pressure exists because UI is treated as a surface to finish;
the answer is to treat it like everything else on the driver: a DECLARATION that renders, passed through the
same gears every pane. ★ The test of every part below (Battlewrath, 2026-08-23): *"should mostly give the
agents a feedback loop rather than working blind and success being tuned by churn."* A part that does not
close a loop — show the agent what it did, against a fact — is not part of this. What the bench already has: AceGUI-3.0 IS the layout abstraction (offline 10/10 since
§539) · `frames.lua` resolves anchors to rects with overlap/overhang/containment checks · `draw_geom.py` draws
a captured geom record · PaneBoard drags real rectangles 1:1. What it lacks is LESSONS: 254 addons in the
client corpus and no way to turn them into constraints — copying their Lua copies the ANSWER (padding 4)
without the QUESTION (why 4), so it cannot generalise. Two rulings, his, 2026-08-23:
(1) **TOKENS, IN BUCKETS, EACH WITH ITS WHY.** *"Tokens. Yes. But buckets. 'Why something works' is an
important part of selection. Our work is putting them together."* The registry is not a flat list of numbers;
a bucket is a role (edge inset · sibling gap · control height · font per role · backdrop · border …) holding
the candidates MEASURED from the corpus, and selection into the registry carries the reason it works. The
registry is the one reasoning element of UI — curated, his taste — and the evaluator judges AGAINST it.
(2) **CAPTURE FIRST, ANNOTATED AT CAPTURE: a COA_DevDump widget.** *"Make a COA devdump tool with a widget.
I can insert a note into what works for me on that capture."* Census runs on client-captured geometry (true)
before addon source (the stub cannot cover every addon's API surface). The capture carries HIS NOTE as a
field — fact and basis travel together (L18), so the why is never reconstructed later from a number.
(3) **THE JOB IS THE THIRD FIELD.** *"Different addons solve different issues. So their formed UI is an echo of
what the addon is. WA is information packed. PFquest is display. Some of the addon quests are fully style and
presentation."* A captured fact carries the measurement · his why · the JOB of the addon it came from (a short
closed list, his to name — information · display · presentation so far). Selection is by job: not the inset
254 addons share, the inset the information-packed ones converge on. Our surfaces already have jobs: the
Dungeon Run editor is INFORMATION (WeakAuras' kin); the Routes overlay and tracker are DISPLAY (pfQuest's kin).
The widget notes ONE fact of ONE control at a time (hover → measured facts → pick → why), so a capture is one
bucket entry with its basis rather than a pane with a dozen unattributed numbers.
(4) **THE CAPTURE'S SHAPE — source vocabulary (Battlewrath, yes, 2026-08-23).** A captured fact carries
**bucket · tier · job · his why**, optionally the M3 category on controls. Bucket names are Nathan Curtis's
(*Space in Design Systems*): **inset** (square · squish · stretch) · **stack** · **inline** · **gutter** · **size**
(captured as its parts: type + padding + border) · **type role** (Carbon productive: heading · body · label ·
helper-text · code) · **surface** · **border** (+ radius). Tier = DTCG/M3 **reference → system → component**
(raw pixels → our bucket names → an addon's value). Job glosses: information-packed = persistent HUD / compact
density; display = contextual HUD / wayfinding (Fagerholt *spatial* for in-world markers); presentation =
theme; AUTHORING has no industry class — ours, marked ours. Basis and the established/stretch marks:
`audit/prior_art_ui_vocabulary_2026-08-23.md`.
(5) **THE SMOKE HARNESS IS FEASIBLE — measured 2026-08-23, opened by Battlewrath for a feasibility read.**
The client's font and Blizzard's textures are readable offline: `Fonts\FRIZQT__.TTF` and `Interface\…\*.blp`
live in `Data/enUS/locale-enUS.MPQ` (+ `patch-enUS-*.MPQ`, later wins; NOT in common/patch-N), read with
`mpyq`, decoded by Pillow's BLP plugin, the font rasterised by Pillow's FreeType — all already installed. At
12px "Dungeon Run" measures 77 px, "When on" 51 px: the FontString extent, the one number the rect model marks
UNMEASURED, is now computable offline. It is an APPROXIMATION until checked once: the client also uses FreeType
but on its own 768-line scale and hinting. The check is `COA_DevDump task_geom` (`GetStringWidth`) on ~10
strings against the offline widths — one run decides "exact" or "±1 px, marked"; either keeps the harness.
Shape: `frames.lua` rect tree → renderer (archive reader · BLP · FreeType) → PNG, or rects + sprites into
PaneBoard's Electron surface (already 1:1). Standing hole, the smoke README's: a Blizzard TEMPLATE is a name to
the stub and draws nothing until its textures are modelled — the corpus census captures exactly that.
Nothing built; probe scripts were scratch. The bench's on the word; the width check runs first.
(6) **WHAT FEEDS THE REGISTRY — the FIELD AT ADMISSION, never a sweep; and the ADMISSION TEST**
(AI-28 → AL-51; REFRAMED on his stop, AI-30 → AL-54; the gate said out loud, AI-29 → AL-55; 2026-08-24).
The register is fed by REPETITION — ours or the field's — and **the field is consulted AT ADMISSION, on a
candidate we already have, never swept up front to generate candidates.** His stop: *"it sounds like
sweeping data that is more likely to distract rather than focus"* — and the record agreed: the field has
only ever CONFIRMED a candidate (collapse, tabs), never proposed one; the one field-only finding
(ScrollFrame) was a targeted question costing one read. `audit/prior_art_ace_field_2026-08-21.md` is the
STANDING ANSWER, extended when a question outruns it. The one class it cannot answer — pixel-space
measurements from captured geometry — names a TARGETED probe's scope when a spacing question actually
arises; no question, no probe. ⚠ The bespoke inventory's "no types" finding stands but implies the bench
is YOUNG, not that the field holds our types — a second instance of our own is worth more than a
stranger's, because it arrives with our why attached.
Admission is the three-way test: **TYPE** (2+ citable instances, ours or the field → registry, settled by
use) · **FEATURE** (1 instance and the field publishes it → a coat; stop hand-building) · **CAPABILITY**
(1 instance and NOTHING publishes it → admissible, MARKED, ours to define — Battlewrath: *"it's a
capability. Just no second use for it yet. And no Ace offers that. So it's a feature? Permissible."*).
Two guards: the ABSENCE must be citable ("AceGUI publishes no range widget" is checkable; "nobody does
this" is the-scope-protected-the-claim), and a capability is marked ONE CALLER permanently — DEFINED, not
OBSERVED. Home: `concepts/type-or-feature.md`.
**THE CURATION GATE, where act 3 will read it (his catch):** *"Land the outcomes into a separate file, not
shunt into registry… Seek improvements rather than replacement."* Any field consultation EMITS a findings
file — OBSERVED, machine-emitted, re-runnable at zero curation cost; the REGISTRY holds SETTLED entries,
hand-curated; **between them HIS curation, never a pipe** (also structural: shared files make no entry's
instances auditable). And the split by what a finding moves: a NUMBER (padding · height · inset) → apply
as an improvement carrying its citation; a MEANING (which hook writes the record; what commit does) →
filed as a CHALLENGE to him, never applied — instance count is not authority over UL-6/UL-15's rulings.
(7) **THE REGISTRY HOLDS UNITS, NOT ONLY TOKENS (AI-26 → AL-52; his words).** *"The registry is our settled
understanding and implementation of UI elements. So that Addon creator doesn't have to re-derive how to
implement UI elements. We've done that work. The functions from Ace on their own are where we wire in. But
how they sit together and how we shape the behaviour is our product."* A token answers HOW FAR APART; a
unit answers WHAT THIS IS AND HOW IT BEHAVES: single unit · grouped unit (controls that travel together) ·
user intent in his words · the recipe. The recipe is a DECLARATION the builder executes (kind · parts ·
spacing · commit · binds BY NAME from the closed list the widget layer publishes) — never pasted source
(the second copy a-stored-field-isn't-live warns of). panespec's own vocabulary, so a selected unit drops
into a pane and the smoke can build it offline. First entries already exist in this shape
(`ui_panespec_borrows_spec.md` §4–§5 · `concepts/input-commit.md`: input+response · slider+value box ·
dropdown).
(8) **A DOORWAY, NOT A MANDATE (AI-27 → AL-53; his ruling).** *"I'd make a door way into the content. But
not harden the registry into a mandate… Dev can impliment and find the edges / limits of the registration.
You can inspect and make it better and consume it as a kind/form/composition."* The registry OFFERS; a pane
that ignores it is not in breach; it grows from USE. The door is `UI_FOR_THE_BENCH.md`, reachable via
`DRIVER_BASIS.md`'s REACHABLE section (a third kind beside GOVERNING and evidence: settled work you build
WITH, offered) — one line, so the basis stays tiny and nothing hardens.
Pipeline shape, held: corpus → capture + note → spatial census (tool) → bucketed token registry (curated) →
declaration (Ace where Ace fits; tokens only, no magic numbers) → offline rects + structural checks →
drawing FROM THE OFFLINE RECTS (one join: draw_geom today reads client captures) → evaluator → ONE client
measuring run for FontStrings. Nothing built. Upstream tools measured: `audit/prior_art_ui_tooling_2026-08-23.md` — no 3.3.5 headless runner exists; wowless draws frames→rects→PNG without text; nobody measures WoW fonts offline; ElvUI-WotLK's Toolkit is the client's de-facto token set; tekkub/wow-ui-source tag 3.3.5 is our FrameXML authority.

_Drain order when stable: AP-2 and AP-5 together (the overlay needs the fit) · AP-1/AP-4 with them · AP-3 with
the offer's filters · AP-6/AP-7/AP-8 with the capture suite (G29–G31) · AP-9/AP-11/AP-12 together (the two stores
and their rule — they reorder G30) · AP-10 last, a new system · AP-13 is TOOLING, drains on its own clock into `operations/ROUTER.md` and the tools, not the driver basis. None before the proof (§6b) is green._
