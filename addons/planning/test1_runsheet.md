# `/dr armdev` — DEV CAPTURE RUN SHEET

_The dev capture profile (§248–§250, verb-based since §264). **Four walks have now run from this
sheet across two dungeons** — the procedure at the foot is unchanged; what grew is the reference
material above it._

⚠ **This file was restructured §268.** Reference material had been wedged between steps 2 and 3,
breaking the numbered spine. Setup and history now sit ABOVE the procedure, and the procedure runs
0→5 unbroken. Nothing was dropped.

---

## ★★★ THE REFERENCE PINS — KEEP THESE, THEY ARE THE EXPERIMENT

    /dr testpin -96.28 2145.02 144.92 33      SFK, last boss room
    /dr testpin  -4.27  -35.85  -21.83 389    RFC, end of the chasm

⚠ **A pin is not run scenery, it is the independent variable.** Two runs against different
references cannot be differenced, and the second one looks fine until somebody tries. Reuse the
exact line above for the map you are in.

★ **RFC's pin sits 0.18 yd from where test2 ENDED** and 418.7 yd from where it started (measured
against the landed corpus, not eyeballed).

**SFK — established 2026-08-17**, the last boss room of the keep (Battlewrath, with a screenshot).
⚠ **A correction worth keeping visible:** this sheet claimed the SFK walk was *"a MONOTONE APPROACH
— a clean spread from maximum range down to ~0."* **The data says the opposite.** test1's row 0 is
the pin itself at `sd = 0`, running out to 264 and ending at 152. It was a departure and a wander,
never an approach — and the whole reason test4 had to exist is that **no capture contained an
approach at all** until it did. ★ A chat-era characterisation written into a stable doc, where a
reader would trust it *because* it was in the doc rather than the transcript.

## ★★ THE FOUR WALKS — what each one actually isolates

                      pin INSIDE            pin OUTSIDE
        SFK   (33)    test1  ts 2/4         —
        RFC  (389)    test3  ts 2/4         test2  ts 0 on all 1,386 rows
                      test4  the approach

⚠⚠ **test1 and test2 differ in TWO things at once** — the dungeon AND the pin — so on their own
they cannot say whether `ts = 0` is caused by the cross-map pin or by something about Ragefire.
That was asserted from those two runs alone; a correlation with the variables tangled. **test3
changes only the pin, and settles it: the pin.**

★ It paid twice — two RFC walks share a coordinate space, so **test2 and test3 can be differenced**.

★★ **test4 is the approach, and the method is the transferable part.** All three earlier walks
pinned at the player's feet and walked *away*, so the flip had only ever been observed outbound.
test4 armed at the far end and came in — **with a deliberate stop/start gait**, which is what broke
the last confound: at constant speed, distance and elapsed time move together, so a state change
could be *"crossed 5.5 yd"* or *"N samples after crossing"* and nothing distinguishes them. Varying
the speed separates them. Four crossings in, four out.

**Recipe, for any future edge you need to bracket:** slow down through the boundary (the bracket is
speed × sample interval — at 0.2 s and 7 yd/s it is 1.4 yd wide, and walking halves it), cross
decisively rather than loitering on the line, and cross **several times in both directions** — one
crossing cannot tell a threshold from a latency.

---

# THE PROCEDURE

## 0. Confirm you are on the new build — two seconds

    /dr testpin

**Prints coordinates** → you are on the new code, carry on.
**"Unknown command"** → the files are deployed but the client is running the old build.
⚠ `/reload` does NOT load new addon code on this account. **Close the client fully and relaunch.**

## 1. Clear the dungeon

Ordinary play. Nothing to arm — a cleared dungeon is what makes the walk a clean path rather than a
combat record.

## 2. Set the reference pin

Reuse the line for your map from the table above. To establish a **new** reference instead:

    /dr testpin

★ **It prints the coordinates and a reusable command. KEEP THAT LINE** — and put it in the table
above, or the next run of that map has nothing to be comparable with.

⚠ Put it somewhere the walk produces a spread of ranges. The entrance is trivially reproducible; a
mid-map point gives a wider spread. Either is valid, as long as it is written down.

## 3. Arm the profile

    /dr armdev <anyname>

Chat should say: **`dev capture <name> - 0.2s sampling + held tracker pin`**

★ **§264: the mode is in the VERB.** `/dr arm <anything>` is always the product path; `/dr armdev
<anything>` is always the dev capture. ⚠ The old form matched on the NAME, which cost `test1` as a
usable label and made a run's name load-bearing. Any name works now.

⚠ **If it says `(pin NOT set)` — stop and report it.** `SuperTrackerUtil` refused, the calibration
pair will be absent, and the record means something different from what was planned.

## 4. Walk the map

★ **Vary the PATH, keep the PIN.** The path is what the transit metric gets measured over, and one
route through a map is a fixture where two are a finding.

⚠ **Include every floor change** where the map has them. SFK has seven; RFC is one throughout.
⚠ There is no in-instance boundary to cross (§250) — one dungeon, one instance, one coordinate
space. Do not go looking for one.

## 5. Close it out

    /dr stop
    /reload

Then land it — **the plain watcher or `[2] Pull once` does it** (§265):

    py addons/landing/pull.py once        (or just leave the watcher running)

⚠ **Temporary by intent** (Battlewrath, 2026-08-17): *"We'll turn it off when out of the heavy dev
loop now."* If `sweep: True` has gone from the `dungeonrun` row, use `once --source dungeonrun` —
the form that works either way.

---

## ⚠ THREE WAYS TO WASTE THE TRIP, all of them SILENT

    re-pin mid-run       one record, two conditions, and no marker saying where they split
    arm before zoning    mixes the states in one record and neither half is clean
    wrong map            THE CLIENT WILL NOT TELL YOU. test2 proved it accepts a cross-map
                         pin without a word and then reports 1,386 confident zeros

★ The third is the one to check by hand, because it is the only failure here that looks exactly
like success from inside the game.

## Worth knowing before you start

- **The pin takes your quest arrow** for the duration. `/dr stop` clears it. (F24: our position
  outranks quest and nothing in the client's flow hands it back — so the clear is the contract.)
- **0.2 s sampling is ~5× the points.** A twenty-minute walk is roughly 6,000 samples. Fine, but it
  is not a normal-sized record.
- **Any name works** (§264) — the dev profile comes from the verb, so `/dr arm test1` is still the
  ordinary product path.

## What these captures have answered

    H3     0.2 s corpus - decimated at the desk, reconstruction error MEASURED (W4)
    H0-b   the calibration pair: engine distance beside a target we know
    H5     the divergence data, which is the same pair read differently
    H1     the floor row - seven floors, no divergence
    §244   SUPER_TRACKED_POSITION carries mapID/x/y/z - so the tracker is readable
           agnostically and /dr testpin drops from necessary to convenient
    B3     the declined state with its OWN capture: 1,386 rows, not 57 borrowed
           from the satnav probe
