# PRIOR ART — storage and transfer formats with a read instruction set

_Addons bench, 2026-08-19 (§379). A FINDINGS file: sourced, directs nothing. The second half of
the sequence in `driver_sense_acceptance.md` A11.1a — **Battlewrath: "and then look to PRIOR WORK
that is industry standard. Information storage and transfer with a read instruction set isn't a
unique issue."** The first half is `audit/peer_data_stores.md` (§377); the three questions it
raised are banked as **RI-20**, and this file is the picture to decide them against._

⚠ **This half is SOURCED, not measured.** The peer audit read installed code on this machine;
this one reads published specifications. Every claim below carries its source, and where a spec
and our situation differ the difference is stated rather than smoothed.

---

## 0 · THE HEADLINE — the research MOVES one of the three

    P1  VERSION       ★★★ REFRAMED. "Does the line need a version?" is the wrong question.
                      It is THREE jobs, and the industry does them with three mechanisms.
    P2  BOUNDS        ★ CONFIRMED and given a method: the range is stated FIRST, the field
                      width is DERIVED from it. We have no stated range to derive from.
    P3  NON-FINITE    ★★ THE EXPERIMENT ALREADY RAN, in public, for a decade. Rejecting is
                      fine. Rejecting WITHOUT A STATED BEHAVIOUR is what made the mess.

---

## 1 · P1 — "a version field" is three different jobs

### 1a · The three, and who does which

    IDENTIFY   is this our format at all?
               PNG's 8-byte signature · CBOR tag 55799 · draft-main-magic's advice

    VERSION    which revision of the format is this?
               WeakAuras `!WA:2!` · GPX `version="1.1"` · .NET resource header

    EVOLVE     can an old reader survive a new writer without either?
               Protocol Buffers - and it has NO VERSION MARKER AT ALL

★★★ **Protobuf is the finding, because it is the counter-example.** The wire format carries no
version anywhere. A field's tag is `(field_number << 3) | wire_type` — a NUMBER, not a position —
and the wire type tells a parser the payload's size without understanding its meaning, so
**"old parsers [can] skip over new fields they don't understand."** Evolution comes from
skippability, not from a discriminator.

★★★ **Which gives the actual rule, and it is about OUR shape rather than about versions:**

> **A POSITIONAL format cannot skip an unknown field — it has no way to know where the field
> ends — so it cannot evolve by skippability, and therefore it MUST carry a version.
> Tag-length-value formats can, and therefore need not.**

⚠ **Our line is positional.** So is GatherMate's, and GatherMate has no version — that is the
defect the peer audit spotted, and this names *why* it is one rather than just noting the absence.
WeakAuras' payload is serialised (skippable at the AceSerializer layer) **and** versioned, which
is belt and braces, and it is the format that survived being revved.

### 1b · IDENTIFY is a separate job with its own published advice

`draft-main-magic-00` is the IETF's guidance and it is worth reading against `!WA:2!`:

    magic numbers SHOULD be 8 octets, at offset zero, randomly selected and filtered:
    no adjacent identical octets · >=50% with the high bit set · >=75% outside printable
    ASCII · not a valid UTF-8 substring · the octet-REVERSE meets the same criteria

and it warns specifically against meaningful ASCII: a magic like `!<arch>` is criticised because
*"by definition the magic number test can be satisfied by a plain ASCII text file."*

⚠⚠ **BUT THE ADVICE IS FOR FILES AND OUR STRING IS PASTED**, and I will not extend it past that.
WeakAuras cannot use a high-bit magic — its export is typed into a chat box and a forum post, so
every octet must survive as printable text. **Ours has the same constraint as theirs, not as
PNG's.** The draft's *placement* rule (offset zero) and its *"specify the exact sequence of
octets"* rule transfer; its byte-selection criteria do not.

★ And CBOR shows the two jobs cleanly separated: tag 55799 is a pure identifier that **adds no
semantics at all** — *"the semantics of the tag content enclosed in tag number 55799 is exactly
identical to the semantics of the tag content itself"* — chosen so its bytes *"will never be found
at the beginning of a JSON text."* Identification, deliberately carrying no version.

### 1c · ⚠ AND PNG'S SIGNATURE DOES A THIRD JOB WE HAD NOT CONSIDERED — transfer corruption

The eight bytes are not only identification. Per the PNG rationale, each byte catches a specific
mangling:

    byte 1  non-ASCII, high bit    catches transfers that CLEAR BIT 7
    2-4     "PNG"                  names the format
    5-6     CR LF                  "catches bad file transfers that alter newline sequences"
    7       ^Z                     stops display under MS-DOS
    8       LF                     "checks for the inverse of the CR-LF translation problem"

★★ **That is directly ours.** A route string is going to be pasted through a chat client, a
Discord message, a forum, and a text editor — and this repo is CRLF. A newline-translating or
whitespace-trimming round trip is the likeliest corruption our format will ever meet, and nothing
in the working model would notice it. ⚠ **Filed as an observation, NOT as a proposal** — GatherMate
carries no checksum either, and whether it is worth a byte is a decision, not a finding.

★ PNG also puts a **CRC on every chunk** rather than one on the file, *"in order to detect
badly-transferred images as quickly as possible. In particular, critical data such as the image
dimensions can be validated before being used"* — validate before use, per unit, not per file.

### 1d · The one place a POSITIONAL format does get skippability

The .NET resource header pattern: magic → version → **a byte count to skip past the header** →
version-specific content. A length prefix buys a positional format exactly one skippable region.
★ Worth knowing because it is the minimum change that makes our line extensible without going
tagged — and it costs one field.

---

## 2 · P2 — the bound comes FIRST, and the width is derived from it

Google's Encoded Polyline Algorithm is route geometry in a pasteable string, which is our problem
almost exactly. Its stated reasoning:

> *"Given a maximum longitude of +/- 180 degrees to a precision of 5 decimal places (180.00000 to
> -180.00000), this results in the need for a 32 bit signed binary integer value."*

★★★ **Read the order of that sentence.** The RANGE is stated, the PRECISION is stated, and the
width is a CONSEQUENCE. GatherMate does the same thing from the other end — it clamps to 0.9999
because the packed width was chosen first. Both formats know their bound.

⚠ **We do not have one.** P2's bench read (bound POS/R/Band at input) is confirmed as the industry
method, and the gap is unchanged and now sharper: **the bound is a measurable fact about this
client that nobody has gone and measured.** Until it exists, no width, no packing and no
fixed-format decision can be made honestly.

★ **And polyline carries a technique we have not discussed: DELTA ENCODING.** *"To conserve space,
points only include the offset from the previous point."* Consecutive route points are near each
other, so the deltas are small and the varint chunking makes small numbers short. ⚠ It costs
random access — you cannot read row 40 without reading rows 1..39 — which for a driver that walks
in order may be free and for a recovery beacon that must be reachable out of order is not.
**Named, not proposed.**

---

## 3 · P3 — the experiment ran in public, and the lesson is not "reject or represent"

    JSON      REJECTS. RFC 8259: values "such as Infinity and NaN are not permitted"
    CBOR      REPRESENTS. major type 7, additional info 25/26/27, non-finites included

★★★ **And JSON's rejection is the cautionary tale, not the model.** Because the grammar excludes
them and the spec says nothing about what a writer should DO on encountering one, the
implementations each invented an answer:

    raise an error
    emit `null`            - ECMAScript. VALID JSON, and the value is unrecoverable: Infinity,
                             -Infinity, NaN and null all become the same token
    emit the token anyway  - Python, by default, producing INVALID JSON
    emit a string          - "+Infinity", "NaN"

⚠ Three incompatible behaviours from one omission, still causing interoperability problems.

★★ **So P3's bench read (a) survives but is INCOMPLETE.** "The format cannot express it" is not a
decision; it is half of one. The other half is **what the writer does when handed one**, and that
has to be stated or every writer will pick differently — which for us means the exporter and any
future tool, and they will disagree silently.

★ CBOR's counterpart advice is the same shape from the other side: if you DO allow it,
*"the protocol needs to pick a single representation, typically 0xf97e00."* **Both specs agree
that the failure is ambiguity, not the choice.**

---

## 4 · THE READ INSTRUCTION SET — DWARF's line program is the closest prior art there is

Battlewrath's phrase was *"a read instruction set"*, and DWARF's `.debug_line` is literally one: a
compact byte program, walked by a small state machine, that reconstructs a table of positions.

    REGISTERS   addr · file · line · column · flags (is_stmt, basic block, prologue/epilogue)
    HEADER      opcode_base · line_base · line_range · min_inst_length
                + the DIRECTORY and FILE tables, referenced BY INDEX
    PROGRAM     special opcodes (one byte, packing BOTH an address advance and a line
                increment) · standard opcodes · extended opcodes (variable length)
    EMIT        a row is emitted at a special opcode; the sequence ends at DW_LNE_end_sequence

★★★ **Three things it independently confirms about our model:**

    1  THE NAME TABLES BELONG IN THE HEADER AND ARE REFERENCED BY INDEX. DWARF's program
       never carries a filename - it carries a file INDEX into a header table. That is
       RI-18's names index and the note table, reached by a format designed in 1992.

    2  THE HEADER CARRIES THE CONFIGURATION THE PROGRAM IS READ AGAINST. opcode_base and
       line_range are not data, they are the terms the instruction stream is interpreted
       under. ⚠ Our line currently has nowhere to put such a thing.

    3  A ROW IS EMITTED BY THE PROGRAM, not stored. The table is the OUTPUT of a walk. ★
       Which is exactly `Stage:Step` being composed rather than stored (proposition §3),
       one layer further along.

⚠ **What does NOT transfer:** DWARF is a compiler artifact written once and read by tools. Ours is
hand-authored in an editor and read by a driver at runtime, so density that costs legibility buys
us much less than it buys a debugger. **The structure transfers; the compression does not** — the
same sentence as GatherMate's packing in §377.

---

## 5 · ROW ORDER — GPX makes it schema-enforced

RI-18 Q5 / proposition G6 asks whether row order is part of the format. GPX answers it for its own
case: *"Waypoints, routes and tracks must be written in that order to be valid against the XML
Schema."* ★ Order is part of the contract **and is machine-checkable**, which is the bench read
(*"part of the format and ASSERTED ON INGEST"*) with a precedent behind it.

★ GPX also carries `version="1.1"` as a document attribute — a route-interchange format that chose
to version, and whose version has not moved since 2004.

---

## 6 · WHAT THE BENCH DOES NOT TAKE FROM THIS

⚠ Stated so the file cannot be read as a shopping list:

    · NOT proposing a checksum, a magic number, delta encoding, or a binary form. §1c, §2 and
      §1d are things the field does, presented so a decision has alternatives - not advice.
    · NOT proposing a header. §4's point 2 is a GAP OBSERVED (we have nowhere to put a term
      the line is read under), not a design.
    · NO view on the version token's SHAPE. RI-20 P1 said the research half would inform it,
      and what the research says is that the SHAPE follows from which of the three jobs it is
      doing - which is a question for the designer, not a byte pattern for the bench.
    · The bound in §2 is still UNMEASURED. This file did not go and get it.

---

## 7 · SOURCES

    Encoded Polyline Algorithm   developers.google.com/maps/documentation/utilities/polylinealgorithm
    Protocol Buffers encoding    protobuf.dev/programming-guides/encoding/
    CBOR                         RFC 8949 (rfc-editor.org/rfc/rfc8949.html)
    JSON                         RFC 8259
    PNG rationale                libpng.org/pub/png/spec/1.2/PNG-Rationale.html
    Magic numbers                IETF draft-main-magic-00
    DWARF line programs          swatinem.de/blog/dwarf-lines/ (secondary; DWARF std is primary)
    GPX                          topografix.com/gpx/1/1/gpx.xsd

⚠ The DWARF entry is a SECONDARY source read against the standard's own vocabulary, not the
standard itself. Flagged because everything else here is primary.

---
_Sourced 2026-08-19. Nothing here rules. RI-20 is the item; this is the picture._
