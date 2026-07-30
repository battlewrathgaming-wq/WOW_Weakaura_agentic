# Class_identity — lane

_Per-class lore, story, feel, and creative taste. Root `Class_identity/` (sibling
to operations/ and to `Class_design/`; separate from `Weak Auras/` tooling).
Stood up 2026-07-30. This file TRACKS the lane and points into the detail; the
imagined identity itself lives in `Class_identity/<Class>/IDENTITY.md`._

## Charter (Battlewrath, 2026-07-30)

Owns the lore, story, feel, and creative taste of each class. **Invented from
source consumption.** Output reaches outward — Suno, auras, anyone pulls from it
for inspiration. **Holds no mechanical claims** (those are Class_design's and the
engine's). It never asserts a rule; it only imagines a feeling. The outward pull
is **loose — read-and-consider, not a contract**; inventiveness has a home in
creative tasks, only the structured pipeline runs zero-invention.

## Method (see `Class_identity/METHOD.md`)

Consume source → imagine feeling, distilled across four facets: **Archetype ·
Register · Narrative · Sensory palette** (the last is the corner Suno pulls from
most). Complement of `Class_design`: they see structure and name feel as
out-of-scope; this lane *is* that feel, and names mechanics as out-of-scope.

## Status

- **Department established (2026-07-30).** Home planted (`README.md` charter +
  `METHOD.md` floor), lane file up, helm taken.
- **Necromancer `IDENTITY.md` landed (2026-07-30)** — the first class populated.
  Forsaken + Animation lens; register live-graded by Battlewrath (victim→master;
  cold, not-a-hero; fallout, not rising; the character is a she). METHOD expanded
  to **two source kinds** (COA-grounding × archetype foundations — WoW + D&D lore).

## Now — active thread (2026-07-30)

- **Suno manager LIVE** (holds the helm, tag `suno`) — a resident puller inside
  Class_identity (`Class_identity/Suno/`). **First-class within the lane, secondary
  in the wider ecosystem** (personal creative byproduct).
  - **First taste-sourcing conversation held** (the fork — his taste sourced from
    his own references, not invented). Refs: Nightwish (*Ghost Love Score* /
    *Phantom*), Emilie Autumn (*Opheliac*), Mishkin Fitzgerald (*Incitatus*).
  - **Architecture set by Battlewrath: form = spec, content = attached.** The song
    *form* is his taste as pure structure (necro-agnostic, reusable); *content*
    (the gothic-necromancer mood, lyrical direction) attaches onto it, pulled loosely
    from an `IDENTITY.md`. Prompt = form × content. Goal = a **varied playlist for
    gameplay** that holds the character's space.
  - **Three form specs landed** (`Suno/forms/`) — a tonal triad on the same dark world:
    **01 Gothic Operatic (Driving Swell)** — driven, avoids atmosphere; grand organ + low
    strings + choir/chant + church-bells-as-hi-hat, no guitar/synth, voice-as-instrument,
    drive-not-chaos. **02 Funeral March (The Last Breath)** — the complement, all atmosphere
    but never directionless (funeral-drum tread, bells prolonging strikes); voice core = pure
    Gregorian chant corrupted by *desperation* (sung spent); lead × chant contend; layers =
    shared palette, focus rotates per song. **03 Dark Vaudeville (Gallows Whimsy)** — the
    whimsy corner (01 drives / 02 grieves / 03 laughs); steampunk cabaret, shanty + waltz,
    wry macabre persona, guitar-free; whimsy edge rotates per song. Open rims in-file.
  - **The guitar / "going full" form split in two** (guitar quarantined from 01–03, keeping
    their no-guitar line clean): **04 Grand Theatrical Heavy (The Full Peak)** — 01's operatic
    drama gone full-electric; theatrical bombast, grand/anthemic/melodic (Nightwish, MCR,
    Ghostfire *Vaudevillain*); melodic (not guttural) voice. **05 Industrial Heavy (Cold
    Machine)** — cold, hard, martial, machine-groove, horror-tinged (Rammstein, Rob Zombie);
    harsh/guttural vocals (the one new vocal color); drive-not-chaos at its most mechanical.
    Both **graded by Battlewrath 2026-07-30 — a clear pass** (04 melodic voice / 05
    harsh-guttural; 05's industrial synth welcome under the guitars; drive-not-chaos holds
    even at full power; 04 = the over-the-top-but-earned form).
  - **Five form specs now** — one tonal spread across the same dark world: 01 driven-operatic ·
    02 funereal-desperate · 03 gallows-whimsy · 04 grand-theatrical-heavy · 05 industrial-heavy.
    A **design pattern surfaced:** each form is allowed to bend a *different* general hard-line
    to fit its character (03 its tinkle/piano; 05 its industrial synth) — the rules are
    per-form, not universal.
  - **Suno levers documented** (`Suno/suno-levers.md`) — the controllable surface, sourced as
    **fact from Battlewrath's own app** (Pro · v5.5 Advanced panel, screenshots): Lyrics
    (Write/Prompt/Instrumental + ReMi), Styles (comma string), Exclude-styles, Vocal Gender,
    Weirdness 0–100, Style Influence 0–100, Duration 0–6min, +Audio/+Voice/+Inspo. **Key
    insight: a form's OUT-list → the Exclude-styles field; tight palette = low Weirdness +
    high Style Influence.** Input grammar researched (OSINT — corroborated community + official
    help): Styles is **front-loaded / priority-ordered**, negatives → **Exclude-Styles**, arc
    tags = **[Build-Up]/[Breakdown]** (not [Build]/[Break]), inline **(whispered)/(belted)**;
    Field caps **confirmed in-app** (Battlewrath tested): **Styles 1000 · Lyrics(Write) 5000 ·
    Prompt-box 3000 · Exclude & Title uncapped**; Duration also has an **Auto** option.
    Meta-tag firing left as a song-level check. Rationale (Battlewrath): a generated song is too
    noisy to reverse-engineer the rules from — get the grammar from authority.
  - **Recipe spine decided (Battlewrath): two drivers** — **A Prompt-driven** (theme + styles →
    Suno writes lyrics; fast/loose, for voice-as-instrument & volume) · **B Write-driven** (custom
    lyrics + meta-tags; full arc & vocal-architecture control). First test = **Driver B** ("test
    what we care about").
  - **Supporting research done — song-structure/arrangement vocabulary** (`Suno/song-structure-vocab.md`):
    established music terms (ostinato = the driving floor; pedal point = 02's drone; antiphony =
    lead↔chant; crescendo = the swell) mapped to Suno meta-tags. **Key find: Suno's meta-tags include
    dynamics/arrangement tags** — `[Call and Response]` (lead↔chant / shanty), `[Crescendo]/[Decrescendo]`
    (swells), `[Unison]`/`[Counterpoint]`/`[Layering]` (the vocal bodies), `[Build-Up]/[Breakdown]` —
    tier-flagged, confirmed by the Driver-B test.
  - **Prompt recipe BUILT** (`Suno/prompt-recipe.md`) — the form × content → lever-set method, both
    drivers, shared fill + pre-flight checklist + the emit→run→grade loop. **First composed prompt cut**
    (`Suno/prompts/necromancer_02_funeral-march.md`) — form 02 × necromancer, Driver B: front-loaded
    Styles, the Exclude OUT-list, sliders (W25/SI80), and Write-lyrics with the meta-tag arc
    ([Call and Response] lead↔chant, [Crescendo]/[Breakdown], (whispered)/(belted), public-domain Latin).
    **RUN 2026-07-30 — strong success** (Battlewrath: *"REALLY good,"* near-chills, headphones-on; a
    richness his own attempts never reached; **the enforced palette held**). **Emergent find: a powerful
    _banshee tone_** in the lead — a happy accident to make reproducible (candidate: elevate to form 02's
    vocal identity + a summonable "banshee wail" style tag; also on-theme — a banshee is a wailing undead
    spirit). Full mechanical grade (which Tier-2/3 tags fired) still to gather. **The method proved out
    end-to-end: sourced taste → form → levers → grammar → recipe → a loved generation.** **Kept & named:
    _"Forsaken in requiem aeternam"_ — the lane's first named product.**
  - **Summonable-features catalog started** (`Suno/summonable-features.md`) — Battlewrath's principle:
    turn a loved happy-accident into a *named, callable* feature (summon by design, not luck). Entry 001 =
    **banshee wail / keening** (from the first keeper), folded into form 02's vocal identity + given a
    summon route: **placed inline cues** (`(wailing)`/`(keening)` on chosen lines), **not** a Styles tag —
    Battlewrath's refinement, generalised into a **scope rule**: pervasive texture → Styles (global),
    punctuating moment → inline placement (else a style insertion over-uses it). Confidence =
    discovered-once; reconfirm by placing the cue at the peaks in a re-run.
  - Still owned by the Suno manager: the content-attachment layer generalised, the growing prompt library,
    the summonable-features catalog, its own charter.

## Open / forecast

- **Necromancer — other lenses** (the `IDENTITY.md` honest rim): the **Death** &
  **Rime** spec registers, and non-Forsaken origins — each shades the same class
  differently.
- **20 more classes** — same method, one `IDENTITY.md` each, as they're reached.
