# The prompt recipe — form × content → a Suno generation

_Where the chain converges: a **form spec** × **content**, expressed through the **levers**
([`suno-levers.md`](suno-levers.md)), in the **grammar** (front-loading, meta-tags), using the
**vocabulary** ([`song-structure-vocab.md`](song-structure-vocab.md)). This file is the **method**;
composed, copy-paste-ready prompts live in [`prompts/`](prompts/)._

## Two drivers — pick one

- **Driver A — Prompt-driven.** You set theme + styles; **Suno writes the lyrics** (Prompt mode). Fast,
  low-effort, good for *volume* and for tracks where the voice is an instrument you don't follow. No arc
  or meta-tag control; the words are a themed roll of the dice.
- **Driver B — Write-driven.** You author the lyrics with meta-tags (Write mode). Full command of the
  **arc** and the **vocal architecture**, at real authoring cost. Meta-tags are *hints*, not commands.
  → **the showcase driver** (02's lead↔chant, 04's build-to-peak, 05's guttural groove).

## The shared fill (both drivers)

1. **Form + content** — which form (the *how*), which content/space (the *what*, pulled loosely from an
   `IDENTITY.md`).
2. **Styles** — a **front-loaded** comma string, **≤1000 chars**, ~8–15 tags. Order:
   **genre → sub-style → register/mood → vocal → instrumentation → production/tempo.** Draw the IN-list
   from the form; name devices in real terms (ostinato, drone, antiphony, crescendo).
3. **Exclude styles** — the form's **OUT-list, verbatim** (no guitar / synth / tinny / …). This is where
   the hard-lines are *enforced*, not hoped.
4. **Vocal Gender** — from the content (the necromancer is a *she* → Female lead).
5. **Weirdness / Style Influence** — the form's dial. Tight forms (drive-not-chaos): **Weirdness ~20–40,
   Style Influence ~70–90.** Loosen Weirdness only for a song *meant* to rove.
6. **Duration** — the form's length feel (Custom slider 0–6 min, or Auto).
7. **Title.**

## Driver A — the one extra step

- **Lyrics = Prompt** mode. Put the **theme** in the box (**≤3000 chars**): the content/mood as a topic
  ("a spent, enduring dirge from one who refuses to stop"). Suno writes fresh lyrics each run.

## Driver B — the one extra step

- **★★ Line structure _commands_ the word (Battlewrath, confirmed in-run 2026-07-30):** how you break the
  lyric lines directly shapes phrasing and delivery — the **strongest, most precise lever in Driver B.**
  Put a phrase on its own short (even lowercase) line to make it land hushed / isolated / collapsed; run
  phrases together to keep them flowing. Proven: breaking "Cold in the long dark / one light / And it is
  fading" made a **large** difference in delivery. **Reach for line structure first; layer meta-tags as
  forecast on top.**
- **★ Author meta-tags as _forecast_, not per-line surgery (Battlewrath, confirmed in-run 2026-07-30):**
  the generation **isn't 1:1** with the instruction. A tag/cue shapes the **region and arc** it sits in,
  not the exact line. Lay out the *trajectory*; place an effect in the *region* you want it; expect loose
  interpretation. Don't over-engineer line-level stage directions — they won't fire surgically.
- **Lyrics = Write** mode (**≤5000 chars**). Author the lyrics with:
  - **Section spine** (Tier-1, reliable): `[Intro]` `[Verse]` `[Chorus]` `[Bridge]` `[Outro]`.
  - **Arc & arrangement** (Tier 2–3, *hints*): `[Build-Up]` `[Breakdown]` `[Crescendo]` `[Decrescendo]`
    `[Call and Response]` `[Unison]` `[Counterpoint]` `[Layering]`.
  - **Inline vocal cues** (parentheses, in-line): `(whispered)` `(belted)` `(guttural)` `(chanted)`.
  - **Cadence over meaning** (Battlewrath's rule) — the words serve the *delivery*, not a plot to follow.

## Control hierarchy — most precise → most diffuse

**Line structure** *commands* the word (delivery/phrasing) → **meta-tags / cues** *forecast* the section &
arc (loose, not 1:1) → **Styles** sets *pervasive* texture → **Exclude** enforces the OUT-list →
**sliders** tune adherence (Style Influence) & variance (Weirdness). **Match the lever to how precise the
control needs to be** — for a specific phrase's delivery, break the line; for a whole-song colour, use Styles.

## Pre-flight checklist

- [ ] Styles **front-loaded**, ≤1000 chars, ~8–15 tags?
- [ ] Exclude carries the **whole** OUT-list?
- [ ] Sliders match the form's dial (tight = Weirdness low / Style Influence high)?
- [ ] Vocal Gender + inline cues set?
- [ ] Within caps (Write 5000 / Prompt 3000 / Styles 1000)?
- [ ] **Content evokes the _space_, not the on-the-nose** — the mood the character lives in, never a
      literal songs-about-undeath (Battlewrath owns this corner).

## Worked example

**02 Funeral March × the necromancer space, Driver B** →
[`prompts/necromancer_02_funeral-march.md`](prompts/necromancer_02_funeral-march.md). Demonstrates the
full fill: front-loaded Styles, the Exclude list, the slider recipe, and Write-lyrics placing the
funeral ostinato, the lead↔chant `[Call and Response]`, the spent `(whispered)` chant, and the
`[Crescendo]`/`[Breakdown]` arc.

## The loop

Compose → **Battlewrath runs it in Suno** → grade the result → correct the recipe/example. Meta-tags are
hints, so the **first Driver-B runs teach us which actually fire at v5.5** — the one place a noisy
generated result is worth reading (it's a *song-level* question, not a field one).
