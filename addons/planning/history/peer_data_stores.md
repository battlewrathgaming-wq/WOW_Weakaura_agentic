# PEER DATA STORES — how the addons on this client store and transfer

> ⚠⚠ **HISTORY (moved 2026-08-20).** Battlewrath: *"Move them. Their more examples of the
> same text to infer seperately. Source of truth and pointers."* ★ **Read for WHY, never for
> WHAT to build** — the conclusions are `driver_data_model.md` §C (compared and NOT selected) and the basis's
> PEER AUDIT section.
> ⚠ It is here because it is FINISHED, not because it was wrong: a finished audit restating a
> conclusion is a second place an agent will read as current, and can drift from the one that
> governs.


_Addons bench, 2026-08-19 (§377). A FINDINGS file: measured, directs nothing. Filed because
A11.1a sequences it — **Battlewrath: "before that, we also model the data stores of our PEERS
through audit. And then look to PRIOR WORK that is industry standard."** So the line in A11.1a is
the WORKING MODEL these are measured against, not the design._

⚠ Read-only on the client throughout. Every number below is from the installed copy.

---

## 0 · WHAT IT CORROBORATES, AND THE THREE THINGS IT ADDS

**Corroborated independently by peers who never spoke to us:**

    gates in the KEY PATH, not tested per record      GatherMate2
    IDs, never names, in the payload                  GatherMate2 · WeakAuras
    a positional DELIMITED line for transfer          GatherMate2
    reader and DATA shipped as separate addons        GatherMate2 · Details · Skada · WeakAuras

**★ Three things they have and our working model does not:**

    1  A VERSION DISCRIMINATOR FIRST ON THE WIRE      WeakAuras: `!WA:2!`
    2  A CLAMP that GUARANTEES field width            GatherMate2: x,y pinned at 0.9999
    3  AN EXPLICIT NON-FINITE POLICY                  AceSerializer: serNaN / serInf / serNegInf

---

## 1 · GATHERMATE2 — the closest analogue, and it split the same way we plan to

`GatherMate2` (reader) · `GatherMate2_Data` (data) · `GatherHud` (a second consumer). Coordinate
records per zone — the same problem shape as a route's targets.

### 1a · STORAGE — the gates ARE the table path, and the payload is ONE integer

    GatherMateData2MineDB = {
        [28] = {              -- zone   (our MapID)
            [201] = {         -- node type ID  (an ID, never a name)
                710973000, 840981000, 980985000, ...
            }
        }
    }

★ **Nothing is ever asked "are you relevant?"** — zone and type are the key path, so the reader
indexes to the set it wants. That is the bucket-at-ingest idea already shipping, and it is why
their records need no gate fields at all.

★★ **And the payload is a packed integer** (`GatherMate2/LibMapDataExtract.lua:48`):

    EncodeLoc(x,y,level) = floor(x*10000+0.5)*1000000 + floor(y*10000+0.5)*100 + level
    DecodeLoc(id)        = floor(id/1e6)/10000, floor(id%1e6/100)/10000, id%100

x and y at four decimals, level 0–99, one number, **no delimiter and nothing to escape**.

⚠ **THE CLAMP IS THE TECHNIQUE WORTH TAKING**, not the packing:

    if x > 0.9999 then x = 0.9999 end
    if y > 0.9999 then y = 0.9999 end

A packed field only works if its width is guaranteed, so they *refuse the overflow at the door*
rather than hope. ★ Same instinct as reject-at-input, applied to a number.

⚠ **We cannot pack the same way, and the reason is worth stating so nobody tries:** their x,y are
NORMALISED map fractions (0..1) with a known bound. Ours are WORLD coordinates with a band and a
radius — unbounded, signed, and needing more precision. The *architecture* transfers; the packing
does not.

### 1b · TRANSFER — a positional delimited line, ids and numbers only

`DataShare.lua:25`, sending one node over AceComm:

    string.format("%d:%s:%s:%d", zone, tostring(id), nodeType, nodeid)

★★★ **That is our line's shape, reached independently** — colon-delimited, positional, four
fields, no free text, no escaping, because there is nothing in it that could contain a colon.

⚠ **And it carries NO VERSION and no checksum.** An old sender and a new receiver are
indistinguishable at read time. Recorded as a peer's OMISSION, not as a model — see §3.

---

## 2 · ACESERIALIZER — the general case, and the bug that argues for our choice

`dependencies/Ace3/wotlk-r960/AceSerializer-3.0`. The field's general answer to *"send an
arbitrary Lua value as text"*, and we ship a copy.

    ^   value separator
    ~   escape character
    ^^  end of serialized data

Escaping (`:34`): nonprints and space → `~` + `char(n+64)` · `^` → `~}` · `~` → `~|` · DEL → `~{`.

★★★ **And its history is the argument for banning free text from our line.** Line 37:

> *`if n==30 then -- v3 / ticket 115: catch a nonprint that ends up being "~^" when encoded... DOH`*

A general-purpose serialiser, used by the whole field for fifteen years, needed a **version bump
to fix an escape collision** — byte 30 encoded to `~^`, which the reader saw as an escape followed
by the terminator. ⚠ That is the class of bug that only appears with a payload nobody tested.

★ **Our working model never enters that class**, because the line has no free text to escape.
Battlewrath's *"nice-ness breaks down when you can break the reader"* has a worked example here.

⚠ **It also has an explicit NON-FINITE POLICY** (`:26`) — `serNaN`, `serInf`, `serNegInf` as
string constants. A11.2e already requires two Lua tests for this; the peer's answer is that NaN
and Inf are *representable* rather than rejected. **A difference to decide, not to copy.**

---

## 3 · WEAKAURAS — the transfer pipeline, and the version prefix

`WeakAuras/Transmission.lua`:

    serialize  →  LibDeflate:CompressDeflate  →  EncodeForPrint  (or EncodeForWoWAddonChannel)
    prefix     "!WA:2!"                       -- :275, ":288 version 2+: b64 prepended with !WA:N!"

★★★ **`!WA:2!` is the finding.** A version discriminator **first**, before any payload, and the
comment says what it versions: *"N is encode version"*.

⚠ **Note what it versions — the ENCODING, not the content.** Those are two different questions
and WA answers only the first on the wire; content versioning lives inside the serialised data.
★ Worth having as a distinction rather than a single "version" field, because they rev at
different rates.

★ And the pipeline order is the reusable part: **serialise, then compress, then encode for the
channel.** Compression before encoding, because encoding inflates and compressing an encoded
string wastes both.

---

## 4 · THE READER / DATA SPLIT — four teams, one answer

    GatherMate2      /  GatherMate2_Data       + GatherHud as a second consumer
    Details          /  Details_DataStorage    + nine other Details_* consumers
    Skada            /  SkadaStorage
    WeakAuras        /  WeakAurasArchive

★ Four independent teams reached the split Battlewrath ruled for Dungeon Run and Dungeon Routes,
and `data_model_findings.md` §6d measured the reason on our own file: **routes are 0.002 MB of a
4 MB store; the capture corpus is the weight.** The peers are the corroboration; the measurement
is the argument.

---

## 5 · WHAT THIS SAYS ABOUT THE WORKING MODEL

**Unchanged and now corroborated:** gates first and in the key path · ids not names · positional
delimited line · no free text · side tables the reader never opens · reader/data split.

**⚠ THREE GAPS IT EXPOSES, none of them a disagreement:**

    P1  NO VERSION ON OUR LINE. `MapID:RID:...` starts with content. WA puts `!WA:N!` first and
        GatherMate has none - one peer solved it, one did not, and the one that did is the one
        whose format survived being revved. ★ And WA's distinction is worth taking whole: the
        ENCODING version and the CONTENT version are different questions.

    P2  NO WIDTH GUARANTEE. GatherMate CLAMPS to make a packed field safe. Our POS is unbounded
        world coordinates - so if the line is ever fixed-width or packed, something has to refuse
        the overflow at the door rather than hope. ⚠ Today nothing bounds a coordinate at all.

    P3  NON-FINITE: REJECT OR REPRESENT? A11.2e says the driver REJECTS NaN and Inf.
        AceSerializer REPRESENTS them. Both are defensible - a driver has nothing useful to do
        with a NaN position, a serialiser must round-trip whatever it was handed. ★ The gap is
        that our answer is stated for the DRIVER and not for the FORMAT, and export/import are
        the ones that meet a hand-edited file.

---

## 6 · WHAT IS NOT DONE

**Prior art beyond this client** — the second half of Battlewrath's sequence. The techniques here
have names outside WoW (the name index is *string interning*; a fixed-shape line with an opcode
and typed operands is an *instruction encoding*; `!WA:N!` is a *magic number with a version*), and
the trade-offs we listed as gaps are well-travelled. Not yet surveyed.

---
_Measured 2026-08-19 from the installed client and from `dependencies/Ace3`. Nothing here rules._
