-- Prove core is there + register our script
CreateThread(function()
  -- Announce registration in the core registry
  exports['ivs_core']:IVS_RegisterScript('ivs_example', {
    version = '0.1.0',
    author = 'IV Studios'
  })

  -- Broadcast that we loaded (uses core’s server export)
  exports['ivs_core']:IVS_NotifyAll('ivs_example loaded ✅', 'success')
end)

-- When core says a player is "loaded", say hello to that player
AddEventHandler('ivs:playerLoaded', function(src, playerObj)
  -- Get framework name for demo
  local fw = exports['ivs_core']:IVS_GetFramework()

  -- Send a client notify via core’s notify event
  local msg = ('Welcome! ivs_example is live. Framework: %s'):format(fw)
  TriggerClientEvent('ivs:notify', src, msg, 'inform')

  -- Also log (server-side)
  print(('[ivs_example] greeted %s (framework: %s)'):format(src, fw))
end)

-- Tiny command to demo unified player getter
RegisterCommand('ivs_example_me', function(source)
  local ply = exports['ivs_core']:IVS_GetPlayer(source)
  if not ply then
    TriggerClientEvent('ivs:notify', source, 'No player object found 🤔', 'error')
    return
  end

  local id = (ply.PlayerData and ply.PlayerData.citizenid)
          or (ply.identifier)
          or (ply.identifiers and ply.identifiers[1])
          or 'unknown'

  TriggerClientEvent('ivs:notify', source, ('Your ID: %s'):format(id), 'info')
end, false)
