# Reference model — the generic shape, and where we stand

Stripped of WoW/WA specifics, this is a **knowledge-grounded, human-in-the-loop
compiler**: turn a natural-language request into a *validated artifact for a
target runtime*, by composing a **component library**, grounded in **reference
data**, checked against the **target's own rules**. Same shape as: compilers
(source → IR → target), low-code builders (spec → app), infra-as-code (intent →
validated config), and RAG-grounded constrained codegen. Comparing ourselves to
that standard scaffold keeps us honest about what's real vs. missing.

| # | Generic component | What it is | Ours | Status |
|---|---|---|---|---|
| 1 | **Intake / DSL** | structured capture of intent | user story + intake format → docket | intake ✎ · docket format not formalized |
| 2 | **Component library** | the primitives you compose | Layer-0 blocks + **slices** | blocks ✔ · **slices ✎ — critical path** |
| 3 | **Reference data** | factual grounding (real values) | DBC + talent crawler | partial ✎ |
| 4 | **Resolver / front-end** | intent → IR (pick parts, bind data) | agent writes the docket | role defined · not built ✎ |
| 5 | **IR / plan** | the structured intermediate | class inventory (the docket) | not formalized ✎ |
| 6 | **Backend / codegen** | deterministic IR → artifact | assembler (distribute + pair) | reconstruction ✔ · generative spec'd ✎ |
| 7 | **Validator** | check artifact vs target rules | wa_validate + Modernize + the game | **strong ✔** |
| 8 | **Target runtime** | where it runs | WeakAuras, in-game | given |
| 9 | **Reference corpus** | examples to validate / mine | corpus + BOM mining | ✔ |
| 10 | **Human gate** | judgment checkpoint | docket review + final fitness | designed |
| 11 | **Graceful degradation** | partial output + explicit gaps | homework tier | designed |

**Where we're unusually strong — (7) the validator.** Most such services *approximate*
the target's validation and drift from it. We **harness the target's own engine**
(`Modernize`, headless) and the target **self-verifies loudly** on import. Running
the real validator instead of a reimplementation is rare, and it's the closest
thing we have to a moat.

**Where we're behind a mature version — (1/5) the DSL/IR and (4) the resolver.** The
docket format and the intent→IR front-end aren't built; we hand-reason them now.
Reference data (3) is partial. These are normal for an early build, not flaws.

**The critical path, generically:** finish the component library's *semantic* layer
(2 = **slices**), formalize the IR (5 = **docket**), build the backend's *generative*
half (6). Components 7–11 exist or are designed; 3 grows incrementally. Everything
points back at slices — the one place the reasoning is genuinely ours to author.

See the numbered component docs (`1_mask` … `6_wa_engine`) and [README](README.md).
