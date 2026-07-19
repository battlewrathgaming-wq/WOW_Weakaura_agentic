# Pain trace — the CoA chat-link FPS collapse (their live issue, our source read)

_2026-07-19. Symptoms from the author's Discord (users at "-1 FPS", author cannot reproduce,
"parse public groups from chat" off = fixed, author: "it's something with CoA and chat links")._

## The mechanism (SignalFireChat.lua ~1320-1407, the "FastChatLinks" filter)

`ChatFrame_AddMessageEventFilter` is installed on **CHAT_MSG_CHANNEL / SAY / YELL** — chat-frame
message filters run **on the render path, once per chat frame** that would display each message.
Inside the filter, per message:

1. cache lookup (`author..raw` key, **1-second TTL only**);
2. `sffcl_upsert` — a row parse of the message;
3. **`B:AddPublicGroup(author, raw, channelName)` — the heavyweight CORE parser, called INLINE**
   (line 1361) whenever the queue flag is clear — despite the adjacent comment saying the
   queue-fix exists precisely to keep the core parser OFF the chat-render path;
4. `sffcl_link_for` — builds a REPLACEMENT message with an injected addon hyperlink, returned as
   the new text (`out ~= raw` → the client re-lays-out the line with the injected link);
5. map pruning, then the same again for the next frame displaying the message.

## Why "-1 FPS" for some, nothing for the author

The cost multiplies along axes the author's setup evidently sits low on:
**channel traffic volume** (`global` on a busy evening) × **number of chat frames/tabs
registered for the channel** (filters run per frame) × **whatever CoA's chat pipeline pays to
render injected/nonstandard links** (the author's own diagnosis names the fork's chat-link
handling; this fork's chat stack is customized — Chatter interactions were also suspected in
the thread). A quiet-channel, single-tab author literally cannot reproduce a busy-channel,
multi-tab user's collapse. The 1s cache is no defense against unique lines on a busy channel.

## Fix directions their own code already implies

- The deferral design EXISTS ("SignalFireChatQueueFix keeps the core parser deferred off the
  chat-render path") — the inline `AddPublicGroup` call in the fast filter defeats it. Defer
  unconditionally; the filter should only ever read, never parse.
- Never return a modified message from the filter by default (links-off default — which the
  author already announced) — display decoration belongs in a lazy path, not message rewrite.
- Cache window ≫ 1s + a per-message (not per-frame) dedupe so N chat frames cost one parse.

## Our-side follow-up (pass 2 candidate)

Read the FORK's chat/ItemRef link handling in the patch-B extraction to name what CoA actually
pays per injected link — that would turn "something with CoA and chat links" into a file:line
answer, which is relayable upstream to both the author AND Ascension.
