# Reconciliation inbox — DRAINED, in full

_Moved out of `addons/planning/Reconcile_inbox.md` on 2026-08-19 at Battlewrath’s direction:
**"Too many competing thoughts / statements degrade the utility of the planning files. It’s where
we settle what is true."** ⚠ **HISTORY — read for WHY, never for WHAT to build.** Every item here
is settled; the flattened one-per-item outcome lives in the inbox’s footer, and the records named
in each CITE are what govern. Nothing was deleted — the prose is here because some of the
reasoning (the frame-of-reference argument, the MAVLink correction, the float-drift and Lua
measurements) exists nowhere else._

---

## RI-20 · THE PEER AUDIT — three things our peers have that the working model does not

**RI-20 DRAINED (Battlewrath's direction, recorded by Opus 5 Analyst, 2026-08-19).** The peer
audit's three questions landed in the heading, `driver_data_model.md`: **P1** de-prioritised as
A17 (no V1, no installed base, and the escape hatch exists by construction) · **P2b** CLOSED
(precision follows the configured minimum radius) · **P2a** CARRIED FORWARD to §B, still open and
narrowed to IMPORT — every numeric door became a selection, so the input half dissolved · **P3**
the non-finite question sits with P2a, same shape. ★ The corroborations and the prior-art working
are §C and the `audit/` files. ⚠ Nothing here directs a build any more; the heading does.

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


---

## RI-21 · DESIGN INPUTS from the prior art — an INVENTORY, not a question

**RI-21 DRAINED (Battlewrath's direction, recorded by Opus 5 Analyst, 2026-08-19).** It was never
a question — it was the inventory of what the field does. **Absorbed whole**: the techniques
weighed and not taken are `driver_data_model.md` §C, recorded once so nobody re-runs the
comparison; D1 (transfer corruption has no detector) and D13 (an absent version IS a version)
became seeds **S1** and **S2** in §D. ★ The rest were confirmations of choices already made.

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


---

## RI-23 · POS IS A NODE CHARACTERISTIC — so what is the unit of independent readability?

**RI-23 DRAINED (Battlewrath's direction, recorded by Opus 5 Analyst, 2026-08-19).** Every question
in it was answered: the NODE is the unit that must stand alone · stage 0 / step 0 = always
eligible · beacon stages WHOLE ONLY, child ordinals the author's choice · nothing auto-updates,
the editor EXPOSES and never nags · every numeric door is a selection and the absence is a TICK ·
the selector shows the store and derives nothing. → heading §A3, A10.3e, DRIVER_BASIS positions.
⚠ Two pieces of BENCH WORK it surfaced are seeded rather than lost: **S5** (the ordinal picker
has no mint and no gap function) and **S7** (`AddBeacon` forces a stage).

_Filed 2026-08-19 (§385) by the **Addons bench**, from Battlewrath's observation: **"We hold POS
inline. But structurally POS is a character of the BID / CID as their self pointing (All lures). We
removed pointing out to non-self closing positions."** ⚠ The observation is CORRECT and MEASURED
below. What it opens is bigger than POS._

### What was measured (routes.lua, 2026-08-19)

**The store is already node-major.** Position lives on the NODE, not on a row:

    routes.lua:735    AddChildHere mints { mapX, mapY, x, y, z, mapC, mapZ, mapID, floor }
    routes.lua:342    AddBeacon refuses a node with no mapX - "unplaceable; refuse rather
                      than store a ghost"
    routes.lua:1210   setReach(p, radius, up, down) - REACH is on the node too
    routes.lua:1028   RowsOf(child) -> child.rows - the rows HANG OFF the node

★ **So the flat line is what disagrees with the store, not Battlewrath with the model.** The store
already holds POS, R, Band and Stage as node characteristics with rows as a child list; flattening
to one line per row is what creates the repetition.

### ★★ AND IT IS NOT A WRINKLE — IT IS MOST OF THE LINE

    MapID : RID : Stage : Step : BID : CID : POS : R : Band : Next:N : Sense : action : trigger : arg
    └──────────────── ROUTE / NODE CHARACTERISTICS: 11 slots ─────────────────┘ └── THE ROW: 4 ──┘

**Eleven of fifteen slots repeat on every row of a node.** RI-18 Q2 and the proposition's G3 named
this for `Next:N` alone and asked whether a mismatch should be reconciled or ignored. ⚠ **The real
scope is ten more fields, and POS is the largest** — three-to-five numbers, repeated per row.

★ **And "all lures" is what makes it clean.** A2.6 removed pointing-out (`supertrack` now points at
the node's OWN position — *"the only place it can name"*), so **there is no case where a row needs
a different position from its node.** No exception to carry, which is what would make hoisting
safe.

### ⚠ THE COUNTER-ARGUMENT, which must be on the table before this looks obvious

**The repetition is what buys OUT-OF-ORDER READABILITY.** A self-contained line can be read alone.
Split into node-records and row-records and a row is meaningless without its node record — which is
**sequential dependence through the back door**, the exact currency `audit/prior_art_execution.md`
§4 found modal state and delta encoding both spending, and which always-listen recovery priced out.

★ So the duplication may be **load-bearing rather than sloppy**, and that has to be settled before
anything moves.

### ★★★ THE QUESTION, which is sharper than "should POS be hoisted"

> **What is the unit that must be INDEPENDENTLY READABLE — the node, or the row?**

    a  THE ROW. Every line stands alone; node characteristics repeat and that is the price.
       ★ the working model as drawn · ⚠ 11 of 15 slots repeat, and can disagree with
       themselves (G3), so import must reconcile or silently pick one

    b  THE NODE. A node record carries address + POS + R + Band + Stage + Next; row records
       carry only `Sense:action:trigger:arg` and their node's address.
       ★ the store's own shape, no invention · ⚠ two record kinds - RI-18 Q2(c), which the
       bench previously read AGAINST on "two line shapes, not one"; that objection is much
       weaker now that the split is ten fields rather than one

    c  THE NODE, COMPOSED AT EXPORT. Store node-major (as now), EMIT row-major (as drawn).
       ★ costs nothing structurally - it is the projection §4 of the proposition already
       accepts, and Stage:Step already works exactly this way
       ⚠ and it does NOT reduce the line at all; it only stops the repetition being a
       STORAGE fact. The disagreement-with-itself problem (G3) is then an EXPORT BUG rather
       than a data state, which is a real improvement but a smaller one than it sounds

**Bench read (marked as the bench's, overturnable in a word): the question decides itself from the
RECOVERY RULE, and the bench does not know the answer.** Battlewrath, 2026-08-18: the driver
*"will need to know to always listen to update beacons (no order, doesn't exist), otherwise
recovery can't be done."* ⚠ **That says BEACONS must be findable out of order. It does not say a
ROW must be interpretable cold.** If recovery is node-addressed then (b) is free and (a) is paying
for a property nothing uses. ★ But the bench will not read a ruling that specific out of one
sentence — **this is the instance, on screen, for a decision.**

⚠ **And (c) is available regardless of how (a)/(b) goes**, because it is a projection choice rather
than a format choice. It is the cheapest thing here and the least committal.

    IMPACT
      on disk now      NONE. The store is ALREADY node-major - option (b) and (c) both
                       describe what routes.lua does today. Only the LINE is in question,
                       and no exporter exists.
      shipped guards   NONE break under any option. ⚠ And none would CATCH a wrong choice
                       either - there is still no export writer and no import reader.
      criteria         A11.1a's line (its field list is the thing under discussion) ·
                       RI-18 Q2 / proposition G3 (this SUPERSEDES their scope: not Next:N
                       alone but 11 fields) · G7 (POS and Band are compound - moot under (b))
      does nothing to  the sense rule · W1-W7 · the adaptor · the UI leg · the note tables ·
                       the reader/data split · RI-22's option bands

★ **One thing this does NOT reopen.** A2.6's removal of pointing-out is what makes the observation
true, and nothing here questions it — *"all lures"* is the property being relied on, not revisited.

### ★★★ THE WALK, WRITTEN OUT (Battlewrath, 2026-08-19) — and it ANSWERS the question above

> Right map · Right RID · Right stage · Right step
> — What BID · What CID · What POS · What R · What Band · Next N   **"All of these are stable, as
>   they are per node."**
> — What sense function · What Action function · What value   **"These need restating per line
>   because they are many tabs on one node."**

★ **That is option (b), written as a read order:** gate, resolve the node ONCE, then iterate its
rows. ⚠ (`Sense:action:arg` in his sketch dropped `trigger` — an old chat reference, corrected in
the same turn. **Trigger stays. The shape was the point.**)

#### ★★★ AND HIS OWN WALK SETTLES THE OPEN QUESTION — the STAGE GATE proves it

The question above was *"what is the unit that must be independently readable — the node, or the
row?"*, and the bench declined to read it out of one sentence. **The walk answers it structurally:**

    the walk gates  map → RID → STAGE → STEP  before it ever reaches a node
    a RECOVERY BEACON IS STAGELESS - so it CANNOT PASS A STAGE GATE

⟶ **Recovery cannot enter through this walk. It finds a NODE, directly.** So **the NODE is the unit
that must stand alone, and a row never needs to be interpretable cold.**

★★ **Which dissolves the counter-argument this item raised.** The duplication was defended as the
price of out-of-order readability; out-of-order readability is needed at the NODE, and a node
record has it. **The repetition is not load-bearing. (b) is free.**

#### ⚠ WHAT THAT EXPOSES — TWO ENTRY PATHS, and the walk as written is only one

    ORDERED PATH    map → RID → stage → step → node → rows        the walk above
    RECOVERY PATH   map → RID → node                              bypasses the stage gate

⚠ Either the walk has a **second door**, or the stage gate must read **"no stage = always
eligible"** — which is RI-18 Q5's sort-order rule (no-stage first · stage · step) doing **real
work** rather than being a tidiness convention. ★ That is worth knowing before Q5 is drained: its
answer is not about tidiness at all, it is what makes recovery reachable.

#### ⚠ AND THE STATE OF DISK, so nobody plans against a thing that is not there

`routes.lua:345`, in `AddBeacon`, verbatim:

> *"⚠ ALWAYS A STAGE. See SetStage's note: the stageless RECOVERY beacon has no path in through
> here either. Owed, no impact yet."*

**The stageless beacon is DESIGNED AND NOT BUILT** — `AddBeacon` forces a stage today. ★ Whichever
way the walk resolves, that is the gap it lands on, and it is now load-bearing for the format
rather than an owed nicety.

#### The size, which is the smaller reason

    FLAT   a node with three tabs = 3 rows × 14 slots            = 42
    SPLIT  11 node slots once + 3 rows × 3 row slots             = 20

★ Less than half. ⚠ **But the stronger reason is not size** — it is that under (b) **eleven fields
can no longer disagree with themselves**, which is RI-18 Q2 / G3 stopping being a question at all
rather than being answered.

    WHAT MOVED
      the open question   ✓ ANSWERED by the walk's own gate order: the NODE is the unit
      the counter-arg     ✓ DISSOLVED - out-of-order readability is a NODE property
      RI-18 Q2 / G3       ✓ MOOT under (b) - no repetition, nothing to reconcile
      RI-18 Q5            ⚠ PROMOTED - sort order is what makes recovery reachable, not tidiness
      proposition G7      ⚠ still live (POS and Band are compound) but now inside a node record
      NEW, on disk        ⚠ the stageless recovery beacon is DESIGNED, NOT BUILT (routes.lua:345)

### ★★★ STAGE 0 / STEP 0 = PERMISSION TO READ IT (Battlewrath, 2026-08-19)

> *"Stage O / step o is permission to read it."*

★ **That removes the second door and replaces it with a VALUE.** One walk, one gate, no special
case: stage 0 always passes, stage N passes when the run has reached N. ★★ And a value is better
than an absence for the reader — an ordinary comparison already handles it, where an absence is a
test the reader must remember to make.

#### What was MEASURED against this (routes.lua + Lua 5.1.5, 2026-08-19)

    SetStage(b, 0)                -> 0      ★ WORKS TODAY. `tonumber(0)` is TRUTHY in Lua,
                                             so the `if not v` guard passes it through.
    AddBeacon(id, node, 0)        -> stage 0  same reason - `tonumber(stage) or NextStage(id)`
    NextStage(id)                 -> starts at n=1 and walks UP; it can NEVER mint 0

★★ **So 0 is RESERVED BY CONSTRUCTION, not by convention** — the mint cannot produce it, and the
setter accepts it. ⚠ And it corrects the scope of the `routes.lua:345` note filed one turn ago:
that comment is about a **stageless** (nil) beacon. **Stage 0 has a path in and always did.**

#### ★★ STEP ALREADY CARRIES THIS RULING — but as `nil`, not `0`

§311, ruled and shipped (`routes.lua:541`):

> *"The child ordinal (Not stage) gates children who are IN a ordinal, to their ordinal. But
> children who are NOT in the ordinal are still listened to."*

with `child.ordinal = nil` commented *"out of the line, on purpose"* (`:566`).

★ **The semantics Battlewrath just named are ALREADY RULED at the step level.** What differs is the
ENCODING, and the difference is reported rather than smoothed:

    STORE   nil    §311's shape. "No ordinal" is naturally an absence, and OrdinalOf
                   returns nil today.
    LINE    0      ★ BETTER on a positional line: an empty slot is AMBIGUOUS - missing,
                   absent and truncated all look alike (RI-18 Q4's "empty means absent").
                   `0` is unambiguous.

⟶ **nil in the store, 0 on the line, one meaning: no gate, always eligible.** ★ Same composing law
as `Stage:Step` (proposition §3) — the store keeps the shape that cannot rot, the line gets the
form the reader can parse. **No conflict with §311; it is a projection, and §4 already accepts
projections.**

#### ⚠ THE DOOR IT OPENS — a reserved value with no guard at the input

If 0 means *always readable*, then **an author typing `0` into the stage field gets a recovery
beacon by accident.** `NextStage` protects the MINT; `SetStage` does not protect the TYPING —
`SetStage(b, 0)` is accepted with no comment.

⚠ **Same class as RI-22's reach door** (`tonumber("1e400") -> Inf` through the shipped radius box):
a value with special meaning, and no guard where a person can enter it. ★ Two instances now, in two
different fields, both at the editor's mouth rather than at the driver's end — which is the shape
RI-20 P2a is circling.

**Bench read (marked as the bench's): this is a UI/input question, not a format one.** The format
wants 0 to mean what it means; the editor wants to not hand it out by accident. ⚠ Filed, not fixed
— it belongs with RI-22's door and P2a rather than being solved here.

    WHAT MOVED
      the two entry paths   ✓ RESOLVED - one walk, one gate; 0 passes always
      routes.lua:345        ⚠ SCOPE CORRECTED - the owed gap is the STAGELESS (nil) beacon;
                            stage 0 is reachable today through AddBeacon and SetStage
      RI-18 Q5             ✓ ANSWERED IN SUBSTANCE - "no-stage first" is stage 0 sorting
                            first naturally; the sort order stops being a separate rule
      §311                 ⚠ UNCHANGED and now cross-referenced: same semantics, and the
                            store keeps `nil` while the line carries `0`
      NEW                  ⚠ a reserved value with no input guard - second instance of the
                            unguarded-door shape, filed against RI-22 / P2a

### ★★ THE STAGE RANGE, SET (Battlewrath, 2026-08-19)

> *"And we just set a range. 1-999 (decimal included) number only."*

★ **One move, four effects:** it excludes 0, so the reserved value cannot be TYPED (the door named
in the turn above) · it excludes negatives · it bounds the field's width at three integer digits ·
and *"decimal included"* keeps **insertion between stages without renumbering**, which is
fractional indexing and is the reason a bare integer ordinal is painful to author against.

#### ⚠ MEASURED — the decimal part has a ceiling, and it is silent

Fractional indexing degrades: every midpoint insertion into the same gap costs a bit of mantissa.
Lua 5.1 numbers are doubles, so this is exact and measurable rather than a worry. Run on
`.tools/lua51`, 2026-08-19:

    repeated midpoint insertion between stage 1 and stage 2
      insert  1 -> 1.5
      insert 10 -> 1.0009765625
      insert 30 -> 1.0000000009313226
      insert 50 -> 1.0000000000000009
      insert 53 -> 1              ★ COLLAPSED - no representable value between them

⚠ **And it fails SILENTLY** — the new stage simply equals its neighbour. No error, no red; two
stages that are the same number, which is the class of fault this project keeps finding.

#### ★★★ BUT IT DISSOLVES, and the reason is already in the model

`Stage:Step` are **COMPOSED AT EXPORT** (`driver_data_model_proposition.md` §3, and §382's landing).
★ **So export is a natural renormalisation point:** fractional stages are an AUTHORING
convenience, and the exported line can carry clean ordinals. **Decimals never leave the editor.**

⟶ The 53-insert ceiling applies only to a live editing session, in one gap, which no route will
approach. ★ **Nothing to build and nothing to guard** — it is a consequence of a choice already
made, which is worth recording precisely so nobody later "discovers" it and designs around it.

⚠ **One thing that IS worth stating in the record:** if `Stage` were ever stored on the line as
authored rather than renormalised, the ceiling comes back and comes back silently. **The
renormalisation is load-bearing, not cosmetic.**

#### ⚠ AND THE RANGE HAS NO GUARD TODAY — third instance of the same missing thing

`routes.lua:1483` `SetStage(b, n)` is `local v = tonumber(n)` and nothing else. Measured: it
accepts `0`, `-5`, `0.5`, and `1e400` alike. **1-999 is the DECISION; the door is still open until
something enforces it.**

    RI-22   the reach boxes    tonumber("1e400") -> Inf, stored          (§383)
    §385c   the stage field    0 typed -> a recovery beacon by accident
    HERE    the stage field    -5 · 0.5 · 1e400 all accepted; no range

★★ **Three instances, three fields, one missing thing: a guard at the EDITOR'S MOUTH.** ⚠ And they
are not three problems — RI-20 P2a asks exactly this question at the format level, and the answer
to it is the answer to all three. **Filed together deliberately; fixing them piecemeal would be
three guards with three shapes.**

    WHAT MOVED
      the reserved-0 door   ✓ CLOSED IN DESIGN by the range - ⚠ NOT in code; no guard exists
      stage field width     ✓ BOUNDED - three integer digits, which is the first bounded
                            numeric field in the model (cf. RI-20 P2, still open for POS)
      fractional insertion  ✓ MEASURED (53 deep, silent) and ✓ DISSOLVED by export-time
                            renormalisation, which is now LOAD-BEARING rather than cosmetic
      NEW                   ⚠ nothing - this is the THIRD instance of the P2a door, not a
                            fourth problem

### ★★★ THE BUILDER (Battlewrath, 2026-08-19) — and the type question hiding under it

> *"1.1 valid. 1.12 invalid. 1.2.3 — Or we give a builder. For 1, it offers 1.1 or 2. For 2 it
> offers 2.1 or 3. For 2.1 it offers 2.2 or 3."*

#### ★★ TAKE THE BUILDER REGARDLESS — it DISSOLVES the guard question for stage

**You cannot type an invalid value if you do not type.** The builder offers the two legal moves —
*go deeper* or *go next* — and the author never needs to know the numbering law.

★ **Same move as radius going to a pre-config menu** (§381c), so it is consistent rather than a new
mechanism, and it is the flatten-decisions rule doing the work: *reduce decision load, encode the
rule, never add a choice.* ⚠ It also removes the §385d instance of the unguarded door **for stage**
— it does NOT touch RI-22's reach boxes, which are a separate door and stay open.

#### ⚠ BUT THE THREE LINES CARRY A TYPE DECISION THE BUILDER DOES NOT SETTLE

    1.1 valid / 1.12 invalid   reads as A NUMBER, one decimal place
    1.2.3                      reads as A PATH, arbitrary depth

⚠ **And the builder as described EXCLUDES `1.2.3`**: for `2.1` it offers `2.2` or `3` — never
`2.1.1`. So the three lines are not fully consistent, and the inconsistency is the question rather
than an error.

**Measured (`.tools/lua51`, 2026-08-19), because the two types differ in ways that bite:**

    AS A NUMBER   tonumber("1.10") == tonumber("1.1")  ->  true
                  ⟶ 1.1 .. 1.9 is NINE slots between majors, then nowhere to go
    AS TEXT       "1.10" < "1.9"  ->  true
                  ⚠ lexical order is WRONG; a path needs component-wise comparison

★ **Nine is REACHABLE**, unlike §385d's 53-deep float ceiling — a long stage that accretes
sub-steps could plausibly want a tenth.

#### ★★★ BUT THE CAP STOPS MATTERING, for the same reason the float ceiling did

⚠⚠ **THE AUTOMATIC REBALANCE IS WITHDRAWN (RI-23 ruled, Battlewrath 2026-08-19): *"we don’t
auto-update."*** The builder never renumbers on the author’s behalf, at either level. The cap
still stops mattering — by `x.xx`’s 99 slots at the child level and by beacons being whole —
but not by anything renumbering itself.

**When the builder runs out of room in a gap, it RENUMBERS — and export renormalises anyway**
(`Stage:Step` composed at export, proposition §3; §385d). A rebalance costs nothing downstream
because the exported line was never going to carry the authored numbers.

⟶ **The cap is an EDITOR-SIDE EVENT, not a format constraint.** The number type survives and no
third level is needed.

⚠ **One thing a rebalance does touch and it is not nothing:** it moves stage numbers under an
author who may have them written down, screenshotted, or spoken aloud to a group. ★ Which is
exactly what the NAMES index is for (RI-18) — **the author's handle is the name, the number is the
system's** — the §374 face/meta split reaching a second field. **Filed as an observation.**

#### The choice, in form

    a  NUMBER, one decimal place, ~~builder REBALANCES when a gap fills~~ [⚠ WITHDRAWN
       (RI-23, 2026-08-19): nothing auto-updates; the author renumbers or does not]
       ★ nothing in code moves - NextStage, used[] and StageMatches are all numeric today
       ⚠ a rebalance renumbers stages under the author (mitigated by names, above)

    b  PATH, arbitrary depth (`1.2.3`), builder offers a third level
       ★ unlimited nesting, no rebalance ever needed
       ⚠ moves NextStage, used[] and StageMatches off numbers · needs component-wise
         comparison everywhere · ⚠ and "1.10" < "1.9" is the classic fault waiting for
         whoever sorts it as text

    c  NUMBER, one decimal, NO rebalance - nine sub-stages is simply the limit
       ★ simplest of all; ⚠ a hard authoring wall with no way past it, and the author
         meets it with no warning

**Bench read (marked as the bench's, overturnable in a word): (a).** ⚠ Not because (b) is wrong —
it buys real nesting and some routes may want it — but because (a) changes NO code, and the thing
that makes it safe (export renormalisation) is already a property we depend on for a different
reason. (c) is rejected on the wall: an authoring limit the author discovers by hitting it is the
same shape as a green that means less than it looks like.

    WHAT MOVED
      the stage guard      ✓ DISSOLVED for stage - a builder cannot emit an invalid value.
                           ⚠ RI-22's reach boxes are UNAFFECTED and still open.
      §385d's range        ✓ ENFORCED BY CONSTRUCTION rather than by validation
      the 9-slot cap       ✓ MEASURED and ✓ DEFUSED by rebalance-plus-renormalisation
      NEW                  ⚠ a rebalance renumbers under the author - which is what the
                           NAMES index already answers (§374's split, second field)
      NAMED, not decided   ⚠ NUMBER vs PATH - the three lines disagree and the builder as
                           described excludes 1.2.3

### ✓ THE FORM SETTLED — `x.xx` (Battlewrath, 2026-08-19)

> *"So for this side of input. x.xx — What gives 1 through 1.99 which is plenty affordance."*

★ **This settles the NUMBER vs PATH question named in the turn above: it is a NUMBER, two decimal
places.** `1.2.3` is out. ⚠ And it supersedes the earlier *"1.12 invalid"* — that was one decimal
place, revised after the nine-slot measurement. Recorded as a refinement, not a contradiction.

**Measured (`.tools/lua51`, 2026-08-19):**

    1.01 .. 1.99   =  99 slots between majors      ★ THE affordance number

★ Against §385e's nine, which was reachable. **Ninety-nine is not** — and the rebalance path
(§385e) still exists behind it if a gap ever fills, so there is no wall.

#### ★★ ONE IMPLEMENTATION CONSTRAINT, and it fails SILENTLY

**The builder must CONSTRUCT the value from integer parts. It must never ACCUMULATE.**

    1.0 + 0.01 x99            ->  1.9900000000000009      == 1.99 ?  FALSE
    (major*100 + minor)/100   ->  1.99                    == 1.99 ?  true

⚠ **An adding builder produces a "1.99" that does not compare equal to a re-parsed or rebuilt
1.99.**

⚠⚠ **AND THE STAKES ARE NOT WHAT THIS ITEM FIRST SAID.** It was filed as "StageMatches would miss a
collision" — wrong, because **a shared stage is not a collision to prevent.** Battlewrath,
2026-08-19: *"Both can sit on the same. It's author to get wrong rather than us validating the
input."* ★ **Which is already RULED AND SHIPPED**, and the bench should have read it before
writing the constraint up:

    routes.lua:613   "it REPORTS a collision and never prevents one (§90, S4 tell-and-trust)"
    routes.lua:614   "Two children on one ordinal is authorable - THEY SIMPLY GATE TOGETHER"
    routes.lua:628   "two beacons may share a stage (StageMatches says so and refuses nothing),
                      so a path can be ambiguous and THE CALLER IS TOLD RATHER THAN LIED TO"

★★ **And his flow argument is the WHY the code never recorded.** Forbidding duplicates would make
a stage change into: find the occupant → move it up → come back → fill the void. Allowing them makes
it: both sit on the same → promote one above. **One in-place move instead of a detour**, which is
the flatten-decisions rule applied to an authoring gesture rather than to a menu.

★★★ **SO WHAT THE FLOAT DRIFT ACTUALLY BREAKS IS ADDRESSING, AND IT IS WORSE THAN A MISCOUNT.**
`Routes.ChildAt` (`routes.lua:632`) parses an address like `1.99:3` with `tonumber` and matches
`b.stage == stage` (`:639`). A beacon holding `1.9900000000000009`:

    · is UNADDRESSABLE - no typed path can ever reach it
    · does NOT GATE WITH ITS TWIN - which is the exact flow above, silently not working

⚠ Same class as everything else this leg has found: not a red, a plausible wrong — but pointed at
a workflow rather than at a report.

#### ★★★ AND THE FORM IS THE VALIDATOR (Battlewrath, 2026-08-19)

> *"Agreed but we just said it is x.xx. 1.9900000000000009 is improper on every count."*

★ **Correct, and it is a stronger statement than the one above.** If the form IS `x.xx` then
`1.9900000000000009` is not a DRIFTED STAGE — **it is not a stage.** So the owed thing is not a
discipline the builder must remember; it is that **the form is a STATED PROPERTY and therefore
ASSERTABLE.** The builder becomes one way of satisfying it rather than the thing being trusted.

⚠⚠ **BUT THE OBVIOUS CHECK IS VACUOUS**, measured on `.tools/lua51`:

    ("%g"):format(1.9900000000000009)     ->  "1.99"     ★ identical to the good value
    ("%.2f"):format(1.9900000000000009)   ->  "1.99"     same

**A check built on how the value DISPLAYS sees nothing and passes forever.** ⚠ That is the exact
shape this project keeps finding — §322's dead registrations, A4.2's tests that passed in either
world, RI-19's aggregate reaching three bodies of five — and it is the check a person would write
first, because `%.2f` looks like it is testing two decimal places.

★ **Two that BITE, measured:**

    VALUE  v == tonumber(("%.2f"):format(v))
           1.99 true · 1.9900000000000009 FALSE · 1.005 FALSE · 1.5 true · 2 true

    FORM   the typed string against `^%d%d?%d?%.?%d?%d?$`
           "1.99" true · "1.9900000000000009" FALSE · "1.123" FALSE · "1" true · "1.5" true

★ **And the two tests are properly SEPARATE**: `"0.99"` passes FORM and fails RANGE. ⚠ Same
range-versus-precision split named for POS in §381b — second field, same shape, and worth keeping
as two checks rather than one so a failure says WHICH.

    WHERE THE CHECKS BELONG
      INPUT     form + range. ⚠ The builder makes this moot for authored stages - but an
                IMPORT or a paste path has no builder, and that is where it earns its place.
      VALUE     the round-trip. ★ Catches anything that arrived by ARITHMETIC regardless of
                route, which is the case the form-on-a-string test cannot see.
      ⚠ NEVER   by display. `%g` and `%.2f` both render the bad value as the good one.

#### ★★★ SIMPLER — A TABLE (Battlewrath, 2026-08-19), and it DISSOLVES the whole thread

> *"Or simpler. A table, 1 through 1.99. A user is offered one above whole or one above decimal,
> and the full list of anything seen. Then the gaps stand out."*

★★ **Every validation question above stops existing.** You cannot SELECT an invalid value — so form,
range, and float drift are not caught, they are **unreachable**. The two checks measured in the
turn above keep their place at IMPORT and lose it at input.

★ **And the offer is three things, so nothing is materialised:** the picker shows **next whole ·
next decimal · the used set**. The used set is the small part — and it is the part Battlewrath is
actually reaching for: ***"then the gaps stand out."***

⚠ **The bench first wrote this as "the 1..999.99 space is ~99,900 addresses". Battlewrath
challenged it and he is right to.** The arithmetic holds (999 majors × 100 hundredths) but it is
**the wrong number to put in a record**: it counts an enumeration nobody intends, and stating it
invites the next reader to picture a 99,900-row table when the whole point is that the table is
never enumerated. ★ **The number that matters is the one he gave: 99 slots between any two
majors.** That is the affordance claim; the product of it is noise. ★★ **That is LEGIBILITY, not validation.** Seeing `1 · 1.1 · 1.5 · 2` makes the structure
of a route visible in the place where it is authored, which no amount of input guarding does.

#### ★★★ AND IT COMPLETES A PATTERN — there would be NO numeric input left

Every numeric door in the editor, enumerated (`object.lua`, 2026-08-19):

    stageBox              -> Routes.SetStage           :690    → this table
    ordBox / row.box      -> Routes.SetChildOrdinal    :842 :896 :1227 :1278
    setBox                -> Routes.SetChildStage      :1003   → this table (see below)
    radBox / upBox / downBox -> Routes.SetChildReach   :199    → the pre-config menu (§381c, RI-22)

**Five doors. Every one becomes a selection.** ★★ So **RI-20 P2a's INPUT half may dissolve
entirely** — the answer to the three unguarded doors filed across §383/§385c/§385d is not a guard,
it is that **there is nothing to guard**. ⚠ Marked as the bench's read: what remains of P2a is
**IMPORT**, where a hand-edited file has no picker — a different consumer, and one the VALUE
round-trip check above is exactly right for.

⚠ Free-text doors are unaffected and were never in P2a's scope: `nameBox`, `noteBox`, the outcome
field. They have no numeric property to violate.

#### ★★ `Set(N)` IS THE SAME PICKER

`setBox` (`object.lua:1003` → `SetChildStage`) is the **`Set(N)` escape on `Next`** — shown only
when `p.role == "set"` (`:466`) — and it names **a stage number**. ★ So it is the same table:

    the STAGE picker   offers where to PUT this node
    the Set(N) picker  offers where to JUMP to

★★ **And "the full list of anything seen" is not merely convenient for the jump case — it is
CORRECT for it**, because a jump target must be a stage that EXISTS. ⚠ Whereas the *put* case
needs "next whole / next decimal" precisely because it is creating one that does not. **Same
table, and the two halves of the offer split cleanly by which job it is doing.**

    WHAT MOVED
      the form/range checks  ✓ UNREACHABLE AT INPUT - kept for IMPORT, which has no picker
      the build constraint   ✓ MOOT - selection is by identity, never by arithmetic
      stage as an INDEX      ✓ third field after radius and band; consistent with §382's
                             config class rather than a new mechanism
      RI-20 P2a              ⚠ ITS INPUT HALF MAY DISSOLVE - five doors, all becoming
                             selections. Bench read; what remains is import.
      NEW                    ★ Set(N) and the stage builder are ONE PICKER, and the "used
                             set" half is what a jump target requires
      ★ the real win        gaps stand out. LEGIBILITY, which no input guard buys.

★ **Building from integers is exact across the whole range**, so the constraint costs nothing — it
only has to be WRITTEN DOWN, because the wrong version is the one that looks more natural.

#### Display

`object.lua` formats stage with `("%g"):format(...)`. Measured across the range:

    %g of 1.01 -> 1.01 · 1.99 -> 1.99 · 100.01 -> 100.01 · 999.99 -> 999.99

★ `999.99` needs five significant digits and `%g` supplies six, so there is a digit of headroom.
**No display change needed.**

    WHAT MOVED
      NUMBER vs PATH      ✓ SETTLED - a number, two decimals; 1.2.3 is out
      the 9-slot cap      ✓ SUPERSEDED - 99 per major, with §385e's rebalance still behind it
      "1.12 invalid"      ⚠ SUPERSEDED by x.xx; 1.12 is now valid. A refinement, recorded.
      duplicate stages    ✓ ALLOWED, and it was ALREADY RULED (§90, S4 tell-and-trust,
                          routes.lua:613/628). ★ The FLOW is the new part: both sit on the
                          same, then promote one above - one in-place move, not a detour.
      NEW, and it is a    ⚠ THE BUILDER MUST CONSTRUCT FROM INTEGERS, NEVER ACCUMULATE - or a
      BUILD CONSTRAINT      drifted stage is UNADDRESSABLE by ChildAt and does not GATE WITH
                            ITS TWIN. Owed to whoever builds it.
      display             ✓ NOTHING TO DO - %g covers the range with a digit spare

### ★★★ ANALYST READ — Opus 5, 2026-08-19 (marked as mine, overturnable in a word)

_Read against §385c–§385i. **The selection move is right and I am not arguing with it** — five
numeric doors becoming pickers is the flatten-decisions rule doing exactly its job, and "the gaps
stand out" is a better reason than any of the validation reasons it replaces. What follows is four
things measured in `routes.lua` that the turn did not reach, one of which is a correctness fact
rather than a design choice._

#### 1 · ~~FRACTIONAL STAGES AND THE SHIPPED PROMOTION ARITHMETIC ARE INCOMPATIBLE~~

⚠⚠ **RETIRED (RI-23 ruled, Battlewrath 2026-08-19): beacon stages are WHOLE NUMBERS ONLY.**
This measured the consequence of breaking an invariant that is now ruled to hold. It is NOT owed work.

`x.xx` exists to allow **insertion between stages without renumbering** (§385d, his words). The two
functions that resolve where a run goes next are shipped and say otherwise:

    routes.lua:1529   Routes.Outcome(b) = b.outcome or ((b.stage or 0) + 1)
                      "What satisfying this beacon promotes the index TO."
    routes.lua:1550   Routes.BeaconAt(id, index) - first beacon with (b.stage or 0) >= index
                      "at or above rather than equal ... lets an index land on 4 when the
                       route jumps from 3 to 7"

Compose them on a route with an inserted stage:

    stages 1 · 1.5 · 2      satisfy stage 1  ->  index := 1 + 1 = 2
                            BeaconAt(2)      ->  first stage >= 2  ->  STAGE 2
                            ⟶ STAGE 1.5 IS NEVER VISITED

★ **`+1` was correct precisely because integers had nothing between them.** "At or above" was built
to jump FORWARD over deleted gaps ({1,2,4}), and it does that well; it cannot land on a value
BETWEEN the one it left and the one it computed. **`x.xx` puts 99 such values in every gap.**

⚠ **Nothing is broken today and I want that stated plainly:** `BeaconAt` has no caller anywhere
(asklist §186, model :1266, mvp_scope :13) and the driver is unbuilt. This is a design fact that
becomes a defect the day the driver is written — **not a red, a plausible wrong**, and it is cheap
now and invisible later, because a skipped stage looks exactly like a route the author laid out
that way.

★ The shape of the fix is not mine to choose, but the shape of the CRITERION is stated so whoever
takes it has a target: *a stage authored between s and s+1 is visited after s* — which fails today
and would pass under a promotion that resolves the **next stage that EXISTS** rather than
`stage + 1`. ⚠ I have not written it into A2.x, because which way it resolves (fix the promotion ·
renormalise before the driver ever sees it · forbid insertion) changes the row's wording, and that
is a ruling not a rewrite. **Named, not landed.**

#### 2 · ~~"THE GAPS STAND OUT" IS COMPUTED BY A FUNCTION THAT CANNOT SEE DECIMALS~~

⚠⚠ **RETIRED AND INVERTED (RI-23 ruled, 2026-08-19).** Under whole-number beacons an INTEGER gap
list is the CORRECT gap list — `Routes.Gaps` is the shipped implementation of the *"expose a gap"*
half of the ruling, not a defect. ★ The CHILD side still has no gap function and no mint; that is
build work for the ordinal picker.

`Routes.Gaps` (`routes.lua:1507`) is the shipped thing the picker's third offer would reach for —
it already feeds the promoter beside the running order:

    for n = 1, math.floor(top) do   if not used[n] then ...   ★ INTEGER GAPS ONLY

★ So under `x.xx` it reports the gap at 3 and is blind to every gap between 1 and 2 — which is the
half of the range the fractional decision was made for. ⚠ **The legibility win he named is the one
part of §385h with an existing implementation, and that implementation answers the integer
question only.** Cheap to widen; expensive to notice later, because a gap list that is merely
INCOMPLETE reads exactly like a route with no gaps.

#### 3 · ⚠⚠ "STAGE AS AN INDEX, third field after radius and band" — I read this as a category error

§385h's WHAT MOVED puts stage in §382's **config class** alongside radius and band. Measured, stage
does not behave like either:

    routes.lua:1541   table.sort(... (x.stage or 0) < (y.stage or 0))      ORDERED
    routes.lua:1550   if (b.stage or 0) >= (index or 0)                    COMPARED
    routes.lua:1529   (b.stage or 0) + 1                                   ARITHMETIC
    routes.lua:657    ("%g:%g"):format(b.stage, child.ordinal)             ADDRESSABLE

★ **A radius index is opaque and resolves once; a stage number is ordered, compared, incremented
and typed into an address.** And §382's config class carries a specific consequence — *"the driver
ALREADY HAS THESE. Nothing goes on the wire"* — which is the opposite of stage, whose whole job is
to ship (`Stage:Step` composed at export).

⚠ **The word "index" is doing two jobs**, and RI-22 already caught this once and named it well:
*"does the STORE hold the index, or the resolved number?"* — the real question under (a)/(b)/(c),
which the options did not ask. §385h collapses the same distinction again for stage. **For radius
and band it is a genuine design call. For stage it is forced: the value stays a NUMBER in the
store, on the wire and in the address — only the INPUT becomes a selection.**

★ So my read is not that §385h is wrong about what to build; it is that one sentence in it would
hand the next builder a table lookup where an ordered number belongs. **Reported, per the one rule,
rather than edited into the bench's item.**

#### 4 · ⚠⚠ THE PICKERS HAVE NO WAY TO SAY "NONE" — and two doors need one

*"Every one becomes a selection"* enumerates five doors. Two of them have a load-bearing member
that is **not a number**, and neither is mentioned:

    ordBox -> SetChildOrdinal    routes.lua:565   n == nil or n == "" -> child.ordinal = nil
                                 ":566  out of the line, on purpose"
                                 §311 RULED AND SHIPPED: "children who are NOT in the ordinal
                                 are still listened to" - the UPDATE type, and the recovery
                                 mechanic at the step level
    stageBox -> SetStage         the STAGELESS beacon, routes.lua:345 "no path in through here
                                 either. Owed, no impact yet" - DESIGNED, NOT BUILT

★ **A picker can only express the values it lists.** §385h's enumeration gives `stageBox`,
`setBox`, and the three reach boxes a destination table and leaves `ordBox`'s unnamed — and the
ordinal is the one door whose empty value is already ruled, shipped, and commented *on purpose*.
⚠ Replace a free-entry box that supports clearing with a list of numbers and a legitimate authoring
state stops being authorable, silently and by omission.

★ §385c is the precedent for the right answer and it is a good one: **make the absence a VALUE**
(*"stage 0 / step 0 is permission to read it"* — "a value is better than an absence for the
reader"). The same move works at the input: **the picker's first offer is the absence**, named in
the author's words (an "always" / "any time" / "no gate" entry), and it projects to `nil` in the
store and `0` on the line exactly as §385c already ruled.

⚠ **What I am NOT doing here is choosing that wording** — the label is the naming pass's and the
author-facing word is his. I am naming that the domain of two pickers has an extra member and that
the enumeration currently omits it.

    WHAT I READ AS STILL OPEN AFTER THIS
      the promotion arithmetic   ✓ RETIRED 2026-08-19 - whole-number beacons ruled; `+ 1`
                                 is correct, nothing can hide between n and n+1
      Gaps' integer loop         ✓ RETIRED AND INVERTED 2026-08-19 - an integer gap list is
                                 the CORRECT one, and is the "expose a gap" half as shipped
      stage as an "index"        ⚠ REPORTED - stage stays a NUMBER; only the input is a
                                 selection. RI-22's store-vs-resolve question stands for
                                 radius and band, where it is genuinely open
      the pickers' domains       ✓ RULED 2026-08-19 - the absence is a TICK beside the
                                 picker with text saying why, never a 0 in the list (A10.3e)
      ✓ NOT REOPENED             the selection move · x.xx · duplicate stages · export
                                 renormalisation · the node as the readable unit (RI-23 (b))

**NEEDS ONE WORD (and it is the only thing here that waits on Battlewrath):** does the stage picker
offer **"no stage"** — the always-eligible recovery node — as a selectable entry? ★ Yes gives the
stageless beacon (`routes.lua:345`, designed and not built) its door in this design and makes
§385c's stage-0 projection reachable by authoring. No means recovery is authored somewhere else,
and that somewhere else is not yet named anywhere. ⚠ The other three findings above are the bench's
to take and need no ruling.

#### ✓ RULED (Battlewrath, 2026-08-19) — THE ABSENCE IS A TICK, NOT A LIST ENTRY

> *"Yes. It gives the offer to not be staged. Most likely a tick rather than in the drop down. With
> some surrounding text as why. Same with the child. As seeing 0 in the drop down is offering a self
> defeating choice."*

★ **The Analyst's open question is answered, and answered better than either option it named.** The
question was whether the picker offers "no stage" as an entry; the answer is that the offer EXISTS
but does not belong in that control at all. ★★ **The reason generalises past this field:** a list of
stage numbers is a list of places in an order, and `0` is not one of them — it is the statement that
this node has no place in the order. **Two different acts, two different controls.**

⚠ **And it does not disturb §385c.** *"Stage 0 / step 0 is permission to read it"* was about what the
READER meets; this is about what the AUTHOR is offered. The projection is unchanged and now has
three faces, each right for its own consumer:

    AUTHOR   a tick, with text saying why        "not staged" / "not in the ordinal"
    STORE    nil                                 routes.lua:566, §311 - already shipped
    LINE     0                                   §385c - a value, never an empty slot

**Records reconciled the same turn:**
- `driver_ui_acceptance.md` **NEW A10.3e** — the pickers, the tick, why not in the list, the
  projection, the precondition, tests and mutations.
- `driver_sense_acceptance.md` A11.1a — the LINE's *"Step blank / Stage blank"* text SUPERSEDED
  and dated; step and stage carry `0`, never an empty slot.
- `DRIVER_BASIS.md` — positions list.

    WHAT REMAINS IN RI-23 (bench work; none of it waits on a ruling)
      ⚠ Routes.Outcome's `stage + 1` skips an inserted fractional stage (Analyst read §1)
      ⚠ Routes.Gaps counts in whole numbers only (Analyst read §2)
      ⚠ the stageless beacon still has no path in through AddBeacon (routes.lua:345) - now a
        PRECONDITION for A10.3e's stage half rather than an owed nicety
    ⚠ NOT STAMPED DRAINED for that reason - the ruling is recorded, the item is not empty.

#### ★★ THE TABLE, SKETCHED (Battlewrath, 2026-08-19) — grown, never enumerated

> *"I imagine it'll be — 1 (BID, CID) · 1.1 (CID, BID, CiD) — and we expand the table as needed.
> 1.1 to 1.9, 2.1 to 2.9. Rather than a full address table to 9.99 that will never be reached. It's
> there as a known affordance and so that we can have 2.9 5.9 and so on."*

★ **Two things, and only the first is settled.** The table is GROWN from what exists rather than
enumerated over the space — which is the same move as `Routes.Gaps` being bounded by the highest
stage in use (*"everything above that is not a gap, it is simply the next number"*, `routes.lua:1505`)
rather than by the range. **The `x.xx` form is an affordance the author can always reach, not a set
of rows anyone has to look at.**

**⚠ AND IT MAKES A PREVIOUSLY MINOR FINDING LOAD-BEARING.** `Routes.Gaps` is the shipped function
this table is made of, and it counts in whole numbers only (`for n = 1, math.floor(top)`, Analyst
read §2 above). ★ A grown table whose gap half cannot see a decimal shows the missing 3 and is
blind to every gap between 1 and 2 — **the half the decimals exist for.** It stops being a
tidy-up and becomes a precondition for this control.

**★ The offered STEP reads as a tenth, with hundredths as the insertion reserve** — nine offers
under each major, and `1.15` appearing only when someone needs to sit between `1.1` and `1.2`.
⚠ **Marked as the Analyst's reading of "1.1 to 1.9" against §385i's settled `x.xx`**, not as his
words. It is consistent: `x.xx` is the FORM (what is legal), a tenth is the OFFER (what is shown).
⚠ Likewise *"to 9.99"* is read as an illustration of enumerating the whole space, not a revision
of §385d's 1–999 range.

##### ⚠⚠ WHAT A STAGE ROW CAN HOLD — measured, and the two entries do not mean the same thing

The sketch puts a `BID` and a `CID` on one row. Measured in `routes.lua`, only ONE of them can be
*at* a stage:

    b.stage          BEACONS ONLY - :347 mint · :639 match · :1487 set · :1499 collide
    child.setStage   the CHILD's `Set(N)` TARGET, :1135 - and the file already flags the
                     collision of meanings at :1132 —
                     ⚠ "Stored on the CHILD, not resolved like an outcome - this is *you are
                        at N*, where a checkpoint's outcome is *advance to N*. §84 flagged that
                        both type a number and mean different things."

★★ **So a stage number is typed in three senses and the table would be showing at least two:**

    AT IT        a beacon whose `stage` is this number                  occupancy
    POINTS AT IT a child whose `setStage` is this number                an inbound jump
    LEADS TO IT  `Routes.Outcome` = stage + 1, resolved and never stored (not a table row)

~~★ If the table carries both kinds it is worth more than a picker — it becomes the only place that
shows what a renumber or a delete would break, which is exactly the silent breakage §84 named and
nothing on disk currently surfaces. ⚠ But the two must be distinguishable in the row, or "who is
here" and "who jumps here" read as one list.~~

##### ✓ RULED (Battlewrath, 2026-08-19) — IT IS AN INPUT SELECTOR, AND IT DERIVES NOTHING

> *"We don't derive value from the stage table. Just what their store is. So we have a mechanism to
> show that within a BID, Child 1 and 2 are both on 1.1. 1.1 can't be exclusive, if it is, every BID
> and CID needs its own table, which is exponential. This is just an input selector. What stage means
> and step means is in the broader context."*

⚠⚠ **THE ANALYST'S INFERENCE ABOVE IS STRUCK.** The dependency view was built from a true
measurement (`setStage` is the only stage number a child owns) and extended into a capability the
control was never asked to have. **A selector shows what is STORED on a number. It does not resolve
what points at it, and it does not carry the meaning of the number.**

★★ **AND THE NON-EXCLUSIVITY IS AN ARCHITECTURAL REASON, not a tolerance.** In his words: if `1.1`
were exclusive, *"every BID and CID needs its own table, which is exponential."* One shared,
non-exclusive value space is what lets **one selector serve every level** — beacons picking a stage,
children picking an ordinal — instead of a private numbering per node.

★ **And what the selector shows is a rule that is already ruled and shipped**, so the control is
surfacing existing behaviour rather than introducing any:

    routes.lua:613   "it REPORTS a collision and never prevents one (§90, S4 tell-and-trust)"
    routes.lua:614   "Two children on one ordinal is authorable - THEY SIMPLY GATE TOGETHER"
    routes.lua:628   "two beacons may share a stage (StageMatches says so and refuses nothing)"
    routes.lua:559   the ordinal's own comment: "Fractions are ordinary (3.1 between 3 and 4),
                     which is what makes insertion cost no renumbering"

⟶ *"Child 1 and 2 are both on 1.1"* is §90 at the ordinal level, and the table's whole job is to
**make it visible while authoring** — which is the same win as *"then the gaps stand out"*, and the
only win claimed for this control.

    SCOPE, so the row cannot grow one later
      SHOWS      the numbers in use and what sits on each, read from the store
      OFFERS     next whole · next decimal · the used set (Set(N): the used set only)
      DOES NOT   derive, resolve, warn, validate, or explain what a stage or a step MEANS -
                 that is the model's, not this control's

#### ★★ THE SELECTOR'S SCOPE, AND A LEAN ON WHOLE-NUMBER BEACONS (Battlewrath, 2026-08-19)

> *"So the selector needs to follow the BID child of, to look for same. I think the alternative is a
> stage table per. So children of the same BID can only ever appear there. And it keeps the parent as
> the identity filter.*
>
> *I am leaning that beacons (Parents) can only be whole numbers, and the 1.1, 1.2 or 1 2 3 4 are
> both valid for children. I just want to give the author choice. And making beacons only ever
> 1, 2, 3, 4 means making a new mechanism just for their use. where x.xx catches both."*

##### ✓ THE PARENT AS THE IDENTITY FILTER IS ALREADY THE SHIPPED SHAPE — nothing to invent

The two collision functions already differ in scope exactly as described:

    routes.lua:1496  StageMatches(id, stage, except)   scoped to the ROUTE - walks r.beacons
    routes.lua:616   OrdinalMatches(b, n, except)      scoped to the BEACON - walks
                                                       ChildrenAsMinted(b)

★ So *"children of the same BID can only ever appear there"* is not a table per node and not a new
rule — **it is the scope the ordinal's own function has always had.** One selector, one scope
parameter: route for a beacon's stage, parent for a child's ordinal.

⚠ **One thing the selector will need that does NOT exist:** there is no ordinal mint. `NextStage`
(`routes.lua:304`) walks `1, 2, 3…` for stages; there is **no `NextOrdinal`** — an ordinal is only
ever set explicitly. The picker's *next* offer has a shipped source on the stage side and nothing on
the child side. **Named so it is built rather than discovered.**

##### ★★★ THE LEAN HAS A CONSEQUENCE THE UI SIDE CANNOT SEE — three shipped functions already assume it

**Whole-number beacons is not a restriction to add. It is the invariant three shipped functions
hold today**, and each is correct if and only if no beacon sits between `n` and `n+1`:

    routes.lua:304   NextStage   n = 1; while used[n] do n = n + 1   ★ THE MINT CAN ONLY EVER
                                 PRODUCE A WHOLE NUMBER
    routes.lua:1507  Gaps        for n = 1, math.floor(top)          integer gaps only
    routes.lua:1529  Outcome     (b.stage or 0) + 1                  "promotes the index TO"

⚠⚠ **AND THAT RETIRES TWO OF THE ANALYST'S OWN FINDINGS, at the stage level.** Read §1 and §2 of the
Analyst read above: *Outcome skips an inserted fractional stage* and *Gaps cannot see a decimal*
were measurements of what breaks **when the invariant is broken** — not defects in the functions.
★ Under whole-number beacons both functions are right as written and there is nothing to fix.
**Recorded as a correction to my own findings, not as a defence of them.**

★ **And the child level costs nothing either way:** fractions are already blessed there
(`routes.lua:559` — *"Fractions are ordinary (3.1 between 3 and 4), which is what makes insertion
cost no renumbering"*), and **no ordinal arithmetic exists on disk** — no mint, no gap function, no
`+1`. Nothing to break.

##### ⚠ "A NEW MECHANISM JUST FOR THEIR USE" — measured against the selector as designed

The selector already takes a scope parameter (route vs parent, above). **Restricting the beacon
picker's offer to whole numbers is the same kind of parameter — which offers apply — on the same
control.** ★ One mechanism, two configurations, and the code already distinguishes the two cases.

⚠ **So the cost is not one-mechanism-versus-two.** It is:

    BEACONS WHOLE-ONLY   the three functions above stay correct · the beacon picker drops one
                         offer (a parameter) · ⚠ INSERTING A BEACON BETWEEN TWO BEACONS COSTS A
                         RENUMBER - which is the rebalance (§385e), mitigated by the names index
                         being the author's handle (§385f)
    BEACONS TAKE x.xx    one picker configuration everywhere · ⚠ Outcome AND Gaps must both
                         change, or an inserted beacon is SILENTLY SKIPPED by the run and
                         INVISIBLE in the gap list

★★ **Which puts the decision on one authoring question and not on the picker at all:** insertion
without renumbering is *the reason decimals were introduced* (§385d, his own words) — and at the
beacon level it is the only thing whole-number beacons take away.

    OPEN - one question, for Battlewrath
      Is inserting a NEW BEACON between two existing beacons, without renumbering the ones
      after it, something the author needs? ★ A child ordinal does not cover it - a child is a
      step under an existing parent, where this is a new place with its own children.
      ⚠ Yes  -> beacons take x.xx, and Outcome + Gaps are owed a change before the driver reads
               either (they are correct today only because nothing fractional can reach them).
      ⚠ No   -> the lean stands, all three functions are already right, and insertion is the
               rebalance with names carrying the author's handle.
      ⚠ Marked as the Analyst's framing of HIS lean, not a proposal either way. Nothing landed
        in A10.3e - the row still says "next whole · next decimal · the used set" for both.

#### ✓✓ RULED (Battlewrath, 2026-08-19) — WHOLE-NUMBER BEACONS, AND NOTHING AUTO-UPDATES

> *"Whole only I think. And we don't auto-update. We just expose to the user they have either a gap
> or a same. We don't want to baby sit someone working out the logical flow of things. That's
> nagging. We can offer assertions so the choice / guard is flattened. Or expose it with help text."*

**★ THE RULING, in three parts:**

    BEACON STAGES   WHOLE NUMBERS ONLY.   1 · 2 · 3 · 4
    CHILD ORDINALS  the author's choice.  1.1 · 1.2  or  1 · 2 · 3 · 4
    THE EDITOR      EXPOSES a gap or a same. It never renumbers, never corrects, never warns.

★★ **AND IT COSTS NOTHING TO BUILD, because it is what the code already does.** All three shipped
functions are correct exactly under this invariant, and the whole-only half needs no new guard —
`NextStage` (`routes.lua:304`) cannot mint anything but a whole number:

    NextStage   n = 1; while used[n] do n = n + 1      the mint IS the constraint
    Gaps        for n = 1, math.floor(top)             ✓ CORRECT, not integer-blind
    Outcome     (b.stage or 0) + 1                     ✓ CORRECT, nothing can hide between

##### ✓ WHAT THIS RETIRES — two of the Analyst's own findings, and one earlier mechanism

- **Analyst read §1 (Outcome skips an inserted fractional stage) — RETIRED.** It measured the
  consequence of breaking an invariant that is now ruled to hold. Struck in place above.
- **Analyst read §2 (Gaps counts whole numbers only) — RETIRED, and INVERTED.** Under whole-only
  beacons an integer gap list is the CORRECT gap list, and it is the shipped implementation of the
  *"expose a gap"* half of this ruling — already shown on the promoter beside the running order.
  ⚠ It remains true that the CHILD side has no gap function and no mint (no `NextOrdinal`); that is
  build work for the ordinal picker, not a defect.
- **§385e's automatic REBALANCE — WITHDRAWN.** *"We don't auto-update."* The builder never renumbers
  on the author's behalf, at either level. Marked in place at its two sites.

##### ★★★ "THAT'S NAGGING" — the manner is already ruled, and this extends it to the EDITOR

The bench's standing manners carry *nothing that nags (the note is PULLED, never pushed)* and
*nothing that judges (the driver informs, never grades)*. ★ Those were written for the DRIVER's
behaviour toward a player. **This applies the same posture to the EDITOR's behaviour toward an
author** — and the reason is his: *"we don't want to baby sit someone working out the logical flow
of things."* ⚠ Marked as the Analyst's connection between his words and the existing manner, not as
a new rule.

**The two sanctioned forms, in his words, and neither of them interrupts:**

    ASSERTION   "so the choice / guard is flattened" - the offer ENCODES the rule, so a wrong
                choice is not available to make. ★ This is what the picker already is: you
                cannot select an invalid stage because invalid stages are not offered.
    HELP TEXT   the state is VISIBLE and explained where it sits. Pulled, not pushed.
    ⚠ NOT       a warning, a colour that means error, a modal, a correction, or a renumber.
                A gap and a same are ORDINARY authoring states (§90, S4 tell-and-trust) and
                the editor's job is to make them legible, not to resolve them.

##### ⚠ ONE CONSEQUENCE, stated so it is chosen rather than discovered

Inserting a beacon between 1 and 2 now costs the author a renumber they perform themselves, and
nothing offers to do it. ★ That is the ruling working as intended — the alternative was the editor
moving numbers under someone who may have them written down — and the names index (§374's split)
is what carries the author's handle across it.

    WHAT MOVED
      beacon stages       ✓ WHOLE ONLY - already enforced by the mint; no new guard owed
      child ordinals      ✓ AUTHOR'S CHOICE - fractions already blessed (routes.lua:559)
      auto-renumber       ✓ WITHDRAWN at both levels (§385e's rebalance)
      Analyst read §1/§2  ✓ RETIRED - struck in place; Gaps INVERTS from defect to the
                          shipped implementation of "expose a gap"
      the editor's manner ✓ EXPOSE, never correct or nag - assertions or help text only
      still bench work    ⚠ no ordinal mint and no ordinal gap function exist for the child
                          picker · AddBeacon's stageless precondition (A10.3e)


---

## RI-25 · THE REFRAME — identity, characteristics, behaviours as separate records

**RI-25 DRAINED (Battlewrath's direction, recorded by Opus 5 Analyst, 2026-08-19).** Answered:
the export carries its identity chain IMPLICITLY — the address is the chain, there is no
ownership table · characteristics and behaviours are two record kinds · the driver is a pure RULE
plus a stateful SENSOR, which is where completion will live. → heading §A1, §A5; A11.3 reworded
with A11.3c/d; A11.2g and A11.4b. ⚠ ONE PIECE CARRIED FORWARD: whether behaviours NEST as a list
or sit as SIBLING records is the representation question **G5**, in §B — which now blocks two
things rather than one and is the next decision.

_Filed 2026-08-19 by **Opus 5 — Analyst**, from Battlewrath's reframe pass. **He asked for a
technical read and named himself not the final judge on it**, so this item is a judgement with its
evidence, not a summary of his words._

> *"MapID:RID:Stage:Step:BID:CID:POS:R:Band:Next:N(Type, arg):Sense:action:Trigger:arg*
>
> *I already raised that POS:R:Band:Next:N are characteristics. so maybe belong on a table next to
> their respective BID or CID. Sense:action:Trigger:arg are behaviours. So action tabs. Then as I
> understand we have a table for the Beacon=Child ownership. Where a child is constructed of BID:CID
> where BID is keyed to RID:BID and RID to MapID:RID. But that is opinion and this is a reframe /
> better model pass. (I am non-technical. So not exactly the final judge.)"*

### ✓ THE SPLIT IS NOT A PROPOSAL — it is what `routes.lua` already does

Measured, each line cited:

    IDENTITY       route keyed by RID          routes.lua:112  ⚠ and the RID is NOT stored inside
                   b.id = BID · c.id = CID     the record - "the key IS the identity, and a second
                                               copy is a thing that can disagree with the first"
    CHARACTERISTIC POS on the node             :735  AddChildHere mints the place
                   R / Band on the node        :1210 setReach(p, radius, up, down)
                   stage on the beacon         :347  · ordinal on the child :571
                   Next as role + setStage     :1125 child.role · :1135 child.setStage
    BEHAVIOUR      rows hang off the node      :1028 RowsOf(child) -> child.rows

★★ **So three of the four parts of the reframe are a description of the store, not a change to it.**
The only thing that ever disagreed was the flat LINE, which is what RI-23 already settled: the node
is the unit that must stand alone, and repetition was not load-bearing.

### ⚠⚠ THE ONE PART THE ANALYST WOULD DROP — the ownership table

> *"we have a table for the Beacon=Child ownership. Where a child is constructed of BID:CID where
> BID is keyed to RID:BID and RID to MapID:RID."*

**The chain is real. A TABLE for it is a second mechanism for a fact the ADDRESS already carries.**

    IN THE STORE   ownership is CONTAINMENT - children live inside b.children, beacons inside
                   r.beacons. There is no join to store; the tree IS the relationship.
    ON THE WIRE    ownership is the ADDRESS PREFIX. A record keyed `MapID:RID:BID:CID` states
                   its whole ancestry in its own key. Nothing else needs to say it.

★ **And the shipped precedent is already this shape:** the note table is
`RID:BID:CID:NoteID : content` (proposition §2, G1 as landed) — address-keyed, with no ownership
table beside it. The names index is the same. **An ownership table would be the only place in the
model where a relationship is stored rather than expressed.**

⚠ It would also be a thing that can disagree with the tree — the exact fault `routes.lua:112` names
for the RID and that A8.1's `StageOf` names one layer out. **Two mechanisms for one fact is the
pattern this arc has retired twice already** (`goTo` / `onRamp`, A2.6).

⟶ **Analyst read: TWO record kinds, not three.** A CHARACTERISTIC record and a BEHAVIOUR record,
both keyed by the address; the ownership chain is the key itself.

    CHARACTERISTIC   MapID:RID:BID:CID  :  Stage : Step : POS : R : Band : Next(Type, arg)
    BEHAVIOUR        MapID:RID:BID:CID  :  Sense : action : Trigger : arg      (N per node)

### ★★ THE COST THE UI SIDE CANNOT SEE — and it is already paid

**A normalised form cannot gate before it joins.** The flat line put `MapID:RID:Stage:Step` first
on purpose so a pass could skip a row without resolving anything. Split the records and the gate
fields live on the characteristic record, so something must be assembled before anything can be
skipped.

★ **It is already paid, and by a decision that predates this reframe:** A11.1a has ingest build an
index (`mapID → stage → ordinal buckets`) and the 1 Hz pass walk the BUCKET, never the lines. **The
join happens ONCE at ingest, not per sample.** So normalisation costs one pass over the file at load
and the runtime cost is unchanged. ⚠ Worth stating plainly because it is the objection a reader
raises first, and the answer is already in a governing row.

⚠ **And it removes a duplication question rather than answering it:** with Stage and Step living
once on the characteristic record, RI-18 Q2 / proposition G3 — *eleven fields repeating and able to
disagree with themselves* — has nothing left to be about.

### ✓ `Next:N(Type, arg)` reads as a BETTER statement of a ruling already made

`DRIVER_BASIS:181` rules Next is ONE field with values *Step · Stage · Set(N)*, and RI-18 Q3 landed
it as *"one field in two positions, said so in the format"*. ★ **`Next(Type, arg)` says the same
thing as a tagged value instead of as a positional convention** — the type carries the meaning and
the arg is present only for `Set`. ⚠ Marked as the Analyst's reading: it is the same ruling in
clearer words, not a new one. If it is taken, A11.1a's *"the writer emits the N slot empty for Step
/ Stage"* becomes unnecessary rather than wrong.

    WHAT THE ANALYST IS NOT SAYING
      ⚠ This does NOT reopen the store. The store is already node-major and needs no change;
        everything above concerns the EXPORTED form.
      ⚠ It does not settle the REPRESENTATION (proposition G5 - positional, serialised or
        keyed), which is a separate question and still open.
      ⚠ It does not touch the two side tables (NAMES, NOTES), the sense rule, or W1-W7.

    OPEN - one question, for Battlewrath
      Does the export carry the ownership chain EXPLICITLY, as its own table, or IMPLICITLY in
      each record's address key?
      ★ The Analyst's read is IMPLICIT - the address states the ancestry, the note and names
        tables already work that way, and an explicit table is the one structure in the model
        that could disagree with the tree it describes.
      ⚠ The case FOR explicit, stated so the choice is real: a reader wanting the roster of a
        beacon's children must otherwise SCAN for a prefix rather than look one up. ⚠ Whether
        that matters depends on G5, which is not decided - so this can wait for it.

### ✓ ANSWERED (Battlewrath, 2026-08-19) — IMPLICIT: each record carries its own identity chain

> *"Yes. It carries its own identity chain so that we can reconstruct it. But we're fine with tables
> where they put dynamic content into the instruction set. It's partly why I think POS and its
> friends should be look up. As in-line if a full range of -/+ and then whatever the total range is.
> Which could grow the characters in the line.*
>
> *So for me it makes sense it reads the gate, passes into the who, collects their needed details
> BID:CID on the map lives at X,Y,Z with a R of 10 and a height of 2.5 yards, as one collection, then
> proceed to what the behaviour is.*
>
> *Then the product is a test against X,Y,Z, R, Band and then function call on the behaviours with
> their args."*

★ **No ownership table. The address IS the chain, and reconstruction works from it** — which is the
shape the note and names tables already have. RI-25's open question is closed.

#### ★★ "POS SHOULD BE A LOOK UP" AND "CHARACTERISTICS ON THEIR OWN RECORD" ARE THE SAME STRUCTURE

⚠ **There is no second table to build here, and it is worth saying before one is.** A POS lookup
would be keyed by the node address and hold one position per node — **which is exactly the
characteristic record.** Each node has its own place; positions do not repeat between nodes, so
there is nothing for a separate table to de-duplicate. ★ He arrived at the split from a WIDTH
argument and it is the same structure the reframe already produced.

    UNDER THE FLAT LINE     POS written once per TAB - a four-tab node writes it four times
    UNDER THE SPLIT         POS written once per NODE

⚠⚠ **TWO SAVINGS, AND THEY MUST NOT BE CONFLATED.** The split removes the MULTIPLICATION (his
*"could grow the characters in the line"*, in its per-row form) — that is done. It does **not**
answer the width of a single coordinate: signed, unbounded world values. **That is still RI-20 P2's
frame-of-reference shape** (a min and a width derived per capture, §381b) and it is still open on
its rejection half (P2a). ★ Naming both so the split is not mistaken for having settled the bound.

#### ★★ HIS READ ORDER IS TWO READS, AND THE RECORD SHAPE MAKES IT SO

    gate  ->  who  ->  their details as ONE COLLECTION  ->  the behaviours

★ Under two record kinds the first three of those arrive **together**: the gate fields (Stage, Step),
the identity (the address key) and the characteristics all live on one record, so there is no lookup
between reading the gate and knowing whose it is. **The driver does two reads: the characteristic
set, then the behaviour rows of whatever passed.** His *"one collection"* is not something the driver
assembles — it is the record.

#### ⚠ A STEP NOBODY HAS NAMED — the collection is RESOLVED, the record is INDEXED

His collection reads *"a R of 10 and a height of 2.5 yards"* — **numbers**. But §381c / RI-22 made
the radius and band a PRE-CONFIG MENU, and §382 put them in the config class: the wire carries an
INDEX and *"the driver ALREADY HAS THESE."* Both are right at different layers, and the step between
them has never been written down:

    ON THE RECORD    R and Band are indexes into the driver's own config table
    IN THE COLLECTION they are the resolved numbers his geometry test needs

★ **So resolution happens ONCE, at ingest, into the collection — never per sample.** A per-sample
lookup would put a table read inside the 1 Hz pass for every node, which is the shape A11.4's cost
row exists to prevent. ⟶ **NEW A11.4b.**

⚠ **And it answers RI-22's still-open question from the consumer side.** RI-22 asks whether the
STORE holds the index or the resolved number; whatever the editor does, **the DRIVER holds the
resolved number**, because its geometry test cannot run on an index. That does not decide RI-22 —
the editor's retro-apply question is a different one — but it removes the driver from the argument.

#### ★★★ AND THE SPLIT MAKES A CORRECTNESS PROPERTY STRUCTURAL RATHER THAN A DISCIPLINE

> *"the product is a test against X,Y,Z, R, Band and then function call on the behaviours with
> their args"*

★ **One geometry test per node per sample, and every behaviour row of that node reads the same
result.** Under the flat line — one line per tab, each carrying its own copy of POS — testing
once per ROW is the natural implementation, and four tabs on one node would evaluate the same
geometry four times. ⚠ **Not merely wasteful: RI-16 ruled that a child COMPLETES when ALL its action
tabs have completed**, which requires every tab to agree about the same in/out transition. Four
independent evaluations of the same geometry is where they could disagree.

⟶ **The two-record split makes the shared evaluation the only expressible shape.** NEW **A11.2g**.

    WHAT MOVED
      RI-25's question    ✓ ANSWERED - implicit; the address is the chain, no ownership table
      "POS as a lookup"   ✓ IT IS THE CHARACTERISTIC RECORD - no second table to build
      the width saving    ✓ the MULTIPLICATION is gone · ⚠ the per-value bound is still
                          RI-20 P2's, and P2a is still open
      the read order      ✓ TWO reads - gate, who and details arrive on one record
      NEW A11.4b          ⚠ config indexes resolve ONCE at ingest, never per sample
      NEW A11.2g          ⚠ one geometry evaluation per NODE per sample, shared by its rows -
                          which is what RI-16's all-tabs-complete rule needs to be true

#### ⚠ CORRECTION ACCEPTED (Battlewrath, 2026-08-19) — it is as many reads as there are tabs

> *"I think on the stage:step gate, it collects the who and where, then keeps reading for their
> tabs. Which is as many reads as there are tabs. But the alternative is many tables. It could be
> argued behaviours live on the table with the BID:CID, flattening the instruction set. And neither
> currently solve ticking off all action tabs to progress the N."*

★ **The Analyst wrote "two reads" and that counted RECORD KINDS, not reads.** One characteristic
record plus one read per behaviour row is `1 + N`. His count is the right one.

##### ★★ BUT THE READ COUNT IS AN INGEST COST, PAID ONCE — it should not shape the format

A11.1a already rules that **ingest builds the index (`mapID → stage → ordinal buckets`) and the
1 Hz pass walks the BUCKET, never the lines.** So `1 + N` reads happen once per arming, over a file
of a few hundred lines, and never again. ⚠ **The thing worth optimising is per-SAMPLE work, and the
format does not touch it.** ★ Which means the choice below is free to be made on legibility and
safety rather than on read count.

##### ✓ NESTED vs SIBLING IS THE REPRESENTATION QUESTION (G5), NOT A MODEL DIFFERENCE

> *"It could be argued behaviours live on the table with the BID:CID, flattening the instruction set."*

    SIBLING ROWS   behaviours are their own records, keyed by the same address     1 + N reads
    NESTED LIST    behaviours are a LIST on the node's record                       1 read

★ **The MODEL is identical either way** — behaviours belong to the node, and both shapes say so.
What differs is the representation, which is `driver_data_model_proposition.md` **G5, still open**.
⚠ And the two are not equally cheap in every representation: a nested variable-length list is
natural in a keyed or structured form and is precisely the **variable-width unknown** that the
positional line cannot skip (RI-20 P1, and D10's MAVLink correction — a fixed-width generic payload
is skippable, a variable one is not). ⟶ **This is one more reason G5 is the next thing to decide,
and it is now blocking two questions rather than one.**

##### ★★★ THE REAL FIND — "neither currently solve ticking off all action tabs", and he is right

**Checked: `driver_authoring_acceptance.md` A2.7 specifies the RULE completely and never says where
the STATE lives.** It carries his own worked case — child 1, tab 1 *give the note*, tab 2 *on boss
killed → set stage*: stepping on fires the note and completes tab 1, the child is NOT complete, tab
2 stays armed while the sense holds, the kill completes tab 2 and then the node's Next fires. **And
the wipe case: tab 1 stays done (Trigger: One time), tab 2 re-arms on re-entry.**

⚠⚠ **That state cannot be recomputed from the current sample.** It survives leaving the region and
coming back, it is per TAB rather than per node, and it interacts with Trigger. **It is accumulated
state, and no record shape holds it** — because it is not stored data at all, it is a fact about a
run in progress.

★★ **AND THE ACCEPTANCE ALREADY SAYS WHOSE IT IS.** A11.3a rules the driver holds no route state:
*"no memory between calls beyond what the CALLER passes in (the previous sample; for `while` mode,
the in-set — W1.8's hysteresis is state the caller owns and hands back)."*

⟶ **So completion is the THIRD member of the caller's state, and the pattern for it already
exists.** The caller's object grows from *(previous sample, in-set)* to *(previous sample, in-set,
per-node per-tab done-set)*. **The driver stays pure; nothing goes in a record.**

    ✓ AND IT IS DELIBERATELY OUT OF V1, not overlooked. A11.8's WHAT IS OUT lists `completion`
      alongside stages, steps, the lock-out, recovery, the boss function and Next. So the gap is
      DEFERRED - but the home was never named, and an unnamed home is where V2 invents a store.

⟶ **A11.8 now carries the home** so the deferral is a pointer rather than a silence. ⚠ No V1 row
changes; nothing is built.

    WHAT MOVED
      "two reads"          ✓ CORRECTED to 1 + N - the Analyst counted record kinds
      the read count       ✓ REFRAMED - an INGEST cost, paid once; the 1 Hz pass walks buckets
      nested vs sibling    ✓ NOT a model difference - it is G5, and G5 now blocks two questions
      all-tabs-complete    ★ NAMED: accumulated per-tab state, owned by the CALLER (A11.3a's
                           existing pattern), OUT of V1 by A11.8, home now recorded there

#### ✓ THE OWNER, NAMED (Battlewrath, 2026-08-19) — A STATEFUL SENSOR INSIDE THE DRIVER

> *"I think it's a part of the driver. The part that completes the function calls and such.
> Basically the stateful sensor. It keeps a running inventory of the resolved position(Parameters),
> and checks against its tab set for completion. Ticking each off as they're met. And keeps open the
> items out of stage, or out of step (for its stage.)"*

⚠⚠ **THE ANALYST'S ANSWER OF ONE TURN EARLIER IS STRUCK.** I said the caller holds it, citing
A11.3a. ★ *"The caller"* is not an owner — it is the absence of one, and it pushed a real
obligation over a boundary where nobody had to meet it. **A component that can be built, reset and
tested is an answer; a role name is not.**

##### ★★ TWO LAYERS, and naming them SAVES the purity property rather than costing it

    THE RULE      point + segment + band. Pure. Same list, same samples, same answer.
    THE SENSOR    the armed object, INSIDE the driver. Holds the resolved parameter inventory
                  (A11.4b), the in-set, the two gate sets, and - at V2 - the per-tab ledger.
                  Calls the rule.

★ A11.3's heading said *"the driver holds no route state"* and **meant the rule**. Reworded in
place, dated, with the old sentence struck. Every purity test survives untouched, now aimed at the
rule directly rather than through the sensor — **which is what makes them mean anything**: run
through a stateful object, "call twice → identical" tests the object's bookkeeping, not the rule.

##### ⚠⚠ AND A STATEFUL SENSOR PUTS W7.1 AT RISK — the row that pays for it

`walk.py` is a PURE pass and the goldens were produced by one. **A stateful sensor graded against
them must reach a known state on demand and expose what it holds**, or a byte comparison starts from
an unknown point and proves nothing. ⟶ **NEW A11.3c**: resettable, readable, arm → fixture → read ·
reset → same fixture → byte-identical. ★ Cheap now, and the thing that makes the port gradeable at
all; expensive the day the sensor exists and cannot be rewound.

##### ★ "KEEPS OPEN THE ITEMS OUT OF STAGE, OR OUT OF STEP" — two sets, and it is the recovery rule

⟶ **NEW A11.3d**: the sensor holds the GATED set (nodes at the current stage / step) and the
ALWAYS-OPEN set (stage 0, and ordinalless children within their stage — §311, ruled and shipped).
★ **This is RI-18 Q5's sort order doing the work it was promoted for** — the always-open bucket is
built once at ingest and never re-tested against the gate. Test: advance the stage → the gated set
changes and the always-open set does not.

##### ⚠ ONE STALE LINE THE REWORD CREATED, and it was caught rather than left

A11.3's mutation read *"keep a module-level `last sample` → the double-call test diverges."* Under
the sensor model **holding the last sample is correct behaviour**, so the mutation asserted a fault
that is now a feature. Rescoped to the RULE in place. ★ Recorded because it is the exact class the
DRILL was run for: a reword that lands cleanly and leaves one sentence behind pointing the other way.

    WHAT MOVED
      the owner        ✓ THE SENSOR, inside the driver. The Analyst's "caller" struck.
      A11.3            ⚠ REWORDED - purity is the RULE's; heading and A11.3a dated in place
      NEW A11.3c       ⚠ resettable + readable, or W7.1 cannot be run against a pure desk
      NEW A11.3d       ⚠ two sets - gated, and always-open (the recovery mechanic)
      A11.3's mutation ✓ RESCOPED - it asserted a fault the new model calls correct
      staging          ✓ V1 ships the sensor with parameters + in-set; V2 adds the tab ledger
                       to the SAME object. Nothing enters a record either way.

---


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
