# The adaptor — `code : user`, one row per term that reaches a pane

_Started 2026-08-18 (§321), owing since §308's T14. `driver_programmatic_model.md` §5 rules how
it is built: **"inventory current code terms into the `code` column AS EACH IS TOUCHED, correct
drift there, THEN free the `user` column for the author's words."** So this file FOLLOWS the
code — it is never a term planner, and a row appears the day its term does._

★ **Why the split exists (§3b):** *"The author is someone just getting used to it. Every verb in
a drop-down must be SELF-DESCRIBING, not technical-leaning… the pane speaks the author's side;
the code may keep its own words underneath."* Agents write and reason in the code word; a rename
is a one-row edit; nobody translates in their head.

⚠ **A miss on this table PASSES THROUGH** (ruled §295): a term with no row renders as the code
term. Silent for the author, and loud at the bench when the checker lands (A5.3). That split is
deliberate — each fault in front of the person who can act on it.

---

## Rows — filed as the term landed

| code | user | landed | note |
|---|---|---|---|
| `sense` | *the axis; the pane labels its block* **detect** | §321 | stage one of `sense → when true → next`. ⚠ the ZONE is labelled `detect` (object.lua:690) and the FIELD is `sense` — different words on purpose (T2) |
| `reachHere` | **reach here** | §321 | the DEFAULT. Picking it clears; it is never stored |
| `bossEngaged` | **boss engaged** | §321 | arms. Model §2c: either witness arms, the kill satisfies |
| `bossKilled` | **boss killed** | §321 | satisfies |
| `boss` | *(the picker has no label; its entries are names)* | §321 | picked from the run, never typed |
| `ordinal` | **order** | §312 | blank = a satellite, live whenever its beacon is current |
| `radius` | **radius** | pre-existing | passes §3b unchanged |
| `bandUp` | **up** | pre-existing | §85's asymmetric half that matters |
| `bandDown` | **down** | pre-existing | |
| `shape` → `wire` | **trip wire** | pre-existing | `radius` renders as itself |
| `role` → `complete` | **stage complete** | pre-existing | from `ROLE_TEXT`, object.lua |
| `role` → `set` | **set stage** | pre-existing | |
| `role` → `start` | **start of stage** | pre-existing | |
| `role` → `update` | **updater** | pre-existing | ⚠ *"updater"* is close to technical — flagged for the naming pass, not changed here |
| `action` → `supertrack` | **point the tracker** | pre-existing | |
| `outcome` → `advance` | **advance (+1)** | pre-existing | |
| `outcome` → `stage` | **go to stage** | pre-existing | |

## ⚠ Terms that reach a pane and have NO user word yet

| code | where | why it is a problem |
|---|---|---|
| `ratchet` | `object.lua:197` — *"ratchets when found"* | **T15.** §3b fails *once · latch · edge · level · hysteresis · activate · trip* as author-facing, and `ratchet` is that family — it is one of our three stage registers. It reached the author in a string G2 extended (§300) rather than introduced. Needs a word. |
| `on-ramp` | `object.lua` — the answers line | *"on-ramp"* is ours. The model calls the idea *the way in*. |
| `satellite` | §312's path readout — *"satellite - always listening"* | ⚠ **§3b names `satellite` explicitly as a FAIL.** I wrote it into a user-visible string eleven days after the law was written. |

★ **Three rows in that second table, and I put two of them there myself this week.** That is the
argument for the checker (A5.3) rather than for trying harder: a rule I have to remember at the
moment of typing a string is a rule that gets remembered most of the time.

---

## What this file is NOT

⚠ **Not a plan.** §9/A5.4: *"the inventory FOLLOWS the code… what lands and is confirmed gets a
real inventory."* No row here anticipates a term. If a term is not in a pane today it is not here.

⚠ **Not the enforcement.** A5.3 puts a third check in `check_interface.py`: every user-visible
string in a pane resolves through this table, and every code term reaching a pane has a row. That
lands once there is enough here to compare against — which, from today, there is.
