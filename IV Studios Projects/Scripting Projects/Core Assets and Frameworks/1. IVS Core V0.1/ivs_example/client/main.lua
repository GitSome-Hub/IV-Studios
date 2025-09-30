-- Prove client export + keybinds
CreateThread(function()
  -- Simple hello using core’s client export
  exports['ivs_core']:IVS_Notify('ivs_example client loaded ✅', 'success')

  -- Ask core for keybinds (demo)
  local keys = exports['ivs_core']:IVS_GetKeybinds()
  if keys then
    TriggerEvent('chat:addMessage', {
      args = { '^6IVS', ('Example Keybinds → Menu: %s | Interact: %s'):format(keys.OpenMenu, keys.Interact) }
    })
  end
end)
