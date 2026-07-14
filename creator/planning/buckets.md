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

**These seven are the meaning, not the display.** They're the *pre-filter* — "why you press it." The **visual primitives**
(the actual shapes on screen) are a *smaller* set, because several buckets wear the same shape (all the kept-up things → a
duration bar; everything that folds into cooldown → an icon; stacks → a count). The buckets aren't the picture — they're what
lets us **decide how to populate** each shape (the trigger, the unit, the grouping). Classify by meaning first, pour into the
shapes second.

_How far the shapes actually collapse (does the cooldown icon = the payoff icon? proc = stack?) is a **build-time** question —
you make them and see if they truly perform the same, not decide it in the abstract. The meaning (the buckets) is locked and
held across every role; the picture is leanings on top, settled at the bench. A **pair** (show the spell + show its reaction)
keeps recurring and may be the base shape._

## The reduction
Seven meanings → **three mechanisms** → **four products**. The unit=target cut does most of the collapsing — it applies to
both sides (the healer's ask is the same flatten: "does *this* one have my HoT?").

Mechanisms (= the corpus's own authorship split): **aura2 window** (all kept-up things + stacks) · **cooldown progress**
(all ready-checks) · **usability/threshold** (the payoff gate — bolted on as trigger 2/conditions, never standalone).

| product | buckets folded in | mechanism · ship form |
|---|---|---|
| **Target tracker** | DoT + bane (+ HoT friendly-side) | aura2 `unit=target` ownOnly · dynamic icon group |
| **Ready tracker** | cooldown · opportunity · interrupt · external | cooldown progress · static icons, desat+recolor |
| **Self tracker** | boon · proc-on-consumer · payoff pair · stack counter | aura2 `unit=player` + threshold · static + reactive |
| **Resource bars** | every power type | resolved — cheap, ship it |

The buckets survive as the **select recipes** deciding what populates each product. Plan: pull one spec's Target tracker →
contract it → one through the real machine → live confirm → then widen.

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
**Builder rule:** if its trigger chain references resource gain, it's a filler/builder in DoT clothing — skip it
(builders feed the gate, not the tracker). Verified on Necro/Death: catches exactly Crypt Swarm (tick → energize), no one else.

Aura side — sharpened: the mechanism is **one trigger: aura2, unit=target, ownOnly** — *"for my target, do they have it?"*
**Ship form (settled):** an **icon** per DoT of yours, in a **dynamic group**, on your **target enemy** — the group is for
multi-*DoT* (a 3-DoT spec shows up to 3 icons, growing/shrinking as they apply/drop), not multi-target.
This deliberately flattens multi-dot tracking:
what's lost is the *ambient prompt* ("a dot elsewhere is about to fall — tab now"); you tab on rhythm instead. Accepted:
- the actionable half survives (show-on-missing: you land on a hostile target, it says "dot absent");
- true multi-unit on a 3.3.5 client is the least-verified path (no nameplate unitIDs; WA "multi" mode = CLEU-based,
  backport support unconfirmed) — wrong stone to build the default on;
- if the ambient view ever earns a build, the data scopes it: duration≫CD DoTs cluster per spec → a **spec-targeted**
  enhancement later, not a global dependency.
unit=target also deletes the printed target name — it's *your* target.
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
Visual: **always shown, desaturate + recolor** as it counts down — you *check* it to stage your next move (anticipatory).

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

Visual: a **pair** —
1. the **ability it impacts**, shown *static* so you anticipate it, that **reacts when its gate opens** (anchored on the
   consumer, like a proc — but kept visible the whole time, not hidden-till-live).
2. a **stack counter** alongside, counting up, that **flips via trigger 2** to the payoff state once the threshold is met.

So the counter shows you closing on it; the ability itself lights the moment it's live. (This is why payoff and proc stay
visually distinct: a proc appears from nothing; a payoff is a static thing that wakes up.)

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

Visual: **show only when it's live** — you *react* to it appearing (not something you check). The opposite of the
cooldown's always-shown-and-styled: a cooldown you anticipate, a proc you react to.
(Open lean: might be better to **show the spell + show the proc** — the ability plus its reaction, like the payoff pair.
Test when building.)

## Healers / support — same shapes, pointed at allies
Mostly the same buckets: procs, cooldowns, boons to maintain — nothing new *in kind*.
- **HoT** — the ally mirror of the DoT, but spread across *shifting* targets, not held on one. Watch: **who I healed +
  what's still ticking** — a dynamic group that flattens the "how do I heal this person" decision.
- **Externals** — big single-target saves (a strong heal, a shield on an ally). Track like a **cooldown** (is it ready);
  *who* to use it on is situational — the game's raid frames own that (localize, don't replace).
- Health values + mana-efficient spell choice = the frames + player skill. Not our tracker.
- Some healers also damage — the **Cultist heals *by* dealing damage**, so their damage trackers double as healing.
