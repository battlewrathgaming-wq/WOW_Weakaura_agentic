# Curation · the dead space I made

_Commits: `e90bbcc` §107 · `d206153` §109_

## The question

> *"Looks better. Long term dead-space to trim. And items to justify or handle properly. But the
> burden is eased."*

Where is the dead space, and what is it?

## The reasoning

He asked for one thing:

> *"I'd make the pane for Curation to match promotion. So when their stacked their claim the same
> vertical lines. And then height is specific to each on their need."*

Straightforward — width shared so a stacked pair reads as one edge, height each its own. Done in
§107: 280 → 320, and the comment box and hint widened with it.

⚠⚠ **But widening a pane is not widening what is in it.** Every other x and width inside stayed
where it was, laid out for 280:

    the time bar        244 in a 284 column          40 short
    the route dropdown  art ends at 252, column 302  50 short
    the tick rows, the step pad, the buttons         all at their 280 positions

★★★ **So the dead space he named two turns earlier is dead space I made one turn earlier.** It was
not there before §107. Seeding the surface file is what surfaced it — the numbers had to sit
together before the gap was visible.

### And the seeding caught a second thing

The inventory said Curation was **240 × 330**. `editor.lua` said **280 × 366**. ⚠ I had typed a
guess into the file whose entire job is being the thing that cannot be guessed at, and the
PaneBoard viewport list had inherited the same wrong pair.

★ Twice in two commits the hand-seeded authority carried something nobody had read. **The seed was
necessary; trusting it was not.**

### The thing that was not this pane at all

He reported something sitting across the *Controls / Curate* labels. I assumed a Curation widget.

⚠ It is the **Map's** two buttons — `map.lua:2213` and `:2219` — reading through this pane's
backdrop. Curation is strata `DIALOG` + toplevel; the Map is `HIGH`. So Curation draws over it, and
wherever its backdrop is not opaque, the map's own buttons show through.

★★ **No per-pane check can ever see that.** Every geometry check asks whether *one* pane is
internally consistent. Nothing asks whether two panes collide on screen.

## What fell out

- **320 wide, 366 tall** — shared edge with Promotion, own height. → `interface/curation.md`
- ☐ **Re-lay every x and width for 320.** Recorded as outstanding rather than fixed in passing:
  it is a design pass, not a find-and-replace.
- **The inventory learned to record where a number came from**, after carrying two it had not read.
- **A gap in the checking, named:** cross-pane collision has no instrument. Written into the
  factual file's `relates` rather than left as a surprise.

## Still open

⚠ The dead space is **not trimmed**. It is measured and named, which is a different thing, and it
stays ☐ until the re-lay happens.
