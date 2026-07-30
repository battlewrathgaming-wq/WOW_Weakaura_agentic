# Class identity — the method

_How a class's identity is invented from source. Pairs with `README.md` (the
charter + the boundary); this file is the reasoning floor — *what* we distill and
*how*. Class specifics live in `<Class>/IDENTITY.md`; this holds what's universal._

## The move: consume → imagine

One direction, disciplined at both ends:

1. **Consume the source** — read the real flavor (ability text, names, schools,
   the client's tone). Not to catalog it; to *soak* in it until the class's
   register is felt.
2. **Imagine the feeling** — distill that into identity across the facets below.
   This is invention, and it's *meant* to be — but invention **fed by** the
   source, never floating free of it (README, "invented from source").

The output is an **imagined feeling, offered outward** — never a rule, never a
claim about how the game works.

## The sources — two kinds

Both feed the imagining; they do different jobs:

- **COA-grounding** (`Input/<class>_talents.json`, `coa_spells`, the client,
  `Class_design/`) — pins *which* feeling is **this** class's, in **this** game.
  Ability names and flavor are the spine; without them the identity drifts to
  generic fantasy.
- **Archetype foundations** (the broad lore a class descends from — e.g.
  Warcraft/WoW lore and the D&D / Forgotten Realms roots) — widen the well: the
  register, the psychology, the material palette a whole tradition carries. Named
  inspiration, **feel only** — never a claim about COA.

The wikis give the *palette of possible feelings*; the COA source + the player's
intent choose *which one is real here*. (Necromancer, proven: WoW's Scourge lore +
D&D's Undead-Master archetype, pinned by COA's own *Scourge Disciple* talents and
the player's Forsaken frame.)

## The four facets (what we distill per class)

- **Archetype** — the power fantasy; who you *are* when you play this. (The
  Necromancer as puppeteer of the dead, not merely a caster of decay.)
- **Register** — the emotional tone. Dread · grandeur · melancholy · savage
  glee · cold patience. The mood a scene in this class's key would be scored in.
- **Narrative** — the story and its relationships: what this class's power
  *costs*, what it reveres, what it's at war with (death, the soul, plague, the
  grave).
- **Sensory palette** — the material a composer or artist reaches for: sound,
  texture, color, motion, instrument. Bone-rattle, dirge, low choir, viscera,
  green witchfire. **The corner Suno pulls from most.**

Not a rigid schema — a **lens.** A class may lean hard on one facet and barely
touch another. The facets serve the feeling, not the reverse.

## The honest boundary

Everything here is **imagined and sourced, never mechanical.** No cooldown, no
stat, no rotation, no "how it works." A mechanic that appears is *texture only*.
The rule-layer belongs to `Class_design/` and the engine (`operations/HOW.md`).
Name the boundary; never fake across it — in either direction.

## The reach is loose (not a contract)

Consumers **read `<Class>/IDENTITY.md` and consider against it** — inspiration,
not specification. They may diverge and invent; that is the *point* of a creative
pull. Nothing downstream is *bound* to what's written here. (Contrast the
structured pipeline, which is bound to its sources by design — a different kind
of work. Invention lives here; determinism lives there.)

## Running it (per class)

1. Consume the source until the register is felt — both kinds: the COA flavor
   (`Input/<class>_talents.json` first) and the archetype foundations (the lore
   the class descends from).
2. Distill across the four facets — lean where the class leans.
3. Emit `<Class>/IDENTITY.md` — evocative, outward-facing, sourced where a detail
   came from a real read. **Feel, not fact.**
