# Prior art — UI tooling upstream: headless runners, offline layout, lint, layout abstractions, skin registries

_Measured 2026-08-23 by a research pass at the architect's ask, for AP-13 (UI as a system). Raw findings below
are the agent's, unedited; the reading at the top is the architect's. Every claim carries its URL; "not found"
is stated so an absence is a claim and not a silence._

## The architect's reading

1. **Nothing upstream runs 3.3.5 headlessly.** wowless (the serious one) has no Wrath product at all; the 2014
   fakes are dead. Our `frames.lua` stub IS the 3.3.5 headless model — there is no one to adopt, only ideas to take.
2. **Our resolver already exceeds wowless's on diagnostics.** wowless `frames2rects` tsorts the anchor graph and
   `assert`s on a cycle (crash, no report) and calls `GetSize()` unconditionally (no anchor-derived size). Ours
   derives a size from opposing anchors and names the zero-sized consumers. The one thing to take from it is the
   OUTPUT SHAPE: `{frames=[{name,strata,level,regions=[{rect,content,layer}]}]}` → a renderer. That is the join
   AP-13 names (draw from offline rects): wowless's `sdlrender` sorts strata then layer and draws quads. It draws
   **no text** either — FontStrings are the universal hole, and we have the client for that (one measuring run).
3. **No cyclic-anchor / unsized / frame-level linter exists anywhere.** Ours has no precedent; keep it.
4. **Blizzard's LayoutFrame mixins are pure Lua over SetPoint/SetSize and first appear in 7.0.3** (Vertical/
   Horizontal), 8.0.1 (Resize), all present in Wrath Classic 3.4.3. Portable to 3.3.5 as a contained layer IF we
   ever need a non-Ace vertical/horizontal stack. ⚠ Blizzard code, no licence — read the algorithm, write our own.
5. **The de-facto token store on this client is ElvUI-WotLK's Toolkit** — `E.Border`, `E.mult`, `SetTemplate`
   names, `SetOutside/SetInside`, and the pixel-rounding formula `E:Scale(x) = mult*floor(x/mult+0.5)` with
   `mult = (pixel/scale) - ((pixel-ratio)/scale)`, `ratio = 768/screenheight`. That is a 3.3.5a fact set an
   offline rect model can carry; it is also what "pixel perfect" means on this client. LibSharedMedia is the
   named-media registry (font/border/background/statusbar) — a token registry by type, already the convention.
6. **3.3.5 FrameXML source exists** (tekkub/wow-ui-source tag 3.3.5, incl. `UI.xsd`) — the authority for what
   templates actually do, which the smoke README lists as a thing green cannot see.
7. **Font metrics offline: nobody has them.** Confirms ROUTER's line: `F.Unmeasured()` names them; the client answers.

What this changes in AP-13: the pipeline's "drawing from the offline rects" step has a measured shape to copy
(frames2rects → strata/layer sort → quads, text left to the client); the token registry has an existing idiom to
sit beside (LibSharedMedia by type; ElvUI's Border/mult/templates as the first bucket of FACTS, before taste).

---
## Raw findings (research agent, 2026-08-23)

### (a) Headless execution without the client

| Name | URL | What it does (measured) | Versions / 3.3.5? | Lang | Last | Licence | Take |
|---|---|---|---|---|---|---|---|
| **wowless** | https://github.com/wowless/wowless · https://wowless.dev/ | "A headless WoW client Lua and FrameXML interpreter. Intended for addon testing." Pre-alpha. Loads Blizzard FrameXML (submodule), runs addons via `bin/run.sh <product> --addondir …`; flags `--frame0`, `--lite`, `--profile`, `--maxerrors`. UI-object API data-driven from YAML (`data/uiobjects/*`, `data/products/<product>/…`). Vendors `meorawr/elune`. `tools/xmlcontainment.lua` derives legal-children/root/chain queries from the XML schema yaml. | `data/products.yaml`: wow, wow_anniversary, wow_classic (= MoP 5.5.4), wow_classic_era(+ptr), wow_classic_ptr, wowt, wowxptr. **No Wrath / 3.3.5.** | Lua + C/C++ | 2026-08-22 | MIT | data-driven stub architecture; `frames2rects` + `sdlrender`; `xmlcontainment` |
| **elune** | https://github.com/Meorawr/elune | Lua 5.1 with WoW-style taint (untrusted writes taint, reads propagate). Not binary-compatible with the client. | version-agnostic | C | 2025 | MIT | taint testing if ever needed |
| **WowInterfakes** | https://github.com/Pondidum/WowInterfakes | Fakes the UI from a code perspective: parses FrameXml, templates, local API. README admits incomplete. | ~2014 wow-ui-source snapshot | Lua | 2014-04 | none | historic |
| **wowmock** | https://github.com/Adirelle/wowmock | setfenv sandbox loader + small API subset; no frames. | unspecified | Lua | 2014-09 | MIT | setfenv loading idiom only |
| **WoWUnit** | https://github.com/Jaliborc/WoWUnit | In-client runner; not headless. | toc incl. 30404 (Wrath Classic), not 3.3.5 | Lua | 2026-02 | All Rights Reserved | nothing offline |
| busted harness for WoW | — | **Not found** as a project; wowless vendors luassert/say. | — | — | — | — | luassert for assertions |

### (b) Offline layout / rendering

| Name | URL | What it does | 3.3.5? | Lang | Last | Licence | Take |
|---|---|---|---|---|---|---|---|
| **wowless `wowless/render.lua`** | https://raw.githubusercontent.com/wowless/wowless/main/wowless/render.lua | `frames2rects(hframes, product, w, h)`: tsorts anchor deps (`resty.tsort`), `p2c(r,p)` to absolute coords, emits `{frames=[{name,strata,level,regions=[{rect,content,layer,debugname}]}],screen,product}`. Cycles: `assert(tt:sort())` — crash, no report. Unsized: `r:GetSize()` unconditionally, no anchor-derived fallback. Table output, not image. | no | Lua | 2026 | MIT | output shape; confirms tsort-over-anchor-graph; lacks our diagnostics |
| **wowless `tools/sdlrender.lua` + `tools/sdl.c`** | https://raw.githubusercontent.com/wowless/wowless/main/tools/sdlrender.lua · …/tools/sdl.c | Reads the rects YAML, sorts frames by strata (1-9) then regions by layer (1-5), draws textures as quads (vertex colour + blend) from CASC via `tactless`, PNG via SDL3 + SDL_image. **No text.** Issues #220 "png renderings not deterministic" (open), #601 structural validation of rendered output (open). | no | Lua + C | 2026 | MIT | strata→layer sort; rect→quad; we add text |

### (c) Structure lint

| Name | URL | What it does | 3.3.5? | Take |
|---|---|---|---|---|
| **Meorawr/wow-ui-schema** | https://github.com/Meorawr/wow-ui-schema | Blizzard `UI.xsd` tweaked for addon XML validation. Retail-tracking. | no (3.3.5 ships its own `FrameXML/UI.xsd`, tekkub tag 3.3.5) | XML only |
| **wowless `tools/xmlcontainment.lua`** | https://raw.githubusercontent.com/wowless/wowless/main/tools/xmlcontainment.lua | schema-derived containment queries (chains/legalChildren/roots). | — | pattern for schema-derived checks |
| **wind-addons/wow_global_check** | https://github.com/wind-addons/wow_global_check | Rust CLI: globals that should be local. | any | not frame-aware |
| luacheck configs | https://github.com/BigWigsMods/luacheck · https://github.com/Jayrgo/wow-luacheckrc · https://gist.github.com/LenweSaralonde/13a217b5d7186f9218ae62736e2bff90 | globals whitelists; no structural checks. | retail lists; a 3.3.5 list would be built from 3.3.5 FrameXML | whitelist idea |
| anchor-cycle / unsized / frame-level linter | — | **Not found** (only client-error forum threads, e.g. https://eu.forums.blizzard.com/en/wow/t/troubleshooting-setpoint-would-result-in-anchor-family-connection-error/64943). | — | ours has no precedent |
| tree-sitter / luau analysers for WoW | — | **Not found**; generic grammars only. | — | — |

### (d) Declarative layout over SetPoint

| Name | URL | What it does | First appeared / 3.3.5? | Licence | Take |
|---|---|---|---|---|---|
| **Blizzard LayoutFrame.lua** | https://raw.githubusercontent.com/Gethe/wow-ui-source/7.0.3/SharedXML/LayoutFrame.lua · …/8.0.1/SharedXML/LayoutFrame.lua · …/3.4.3/Interface/SharedXML/LayoutFrame.lua | 7.0.3: `LayoutMixin, VerticalLayoutMixin, HorizontalLayoutMixin`; 8.0.1 adds `BaseLayoutMixin`, `ResizeLayoutMixin` (resize to child extents, min/max); 3.4.3 full set incl. `GridLayoutFrameMixin`. Algorithm: gather+sort children by layoutIndex → anchor with padding/alignment → resize parent → relayout if expandable. | **not in 3.3.5**; pure Lua over SetPoint/SetSize so portable | none (Blizzard) | port the algorithm as a contained layer if a non-Ace stack is ever needed |
| **AceGUI-3.0 layouts** | https://raw.githubusercontent.com/WoWUIDev/Ace3/master/AceGUI-3.0/AceGUI-3.0.lua | `RegisterLayout`: List (stack; width "fill"/"relative"), Fill (first child all points), Flow (row flow on `usedwidth` vs content width, rowheight/rowoffset, "fill" takes the row, `LayoutFinished(w,h)`), Table (colspan/rowspan, weighted columns). MINOR 41. | toc lists 30405 (Wrath Classic), not 30300; 3.3.5 bundles exist (e.g. https://github.com/hurricup/WoW-Ace3) | BSD-style | the closest declarative layout on our era's API — what we already use |
| **LibWindow-1.1** | https://www.wowace.com/projects/libwindow-1-1 (copies e.g. https://github.com/fgprodigal/RayUI/blob/master/Interface/AddOns/Skada/lib/LibWindow-1.1/LibWindow-1.1.lua) | `RegisterConfig`, `SavePosition` (quadrant-relative to nearest corner), `RestorePosition`, `SetScale`, `MakeDraggable`, mouse-wheel scaling. Position persistence, not layout. | pure Lua; runs on 3.3.5 (Skada forks) | Public Domain | quadrant-relative save idiom |

### (e) Token / skin registries

| Name | URL | What it does | 3.3.5? | Last | Licence | Take |
|---|---|---|---|---|---|---|
| **ElvUI-WotLK Skins** | https://raw.githubusercontent.com/ElvUI-WotLK/ElvUI/master/ElvUI/Modules/Skins/Skins.lua | `S:AddCallbackForAddon(addon, event, fn, forceLoad, bypass)` + `S:AddCallback`; `S:Initialize()` order: non-addon callbacks → loaded addons → hook `ADDON_LOADED`. Primitives `HandleButton/HandleTab/HandleCheckBox/HandleScrollBar/HandleEditBox/HandleSliderFrame`; combat-deferred queues. | **3.3.5a** | 2024-07 | none | per-addon callback registry + primitive vocabulary |
| **ElvUI-WotLK Toolkit / PixelPerfect** | https://raw.githubusercontent.com/ElvUI-WotLK/ElvUI/master/ElvUI/Core/Toolkit.lua · …/Core/PixelPerfect.lua | Metatable-injected `Size, Point, Width, Height, SetOutside, SetInside, SetTemplate, CreateBackdrop, CreateShadow, Kill, FontTemplate, StripTextures, StyleButton, CreateCloseButton`. `Point/Size` route offsets through `E:Scale(x) = mult*floor(x/mult+0.5)`; `E.mult = (pixel/scale) - ((pixel-ratio)/scale)`, `ratio = 768/screenheight`; `E:PixelBestSize` clamps 768/screenheight to [0.4, 1.15]. `SetTemplate` names: ClassColor, Transparent, default; `SetOutside/SetInside` default `E.Border`. | 3.3.5a | 2024 | none | the token set and the rounding formula — facts for the offline rect model |
| **ElvUI_AddOnSkins (WotLK)** | https://github.com/ElvUI-WotLK/ElvUI_AddOnSkins | 95+ addon skins via the S:Handle* helpers. | 3.3.5a | 2024-02 | none | skin corpus |
| **AddOnSkins (Azilroka)** | https://github.com/Azilroka/AddOnSkins | `AS:RegisterSkin(name, fn, priority, '[AddonLoader]')`, `CheckAddOn`, `UnregisterSkin`. | retail | 2025-10 | none | named-skin registry with priority |
| **LibSharedMedia-3.0** | https://www.wowace.com/projects/libsharedmedia-3-0 · 3.3.5 packs https://github.com/bkader/SharedMedia, https://github.com/NoM0Re/SharedMedia | Media registry by type: background/border/statusbar, font, sound; `Register(type,name,path)`, `Fetch`, `List`, callbacks. | yes | active | LGPL | the de-facto by-type token store on this client |
| **wind-addons/wow-windmedia** | https://github.com/wind-addons/wow-windmedia | Rust library managing SharedMedia assets offline. | — | — | — | offline media manifest idea |

### (f) Font metrics offline
**Not found.** wowless `FontString/SetText.lua` stores text only; no `GetStringWidth`; renderer has no SDL_ttf. Only fact: `GameFontNormal` = `Fonts\FRIZQT__.TTF` 12px (https://addonstudio.org/wiki/WoW:XML/FontString). fontTools/Pillow over the client TTF would be unvalidated against client rasterisation.

### (g) UI designer tools

| Name | URL | What it does | Era | Licence |
|---|---|---|---|---|
| **WoW UI Designer** (fenlis) | https://www.wowinterface.com/downloads/info4222-WoWUIDesigner.html | form-designer IDE for Lua/XML, C#/.Net 2.0; download 403s. | ~2007-2010, Wrath | closed |
| **AddOn Studio for WoW 2.0** | https://github.com/FallenWorlds/AddOn-Studio-for-World-of-Warcraft-2.0 | VS-shell drag-drop designer; last commit 2009. | 3.0 | Ms-PL |
| **AddOn Studio 2022** | https://addonstudio.org/wiki/AddOn_Studio_2022_for_World_of_Warcraft · https://github.com/FallenWorlds/AddOnStudio | VS2022 extension with visual designer; v7.0.251028.0 (2025-10-28); VS ≤17.12. | retail + classic | not open source |

### Supporting: stubs / API data

| Name | URL | Notes |
|---|---|---|
| Ketho/vscode-wow-api | https://github.com/Ketho/vscode-wow-api | LuaLS annotations; Retail/MoP/Vanilla; MIT; no 3.3.5 |
| Ketho/BlizzardInterfaceResources | — | enums/GlobalStrings; no Wrath branch |
| araxiaonline/wow-wotlk-declarations | https://github.com/araxiaonline/wow-wotlk-declarations | TS declarations for 3.3.5a; MIT; 2024-07 — the only 3.3.5-specific API surface found |
| Gethe/wow-ui-source | https://github.com/Gethe/wow-ui-source | tags from 3.4.0; no 3.3.x; no licence |
| **tekkub/wow-ui-source** | https://github.com/tekkub/wow-ui-source | **tags 3.3.0, 3.3.3, 3.3.5** (verified `3.3.5/FrameXML/UIParent.lua`) — our era's FrameXML + `UI.xsd` |
| tomrus88/BlizzardInterfaceCode | https://github.com/tomrus88/BlizzardInterfaceCode | branches incl. `wrath` (3.4, not 3.3.5); no licence |

### Does not exist / could not find
- A headless runner with a 3.3.5 / Wrath product.
- Any offline tool that renders FontStrings or measures WoW font widths.
- A cyclic-anchor / unsized-frame / frame-level linter.
- A busted-based WoW frame harness as a project.
- Tree-sitter / luau WoW analysers.
- Source for WoW UI Designer or AddOn Studio 2022's designer.
- `LayoutFrame` / `ResizeLayoutMixin` in any 3.3.5 FrameXML (first 7.0.3 / 8.0.1).
- A canonical GitHub for LibWindow-1.1.
