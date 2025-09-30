AddEventHandler('playerJoining', function()
  local src = source
  CreateThread(function()
    Wait(500) -- give framework a tick
    local ply = exports['ivs_core']:IVS_GetPlayer(src)
    TriggerEvent(IVS.Consts.Events.PlayerLoaded, src, ply)
    IVS.Log('DEBUG', ('PlayerLoaded %s'):format(src))
  end)
end)

AddEventHandler('playerDropped', function(reason)
  local src = source
  TriggerEvent(IVS.Consts.Events.PlayerDropped, src, reason or 'unknown')
  IVS.Log('DEBUG', ('PlayerDropped %s (%s)'):format(src, reason or 'n/a'))
end)
