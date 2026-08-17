# EXPRESSIONS IN THE INSTALLED "DRIVER" ADDONS — what a player or author can already SAY, in the addon's own words

_Independent audit, files only, 2026-08-17. Root for every citation:
`F:\games\Ascension_wow\resources\ascension-live\Interface\AddOns\` (abbreviated `AddOns/`).
Read: WeakAuras (`Prototypes.lua`, `Types.lua`, `BossMods.lua`, `RegionTypes/RegionPrototype.lua`),
WeakAurasOptions (`Locales/enUS.lua`, `OptionsFrames/OptionsFrame.lua`, `CommonOptions.lua`,
`TriggerOptions.lua`, `GenericTrigger.lua`, `BuffTrigger2.lua`, `ConditionOptions.lua`,
`ActionOptions.lua`, `LoadOptions.lua`, `RegionOptions/*.lua`), WeakAurasTemplates
(`Locales/enUS.lua`, `TriggerTemplates.lua`, `TriggerTemplatesDataWrath.lua`), DBM-Core
(`localization.en.lua`, `DBM-Core.lua`, `DBM-Arrow.lua`), DBM-GUI (`localization.en.lua`,
`DBM-GUI.lua`), one DBM mod locale (`DBM-Naxx/localization.en.lua`), TomTom (`TomTom_Config.lua`,
`TomTom.lua`, `TomTom_CrazyArrow.lua`, `TomTom_Waypoints.lua`, `TomTom_POIIntegration.lua`),
pfQuest (`config.lua`, `slashcmd.lua`, `route.lua`, `map.lua`, `quest.lua`, `tracker.lua`,
`database.lua`, `locales.lua`) and pfQuest-ascension (all four files)._

_Reported as data; no recommendations. Quoted strings are what the user sees. TomTom's enUS
locale is an identity table (`TomTom/Localization.enUS.lua:3-6`), so the English key IS the
shown string; pfQuest's enUS entries are `nil` = key shown (`pfQuest/locales.lua:4`).
Citations are `FILE:line`._

---

## 1. WEAKAURAS (WeakAurasOptions + WeakAurasTemplates)

### M1. The author surface — composing an aura, step by step

**Step 0 — the New screen.** Three headings: **"Simple"** → one button **"Premade Auras"** /
"Offer a guided way to create auras for your character" (`OptionsFrame.lua:1360-1366`);
**"Advanced"** → one button per region type (`:1380-1424`); **"External"** → **"Import"**
(`:1435-1445`). Region-type buttons, in the words shown:

| button (title) | description shown | cite |
|---|---|---|
| "Group" | "Controls the positioning and configuration of multiple displays at the same time" | `RegionOptions/Group.lua:734-735` |
| "Dynamic Group" | "A group that dynamically controls the positioning of its children" | `RegionOptions/DynamicGroup.lua:701` |
| "Icon" | "Shows a spell icon with an optional cooldown overlay" | `RegionOptions/Icon.lua:493-495` |
| "Progress Bar" | "Shows a progress bar with name, timer, and icon" | `RegionOptions/AuraBar.lua:893` |
| "Text" | "Shows one or more lines of text, which can include dynamic information such as progress or stacks" | `RegionOptions/Text.lua:523` |
| "Texture" | "Shows a custom texture" | `RegionOptions/Texture.lua:227-228` |
| "Progress Texture" | "Shows a texture that changes based on duration" | `RegionOptions/ProgressTexture.lua:808` |
| "Model" | "Shows a 3D model from the game files" | `RegionOptions/Model.lua:308-309` |
| "Stop Motion" | "Shows a stop motion texture" | `RegionOptions/StopMotion.lua:666-667` |
| "Empty Base Region" | "Shows nothing, except sub elements" | `RegionOptions/Empty.lua:89-91` |

**Step 1 — the tabs.** Once an aura exists, the option pane has tabs in this order:
**"Display" · "Trigger" · "Conditions" · "Actions" · "Animations" · "Load" · "Custom Options" ·
"Information"**, with **"Group"** prepended for groups (`OptionsFrame.lua:1204-1215`).

**Step 2 — Trigger tab.** Header "Trigger" (`TriggerOptions.lua:161`); button **"Add Trigger"**
(`:120-128`). Each trigger is titled "Trigger %i: %s" (`:305`). First field **"Type"** / tooltip
"The type of trigger" (`CommonOptions.lua:2015-2016`); its dropdown values are the trigger
systems: **"Aura"** (`WeakAuras/BuffTrigger2.lua:3136-3140`) plus the event categories
**"Spell" · "Item" · "Player/Unit Info" · "Other Addons" · "Combat Log" · "Other Events" ·
"Custom"** (`WeakAuras/Prototypes.lua:1585-1613`). Choosing a category pre-selects a default
event ("Cooldown Progress (Spell)", "Cooldown Progress (Item)", "Health", "GTFO", "Combat Log",
"Chat Message"; `Prototypes.lua:1588-1608`). The second field is the event within the category —
the full menu, by category (names are the `name =` of each prototype, `Prototypes.lua:1621-8860`;
boss-mod ones from `BossMods.lua`):

- *Spell*: "Cooldown Progress (Spell)", "Cooldown Ready (Spell)", "Charges Changed", "Global
  Cooldown", "Action Usable", "Totem", "Spell Known", "Queued Action".
- *Item*: "Cooldown Progress (Item)", "Cooldown Progress (Equipment Slot)", "Cooldown Ready
  (Item)", "Cooldown Ready (Equipment Slot)", "Item Count", "Weapon Enchant", "Item Equipped",
  "Item Type Equipped", "Equipment Set".
- *Player/Unit Info*: "Unit Characteristics", "Faction Reputation", "Experience", "Health",
  "Power", "Swing Timer", "Talent Known", "Class/Spec", "Stance/Form/Aura", "Death Knight Rune",
  "Threat Situation", "Crowd Controlled", "Cast", "Character Stats", "Conditions", "Pet
  Behavior", "Range Check", "Money", "Currency", "Location" (`:8745-8859`).
- *Combat Log*: "Combat Log" (with "Subevent" / "Subevent Suffix" pickers, `GenericTrigger.lua:496-513`).
- *Other Events*: "Chat Message", "Spell Cast Succeeded", "Ready Check", "Entering/Leaving
  Combat" (`:6268`), "Entering/Leaving Encounter" (`:6293`).
- *Other Addons*: "GTFO", "DBM Stage", "DBM Announce", "DBM Timer", "BigWigs Stage", "BigWigs
  Message", "BigWigs Timer", "Boss Mod Stage", "Boss Mod Stage (Event)", "Boss Mod Announce",
  "Boss Mod Timer" (`BossMods.lua:445-1680`).
- *Custom*: "Event Type" = "Event" / "Status" / "Trigger State Updater (Advanced)"
  (`GenericTrigger.lua:29-32`, `Types.lua:2365-2369`); "Check On..." = "Every Frame (High CPU
  usage)" / "Event(s)" (`Types.lua:1260-1263`); code boxes "Custom Trigger", "Custom Untrigger",
  "Duration Info", "Name Info", "Icon Info", "Texture Info", "Stack Info", "Custom Variables"
  (`GenericTrigger.lua:328-449`).

Per-type fields the author fills, for the types nearest a route:

- **Aura** (`WeakAurasOptions/BuffTrigger2.lua`): "Unit" (:308) with values "Player", "Smart
  Group", "Target", "Focus", "Pet", "Specific Unit", "Multi-target"… (`Types.lua:1120-1141`);
  "Aura Type" = "Buff"/"Debuff"/"Buff/Debuff" (:361; `Types.lua:1085-1089`); "Name(s)" (:421),
  "Exact Spell ID(s)" (:434), "Ignored Name(s)" (:447), "Name Pattern Match" (:477); "Stack
  Count" + "Operator" (:512-518); "Remaining Time" (:545); "Total Time" (:578); filters "Filter
  by Specialization / Group Role / Raid Role / Class / Unit Name / Hostility / Npc ID"
  (:869-1068); "Ignore Self / Dead / Disconnected / out of casting range / out of checking
  range" (:1083-1114); "Show On" = "Aura(s) Found" / "Aura(s) Missing" / "Always"
  (:1183; `Types.lua:3055-3057`); "Unit Count", "Match Count" (:1136, :1203).
- **Location** (`Prototypes.lua:8745-8859`): "Player Location ID(s)" (tooltip shows "Current
  Zone" name + map ID; "Supports multiple entries, separated by commas. Prefix with '-' for
  negation."), "Zone Name", "Subzone Name" ("Name of the (sub-)zone currently shown above the
  minimap."), header "Instance Info", "Instance Size Type" (values "No Instance", "5 Man
  Dungeon", "10 Man Raid", "20 Man Raid", "25 Man Raid", "40 Man Raid", "Battleground", "Arena";
  `Types.lua:2534-2543`), "Instance Difficulty" ("None", Normal, Heroic, "Mythic", "Ascended";
  `Types.lua:2573-2579`).
- **Range Check** (`Prototypes.lua:8459-8543`): "Unit" (values "Target", "Focus", "Pet",
  "Specific Unit"; `Types.lua:1173-1176`), "Minimum Estimate", "Maximum Estimate", "Distance"
  (a yard number with operator; default 8).
- **Conditions** (`Prototypes.lua:8059-8252`): tri-state checks "Always active trigger", "In
  Combat", "PvP Flagged", "Alive", "In Vehicle", "Resting", "Mounted", "HasPet", "Is Moving",
  "Is Away from Keyboard", "Group Type", "PvP Ruleset", "Instance Type", "Instance Difficulty".
- **Entering/Leaving Combat**: "Type" = "Entering" / "Leaving" (`Prototypes.lua:6268-6276`,
  `Types.lua:3107-3110`). **Entering/Leaving Encounter**: note "Requires Deadly Boss Mods (DBM)
  to detect encounters." (`Prototypes.lua:95`), "Type" ("Entering"/"Leaving"), "Id", "Name",
  "Difficulty", "Success" (`:6302-6344`).
- **DBM Stage** ("Stage" — "Matches stage number of encounter journal.\nIntermissions are
  .5\nE.g. 1;2;1;2;2.5;3", "Stage Counter"; `BossMods.lua:459-471`), **DBM Announce** ("Spell
  Id", "Message", "Clone per Event"; `:500-529`), **DBM Timer** ("Timer Id", "Spell Id",
  "Message", "Remaining Time", "Offset Timer", "Count", "Type", "Bar enabled in DBM settings",
  "Clone per Event"; `:715-781`).
- **Chat Message**: message-type list "Say", "Yell", "Whisper", "Party", "Raid", "Raid Warning",
  "Monster Yell/Emote/Say/Whisper", "Boss Emote", "Boss Whisper", "System", "Loot", …
  (`Types.lua:2774-2799`).
- Every *event*-kind trigger carries **"Hide"** = "Timed" / "Custom" (`GenericTrigger.lua:230-242`;
  `Types.lua:2371-2374`), **"Duration (s)"** (:271), and — where offered — **"Count"** ("Occurrence
  of the event… 2nd 5th and 6th events: 2, 5, 6 … every 3 events starting from 2nd: 2/3";
  `LoadOptions.lua:1109-1110`) and **"Delay"** (`:1155`).

Trigger combination lives under **"Trigger Combination"** → **"Required for Activation"** with
values **"Any Triggers" / "All Triggers" / "Custom Function"** (`TriggerOptions.lua:34-38`,
`Types.lua:1069-1073`) and **"Dynamic Information"** = "Dynamic information from first active
trigger" / "Dynamic information from Trigger %i" (`TriggerOptions.lua:63-70`).

**Step 3 — Conditions tab.** Rows read **"If"** *<trigger variable>* *<operator>* *<value>*,
**"Then"** *<property>* *<new value>*, with **"And"** for extra changes and **"Else If"** for
linked rows (`ConditionOptions.lua:247, 1713-1718`; button "Add Condition"
`Locales/enUS.lua:131`, "Add Property Change" `:136`). Property choices common to every region:
"Sound", "Chat Message", "Run Custom Code", "Relative X-Offset", "Relative Y-Offset", "Glow
External Element", "Alpha", "Progress Source" (`RegionTypes/RegionPrototype.lua:68-119`); sub
elements add "Visibility" (`SubRegionTypes/Glow.lua:35`, `SubText.lua:67`, `Border.lua:24`…).
Special check kinds: "Range in yards" (`ConditionOptions.lua:2098`) and "Group player(s) found"
/ "Enemy nameplate(s) found" (`:2134-2135`); "Custom Check" (`:2188`).

**Step 4 — Actions tab.** Sections **"On Show"** and **"On Hide"** (`ActionOptions.lua:106,
634`), each with: "Chat Message" → "Message Type" (values "Whisper", "Channel", "Say", "Emote",
"Yell", "Party", "Guild", "Officer", "Raid", "BG>Raid>Party>Say", "Raid Warning",
"Battleground", "Blizzard Combat Text", "Chat Frame", "Error Frame", + "Text-to-speech" when
enabled; `Types.lua:2807-2826`), "Send To", "Is Unit", "Message", "Dynamic Text Replacements";
"Play Sound" → "Loop", "Repeat After", "Sound", "Sound Channel", "Sound File Path", "Sound Kit
ID"; "Glow External Element" → "Glow Action", "Glow Frame Type", "Glow Type" ("Autocast Shine",
"Pixel Glow", "Action Button Glow", "Proc Glow"; `Types.lua:3497-3502`), "Frame", "Glow Color",
"Lines & Particles", "Frequency", "Length", "Thickness", "Scale", "Border"; "Custom" code
(`ActionOptions.lua:112-628`). On Hide adds "Stop Sound", "Fadeout Sound", "Fadeout Time
(seconds)", "Hide Glows applied by this aura" (`:846-1167`). Note shown: "Note: Automated
Messages to SAY and YELL are blocked outside of Instances." (`:127`). Also "Custom Functions":
"Custom Init", "Custom Load", "Custom Unload" (`:82-99`).

**Step 5 — Load tab.** Header "Load" (`LoadOptions.lua:1222`). Sections and tri-state checks
(`Prototypes.lua:963-1370`): **"General"** — "In Combat" (:985), "Never" (:994), "Alive", "In
Encounter" (:1010), "PvP Mode Active", "In Manastorm", "In Vehicle", "Has Vehicle UI",
"Mounted"; **"Player"** (:1064) — "Player Class", "Talent Specialization", "Talent", "Mystic
Enchant", "Not Mystic Enchant", "Spell Known", "Not Spell Known", "Player Name/Realm", "Not
Player Name/Realm", "Guild", "Player Race", "Player Faction", "Player Level", "Spec Role",
"Spec Position", "Raid Role", "Group Type" (:1222; "Not in Group"/"In Party"/"In Raid"
`Types.lua:2560-2564`), "Group Size" (:1232), "Group Leader/Assist", "PvP Ruleset";
**"Location"** (:1263) — "Zone Name" (:1268), "Player Location ID(s)" (:1282), "Subzone Name"
(:1295), "Encounter ID(s)" (:1309), "Instance Size Type" (:1320), "Instance Difficulty" (:1330);
**"Equipment"** (:1339) — "Item Equipped", "Not Item Equipped", "Item Type Equipped". Tri-state
tooltips: "Ignored – Single – Multiple / This option will not be used to determine when this
display should load" (`Locales/enUS.lua:587-592`).

**Step 6 — Custom Options tab** (author-exposed settings): "Option Type" values "Toggle",
"String", "Number", "Slider", "Description", "Color", "Dropdown Menu", "Space", "Toggle List",
"Media", "Separator", "Option Group" (`Types.lua:3359-3372`); "Enter User Mode" / "Enter Author
Mode" (`Locales/enUS.lua:362-365`).

**Templates ("Premade Auras") — the pre-built intents.** Wizard: step 1 = region buttons
(only regions that ship templates: Icon, Progress Bar, Text, Texture, Model, Progress Texture;
`TriggerTemplates.lua:1655-1667`); step 2 = class dropdown, then sections per spec **"Buffs" ·
"Debuffs" · "Abilities" · "Resources"** (`TriggerTemplatesDataWrath.lua:50, 67, 86, 143`), a
**"General"** section with **"Health", "Cast", "Always Active", "Pet alive", "Pet Behavior",
"Bloodlust/Heroism"** and power types (`:935-990`), then a **race** dropdown with racial
buff/cooldown items ("… buff", "… cooldown", "… debuff" suffixes; `:1200-1210`); "Hold CTRL to
create multiple auras at once" (`TriggerTemplates.lua:1755`), "Next", "Back", "Cancel", "Create
Auras" (`:1787-1845`). Step 3 = a *sub-type* per item, each with a title and a one-line
intent, e.g. "Basic Show On Cooldown" / "Only shows the aura when the ability is on cooldown."
(`:546-547`), "Basic Show On Ready" / "Only shows the aura when the ability is ready to use."
(:565-566), "Show Cooldown and Check for Target" / "Always shows the aura, turns red when out
of range." (:893-894), "Show Only if Buffed" / "Only shows the aura if the target has the
buff." (:999-1000), "Always Show" / "Always show the aura, highlight it if debuffed."
(:1045-1046), "Show if Enchant Missing", "Show Only if on Cooldown" (`Locales/enUS.lua`). On an
existing aura the last page offers **"Replace Triggers"** / "Replace all existing triggers"
and **"Add Triggers"** / "Keeps existing triggers intact" (`TriggerTemplates.lua:1621-1641`).

### M2. WeakAuras vocabulary

| concept | WA word(s) shown | cite |
|---|---|---|
| a place | "Location"; "Zone Name", "Subzone Name", "Player Location ID(s)", "Instance Size Type", "Instance Difficulty" | `Prototypes.lua:8758-8855, 1263-1330` |
| a condition | "Trigger" (a thing that is true), "Conditions" tab ("If … Then …", "Else If", "And"), "Load" (when the aura exists at all) | `OptionsFrame.lua:1204-1209`; `ConditionOptions.lua:247,1713-1718` |
| an action | "Actions" → "On Show" / "On Hide": "Chat Message", "Play Sound", "Glow External Element", "Custom" | `ActionOptions.lua:106-634` |
| a sequence / order | "Trigger Combination" → "Any Triggers" / "All Triggers" / "Custom Function" (Boolean, not ordered); "Count" = which occurrence of an event ("2-6", "/2", "2/3"); "Aura Order" (list order of a group's children); "Animation Sequence"; "Move Up"/"Move Down" | `Types.lua:1069-1073`; `LoadOptions.lua:1109-1110`; `Locales/enUS.lua:178,192,577,584` |
| an arrival | none as such — nearest is "Range Check" ("Distance" ≤ n yards to a *unit*) and the Conditions check "Range in yards" | `Prototypes.lua:8459-8543`; `ConditionOptions.lua:2098` |
| a state | "Loaded" / "Standby" / "Not Loaded" (per aura); trigger "active" (shown) vs hidden; "Show On: Aura(s) Found / Aura(s) Missing / Always" | `Locales/enUS.lua:555-556,606,804`; `Types.lua:3055-3057` |
| a stage / phase | "DBM Stage" → "Stage" / "Stage Counter"; "Entering/Leaving Encounter", "Entering/Leaving Combat" | `BossMods.lua:452-471`; `Prototypes.lua:6268,6293` |
| a group of things | "Group", "Dynamic Group" ("Grow direction" values "Left/Right/Up/Down/Centered Horizontal/…/Grid/Custom"; "Sort" "Ascending/Descending/Hybrid/None/Custom"); "Add to new Group"; a trigger's "Unit" = "Smart Group" / "Party" / "Raid" | `Types.lua:2386-2397, 68-73`; `Locales/enUS.lua:140-141` |

### M3. What the reader receives

Surfaces = the region types in M1 (icon, bar, text, texture, model, stop-motion, empty), each
with **"Sub Elements"** — "Shows a border", "Shows a glow", "Shows a model", "Shows a Stop
Motion", "Shows one or more lines of text…", "Shows a Texture", "Places a tick on the bar",
"Background"/"Foreground" (`SubRegionOptions/*.lua`) — plus off-screen effects: chat line
(any channel incl. "Raid Warning", "Chat Frame", "Error Frame", TTS), sound (file/kit/loop),
external glow on a named frame, screen-shake none. Appear/disappear: a display shows while its
trigger combination is active (or for "Duration (s)" after an event with "Hide: Timed") and
plays "Start"/"Main"/"Finish" animations ("Fade In", "Slide In", "Zoom In", "Rotate In",
"Color"; `AnimationOptions.lua:129-372`). Loading (existence at all) is gated by the Load tab.
User can turn off: any aura ("Toggle the visibility of this display", `Locales/enUS.lua:882`),
sounds globally ("Remove All Sounds", "Remove All Text To Speech", `:694-695`), and per-import
"Ignore Wago updates" (`:502`).

### M4. What WeakAuras never lets you express (relative to a route)

- **An ordered sequence.** Checked `TriggerOptions.lua`, `Types.lua:1069-1073`,
  `ConditionOptions.lua`: combination is any/all/custom-Lua; "Count" is an occurrence index of
  one event stream, not "after step 3". Order among children exists only as list/grow order.
  Absent without custom code.
- **Position-based completion.** Checked `Prototypes.lua:8745-8859` (Location = zone/subzone/
  map ID only, no x/y) and `:8459-8543` (Range Check = distance to a *unit*, no world point).
  No coordinate field anywhere in `Prototypes.lua`. Absent.
- **"Come here" / a pointer to a place.** No arrow region among the region types
  (`OptionsFrame.lua:1385-1426`); no facing/direction variable in any prototype. Absent.
- **A stage.** "DBM Stage" exists in WA (`BossMods.lua:445`) but the installed DBM-Core fires
  only `DBM_Announce`, `DBM_Kill`, `DBM_TimerStart/Stop/Update`, `DBM_Wipe`, and lowercase
  `pull`/`wipe`/`kill` (grep of `fireEvent(` in `DBM-Core/DBM-Core.lua`, `DBT.lua`; no
  `DBM_SetStage`, no `DBM_Pull` anywhere under `DBM-*/`). WA maps `DBM_Pull → ENCOUNTER_START`
  (`WeakAuras/GenericTrigger.lua:3991-3995`), so "Entering Encounter"/"In Encounter" has no
  installed source; "Leaving" does (`DBM_Kill`/`DBM_Wipe`). Data, not a fix.
- **Movement direction / heading.** Conditions offer "Is Moving" only (`Prototypes.lua:8204`).

### M5. Defaults and ease

Zero-config path: "Premade Auras" → pick region → pick class item → pick sub-type → aura
exists with trigger + conditions pre-filled (`TriggerTemplates.lua:1584-1600`). "Advanced"
gives an empty region whose default trigger is "Cooldown Progress (Spell)" etc. by category
(`Prototypes.lua:1585-1608`) — the author must fill a spell/aura name. "Import" takes an
encoded string ("Import a display from an encoded string", `Locales/enUS.lua:510`), warning
"This aura contains custom Lua code.\nMake sure you can trust the person who sent it!"
(`:848-850`). Load tab defaults to no conditions (loaded everywhere). Everything is per-aura;
no global profile.

---

## 2. DEADLY BOSS MODS (DBM-Core + DBM-GUI)

### M1. The author / config surface

**Player config** — `/dbm` with no argument opens the GUI (`DBM-Core.lua:837`). Frame title
"Deadly Boss Mods" (`DBM-GUI/localization.en.lua:5`). Left tree: **"General Options"** with
sub-panels **"General DBM Options"**, **"Raid Warnings"**, **"Bar Style"**, **"Special
Warnings"**, **"Health Frame"**, **"Global and Spam Filters"** (`:9, 48, 68, 88, 109, 121,
129`); then expansion tabs **"Wrath of the Lich King"**, **"The Burning Crusade"**, "Vanilla",
"Misc Mods" (`:10-13`) → one panel per instance addon (`DBM-GUI.lua:1962-1972`; if not loaded:
"This boss mod is not loaded. It will be loaded when you enter the instance. You can also
click the button to load the mod manually." + button "Load AddOn", `localization.en.lua:16-26`)
→ optional wing sub-panels → one panel per boss (`DBM-GUI.lua:2001-2011`).

Per-boss panel (`DBM-GUI.lua:2021-2085`): "Icons used by this mod" row of raid marks (:2032);
checkbox **"Enable boss mod"** (:2051); checkbox **"Announce to raid"** (:2055); then one
collapsible area per option category — default categories **"Bars"**, **"Announces"**,
**"Miscellaneous"** (`DBM-Core/localization.en.lua:31-33`) or mod-defined ones (e.g. Thaddius
adds **"Arrows"**, `DBM-Naxx/localization.en.lua:250`) — each a list of **checkboxes** whose
labels are auto-generated from the constructor used (`localization.en.lua:119-201`):

| constructor family | checkbox label the user sees | fired text (bar / warning) |
|---|---|---|
| timers `NewTargetTimer / NewCastTimer / NewBuffActiveTimer / NewCDTimer / NewNextTimer / NewAchievementTimer / NewPhaseTimer` (`DBM-Core.lua:3505-3536`) | "Show timer for <spell> debuff / cast / duration / cooldown", "Show timer for next <spell>", "Show timer for %s", "Show timer for phase <spell>" (:120-126) | "%s: %s", "%s", "%s CD", "Next %s", "Phase %s" (:110-116) |
| announces `NewTargetAnnounce / NewSpellAnnounce / NewCastAnnounce / NewSoonAnnounce / NewPreWarnAnnounce / NewPhaseAnnounce / NewInterruptAnnounce` (:2816-2840) | "Announce <spell> targets", "Show warning for <spell>", "Show warning when <spell> is being cast", "Show pre-warning for <spell>", "Announce Phase %d", "Show warning for when to interrupt %d" (:142-148) | "%s on >%s<", "Casting %s: %.1f sec", "%s soon", "%s in %s", "Phase %d", "Interrupt %d" (:131-137) |
| special warnings `NewSpecialWarning{Spell,Dispel,Interupt,You,Target,Close,Move,Run,Cast,Stack}` (:3108-3144) | "Show special warning for $spell", "…to dispel/spellsteal", "…to interupt", "…when you are affected by", "…when someone is affected by", "…when someone close to you is affected by", "…for >=%d stacks of" (:154-163) | "%s!", "%s on %s - dispel now", "%s - interupt now", "%s on you", "%s on %s", "%s on %s near you", "%s - move away", "%s - run away", "%s - stop casting", "%s (%d)" (:167-176) |
| yells `NewYell / NewShortYell / NewCountYell / NewFadesYell / NewShortFadesYell / NewIconFadesYell / NewPosYell / NewComboYell` (:2962-2990) | "Yell when you are affected by $spell", "Yell with name…", "Yell with count…", "Yell with countdown and spell name when $spell is fading", "Yell with position when you are affected by $spell", … (:180-187) | "%s on <you>", "%s fading in %d", "{rt%d} %d {rt%d}", "%s %s on {rt%d}<you>{rt%d}" (:190-197) |
| icons / sounds `SetIcon` (:3873), `NewSound` (:2851) | "Set icons on $spell targets", "Play sound on $spell" (:200-201) | raid mark / sound file |
| generic `AddBoolOption / AddSliderOption / AddDropdownOption / AddButton` (:3614-3665) | mod-localized text via `SetOptionLocalization` (e.g. "Show arrows (normal \"2 camp\" strategy)", `DBM-Naxx/localization.en.lua:239`) | — |

Note: the installed GUI renders only **boolean** options (`DBM-GUI.lua:2066` — `type(mod.Options[v]) == "boolean"`); sliders/dropdowns/buttons a mod declares are not shown.

**Author (mod) surface** — a mod is Lua: `DBM:NewMod("Anastari", "DBM-Party-Vanilla", 5)`,
`mod:SetCreatureID(10436)`, `mod:RegisterCombat("combat")`, `mod:RegisterEvents(...)`
(`DBM-Party-Vanilla/Stratholme/Anastari.lua:1-10`); `SetZone(...)` (`DBM-Core.lua:2457`),
`RegisterCombat(cType,...)` where cType is "combat" or a message type with trigger strings
(:3708-3716), `RegisterKill` (:3746), `SetBossHealthInfo` (:2684), `SetUsedIcons` (:2598),
`Schedule/Unschedule` (:3845-3861), `SendSync` (:3816), and the arrow API `DBM.Arrow:ShowRunTo(x, y | playerName [, distance, time])`,
`DBM.Arrow:ShowRunAway(...)`, `DBM.Arrow:Hide()`, `DBM.Arrow:Move()` (`DBM-Arrow.lua:198-246`).
Text is separated into `SetGeneralLocalization{name}`, `SetOptionLocalization`,
`SetWarningLocalization`, `SetTimerLocalization`, `SetMiscLocalization`,
`SetOptionCatLocalization` (`DBM-Naxx/localization.en.lua:225-260`).

**Slash surface** (`DBM-Core.lua:712-838`, help text `localization.en.lua:76-84`): "/dbm
version", "/dbm unlock: Shows a movable status bar timer (alias: move)", "/dbm timer <x>
<text>", "/dbm broadcast timer <x> <text>", "/dbm break <min>", "/dbm pull [sec]" (also
`/pull`), "/dbm arrow <x> <y> creates an arrow that points to a specific locataion (0 < x/y <
100)", "/dbm arrow <player>", "/dbm arrow target|focus", "/dbm arrow hide", "/dbm arrow move"
(:213-219, `DBM-Core.lua:801-829`; the slash arrow refuses outside a raid: "This function only
works in raid groups and within raid instances." :212). GUI also has 'Create a "Pizza Timer"'
with "Name (e.g. \"Pizza!\")", "Hours/Min/Sec", "Start timer", "Broadcast to raid"
(`DBM-GUI/localization.en.lua:59-65`).

### M2. DBM vocabulary

| concept | DBM word(s) shown | cite |
|---|---|---|
| a place | zone (mod loads by zone: "It will be loaded when you enter the instance."); arrow target = "a specific locataion (0 < x/y < 100)" or "a specific player" | `DBM-GUI/localization.en.lua:16-18`; `DBM-Core/localization.en.lua:215-216` |
| a condition | none user-facing; mod-side = combat-log/emote/yell events + `RegisterCombat("combat"/"yell"/"emote"…)` | `DBM-Core.lua:3708-3716` |
| an action | "Announce", "warning", "special warning", "timer", "Yell", "Set icons", "Play sound", "whisper" | `localization.en.lua:119-201` |
| a sequence / order | "Next %s" (timer), "%s soon", "%s in %s" (pre-warning), "Pull in %d sec" / "Pull now!", "Break ends in %s" | `:114, 134-135, 101-104, 95-99` |
| an arrival | arrow hides at ≤ 3 yd (run-to) / ≥ 100 yd (run-away); no word shown | `DBM-Arrow.lua:111-124, 205` |
| a state | "engaged" / "down" / "Combat … ended" / "wiped"; "Kills:", "Wipes:", "Best Kill:" | `:8-12, 38-39`; `DBM-GUI/localization.en.lua:40-42` |
| a stage / phase | "Phase %d" (announce), "Phase %s" (timer), "Announce Phase %d", "Show timer for phase <spell>" | `:116, 126, 136, 147` |
| a group of things | "raid" (announce/broadcast target), option categories "Bars"/"Announces"/"Miscellaneous", "Icons used by this mod" | `:31-33`; `DBM-GUI/localization.en.lua:28, 36` |

### M3. What the reader receives

- **Announce**: raid-warning frame text (colored, optional left/right spell icon), optional
  chat-frame copy ("Show warnings in chat frame", "Show warnings as faked raid warning
  messages"), sound `Sound\Doodad\BellTollNightElf.wav` on every announce; if "Announce to
  raid" and the player is promoted, `*** msg ***` to RAID_WARNING/PARTY
  (`DBM-Core.lua:2700-2745`; defaults `:60, 70-73`).
- **Special warning**: centre-screen text, default font size 50, blue, visible 5 s with fade,
  sound `Sound\Spells\PVPFlagTaken.wav`; "Show special warnings for boss abilities" toggle
  (`DBM-Core.lua:3028-3050`, defaults `:93-98`; `DBM-GUI/localization.en.lua:111`).
- **Bars** (DBT): timer bars with "Bar texture", "Start color"/"End color", "Expand bars
  upward", "Enable huge bar (aka Bar 2)", "Fill up bars", "Left icon"/"Right icon"
  (`DBM-GUI/localization.en.lua:88-106`).
- **Yell**: `/say` text with the player's name/count/countdown/raid mark (`localization.en.lua:190-197`).
- **Raid target icons** on units; **whispers** to affected players ("Filter <DBM> warning
  whispers while fighting"); **Range Check frame** ("Range Check (%d yd)", "Set range",
  sounds "Sound when one player is in range"/"…more than one…"; `localization.en.lua:62-72`);
  **Health Frame** ("Always show health frame", `DBM-GUI/localization.en.lua:123`); **Arrow**
  (screen texture; yellow→red by distance for run-to, red→green for run-away; hidden while the
  World Map is open; `DBM-Arrow.lua:111-131, 141-145`).
- Off-switches: per boss "Enable boss mod"; per option checkbox; global "Do not show announces
  or play warning sounds", "Do not send announces to raid chat", "Do not send whispers to
  other players", "Do not set icons on targets" (`DBM-GUI/localization.en.lua:139-142`).

### M4. What DBM never lets a player express

- **A route / order of places.** No waypoint list, no "next"; the only place primitive is a
  single arrow to one map percent or one player (`DBM-Arrow.lua:198-218`), and via slash only in
  raids (`DBM-Core.lua:802-805`). Absent.
- **Position-based completion.** Arrow auto-hides at a distance (`DBM-Arrow.lua:111-124`) but
  fires nothing; no option, no event. Absent.
- **Any condition or trigger authoring** without writing a mod file — the GUI is toggles only
  (`DBM-GUI.lua:2059-2081`). Absent.
- **Stage as data for other addons.** Installed core fires no `DBM_SetStage`/`DBM_Pull` (see WA
  M4). Absent.

### M5. Defaults and ease

Everything is on unless the mod author passed `optionDefault=false`; "Enable DBM", minimap
button, status whispers, auto-respond, "Show warnings in chat frame", special warnings all
default true (`DBM-Core.lua:67-80`). Mods load on zone entry (`DBM-GUI/localization.en.lua:16-18`);
the user configures nothing to receive warnings, and each option row is a labeled checkbox
that already names the spell.

---

## 3. TOMTOM

### M1. The config surface

`/tomtom` opens Interface Options → "TomTom" ("TomTom is a simple navigation assistant",
`TomTom_Config.lua:712, 757-766`) with panels **"General Options"**, **"Coordinate Block"**,
**"Waypoint Arrow"**, **"Minimap"**, **"World Map"**, **"Data Feed Options"**, **"Quest
Objectives"**, **"Profile Options"** (`:57, 151, 344, 388, 506, 561, 627, 675`).

- **General Options** (`:558-622`): "Announce new waypoints when they are added"; "Ask for
  confirmation on \"Remove All\""; "Save new waypoints until I remove them"; slider **"Clear
  waypoint distance"** — "Waypoints can be automatically cleared when you reach them. This
  slider allows you to customize the distance in yards that signals your \"arrival\" at the
  waypoint. A setting of 0 turns off the auto-clearing feature" (0-150); "Automatically set a
  waypoint when I die" — "guiding you back to your corpse".
- **Waypoint Arrow** (`:148-339`): intro "Similar to the arrow in \"Crazy Taxi\" it will point
  you towards your next waypoint"; "Enable floating waypoint arrow"; "Automatically set
  waypoint arrow" ("When a new waypoint is added, TomTom can automatically set the new waypoint
  as the \"Crazy Arrow\" waypoint."); "Lock waypoint arrow"; "Show estimated time to arrival";
  "Enable the right-click contextual menu"; "Disable all mouse input"; **"Automatically set to
  next closest waypoint"** ("When the current waypoint is cleared … TomTom will automatically
  set the closest waypoint in the current zone as active waypoint."); slider **"\"Arrival
  Distance\""** ("the distance at which the waypoint arrow switches to a downwards arrow,
  indicating you have arrived at your destination", 0-150); **"Play a sound when arriving at a
  waypoint"**; "Arrow display" (Scale, Alpha, Title Width/Height/Scale/Alpha, "Reset
  Position"); "Arrow colors" — "Good color" ("when you are moving in the direction of the
  active waypoint"), "Middle color", "Bad color" ("opposite direction").
- **Minimap** / **World Map** (`:341-500`): "Enable minimap waypoints", "Enable world map
  waypoints", "Display waypoints from other zones" (disabled), "Enable mouseover tooltips",
  "Enable the right-click contextual menu", "Allow control-right clicking on map to create new
  waypoint", "Create note modifier" (Alt/Ctrl/Shift combos), "Enable showing player
  coordinates", "Enable showing cursor coordinates" + accuracy sliders.
- **Quest Objectives** (`:624-670`): "TomTom can be configured to set waypoints for the quest
  objectives that are shown in the watch frame and on the world map."; "Enable quest objective
  click integration"; "set waypoint modifier"; **"Enable automatic quest objective waypoints"**
  ("based on which objective is closest to your current location. This setting WILL override
  the setting of manual waypoints."). Implementation hooks `WatchFrame_Update` and picks the
  closest quest POI (`TomTom_POIIntegration.lua:5-8, 43`).
- **Coordinate Block** (`:54-146`): "Enable coordinate block", "Lock coordinate block",
  "Coordinate Accuracy", colors/size.

**Slash** (`TomTom.lua:988-992, 1029-1044`): "/way <x> <y> [desc] - Adds a waypoint at x,y with
descrtiption desc", "/way <zone> <x> <y> [desc]", "/way reset all", "/way reset <zone>";
"/cway" (= set closest), "/wayb"/"/wayback" (waypoint at current spot titled "Wayback").
Aliases "/tway", "/tomtomway".

**Right-click menus** — on a map/minimap waypoint: "Waypoint Options" → "Set as waypoint
arrow", "Send waypoint to" → "Send to party/raid/battleground/guild", "Remove waypoint",
"Remove all waypoints from this zone", "Remove all waypoints", "Save this waypoint between
sessions" (`TomTom.lua:419-532`); on the arrow: "TomTom Waypoint Arrow" → "Clear waypoint from
crazy arrow", "Remove waypoint", "Remove all waypoints from this zone", "Remove all waypoints"
(`TomTom_CrazyArrow.lua:266-307`).

### M2. TomTom vocabulary

| concept | TomTom word(s) shown | cite |
|---|---|---|
| a place | "waypoint" (x,y in a zone; optional "desc"/title); "TomTom waypoint"; "My Corpse"; "Wayback" | `TomTom.lua:989-990, 389`; `TomTom_Corpse.lua:57`; `TomTom.lua:1039` |
| a condition | none — only "when a new waypoint is added", "when the current waypoint is cleared", "when I die" | `TomTom_Config.lua:172, 210, 616` |
| an action | "Adds a waypoint", "Set as waypoint arrow", "Clear waypoint", "Remove waypoint", "Send waypoint to", "Announce new waypoints" | `TomTom.lua:424-457, 989`; `TomTom_Config.lua:584` |
| a sequence / order | "your next waypoint" = "next closest waypoint" (proximity, not authored) | `TomTom_Config.lua:158, 209-210` |
| an arrival | "\"Arrival Distance\"" (down arrow), "Clear waypoint distance" ("signals your \"arrival\""), "Play a sound when arriving at a waypoint", "Show estimated time to arrival" | `TomTom_Config.lua:217-218, 608-609, 225, 185` |
| a state | active waypoint (the "\"Crazy Arrow\" waypoint"), saved vs session ("Save this waypoint between sessions") | `TomTom_Config.lua:172`; `TomTom.lua:468` |
| a stage / phase | absent | — |
| a group of things | "all waypoints", "all waypoints from this zone", "Waypoints profile" | `TomTom.lua:447-457`; `TomTom_Config.lua:691` |

### M3. What the reader receives

The **crazy arrow**: rotates toward the active waypoint, colored by a gradient from "Good
color" (facing it) through "Middle color" to "Bad color" (facing away); status text "%d
yards"; optional time-to-arrival; within "Arrival Distance" (default 15) it swaps to an
animated **up/down arrow** in the good color (`TomTom_CrazyArrow.lua:130-183`); at "Clear
waypoint distance" (default 10) the waypoint is auto-removed and, if "Automatically set to
next closest waypoint", the arrow jumps to the next nearest; optional ping sound
`Media\ping.mp3` at arrival (`TomTom.lua:675-678, 760-780`). **Minimap** and **world map**
icons with tooltip "TomTom waypoint" / "%s yards away" / "%s (%.2f, %.2f)"
(`TomTom.lua:389-393, 635-641`); chat line "TomTom: Added a waypoint (…) in <zone>" when
announce is on (`:834`). Disappears: **the arrow and minimap icons hide whenever
`IsInInstance()` is true or distance cannot be computed** (`TomTom_CrazyArrow.lua:114-127`,
`TomTom_Waypoints.lua:340-343`). Off-switches: every panel has an "Enable …" toggle.

### M4. What TomTom never lets you express

- **An authored order.** Only "next closest" (`TomTom_Config.lua:206-213`); `/way` adds
  independent points; no list ordering, no "after". Absent.
- **A condition on anything but distance/death/quest-POI-closest.** Absent (`TomTom_Config.lua` whole).
- **A stage.** Absent.
- **Anything inside an instance.** Arrow and minimap icons hide on `IsInInstance()`
  (`TomTom_CrazyArrow.lua:116`, `TomTom_Waypoints.lua:340`).
- **"Come here" from another person** exists only as "Send waypoint to" party/raid/bg/guild
  (`TomTom.lua:433, 506-532`; the receiver sees "Waypoint from %s" / "Added '%s' (sent from
  %s) to zone %s", `:605-611`); the "Accept waypoints from guild and party members" option is
  commented out of the config panel (`TomTom_Config.lua:565-580`).

### M5. Defaults and ease

`/way 50 50` alone yields an arrow: arrow enabled, "autoqueue" true, "setclosest" true,
arrival 15, TTA on, cleardistance 10, savewaypoints true, corpse arrow true, POI click
integration true, automatic quest POI false, ping false (`TomTom.lua:56-57, 76-93, 114-127`).
No wizard; help printed on bad `/way`.

---

## 4. PFQUEST (+ pfQuest-ascension)

### M1. The config surface

**First run** — dialog "Please select your preferred pfQuest mode:" with three picture
buttons **"Simple Markers"** ("Only show cluster icons with summarized objective locations
based on spawn points"), **"Combined"** ("Show cluster icons with summarized locations and
also display all spawn points of each quest objective"), **"Spawn Points"** ("Display all spawn
points of each quest objective and hide summarized cluster icons.") and a checkbox **"Show
Navigation Arrow"** (tooltip "Navigation Arrow" — "Show navigation arrow that points you to the
nearest quest location."; `pfQuest/config.lua:487-568`).

**Config panel** (`/db config`; `pfQuest/config.lua:53-159`), title "pfQuest Config", headers
and entries:
- **"General"**: "Enable World Map Menu", "Enable Minimap Button", "Enable Quest Tracker",
  "Enable Quest Log Buttons", "Enable Quest Link Support", "Show Database IDs", "Draw
  Favorites On Login", "Minimum Item Drop Chance", "Show Tooltips", "Show Help On Tooltips",
  "Show Level On Quest Tracker", "Show Level On Quest Log".
- **"Questing"**: "Quest Tracker Visibility", "Quest Tracker Font Size", "Quest Tracker Unfold
  Objectives", "Quest Objective Spawn Points (World Map)", "…(Mini Map)", "Quest Objective
  Icons (World Map)", "…(Mini Map)", "Display Available Quest Givers", "Display Current Quest
  Givers", "Display Low Level Quest Givers", "Display Level+3 Quest Givers", "Display Event &
  Daily Quests".
- **"Map & Minimap"**: "Enable Minimap Nodes", "Use Monochrome Cluster Icons", "Use Cut-Out
  Minimap Node Icons", "Use Cut-Out World Map Node Icons", "Color Map Nodes By Spawn", "World
  Map Node Transparency", "Minimap Node Transparency", "Node Fade Transparency", "Highlight
  Nodes On Mouseover".
- **"Routes"**: **"Show Route Between Objects"** (default 1), "Include Unified Quest Locations"
  (1), "Include Quest Enders" (1), "Include Quest Starters" (0), "Show Route On Minimap" (0),
  **"Show Arrow Along Routes"** (1) (`:134-147`).
- **"User Data"**: "Reset Configuration / Quest History / Cache / Everything"; bottom button
  reloads UI ("Close & Reload").

**World-map dropdown** (top-right of the map; `pfQuest/quest.lua:496-540`): **"All Quests" ·
"Tracked Quests" · "Manual Selection" · "Hide Quests"** (= `trackingmethod` 1-4,
`config.lua:54-57`).

**Tracker buttons** (`pfQuest/tracker.lua:186-215`): "Show Current Quests", "Show Database
Results", "Show Quest Givers", "Close Tracker" (prints "Tracker is now hidden. Type `/db
tracker` to show."), "Open Settings", "Clean Database Results", "Open Database Browser".
Tracker row tooltips: "<Click> Unfold/Fold Objectives / <Right-Click> Show In QuestLog /
<Ctrl-Click> Show Map / Toggle Color / <Shift-Click> Hide Nodes"; on a quest giver row
"<Shift-Click> Mark As Done" (`:425-449`).

**Map-node clicks** (`pfQuest/map.lua:566-593`): plain click on a route-eligible node =
**set/unset it as the arrow's target** ("set as arrow target priority", `:587`; eligibility =
cluster ≥ layer 9 with "Include Unified Quest Locations", ender with "Include Quest Enders",
starter with "Include Quest Starters"); other nodes: click cycles color ("Click Node To Change
Color", locale); Shift-click hides the node / marks the quest done ("Use <Shift>-Click To
Remove Nodes", "Use <Shift>-Click To Mark Quest As Done", locale).

**Slash** (`/db`, `/pfquest`, `/pfdb`, `/shagu`; `pfQuest/slashcmd.lua:4-34`): "/db lock -
Lock map tracker", "/db tracker - Show map tracker", "/db journal - Show quest journal", "/db
arrow - Show quest arrow", "/db show - Show database interface", "/db config", "/db unit
<unit> - Search unit", "/db object <gameobject>", "/db item <item> - Search loot", "/db vendor
<item>", "/db quest <questname> - Show specific quest", "/db quests - Show all quests on map",
"/db clean - Clean Map", "/db reset - Reset Map", "/db chests", "/db taxi [faction]", "/db rares
[min, [max]]", "/db mines [min, [max]] | auto", "/db herbs …", "/db scan", "/db query".

**pfQuest-ascension** adds no surface: it is a database patch ("Ascension WoW DB extension for
pfQuest", `pfQuest-ascension.toc:4`; `patchtable.lua:1-15` merges `db/*-ascension.lua`) plus a
version-ping over addon channel (`pfQuest-ascension.lua:17-69`).

### M2. pfQuest vocabulary

| concept | pfQuest word(s) shown | cite |
|---|---|---|
| a place | "node", "spawn point", "cluster icon" / "Unified Quest Locations", "Quest Start"/"Quest End", "Exploration Mark", "Location", "Area/Zone" | `config.lua:94-100, 138`; `database.lua:676`; `locales.lua` |
| a condition | quest state only: "You are on this quest." / "You already did this quest." / "You don't have this quest."; objective done via `IsQuestWatched`/history | `locales.lua`; `quest.lua:199-200` |
| an action (objective verbs) | "Kill %s", "Talk to %s", "Interact with %s", "Use %s on %s", "Use %s at %s", "Loot [%s] from %s", "Loot and/or Use [%s] from %s", "Explore %s", "Use Quest Item at %s", "Speak with %s to obtain [!] %s", "…to complete [?] %s" | `database.lua:387-416` |
| a sequence / order | "Route Between Objects" — computed nearest-neighbour from the player, re-sorted by distance every second; one user-pinned "target" goes first | `route.lua:13-31, 199-227, 253-262`; `:146-165` |
| an arrival | none as word; the arrow fades out as distance approaches the node's area (alpha by `target[4] - area`), no event, no sound | `route.lua:379-388` |
| a state | tracker "Show Current Quests"; map dropdown "All / Tracked / Manual Selection / Hide"; quest history "Mark As Done" | `tracker.lua:186`; `quest.lua:509-540`; `tracker.lua:444` |
| a stage / phase | absent | — |
| a group of things | "cluster" (icons summarizing spawns), "Combined", "quests" (map), "Favorites" | `config.lua:98-100, 491-495, 73` |

### M3. What the reader receives

World-map/minimap **nodes** (icons per unit/object/spawn; cluster icons; colored per quest,
level-colored titles); **route lines** drawn between the ordered objectives and from the
player to the first (`route.lua:264-292`; on the minimap only if "Show Route On Minimap");
the **navigation arrow** at screen centre-100 (draggable with Shift; `route.lua:302-318`) that
rotates toward the first route node with a red→green gradient by facing, and shows the node's
icon, "[level] Title" in difficulty color, the objective sentence ("Kill X", …), and
"Distance: n.n" (`:404-433`); a **quest tracker** list with objectives; tooltips on nodes.
Appears when a route exists and is stable for 1 s ("show arrow when route exists and is
stable", `:233`); hides after 1 s when there is no target, when the player has no map position
("wrongmap"), or "Show Arrow Along Routes" is 0 (`:337-345`). Off: "Show Route Between
Objects", "Show Arrow Along Routes", "/db arrow" toggle, "Hide Quests".

### M4. What pfQuest never lets you express

- **An authored order.** Route order is greedy nearest-neighbour recomputed from the player's
  position; the only user override is pinning ONE node first by clicking it
  (`route.lua:146-165, 199-227, 253-262`). No drag-order, no "then". Absent.
- **Position-based completion / arrival event.** Nodes leave the route only when the quest
  objective completes or the user Shift-clicks; the arrow fades by distance but nothing
  fires (`route.lua:379-388`; `map.lua:566-576`). Absent.
- **"Come here" / player-defined places.** No slash to add a coordinate; places come only
  from the database (`slashcmd.lua:9-34`). Absent.
- **A stage.** Absent. **Conditions** other than quest state: absent (`config.lua`).
- **Instance awareness.** Only the generic "wrongmap" (0,0 map position) hide (`route.lua:335-345`).

### M5. Defaults and ease

First-run dialog picks a display mode and the arrow with two clicks; defaults already give
routes (1), arrow (1), tracker (1), world-map menu (1), spawn points on world map (1)
(`config.lua:53-159`). Accepting a quest is the only "authoring" needed. pfQuest-ascension is
install-and-forget (no options).

---

## 5. CROSS-ADDON TABLE

| concept | WeakAuras | DBM | TomTom | pfQuest |
|---|---|---|---|---|
| a place | "Location": "Zone Name" / "Subzone Name" / "Player Location ID(s)" / "Instance Size Type" (no x/y) | zone (mod load); "/dbm arrow <x> <y>" map-percent point or "<player>" | "waypoint" `<x> <y> [desc]` in a zone | "node" / "spawn point" / "cluster" / "Exploration Mark" (from DB) |
| a condition | "Trigger" (typed: Aura, Spell, Item, Player/Unit Info, Combat Log, Other Addons, Other Events, Custom) + "Conditions" ("If … Then …") + "Load" | none for players; mod code (`RegisterCombat`, events) | distance ("Arrival Distance", "Clear waypoint distance"), death, closest quest POI | quest state (on / done / not have) |
| an action | "On Show"/"On Hide": "Chat Message", "Play Sound", "Glow External Element", "Custom" | "Announce", "special warning", "timer", "Yell", "Set icons", "Play sound", whisper | "Adds a waypoint", "Set as waypoint arrow", "Clear/Remove waypoint", "Send waypoint to" | objective verbs "Kill / Talk to / Interact with / Use … on / Loot … from / Explore" |
| a sequence / order | "Trigger Combination: Any Triggers / All Triggers / Custom Function"; event "Count" (occurrence) | "Next %s", "%s soon", "%s in %s", "Pull in %d sec" | "next closest waypoint" | "Route Between Objects" (nearest-neighbour), one pinned target |
| an arrival | "Range Check: Distance ≤ n" to a *unit* | arrow auto-hide ≤ 3 yd (no word) | "\"Arrival Distance\"" (down arrow), "arriving at a waypoint" (sound), auto-clear | arrow fade by distance (no word) |
| a state | "Loaded / Standby / Not Loaded"; "Aura(s) Found / Missing / Always" | "engaged / down / wiped"; "Enable boss mod" | active "\"Crazy Arrow\" waypoint"; "Save this waypoint between sessions" | "All / Tracked / Manual Selection / Hide Quests"; "Mark As Done" |
| a stage / phase | "DBM Stage" → "Stage" (no installed source); "Entering/Leaving Encounter" | "Phase %d" / "Phase %s" (mod-authored) | absent | absent |
| a group of things | "Group", "Dynamic Group" ("Grow", "Sort"); unit "Smart Group/Party/Raid" | "raid" (broadcast target); option categories "Bars/Announces/Miscellaneous" | "all waypoints (from this zone)" | "cluster" / "Combined"; "quests" |
| reader surface | icon · bar · text · texture · model · glow · chat · sound · TTS | raid-warning text · big centre text · bars · /say yell · raid marks · whisper · range frame · health frame · arrow | crazy arrow (+TTA, yards) · minimap/map icons · chat line · ping | map nodes · route lines · arrow (icon/title/sentence/distance) · tracker |
| works inside instances? | yes (no location dependency) | yes (that is its home) | **no** — arrow/minimap hide on `IsInInstance()` | only where the map returns a player position |
