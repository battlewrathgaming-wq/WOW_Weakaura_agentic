# Class_identity

Root-level, per-class **lore, story, feel, and creative taste** for Conquest of
Azeroth classes — what a class *is* imaginatively: its fantasy, its mood, the
story it tells, the sensory world it lives in. One subfolder per class.

Deliberately **separate from `Weak Auras/`** (the aura-building tooling) and a
sibling to `Class_design/` (the mechanics). Those two lanes see the *structure*
of a class; this one imagines its *soul*.

## The charter (founding directive — Battlewrath, 2026-07-30)

> Class Identity — owns the lore, story, feel, and creative taste of each class.
> Invented from source consumption. Its output reaches outward: other departments
> (Suno, auras, anyone) pull from it for inspiration. It holds no mechanical
> claims — not on how WoW operates, how WeakAuras function, or how talents/
> abilities work. Those belong to Class_design and the engine. It never asserts a
> rule; it only imagines a feeling.

## The boundary (what keeps this lane honest)

**No mechanical claims. Ever.** Not how a spell works, not a cooldown, not a stat
weight, not a rotation. Where a mechanic surfaces here it is *texture* — the
feeling of the thing — never an assertion of how it functions. The rule-layer is
`Class_design/`'s and the engine's; this lane would only get it wrong and muddy
the record. When tempted to state a mechanic: drop it, or point at them.

This is the exact inverse of `Class_design/METHOD.md`'s honest boundary — *they*
name "feel/rotation in the moment" as out of their scope. That corner is this
lane's whole territory. The two are **complementary halves of one class.**

## The reach — inspiration, not contract (Battlewrath, 2026-07-30)

Output reaches *outward*: Suno prompts, auras, art, anyone. But the pull is
**loose, not arbitrated.** Consumers **read these files and consider against
them** — they riff, they diverge, they invent. There is no schema, no contract,
no API to satisfy. **Inventiveness has a home in creative tasks** (here, and in
whoever pulls) — it is only the *structured pipeline* (dockets, gate, engine)
that runs zero-invention. This lane is a contained creative space; its consumers
are too.

## Invented from source (not from nothing)

"Invented" is not "made up." The imagination is **fed by consuming real source** —
without it, class identity collapses to generic-fantasy cliché. With it, the feel
is specific to *this* class in *this* game. Source consumed (never asserted from):

- **`Input/<class>_talents.json`** — dev-authored ability/talent text; the
  descriptions carry the flavor and fantasy. The richest read.
- **`dependencies/coa_spells.json`** — names, schools, families — texture.
- **In-game** — the client, models, tone, the way it *reads* in play.
- **`Class_design/<Class>/`** — read for texture; its mechanics stay theirs.
- **External lore foundations** — the broad tradition the class descends from
  (e.g. Warcraft/WoW lore, D&D / Forgotten Realms roots). Named inspiration,
  **feel only** — they widen the well; never a claim about COA. Per-class
  citations live in that class's `IDENTITY.md`.

## Layout

```
Class_identity/
  README.md          # this file — charter, boundary, the loose reach
  METHOD.md          # how identity is invented from source — the four facets
  <Class>/
    IDENTITY.md      # the imagined feel/story/taste, sourced — the outward artifact
```

## Classes

_(none populated yet — home just planted. First target: Necromancer.)_
