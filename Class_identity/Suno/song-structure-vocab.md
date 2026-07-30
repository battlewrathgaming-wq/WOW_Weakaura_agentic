# Song structure & arrangement — the vocabulary

_The **terminology fact-basis** for authoring. Two jobs: (1) label sections and dynamics in **Driver-B**
lyrics using the *recognized* meta-tags, and (2) describe structure/arrangement in the **Styles** field in
words Suno was trained on. So I reach for the right term, not whatever comes to mind (the fork)._

_**Two confidence layers, kept apart:** the **music terms** below are established fact (music-theory
sources). The **Suno meta-tag** recognition is **community-sourced lead**, tier-flagged — Suno tags are
*probabilistic hints, not commands*, and the Driver-B song test is how we learn which actually fire at
v5.5. Sources at the foot._

## Sections (the skeleton — Tier-1 meta-tags, most reliable)

- **`[Intro]`** — the opening; sets pulse and palette before the voice.
- **`[Verse]`** — the narrative body; same melody, changing lines.
- **`[Pre-Chorus]`** — a lift that builds anticipation into the chorus.
- **`[Chorus]`** — the emotional release / central hook; same lines each return.
- **`[Bridge]`** (a.k.a. **middle-8**) — contrast section, a change of energy.
- **`[Outro]` / `[Coda]`** — the way out (fade, stripped tag, or written ending).
- **Refrain** — a short repeated line (often the title) inside/around the verse; simpler than a chorus.
- **Hook** — the stickiest musical/lyric fragment; usually *in* the chorus.
- **Vamp** — a repeated figure that loops out an ending.

## Arrangement & dynamics devices (how your forms' ideas get their proper names)

_Established terms (fact). Where a Suno tag exists it's noted — **Tier 2** = common, **Tier 3** =
experimental/shorthand (less reliable)._

- **Ostinato** — a figure that persistently repeats (same voice/pitch). **= your fixed driving floor
  (01) and funeral-march tread (02).** Styles-field word, not a tag.
- **Pedal point / Drone** — a sustained low note held under changing harmony. **= 02's atmosphere bed.**
  Styles word.
- **Antiphony / Call-and-response** — two groups alternating, a musical conversation. **= 02's lead↔chant,
  03's shanty crowd.** → **`[Call and Response]`** (Tier 3).
- **Counterpoint** — independent melodic lines at once. **= lead and chant as two bodies (02).** →
  **`[Counterpoint]`** (Tier 3).
- **Unison / Homophony** — voices on one line together. **= 02's "in concert" mode.** → **`[Unison]`**
  (Tier 3).
- **Canon / Round** — overlapping entries of the same line. → **`[Canon]`** (Tier 3).
- **Layering** — parts stacked into depth. **= 02's layer accretion.** → **`[Layering]`** (Tier 3).
- **Motif / Leitmotif** — a short recurring idea that binds the piece.
- **Crescendo / Decrescendo (Diminuendo)** — gradual swell / gradual recede. **= 01's swell, 02's
  rise-and-recede, 04's build-to-peak.** → **`[Crescendo]` / `[Decrescendo]`** (Tier 3).
- **Build-Up / Drop / Breakdown** — EDM-lineage structural events (build tension → release → strip down).
  → **`[Build-Up]` `[Drop]` `[Breakdown]`** (Tier 2). **`[Breakdown]`** = the chant break / the strip.
- **Instrument feature cues** — e.g. **`[Organ Intro]`**, **`[Cello Solo]`**, **`[Choir]`**, `[Chant]`
  (Tier 2–3; the pattern `[<instrument/voice> <section>]` is documented).
- **Inline vocal cues** (parentheses, in the lyric line): `(whispered)` `(belted)` `(guttural)`
  `(spoken)` `(chanted)`.
- **NOT wanted** (named so we avoid it): **ritardando / accelerando** (tempo drifting) — Battlewrath wants
  a **fixed** signature; drive comes from *subdivision*, not tempo change (form 01).

## The form → term → lever map (the payoff)

| Form idea | Proper term | Suno lever (tier) |
|---|---|---|
| 01 fixed driving floor | ostinato | Styles: "driving ostinato, fixed pulse" |
| 01 fractional subdivision build | rhythmic diminution | Styles: "subdividing percussion" + `[Build-Up]` (T2) |
| 01 / 02 / 04 swell & recede | crescendo / decrescendo | `[Crescendo]` `[Decrescendo]` (T3) |
| 02 atmosphere bed | pedal point / drone | Styles: "low drone, pedal point" |
| 02 lead **with** chant | unison / homophony | `[Unison]` (T3) |
| 02 lead **vs** chant (each in the other's absence) | antiphony | `[Call and Response]` (T3) |
| 02 lead & chant as two bodies | counterpoint | `[Counterpoint]` (T3) |
| 02 chant break | breakdown / interlude | `[Breakdown]` (T2) |
| 02 layer accretion | layering | `[Layering]` (T3) + `[Build-Up]` (T2) |
| 03 shanty crowd | call-and-response | `[Call and Response]` (T3) |
| 04 build to peak | crescendo → final chorus | `[Build-Up]` → `[Final Chorus]` (T2) |
| 05 machine groove | ostinato (mechanical) | Styles: "mechanical ostinato, martial" |
| voice texture (all forms) | — | inline `(whispered)` / `(belted)` / `(guttural)` |

## How this feeds the recipe

- **Styles field** gets the *word-level* terms (ostinato, drone, crescendo, antiphony, mechanical) —
  they describe the arrangement in language the model knows.
- **Driver-B lyrics** get the *placed* tags — sections (T1, reliable) as the spine, then dynamics /
  arrangement tags (T2–T3, hints) to shape the arc and the vocal bodies.
- **Reliability discipline — meta-tags are FORECAST, not per-line (confirmed in-run 2026-07-30):** the
  generation **isn't 1:1** with the instruction. A tag/cue shapes the **section / region / arc** it sits
  in, not the exact line. Author the *forecast* (the overall trajectory + regional intent), place a cue in
  the region you want the effect, and let the model render it loosely. Lean on T1 sections for shape; T2–T3
  are directional nudges — don't write surgical line-level stage directions. **For precise phrasing, use
_line structure_ instead** — how you break the lyric lines *commands* delivery directly (confirmed in-run;
see the recipe's control hierarchy). Structure commands; tags forecast.

## Sources

Music terms (fact): [MasterClass — Song Structures](https://www.masterclass.com/articles/songwriting-101-learn-common-song-structures) ·
[Wikipedia — Song structure](https://en.wikipedia.org/wiki/Song_structure) ·
[Native Instruments — Dynamics](https://blog.native-instruments.com/dynamics-in-music/) ·
[SUNY Potsdam — Musical Terms](https://www.potsdam.edu/academics/crane-school-music/departments-programs/music-theory-history-composition/musical-terms) ·
[Wikipedia — Ostinato](https://en.wikipedia.org/wiki/Ostinato) / [Pedal point](https://en.wikipedia.org/wiki/Pedal_point).
Suno tag recognition (community leads, tier-flagged): [Jack Righteous Meta Tags Guide](https://jackrighteous.com/en-us/pages/suno-ai-meta-tags-guide) ·
[Musci.io — Suno Tags](https://musci.io/blog/suno-tags). Confirm which tags fire in-app.
