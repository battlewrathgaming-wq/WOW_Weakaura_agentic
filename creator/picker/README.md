# picker/ — the public packaging silo

_This silo exists for ONE job: **packaging the bench's work for public consumption**. Everything else in
creator/ invents or designs; everything in engine/ proves and presses. This folder takes what they made and
puts it in players' hands. Established 2026-07-15 (Battlewrath)._

## What this is

The **HTML picker V1**: one portable, self-contained, text-only .html — a guided wizard (six questions to one
WA import string) plus a browsable library face (the flattened game, ID→ID→ID). Download the file, answer the
questions, paste the string. No install, no account, no server.

## The documents

- **`picker_tree.md`** — THE SPEC. 8 laws, the screen script, seams closed, the data pool assessed, export
  feasibility confirmed, the gap-display rule. Design is DONE; don't reopen it casually — changes here are
  deliberate acts.
- **`picker_build.md`** — THE RUNWAY. Six phases from need to built (library emit ∥ JS codec port → template
  press → shell → live stamp → doors light up). Build products land in this silo as the phases execute.

## What lands here (as the build runs)

```
picker/
  README.md          this charter
  picker_tree.md     the spec
  picker_build.md    the runway
  emit_library.py    Phase 0 gear   (→ library.json)
  codec/             Phase 1        (the JS encode port + its cross-validation harness)
  templates/         Phase 2        (machine-pressed lane templates + behaviour fragments, slot-annotated)
  shell/             Phase 3        (the HTML template + build_picker.py)
  out/picker.html    THE PRODUCT    (a build artifact — never hand-edited; fix the gear, re-emit)
```

## Standing laws (inherited, not new)

- The HTML is a **build product** — pipeline law applies: nothing in out/ is ever hand-edited.
- The shell **emits and never ingests** (one-time minting) and **never authors structure** (templates are
  pressed by the real machine at build time).
- Text-only: **data flattening, not in-game emulation** — WA owns the come-alive moment.
- When a new contract lands (Ready, Self, …), doors light up by **regenerating data** — if the shell needs
  editing, Phase 3 was done wrong.

## The seat in the roadmap

This ships first — the packaging of what exists. **After it's out the door, the bench's focus turns to bespoke
UIs through the existing engine pipeline** (Battlewrath, 2026-07-15): the picker is the wide product for
everyone; bespoke is the deep product the machine was always for.
