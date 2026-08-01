# Suno — index

_The Suno manager's home: turning class identities into music. A **resident of
`Class_identity/`** — it *pulls from* the identities this lane imagines. **First-class within
Class_identity; secondary to the wider ecosystem** — the music is for Battlewrath, a personal
creative byproduct, not a core project pillar._

_This file is an **index** — a map to the materials the Suno manager reasons from. The
substance (a taste basis, a prompt library, the manager's own charter) is the **Suno manager's
to author** when it moves in. This lane scaffolds the landing; ownership stays with the owner._

## What this is

The Suno department, living inside Class_identity. It reads the class `IDENTITY.md` files as
inspiration — **loose: read-and-consider, never a contract** — and composes Suno music prompts
from them. Invention is licensed here; this is a creative space.

## The first job (before any prompt): define taste

The music is **for Battlewrath** — so his musical taste is grounded as a **basis** first, the
same fork the whole project runs on: don't invent-and-spiral on what he'd like; **source his
taste from his own references** (tracks, scores, artists, the game-music that lands), distill
the dimensions, reason from that. His taste is the one corner no source holds — the intent
corner, the same seat the class register sat in.

**Underway (opened 2026-07-30).** First taste-sourcing conversation held; taste is being captured as
**song-form specs** (see below). First form landed: [`forms/01_gothic-operatic.md`](forms/01_gothic-operatic.md).

## How this lane is organized: form vs content (Battlewrath, 2026-07-30)

> "Document that song form first. It's spec. The content is something we attach from that."

Two layers, kept clean:

- **Form = spec** (`forms/`) — Battlewrath's taste as pure *structure*: the pulse, the register, the
  instrumentation (in and out), the vocal architecture, the arc. **Necro-agnostic, reusable.** Sourced
  from him (the fork). One file per form; the playlist goal is a *mix*, so more forms land as siblings.
- **Content = attached** — the theme / mood / lyrical direction, layered onto a form. This is where the
  **loose pull from a class `IDENTITY.md`** happens (the gothic-necromancer *space*). Content-attachment
  is a separate layer, not yet built.
- **Prompt = form × content** — a form supplies a Suno prompt's *style/production/structure* half;
  content supplies the *theme/lyrics* half. The prompt library composes the two.
- **Levers = the Suno control surface** a prompt is expressed *through* — Styles, Exclude-styles, Lyrics
  mode, Weirdness, Style Influence, Duration… Documented as fact from the app in
  [`suno-levers.md`](suno-levers.md) (Pro · v5.5). A form's OUT-list becomes the **Exclude-styles** field.
- **Vocabulary = the words to author in** — song-structure & arrangement terminology (ostinato, antiphony,
  crescendo, pedal point…) mapped to the Suno meta-tags that express them, in
  [`song-structure-vocab.md`](song-structure-vocab.md). Feeds Driver-B lyric authoring + the Styles field.
- **Two drivers** (the recipe's spine) — **A: Prompt-driven** (theme + styles → Suno writes lyrics; fast,
  loose, for voice-as-instrument / volume) · **B: Write-driven** (custom lyrics + meta-tags; full arc &
  vocal-architecture control; the showcase cuts). Method in [`prompt-recipe.md`](prompt-recipe.md).
- **Composed prompts** live in [`prompts/`](prompts/) — copy-paste-ready lever sets.
  - [`necromancer_02_funeral-march.md`](prompts/necromancer_02_funeral-march.md) (+v2/v3) — form 02 ×
    necromancer, Driver B. **Run + kept as _"Forsaken in requiem aeternam,"_ the lane's first named track;**
    v3 drove out the method (banshee callable, forecast-tags, line-structure command).
  - [`necromancer_01_gothic-operatic.md`](prompts/necromancer_01_gothic-operatic.md) — form 01 ×
    necromancer, **in service of the Dark Lady (Sylvanas)**; driving war-march, banshee at the peaks.
    **Ran strong on all four dims — the method transfers.**
  - [`necromancer_03_dark-vaudeville.md`](prompts/necromancer_03_dark-vaudeville.md) — form 03
    (organ-forward bend) × necromancer, **"The Maestro of the Dead"**; sinister-playful gallows-whimsy
    waltz on a grand gothic pipe organ. **Ran well — musical sections + snappy/witty delivery.**
  - [`necromancer_04_grand-theatrical.md`](prompts/necromancer_04_grand-theatrical.md) — form 04
    (first track) × necromancer, **"Rise of the Grave"** (her command of power); grand symphonic-metal —
    power chords + sharp tone enter the necromancer sound; operatic lead, banshee at the peak.
    **Ran — "lands really well"; form 04's first live test passed.**
  - [`necromancer_rise-of-the-grave_01.md`](prompts/necromancer_rise-of-the-grave_01.md) — **A/B test:**
    *Rise of the Grave*, **same lyrics** rendered as form 01 (organ-grand, no guitar) to isolate the
    form's contribution against the 04 version. **Result: both great; taste leans 01** — established the
    weighting *01/02/03 = core, 04/05 = for a change.*
- **Summonable features = the callable catalog** — qualities discovered in real runs and made reproducible
  (summon by design, not luck), in [`summonable-features.md`](summonable-features.md). Battlewrath's
  principle. First entry: the **banshee wail**.

_His **taste** is not a necro thing — it's operatic-gothic-darkwave on its own terms. The **playlist's
job** is to hold him in the character's space while he plays. Taste is the form; the mood is attached._

## Index — materials to pull from

**The class identities (the feel to score):**
- [Necromancer](../Necromancer/IDENTITY.md) — the Forsaken victim-who-became-master; a mood
  seed is already inside it (`## For the puller`). _More classes as the lane populates them._

**This lane (how an identity is made):**
- [Class_identity charter](../README.md) · [method](../METHOD.md) — what an identity is, the
  four facets, the loose-reach rule.

**The wider ecosystem (why any of this works this way):**
- [operations/WHAT.md](../../operations/WHAT.md) · [operations/HOW.md](../../operations/HOW.md)
  — the project's telos + the fact-basis method (§0, the fork).

## Song forms (spec — the taste basis, as it fills in)

**Taste weighting (Battlewrath, 2026-08-01, from the _Rise of the Grave_ A/B):** his core leaning is the
**guitar-free grand-gothic register — 01 / 02 / 03** (organ, choir, cello, bells; the necromancer's native
sound). **04 / 05** (the heavy guitar forms) are good and *have a place* — but as **a change of pace**, not
the default. Weight the playlist mostly 01/02/03, with 04/05 sprinkled for variety.

- [`forms/01_gothic-operatic.md`](forms/01_gothic-operatic.md) — **Gothic Operatic (Driving Swell).**
  Fixed driving floor (fractional subdivision, heavy percussion, bass-rich) under an operatic swell;
  grand organ + low strings + choir/chant + church-bells-as-hi-hat, harpsichord welcome, piano minimal;
  **no guitar, no synth-focus, not classical/atmospheric**; voice-as-instrument (cadence over meaning);
  **drive, never chaos** (frantic only as a builder). Avoids atmosphere on purpose.
- [`forms/02_funeral-march.md`](forms/02_funeral-march.md) — **Funeral March (The Last Breath).** The
  deliberate complement — **all atmosphere, but never directionless**: a funeral-drum tread (bells
  prolonging each strike) carries the atmosphere *forward* instead of drifting. Voice core = **pure
  Gregorian chant corrupted by desperation** — not angelic, the *last breath of the lungs*, sung spent.
  Lead **and** chant contend (concert / absence / lead-dispels / chant-overwhelms). Layers = a shared
  palette whose **focus rotates per song**. _(Open rim: arc — in-file.)_
- [`forms/03_dark-vaudeville.md`](forms/03_dark-vaudeville.md) — **Dark Vaudeville (Gallows Whimsy).**
  The whimsy corner — **01 drives the dark, 02 grieves it, 03 laughs at it.** Steampunk cabaret / dark
  vaudeville: a wry macabre *persona* griping (zombie's-eye-view, alchemist's complaints) over
  **shanty roll + waltz lilt**; guitar-free, theatrical, tongue-in-cheek. Whimsy edge (gallows / absurd /
  sinister-playful) **rotates per song**. Playful space → clockwork/music-box tinkle + cabaret piano
  welcome (it bends the not-tinny rule the grand forms keep).
- [`forms/04_grand-theatrical.md`](forms/04_grand-theatrical.md) — **Grand Theatrical Heavy (The Full
  Peak).** The guitar arrives — **01's operatic drama gone full-electric**: the metal wall 01 left out,
  in service of **theatrical bombast** (Nightwish grandeur, MCR pageantry, Ghostfire). Grand, anthemic,
  melodic, cathartic; powerful *melodic* voice, not guttural; the over-the-top form, big-but-earned.
  Graded — a clear pass.
- [`forms/05_industrial-heavy.md`](forms/05_industrial-heavy.md) — **Industrial Heavy (Cold Machine).**
  The cold half of the split — **hard, machine-driven, martial, horror-tinged** (Rammstein, Rob Zombie).
  Catharsis through *force*, not grandeur; **harsh/guttural vocals** (the one new vocal color in the set);
  industrial synth welcome under the guitars; drive-not-chaos at its most mechanical. Graded — a clear pass.

## Coming (this folder — owned by the Suno manager)

- **More song forms** — other modes, as siblings in `forms/`, toward the varied playlist.
- **Content-attachment layer** — how a class identity's mood attaches onto a form (form × content).
- **Prompt library** — Suno prompts composed from form × content, pulling from the identities.
- **Charter** — the Suno manager's founding directive.
