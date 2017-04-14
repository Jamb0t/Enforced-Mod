MCG = MCG or {}

---- Start Message Register ----
local kMsgMoveName = "MoveServer_Move"
local kMsgMoveData = {
  host = "string (21)"
}

Shared.RegisterNetworkMessage(kMsgMoveName, kMsgMoveData)
---- End Message Register ----

if Server then
  ---- Start Server ----
  function MCG.SendMoveServer(host)
    local m = {}

    m.host = host

    Server.SendNetworkMessage(kMsgMoveName, m, true)
  end
  ---- End Server -----
else
  ---- Client Start ----
  local function recMoveServer(m)
    Shared.ConsoleCommand(string.format("connect %s", m.host))
  end
  
  Client.HookNetworkMessage(kMsgMoveName, recMoveServer)
  ---- End Client -----
end

