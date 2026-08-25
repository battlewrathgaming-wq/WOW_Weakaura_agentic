# CONCEPT HOME · `arg` — what an action acts ON, and why no string travels

_A HOME is an INDEX, never a second copy (AL-26, Battlewrath 2026-08-22: "a home is better than a
run-time cost — it's greppable and inspectable"). It says what the concept IS in a few lines, its closed
list, and POINTS at every place that rules or grades it. The pointed-at documents stay authoritative;
if this page and one of them disagree, the document is right and this page has drifted. Checkable: a
home must name every governing document the vocabulary appears in (`emit_divergence` computes that set)._

## WHAT IT IS
The third slot of a behaviour row — `<sense> : <action> : <arg>` — present only for actions that take
one. **`supertrack` has none** and is absent from the rule table, because it points at the node's own
position (A2.6): there is no second thing to name.

### ★★★ THE ONE THING TO UNDERSTAND: TWO LAYERS, AND ONLY ONE OF THEM TRAVELS
    THE RECORD       carries a REFERENCE — `contract.lua`: *"AN ID REFERENCE, never free text — a boss
                     NAME is an index into the shipped names table, so the record carries no string
                     to escape."*
    THE SIDE TABLE   carries the text. `Contract.SIDE_TABLES` — *"each has exactly ONE free field and
                     it is LAST after its key, which is the only place free text lives at all"* — and
                     **the driver never opens them** (RI-18).

⟶ So *"the arg is raw text"* (RI-50) and *"the arg is an id"* (the contract) are **not in conflict**:
the AUTHOR types into a side table, the RECORD carries the key. ★ That is the whole security answer —
[[travelling-data-names-never-supplies]] — and it is why `say` is CONSTRUCTED rather than free
(AL-30/31: channel · term · a picked stand-in; **no free text meets an executable path**).

## THE CLOSED LIST — per ACTION, never per label
    Routes.ROW_ARG        which actions take one, and its FIELD LABEL: boss → "name" ·
                          note / say → "content" · supertrack → none
    Routes.ROW_ARG_RULE   the DECLARATION the guard READS: `{ type, source, max? }`
                            boss  string · source `run`   — PICKED from the run's own bosses (A3.1),
                                                            never typed, uncapped
                            note  string · source `user`  · max `ARG_MAX` (255)
                            say   string · source `user`  · max `ARG_MAX`
    ⚠⚠ KEYED ON THE **ACTION**, NOT THE LABEL. `note` and `say` share the label `"content"` and are
      typed differently, so a label-keyed table cannot hold the declaration it exists to carry — and a
      label is a PANE concern that DR_Content_1.2 may rename out from under the type. **Measured, not preferred.**
    ★ `source` is the trust split, in the same table: `run` is picked, `user` is typed and capped.

## WHERE IT IS RULED (read these; this page only points)
    driver_architecture.md       §4b (the posed tab: arg is a typed VALUE, refused by name; the resolver
                                 binds only words on the closed list) · §5 (names-never-supplies)
    ARCHITECT_LOG.md             AL-17 (typed, the guard READS the declaration) · AL-30 / AL-31 (THE ACTOR:
                                 `mark` picked from the run; `say` CONSTRUCTED; the actor is OPT-IN)
    driver_manager_acceptance.md A12.2j (the type and cap, read from the declaration, keyed on the action)
    driver_data_model.md         A1.1 / A1.4a (every term a REFERENCE the driver resolves) · the side tables
    Reconcile_inbox.md           RI-50 (the comparand, and WA's precedent: user text becomes LOOKUP TABLES
                                 checked by equality, never a pattern) · RI-60 (no door at all — the gap)
    contract.lua                 `arg` on the BEHAVIOUR record · `Contract.SIDE_TABLES`
    routes.lua                   `ROW_ARG` · `ROW_ARG_RULE` · `ARG_MAX` · `RowIncomplete`

## WHAT IS OWED — derive it; never read it here (`emit_built_state.py`)
As of 2026-08-22 by hand: the declaration and the build-time type/cap guard are BUILT (B3, §473).
**The DOOR is not** (RI-60 — and its two origins need different doors: a PICKER for boss, a capped
box for note/say). ⬜ RI-50's rows 2 and 3 are the Analyst's: *never a Lua pattern, never formatted
into source*, and the standing closed-verb regression. ⚠ A hand line; it rots — the tool is the truth.
