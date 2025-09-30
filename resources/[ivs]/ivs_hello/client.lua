RegisterCommand('ivs_ping', function()
  TriggerServerEvent('ivs:ping', GetPlayerServerId(PlayerId()))
end)

RegisterNetEvent('ivs:pong', function(ts)
  lib.notify({title='IVS', description=('Pong %s'):format(ts), type='success'})
end)
