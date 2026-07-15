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
  `CompactUnitFrame.lua` itself is packed inside this client's MPQ
  archives (not a loose readable file) - this could only be confirmed by
  catching it live, not by reading source.
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
- **MPQ archives are not extractable from a sandboxed environment.**
  `F:\games\Ascension_wow\resources\ascension-live\Data\*.MPQ` - `mpyq`
  (pure Python) fails on even the smallest archives
  (`AttributeError` reading the internal listfile, likely unsupported
  compression); no StormLib/python-mpq bindings installable via pip; no
  CLI tools (7z, unmpq) available. A Windows-native tool (Ladik's MPQ
  Editor, CascView) run directly on the user's machine is the only
  realistic path, with no guarantee custom archives even have a
  `(listfile)`. Concluded not worth pursuing further given live-capture
  tools already answer most "what's the real driver" questions.

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
