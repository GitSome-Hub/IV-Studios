RegisterNetEvent('ivs:notify', function(msg, nType)
  nType = nType or 'info'
  local useOx = (IVS.Config and IVS.Config.Notifications and IVS.Config.Notifications.UseOxLib)
                and GetResourceState('ox_lib') == 'started'
  if useOx then
    lib.notify({ description = msg, type = nType })
  elseif IVS.Config.Notifications.FallbackChat then
    TriggerEvent('chat:addMessage', { args = { '^6IVS', msg } })
  end
end)

-- Exports (client)
exports('IVS_Notify', function(msg, nType)
  TriggerEvent('ivs:notify', msg, nType)
end)

exports('IVS_GetKeybinds', function()
  return {
    OpenMenu = 'F2',
    Interact  = 'E'
  }
end)
