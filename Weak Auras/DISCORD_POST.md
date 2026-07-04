# Discord post draft - WeakAuras community documentation wishlist

Written 2026-07-05, grounded in this project's own WeakAuras research
(`CAPABILITY_INVENTORY.md`, `Docs/WEAKAURA_INDEX.md`, `reference_library.py`
section 9's db.ascension.gg survey, and the Necromancer build). Ready to
paste into a Discord channel as-is - Discord markdown (`**bold**`, numbered
lists) renders natively.

---

**WeakAuras on Conquest of Azeroth - what's actually unique here and worth documenting**

Generic WeakAuras knowledge (how triggers work, how conditions work, import/export mechanics) is already covered by the base game's own docs and the wider community - no need to reinvent that. What's genuinely specific to *this* server is the stuff no outside guide could ever cover, because it only exists here: 21 custom classes, custom spell IDs, and custom mechanics with no retail equivalent. A few gaps I think are worth the community closing:

1. **Per-class resource identity, confirmed in WeakAuras itself.** The database already tells you a lot (e.g. a spell's page will say "Cost: Runic Power" or "Give Power: Runic Power" in its effect text) - but that's the resource's *display name*, not proof of what WeakAuras' own Power-status trigger dropdown will actually show for that class. Those can differ. A living per-class table (resource name -> exact power-type string WA's trigger picker shows) closes a gap the database can't - either someone screenshots the picker, or (better) pulls it directly via `/devconsole` (see item 6 below).

2. **A curated, per-class WeakAuras spell-ID shortlist.** The database (db.ascension.gg) already has real per-spell pages by ID - cost, cooldown, range, effects, all there - and this client's own "Show IDs in Tooltips" option (item 6) puts the ID right on the tooltip once you're looking at the ability. What's still missing is the curation: there's no single "here are the dozen spell IDs that actually matter for your class's WeakAuras" list, so you're still hunting through a whole kit ability-by-ability to know which ones are worth tracking. A per-class sheet (ability name -> spell ID -> cooldown/duration/proc chance, filtered to what's actually WA-worth-tracking) turns "build a WeakAura for X" from a scavenger hunt into a copy-paste job.

3. **A glossary of custom mechanic names.** Several classes have unique resource/debuff mechanics that don't map onto anything from retail, and it's easy to get the name slightly wrong if you're going off memory instead of the actual tooltip text. A short "mechanic -> real in-game name -> what it does" reference per class would keep everyone's WAs (and conversations about them) consistent - again, nothing an outside source could supply.

4. **Which custom mechanics are genuinely untrackable.** Some server-side scripted effects appear to have zero client-visible footprint at all - no combat log event, no aura, nothing an addon can hook into. Worth a short "confirmed untrackable" list per class so people stop burning time trying to build a WeakAura for something that structurally can't be built, versus something that just hasn't been figured out yet.

5. **A single index of what already exists for this ruleset.** The CoA-tagged category on the database already has a good number of packs covering resource bars, CD suites, and stack trackers for several classes - but it's just a flat list, easy to miss, and specific to this server's own class roster. A pinned, maintained index ("this class -> these packs cover it, this class -> nothing yet") would stop people rebuilding the same aura from scratch.

6. **A guide to this client's own built-in dev tools.** Two things worth spreading awareness of, since they'd make half the items above much easier for anyone who knows they exist: an Interface option under Help called "Show IDs in Tooltips" puts the raw ID right on any tooltip (hover an ability, see its real ID - no outside lookup needed), and `/devconsole` opens a genuine in-game Lua console with commands like `dump`, `tinspect`, and `lookup` that can read live data straight out of the client - more direct ground truth than any external site or add-on. A short "what these do and how to use them" writeup would help a lot of people who are currently doing this the hard way.

None of this needs to be exhaustive on day one - even a rough per-class table people add to over time beats what exists now (nothing centralized). Happy to share what I've already dug up on a couple of these if it's useful as a starting point.

---

## Notes for Battlewrath (not part of the post itself)

- Cut the three items that were really "how WeakAuras works" rather than
  "what's unique to CoA": the nested-group/import-behavior engine quirks,
  the no-unit-token-for-extra-pets limitation, and the multi-condition
  glow-icon technique - all true on any server running this WeakAuras
  version, not specific to this one. Added item 4 (untrackable server-side
  mechanics) instead, since that genuinely can't come from anywhere but
  this server's own community.
- **Correction (2026-07-05): item 2's original claim that "no external
  database has these" was wrong - you were right to challenge it.**
  Checked `db.ascension.gg` directly: it's a real, server-rendered public
  database with a per-spell page at `?spell=<id>` for this server's exact
  custom IDs (verified against Necromancer's own Command abilities and
  Glacial Tap) - cost, cooldown, range, and effect data all present. Item
  2 is rewritten to reflect what's actually still missing: not the raw
  data, but a curated per-class shortlist of which IDs matter for WA
  building. This same check also resolved two of this project's own open
  items for the better: `necromancer_abilities_reference.html`'s
  `manaCost` field on the three Command abilities was a confirmed
  extraction bug (they really cost Runic Power - 30/20/30, per
  db.ascension.gg), and two of those abilities' names were wrong too
  (504050 is "Command: Decaying Colossus," not "Blight"; 504316 is
  "Command: Abomination," not "Hook"). Full corrected data now in
  `Necromancer/spell_index.md`.
- Item 1's Runic-Power-reuse guess is Necromancer-specific info from this
  project, generalized to "at least one class" for the post since the
  exact WeakAuras trigger-dropdown string is still unconfirmed live -
  soften or cut if you'd rather not reference your own hypothesis publicly
  before testing it, even though the resource's real name ("Runic Power")
  is now independently corroborated by db.ascension.gg's own spell pages.
- Item 5 ("index of existing packs")'s "good number of packs" is
  deliberately vague instead of citing the exact count/list from
  `reference_library.py` section 9 - post that full 14-entry table
  separately (or link the database category directly) if you want to name
  specific existing packs/authors.
- Nothing here names specific people, servers, or Discord channels -
  safe to post as-is, or trim to just the numbered list if you want it
  shorter.
- **Item 6 added (2026-07-06)** after you shared screenshots of
  `/devconsole` and the "Show IDs in Tooltips" Help option - full command
  list and details now in `DEV_TOOLS.md`. Both tools are custom/non-obvious
  enough that they're worth the community post on their own merits, not
  just as a footnote to items 1-2.
