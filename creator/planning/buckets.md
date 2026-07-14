# buckets — plain language

_Talking these out nice and slow. One line each: what the thing is, and the one thing you watch while playing. No machinery — we write the proper contracts on top of this later._

## At a glance
Everything you watch lands in one of these — and it held across DPS, healers, and tanks:

- **DoT** — *is it still up?* (enemy, ticking damage)
- **Bane** — *is it up / have I applied it?* (enemy, a negative you keep on them — curse/vuln)
- **Boon** — *is it up?* (self/ally, a positive you keep up — buff/empower/armor; tank mitigation too)
- **HoT** — *who did I heal + what's still ticking?* (allies, shifting)
- **Cooldown** — *is it ready?* (your empowers & defensives — opportunity, externals, interrupts all fold in)
- **Payoff / availability** — *can I use it now?* (a stack/resource/state gate opens — procs ride here as events)
- **Stack counter** — *the build toward the threshold* (the class mechanic, plus local talent stacks)

Deliberately **not tracked:** control/CC (skill; the interrupt's just a cooldown) · the fillers & builders that feed the
gate · health values (raid frames) · mana (its own resource-bar pack). Running principle throughout: **localize, don't replace.**

---

## DoT
Cheap to cast, thrown on an enemy. A debuff that ticks damage over time.
You watch: **is it still up?** — refresh before it drops.

Two flavours, told apart by the debuff's duration vs its cooldown:
- **duration longer than the CD** → *multi-dot*: spread it around, keep several enemies ticking.
- **duration ≈ the CD** → *single-dot / burn*: keep it rolling on one target.
Both are DoTs.

It might also carry an amp/vulnerability, but that's a rider — you press it for the tick, not the amp.
So when something's both, the DoT wins the "why."

Aura side: both flavours live in the **same DoT tracker** — a dynamic group, a bar per active DoT.
We're not replacing the game's debuff frames or the dedicated DoT addons; we just **localize** the
info — bring it to where you're already looking. _(This "localize, don't replace" line probably holds for most buckets.)_

## Bane — negative, kept up on the enemy
Short CD, long duration, sometimes one-target-only. A negative effect you keep on the enemy — the reminder is
*"you could cast this, and you haven't."* Watch: **is it up / have I applied it.** Curses, vulnerabilities live here.
(The DoT is the damage cousin of this — same "keep it up," different why.)

## Boon — positive, kept up on you / allies (the mirror of the bane)
Same shape, friendly side. The class buff that lasts ~30 min; healers/support get more opportunistic ones.
Buffs, empowerments, armor increases. Tank active-mitigation buffs live here too — a boon on yourself.

## Opportunity — pop it in the window
Short duration, long CD. Boss executes, PvP, pressing for the win. You *don't* keep it up — you pop it.
Watch: **is it ready** (so it tracks like a cooldown, not like a maintained thing). Can have its own lane.

> Method note (Battlewrath): **first don't split.** Treat "a kept-up thing" as one (bane + boon together), get it working,
> *then* refine — bane/boon → curse/vuln, buff/empowerment/armor. Keeps the load down.

## Cooldown — "is it ready?"
Your side: **empowerments or defensives** — they lift performance or keep you alive. Generally instant cast.
Watch: **is it ready** — a **static** icon showing its cooldown sweep, bright/visible when available.
(One fixed icon each — not a dynamic group like the DoTs.)
Come in CD brackets: short 30s–1min, then 90s, 5min.
Some get **reset by procs** — the native cooldown reflects that on its own, so the icon just updates; we read it.
Opportunity folds in here — it's a cooldown you pop in the window.

## Control (CC) — mostly NOT tracked
Stuns, slows, silences. Situational, governed by diminishing returns — this is instinct and class mastery, not
something you put on a tracker. We leave it.
- Exception: **interrupts ("kick")** — short CD, and you *do* want to know it's ready → it just rides in the **cooldown** bucket.
- Stun is borderline (similar need) but leave it for now.

## Payoff / availability — the rotation's gated moments
Rotation isn't watched at the fillers — it's watched at the **payoffs**: the moment something becomes usable.
Three gates, all the same shape:
- **Stacks** hit a threshold → an ability is empowered.
- **Class resource** reaches enough → an ability is available.
- **State change** unlocks other abilities (Blood Mage has one).

Common shape: a resource / stack / state is the goal, its **threshold is the gate**, and when it's met you **show the opportunity**.
Tracking the resource itself is useful — but the *most* useful thing is showing **availability**: "you can use this now."

Aura side: a **dynamic group** that shows abilities as they become usable. Users can pull individual ones out for
fixed/stacking placement if they prefer that. (Works out of the box, bends to taste.)
The fillers you press to *feed* the gate aren't tracked — they're the chaff that builds toward the payoff.

## Stack counters — showing the build, not just the open
Worth showing the **stack count itself** as it climbs toward its target — the high-target ones especially.
Same **dynamic group**, same principle: curate the useful ones first, users drop out what they don't care about.
(Mana / generic resource is transient — it lives in a separate **resource-bar pack**: cheap to just ship a bar for
*every* power type, all classes covered. Resolved — it's a pack, not a classification problem.)

Two scales:
- **Class mechanic** — the big signature stack (Reaper's souls, etc.). Mostly this.
- **Ability/talent-local** — a specific talent builds its *own* stack, then either a **spender** uses it, or it flips into a
  **buff** once the count is satisfied.

Same gate→payoff shape either way: the stack is the gate; the spender-available / buff-up is what you watch for.

## Procs — the random opportunities
Fall into the **same opportunity dynamic group**, but as an **event stream** — they come and go.
We don't track the proc in the abstract — we **anchor on the ability that consumes it and reflect the proc on it**:
the consuming spell lights up while the proc is live → "use this now." (Read the native buff — pull, not push.)
Two kinds:
- **Weather** — ambient procs that don't change what you press. Skip.
- **Behaviour drivers** — "have proc, use spell" relationships. These are the useful ones — the ones we track.

## Healers / support — same shapes, pointed at allies
Mostly the same buckets: procs, cooldowns, boons to maintain — nothing new *in kind*.
- **HoT** — the ally mirror of the DoT, but spread across *shifting* targets, not held on one. Watch: **who I healed +
  what's still ticking** — a dynamic group that flattens the "how do I heal this person" decision.
- **Externals** — big single-target saves (a strong heal, a shield on an ally). Track like a **cooldown** (is it ready);
  *who* to use it on is situational — the game's raid frames own that (localize, don't replace).
- Health values + mana-efficient spell choice = the frames + player skill. Not our tracker.
- Some healers also damage — the **Cultist heals *by* dealing damage**, so their damage trackers double as healing.
