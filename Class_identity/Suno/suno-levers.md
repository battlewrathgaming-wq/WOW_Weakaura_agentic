# Suno — the levers (Pro · v5.5)

_The **controllable surface** of Suno: every knob we can actually turn. This is the bridge from a **form
spec** (× content) to an actual generation — a form is *expressed in these levers*. Documented as **fact
from Battlewrath's own Suno** (Pro tier, model **v5.5**, Advanced panel — screenshots + field list,
2026-07-30, PRIMARY source). Anything inferred from general Suno knowledge is quarantined to
[§ To verify](#to-verify) and marked — **his app is the authority, not my memory.**_

## Tier & version (the frame)

- **Suno Pro**, model **v5.5**. Version is selectable (top-right dropdown); levers can differ by version,
  so this doc is **pinned to v5.5** — re-confirm if he changes it.
- Panel modes: **Simple · Advanced · Sounds.** Everything below is the **Advanced** panel (full levers).

## The levers (as shown — fact)

**Inputs / attachments** (top row): **+ Audio** · **+ Voice** (New) · **+ Inspo** — reference/voice
inputs. _(Exact behaviour → § To verify.)_

**Lyrics — three modes:**
- **Write** — you supply explicit lyrics.
- **Prompt** — you describe what the lyrics are *about*; Suno writes them fresh each generation (blank =
  random topic). Lyrics model shown: **ReMi** (dropdown → selectable).
- **Instrumental** — no lyrics, no vocals.

**Styles** — a **comma-separated string** (`string, string, string`): genre / mood / instrument /
production tags. App example: *"dj scratches, passionate, intense, hi-nrg, sentimental."* Helpers beside
it: enhance (wand) + shuffle.

**Exclude styles** — a negative field: styles to keep **out**.

**Vocal Gender** — **Male / Female.**

**Weirdness** — slider **0–100%** (default 50). App tooltip: *"Turn it up for wild, unexpected results."*
→ experimentation / unpredictability.

**Style Influence** — slider **0–100%** (default 50). App tooltip: *"Turn it up to match your style
description."* → **how tightly the result adheres to the Styles string** (Battlewrath: how constrained to
the styles it is).

**Duration** — **0–6 min** (Pro tier sets length; shown at 5:00).

**Song title** · **Save to workspace.**

## How a FORM maps onto the levers (the bridge — why the specs exist)

| Form element | Suno lever |
|---|---|
| Instrumentation IN · genre · production · mood · tempo-feel | **Styles** (comma tags) |
| Instrumentation OUT / hard-lines (01–03 *no guitar*, etc.) | **Exclude styles** |
| Vocal architecture (operatic / choir / chant / guttural / whisper) | **Styles** tags + **Vocal Gender** |
| Content — theme / persona | **Lyrics**: *Prompt* for a topic · *Write* for explicit + structure |
| "Voice-as-instrument" (no plot to follow) | **Instrumental**, or *Prompt* with cadence-led styles |
| Length feel (01/02 long · 03 tighter) | **Duration** |
| **Drive-not-chaos / tight palette** | **Weirdness low** + **Style Influence high** |
| Deliberately wilder / roving a per-song edge | **Weirdness up** |

**★ The key insight:** **Exclude styles + high Style Influence** are how we *enforce* a form's chosen
boundaries — the "no guitar" line, the "not-tinny" rule — instead of *hoping* the model honours them.
Every form spec's OUT list finally has a home: it becomes the Exclude-styles field.

## To verify

_(My knowledge / inference — **not** read off the app. Confirm in-app; his Suno is the authority.)_

- **Structure / meta-tags in _Write_ lyrics** — Suno has historically supported inline section tags
  (`[Intro]` `[Verse]` `[Chorus]` `[Build]` `[Break]` `[Bridge]` `[Outro]` `[Instrumental]`
  `[Guitar Solo]`, and vocal cues like `[Choir]` `[Whispers]` `[Spoken]`). **The set supported at v5.5 is
  unconfirmed.** If they work, they're how a form's *arc* (build → break → peak) gets placed in a track.
- **+Audio / +Voice / +Inspo** — a possible route to **playlist consistency** (one voice/persona across
  tracks). Behaviour + limits unknown.
- **Character limits** on the Styles / Lyrics fields — unknown.
- **Weirdness × Style Influence defaults** for our forms — to find by testing. Starting guess for the
  tightly-specified forms: **Weirdness ~20–40 / Style Influence ~60–80** (hold the palette, stay driven).

## Sourced from

Battlewrath's own **Suno Pro · v5.5 · Advanced panel** — screenshots + field list, 2026-07-30. Primary
source; supersedes remembered Suno behaviour. Re-confirm the levers if the version changes.
