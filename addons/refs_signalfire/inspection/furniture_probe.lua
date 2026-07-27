-- furniture_probe.lua - LIVE audit: which of the render-impact map's installs
-- actually run vs sit as furniture. Paste into /luaconsole (too long for a
-- macro), then /reload with the watcher open. Lands schema-less into the
-- mailbox as task "furniture" (the /run->mailbox lane).
-- Answers: (a) the ACTUAL installed filter roster per chat event, by global
-- name (which of the 5 generations survived the install/remove dance);
-- (b) every live OnUpdate (named + anon + how many on SHOWN frames - UI-panel
-- handlers only cost while open); (c) which chat frames run wrapped AddMessage.
-- Run with SignalFire in its normal config; the record self-describes.

local P={header={task="furniture",runId=date("%Y%m%d_%H%M%S").."_r",status="complete",tool="COA_DevDump",version="run"},payload={filters={},onupdate={named={},anon=0,shown=0},addmsg={}}}
for _,ev in ipairs({"CHAT_MSG_CHANNEL","CHAT_MSG_SAY","CHAT_MSG_YELL"}) do
  local L={} for i,fn in ipairs(ChatFrame_GetMessageEventFilters(ev) or {}) do
    local name="?" for k,v in pairs(_G) do if v==fn and type(k)=="string" then name=k break end end
    L[i]=name end
  P.payload.filters[ev]=L end
local f=EnumerateFrames() while f do
  if f.GetScript and f:GetScript("OnUpdate") then
    local n=f.GetName and f:GetName()
    if n then table.insert(P.payload.onupdate.named,n) else P.payload.onupdate.anon=P.payload.onupdate.anon+1 end
    if f:IsShown() then P.payload.onupdate.shown=P.payload.onupdate.shown+1 end
  end
  f=EnumerateFrames(f) end
for i=1,NUM_CHAT_WINDOWS do local cf=_G["ChatFrame"..i]
  if cf then P.payload.addmsg["ChatFrame"..i]=(cf._sffclAddMessageHook and "sffcl-hooked") or (cf._sfPublicWhoAddMessageWrapper and "sfPublicWho-wrapped") or "unwrapped-or-unknown" end end
COA_DevDumpDB=P print("furniture audit captured - /reload")
