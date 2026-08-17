# research_routing — what dungeon route guides and routing tools actually convey

_Independent web research, 2026-08-17. Data only; no recommendations. Quotes are short and cited. Where a source could not be fetched (403 / empty shell) it is marked UNREACHABLE and only what search snippets showed is used._

Reachability note: wowhead.com guide pages returned only the page shell (comments/nav) to the fetcher — guide bodies could not be read; wow-pro.com, warcrafttavern.com, speedrun.com, raider.io news, method.gg partially, and youtube returned 403/empty. Substitutes were used (GitHub wikis/source, Icy Veins, Maxroll, Method, mapsfortanks, almarsguides, ConquestCapped, Raider.IO support KB, MDT locale file).

---

## R1. Per source

### 1. Mythic Dungeon Tools (MDT) — the addon

**What it conveys.** A *plan* of which enemies to kill, grouped into ordered pulls, on a shipped map of the dungeon, with a running "Enemy Forces" total; optional freehand drawings, arrows, lines and text notes placed on the map. It is a planner: "a Mythic+ Dungeon Planner AddOn which helps you perfectly plan out your strategies and pull patterns" (CurseForge). "Every NPC in every Mythic+ dungeon has been mapped out and can be viewed on an interactive map" (CurseForge). Nothing in the description says it guides movement during a run; third-party companions (below) add "which pull is next".

**Form.** Map drawing (interactive dungeon map, sublevels/floors) + a numbered pull list (sidebar) + a forces progress bar. Drawings: "Drawing: Arrow", "Drawing: Eraser", "Drawing: Freehand", "Drawing: Line", "Insert Note", "Note Text:" (enUS.lua). Pull list ops: "Add pull", "Clear Pull", "Clear Pulls", "Insert after", "Insert before", "Merge", "Move down", "Move up" (enUS.lua). Pulls are colour-coded ("Automatically color pulls").

**Vocabulary (verbatim strings).** "Enemy Forces" · "Add pull" · "New Route" / "Preset Name" / "Route Name" (the code calls it a *preset*, the UI calls it a *route*) · "Sublevel" / "Dungeon Level" / "Select the dungeon level" · "Dungeon Entrance" · "New Patrol Waypoint at Cursor Position" · "Mouseover a patrolling enemy with a blue border to view the patrol path" · "Import Route" / "Import a route from a text string" / "Export the route as a text string" · "Share the route with your party members" · "Live" / "Live Session" · "Make this route the live route" · "Open Enemy Info" · "Hold SHIFT to create a new pull while selecting enemies." · "Drag enemies on the map to move them into pulls." (all: https://raw.githubusercontent.com/Nnoggie/MythicDungeonTools/master/Locales/enUS.lua). README feature list: "Patrol paths for all patroling NPCs", "Enemy forces for every npc and dungeon", "export/import via paste strings", "Ingame sharing functions to share routes with party members" (https://github.com/Nnoggie/MythicDungeonTools/blob/master/README.md).

**How position is described.** Not in words. Position is a point on the shipped map image; enemies sit at mapped x/y per sublevel; a pull is a set of enemy ids; drawings and notes carry map x/y. No coordinates are shown to the player as text.

**How progression / next is expressed.** Pull *index* (1..N) in the pull list; a "current pull" is the selected pull in the editor. No arrival, no in-run advancement in core MDT. Companions: *MDT – Next Pull Tracker* "watches scenario forces, figures out which pull of your route is the one the tank is about to grab" and shows "Pull X / Total, current pull status, live forces percentage" — "no Combat Log dependency" (https://www.curseforge.com/wow/addons/mythicdungeontools-nextpulltracker ; https://github.com/KevinCalmant/MythicDungeonTools_NextPullTracker/blob/main/README.md). *MDT Guide* "automatically zoom to the current/next pull based on your planed route and current enemy forces" and "Color dead enemies and your current/next pull differently" (https://curseforge.com/wow/addons/mdt-guide). Both infer progress from the M+ *scenario enemy-forces counter*, i.e. a retail-only server-fed number.

**Live mode.** Cooperative editing, not driving: "The route will continuously synchronize between all party members participating in the Live Session" (enUS.lua); "Live mode for cooperative editing of routes including drawing, selecting enemies" (README).

**Sharing.** Export/import as a paste string (a serialized+compressed preset, `!`-prefixed in practice), or in-game send to party ("Share the route with your party members"). Third-party sites (keystone.guru, Icy Veins, Maxroll, wago.io) distribute MDT strings.

**Shipped vs authored.** SHIPPED: dungeon map textures, sublevels, every NPC's position, health, enemy-forces value, patrol paths, boss positions, seasonal affix data. AUTHORED by user: pull membership/order, drawings, notes, route name.

**Data structure (from source, field names).** `preset.value` carries `currentPull`, `currentSublevel`, `pulls`, `objects` (drawings/notes), `selection`, `currentDungeonIdx`, `teeming`, `difficulty`, `week` (https://raw.githubusercontent.com/Nnoggie/MythicDungeonTools/master/MythicDungeonTools.lua). Live transmission prefixes seen in forks: "MDTLiveNote", "MDTLivePull", "MDTLivePreset" (search snippet; Transmission.lua raw fetch 404).

URLs: https://www.curseforge.com/wow/addons/mythic-dungeon-tools · https://github.com/Nnoggie/MythicDungeonTools · https://noobtoboss.com/addon/mythic-dungeon-tools-mdt/ · https://mmonster.co/blog/wow-mythic-plus-dungeon-tools · https://www.wowhead.com/guide/how-to-use-mythic-dungeon-tools-addon-guide (UNREACHABLE body).

### 2. keystone.guru — the web planner

**What it conveys.** Same object as MDT — pulls of enemies on a shipped map to reach 100% enemy forces — plus a drawn *path*, free-drawn lines, icon+comment annotations, per-pull descriptions and per-pull ability assignments, difficulty attributes, publishing/sharing. README: "Plotting a path through the dungeon, allowing a route to split up should the need arise" · "Free-drawing of lines" · "Easy creation of pulls of which enemies to kill and optionally where" · "Add a description to a pull" · "Assign abilities that your party should utilize directly to a pull" · "Various icons with optional comments to indicate difficult enemies, strategies to use or abilities to use" · "Attach attributes to your route to give an indication of difficulty (death/invisibility skips or classes required)" · "Full import/export support for Mythic Dungeon Tools strings" (https://github.com/Wotuu/keystone.guru). Launch post: "All enemies, their packs and patrols are mapped and visible" · "Zoom-able maps of all dungeons and floors" · "Easy sharing (short links!)" (https://www.mmo-champion.com/threads/2444077-Keystone-guru-a-website-for-planning-your-M-routes).

**Form.** Web map with layered objects (path polyline, brushlines, killzones/pulls, map icons with comment text, raid markers on enemies), a pull sidebar list, floating enemy-forces bar; route listing pages with author, dungeon, level ("+2", "+25"), enemy forces % ("100%", "104%"), views, "Community routes" (https://keystone.guru/ ; https://keystone.guru/routes).

**Vocabulary.** "killzone" / "Kill Zone" (older term for a pull, a bullseye marker on the map where the pull is killed) — later made optional because "The average player doesn't typically think about 'where' they will kill a mob first" (https://github.com/RaiderIO/keystone.guru/issues/116); "pull" (replacement/backend term); "path"; "enemy forces"; "enemy pack"; "patrol"; "floor"; "map icon"/"comment"; "raid marker"; "MDT string"; "published"/"private"/"team"; "affix"; "Teeming"/"Infested" enemies; "sandbox" (try mode). v2.2 notes: "Adding enemies to a Killzone", "Enemy forces are now displayed in the above mentioned floating bar" (https://github.com/RaiderIO/Keystone.guru/releases/tag/v2.2).

**How position is described.** Map x/y on a shipped floor image; killzone = an explicit *where* marker (optional); path = drawn polyline; icons/comments pinned to points. Route viewer: "When you click on a pull, it will highlight it on the pull list, and then also highlight where that pull is" (https://support.raider.io/kb/auto-route-creator/how-do-i-view-a-route-on-keystone-dot-guru).

**How progression / next is expressed.** Pull order in the sidebar; the path polyline's direction; no in-game component at all (web only). Real-time co-editing "Google Docs-style".

**Sharing.** Short links; publish private/team/everyone; MDT string copy ("Copy MDT String button" — https://support.raider.io/kb/auto-route-creator/how-do-i-export-a-route-to-method-dungeon-tools-mdt); embed.

**Recorded-run derivation (relevant adjacent).** Raider.IO *Auto Route Creator* builds a keystone.guru route from a run "live tracked by our desktop client": it shows "when the group killed certain mobs, bosses, and when anyone died", per-pull "exact percentage each pull is worth, as well as where that pull is located", and can "export the run to Method Dungeon Tools" (https://support.raider.io/kb/auto-route-creator/what-is-the-auto-route-creator ; https://support.raider.io/kb/auto-route-creator). It reconstructs *pulls* (kill sets, in order) — it does not claim to reconstruct the players' walked path.

**Shipped vs authored.** SHIPPED: floors, enemies, packs, patrols, forces, affix data (mirrors MDT's DB; footer shows "MDT v6.2.2" version tracking). AUTHORED: pulls, path, brushlines, icons+comments, pull descriptions, attributes, title.

### 3. Written dungeon route guides (M+ era and older WotLK/Classic)

**M+ era (Icy Veins / Maxroll / Method / ConquestCapped / raider.io Weekly Route / Wowhead).**
- Dominant form: **an MDT import string** (+ sometimes a static route map image), with prose reduced to per-boss trash notes. Maxroll's Ara-Kara route section is an MDT string ("!1z1YUTnmqWFNE08PKo2xanxCcGcsb6bcyhtfO...") + one image "Ara-Kara, City of Echoes Route" + the line "It is recommended to use the Mythic Dungeon Tools addon to look at your route" (https://maxroll.gg/wow/dungeons/ara-kara-city-of-echoes-guide). Method links a wago.io MDT route ("Ara-Kara, City of Echoes M+ Dungeon Route: https://wago.io/kDwiwnRGA") and otherwise organises by boss trash sections with no spatial prose (https://www.method.gg/guides/dungeons/ara-kara-city-of-echoes). Icy Veins' weekly page is per-dungeon "Path" sections built around MDT (https://www.icy-veins.com/wow/weekly-mythic-dungeon-mdt-routes ; guide body not in fetch). Tanknotes points tanks at MDT/keystone.guru/Raider.IO rather than writing pulls: "automatically calculate the mob percentage on a pull by pull basis" (https://tanknotes.com/mythic-plus/tank-resources/).
- Where prose exists, a route step reads: **direction + verb + counted mobs + skip clause + cooldown note.** ConquestCapped: "Head to the right and kill x1 Creeping Spindleweb" · "Go to the left corridor killing all the enemies" · "ignoring the Animated Codex packs" · "Ignore mobs in the center of the third area" · "use Bloodlust or Heroism for large pulls" · counts as "x1 [mob], x15 [mob], x2 [mob]" (https://conquestcapped.com/guides/wow/mythic-plus-routes/). Skip guides use annotated map images: "Follow the red arrows to make the skip and once you reach the mob targeted by the blue arrow" (https://www.icy-veins.com/wow/mythic-rogue-shroud-of-concealment-trash-skips).
- Position words: "left corridor", "central part", "third area", "left and right walls in the final room", "directly to", "bypass", "head towards"; never coordinates.
- Progression: numbered steps / "then"; boss-section headings act as milestones.
- Vocabulary: route, pull, pack, skip, pat/patrol, count/percentage/enemy forces, invis pot / shroud, "wall pulling" (Icy Veins forum comment).

**WotLK-era / Classic written guides (Icy Veins WotLK Classic, Almar's, mapsfortanks, wowisclassic, eintr.net tank maps).**
- Form: boss-by-boss text; a map image (sometimes with boss numbers); very thin trash/route prose. Icy Veins WotLK Classic Halls of Lightning and Culling of Stratholme guides contain no layout/trash sections — only entrance ("Talk with the dragon to fly down and head to the far left") and boss mechanics (https://www.icy-veins.com/wotlk-classic/halls-of-lightning-dungeon-guide ; https://www.icy-veins.com/wotlk-classic/the-culling-of-stratholme-dungeon-guide).
- Where route prose exists it is **landmark narrative**: Icy Veins Strat UD: "you will follow a short corridor to a gate" · "head to the opposite side from where you entered" · "A gate to the west will have been opened" · "double back slightly" (https://www.icy-veins.com/wow-classic/stratholme-undead-dungeon-guide). Almar's Azjol-Nerub: "Kill the 3 packs of mobs before the boss, then the boss." · "Clear the 3 groups in the room after the bridge" (https://www.almarsguides.com/wow/Instances/WoTLK/Azjol-Nerub/). Almar's WotLK heroic achievement guide: "have everyone run to the center of the tunnel (Where the earth elemental is)" · "pull everything down to the end of the Gauntlet" (https://www.almarsguides.com/wow/achievements/wotlkheroic.cfm). mapsfortanks BRD: "Pass through the Ring of Law to get to Shadowforge City" · "go up the stairs to your right" · "Clear out the anteroom and engage Warder Stilgiss and Verek"; legend "A '*' on the map indicates quest activity" (https://mapsfortanks.wordpress.com/2012/06/13/blackrock-depths/ ; https://mapsfortanks.wordpress.com/).
- Tank maps (Aetherflask lineage, rehosted at eintr.net): the route is an **image** — dungeon map with drawn path, numbered bosses, patrol marks; text minimal (https://eintr.net/WoW/World-of-Warcraft-Classic-Dungeon-Walkthrough.html).
- Position words: gate, corridor, courtyard, ziggurat, bridge, ramp, stairs, room, tunnel, "opposite side", "to your right", "north side", "far left"; skips as "hug the wall" (mmo-champion snippet: "hugging the wall, to see if they could slip by").
- Progression: sequential prose, boss numbering, "once all 3 of them are dead Hadronox will come" (event gates).
- Shipped vs authored: authored prose + a hand-annotated map image; relies on the reader recognising named landmarks; no data.
- Wowhead classic/WotLK guide bodies UNREACHABLE (shell only): https://www.wowhead.com/classic/guide/stratholme-undead-dungeon-strategy-wow-classic ; https://www.wowhead.com/wotlk/guide/utgarde-keep-overview.

### 4. Speedrun / dungeon-route communities (Classic/WotLK)

**What could be established.** speedrun.com leaderboard/guide pages and warcrafttavern speedrun pages were UNREACHABLE (403); YouTube descriptions unreadable. From reachable text: categories "any%" and "all bosses%" (speedrun.com snippet); "prepare gear, set up macros, and plan your route" (search summary); route knowledge phrased as "know which trash to skip", "pulling multiple rooms at once", "skip bosses", "practice a full run once or twice" (https://thelighthouseworks.com/how-to-speedrun-classic-dungeons-for-fun/). Warcraft Tavern defines run start/end by geometry/aggro: runs "start when anyone aggros mobs or crosses certain lines" (search summary; https://www.warcrafttavern.com/wow-classic/dungeon-speed-run/ UNREACHABLE). A speedrun WeakAura exists ("Domain Expansion Speedrun - Stratholme", https://wago.io/YnZPxBp41 — body UNREACHABLE).

**Form (as far as visible).** Video runs with commentary ("Undead Stratholme 8 Minute Clear ... Analysis and Commentary", https://www.youtube.com/watch?v=Z5tcBsrcVek), YouTube playlists titled "Speedrun Route Guide" (https://www.youtube.com/playlist?list=PLP7Djb3ElUR1xEqZgSh3zPIErY2Fh0wgz), forum/Discord notes, WeakAura timers. No standard written notation surfaced; the route lives in the video and in the runner's head, with prose limited to what to skip and where the timer starts/ends.

**Vocabulary (from snippets/comments).** any%, all bosses, skip, pull (multiple rooms), reset, split (timer), invis pot / stealth / "no stealth", wall-hug, aggro line, LoS.

**Position.** Landmarks and "lines" (start/finish crossing lines), video frames.

**Progression.** Timer splits per boss; kill of final boss ends the run.

**Shipped vs authored.** Nothing shipped; entirely authored knowledge + a video.

### 5. Step-driving addons on 3.3.5 (TourGuide / WoW-Pro / Zygor)

These are the only in-game *drivers* found. All three drive **quest/leveling** content, and all rely on a **hand-authored step DSL + a coordinate arrow (TomTom / own arrow) + auto-advance from game events**.

**TourGuide (Tekkub; ported to 1.12/3.3.5).** Line grammar `<ActionLetter> <Title> |TAG|value|...|`. Actions: A accept, C complete, T turn-in, K kill, N note, R run, F fly, H hearth, h set hearth, f flight point, U use, B buy, b boat. Tags `|QID|`, `|N|note|`, `|L|item|`, `|U|item|`, `|O|` optional, `|Z|Zone|`, `|C|classes|`, `|R|races|`, `|QO|objective|`, `|PRE|`, `|NODEBUG|`. Auto-complete: accept "when the objective name is found in the quest log"; travel steps "zone change when the title matches"; arrow: "Entering a coordinate in the format '(12,34)' ... in the note will automatically set up a TomTom waypoint" (https://warcraft.wiki.gg/wiki/TourGuide/Guide_Creation ; https://github.com/TekNoLogic/TourGuide). Example lines: `A Accept Quest |QID|####|`, `N Guide #1 |N|This is where your guide will go|`.

**WoW-Pro Guides addon (successor; syntax page https://www.wow-pro.com/wow-pro-addon-syntax/ UNREACHABLE; GitHub wiki used).** Grammar "`<Action> <Step>|<Tags>|`" with tag classes "Flavor Tags", "Context Tags", "Activation Tags", "Completion Tags" (https://github.com/Ludovicus-Maior/WoW-Pro-Guides/wiki/Step-Processing-Theory). Actions add P portal, l loot, L level, r repair, `;` comment, `$` treasure. Movement-completion tags: `|M|x,y;x,y|` coordinates ("multiple separated by semicolons"), `|CC|` "auto-complete at final waypoint only", `|CS|` "auto-complete only in sequence", `|CN|` markers only; `|Z|Zone|`; `|IZ|Zone|` show only in zone; `|S|` sticky, `|US|` unsticky; `|O|` optional; `|ACTIVE|`/`|AVAILABLE|`/`|PRE|`/`|LEAD|` gates; `|NC|` non-combat icon; `|T|NPC|` target; `|U|item|` use button; `|L|item|` completes on loot (https://github.com/Ludovicus-Maior/WoW-Pro-Guides/wiki/Addon-Syntax). Verbatim examples: `R Run to Goldshire |QID|12345|M|42.00,65.00|N|Follow the road to Goldshire.|` · `K Kill Vile Familiars |QID|792|M|44.7,57.7|N|Kill the Vile Familiars in the north.|` · `N Dismount |AVAILABLE|10041|N|You can't mount for next quest. Manually advance.|` · `A Wanted: Dreadtalon |QID|12091|N|From the Wanted Poster just outside the door.|`. Auto-completion table: R/F/b/H/P "Reaches destination zone OR coordinate via |CC||CS|"; N "Manual advancement required". Design intent: "just have them 'follow the arrows'" (https://github.com/Ludovicus-Maior/WoW-Pro-Guides/wiki/How-To-Contribute). A "WoW-Pro Dungeons" module was announced to "make use of the WoW-Pro Guide frame, showing steps" for dungeons (https://www.wow-pro.com/wow-pro-dungeons-addon/ UNREACHABLE; snippet only) — no dungeon step examples were retrievable.

**Zygor Guides Viewer (3.3.5a forks on GitHub).** Guides are Lua strings registered via `ZygorGuidesViewer:RegisterGuide("Name\\Sub", [[...]])` with a `next` guide link. Steps are `step` blocks: `goto Zone,x,y` / `goto x,y`, `.talk NPC##id`, `..accept Quest##id`, `..turnin Quest##id`, `.from Mob##id+`, `.get 8 Item|q 33/1`, `.kill`, `.use`, `.click`, `only Human Mage`, plus modifiers `|q` (quest/objective tracker), `|c` (completion), `|noway` (no waypoint), `|tip`, `|n`, `|next`, `|only`. Verbatim: `step //5` / `goto 47.4,39.7` / `.from Diseased Young Wolf##299+` / `.get 8 Diseased Wolf Pelt|q 33/1` (https://raw.githubusercontent.com/ErebusAres/ZygorGuidesPlus_3.3.5a-WOTLK/main/ZygorGuidesViewer/Guides/ZygorGuidesAlliance.lua ; also `...|goto 22.6,57.0,0.3|use Surge Needle Teleporter##36747|noway|c` from a CATA fork snippet). Viewer: "The number tells you which step you are currently on"; arrows "skip ahead or back through the guide steps"; "Step Based ... green bar" progress (https://zygorguides.com/support/manual/controls). Arrow: "special 3D Waypoint Arrow ... shows you exactly where to go"; "every step of the guide that requires you to be at specific location" carries coordinates (https://zygorguides.com/support/manual/waypoint). Kill lines "dynamically updates as you kill each mob to show how many you have remaining" (zygorguides manual snippet). Remaster README: "Guide parser and step engine", "Map and waypoint workflow", "Arrow and waypoint navigation" (https://github.com/ErebusAres/ZygorGuidesRemaster-3.3.5a_WOTLK).

**Ascension-specific.** No dungeon-step driver found for Ascension/CoA; addon lists mention TomTom (arrow, `/way`, `/tway`), Carbonite ("Maps, Guide, HUD (TomTom Emulation)"), AtlasLoot, with the caveat that "addons that rely on predefined game data ... may not work as intended" on custom content (https://noobtoboss.com/ascension-wow-addons/ ; https://conquest-of-azeroth.wiki/tools/addons-guide/ ; https://project-ascension.fandom.com/wiki/Project_Ascension_AddOns — search snippets).

**Shipped vs authored (all three).** SHIPPED: world map coordinate system (zone x/y), quest log/quest IDs, item IDs, NPC IDs, zone/subzone names, flight-point events. AUTHORED: every step line, its coordinates, its note, its completion tag.

---

## R2. Cross-source table

| Concept | MDT | keystone.guru | M+ written guides | WotLK/Classic written / tank maps | Speedrun community | TourGuide / WoW-Pro / Zygor |
|---|---|---|---|---|---|---|
| a step | a **pull** (index in pull list) | a **pull** / **killzone** in sidebar | numbered prose step ("Head to the right and kill x1 …") | a paragraph / a numbered boss | a segment between timer splits / a video chapter | a **step** line: `<Action> Title |tags|` / `step` block |
| a place | map x/y on sublevel (never worded) | map x/y on floor; **killzone** marker "where"; **map icon** | landmark words: "left corridor", "third area", "final room" | landmark words: gate, corridor, bridge, ramp, "to your right"; boss number on map image | landmarks, "lines" (aggro/start lines), video frame | `|M|x,y|` / `goto x,y` (zone coordinates) + `|Z|Zone|`; arrow points |
| a pull | **pull** = set of selected enemies; "Enemy Forces" % | **pull**/**killzone** = enemies + optional where; "enemy pack" | "pull", "pack", counted "x15 [mob]" | "pack", "group", "clear the room" | "pull", "pulling multiple rooms" | (n/a; `K Kill …` / `.from Mob##id+` / `.kill`) |
| a skip | absence from any pull; drawings/notes; keystone attribute "invisibility skips" | attributes "death/invisibility skips"; icons "strategies to use" | "ignoring …", "Ignore mobs …", "skip", "invis pot", "shroud", red-arrow map | "you can skip", "hug the wall" | "skip bosses", "know which trash to skip", "no stealth" | `|O|` optional step; a step simply not present |
| a note | **Note** ("Insert Note", "Note Text:") pinned on map | **map icon** with **comment**; **pull description** | inline sentence in the step | inline sentence | video commentary | `|N|text|` / `.tip` / `N Note` step |
| a boss note | enemy info window (shipped abilities); notes | icon "difficult enemies"; pull description | boss section heading + mechanics prose | boss section prose ("Put yourself against the wall …") | commentary | (quest-centric; no boss primitive) |
| order | pull index; "Move up/down", "Insert before/after" | sidebar order; drawn **path** direction | numbered steps / "then" | prose sequence; boss numbering 1..N | boss order = split order | line order in file; `next` guide link; "The number tells you which step" |
| arrival | none in core (companions: forces-% advance) | none (web) | none | none | crossing "certain lines" (timer rule) | `|CC|`/`|CS|` coordinate reach; zone-change match; quest events |
| sharing | "Export the route as a text string" / import string; "Share the route with your party members"; Live Session | short link; publish private/team/everyone; MDT string; embed | MDT string / wago.io link + image | image + page | video link | guide file (Lua/text) distributed with addon |

---

## R3. The recurring step grammar

The smallest unit across guides is: **[go to a place, in landmark or coordinate terms] + [do a verb on a counted target] + [optional skip/avoid clause] + [optional note/cooldown]**, with completion either manual (prose, images) or event-driven (quest log / coordinate reach / zone change in step-drivers; forces-% in MDT companions).

Verbatim examples (short):

1. "Head to the right and kill x1 Creeping Spindleweb" — https://conquestcapped.com/guides/wow/mythic-plus-routes/
2. "Go to the left corridor killing all the enemies" — same
3. "Kill the 3 packs of mobs before the boss, then the boss." — https://www.almarsguides.com/wow/Instances/WoTLK/Azjol-Nerub/
4. "Clear the 3 groups in the room after the bridge" — same
5. "go up the stairs to your right" — https://mapsfortanks.wordpress.com/2012/06/13/blackrock-depths/
6. "head to the opposite side from where you entered" — https://www.icy-veins.com/wow-classic/stratholme-undead-dungeon-guide
7. `R Run to Goldshire |QID|12345|M|42.00,65.00|N|Follow the road to Goldshire.|` — https://github.com/Ludovicus-Maior/WoW-Pro-Guides/wiki/Addon-Syntax
8. `goto 47.4,39.7` / `.from Diseased Young Wolf##299+` / `.get 8 Diseased Wolf Pelt|q 33/1` — https://raw.githubusercontent.com/ErebusAres/ZygorGuidesPlus_3.3.5a-WOTLK/main/ZygorGuidesViewer/Guides/ZygorGuidesAlliance.lua
9. "Follow the red arrows to make the skip and once you reach the mob targeted by the blue arrow" — https://www.icy-veins.com/wow/mythic-rogue-shroud-of-concealment-trash-skips

Observed regularities (data): direction words are relative to the player's facing on entry ("to your right", "opposite side"); places are named by architecture (gate, bridge, ramp, room, corridor, courtyard) or by ordinal area ("third area", "final room"); targets are counted ("x1", "3 packs", "8 pelts"); M+ prose collapses to an MDT string as soon as a tool exists to carry the geometry.

---

## R4. What none of them do

- **None drives the player through a *dungeon* in-game with arrival detection.** MDT/keystone.guru are planners with no arrival concept; MDT companions advance on the retail M+ *scenario forces counter* (server-fed), not on position or kills. TourGuide/WoW-Pro/Zygor do arrival detection (`|CC|`/`|CS|`, zone change, `goto`) but for **overworld quest steps** using zone x/y coordinates and quest-log events; no retrievable dungeon-step guide from them was found (WoW-Pro Dungeons module page unreachable; described only as reusing the guide frame).
- **None works without shipped per-dungeon data or authored coordinates.** MDT and keystone.guru require a shipped map + full NPC/patrol/forces DB per dungeon; step-drivers require author-typed coordinates per step and the game's zone coordinate system; written guides require the reader to recognise named landmarks.
- **None derives a route from a recorded run of the player's own movement.** Raider.IO's Auto Route Creator is the only recorded-run derivation found, and it reconstructs *pulls from kill events* of a desktop-client-tracked M+ run, then exports an MDT string — not a walked path, and only on retail.
- **None expresses "where" as anything other than (a) a point on a shipped map image, (b) a zone x/y coordinate, or (c) a landmark noun.** No source expresses position as a beacon/zone recorded in-run.
- **None (of the planners) carries a "next" that changes with the player's position.** "Next" is either static list order, or (companions) inferred from a % counter.
- **Speedrun communities**: no written route notation surfaced; routes are videos + skip/skip-not prose + timer rules ("crosses certain lines").
- **Live mode** in MDT is co-editing sync, not driving ("continuously synchronize between all party members").

---

## R5. Vocabulary shortlist (candidates the field already uses; not decisions)

- **route** (MDT UI, keystone.guru, all guides) — the whole plan; MDT code says **preset**.
- **pull** (MDT, keystone.guru, guides, speedrun) — an ordered kill-set; **killzone** (keystone.guru, older) — a pull *with a where*; **pack** / **group** (guides) — the world's grouping of mobs.
- **path** (keystone.guru "Plotting a path", Icy Veins "Path", tank maps) — the drawn line of travel; **route** doubles for this in prose.
- **step** (TourGuide/WoW-Pro/Zygor: `step`, "The number tells you which step") — the driven unit; **note** (`|N|`, MDT "Insert Note", keystone "comment") — free text attached to a step/place.
- **waypoint** / **arrow** (Zygor "Waypoint Arrow", TomTom, WoW-Pro "follow the arrows"; MDT "New Patrol Waypoint") — a pointed-at place; **goto** (Zygor verb).
- **skip** (universal) — an intended omission; **ignore/ignoring** (ConquestCapped) — same in prose; **invis skip / death skip** (keystone attributes).
- **patrol / pat / patrol path** (MDT, keystone.guru, guides).
- **sublevel / floor / dungeon level** (MDT "Sublevel", "Dungeon Level"; keystone.guru "floor").
- **enemy forces / forces / count / %** (MDT, keystone.guru, tanknotes "mob percentage").
- **arrive / reach** (WoW-Pro `|CC|` "auto-complete at final waypoint", TourGuide "reaches"; speedrun "crosses certain lines").
- **current / next pull** (MDT Guide, Next Pull Tracker "Pull X / Total").
- **import string / export string / paste string / MDT string** (MDT, keystone.guru, guide sites); **share with party** / **Live Session** (MDT); **short link / publish** (keystone.guru).
- **landmark nouns** the prose leans on: entrance, gate, corridor, hallway, room, courtyard, bridge, ramp, stairs, tunnel, ziggurat, "final room", "third area", "to your right", "opposite side".
- **kill / clear / engage** (guides), **from / get / talk / accept / turnin / use / click** (Zygor verbs), **A/C/T/K/R/N/U/B/F/H** (TourGuide/WoW-Pro action letters).

---

### Source index (fetched unless marked)
- MDT: https://github.com/Nnoggie/MythicDungeonTools/blob/master/README.md · https://www.curseforge.com/wow/addons/mythic-dungeon-tools · https://raw.githubusercontent.com/Nnoggie/MythicDungeonTools/master/Locales/enUS.lua · https://raw.githubusercontent.com/Nnoggie/MythicDungeonTools/master/MythicDungeonTools.lua · https://noobtoboss.com/addon/mythic-dungeon-tools-mdt/ · https://mmonster.co/blog/wow-mythic-plus-dungeon-tools · https://www.curseforge.com/wow/addons/mythicdungeontools-nextpulltracker · https://github.com/KevinCalmant/MythicDungeonTools_NextPullTracker/blob/main/README.md · https://curseforge.com/wow/addons/mdt-guide · (UNREACHABLE body) https://www.wowhead.com/guide/how-to-use-mythic-dungeon-tools-addon-guide
- keystone.guru: https://keystone.guru/ · https://keystone.guru/routes · https://github.com/Wotuu/keystone.guru · https://github.com/RaiderIO/keystone.guru/issues/116 · https://github.com/RaiderIO/Keystone.guru/releases/tag/v2.2 · https://www.mmo-champion.com/threads/2444077-Keystone-guru-a-website-for-planning-your-M-routes · https://support.raider.io/kb/auto-route-creator · https://support.raider.io/kb/auto-route-creator/what-is-the-auto-route-creator · https://support.raider.io/kb/auto-route-creator/how-do-i-view-a-route-on-keystone-dot-guru
- Written guides: https://conquestcapped.com/guides/wow/mythic-plus-routes/ · https://maxroll.gg/wow/dungeons/ara-kara-city-of-echoes-guide · https://www.method.gg/guides/dungeons/ara-kara-city-of-echoes · https://www.icy-veins.com/wow/mythic-rogue-shroud-of-concealment-trash-skips · https://tanknotes.com/mythic-plus/tank-resources/ · https://www.icy-veins.com/wow/weekly-mythic-dungeon-mdt-routes · https://www.icy-veins.com/wow-classic/stratholme-undead-dungeon-guide · https://www.icy-veins.com/wotlk-classic/halls-of-lightning-dungeon-guide · https://www.icy-veins.com/wotlk-classic/the-culling-of-stratholme-dungeon-guide · https://www.almarsguides.com/wow/Instances/WoTLK/Azjol-Nerub/ · https://www.almarsguides.com/wow/achievements/wotlkheroic.cfm · https://mapsfortanks.wordpress.com/ · https://mapsfortanks.wordpress.com/2012/06/13/blackrock-depths/ · https://eintr.net/WoW/World-of-Warcraft-Classic-Dungeon-Walkthrough.html · https://www.wowisclassic.com/en/dungeon-guide/stratholme/ · (UNREACHABLE) wowhead classic/wotlk guide bodies, raider.io news, warcrafttavern
- Speedrun: https://thelighthouseworks.com/how-to-speedrun-classic-dungeons-for-fun/ · (UNREACHABLE) https://www.speedrun.com/World_of_Warcraft_Classic_Dungeons · https://www.speedrun.com/wowclassicera/guides/ua5fr · https://www.warcrafttavern.com/wow-classic/dungeon-speed-run/ · https://wago.io/YnZPxBp41 · YouTube pages
- Step-drivers: https://warcraft.wiki.gg/wiki/TourGuide/Guide_Creation · https://github.com/TekNoLogic/TourGuide · https://github.com/Ludovicus-Maior/WoW-Pro-Guides/wiki/Addon-Syntax · https://github.com/Ludovicus-Maior/WoW-Pro-Guides/wiki/How-To-Contribute · https://github.com/Ludovicus-Maior/WoW-Pro-Guides/wiki/Step-Processing-Theory · https://raw.githubusercontent.com/ErebusAres/ZygorGuidesPlus_3.3.5a-WOTLK/main/ZygorGuidesViewer/Guides/ZygorGuidesAlliance.lua · https://github.com/ErebusAres/ZygorGuidesRemaster-3.3.5a_WOTLK · https://zygorguides.com/support/manual/waypoint · https://zygorguides.com/support/manual/controls · (UNREACHABLE) https://www.wow-pro.com/wow-pro-addon-syntax/ · https://www.wow-pro.com/wow-pro-dungeons-addon/
