# Reconcile_inbox — the relay for questions that need a ruling

_Standing channel, opened 2026-08-18 (§325) at Battlewrath's ask. **The bench files items here;
the designer DRAINS them** — rules, reconciles the records against the outcome, and tests the
change against its impact. Kept short on purpose: an inbox that grows is one nobody empties._

## How it works

    THE BENCH FILES     a question it cannot settle alone, with everything needed to settle it -
                        options, costs, what is already built on an assumption, and the bench's
                        own read MARKED AS THE BENCH'S so it can be overturned in one word.
    ★ A TIE BREAK      is a DIFFERENT SHAPE (Battlewrath, §342): "tie break with instruction
                        instead of deliberation." When two governing docs disagree the rule has
                        ALREADY decided which wins - weighing them again is the builder doing
                        the thing the rule forbids. So it states the tie and lists INSTRUCTION
                        LINES to pick from. No bench read.
    THE DESIGNER DRAINS rules it · reconciles every record the ruling touches · checks the
                        IMPACT list below the item and says which parts actually moved.
    THE ITEM LEAVES     to §DRAINED at the foot with a one-line outcome and where it landed.
                        Removed entirely once the records carry it.

⚠ **An item is not a discussion.** If it needs a conversation it belongs in chat first and arrives
here as a question with options. **A row with no options is not ready to be drained.**

★ **Every item carries an IMPACT block**, because *"test against impact"* is the drain's second
half: a ruling that changes nothing on disk and a ruling that invalidates a shipped guard are
different events and should not look the same in an inbox.

⚠ **This file is a CHANNEL, not a governing document.** It directs nothing; it holds questions
until they are answered. `DRIVER_BASIS.md` is the authority and should carry a pointer to this so
nobody mistakes an open question here for a ruling.

---

# OPEN

_**Status lives on the ITEM, never in a header** (bench finding 2026-08-19: two conventions were
live — RI-1..8 inherited "drained" from the section, RI-9.. carried their own stamp — so a hand
header compensated and went stale within a day, on RI-18). **The one convention: an item is DRAINED
when its text begins `RI-N DRAINED (who, date)`; an item without that stamp is OPEN.** Derive,
don't read a list: `grep -n "RI-[0-9]* DRAINED" Reconcile_inbox.md` gives the drained; every other
`## RI-` heading is open; the next number is the highest present + 1. Sections are PLACEMENT only
(open items sit here, drained items move below) — the stamp is the truth if they ever disagree._

---

## RI-19 · THE GOLDEN WATCH — `walk.py check` cannot reach W1 or W5

_Filed 2026-08-19 by **Opus 5 — Design/acceptance setter**. ⚠ This item is mostly MEASURED FACT.
The acceptance rewording under it is mine and TAKEN, not asked; one build-shape choice is the
bench's and carries options. A9.5 named this blocker; what follows is its exact shape._

### What was measured (2026-08-19, read-only, on the tree as it stands)

    py addons/tools/walk.py check     PASS - every W2/W3/W4 golden reproduced
    py addons/tools/walk.py w1        PASS - all ten criteria
    py addons/tools/walk.py w5        W5.4 PASS · W5.6 all three goldens SAME

★ **The goldens have NOT drifted.** `w5_SFK_live` · `w5_SFK_Run4` · `w5_rfc_combat` all read SAME.
The reference the Lua port will be graded against is intact today. This item is not about their
contents.

### The finding — one notch wider than "the goldens are unwatched"

`main()` (`addons/tools/walk.py:1752`) gates by MODE. `w32`, `w5` and `w1` each return early;
`check` then falls through to `w2` / `w3` / `w4` and nothing else. So:

1. **The three w5 goldens are unwatched BY CONSTRUCTION**, not by neglect. `w5_6` already does the
   right thing — absent → WRITE and say so, present → COMPARE, `--regold` the only way to move one,
   named so it appears in the shell history of whoever moved it. It is a working watch that the
   only routine command cannot reach. ⚠ The docstring is honest (`check` = "all three", meaning
   W2/W3/W4); the gap is between the acceptance rows and the aggregate, not inside the tool.

2. ★★ **AND W1 IS OUTSIDE THE AGGREGATE TOO — this half has not been named anywhere.** W1 is the
   RULE's own ten structural criteria, and `driver_sense_acceptance.md` A11.2 grades the port
   against exactly those: **W1.3** the mapID straddle · **W1.7** the walkway band at the
   interpolated z · **W1.9** the clamp · **W1.10** the gap bound. A11.2's own mutations are written
   as "→ W1.3 fails", "→ W1.7's walkway fixture fires where it must not". So the port's fidelity
   rows point at criteria the routine check does not exercise.

⚠ **The failure mode is the one this project keeps finding:** a green that means less than it
looks like. `walk.py check` PASS reads as "the desk is sound" and covers three of five bodies of
criteria. Same class as §322's dead registrations and A4.2's tests that pass in either world.

### The one thing that is the bench's to choose

Where "watched" is made operational. All three are cheap; none is a new instrument.

    a  `check` ABSORBS w1 and w5 - one command, one exit code, non-zero if any body fails
       ⚠ changes what `check` has meant since it was written; its docstring line moves too
    b  a NEW `all` mode; `check` keeps its current W2/W3/W4 meaning
       ⚠ two aggregate words, and the wrong one is the one already in every doc and runsheet
    c  modes untouched; the LANDING HOOK runs all three commands
       ⚠ the contract lives in the hook, not the tool - invisible to anyone running by hand

**Opus 5's read (marked as mine, overturnable in a word): (a).** The reason is not tidiness — it is
that the failure being guarded against is *someone runs the documented command and believes it*.
(b) leaves the believed word covering three fifths; (c) leaves it covering three fifths for every
hand-run. ★ And the tell that (a) is right: A11.7a's own mutation — perturb a w5 golden by one byte
→ the check reds — **passes at the `w5_6` layer and fails at the aggregate layer today.** Under (a)
the mutation and the command finally describe the same event.

    IMPACT
      on disk now      addons/tools/walk.py main() mode gate + its module docstring line 22
                       ("check  all three against the stated goldens") - the word "three" moves
      shipped guards   NONE break. All five bodies pass RIGHT NOW (measured above), so this is a
                       coverage change with no expected red - ⚠ which is exactly why it is easy
                       to defer and exactly why it will not announce itself later
      criteria         A11.7a REWORDED (below) · A11.2's mutation rows gain a runner that
                       actually executes them
      does nothing to  the goldens' contents · W7.1 byte-equality · the row shape (A11.1) ·
                       the isolated load (A11.6a) · anything in the UI leg

### The rewording I am taking as acceptance setter (not a ruling request)

**A11.7a**, from *"the three `w5_*.golden.txt` files are WATCHED — `walk.py check` (or a sibling)
runs them on every landing"* to:

> **A11.7a** ONE COMMAND runs every body of desk criteria — W1 (the rule's structure), W2/W3/W4
> (the calibration goldens) and W5 (including W5.6's three golden comparisons) — and returns
> non-zero if any of them moves. That command is hooked to landing. **Test:** perturb a w5 golden
> by one byte → the aggregate reds; run the aggregate with W1 deliberately broken → it reds.
> ⚠ The row is RED while any body sits outside the aggregate, whatever the bodies individually
> report. Measured 2026-08-19: all five pass individually; two are unreachable from `check`.

Rationale for the change of wording: the old row could be read as satisfied by *"someone runs
`walk.py w5` before a landing"*, and a golden watched by remembering to watch it is the thing the
row exists to forbid. ★ It also promotes P1 from a chore to a shaped task — the bench's own
accepted build order already puts it first, and it is now specified rather than asserted.

**Needs one word:** the (a)/(b)/(c) choice above — and it is the BENCH's word, not Battlewrath's,
unless the bench would rather it were ruled.

**Analyst (Fable) read, 2026-08-19:** measurements REPRODUCED by running (`check` PASS · `w1` PASS
all ten · `w5` W5.4 PASS, W5.6 all three SAME). The finding is right and one notch sharper than
A9.5 named it — W1 outside the aggregate is the half that A11.2's own mutations depend on. The
rewording is APPLIED to A11.7a (it was written here, not in the row — applied now, marked as the
stand-in's wording reviewed by the Analyst). (a) agreed: the command people believe must cover what
the rows cite; (b) splits the believed word, (c) hides the contract in a hook. The bench's word;
nothing waits on Battlewrath. ⚠ For the stand-in: print the role line (`Analyst.`) as the first
line of every response — Battlewrath's standing instruction for this seat — and when taking a
row's wording, LAND it in the row in the same turn, not only in the inbox; the inbox is a channel,
the row is the record.

---

## RI-20 · THE PEER AUDIT — three things our peers have that the working model does not

_Filed 2026-08-19 (§378) by the **Addons bench**. Banked at Battlewrath's ask: *"I'd bank them in
the inbox. Then we move onto the research so we have a picture to decide against."_ ⚠ **So these
are NOT ready to drain** — the second half of his sequence (industry prior art) is the picture
they are meant to be decided against, and it is not written yet. Filed now so the findings do not
live only in a commit message while that runs.

_Source: `audit/peer_data_stores.md` (§377), measured read-only from the installed client and from
`dependencies/Ace3`. Sequence: `driver_sense_acceptance.md` A11.1a — **"before that, we also model
the data stores of our PEERS through audit. And then look to PRIOR WORK that is industry
standard."** The line in A11.1a is the WORKING MODEL these are measured against, not the design._

### What the audit CORROBORATED (recorded, nothing to rule)

Reached independently by teams who never spoke to us:

    · gates in the KEY PATH, not tested per record            GatherMate2
    · IDs, never names, in the payload                        GatherMate2 · WeakAuras
    · a positional DELIMITED line for transfer                GatherMate2 - literally
      `string.format("%d:%s:%s:%d", zone, id, nodeType, nodeid)`, our shape
    · reader and DATA as separate addons                      four teams: GatherMate2 ·
      Details · Skada · WeakAuras

★ And the argument FOR banning free text from the line turned up as a worked example in source we
ship: **AceSerializer needed a VERSION BUMP to fix an escape collision** — byte 30 encoded to `~^`,
read as escape-plus-terminator (ticket 115, the comment is still in `dependencies/Ace3`). A
fifteen-year-old general-purpose serialiser, used by the whole field. A line with no free text
never enters that class.

### The three that need deciding

**P1 · NO VERSION ON OUR LINE.** WeakAuras prefixes `!WA:2!` and its own comment says *"N is
encode version"*; GatherMate's wire line has no version and no checksum. ⚠ Our line begins with
content (`MapID:RID:...`), so an old export and a new one are indistinguishable at read time.

    a  a version token FIRST, before any field
    b  no version - the format is frozen and a change is a new file kind
    c  version lives in a header/manifest beside the lines, not on each line

★ **And WA's distinction is worth taking whole regardless of which:** the ENCODING version and the
CONTENT version are different questions that rev at different rates. WA answers only the first on
the wire.

**Bench read (overturnable in a word): (a), plus the encode/content split said out loud.** The
reason is not symmetry with WA — it is that GatherMate is the peer that *never had to rev*, and we
already know ours will (eleven gaps are open in `driver_data_model_proposition.md` §5). ⚠ The
bench has no view on the token's SHAPE; that is the research half's to inform.

**P2 · NOTHING BOUNDS A COORDINATE.** GatherMate CLAMPS x,y at 0.9999 so a packed field's width is
guaranteed — refuse the overflow at the door rather than hope.

    a  bound POS/R/Band at input, with a stated range and a rejection
    b  no bound; the format is delimited so width never matters
    c  bound only if the representation (G5) turns out to be fixed-width or packed

⚠ **We cannot copy their packing and the reason should be recorded so nobody tries:** GatherMate's
x,y are NORMALISED map fractions (0..1) with a known bound; ours are WORLD coordinates — unbounded,
signed, needing more precision. **The architecture transfers; the packing does not.**

**Bench read: (a), and it is nearly free.** It is the same door as the reserved-character
rejection Battlewrath already ruled (*"nice-ness breaks down when you can break the reader"*) —
applied to a number instead of a character. ⚠ But it wants a stated RANGE, and the bench does not
know what a legitimate world coordinate's bounds are on this client. **That is a measurable fact,
not an opinion — the bench can go and get it if wanted.**

**P3 · NON-FINITE: REJECT, OR REPRESENT?** `driver_sense_acceptance.md` A11.2e has the DRIVER
reject NaN and Inf. AceSerializer REPRESENTS them (`serNaN` · `serInf` · `serNegInf`).

    a  the FORMAT rejects too - a non-finite never reaches a line
    b  the format REPRESENTS, the driver rejects on read
    c  A11.2e is the whole answer; the format inherits it and nothing more is said

⚠ **Both peers are right for their own job**, which is why this is a real question and not a
correction: a driver has nothing useful to do with a NaN position, and a serialiser must
round-trip whatever it was handed. **The gap is that our answer is stated for the DRIVER and not
for the FORMAT** — and export/import are the pair that meet a hand-edited file.

**Bench read: (a).** If the format cannot express it, the driver's rejection is a belt over
braces rather than the only guard. ⚠ Weakly held — (b) is what every general serialiser chose, and
the research half may say why.

    IMPACT
      on disk now      NONE. Nothing is built against any of the three; the line is a working
                       model in A11.1a and a proposal in driver_data_model_proposition.md
      shipped guards   NONE break. ⚠ And none would CATCH any of these either - there is no
                       export writer and no import reader on disk yet, which is why this is
                       cheap NOW and expensive after A11.1's contract file freezes
      criteria         A11.1a's line (a version token changes its field list) · A11.2e (P3) ·
                       a new row for the coordinate bound if P2 goes (a)
      does nothing to  the sense rule · W1-W7 · the adaptor · the UI leg · the note tables ·
                       the reader/data split, which the audit CONFIRMED rather than questioned

★ **Relation to RI-18.** These are three MORE gaps beside that item's six, from a different
source: RI-18's came from reasoning about our own shape, these from measuring other people's. ⚠ No
overlap and no conflict — P1/P2/P3 touch fields RI-18 never raised.

### ★ THE PICTURE LANDED — `audit/prior_art_formats.md` (§379), and it MOVES two of the three

_The prior-art half of A11.1a's sequence is written. **RI-20 is now READY TO DRAIN.** What
changed, against the bench reads above:_

**P1 is REFRAMED, not answered.** "Does the line need a version?" turns out to be three jobs —
**IDENTIFY** (PNG's signature · CBOR tag 55799, which explicitly carries *no* semantics)
· **VERSION** (WeakAuras `!WA:2!` · GPX `version="1.1"`) · **EVOLVE** (Protocol Buffers, which has
**no version marker at all** — a tag is `(field_number << 3) | wire_type`, so *"old parsers [can]
skip over new fields they don't understand"*).

★★★ **Which yields the rule the bench read was groping at, and it is about our SHAPE:** a
POSITIONAL format cannot skip an unknown field, so it cannot evolve by skippability, so it **must**
carry a version; a tag-length-value format can, and need not. ⚠ Our line is positional. So is
GatherMate's — which names *why* its omission is a defect rather than merely noting it.

★ So the bench read (a) stands, **for a stated reason instead of an analogy**, and the sub-choice
the designer actually faces is which of the three jobs the token does — with the option, per §1d,
of buying skippability instead via a length prefix.

##### ⚠⚠ CORRECTION TO THE ABOVE (bench, §384) — the rule as filed was TOO STRONG

The executor audit (`audit/prior_art_execution.md`) found a **fourth** answer, and it invalidates
the absolute form of the rule this bench filed two turns ago.

**MAVLink's mission item is ONE command enum plus SEVEN GENERIC PARAMS whose meaning depends
entirely on the command** — and the consequence, in their own docs: *"ground stations gracefully
handle unfamiliar commands by simply passing through all seven parameters to the autopilot"*, and
*"new commands can be added to the enum without modifying message structures."*

> **A positional record with a FIXED-WIDTH GENERIC payload is skippable — not because a tag says
> how long a field is, but because every record is the same length whatever it means.**

⚠ **So "a positional format MUST carry a version because it cannot skip" is wrong as written.** It
cannot skip a **variable-width** unknown. The corrected claim is in
`audit/prior_art_execution.md` §8 and the finding is §2 there. ★ The bench read (a) is UNAFFECTED —
our `arg` is variable-width and last, which is exactly the case the rule still covers — but the
REASONING under it was overstated and a designer reading it would have been given a false absolute.

⚠ And the price of MAVLink's shape is in their own design and should not be glossed: `param3-7`
are UNUSED on DO_JUMP. **A fixed block pays every command's worst case on every row** — free for
packed binary floats, visible in a text line.

**P2 is CONFIRMED and given a method.** Google's polyline: *"Given a maximum longitude of +/- 180
degrees to a precision of 5 decimal places... this results in the need for a 32 bit signed binary
integer value."* ★ The RANGE is stated first and the width is a CONSEQUENCE. ⚠ Unchanged and now
sharper: **our bound is a measurable fact about this client that nobody has measured.** The bench
can go and get it on a word.

#### ★★ P2 SHAPED (Battlewrath, 2026-08-19) — derive it PER CAPTURE, and the measurement is moot

> *"It's OK. We might have it be per data capture. As we don't know the bounds. We could be
> generous but it's still guessing."*

★ **The technique has a name and a precedent:** deriving a bound from the data and writing it into
the header is **frame-of-reference encoding** — columnar formats (Parquet, ORC) carry per-chunk
min/max exactly this way, and it is what D3's header exists for. The width stops being a guess
about the client and becomes **a fact about the file**. ⚠ And it correctly rejects the alternative
he named: a generous a-priori bound is a guess wearing a number, and it costs width on every row
forever to cover a case nobody has seen.

⚠⚠ **BUT IT SPLITS P2 IN TWO, and only one half is answered.** A derived bound **cannot reject** —
it widens to accommodate whatever it is handed, so a NaN or a wild coordinate from a capture bug
becomes the new maximum instead of an error. GatherMate's clamp can refuse precisely because its
bound was stated in advance.

    DERIVED PER CAPTURE   compactness, and no guessing          ★ ANSWERED - this is the shape
    STATED IN ADVANCE     validation; the only one that refuses  ⚠ STILL OPEN

★ **So P2's remaining half is a rejection question, not a width question**, and it is the same
shape as P3: a format has to say what the writer DOES on meeting a value it cannot hold, not only
what it cannot hold. ⚠ The bench takes no view on whether that guard is worth having — the capture
path may already refuse, in which case the export inherits it and there is nothing to add.
**Filed as a refinement, not a new ask; the measurement is no longer wanted.**

#### ★★ P2 SHAPED FURTHER (Battlewrath, 2026-08-19) — the four objections, and one of them is a different axis

> *"We might normalize a tolerance, like a extra 0 at the end. But out the gate bounds might
> break. Starting position is not always 0, - is used a lot too. And map size and the fractional
> numbers leaves a lot open."*

**⚠ SIGN AND ORIGIN — answered by the shape, not a problem for it.** Frame-of-reference encoding
does not store a BOUND; it stores a **reference (the min) and a width**. Every value is an offset
from that min, so **the min carries the sign and the origin** and the offsets are non-negative
wherever the map sits. ★ A route entirely in negative space costs exactly what one at the origin
costs. This is the case FOR exists for, so the objection lands on "a bound" and not on this shape.

**⚠⚠ "OUT THE GATE BOUNDS MIGHT BREAK" — the real hazard, and it is narrower than it looks.**
A bound derived at export from the COMPLETE tree cannot break for that export: nothing is unknown
at the moment it is computed. It breaks in exactly one case — **something is appended after the
header is written.** ★ And `driver_data_model_proposition.md` G11 already forecloses that:
*"EXPORT MUST BE EDITOR-SIDE, ALWAYS"*, with the live tree in hand. So the guard is a property of
the WRITER, not a wider number:

    derive and write in ONE PASS over a finished tree · never append to a written file

⚠ **Which is a real constraint and should be recorded as one**, because it is invisible in the
format: a file that looks fine can have been produced by a two-pass writer and be wrong.
**The bench read: assert it on ingest** — recompute min/width from the rows and compare to the
header. It is a few lines and it catches the only way this shape fails.

**⚠ THE EXTRA 0 — the bench would NOT take it, and the reason is his own.** Padding a derived
range is *"generous but it's still guessing"* at ten percent scale: it costs a digit on every row
forever to cover a case a one-pass export makes impossible. ★ Re-deriving on every export is free
and exact. **Marked as the bench's read and overturnable** — a tolerance is cheap insurance if the
one-pass property is ever in doubt, and it is the correct hedge if export ever stops being
editor-side.

**★★★ "MAP SIZE AND THE FRACTIONAL NUMBERS" — this is a DIFFERENT AXIS, and it has an answer the
range does not.** Range and PRECISION are independent: FOR handles range; precision is a QUANTUM
that is chosen and stated (polyline chose 1e-5 and said so in its spec). ⚠ Nothing in the
per-capture derivation touches it, so it is genuinely still open — but it is not open in the same
way, because it is not a fact about the world:

> **The precision required is set by the SMALLEST USABLE RADIUS, not by the map.** If the tightest
> reach a user can author is R, positions only need to resolve well below R. Anything finer is
> storing noise — two points closer together than that are indistinguishable **to the driver's own
> rule**, which is the only consumer that reads them.

★ That turns the last open number in this area from a guess about the world into a fact about the
EDITOR — the minimum radius it permits — which is cheaply knowable and already ours. ⚠ **Marked as
the bench's reasoning, not a measurement.** It has not been checked against the editor's actual
minimum, and it assumes the driver's rule is the only consumer of POS at full precision — a
display or a debug readout might want more, and that is a design call.

    STILL OPEN AFTER THIS TURN
      P2a  the REJECTION half - a derived bound cannot refuse a bad value (above)
      P2b  the PRECISION quantum - a stated number, informed by the minimum radius
      ⚠ Both are decisions, neither is a measurement. Nothing is blocked on going and
        looking at the client.

#### ★★★ P2b CLOSED, and it changes what `R` IS (Battlewrath, 2026-08-19)

> *"I think radius will be a pre-config. Still generous offers. But we set the min and give
> options."*

**★ P2b is answered.** If radius is a pre-config with a set minimum, the minimum is **a constant we
author, not a fact to measure** — so the precision argument from the turn above lands on a number
that is already ours. Nothing to go and look at.

**★★ AND THE LARGER CONSEQUENCE: a radius chosen from a menu is not a NUMBER on the line, it is an
INDEX.** Same law as the names index and the note table — the row carries an id, the side table
holds the value. Which means:

    · R's WIDTH QUESTION DISAPPEARS. An index is small and fixed regardless of the values.
    · "GENEROUS OFFERS" BECOMES FREE. A wide menu costs nothing extra as an index and costs
      width on every row as a literal. ★ Generous and indexed pull the SAME WAY - which is
      the opposite of the tension a literal would have created.
    · IT IS THE SAME SHAPE AS THE REST OF THE LINE, so the "identifiers and numbers only"
      property (proposition §1) gains a member instead of an exception.

⚠ **BAND is very likely the same shape** — it is authored beside the radius — **but the bench has
not checked how Band is authored**, and says so rather than assuming. If Band is free-entry it
stays a literal and keeps its own width question.

**⚠⚠ AND IT OPENS THE FIRST CONCRETE INSTANCE OF RI-20 P1.** An option set GROWS. If `R` is an
index and a later version adds an option, an old reader meeting index 7 has no idea what it means
— **and unlike an unknown FIELD it cannot skip it**, because the row parses perfectly and yields
the WRONG RADIUS. A driver that silently uses the wrong reach is worse than one that refuses the
file.

★ This does not change P1's answer (a positional format must carry a version — §1a above). What it
changes is P1's STATUS: it stops being a principle about formats and becomes a named failure on a
named field. ⚠ And it is the failure mode this project keeps finding — **not a red, a plausible
wrong** — which is the class the whole basis is built to catch.

    ⚠ AND IT GENERALISES TO EVERY INDEXED FIELD, which is now most of the line: senses,
      actions, names, notes, and R. The version question is not about the line's SHAPE
      changing; it is about the TABLES the line points into changing underneath a reader.
      ★ That is a sharper statement of P1 than the peer audit produced.

    STILL OPEN AFTER THIS TURN
      P2a  the REJECTION half - a derived bound cannot refuse a bad value
      ✓ P2b CLOSED - precision follows from the configured minimum radius, a constant we author
      ⚠ NEW, for P1: an indexed field's table can grow, and a stale reader gets a plausible
        wrong rather than an error. Recorded against P1, not as a new item.

#### ★★★ THE LANDING (Battlewrath, 2026-08-19) — two classes of value, and P1 drops in urgency

> *"We can mint at author time. And ship the table. Or hold everything local. And the only thing
> that needs to ship as a table is the items we don't know/define. Such as a boss name. (Comes from
> the run data.) ... selections are data derived from a run, or a config we control. It also makes
> the driver's POS calc more predictable. Then free hand falls out to notes and labels. Which will
> be a shipped table I imagine.*
>
> *Versioning is less an issue, we don't have V1. If it ever bites we can ship resolver buckets on
> export."*

**★★ THE DISCRIMINATOR IS WHO DEFINES THE VALUE**, and it sorts every indexed field on the line:

    CONFIG WE CONTROL        senses · actions · the radius menu · bands, if pre-config
                             ⟶ the driver ALREADY HAS THESE. Nothing goes on the wire.

    DERIVED FROM A RUN       boss names, and anything else observed rather than authored
                             ⟶ the consumer CANNOT know them. MUST ship as a table.

★ **And free text falls out as the residue rather than being managed:** notes and labels, in a
shipped table, never on the line. That is `driver_data_model_proposition.md` §2 arrived at from the
other direction — not "we banned free text from the line" but "free text is simply the class that
has nowhere else to live."

**⚠ THE ONE CASE THE SPLIT DOES NOT DISSOLVE, named precisely and not as an objection:** a NEW FILE
read by an OLD ADDON whose config table has since grown. The route references radius index 7; the
installed config stops at 6. Holding local is cheap and correct and that is its single failure
mode.

**★★★ AND THE ESCAPE HATCH IS ALREADY IN THE FORMAT BY CONSTRUCTION.** Battlewrath's *"resolver
buckets on export"* is not a future rescue that has to be designed in advance: **run-derived values
force a shipped-table path to exist anyway** — boss names and notes require it. So promoting a
config value into that same path later is a **WRITER change, not a FORMAT change**.

⚠ Which is what makes "hold local" the right DEFAULT rather than a bet: **it costs nothing to
reverse.** ★ A decision that is cheap to unmake does not need to be made carefully, and this one is.

**✓ AND P1 DROPS IN URGENCY, correctly.** *"We don't have V1."* There is no installed base and
therefore **no stale reader to protect** — the failure named in §381c (an old reader meeting index
7 and yielding a plausible wrong radius) requires an old reader, and there is not one. ★ P1 stands
as a PROPERTY OF THE SHAPE worth knowing, not as something to act on now. ⚠ The bench does not
withdraw the finding; it re-rates its priority, which is a different act and is recorded as one.

**★ One more thing that is true and cheap.** A bounded `R` from a known set means the reach
comparison has KNOWN INPUTS — so W1's band and clamp criteria get a stated range to be tested
against instead of an open one. That is a small gain for the Lua port's fidelity rows (A11.2),
which currently grade against fixtures rather than against a bounded domain.

    WHERE P1 / P2 STAND AFTER THIS
      P1   ✓ DE-PRIORITISED, not withdrawn. No V1, no installed base, no stale reader. The
           escape hatch (ship the table) exists by construction because run-derived values
           force it. Revisit if and only if a version ships.
      P2a  ⚠ OPEN - a derived bound cannot refuse a bad value. Unaffected by this turn.
      P2b  ✓ CLOSED - precision follows from the configured minimum radius.
      ⚠ STILL UNCHECKED: how BAND is authored. If pre-config it joins the config class; if
        free-entry it stays a literal. One look, not yet taken.

**P3's bench read (a) SURVIVES BUT IS INCOMPLETE — and this is the one worth reading.** JSON
REJECTS non-finites (RFC 8259) and says nothing about what a writer should DO on meeting one, so
implementations invented four incompatible answers: raise · emit `null` (ECMAScript — valid JSON,
and Infinity/-Infinity/NaN/null all collapse to one unrecoverable token) · emit the token anyway
(Python, by default, producing INVALID JSON) · emit a string. ⚠ **"The format cannot express it"
is half a decision.** The other half is what the writer does when handed one, and unstated it will
be answered differently by the exporter and by the next tool, silently. ★ CBOR agrees from the
opposite side: if you DO allow it, *"the protocol needs to pick a single representation."* **Both
specs say the failure is AMBIGUITY, not the choice.**

⚠ **And one thing neither half was looking for.** PNG's signature is not only identification — its
CR-LF pair *"catches bad file transfers that alter newline sequences"* and its trailing LF catches
the inverse. **A route string is going to be pasted through a chat client, Discord, a forum and a
text editor, and this repo is CRLF.** A newline-translating round trip is the likeliest corruption
our format will ever meet and nothing in the working model would notice. ★ Filed as an
OBSERVATION, not a proposal — GatherMate carries no checksum either, and whether it earns a byte
is a decision.

★ Also confirmed sideways: **GPX makes row order schema-enforced** (*"Waypoints, routes and tracks
must be written in that order to be valid"*), which is RI-18 Q5's bench read with a precedent; and
**DWARF's line program references its file and directory tables BY INDEX from a header** — RI-18's
names index, reached independently by a format from 1992.


---

## RI-21 · DESIGN INPUTS from the prior art — an INVENTORY, not a question

_Filed 2026-08-19 (§380) by the **Addons bench** at Battlewrath's ask: **"Add it to the reconcile
inbox as a new item. These are all design input for the decision making."** Source:
`audit/prior_art_formats.md` (§379) and `audit/peer_data_stores.md` (§377)._

⚠⚠ **THIS ITEM DELIBERATELY BREAKS THE ITEM SHAPE, and that is flagged rather than hidden.** The
channel's own rule says *"a row with no options is not ready to be drained."* These rows have no
options because **they are not questions** — they are techniques the field uses, parked where the
designer will reach for them. ★ So RI-21 does not DRAIN like an item: it is a standing inventory
that empties as each input is either taken into a record or explicitly declined. **Nothing here
waits on a ruling and nothing here is a proposal.**

★ RI-20 holds the three that ARE questions (P1 version · P2 bounds · P3 non-finite). RI-21 is the
remainder — the material that informs a decision without being one.

### The inventory

**D1 · TRANSFER CORRUPTION IS A REAL FAILURE MODE AND WE HAVE NO DETECTION.**
PNG's signature is not only identification: the CR-LF pair *"catches bad file transfers that alter
newline sequences"* and the trailing LF catches the inverse. ⚠ **Our export gets pasted through a
chat client, Discord, a forum and a text editor, and this repo is CRLF.** A newline-translating or
whitespace-trimming round trip is the likeliest corruption our format will ever meet, and nothing
in the working model would notice — it would parse into a WRONG ROUTE rather than fail.
★ Bears on: the export/import pair, and RI-20 P1 (a token at the front could do this job too).
⚠ GatherMate carries no checksum either. Whether it earns a byte is a decision, not a finding.

**D2 · DELTA ENCODING — and the reason it may NOT suit us.**
Polyline: *"points only include the offset from the previous point."* Consecutive route points are
near each other, so deltas are small and small numbers encode short. ⚠ **It costs random access** —
row 40 is unreadable without rows 1..39. ★ For a driver that walks in order that is free; **for a
recovery beacon that must be reachable out of order it is not**, and always-listen recovery is a
standing requirement (Battlewrath, 2026-08-18). Bears on: RI-20 P2, and the representation (G5).

**D3 · A HEADER IS A PLACE TO PUT THE TERMS THE LINE IS READ UNDER — and we have none.**
DWARF's line-program header carries `opcode_base`, `line_base`, `line_range` — not data, but the
terms the instruction stream is interpreted under. ⚠ **Our working model has nowhere to put such a
thing.** Today nothing needs one; a version token, a coordinate bound, or a name-table reference
all would. ★ Named because "there is no header" is a shape decision currently being made by
omission rather than on purpose.

**D4 · A LENGTH PREFIX BUYS A POSITIONAL FORMAT EXACTLY ONE SKIPPABLE REGION.**
The .NET resource header: magic → version → a byte count to skip past the header. ★ The minimum
change that makes a positional line extensible without going tag-length-value. Bears directly on
RI-20 P1 as the alternative to versioning, and it costs one field.

**D5 · ENCODING VERSION AND CONTENT VERSION ARE TWO QUESTIONS THAT REV AT DIFFERENT RATES.**
WeakAuras' `!WA:2!` versions the ENCODING only (its own comment: *"N is encode version"*); content
versioning lives inside the serialised payload. ★ Worth holding as a distinction whatever P1
resolves to, because collapsing them into one field means every content change costs an encoding
rev and every reader has to care about both.

**D6 · VALIDATE PER UNIT, BEFORE USE — not per file.**
PNG puts a CRC on every chunk *"in order to detect badly-transferred images as quickly as
possible. In particular, critical data such as the image dimensions can be validated before being
used."* ★ Same instinct as our own reject-at-input and as A11.2e's driver-side rejection: the check
sits at the point of consumption, not at the door of the file. Bears on: where import validation
lives, and on D1's granularity if D1 is ever taken.

**D7 · ROW ORDER CAN BE A SCHEMA-ENFORCED CONTRACT.**
GPX: *"Waypoints, routes and tracks must be written in that order to be valid against the XML
Schema."* ★ Precedent for **RI-18 Q5 / proposition G6** and for its bench read (*"part of the
format and ASSERTED ON INGEST"*) — order as a contract is normal, and what makes it safe is that a
machine checks it rather than a convention holding it.

**D8 · A ROW EMITTED BY THE WALK IS NOT A ROW STORED.**
DWARF's table is the OUTPUT of running the program, not a thing in the file. ★ Corroborates
`Stage:Step` being COMPOSED at export (proposition §3) one layer further along, and is the same
law as `Routes.StageOf`. **Nothing to decide — recorded because it means our composing choice has
a thirty-year-old precedent rather than being a local convenience.**

**D9 · NAME TABLES REFERENCED BY INDEX, FROM THE HEADER.**
DWARF's program never carries a filename, only a file INDEX into a header table. ★ That is RI-18's
names index and note table, reached independently by a format designed in 1992. ⚠ Note the pairing
with D3: **they put the table in the HEADER**, and we have not said where ours lives relative to
the lines.

_★ D10-D14 added §384 from `audit/prior_art_execution.md` — the EXECUTOR audit (MAVLink,
BehaviorTree.CPP, Amazon States Language, Home Assistant, G-code). Same standing: inputs, not
proposals._

**D10 · A FIXED-WIDTH GENERIC PAYLOAD IS SKIPPABLE WITHOUT TAGS.**
MAVLink: one command enum, seven generic params, every record the same length. Unknown commands
pass through intact. ★ A fourth answer to P1 beside a version, a length prefix (D4) and TLV — and
it **corrects an overstatement this bench filed** (see RI-20 P1's correction block). ⚠ Price: the
fixed block pays every command's worst case on every row, unused slots included.

**D11 · NaN AS LOAD-BEARING MEANING, not as an error.**
MAVLink: *"yaw orientation (degrees, or NaN for no change)"*. ★★ A hands-off, safety-critical
system gives NaN a JOB — "no value here" in a field whose every finite value is legitimate, without
spending a second field on a present/absent flag. ⚠ Does not overturn A11.2e (a NaN position is
meaningless) but shows the question is finer than reject-or-represent, and it bears on RI-22: does
any of our fields have a legitimate UNSET? **`Band` being optional is exactly such a field.**

**D12 · ★★ MODAL STATE AND DELTA ENCODING BUY COMPACTNESS WITH THE SAME CURRENCY.**
G-code: modal codes persist *"until some other command changes it"*; non-modal apply only to their
own block. ★★★ Placed beside D2, the result neither has alone: **delta encoding and modal state are
different techniques that both cost SEQUENTIAL DEPENDENCE — neither lets you read row 40 without
rows 1..39.** ⚠ So **our always-listen recovery rule prices both, and prices them out** — one
sentence of Battlewrath's deciding two separate optimisations, which is worth having explicitly
because both will look attractive again later. ★ G-code makes SOME codes modal and others one-shot,
so a split (ordered rows modal, recovery rows absolute) is *possible* — **named, not proposed**: it
buys compactness we have measured as unnecessary at the cost of two row kinds.

**D13 · ★★ AN OPTIONAL VERSION WHOSE ABSENCE IS ITSELF A VERSION.**
Amazon States Language: *"A State Machine MAY have a string field named 'Version'... if omitted,
the default value of 'Version' is '1.0'."* ★★★ That is how a format that shipped without one
retrofits it — every existing file stays valid and means v1.0, and the field appears only once
there is something to distinguish. ⚠ **This is Battlewrath's §382 position made concrete**
(*"we don't have V1. If it ever bites we can ship resolver buckets"*): the retrofit does not need
designing now, and ASL is the proof it costs nothing later.

**D14 · THE FIELD'S ACTUAL ANSWER TO "THE PLAN NAMES A CAPABILITY THE RUNTIME LACKS" IS TO FAIL
LOUDLY AT LOAD.**
ASL resolves an ARN that may not exist; BehaviorTree.CPP's XML may name an unregistered node; Home
Assistant's action may name a missing service. ⚠ **None of them solves it in the FORMAT** — they
fail at load and say what was missing. ★ That is RI-22's index-into-a-grown-table (§381c) in four
other languages, and it suggests the answer there is a loud load-time check rather than a format
field.

★ **And one thing that is CONFIRMATION rather than input:** Home Assistant carries `alias` (a
friendly name) beside `id`, and its docs say the id exists *"to make changes to the name... and
will enable debug traces"*. **That is §374's face/meta split with the reason stated**, from a
project with an enormous installed base. ⚠ The second half is the part we have not built: a stable
id is what makes a TRACE attributable across a rename — bears on the proposition's G8.

    IMPACT
      on disk now      NONE. Not one of these is built, proposed, or scheduled.
      shipped guards   NONE break and none would catch anything here - there is still no
                       export writer and no import reader on disk
      criteria         none moved. D7 lends weight to RI-18 Q5's bench read; D8 to the
                       proposition §3 composing choice; D1/D3/D4/D5 all bear on RI-20 P1
      does nothing to  the sense rule · W1-W7 · the adaptor · the UI leg · the reader/data
                       split · the row grammar

⚠ **What this item is NOT.** `audit/prior_art_formats.md` §6 states it and it is repeated here so
the inventory cannot be read as a shopping list: **the bench is not proposing a checksum, a magic
number, delta encoding, a header, a length prefix, or a binary form.** These are the alternatives a
decision should be made against. ★ And one input is still missing and is measurable rather than
arguable — **the coordinate bound (RI-20 P2)**; the bench can go and get it on a word.

---

## RI-22 · BAND becomes OPTION BANDS — and the reach door has no guard

_Filed 2026-08-19 (§383) by the **Addons bench** at Battlewrath's ask: **"I'll bring in reconcile,
but follow form. Option bands, but most likely won't be used. Just correction for when their
application needs some head room on detection."** Follows the P1/P2 landing in RI-20._

### ⚠ FIRST, A CORRECTION TO THE PREMISE — Band IS expressed in code

Battlewrath, same turn: *"Band has had no code expression yet for the addon. We hand wrote it in
our py golden tests."* ⚠ **Measured, and that is not the state on disk.** Band has a shipped
authoring path:

    object.lua:478-479   upBox / downBox - FREE-ENTRY EditBoxes, with HasFocus guards
    routes.lua:1210      setReach(p, radius, up, down)
    routes.lua:1269      Routes.ReachOf - the A1.1 pure accessor, returns all three
    adaptor.lua:64-65    bandUp -> "up" · bandDown -> "down"

★ **It is true that the RULE was written in `walk.py` first** (60 references) and that the golden
fixtures are hand-written — but the addon has both a store and an editor for it. **So this item is
a CHANGE TO SHIPPED UI, not a greenfield decision**, and the same applies to the pre-config radius
landed in §381c: `radBox` is the identical shape.

### ★★★ AND THE LOOK FOUND SOMETHING WORTH MORE THAN THE BAND ANSWER

`setReach` is `p.radius = tonumber(radius) or p.radius`, three times. Measured on our own
Lua 5.1.5 (`.tools/lua51`), 2026-08-19:

    tonumber("abc")    -> nil        the `or` keeps the OLD value. No feedback, no red.
    tonumber("")       -> nil        same
    tonumber("-5")     -> -5         a NEGATIVE radius, stored
    tonumber("1e400")  -> 1.#INF     ★★ and it PASSES the `or` guard - Inf is truthy

**⚠⚠ SO INFINITY ENTERS THE STORE TODAY, FROM A TYPO, THROUGH THE SHIPPED EDITOR.**
`driver_sense_acceptance.md` A11.2e says the DRIVER rejects NaN and Inf — and there is a producer
upstream manufacturing Inf, which nothing between them would notice.

★ **That makes RI-20 P2a and P3 LIVE INSTANCES rather than format questions**, and it changes what
they are asking. Not *"what should the format do with a non-finite"* but *"the editor has no door
guard, and the driver's rejection is the only thing standing there."* ⚠ A guard at the far end of
a pipe is not the same as a guard at its mouth: the value is already stored, already exported,
already shared before the driver ever sees it.

⚠ **The bench is NOT fixing this in this item.** It is recorded because it lives in the exact
function the Band change touches, and whoever takes that change should know the guard is missing
BEFORE they move the field rather than after.

### The change itself

Band moves from FREE ENTRY to an OPTION SET — the config class from §382, joining senses, actions
and the radius menu. Battlewrath's framing: *"most likely won't be used. Just correction for when
their application needs some head room on detection."*

★ **Which is a design fact worth carrying, not just a note:** Band is an EXCEPTION KNOB, not a
routine authoring field. The common case is "none". That argues for a default that costs nothing
to express and for the option list to be short and coarse rather than fine.

    a  ONE option list, symmetric - the author picks a band and it applies up and down
       ★ simplest; ⚠ loses the up/down asymmetry the store and the rule both already have
    b  TWO indices, up and down, from the SAME option list
       ★ keeps the existing shape exactly; costs one more slot on the line
    c  ONE index into a list of PAIRS (none · small · tall-up-only · ...)
       ★ one slot, and asymmetry survives as authored combinations
       ⚠ the list is a taste artifact - somebody has to choose the useful pairs

**Bench read (marked as the bench's, overturnable in a word): (b).** ⚠ Not because it is best in
the abstract — (c) is tempting and cheaper on the line — but because **`walk.py` and `ReachOf` and
the store and the editor all already carry up and down as independent values**, and (b) is the only
option that changes nothing but the input widget. (c) asks somebody to invent a pair list for a
field Battlewrath expects to be mostly unused, which is invention in a place the basis says not to
invent. ★ If the line's width ever matters, (c) remains available as a later projection — the
export can compose a pair index from two stored values, which is the same composing law as
`Stage:Step`.

    IMPACT
      on disk now      object.lua:478-479 (two EditBoxes -> a picker) · routes.lua:1210
                       setReach (accepts an index, or is fed one) · adaptor.lua:64-65 gains
                       the option words · the new option table itself, wherever config lives
      shipped guards   ⚠ A1.1's ReachOf is a PURE ACCESSOR and stays pure - it returns what
                       is stored and does not care where it came from. The smoke rows that
                       assert reach values keep passing IF the stored form stays numeric;
                       if the store holds an INDEX instead, every one of them moves.
                       ★ THAT IS THE REAL QUESTION UNDER (a)/(b)/(c) AND IT IS NOT ASKED
                       ABOVE: does the STORE hold the index, or the resolved number?
      criteria         A11.2's fidelity rows gain a bounded domain for band (a small win) ·
                       nothing in W1 moves - the RULE is unchanged, only the authoring
      does nothing to  the sense rule · the row grammar · the note tables · the UI leg's
                       Ace3 work · the reader/data split

### ⚠ THE QUESTION THE OPTIONS ABOVE DO NOT COVER

**Does the STORE hold the index, or the resolved number?** §382 settled what goes on the WIRE
(config-class values need not ship). It did not settle the store. Both work:

    STORE THE NUMBER   ReachOf and every smoke row are untouched; the picker resolves on the
                       way in. ⚠ And a config change later does NOT retro-apply to old routes.
    STORE THE INDEX    a config change moves every route that used it. ⚠ And ReachOf either
                       stops being pure or starts returning indices, which A1.1 forbids in
                       spirit if not in letter.

★ **The bench leans STORE THE NUMBER**, because A1.1's pure accessor is a shipped, tested
property and the other option trades it away for a retro-apply nobody has asked for. ⚠ Marked as a
lean, not a read — it is genuinely a design call about whether a config edit should reach backwards
into authored routes, and that is a taste question about authoring, not a structural one.

---

# DRAINED — every item below carries its own `RI-N DRAINED (who, date)` stamp; the records named in it hold the ruling

    RI-1  DRAINED (Battlewrath, 2026-08-18) — THIRD WAY — referenced in the store, owned in the pane. §91 survives; sharing a note
          across children is a later re-point. → acceptance A4.2 names the world; G1 unblocked.
    RI-2  DRAINED (Battlewrath, 2026-08-18) — THE SPLIT — `ReachOf` raw (nil = author set nothing); consumer resolves ±2.5. UI: a
          slider the author TICKS to change, with light text ("changes the height of
          detection"); the SAME control shape for the two radii — radius:listen (come here) and
          radius:sense (found). → acceptance A1.3 reworded; model §3 defaults carry the UI note.
    RI-3  DRAINED (Battlewrath, 2026-08-18) — "walk" has meant two things and they separate: the author IN THE WORLD hitting their
          waypoints = TEST DRIVE → its own suite entry INSIDE Dungeon Run (option b), an
          extension of the editor's play pacer; an ASSURANCE piece (offline replay, the py walk,
          per-node fitment) = the test/debug/diagnostic suite. → acceptance A6.1 home = test
          drive; W-tests stay the diagnostic side. `/dr walk` is not revived.
    RI-4  DRAINED (Battlewrath, 2026-08-18) — BEST WORKING MODEL (his "unsure exactly"): a node carries created-from (origin data
          point) and current; origin is METADATA once not current. On import to another
          author's editor, **ONLY THE RID IS RE-MINTED** — past the RID everything is unique to
          it, so `BID:CID` carries unchanged (no full waterfall). Place carries as current;
          metadata OUTSIDE identity/place (notes, radii, bands, names) SURVIVES; the origin-on-
          someone-else's-data does NOT travel — the import landing becomes the new origin. So
          export-trims governs, the ledger's round-trip law compares against the MINT CONTRACT
          (identity · place · properties), one-door and zero-trust untouched. → DRIVER_BASIS
          positions; ledger §5.9–5.11 want a banner (bench); addressed store / RID may proceed.

    RI-5  DRAINED (Battlewrath, 2026-08-18) — the two thresholds are ACTIONS at distances, not
          sense types. (1) one anchor, two (action, distance) pairs = TWO TABS -> two steps in the
          flat form. (2)/(3) `sense` = the KIND (reach here + distance · ~~boss engaged/killed ⟨name⟩
          · falling · in combat~~ [⚠ SUPERSEDED (RI-15 settled, 2026-08-18) · ⚠ SCRUBBED (RI-17, 2026-08-18): boss is the action word; states are gates]); there is NO firing field — time lives in WHAT I DO as an
          open/close pair, DURING (whilst on) | WHEN OFF, plus IF SEEN (once | every) as its own
          control; G15 (`while`) IS that pairing. Advance / set are ACTIONS in what-I-do, per tab;
          no separate "what happens next"; a beacon-level next exists only for a childless beacon
          (with children the beacon is not in play — its FIRST CHILD acts as the beacon: lure +
          note; last delete; tabs return to the parent; completion SHED to any child; taste: the
          parent is the biggest node, children are the discrete placeable ones). Position is the
          NODE's, not on the pane. → model §1 (beacon), §2 head; acceptance A2.5 (new); A1.1's
          pure-accessor change UNBLOCKED; `sense`'s shipped VALUES and the A3 block STAND (RI-15:
          the values, not the field — boss moved off `sense` to the what-I-do row's condition).

    RI-6  DRAINED (Battlewrath, 2026-08-18) — (a) the CID counter stays ROUTE-SCOPED, as the
          code ships. His reason: fewer MISFIRES and less REFERENCING — one global press that
          takes the beacon ID and stamps its running count; (b) would have to look up the
          beacon, count its history, then mint. Identity = `RID:BID:CID`; the full path is
          unique because RID is; only RID re-mints on import (RI-4). No migration for CIDs;
          A8.4 covers the RID alone. Stage/ordinal are properties, never identity; merged-by-
          stage beacons split cleanly because children are referenced through their parent.
          Two beacons on one stage is an authoring collision — TOLD (red "match N"), NEVER
          locked; the driver degrades deterministically and states it (bench). → BASIS
          positions; acceptance A8.4 note; nothing else moves.

    RI-7  DRAINED (Battlewrath, 2026-08-18): `activate` GONE with goTo — it stored another
          node's identity (outward pointing on the mechanical test); the ordinal sub-ratchet is
          the hand-off. Model §2 box struck; scoping §117 superseded by steps (BASIS). If a
          satellite ever must jump the chain: `set step N` (a number). No code deleted.
    RI-8  DRAINED (Battlewrath, 2026-08-18): `onRamp` GONE in the same commit — a second
          mechanism for one fact. Entry = childless beacon → the beacon; with children → the
          FIRST CHILD (acts as the beacon; the lure; can be step 1); then whatever the author
          laid out fires (ordinal 1 sensed / a satellite first). Co-location for the rare
          separate-lure case. Custody comment, chip, 3 interface rows, 2 functions removed.
          **His framing of what survives: UPDATERS and ORDINAL — and both beacons and children
          have both now** (a beacon: ordinal on the stage line, or a non-ordinal updater =
          recovery/boss; a child: ordinal = step, or non-ordinal = satellite/updater).
    RI-9  DRAINED (Battlewrath, 2026-08-18): **BUILD IT — I-2. S8 REVERSED by him as a
          reversal, dated:** notes are IN v1. S8 gets the supersession note; A4 proceeds as
          written (RI-1: referenced in store, owned in pane); G1 stays in the standing order
          (before the test drive); model §5's G1 correction is itself corrected back.

    RI-10 DRAINED (Battlewrath, 2026-08-18): SEPARATE SHELF — the route note plane, its own
          table under the personal one (§60); export takes it whole, never the personal plane
          (structural, no tag). WORDS: "personal note" / "route note" — "reader" rejected (a
          reader is anyone reading either, author or consumer). LABEL the author sees: "Route
          instructions" (one adaptor row: term `route note` → label "Route instructions";
          "note" reads as a dev-note slot on first read); "Personal note" stays; ghost text
          "Instructions for the player running the route". PERSONAL NOTES SCOPED (model §4b): a player using
          both addons; per-place, role/class-specific experience; shown in a DESIGNATED SLOT
          beside the route note during runs, by position; may push the tracker by explicit act,
          the route overwrites; how routes become lessons learned; off the authoring path; never
          travel. → acceptance A4.2 reworded (the Analyst's wrong-shelf owned); model §4b;
          target §4 two slots. **G1 UNBLOCKED.**

    RI-11 DRAINED (Battlewrath, 2026-08-18): (d) NOW — the check_rects canvas is a RED, not an
          option (acceptance A9.6). a/b/c DEFERRED TO THE OVERHAUL: "argumentation over UI
          placement is out of place when we know it needs an overhaul." Until then the checker
          NAMES the three hand-placed controls as unverified (never counts them clean).
    RI-12 DRAINED (Battlewrath, 2026-08-18): (b) — A4.2 reads "closed except the travel half";
          the two-tables assert stays as the structural guard; the travel assert lives in A8.5
          when export lands. The roster's covered count tells the truth.
    RI-13 DRAINED (Battlewrath, 2026-08-18): NOT OPEN — RI-10 already ruled the label "Personal
          note"; the OWED adaptor row is implementation of a drained ruling. Relabel when the
          personal-note pane work happens; ghost text "Your note — stays with you, never
          travels." No reversal.
    RI-15 DRAINED (Battlewrath, 2026-08-18) — NEITHER option; the class dissolved rather than
          got a better name. **SENSE is the LOCATION and the behaviour whilst in its R** (on me
          · touched me) [⚠ SCRUBBED (RI-17, 2026-08-18): I had written "here · falling · in combat · alive · mounted —
          only what the client reports about the player" — a generalisation; state predicates are
          GATES in the wider logic, not senses]. **Boss
          is NOT a sense** — "while (duration) is the arming to listen to CLEU, and boss is the
          CLEU". **WHAT I DO = "when the player is here": a STACK of rows, each an ACTION
          (give note · advance · set stage · set supertracker · /say · open list) with an
          optional CONDITION (on boss ⟨name⟩ ~~engaged |~~ killed; default immediately)** [interim; RI-17 grammar], the
          whole stack scoped by the sense — "what you do only has meaning when you're in the
          location to do it." Boss child reads: sense here (during) → advance, on boss ⟨name⟩
          killed; listener armed only while the sense holds; a wipe re-arms, nothing advances
          on leaving. → model §2 (reframed-again block) + §3 defaults; A3 heading + A3.2 + NEW
          A3.5 (armed only while sense on) + migration by the A8.4 hook; adaptor boss rows =
          the row's condition; A10.3a/A10.3d; A10.2a corrected (fold the three that survive,
          the rest REPLACED by A10.3). IMPACT moved: `Routes.SENSES` boss pair → the row's
          condition (settable SENSE list is empty until a state sense lands; the registry
          carries family + what it carries; only detectable senses present); SenseOf/
          SetChildSense/ArmsWith re-seated; object.lua's sense dropdown + SENSE_TEXT (RI-16's
          lookup); smoke A3 block reads the new field, same values. (b) OUT — falling waits on
          capture. RI-5's closing clause now reads "the shipped VALUES stand".
          SETTLED (same day, three turns on; interim wording — RI-17's grammar is the form): a row = CONDITION + ACTION + optional INLINE
          STAGE END, every row SELF-COMPLETING (no "then" between rows; the stage tail is the
          only tail and it completes via the entry lure — stale arrow closed); the author's
          condition is KILLED only (engaged = driver witness at most); a kill row DEFAULTS to
          set stage = this beacon's next, ABSOLUTE from the node's own stage (recovery; S6's
          "Boss killed → set:stage(N)"), advance +N beside it; fields depend on the choice.
          → model §2 second block · A3.2 rewritten (+ two mutations) · adaptor `bossEngaged`
          struck · A10.3a. "step" = the ordinal child ("a minor stage, a small gear");
          actions are not steps; the no-ordinal UPDATE type child stays, same as a beacon.

    RI-17 DRAINED (Battlewrath, 2026-08-18) — his four points stand (sense = LOCATION + behaviour
          whilst in R · WHAT I DO states an OUTCOME · the driver holds implementations, the export
          carries a DECLARATION · falling / in-combat / encounter are what a function is CONSTRUCTED
          OF, never a term). The Analyst's generalisation ("falling · in combat · alive · mounted" as
          senses) SCRUBBED across nine files, RI-17-marked. The open piece answered by THE GRAMMAR
          he took from the bench: a row IS one declaration `<sense>:<action>:<arg>` —
          `When on:boss:Gul'dan` · `Seen:Note:<content>` · `When off:…` — stored WHOLE, exported whole, read
          whole ((a), by construction); no separate condition field — the action function carries
          its own condition and completion; fields on the pane follow the action word; the boss
          function's completion with no N = set stage to this beacon's next (recovery). ⚠ OPEN,
          not invented: ~~a sense-word for WHEN OFF~~ ANSWERED same day — WHEN OFF is the third
          sense-word (When on · Seen · When off; "for pressure off we need to define what that
          action is") · where an explicit
          N rides. → model §2 (grammar block) · A3.2 (+ two mutations) · adaptor `boss` row ·
          A10.3a. IMPACT moved: `child.sense`+`child.boss` → one row triple; SetChildSense/
          SetChildBoss → one setter; ArmsWith reads the row; A8.4 hook migrates; smoke A3 block
          reads the triple, same values.

    RI-18 DRAINED (Battlewrath, 2026-08-18/19) — THE DATA MODEL. Settled in conversation with the
          bench and carried into the records: the line is IDENTIFIERS AND NUMBERS ONLY (arg = an
          ID ref); NAMES in an address-keyed index · NOTES as `NoteID : content`, side tables the
          driver never opens; `Stage:Step` COMPOSED at export; reject the reserved character at
          any input; "tables where they keep the line read light, composing where that is the
          correct solution"; the export a PROJECTION of the store; an import is a SIBLING route,
          never a successor. Q1 A8.6 REWORDED (exported form = a projection; criterion unchanged)
          · Q2 (b) reconcile-and-tell · Q3 Next:N one field two positions, said · Q4 fixed
          positions · Q5 order asserted at ingest, never depended on by the pass · Q6 YES —
          "in-line is an ID pointer; the free-hand text is derived from a lookup table; that
          keeps the instruction line predictable and repeatable": route notes stored
          `NoteID → content` in the EDITOR too; A4.2 reworded, its "which world" mutation
          ANSWERED (referenced); migration via A8.4's hook. SEQUENCE recorded: DESIGN picks the
          data model up AFTER a peer data-store audit and prior-art review. → A11.1a/A11.1c ·
          A8.6 · A4.2 · adaptor `routeNote` · model §2 · basis. IMPACT moved: routes.lua
          SetRouteNote/noteKey · store.lua RouteNoteTable · smoke A4 block · the no-free-text
          smoke (new) · the NAMES table (new, with A8.4's migration walking it — G9).

    RI-16 DRAINED (Battlewrath, 2026-08-18) — (a) YES: the RUNTIME LOOKUP lands BEFORE the
          first fold — one lookup function over one CONSTANT table on the UI side (`code →
          user`), pass-through on a miss; ROLE_TEXT + SENSE_TEXT retire into it; A5.1/A5.2 smoke
          rows filled. Not a deviation (A10.2a orders folds among themselves — the brief's
          omission, Analyst's). (b) fails A5.3 outright. (c) provenance = a tooling item that
          FOLLOWS (generate the constant from driver_adaptor_table.md; A5.3's 1:1 check is the
          guard until then). → A10.2 PRECONDITION line; A5.1/A5.2 unchanged in wording.
          Same turn, on the row model: A CHILD COMPLETES WHEN ALL ITS ACTION TABS HAVE
          COMPLETED — a CONSTANT, no control (note fired + kill pending = not complete; the
          ordinal does not hand off). → model §2 · NEW A2.7.

    RI-14 DRAINED (Battlewrath, 2026-08-18): keep the HEADSTONE in routes.lua; the acceptance
          composition lives ONCE at the CALL LAYER, outside routes.lua, swept by the smoke
          (A1.2's invariant covers every site that goes through it). No source-text scanner.
          `<Noun>Of` accessors stay pure; a composer IN routes.lua would be the branch renamed.

_Items above leave entirely once every record named carries them._
