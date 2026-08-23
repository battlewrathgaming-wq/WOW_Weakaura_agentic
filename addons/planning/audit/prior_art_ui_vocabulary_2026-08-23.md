# Prior art — the designer's vocabulary: tokens, spacing, type roles, density, Gestalt, game-UI taxonomy, surfaces, layout

_Measured 2026-08-23 by a research pass at Battlewrath's ask ("see what the industry norm terms and concepts
are, then we cut the axis of our ingest / bucketing based on those where we can"), for AP-13. Raw findings
below are the agent's, unedited, with its own well-established / stretch markings kept. The cut at the top is
the architect's proposal — source vocabulary where one exists, ours only where none does, each marked._

## The architect's cut — the axes of a captured fact

A capture (AP-13) carries **measurement · why · job**. The industry gives the first and, partly, the third.

### Axis 1 — the BUCKET (what was measured). Source: Nathan Curtis, *Space in Design Systems* (2016) + DTCG types.
| our working word | the term | status |
|---|---|---|
| edge inset | **inset** (square · squish · stretch) | established |
| vertical sibling gap | **stack** | established |
| horizontal sibling gap | **inline** | established |
| column gap | **gutter** | established |
| control height | **size** — and it *results from* type + padding + border (Curtis, *Size in Design Systems*), so capture the parts, not just the height | established |
| font per role | **type role** — Carbon's productive set (`heading · body · label · helper-text · code`) fits a dense product UI better than Material's display-led scale | established; the Carbon choice is ours |
| backdrop | **surface** (M3 `surface container lowest…highest` is by tone, NOT opacity — do not rank WoW backdrop alphas on it) | established; the alpha caveat is the agent's |
| border | DTCG **border** composite (colour · width · stroke style) + **radius** separately | established |
| the tier of a value | DTCG **group**; three tiers **reference → system → component** (M3) / global → alias → component (Salesforce). Mapping: raw captured pixels = reference · our bucket names = system · per-addon values = component | established; the mapping is ours |

### Axis 2 — the JOB (what kind of problem the source addon's UI solves). His three, in source terms.
| his word | the term | status |
|---|---|---|
| "information packed" (WA, meters, unit frames) | **persistent HUD · compact density · data-rich** (Fagerholt non-diegetic; Material density −1..−3; Tufte data-ink) | non-diegetic is a paper; "persistent" is practitioner usage; applying Material's density steps numerically to WoW frames is a STRETCH |
| "display" (pfQuest, maps, trackers) | **contextual HUD · wayfinding**; Fagerholt **spatial** for markers anchored in the world, non-diegetic for the minimap | Fagerholt is established; "wayfinding" has no design-system home (Material's Navigation means screen-switching) — ours |
| "style and presentation" (skins, reskins) | **theme** (M3: a theme = remapping reference→system tokens) | established |
| (ours, not yet his) "authoring / configuration" (options panels, the WA editor — and the Dungeon Run editor) | **inspector / property panel · tree view · sidebar / panel** (Unity, Figma, VS Code, Blender) — NO standards body has a purpose class called authoring | structural terms established; the class is a STRETCH |

⚠ No single source gives a purpose taxonomy. The most citable closed list is **Material 3's six component
categories: Action · Containment · Communication · Navigation · Selection · Text input.** If one vocabulary
is wanted for "what is this control FOR", that is it — and it is a CONTROL axis, not an addon axis.

### The cut, as a yes/no
The captured fact carries: **bucket** (Curtis/DTCG names above) · **tier** (reference/system/component) ·
**job of the source addon** (his list, glossed with the terms above; authoring added as a fourth candidate) ·
**his why**. Optional fifth, on controls only: the M3 category. Nothing invented past what the table shows.

---
## Raw findings (research agent, 2026-08-23)

### 1. Design tokens
| Term | Definition | Canonical source | Used by |
|---|---|---|---|
| **design token** | named entity storing a visual design attribute; coined by Jina Anne at Salesforce ~2014 for Lightning | [SLDS](https://developer.salesforce.com/docs/platform/lwc/guide/create-components-css-design-tokens.html); [CSS-Tricks](https://css-tricks.com/what-are-design-tokens/); [history](https://www.designsystemscollective.com/the-incomplete-history-of-design-tokens-61581c573e5d) | all |
| **DTCG Format Module 2025.10** (W3C Design Tokens CG) — first stable spec, Oct 2025 | `$value`, `$type`, `$description`, `$extensions`, `$deprecated`; **group** = tokens of one category; alias via `{group.token}` | [spec](https://www.designtokens.org/tr/drafts/format/), [announcement](https://www.w3.org/community/design-tokens/2025/10/28/design-tokens-specification-reaches-first-stable-version/) | Style Dictionary, Tokens Studio, Terrazzo, Figma |
| DTCG `$type` values | primitive: `color, dimension, fontFamily, fontWeight, duration, cubicBezier, number`; composite: `strokeStyle, border, transition, shadow, gradient, typography`. The spec types VALUES not purposes — "spacing" is a `dimension` | same | — |
| **Tier taxonomy** | Salesforce: global (primitive) → alias (semantic) → component. Material 3: reference (`md.ref.*`) → system (`md.sys.*`) → component (`md.comp.*`) | [M3 tokens](https://m3.material.io/foundations/design-tokens) (JS-rendered; tiers confirmed via [material-web theming](https://material-web.dev/theming/material-theming/)) | Material, SLDS, Atlassian, Polaris |
| **Atlassian** naming Foundation · Property · Modifier | foundations `color, elevation, space, font`, plus `border`, `opacity` [unverified-here]; `space.100` = 8px | [tokens](https://atlassian.design/foundations/tokens/design-tokens), [spacing](https://atlassian.design/foundations/spacing) | Atlassian |
| **Polaris** groups | `color, font, space, border, shadow, motion, z-index, breakpoints, height/width` | [repo](https://github.com/Shopify/polaris-tokens), [z-index](https://polaris.shopify.com/tokens/z-index) | Shopify |
| **Carbon** | `$spacing-01..13` (component), `$layout-01..07` (layout, v10), `$fluid-spacing-01..04`; type tokens in productive / expressive sets | [spacing](https://carbondesignsystem.com/elements/spacing/overview/), [layout sass](https://github.com/carbon-design-system/carbon/blob/main/packages/layout/docs/sass.md) | IBM |
| **Material 3 categories** | color, typography, shape, elevation, motion, state [unverified-here: exact list] | M3 tokens | Material |

Cross-system consensus for CATEGORY names: color · typography(font) · space · size/dimension · border (width/radius) · shadow/elevation · motion · z-index/layer · breakpoint · opacity.

### 2. Spacing systems
| Term | Definition | Source |
|---|---|---|
| **8dp grid / 4dp subdivision** | spacing and sizes in multiples of 8 (4 for fine); Material margins/gutters 8/16/24/40dp | [M1 responsive UI](https://m1.material.io/layout/responsive-ui.html), [M2 layout grid](https://m2.material.io/develop/web/supporting/layout-grid) |
| **columns · gutters · margins** | columns = content areas; gutters = space BETWEEN columns; margins = content ↔ screen EDGE | same |
| **Inset** | space on all four sides of a container | Nathan Curtis, *Space in Design Systems* (2016): [eightshapes](https://eightshapes.com/articles/space-in-design-systems/), [medium](https://medium.com/eightshapes-llc/space-in-design-systems-188bcbae0d62) |
| **Squish inset** | top/bottom reduced (~50%) — buttons, pills | same |
| **Stretch inset** | top/bottom increased — text fields | same |
| **Stack** | vertical space between siblings | same |
| **Inline** | horizontal space between siblings that flow/wrap | same |
| **Grid** (Curtis) | columns/gutters/outer margins | same |
| **T-shirt scale** | XS/S/M/L/XL naming of a spacing scale; Cloudscape `xxx-small…xxx-large` on a 4px base | same; [Cloudscape spacing](https://cloudscape.design/foundation/visual-foundation/spacing/) |
| **padding vs margin** | Cloudscape: paddings INSIDE components, margins BETWEEN; Carbon: spacing scale (within) vs layout scale (between) | Cloudscape; Carbon |
| **Size ≠ density** | control height results from font-size + line-height + padding + border tuned together | Curtis, *Size in Design Systems* (2019): [eightshapes](https://eightshapes.com/articles/size-in-design-systems/) |

### 3. Typography roles
| Term | Definition | Source |
|---|---|---|
| **M3 type roles** `display, headline, title, body, label` × large/medium/small = 15 (+ emphasized set) | Display = glanceable hero; Headline = primary headings; Title = card/dialog headers; Body = reading; Label = short functional text in controls | [material-web typography](https://material-web.dev/typography/), [Android M3](https://developer.android.com/develop/ui/compose/designsystems/material3) |
| **Carbon type sets** `productive` (14px base, fixed headings, dense product UI) vs `expressive` (16px, fluid, editorial); tokens `heading-01..07, body-01/02, label-01/02, helper-text-01/02, code-01/02, legal-01/02` | | [type sets](https://carbondesignsystem.com/guidelines/typography/type-sets/), [style strategies](https://carbondesignsystem.com/elements/typography/style-strategies/) |
| **type scale** | ordered set of sizes, often ratio-based | Material, Carbon |
| **measure** | line length; 45–75 chars, 66 ideal | Bringhurst §2.1.2 via [webtypography](http://webtypography.net/2.1.2) |
| **leading / line-height** | baseline-to-baseline | Bringhurst; DTCG `typography` |
| **typography composite** = fontFamily + fontSize + fontWeight + letterSpacing + lineHeight | | [DTCG](https://www.designtokens.org/tr/drafts/format/) |

### 4. Information density
| Term | Definition | Source |
|---|---|---|
| **Material density scale** | 0 default; −1, −2, −3 each −4dp component height; "compact" for data-rich UIs; never densify focused inputs or attention components | [M2 applying density](https://m2.material.io/design/layout/applying-density.html), [Una Kravets](https://m3.material.io/blog/material-density-web) |
| **default / comfortable / compact** | the three named levels | [MUI density](https://mui.com/material-ui/customization/density/) |
| **Content density: comfortable / compact** | 4px unit; compact reduces vertical paddings and margins in 4px steps | [Cloudscape](https://cloudscape.design/foundation/visual-foundation/content-density/), [pattern](https://cloudscape.design/patterns/general/density-settings/) |
| **data-ink ratio · chartjunk · data density** | Tufte 1983 | [InfoVis wiki](https://infovis-wiki.net/wiki/Data-Ink_Ratio), [NN/g clutter](https://www.nngroup.com/articles/clutter-charts/) |
| **data-dense / data-rich UI** | Material's phrasing | M2 density |

### 5. Visual hierarchy, Gestalt, heuristics
| Term | Definition | Source |
|---|---|---|
| **proximity** | close = same group | [NN/g](https://www.nngroup.com/articles/gestalt-proximity/) |
| **similarity** | shared traits = same group | [NN/g](https://www.nngroup.com/videos/similarity-gestalt-principle/) |
| **common region (enclosure)** | inside a boundary = group; overrides proximity/similarity | [NN/g](https://www.nngroup.com/articles/common-region/) |
| closure, figure/ground, common fate, continuity | | [NN/g intro](https://www.nngroup.com/videos/the-gestalt-principles-intro/) |
| **visual-design principles** scale, hierarchy, balance, contrast, Gestalt | | [NN/g](https://www.nngroup.com/articles/principles-visual-design/) |
| **Nielsen's 10 heuristics** (1994) | | [NN/g](https://www.nngroup.com/articles/ten-usability-heuristics/) |
| **progressive disclosure** (1995) | few important options first | [NN/g](https://www.nngroup.com/articles/progressive-disclosure/) |
| **Fitts's law** | | [NN/g](https://www.nngroup.com/articles/fitts-law/) |
| **affordance / signifier** (Gibson 1977 / Norman 1988) | | [jnd.org](https://jnd.org/affordances-and-design/) |
| **44×44pt minimum target** | Apple HIG | [HIG layout](https://developers.apple.com/design/human-interface-guidelines/foundations/layout/) |

### 6. Game UI classification
| Term | Definition | Source |
|---|---|---|
| **diegetic / non-diegetic / spatial / meta** | axes fiction × geometry: diegetic (both), non-diegetic (neither; classic HUD), spatial (in 3D not fiction), meta (in fiction, 2D) | Fagerholt & Lorentzon 2009, *Beyond the HUD*: [PDF](http://publications.lib.chalmers.se/records/fulltext/111921.pdf), [RG](https://www.researchgate.net/publication/277202228_Beyond_the_HUD_-_User_Interfaces_for_Increased_Player_Immersion_in_FPS_Games) |
| **persistent vs contextual HUD** | persistent = always tracked; contextual = appears when relevant | practitioner: [Game Developer](https://www.gamedeveloper.com/design/long-dark-survival-game-hud-ui), [StraySpark](https://www.strayspark.studio/blog/game-ui-ux-design-principles) |
| **Game UI Database** screen taxonomy | Gameplay & HUD, Inventory, Skill Tree, Settings (…), Loading, Map, Dialogue; tags for HUD elements, patterns, layout, colour | [gameuidatabase.com](https://www.gameuidatabase.com/) |
| **XAG** | numbered guidelines; 101 text, 102 contrast (names HUD elements), 112 UI navigation | [XAG 102](https://learn.microsoft.com/en-us/xbox/accessibility/xbox-accessibility-guidelines/102), [XAG 112](https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/112) |
| **Game Accessibility Guidelines** | resizable text, movable/resizable HUD | [GAG](https://gameaccessibilityguidelines.com/basic/), [Includification](https://accessible.games/wp-content/uploads/2018/11/AbleGamers_Includification.pdf) |

No standards body classifies game UI elements by PURPOSE (status / navigation / feedback / authoring). Nearest: Material 3's component categories (§7).

### 7. Surface / component taxonomies
| System | Categories / names | Source |
|---|---|---|
| **Material 3 categories by purpose**: Action · Containment · Communication · Navigation · Selection · Text input | | [m3 components](https://m3.material.io/components), [Android](https://developer.android.com/design/ui/mobile/guides/components/material-overview) |
| **M3 surfaces** `surface`, dim/bright, `surface container lowest/low/default/high/highest`; elevation 0–5 as tonal tint | | [elevation](https://m3.material.io/styles/elevation), [Compose 1.2](https://m3.material.io/blog/material-3-compose-1-2) |
| **VS Code**: Activity Bar → Sidebar (View Containers → Views: Tree/Welcome/Webview) · Panel · Editor area · Status Bar · notifications, quick picks | | [overview](https://code.visualstudio.com/api/ux-guidelines/overview), [views](https://code.visualstudio.com/api/ux-guidelines/views), [sidebars](https://code.visualstudio.com/api/ux-guidelines/sidebars) |
| **Blender**: Window → Screen → Areas → Editors → Regions (Header, Main, Toolbar, Sidebar, Adjust Last Operation) → Tabs → Panels → Controls | | [regions](https://docs.blender.org/manual/en/latest/interface/window_system/regions.html) |
| **Unity**: Inspector, Hierarchy, Project, Scene/Game; PropertyField / property drawer | | [custom inspector](https://docs.unity3d.com/Manual/UIE-HowTo-CreateCustomInspector.html), [drawers](https://docs.unity3d.com/Manual/editor-PropertyDrawers.html) |
| **Unreal UMG**: Canvas Panel, Anchors, Menu Anchor; Slate | | [anchors](https://dev.epicgames.com/documentation/en-us/unreal-engine/umg-anchors-in-unreal-engine-ui) |
| generic: panel, dialog (modal), sheet, card, toolbar, tray/dock, inspector / property panel, tree view, list, data table | Apple HIG also: sidebars, toolbars, inspectors, panels, sheets, popovers [unverified-here] | HIG |

### 8. Layout vocabulary
| Term | Definition | Source |
|---|---|---|
| **Constraints** (Figma) | how a layer responds when the PARENT resizes: pin / centre / scale | [Figma](https://help.figma.com/hc/en-us/articles/360039957734-Apply-constraints-to-define-how-layers-resize) |
| **Auto layout** (Figma) | flow container: direction, gap, padding, hug/fill | same |
| **Anchors / pivot / anchoredPosition** (Unity RectTransform) | anchor min/max normalised in parent; pivot = origin | [Unity](https://docs.unity3d.com/Packages/com.unity.ugui@1.0/manual/UIBasicLayout.html) |
| **Anchors** (UMG) | normalised (0,0)-(1,1) on Canvas Panel | [UMG](https://dev.epicgames.com/documentation/en-us/unreal-engine/umg-anchors-in-unreal-engine-ui) |
| **Safe area** · **layout margins / guides** | | [HIG layout](https://developers.apple.com/design/human-interface-guidelines/foundations/layout/) |
| **Breakpoints / window size classes** | M3 compact <600dp · medium 600–840 · expanded ≥840 | [M3](https://m3.material.io/foundations/layout/applying-layout/window-size-classes) |
| **Stack / flow / grid layouts** | SwiftUI stacks; CSS flex/grid; WPF StackPanel/Grid/DockPanel [unverified-here] | — |

### 9. The agent's proposed mapping (kept as filed; the cut above is the architect's reading of it)

**Measurements → terms**

| Project bucket | Industry term | Status |
|---|---|---|
| edge inset | **Inset** (Curtis); padding (CSS/Cloudscape); Material margin if the container is the screen | established; square/squish/stretch sub-typing established |
| sibling gap (vertical) | **Stack** (Curtis); Figma gap | established |
| sibling gap (horizontal) | **Inline** (Curtis) | established |
| column gap | **gutter** | established |
| control height | **size**; RESULTS from type + padding + border (Curtis); Material density level | established; record height per density step |
| font per role | **type role** — M3 display/headline/title/body/label; Carbon heading/body/label/helper-text/code; productive set closer for dense UI | established |
| backdrop | **surface / surface container** (M3), `color.background` (Atlassian), elevation if depth | surface established; ranking WoW backdrop alphas on M3 tiers = STRETCH (tiers are by tone) |
| border | DTCG border composite + radius | established |
| tier of a measurement | DTCG group; global/alias/component or reference/system/component | established; raw pixels = reference, bucket names = system, per-addon = component |
| density mode of a whole addon | compact / default (comfortable) | established |

**Source-addon classification**

| Project class | Proposed terms | Status |
|---|---|---|
| information-dense monitoring | non-diegetic HUD, persistent; compact density / data-rich; high data-ink ratio; Carbon productive; M3 Communication | non-diegetic established; persistent practitioner; Material density numerically on WoW frames = STRETCH |
| display / wayfinding | M3 Navigation (maps, trackers); Containment (tooltips); contextual HUD; Fagerholt spatial for in-world markers, non-diegetic for minimap; visibility of system status; Fitts for action bars | Fagerholt established; wayfinding under M3 Navigation = STRETCH |
| presentation / cosmetic | theme (M3: remapping reference→system); surface/elevation; Tufte non-data-ink (neutral) | theme established; non-data-ink label = STRETCH |
| editing / authoring / configuration | inspector / property panel, tree view, views/panels/sidebar (VS Code), regions/panels (Blender); M3 Selection + Text input; progressive disclosure; Game UI DB Settings | components established; no standards-body class "authoring" — STRETCH |

Notes: no single source gives a purpose taxonomy of status / navigation / feedback / editing; the most citable closed list is Material 3's six categories. Material's own pages are JS-rendered and were not fetched; M3 names come from material-web.dev, developer.android.com, the M3 blog and MUI docs, consistent with each other.
