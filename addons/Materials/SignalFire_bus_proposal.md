# Proposal: a hidden-channel advert bus for SignalFire

_Feasibility probed live on Ascension "Conquest of Azeroth" (realm Vol'jin, WotLK 3.3.5a client
with retail backports), 2026-07-19. Everything marked **[proven]** ran in-game with receipts;
the rest is standard-era prior art._

## The idea

Separate boards over one shared transport: **group listings · guild profiles · crafter profiles.**
Advertisers post static, encoded profiles to a hidden chat channel; readers listen passively and
cache profiles into SavedVariables — a guilder's/crafter's board that populates in the background
while you play. Discovery only: contact hands off to whisper/mail.

## Transport — one hidden channel **[proven]**

`JoinChannelByName("...")`, never attached to a chat tab: invisible to the user, and a plain
frame registered for `CHAT_MSG_CHANNEL` receives everything, self-echo included (probed live:
join → listen unattached → send → receive). Notes:

- **One channel, typed messages** (`SF1|GRP|…`, `SF1|GLD|…`, `SF1|CRF|…`) — 3.3.5 caps a
  character at 10 channels total; don't spend three.
- **No channel history** → a joiner sees nothing until someone speaks. Prior art solves it:
  advertisers heartbeat on a long jittered interval + newcomers broadcast `SYNC?` answered with
  staggered random delays and answer-suppression (the Gatherer/Cartographer mesh-sync pattern;
  GuildAds did cross-guild boards this way in this era).
- **Throttle** all sends (ChatThrottleLib or equivalent) — chunked profiles = message bursts.
- Hidden ≠ private: anyone who learns the name can join. Design for it, don't rely on it.
- Sender identity is **server-attested** — `CHAT_MSG_CHANNEL` carries the real sender name.
  WHO posted is proven; WHAT they claim is attestation (see below).

## Payload — pre-flight encode (the WeakAuras pattern) **[proven]**

Flatten before send, cache flat, decode lazily on view: `serialize → deflate → print-safe encode`
(WeakAuras' transmission pipeline — the prior art for chat-safe dense payloads).

On this server it's **one native call each way, zero embedded libraries**:
`C_Serialize:SerializeCompressForPrint(tbl)` / `DeserializeDecompressFromPrint(s)` —
probed live: `{a=1,b="crafter"}` → 23 chars → round-trips exact. (Portable fallback:
LibSerialize + LibDeflate:EncodeForPrint, same wire shape.)

Wire format: keep the envelope plaintext so readers filter/reassemble without decoding:
`SF1|CRF|<id>|<seq>/<total>|<blob>` (≤ ~240 chars/message).

Reader cache: store the **flattened blob + version + seenAt** in SavedVariables, TTL-prune,
decode only when viewed.

## Attestation surfaces **[proven]**

- **Guild rank, by STRUCTURE not name:** `GetGuildInfo("player")` returns the rank *index*
  (probed: `"Noctis Raven Occult", "Cult member", 3`). Only index **0 (Guild Master)** is
  structurally universal — default hard lock for posting a guild profile. Elegant delegation:
  the GM-signed profile itself declares which rank indices may refresh it. Same-guild readers
  can hard-verify a poster via `GuildRoster()`/`GetGuildRosterInfo` (probed: name, rankName,
  rankIndex, level, class...); cross-guild readers accept attestation anchored to the
  server-attested sender name.
- **Professions:** `GetNumSkillLines()`/`GetSkillLineInfo(i)` under the "Professions" header
  (probed: `Herbalism 65/150`, `Skinning 115/150`) — and this fork appends a full profession
  **description string** stock never had. Everything an ad needs in one read.

## Recipes — ride the native trade link **[proven, the headline]**

The tradeskill UI's share button (`GetTradeSkillListLink()`) emits a genuine wrath-format trade
link **with the known-recipe bitmap in-band** — probed on an Ascension CUSTOM profession:

```
|Htrade:1005008:1:75:37E79:AiDAAAAAAAAAAAAAAAA|h[Apprentice Woodworking]|h
        spellId:cur:max:GUID:recipe-bitmap        (86 chars at rank 1/75)
```

So a crafter ad = `profession + rank/max (skill line) + blurb (bounded free text) + trade link +
contact preference`. No recipe serialization needed — the client's own format, decoded and
rendered by every receiver's native handler, and impossible to claim recipes the decoder won't
render. (Optional deeper validation on this server: the client ships `Data/Content/
TradeSkillRecipeData.json` — dev-authored recipe catalog, bake-able into the addon at build time.)

## Contact handoff

The board's job ends at discovery: a click-to-whisper prefill (`/w Name `), mail as a *listed
preference* only (addons can't send mail without a mailbox + hardware events — correctly manual).

## Open items (small)

1. **Offline-link test:** click a cached trade link while the poster is offline (bitmap is
   in-band, expected to decode standalone — one test).
2. Officer-delegation UX (the GM-declared rank-threshold field).
3. Heartbeat/SYNC tuning under real channel population.

## Prior art index

WeakAuras (serialize→deflate→EncodeForPrint transmission) · Gatherer/Cartographer mesh sync
(heartbeat + request/response + answer-suppression) · GuildAds (hidden-channel cross-guild
boards, this client era) · ChatThrottleLib (send pacing) · wrath trade links (in-band recipe
bitmaps, the era's own "share my craft" primitive).
