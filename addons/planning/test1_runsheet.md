# `/dr armdev` — DEV CAPTURE RUN SHEET

_The dev capture profile (§248–§250). One walk answers four open questions, so it is worth
getting right in one trip rather than three._

---

## 0. Confirm you are on the new build — two seconds

    /dr testpin

**Prints coordinates** → you are on the new code, carry on.
**"Unknown command"** → the files are deployed but the client is running the old build.
⚠ `/reload` does NOT load new addon code on this account. **Close the client fully and relaunch.**

---

## 1. Clear SFK

Ordinary play. Nothing to arm — a cleared dungeon is what makes the walk a clean path rather than
a combat record.

## 2. Set the reference pin

    /dr testpin

★ **It prints the coordinates and a reusable command. KEEP THAT LINE.** It is what makes the next
run of this map comparable with this one — same reference, same numbers.

⚠ Put it somewhere the walk produces a spread of ranges. The entrance is fine and is trivially
reproducible; a mid-map point gives a wider spread. Either is valid, as long as it is written down.

## ★★★ THE REFERENCE PINS — KEEP THESE, THEY ARE THE EXPERIMENT

    /dr testpin -96.28 2145.02 144.92 33      SFK, last boss room     (test1)
    /dr testpin  -4.27  -35.85  -21.83 389    RFC, end of the chasm   (test2 held SFK's,
                                                                       test3 holds this)

⚠ **A pin is not run scenery, it is the independent variable.** Two runs against different
references cannot be differenced, and the second one looks fine until somebody tries. Reuse
the exact line above for the map you are in.

★ **RFC's pin sits 0.18 yd from where test2 ENDED** and 418.7 yd from where it started
(measured against the landed corpus, not eyeballed). So a reversed test3 starts AT the pin and
walks away — structurally what test1 did in SFK, which is what makes the two comparable.

### ★★★ WHY THREE RUNS AND NOT TWO — the cell that was empty

                      pin INSIDE            pin OUTSIDE
        SFK   (33)    test1  ts 2/4         —
        RFC  (389)    test3  ← the ask      test2  ts 0 on all 1386 rows

⚠⚠ **test1 and test2 differ in TWO things at once** — the dungeon and the pin — so on their
own they cannot say whether `ts = 0` is caused by the pin being cross-map or by something
about Ragefire. I asserted the former from those two runs; that was a correlation with the
variables tangled. **test3 changes only the pin.**

★ And it pays twice: two RFC walks share a coordinate space, so **test2 and test3 can be
differenced** — the transit-metric prong the SFK plan wanted, arriving from a direction
nobody planned.

### ★★ THE SFK REFERENCE, established 2026-08-17

    /dr testpin -96.28 2145.02 144.92 33

**Shadowfang Keep, the last boss room of the keep** (Battlewrath, with a screenshot).
★ A good choice and worth saying why: the walk starts at the entrance and ends here, so the
whole capture is a MONOTONE APPROACH — a clean spread from maximum range down to ~0, rather
than a scatter that has to be binned before it says anything.

★★ **FOR A SECOND WALK, KEEP THE PIN AND VARY THE PATH** — the path is what the transit
metric gets measured over, and one route through a map is a fixture where two are a finding.

⚠ **Reuse this exact line for every later SFK run.** To reuse any pin: `/dr testpin <x> <y>
<z> <mapID>` with the numbers it printed.

### ⚠ THREE WAYS TO WASTE THE TRIP, all of them SILENT

    re-pin mid-run       one record, two conditions, and no marker saying where they split
    arm before zoning    mixes the states in one record and neither half is clean
    wrong map            THE CLIENT WILL NOT TELL YOU. test2 proved it accepts a cross-map
                         pin without a word and then reports 1,386 confident zeros

★ The third is the one to check by hand, because it is the only failure here that looks
exactly like success from inside the game.

## 3. Arm the profile

    /dr armdev test2        (or any name — the VERB picks the dev profile)

Chat should say: **`dev capture test2 - 0.2s sampling + held tracker pin`**

★ **§264: the mode is in the VERB now.** `/dr arm <anything>` is always the product path;
`/dr armdev <anything>` is always the dev capture. ⚠ The old form matched on the NAME, which
cost `test1` as a usable label and made a run's name load-bearing. Any name works now.

⚠ **If it says `(pin NOT set)` — stop and report it.** That means `SuperTrackerUtil` refused, the
calibration pair will be absent, and the record means something different from what we planned.

## 4. Walk the whole map — INCLUDING EVERY FLOOR CHANGE

★ The floor transitions are the point. Everything else on the list has been measured before;
**cross-floor tracker behaviour has not**, and it is the axis the reach band exists for.

⚠ There is no in-instance boundary to cross (§250) — one dungeon, one instance, one coordinate
space. Do not go looking for one.

## 5. Close it out

    /dr stop
    /reload

Then land it — **the plain watcher or `[2] Pull once` now does it.**

    py addons/landing/pull.py once        (or just leave the watcher running)

★ **§265 changed this and the old instruction is worth keeping visible.** It used to say
*"NOT with the plain watcher"* and gave `once --source dungeonrun`, because `stage: testing`
meant both *gitignored* and *excluded from the sweep* — one field for two guards. It still
lands in gitignored `staging/`; it is just swept now as well.

⚠ **Temporary by intent** (Battlewrath, 2026-08-17): *"We'll turn it off when out of the heavy
dev loop now."* If `sweep: True` has gone from the `dungeonrun` row, the `--source` form above
is the one that works — and it is the form that always works either way.

---

## What this one capture answers

    H3     0.2 s corpus - decimate at the desk, MEASURE reconstruction error
    H0-b   the calibration pair: engine distance beside a target we know
    H5     the divergence data, which is the same pair read differently
    H1     the floor row - the last unmeasured axis
    §244   what `SUPER_TRACKED_POSITION` actually carries, dumped once on the
           first sample. If it holds x/y/z, the design simplifies and
           `/dr testpin` drops from necessary to convenient

## Worth knowing before you start

- **The pin takes your quest arrow** for the duration. `/dr stop` clears it. (F24: our position
  outranks quest and nothing in the client's flow hands it back — so the clear is the contract.)
- **0.2 s sampling is ~5× the points.** A twenty-minute walk is roughly 6,000 samples. Fine, but
  it is not a normal-sized record.
★ **Any name works** (§264). The dev profile comes from the VERB, so `/dr arm test1` is the
  product path, unchanged.
