# Suno — the levers (Pro · v5.5)

_The **controllable surface** of Suno: every knob we can actually turn. This is the bridge from a **form
spec** (× content) to an actual generation — a form is *expressed in these levers*. Documented as **fact
from Battlewrath's own Suno** (Pro tier, model **v5.5**, Advanced panel — screenshots + field list,
2026-07-30, PRIMARY source). The **input grammar** (formatting / priority / meta-tags) that isn't visible
in the panel is gathered separately as **OSINT leads** — sourced, corroborated, and marked *confirm-in-app*
— because **his app is the authority, not my memory** (and a generated song is too noisy to reverse-engineer
the rules from)._

## Tier & version (the frame)

- **Suno Pro**, model **v5.5**. Version is selectable (top-right dropdown); levers can differ by version,
  so this doc is **pinned to v5.5** — re-confirm if he changes it.
- Panel modes: **Simple · Advanced · Sounds.** Everything below is the **Advanced** panel (full levers).

## The levers (as shown — fact)

**Inputs / attachments** (top row): **+ Audio** · **+ Voice** (New) · **+ Inspo** — reference/voice
inputs. _(Exact behaviour → § To verify.)_

**Lyrics** (field cap **3000 chars**) **— three modes:**
- **Write** — you supply explicit lyrics.
- **Prompt** — you describe what the lyrics are *about*; Suno writes them fresh each generation (blank =
  random topic). Lyrics model shown: **ReMi** (dropdown → selectable).
- **Instrumental** — no lyrics, no vocals.

**Styles** — a **comma-separated string** (`string, string, string`): genre / mood / instrument /
production tags. App example: *"dj scratches, passionate, intense, hi-nrg, sentimental."* **Field cap:
1000 chars.** Row controls: enhance (wand), shuffle, undo, save-preset (bookmark), clear.

**Exclude styles** — a negative field: styles to keep **out**. **No visible cap** (tested past 110 chars —
no warning, no counter shown).

**Vocal Gender** — **Male / Female.**

**Weirdness** — slider **0–100%** (default 50). App tooltip: *"Turn it up for wild, unexpected results."*
→ experimentation / unpredictability.

**Style Influence** — slider **0–100%** (default 50). App tooltip: *"Turn it up to match your style
description."* → **how tightly the result adheres to the Styles string** (Battlewrath: how constrained to
the styles it is).

**Duration** — **Custom** (a **0–6 min** slider) or **Auto** (Suno chooses the length). Pro tier.

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

## Formatting & priority — the input grammar (OSINT, 2026-07-30)

_Gathered from public Suno guides + the official help centre (sources below). **Corroborated across
independent sources = a strong lead, not gospel** — Suno lore is half-stale, and version-specific numbers
belong to **his v5.5 app as final authority.** This is the "question register": admissible as a lead,
confirmed in-app._

**The Styles field is priority-ordered — front-loaded.**
- **The first tag carries the most weight** (the tokenizer weights earlier terms more heavily). Order the
  string by importance. _(Multi-source community consensus; not official.)_
- **Recommended element order:** **Genre → sub-style → Mood/energy → Vocal direction → Instrumentation →
  Production/Tempo.** Genre first, production/tempo last (the middle order varies by source; genre-first /
  tempo-last is unanimous).
- **~8–15 tags** is the workable band; <5 reads vague (the model fills with an average), >20 starts
  contradicting itself.
- **Comma-separated** (`a, b, c`).
- **A concrete scene beats a vague emotion word** — v5.5 reportedly maps a scene to timbre/BPM/harmony,
  ~5× more effective than a lone mood word. (So "a dead sorceress conducting a frozen crypt-choir" beats
  "epic.")
- **Character limit — CONFIRMED in-app (2026-07-30):** **Styles = 1000 chars.** (The community's ~200-char
  figure was wrong; ~1000 was right.) Front-load regardless — leading tokens weigh most.

**Negatives go in Exclude Styles, never the Styles string.** Direct negation inside Styles isn't reliably
parsed; the dedicated **Exclude Styles** field (your app has it) is the confirmed home for **every form's
OUT-list**. _(Multi-source + matches the app.)_

**Lyrics meta-tags — bracketed section labels, each on its own line, right before the lines they affect.**
They are probabilistic **hints, not commands** — honoured most of the time, ignorable; regenerate or
simplify a tag if skipped. Reliability tiers (community consensus across versions):
- **Tier 1 (most reliable):** `[Intro]` `[Verse]` `[Pre-Chorus]` `[Chorus]` `[Bridge]` `[Outro]` `[End]`
- **Tier 2 (common events):** `[Build-Up]` `[Drop]` `[Breakdown]` `[Instrumental]` /
  `[Instrumental Break]` `[Guitar Solo]` `[Spoken]` `[Final Chorus]`
- **Tier 3 (experimental — shorthand, not switches):** `[Energy: High]`, `[Vocal: Warm]`,
  `[Drums: Stronger]`.
- **Correction to my earlier guess:** the arc tags are **`[Build-Up]` / `[Breakdown]`**, *not*
  `[Build]`/`[Break]`.
- **Inline vocal cues use _parentheses_** in the lyric line: `(whispered)`, `(belted)`, `(spoken)`.
  → for our forms: `(whispered)` = 01's whisper-layers · `(belted)` = 04's operatic belt · `(guttural)` = 05.
- **Lyrics field = 3000 chars** (confirmed in-app; the community ~5000 figure was wrong).

**Sliders (official help + community):**
- **Weirdness** — *Safe → Chaos*, **50 = normal**. Low = simpler, predictable, steady; high = complex,
  unpredictable, experimental. _(Official confirms Safe→Chaos / 50 normal.)_
- **Style Influence** — *Loose → Strong*, how tightly it obeys the Styles string: ~0–30 loose hints ·
  40–70 balanced · **70–100 strict / hard constraint**. _(Official confirms Loose→Strong.)_
- **Audio Influence** — appears only with an Audio Upload; how much the uploaded audio drives the result.

**→ Slider recipe for our tight forms (drive-not-chaos):** **Weirdness low (~20–40)** + **Style Influence
high (~70–90)** — hold the exact palette, stay driven. Only push Weirdness up when a song is *meant* to
rove (a whimsy edge, a wilder take). Starting recipe; refine per form by ear.

## Still to confirm in-app (his Suno is the authority)

- **Which meta-tags actually fire at v5.5** — the tiers are cross-version community consensus; confirming
  them is a *song-level* read, so lower priority given the noisy-feedback caveat (they stay *hints*
  regardless).
- **+Voice / +Inspo behaviour + limits** — the new attachment inputs; a possible route to playlist
  voice-consistency, still unmapped.
- _Resolved 2026-07-30 (in-app, primary): field caps — **Styles 1000 · Lyrics 3000 · Exclude & Title
  uncapped** (tested). The app superseded the community numbers where they conflicted._

## Sources

Primary: **Battlewrath's Suno Pro v5.5 Advanced panel** (screenshots, 2026-07-30) + **official Suno help —
[Creative Sliders](https://help.suno.com/en/articles/6141377)**. OSINT leads (community, corroborated):
[hookgenius Suno Prompt Guide 2026](https://hookgenius.app/learn/suno-prompt-guide-2026/) ·
[Jack Righteous Meta Tags Guide](https://jackrighteous.com/en-us/pages/suno-ai-meta-tags-guide) ·
[Suno slider guides (genxnotes / Jack Righteous)](https://blog.genxnotes.com/en/what-does-the-weirdness-style-influence-and-audio-influence-sliders-in-advanced-options-do-in-suno/).
Community claims marked as leads; confirm the numbers in-app.

## Sourced from

Battlewrath's own **Suno Pro · v5.5 · Advanced panel** — screenshots + field list, 2026-07-30. Primary
source; supersedes remembered Suno behaviour. Re-confirm the levers if the version changes.
