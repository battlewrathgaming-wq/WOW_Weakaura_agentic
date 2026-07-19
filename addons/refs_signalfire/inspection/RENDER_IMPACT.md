# Render-impact map — every SignalFire site that touches the frame or can hang it

_2026-07-20, SignalFire 1.5.1 tree. Backs the Discord commitment: "trace where the source code
impacts the renderer or is likely to make WoW hang." Counts are installs/sites found by
mechanical sweep; representative file:line per class; verify against the current tree._

## The aggregate story (the headline)

The render path carries the addon's WHOLE GENERATIONAL HISTORY. Filters and hooks from multiple
eras are ALL still installed — a single chat message can pass through **up to five filter
generations per chat frame** (PublicInline → 567_FilterAddonSpam → 5610_HideAddonBroadcast →
577_RoleCombo → FastChatLinks), each with its own parse/decision, multiplied by however many
chat frames/tabs the user runs. The fossil-record naming (FINDINGS.md) isn't cosmetic — the
fossils are LIVE on the hot path.

## A. Chat message filters — 22 installs (render path, × per chat frame)

`ChatFrame_AddMessageEventFilter` on CHANNEL/SAY/YELL across five+ generations:
`BronzeLFG.lua:7443-7445` (PublicInline) · `:8687-8689` (567 spam filter) · `:9430+`
(5610 hide-broadcast) · SF577 role-combo · SignalFireChat FastChatLinks (:1392-1394, the
traced inline-parse one — see PAIN_TRACE.md). Filters run once per registered chat frame per
message; returning modified text forces re-layout. **This class is the measured 4.6 ms/s.**

## B. AddMessage REPLACEMENT — 12 sites (every rendered line, all sources)

Not hooksecurefunc — direct method replacement (`frame.AddMessage = wrapper`):
`BronzeLFG.lua:14401/14409` (_sfPublicWhoAddMessageWrapper) · `SignalFireChat.lua:1300/1306/
1674/1681` (_sffclAddMessageHook, _sfcpBaseAddMessage save/restore pairs) ·
`SignalFireNetwork.lua:2911` ("hook DEFAULT_CHAT_FRAME:AddMessage globally") ·
`SignalFireUI.lua:1735`. Every line ANY addon or the client prints pays these wrappers; layered
save/restore pairs across generations risk wrapping wrappers after profile/UI reloads.

## C. OnUpdate handlers — 47 sites (every frame, unconditionally while shown)

Forty-seven per-frame scripts (BronzeLFG.lua :1778 :4757 :5434 :7328 :7528 :7705 :7856 :8127 …).
Each is per-frame cost whether or not anything changed; several look like hand-rolled timers
(accumulator pattern) predating any C_Timer use. Candidates for one shared budgeted ticker.

## D. /who machinery — 22 sites (hang-class, not fps-class)

`SetWhoToUI(1)/(0)` mode toggling + `SendWho('n-"..name..')` per-name queries
(`BronzeLFG.lua:13743-14182`). Risks: the server's /who throttle silently queueing, UI-mode
races with the player's own /who, and burst sequences of per-name queries — this is the class
that produces FREEZES/hangs rather than steady fps loss, and it's invisible to fps sampling.

## E/F. Timers & roster

No C_Timer cadence sites surfaced in the sweep — the OnUpdate accumulators above ARE the timer
layer (pre-C_Timer idiom). `GuildRoster()` requests ride the /who-adjacent paths.

## The fix shape (same as PAIN_TRACE, now with scope)

One capture layer (single event handler, O(1) enqueue) + one budgeted worker + board-rendered
results would replace classes A (all five generations), most of B, and most of C outright —
not an optimization pass but a RETIREMENT pass: the generations are the cost. D needs its own
queue with throttle-aware pacing.

## Measured context (the four-arm perf curves, landing/records 20260719-20)

SF absent 0.0 ms/s → parsing on 4.6 ms/s (bursts 22) → parser off 1.3 ms/s (bursts 5) →
parser off + Chatter 2.24 ms/s (bursts 15.5; Chatter's frame topology multiplies the
still-installed filter/hook classes — the measured form of the author's own Chatter suspicion).
