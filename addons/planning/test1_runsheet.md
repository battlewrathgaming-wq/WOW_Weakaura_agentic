# `/dr arm test1` — RUN SHEET

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

To reuse it on a later run: `/dr testpin <x> <y> <z> <mapID>` with the numbers it gave you.

## 3. Arm the profile

    /dr arm test1

Chat should say: **`dev profile test1 - 0.2s sampling + held tracker pin`**

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

The watcher lands it, or bench `[2] Pull once`.

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
- ⚠ **A run cannot be named `test1`** — the profile owns that name. Any other name is the ordinary
  product path, unchanged.
