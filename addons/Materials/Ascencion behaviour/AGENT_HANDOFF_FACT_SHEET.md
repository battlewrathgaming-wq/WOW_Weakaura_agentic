# COA_GuardianPlates - Fact Sheet for Local Code Agent Handoff

Compiled from a Cowork chat session (2026-07-15) covering live debugging, a
documentation pass, and a git incident on this addon. Written for a fresh
local coding agent picking up addon production with no prior context.

## Project identity

- **Addon folder name:** `COA_GuardianPlates` (do not rename - this is the
  live AddOns folder name and the `## SavedVariablesPerCharacter:
  COA_GuardianPlatesDB` key; both are load-bearing and untouched by the
  cosmetic rebrand below).
- **Outward brand:** "COA State Plates" (renamed from "COA Guardian
  Plates" at v3.1 - .toc `## Title:`, in-chat naming, and doc prose all
  say "State Plates"/"Enemy Plates" now; the folder/SavedVariables/.toc
  filename intentionally did not follow).
- **Path:** `F:\Projects_games\World of Warcraft - Conquest of
  Azeroth\Weak Auras\Tools\COA_GuardianPlates\`
- **Client/server:** WotLK 3.3.5a, Ascension private server, project
  "Conquest of Azeroth" (realm Vol'jin). Project-wide framing: "Low risk
  experimental modelling and theory craft" - not a production/competitive
  addon, safe to iterate boldly.
- **Current version:** v3.5.42 (see `.toc` `## Notes:` for the full
  per-version changelog back to v3.1 - it's long and narrates essentially
  every change with the user's own quotes as rationale; read it before
  assuming something is undocumented).

## Architecture

Three files, one shared executor:

- **Core.lua** (~2760 lines) - the ONLY code that ever calls
  `SetAlpha`/`SetStatusBarColor`/`SetTextColor`/drives the glow library
  directly. Owns: unit/plate tracking (`ns.activeUnits`, `ns.plateOwner`
  dedup guard, `ns.unitIndex`), classification helpers
  (`IsFriendlyPlayer`/`IsHostileUnit`/`IsPotentialThreatUnit` etc.),
  player-role + group-roster caches, all executor primitives
  (`SetSuppressed`, `SetHealthBarColor`, `SetNameColor`, `SetGlow`,
  `SetHandRolledGlow`, native aggroHighlight locate/recolor/suppress),
  the event dispatch frame, reclassify ticker, unified `/coasp log`
  debug/perf monitor, copyable export box, and the render-test registry
  + cycle engine.
- **FriendlyPlates.lua** (`ns.Friendly`, ~739 lines) - suppression of
  friendly PLAYER nameplates, healer mode (partial reveal on low HP),
  NPC/pet/guardian color override. Signal/behavior only - never touches
  visual state directly, always calls into Core.
- **EnemyPlates.lua** (`ns.Enemy`, ~1425 lines) - threat coloring
  (secure/warning/danger, tank vs DPS view), Mob Aggro Cue (early
  percentage-based warning), Instance Fill option. Same rule: computes
  WHAT should be true, hands it to Core.

**Dispatch contract:** Core pre-creates `ns.Friendly = {}` / `ns.Enemy =
{}`; each module fills in its own `OnUnitAdded`/`OnUnitRemoved`/
`OnReclassify`/`OnThrottledTick`/etc. functions, called by Core's event
frame wrapped in `pcall`. Neither module has to exist for the other to
keep working. Read the top-of-file doc comment in `Core.lua` for the
exact contract - it's spelled out in full there.

**Governing principle (Battlewrath's own framing, repeated throughout):
"Core is the executor... everything pulls requirements from what we
attach to it."** Any new capability should follow this shape: put the
actual draw/hook primitive in Core, keyed generically (not hardcoded to
one caller), and have Friendly/Enemy just decide when to invoke it.

**Slash commands:** everything lives under `/coasp` now (Core-owned,
shared). `/coagp` and `/coaep` used to exist as separate per-module
commands but were consolidated - don't reintroduce a parallel command
surface for a new module; register with Core instead
(`ns.RegisterRenderTest`, etc.).

## Key confirmed technical findings

- **This client backports the Legion/BfA CompactUnitFrame nameplate
  system into 3.3.5a.** Confirmed via a live `debugstack` capture (the
  `/coasp watchaggro` tool): the native "you have aggro" red highlight is
  driven by `CompactUnitFrame.lua:773 UpdateAggroHighlight`, called via
  `UpdateAll <- SetUnit <- Ascension_NamePlates\NamePlateDriver.lua:227`.
  **The live capture stands - it was and remains a real confirmation.**
  - **CORRECTED 2026-07-17 (macros bench): the tail of this bullet -
    "this could only be confirmed by catching it live, not by reading
    source" - no longer holds.** Both files are readable on disk now:
    `Outputs/client_interface/patch-B/Interface/FrameXML/CompactUnitFrame.lua`
    (`CompactUnitMixin:UpdateAggroHighlight` at ~:770) and
    `.../AddOns/Ascension_NamePlates/NamePlateDriver.lua`. See the MPQ
    bullet below. Live capture is still the *completeness* check (a C-side
    driver no Lua file calls stays invisible to source) - but source is no
    longer a closed door, and it is much the cheaper first look.
  - **LEAD for the still-open #266 (addons bench's to take, not mine).**
    The real function gates on its own option table before it ever
    touches the texture:
    `if not self.optionTable.displayAggroHighlight then ... aggroHighlight:Hide() ... return end`
    (with a second `playLoseAggroHighlight` branch). The saga's open
    blocker is "the v3.5.42 suppress hook reaches the real driver but
    showed no visible effect, cause not yet isolated" - an `optionTable`
    gate upstream of the draw is a candidate explanation worth reading
    before the next hypothesis→test round. **Per this file's own
    principle 3, a source read is a LEAD, not settled** - it wants a live
    confirm exactly like everything else here. Flagged across the lane by
    the macros bench; not investigated from that seat.
- **Instance-scoped `hooksecurefunc` is the reliable technique on this
  client** - hook the actual, already-located frame/texture OBJECT's own
  method (`hooksecurefunc(frame, "Show", ...)` /
  `hooksecurefunc(texture, "SetVertexColor", ...)`), not a guessed global
  function name. This is what finally worked after several guessed-name
  hooks (`UnitFrame_UpdateThreatIndicator`,
  `CompactUnitFrame_UpdateAggroHighlight` as a global) were proven wrong
  via live traces. **Any external code lead (CurseForge, AI search
  results, forum posts) should be treated as an unverified name until
  confirmed live** - this project has been burned by plausible-sounding
  but wrong function names more than once; the standing convention is to
  verify via `/coasp scanglobals`/`scantables`/`upvalues`/`watchaggro`
  before trusting a pasted name.
- **Hand-rolled glow texture is the addon's sole production threat
  signal** (`ns.SetHandRolledGlow`/`ClearHandRolledGlow` in Core.lua,
  tuned v3.5.23-28). It reuses a real client texture
  (`Interface\QuestFrame\bonusobjectives`, the
  "bonusobjectives-bar-glow-ring" atlas piece) that the addon creates and
  owns outright, so `Show()`/`Hide()`/`SetVertexColor` are guaranteed to
  actually apply - no external frame's visibility logic to fight, and no
  per-frame `OnUpdate` cost (static tinted texture, not an animated
  LibCustomGlow effect).
- **Native aggroHighlight recolor (v3.5.40) and suppress (v3.5.42) are
  built but NOT wired into production.** Both use the proven
  instance-scoped hook technique and are confirmed to reach the real
  driver, unlike earlier dead-end attempts - but a live macro test of the
  suppress hook showed no visible effect, cause not yet isolated. Test
  via `/coasp suppressaggro on|off [unit]` and
  `/coasp watchaggro [unit]`. Full research trail (12+ version
  iterations of hypothesis -> test -> revision) is in
  `AggroHighlight_Saga/FINDINGS.md` and `CHANGELOG.md` - read those before
  re-investigating this so prior dead ends aren't repeated.
- **LibCustomGlow's `PixelGlow_Start` auto-derives dash `length` from
  frame size when `length` is nil, via `floor((width + height) * (2 / N -
  0.1))` - this formula goes NEGATIVE once N >= 20** and silently fails
  every frame (a negative value passed to `SetSize` inside the library's
  own OnUpdate). Always pass an explicit small positive `length` for any
  high-N PixelGlow style; see `GLOW_STYLE_PARAMS.threatDanger` in
  Core.lua for the fix and its own doc note.
- **~~MPQ archives are not extractable.~~ CHALLENGED + CORRECTED
  2026-07-17 (macros bench) - the archives ARE extractable locally, and
  the client's entire UI source is readable on disk right now.**
  `py addons\tools\extract_interface.py` uses **mpyq successfully**;
  `patch-B.MPQ` carries ALL client-side code (823 lua / 1299 files) and
  is extracted to `Outputs/client_interface/patch-B/` with a sha256
  manifest. `addons/maps/census/` is built on it. **Read
  `Outputs/client_interface/patch-B/Interface/` before concluding
  anything about this client is unreadable.**
  - **The original bullet was TRUE IN ITS ENVIRONMENT** (Battlewrath,
    2026-07-17: "that is what was true during that env, pre-code
    agents") - it was written from the Cowork sandbox, before local code
    agents worked this repo directly. It is kept below as history, not
    deleted: the wall was real *there*. What changed is the environment,
    not the archives.
  - **Why it over-generalized** (the lesson worth keeping): it reports
    failure "on even the smallest archives" - and the smallest archives
    are exactly the ~8 listfile-less art archives (patch-4/5/C/CZZ/P/W/
    WB/WC) that genuinely have no `(listfile)` and still can't be
    listed. Starting small is the right instinct and it landed on the
    one broken subset, which then read as "all archives". The
    code-bearing archive was never the problem. **A negative result from
    a convenience sample is not a general negative** - the same shape as
    this file's own "verify before assuming" lesson, pointed at itself.
  - **Real cost, measured:** a fresh local agent (2026-07-17) read this
    bullet, believed it, and nearly ruled out the client's own FrameXML -
    which is the authoritative source for the macro/slash-command
    surface and the whole basis of `operations/Macros.md`. Operations had
    already carried the correction since 2026-07-15 (`Addons_load.md`
    standing cautions: "the Cowork-era 'mpyq can't read these MPQs'
    claim is false locally - don't re-inherit that wall from old notes";
    `STATE.md`: "CompactUnitFrame now readable"). **This handoff sheet is
    what a fresh agent reads FIRST, so a stale claim here outranks a
    correct one in operations.** Boot on `addons/invariants.md` +
    operations, then this.
  - _Original (2026-07-15, Cowork sandbox - kept for context):_ "MPQ
    archives are not extractable from a sandboxed environment. `mpyq`
    (pure Python) fails on even the smallest archives (`AttributeError`
    reading the internal listfile, likely unsupported compression); no
    StormLib/python-mpq bindings installable via pip; no CLI tools (7z,
    unmpq) available. A Windows-native tool (Ladik's MPQ Editor,
    CascView) run directly on the user's machine is the only realistic
    path... Concluded not worth pursuing further given live-capture tools
    already answer most 'what's the real driver' questions." (Ladik's
    remains the named fallback for the 8 listfile-less archives - see
    `Addons_load.md` small debts. 5 individual patch-B files also failed
    `read_file`; named in that extraction's `manifest.json`.)

## Critical testing constraint (anti-cheat)

**New/edited Lua addon files cannot be loaded via `/reload` on this
setup - a FULL CLIENT RESTART is required.** Battlewrath's own words:
"You can't live load into WoW... it's the injection of the running
engine that is considered a memory violation." This is a hard constraint
on this client/account, not a general WoW limitation - do not assume
`/reload` is sufficient to test new code, and do not build tooling that
depends on it. Only a plain `/run` macro using exclusively
already-resident Blizzard API (no reference to this addon's own `ns`
namespace, since that's a private Lua upvalue invisible outside the
addon) can be tested without a full restart.

## Repo/git notes

- Git history and the remote are intact and up to date as of this
  session - a stale `multi-pack-index` was found and fixed
  (`git multi-pack-index write`), and a scary but ultimately harmless
  moment where `git checkout` briefly staged a mass deletion (including
  `.gitignore`) was caught and reverted via `git reset` before anything
  was committed. Nothing bad actually landed in history.
- **`Addon refs_threat/` is third-party reference addon source**
  (bdThreat, NamePlatesThreat, QoL_ClassicThreat-TBC, ThreatMeter,
  TidyPlates_ThreatPlates, WhoThreatAggro) downloaded for design/API
  research, not this project's own code. It was deliberately left
  untracked during one commit in this session but ended up pushed anyway
  via the user's own commit/push script - Battlewrath is fine with that,
  but a code agent should not treat anything under that folder as
  project-authored code, and should be cautious about license
  implications if ever redistributing this repo.
- Embedded libraries: `Libs/LibStub/`, `Libs/LibCustomGlow-1.0/` - own
  copies bundled with the addon (not relying on another addon's already-
  loaded instance), standard WoW addon practice, fine to keep committed.
- `deploy_to_game.bat` exists in the addon folder for pushing built files
  to the live AddOns directory - check it before assuming a manual copy
  step is needed.
- A previously-relevant "FUSE mount-lag" sandbox bug (Cowork's own
  bash-mount cache occasionally serving stale/truncated file content)
  should NOT apply to a local code agent working directly on disk - that
  was specific to this chat's sandboxed environment, not a property of
  the files or repo themselves. Mentioned here only so a fresh agent
  doesn't get confused by references to it in older doc comments/commit
  messages.

## Open / pending work

- **Task #266 - build a "focus" indicator** (static glow for current
  target): the original motivation for the whole native-aggroHighlight
  suppress/recolor investigation. Blocked on confirming the suppress hook
  (v3.5.42) actually holds live - next real step once Battlewrath resumes
  testing (paused for fatigue, not a dead end).
- **Task #197 - "Needs-action" highlight capability** (future,
  unscoped).
- **Task #251 - Healer aggro-shift awareness** (future consideration,
  unscoped).
- `GLOW_STYLE_PARAMS`/`ns.SetGlow` (the animated LibCustomGlow path) is
  still present in Core.lua but unused by production threat coloring
  since v3.5.29 - kept specifically as the mechanism a future capability
  (#197/#251) might reuse, per Battlewrath's own "work out what that
  extra signal is good for" framing. Don't delete it as dead code without
  checking those tasks first.

## Where to read more

- `Core.lua`'s own header doc comment - the fullest single explanation of
  the module split rationale and dispatch contract.
- `COA_GuardianPlates.toc`'s `## Notes:` field - the complete
  version-by-version changelog, written in narrative form with the user's
  own quotes as the rationale for each change. Genuinely useful as design
  history, not just changelog noise.
- `AggroHighlight_Saga/` (README, CHANGELOG, CODE_MAP, FINDINGS) - the
  flattened, self-contained writeup of the entire native-aggroHighlight
  investigation (v3.5.16-v3.5.42). Read this before touching anything
  aggroHighlight-related again.
- `README.md` - project-level overview, points here for anything past
  ~v3.5.2 (its own prose narration stops there; the .toc is the
  authoritative changelog from that point on).
