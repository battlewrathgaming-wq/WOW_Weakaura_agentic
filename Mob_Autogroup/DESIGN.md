# Mob Autogroup - design summary

Flattened from a discussion pass (2026-07-09/10) scoping a lightweight
WotLK 3.3.5a addon to cut down on the classic "form a line and take turns"
friction around contested mob tags/spawns. Handed off here as a spec for
a fresh build session - nothing below has been implemented yet.

## The problem

Competing for a mob tag/kill/loot on a populated server leads to players
manually negotiating (whispering, forming lines, taking turns) instead of
just grouping up. The goal is to shortcut the "notice contention -> find
who else is there -> click invite" sequence with a single macro press.

## Core mechanism

No custom addon channel, no position broadcasting, no mob/GUID matching -
all three were considered and deliberately dropped in favor of the
simplest thing that works:

- **Transport: standard `/say`** (local chat), not a custom hidden
  channel. The game server already range-limits who receives a `/say` -
  that native range check IS the proximity filter, for free, with no
  custom coordinate math and no dependency on whether this server's build
  restricts custom addon channels/messages (an open question for a
  hidden-channel design; a non-issue for stock chat).
- **No mob/target matching.** Earlier drafts tried to match players
  fighting the *same* mob (by GUID). Dropped because the mob might
  already be dead by the time someone reacts - the real need is just
  "is anyone else nearby also looking to group," not "who's hitting this
  specific spawn."
- **Dual role, no separate initiator/responder.** Pressing the macro both
  broadcasts your own request AND arms your own listener. Whoever's
  nearby and also armed will hear you, and vice versa - there's no
  asymmetry to design around.

## The broadcast message

```
[!Mob Autogroup] Seeking party, request inv or invite me.
```

Sent via `/say` (optionally also `/yell` for a wider radius) when the
macro is pressed. Does double duty: the `[!Mob Autogroup]` tag is the
addon's own precise match anchor (easy exact-prefix check), and the rest
of the sentence is plain human-readable instruction for anyone standing
nearby who doesn't have the addon at all - they can just type `inv` or
`invite` back and still get picked up (see gesture matching below).

**Why this matters for adoption, added 2026-07-10 (Battlewrath):** most
coordination tools are only useful once enough other people have also
installed them - a cold-start problem that can kill an idea before it
gets any traction. This design sidesteps that entirely. The fallback path
for someone without the addon isn't "go install this too," it's just
"type what you'd normally type" (`inv`/`invite`), or literally read the
plain sentence and invite the broadcaster themselves. So it has real
utility for a single, lone adopter with zero other installs in the
world - Battlewrath's own framing: "Even if I just used it, I've fixed
one of my burdens." Worth remembering as the core reason this is worth
building even before any community consensus forms, not just a nice side
effect.

## Arming lifecycle

1. **Idle by default.** The addon does nothing and hooks no chat events
   until the macro is pressed - a deliberate performance/privacy choice:
   no rolling pre-arm chat buffer, no passive background listening.
2. **Press macro** -> sends the broadcast message and arms a **listen
   window** (default ~60s). **Exception, decided 2026-07-10:** if you're
   already in a group AND you are not the leader, the macro press is
   **ignored entirely** - no broadcast, no arm, full no-op. This resolves
   the earlier open question of whether a non-leader member should
   broadcast at all - they simply can't start a session in the first
   place, so it never comes up.
3. **While armed**, the addon reacts to two kinds of incoming `/say`
   (and `/yell`) messages:
   - The exact `[!Mob Autogroup]`-tagged phrase from another armed
     addon user.
   - A **loose gesture match** - the entire message (trimmed) is exactly
     `inv` or `invite`, nothing else. Must be a whole-message match, not
     a substring search - the broadcast sentence above literally contains
     the word "invite" inside it, so a substring check would make an
     armed listener falsely match its own or someone else's full
     broadcast as a casual gesture. This is what lets the tool work
     against people who've never heard of it.
   - For both kinds: extract the sender's name, skip it entirely if it's
     your own name (you will hear your own broadcast), and skip it if
     that name is already on this session's **do-not-retry list**
     (below) or already has a pending invite out this window.
   - **Leader-gate before ever queuing an invite.** Added 2026-07-10:
     whether you can actually invite depends on your own group status,
     and this should be checked BEFORE attempting anything, not
     discovered via yet another error to suppress:
     - **Not in a group at all** -> free to invite (this forms a brand
       new party with you as leader).
     - **In a group and you are the leader** -> free to invite (grows
       the existing party).
     - **In a group but NOT the leader** -> **do not fire an invite at
       all.** Only the party leader can invite in this era of WoW - a
       non-leader's `InviteUnit` call would just fail on a permission
       basis, which is a *third* distinct rejection case beyond
       already-grouped/declined, and cleaner to avoid entirely than to
       add another suppression pattern for it. Checked live via
       `UnitIsGroupLeader("player")` before a non-leader member ever
       attempts to queue anything - if you're a regular party member,
       leave inviting to whoever in your group actually IS the leader
       (and is presumably running their own armed session if this
       matters to them). This case should be rare in practice now that
       step 2's arm-time gate blocks a non-leader from ever arming in the
       first place - kept anyway as a defensive re-check, since group/
       leader status could in principle change during the ~60s window
       (leadership transferred, pulled into another group, etc.), and
       this check is cheap insurance against that.
   - Otherwise: **queue** an invite attempt for that name - see "invite
     cadence" below, invites are NOT fired the instant a match is found.
   - **No pre-check for whether the target is already grouped.** The
     invite is always just attempted; if the target is already in a
     different group, the game's own native invite validation rejects
     it - no need to independently track anyone's group membership on
     our side. This is a real simplification, not just a shortcut: it
     removes an entire category of state the addon would otherwise need
     to keep in sync with reality.
   - **Do-not-retry list** - a name is added to it, for the rest of this
     armed session, the moment either of these is detected:
     - **Target already in a group.** CONFIRMED LIVE 2026-07-10
       (Battlewrath): this surfaces as red floating `UIErrorsFrame` text,
       not a system chat line - suppress it by hooking/wrapping
       `UIErrorsFrame:AddMessage` and swallowing calls matching the known
       "already in a group" pattern, letting every other error through
       unchanged (do NOT blanket-disable the `UI_ERROR_MESSAGE` event
       itself - `UIErrorsFrame` also carries unrelated, still-useful
       messages that should keep showing normally).
     - **Target explicitly declines.** A different, delayed signal from
       the instant already-grouped reject above (the invite genuinely
       reached them and they chose not to accept) - exact detection
       string/event on this server build not yet confirmed, see "Open
       questions."
   - The do-not-retry list (and all other per-window bookkeeping - who's
     been queued/tried) is **entirely wiped when the armed session
     ends**, whatever the reason. Nothing about a stale, expired session
     should ever bleed into the next time you arm.
   - **Invite cadence: match human pacing, not machine pacing.** When
     several names queue up close together, dispatch `InviteUnit` calls
     roughly **0.5-1s apart, with some random jitter**, rather than
     firing them all in the same tick - both genuine fair-use toward the
     server and so the traffic pattern doesn't read as automated/bot
     activity. Implementation note: WotLK 3.3.5a has no `C_Timer` (that's
     a much later API) - this needs an `OnUpdate`-driven queue that
     tracks elapsed time via `GetTime()`, not a modern timer callback.
4. **Two ways an armed session ends in a group - handle both:**
   - **You get invited** (someone else's addon reacted to *your*
     broadcast and invited you first) and you accept -> you are now in a
     group -> **stand down and reset immediately**: disarm, wipe all
     session state (do-not-retry list, invite queue, timers). You never
     needed to send an invite yourself for this path.
   - **Else, you're the one sending invites** (you reacted to someone
     else's broadcast/gesture) -> keep working the queue until whichever
     comes first: **you're in a group at all** (not "full" - even a
     2-person group from your first accepted invite counts, don't wait
     for 5/5), the ~60s window timer expires, or you manually leave the
     group. Same full session-state wipe on disarm either way.
   - Either path: re-arming always requires pressing the macro again
     (deliberate, not automatic) - matches the "shortcut the manual step,
     don't fully automate consent" framing this whole design leans on.
   - **The earlier "optional courtesy stand-down ping" idea is now
     unnecessary** - resolved by the already-grouped auto-suppression
     above. A stray, late invite arriving after you've already matched
     elsewhere just bounces the same way any already-grouped target
     does, silently, with no separate signal needed.

## Explicit non-goals (already decided against, don't re-litigate without reason)

- No custom/hidden chat channel for the main broadcast.
- No mob-instance/GUID matching.
- No position/coordinate broadcasting or distance math.
- No passive/always-on listening - armed-only, for performance.
- No silent auto-accept of invites on the receiving end (unconfirmed
  whether that's even possible on this server - see open questions) -
  the standard native invite popup stays in the loop so consent isn't
  bypassed, only the "who do I invite" decision is automated.

## Open questions to verify live before/while building

- Whether `InviteUnit`/`AcceptGroup` behave as expected on this specific
  server build - see the footnote below on this server's history of
  diverging from stock Blizzard API for custom systems.
- Actual effective range of `/say` and `/yell` on this build (may not
  match vanilla 3.3.5a assumptions).
- Exact `CHAT_MSG_SAY`/`CHAT_MSG_YELL` event arg shape in this client
  build (which arg is the plain sender name, whether a realm suffix ever
  appears even on a single-realm server).
- ~~Where the "already in a group" invite rejection surfaces~~ -
  RESOLVED, see the arming lifecycle section: confirmed live as
  `UIErrorsFrame` red text.
- **Exact detection mechanism for an explicit decline** (distinct from
  the instant already-grouped reject above - this is the case where the
  invite genuinely reached the target and they chose "Decline"). Likely
  a delayed system chat message ("X declines your invitation to group,"
  by analogy with vanilla-era behavior) rather than the immediate
  `UIErrorsFrame` path, but not yet confirmed on this server build - test
  live before assuming the exact string/event.
- ~~Should a non-leader group member even broadcast at all?~~ - RESOLVED
  2026-07-10, see the arming lifecycle's step 2: arming is refused
  entirely (no broadcast, no listen) if you're in a group and not the
  leader.

---

## Footnotes: existing Lua/addon tooling already in this project

Nothing chat-hook/addon-messaging related exists yet anywhere in this
project - this would be new ground. What *does* already exist and is
directly relevant to building and testing it:

- **`Weak Auras/Tools/COA_DevDump/`** - a real, already-confirmed-loading
  custom addon on this exact server (not a hypothetical - proven live,
  see its own `README.md`). Use it as the structural template: `.toc`
  format (`## Interface: 30300` = WotLK 3.3.5a, `## SavedVariables:
  <Name>DB`), the deployment convention (this repo's copy is the source
  of truth; the actual game-install copy at
  `<GameInstall>/Interface/AddOns/<Name>/` is a wholesale-overwrite
  target, never hand-edited in place), and the slash-command registration
  pattern (`SLASH_X1 = "/cmd"` / `SlashCmdList["X"] = function(msg) ...
  end`) - the mob-autogroup macro/addon will need exactly this shape.
- **Live gotcha already learned the hard way on this server**, documented
  in that same addon's comments/README: this server's custom systems
  sometimes bypass the stock Blizzard API entirely (`GetNumTalentTabs()`
  returns 0/0 here - the custom talent UI doesn't route through it at
  all). Treat every stock API call this design leans on
  (`InviteUnit`, `AcceptGroup`, chat message events) as **needing a real
  live check on this server**, not an assumption carried over from
  vanilla 3.3.5a knowledge.
- **`Weak Auras/wa_lua_verify/`** - a real Lua 5.1.5 interpreter (matching
  WotLK's actual Lua version, not a newer bundled one), buildable via
  `bash wa_lua_verify/setup.sh` (pulls and compiles from lua.org - **not
  preinstalled in this sandbox and does not persist across sessions**,
  takes a few seconds to rebuild each time it's needed). Useful for
  syntax-checking and exercising pure-Lua logic in isolation (e.g. the
  phrase/gesture-matching function, the per-window dedup table) outside
  the game client. **Not a WoW API mock** - `harness.lua`'s own docstring
  is explicit that it only runs real WeakAuras source files that are pure
  data/logic, not anything touching `CreateFrame`, `InviteUnit`, or other
  real client calls. Anything that touches the actual game API still
  needs a genuine in-game test, this harness can't substitute for one.
- **FUSE mount-lag bug** (documented extensively in this project's
  `CLAUDE.md`/`Weak Auras/fuse_check.py`) - a real, recurring issue where
  this sandbox's `bash` view of a file goes stale after repeated edits,
  or (separately confirmed via `COA_DevDump`'s own README) after an
  *external* process rewrites a file, such as the game client flushing
  `SavedVariables` on `/reload`. **The `Read`/`Grep` tools reliably see
  current content; bash's `cat`/`wc`/`stat` can silently show stale
  data.** Worth remembering if this addon's own testing loop ends up
  round-tripping through SavedVariables or repeated file edits the way
  `COA_DevDump`'s did.
