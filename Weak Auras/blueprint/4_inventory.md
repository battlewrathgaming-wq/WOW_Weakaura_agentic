# 4 · Class inventory — the authoring surface

**Role.** How a class declares its HUD. Per mask slot: which **slice(s)**, and the
**fills** (spell ID, options). Holds *intent and references* — never code or WA
tables. Example: `Tier1 slot 1 → dot-tracker, spell = X`.

**In:** a human/agent authoring against the **mask** (which slots exist) and the
**slices** (what can go in them).
**Out:** a per-class inventory = a list of `{ slot, slice(s), fills }`.

**Owned by:** the human / agent author. This is the surface a person actually
touches; everything downstream is mechanical.

**Consumed by:** the assembler (turns it into a data table).

**Status:** NOT YET REDESIGNED for this model. The old `<Class>/inventory.py`
hardcodes full tables/positions; this component collapses it to slot + slice +
fill. Depends on the slice vocabulary (component 2) existing first.
