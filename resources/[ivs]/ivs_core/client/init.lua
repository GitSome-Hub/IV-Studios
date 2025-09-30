RegisterNetEvent('ivs:notify', function(msg, typ)
  local useOx = (IVS.Config and IVS.Config.Notifications and IVS.Config.Notifications.UseOxLib)
                and GetResourceState('ox_lib') == 'started'
  if useOx then lib.notify({ description = msg, type = typ or 'info' })
  elseif IVS.Config and IVS.Config.Notifications and IVS.Config.Notifications.FallbackChat then
    TriggerEvent('chat:addMessage', { args = { '^6IVS', msg } })
  end
end)

exports('IVS_Notify', function(msg, typ) TriggerEvent('ivs:notify', msg, typ) end)
exports('IVS_GetKeybinds', function() return { OpenMenu='F2', Interact='E' } end)
