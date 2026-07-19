# SignalFire: the CoA chat-link FPS collapse — a source trace + a fix architecture

_A read of SignalFire 1.5.1's source (github.com/joshxor/SignalFire) against the reported
symptoms (users at "-1 FPS" on Conquest of Azeroth; unreproducible on the author's setup;
"parse public groups from chat" off = fixed). Offered in the collaboration spirit — trace at
the bottom, verify everything against your own tree._

## The symptom, mechanically

The FastChatLinks path installs `ChatFrame_AddMessageEventFilter` on
`CHAT_MSG_CHANNEL/SAY/YELL`. Two properties of message filters drive everything:

1. **Filters run on the chat RENDER path, once per chat frame** registered for the event — a
   user with several tabs showing General/Trade/global runs the filter several times per message.
2. **Returning a modified message forces re-layout** of the line — and the modified message here
   carries an injected addon hyperlink, which prices in whatever CoA's customized chat/link
   pipeline charges per nonstandard link render.

Inside the filter, per message per frame: a 1-second-TTL cache check, a row upsert (parse), and
— the heavy one — **`B:AddPublicGroup(author, raw, channelName)` called inline** whenever the
queue flag is clear, despite the adjacent comment saying the ChatQueueFix exists precisely to
keep the core parser OFF the chat-render path. The deferral design exists; the inline call
defeats it.

## Why you can't reproduce it

The cost is a product of three axes your setup evidently sits low on:
**channel traffic** (a busy `global` evening) × **chat frames/tabs registered** (filter runs per
frame) × **CoA's per-link render cost**. A quiet-channel, single-tab environment can be orders
of magnitude cheaper than a busy-channel, multi-tab one — same code, same version. The 1s cache
is no defense on a busy channel where every line is unique. (This also explains users too frozen
to reach the options panel: the collapse scales with the very traffic they can't escape.)

## The fix architecture: capture on the event, parse on a budget, render from your own board

The pipeline inversion that removes the problem class entirely:

1. **Capture** — a single hidden frame registered for `CHAT_MSG_CHANNEL/SAY/YELL` (an event
   handler fires ONCE per message, not per chat frame). The handler does O(1) work only:
   `queue[#queue+1] = {author, msg, channel, GetTime()}`. No parsing, no rewriting, no cache.
2. **Parse on a budget** — a worker (`C_Timer` tick or OnUpdate) drains N messages or M
   milliseconds per frame, running the FULL core parser quality off the render path. Bursty
   traffic amortizes across frames instead of spiking one.
3. **Render from the board** — parsed rows land where they already land (Public Groups / Guild
   Browser / SV cache), and the addon's own UI is the read surface. **Chat text is never
   rewritten.** The clickable-link decoration becomes an optional cosmetic: if kept, decorate
   from the ALREADY-parsed row (a string lookup, no parse in the filter), per-message deduped —
   or leave links off by default, as you already announced, with zero functional loss.

Your ChatQueueFix is already half of this design — the fix is finishing your own architecture:
the filter/handler only ever reads; everything else is deferred.

## Two cheap hardening notes

- Dedupe per MESSAGE (author+msg+channel key), not per filter invocation, so multi-tab users
  cost one parse regardless of frame count.
- Widen any cache TTL well past 1s; on busy channels a 1s window is a miss generator.

---

## Source trace (SignalFire 1.5.1, `SignalFireChat.lua` ~1335–1407, abridged)

```lua
-- the filter body (runs per chat frame, per message, on the render path)
local raw = tostring(msgText or "")
local cacheKey = sffcl_key(author, raw)
local stamp = sffcl_now()
B._sffclFilterCache = B._sffclFilterCache or {}
local cached = B._sffclFilterCache[cacheKey]
if cached and (stamp - (cached.t or 0)) <= 1 then          -- 1-second TTL
  if cached.out and cached.out ~= raw then return false, cached.out, author, ... end
  return false, msgText, author, ...
end

local row = sffcl_upsert(B, author, raw, channelName)       -- parse #1 (row upsert)
-- Let SignalFireChatQueueFix/core BronzeLFG parser re-parse the same line later.
-- The fast parser is only for lightweight inline display; the core parser owns the
-- Public Groups/Guild Browser row quality.
if B.AddPublicGroup and not B._sfChatQueueProcessing then
  pcall(function() B:AddPublicGroup(author, raw, channelName) end)  -- parse #2: the CORE
end                                                          -- parser, INLINE on render —
                                                             -- the comment above says the
                                                             -- queue exists to prevent this
local out = sffcl_link_for(B, row, raw)                      -- build REWRITTEN message
B._sffclFilterCache[cacheKey] = {t=stamp, out=out}
sffcl_prune_fast_maps(B, stamp)
if out and out ~= raw then return false, out, author, ... end -- modified return → re-layout
return false, msgText, author, ...
```

```lua
-- installation (per chat frame semantics come from the filter API itself)
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", SignalFireFastChatLinks.Filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY",     SignalFireFastChatLinks.Filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL",    SignalFireFastChatLinks.Filter)
```

_Trace context: read on 2026-07-19 against the 1.5.1 GitHub tree. Happy to share the CoA-side
half too — we maintain a mapped extraction of this client's own FrameXML/chat stack, and can
likely name the exact fork-side cost your "CoA and chat links" hunch points at._
