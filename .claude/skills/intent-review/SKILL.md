---
name: intent-review
description: Review a document against the code it names — what agrees, what does not, and who decides each disagreement. Use when asked whether a doc still matches the code, when verifying or stamping a governing doc, when a doc and the code seem to contradict each other, before building against an acceptance brief, when auditing docs for staleness, or when told to reconcile docs with implementation.
---

# Code and intent review — what agrees, what does not, who decides

**It is bounded where "tell me what the code does" is not:** every line you check is a claim
somebody already wrote down, so the question has an edge. ⟶ And it is **the readable half of the
smoke detectors** — the half that can say *a criterion is wrong*, which no detector can say about
itself. A mutation with a stale criterion bites flawlessly on the wrong thing.

## 1 · The output is three numbers per document, then a sort

    document              claims checked    agreed    disagreed

**Print the agreements as a count.** A review that reports only disagreement cannot tell *"the basis
is drifted"* from *"we only looked at the drifted parts."* ⚠ And say plainly whether the denominator
is measured or indicative — if "a claim" is not defined identically across reads, it is indicative.

## 2 · ★★★ Sort every disagreement by WHO DECIDES. This is the whole product.

    FACT       the doc describes a STATE of the build      ⟶ THE CODE DECIDES, always. Nothing
               ("not built", "no caller", "16 functions")     to rule; the doc is behind.
    INTENT     the doc states a REQUIREMENT the code       ⟶ THE DOC DECIDES — it is the
               does not meet                                  requirement and the code owes it.
                                                             ⚠ Whether it is still WANTED is the
                                                             Designer's call, not the reviewer's.
    RULED      both assert, and a later dated ruling       ⟶ THE RULING DECIDES. Not a conflict —
               already settled it                            a doc that never heard. Carry the
                                                             pointer, change nothing.
    YOURS      the doc and a PASSING TEST specify          ⟶ NOBODY IN THE REVIEW DECIDES. A spec
               different behaviour                           and a test that disagree is an
                                                             unresolved design question wearing a
                                                             doc bug's costume. Escalate it.
    CITATION   the pointer no longer resolves to the       ⟶ MECHANICAL. No arbiter, no judgement.
               thing it names                                Re-aim it.

**An unsorted list of divergences is a backlog. A sorted one says who may act before anyone opens
the file.**

## 3 · ⚠⚠ The dangerous repair, and it is the one that looks like progress

**Updating a doc to match the code always reads as tidy reconciliation.** If the disagreement was
INTENT, that edit **deletes the only record that the code is wrong** — it retires a requirement
instead of meeting it.

⟶ **Decide the class by READING, never by assuming.** One question does it:

> **Does this line describe what IS, or what SHOULD BE?**

They look identical on the page and have opposite arbiters.

★ **Who may repair:** FACT and CITATION, a seat may fix alone. **INTENT and YOURS must not be
repaired by the seat that found them** — resolving a requirement against evidence you gathered
yourself is the fork this project keeps away from.

## 4 · A large part of FACT is not stale — it is FINISHED

A row reading *"THIS ROW IS A BUILD ITEM"* about something that shipped and is asserted in a smoke
is **a closed item nobody closed**. ⟶ Ask whether the brief should be **retired** rather than
repaired. It is a ruling, not a reading — but raising it can clear most of the FACT class without
anyone editing a line.

## 5 · Using sub-agents — they read, they never decide

Agents make this affordable at scale. They do not make the finding trustworthy on their own.

- **Form your own read first on one calibration document**, or read one alongside an agent. Two
  agents agreeing share a prior; an agent plus a human read is the informative case.
- **Spot-check a chosen-to-be-refutable sample at source before resting anything on a report** —
  favour the absence claims, which is where a reader most often overreaches. Record how many you
  checked, and mark verified findings apart from reported ones. **Evidence from a sample is never
  proof across the whole list.**
- Never write a VERIFIED stamp on an agent's reading. A stamp is a claim that a person did the read.

**The brief that worked — reuse it rather than re-deriving it:**

    Read <doc> WHOLE against the code it names, and report DIVERGENCES.
    ⚠ Follow `.py` names as seriously as `.lua` — this project's docs govern Python desk tools too.
    Read for the ASSERT, never the presence of a name: a function CALLED in a smoke is not evidence
    a criterion is graded.
    READ ONLY. Report FACTS with evidence — never verdicts, never fixes, never design opinions.
    Every divergence carries: doc line · the claim · code file:line · what the code actually does.
    An absence claim must state HOW you searched — an absence is a claim about everywhere you
    did not look.
    If unsure, say UNSURE. A false divergence costs more than a missed one; a human will act on it.
    Return: A. divergences (cap them, ordered by consequence) · B. unsure · C. not checked and why
    · D. how many distinct claims about code you checked.

## 6 · Print the ceiling

Every review states what it did **not** reach: docs not read · docs that name no code and so cannot
be reviewed this way · whether any smoke or checker was actually RUN (*"a guard does not exist"*
means no code implements it, never that it was run and failed) · and how many findings were
spot-checked versus taken on report.

★ **A review that produces no stamp has not failed.** A document that reconciles yields a stamp and
nothing else; one that does not yields findings. **The stamp is what you get when there is nothing
to say.**
