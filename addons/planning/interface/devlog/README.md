# Devlog — the messy middle

★★★ **Three registers, and this is the one in between.**

| | |
|---|---|
| **hopes** | what a surface should hold and do. The foot of each surface file |
| **devlog** | ⬅ **here.** Why it is, and how it got argued into a shape |
| **inventory** | what is, or what is declared for code to comply with. `interface/<surface>.md` |

> *"I feel it's partly your 'Why it is'. And I think it can be the middle ground of hopes and
> implementation. The messy space that things get developed and comment logged into."*

★★ **A folder per surface, a file per feature.**

    devlog/curation/dead-space.md
    devlog/promotion/field-vs-art.md

> *"It gives a home to the moving parts. And we can dump reasoning into a feature there before it
> gets built. And then annotate what fell out of it."*

---

## What a feature file holds

    the question    what we were trying to do, before anything was built
    the reasoning   dumped. Messy, quoted, out of order, including the wrong turns
    what fell out   annotated AFTER. What shipped, what moved to the factual file,
                    what died on the way

★★★ **The wrong turns are the point.** A settled fact tells you what to do; the argument tells you
why the other options were rejected — which is what stops them being re-proposed in six weeks. The
factual file cannot carry that without stopping being factual.

## ⚠ What this is NOT

- **Not an authority.** When something settles it moves to `interface/<surface>.md`. The devlog
  keeps the *reasoning*, never the ruling — and if the two disagree, the factual file wins.
- **Not a task list.** Outstanding jobs are ☐ marks in the factual file, collected by
  `emit_outstanding.py`.
- **Not a diary.** A feature, not a day. If nothing was argued, nothing is written.

## ⚠ And it is only created where there is content

Four surfaces have real argument behind them. **Map** and **Map controls** do not — nothing has
been developed about them yet, only described. ★ An empty devlog folder is parked structure, which
is the thing `memory/half-formed-code-invites-building-on-it.md` exists to stop.

## Provenance

★ Much of this was already written — in **commit messages**. The field-vs-art argument, why regions
beat lines for a cut, why the driver was parked: all in `git log`, where you cannot read it as a
subject. Each entry cites the commits it came from, so the devlog is a container rather than a
retelling.
