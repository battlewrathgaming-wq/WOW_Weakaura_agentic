# 2 · Slices — logical display operators (WHAT)

**Role.** The vocabulary of *what to display*. A slice is a **logical operator** —
"dim when unaffordable", "flash on proc", "show when available". It is a
**cross-lane cut**: a trigger, a condition, and a subregion that live in
different lanes and point at each other by index. The atomic unit of authoring,
and the part that is *always* the real work.

**In:** hand-authored intent — **defined by reference auras / pattern templates,
not inferred.** A hand-built aura *is* the authoritative definition of a slice.
**Out:** a slice definition = { which blocks, in which lanes, paired how } + the
fills it needs (spell ID, thresholds, colours).

**Owned by:** the human author. The machine never reasons a slice into existence;
it only distributes and pairs an already-defined one.

**Status:** NOT YET FORMALIZED. The join *mechanics* are spec'd
(`../ASSEMBLER.md`); the slice *vocabulary* is the next real work. BOM mining
(`../BLOCK_SYSTEM.md`) is a discovery aid for candidate slices, not their authority.
