IVS = IVS or {}

-- Export: framework getter
exports('IVS_GetFramework', function()
  return IVS.GetFramework and IVS.GetFramework() or 'standalone'
end)

-- Export: script registry
local Registered = {}
exports('IVS_RegisterScript', function(name, meta)
  Registered[name] = meta or {}
  TriggerEvent(IVS.Consts.Events.ScriptRegistered, name, meta)
  IVS.Log('INFO', ('Script registered: %s'):format(name))
end)

-- Export: unified player fetch
exports('IVS_GetPlayer', function(src)
  local fw = IVS.GetFramework and IVS.GetFramework() or 'standalone'
  if fw == 'qb' and IVS.QBCore then
    return IVS.QBCore.Functions.GetPlayer(src)
  elseif fw == 'esx' and IVS.ESX then
    return IVS.ESX.GetPlayerFromId(src)
  else
    -- minimal standalone wrapper
    local identifiers = {}
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
      identifiers[#identifiers+1] = GetPlayerIdentifier(src, i)
    end
    return { source = src, identifiers = identifiers }
  end
end)

-- Export: broadcast notify
exports('IVS_NotifyAll', function(message, nType)
  nType = nType or 'info'
  TriggerClientEvent('ivs:notify', -1, message, nType)
end)

AddEventHandler('onResourceStart', function(res)
  if res ~= GetCurrentResourceName() then return end
  IVS.Log('INFO', 'IVS Core initialized.')
  if IVS.Config and IVS.Config.License and IVS.Config.License.Enable then
    TriggerEvent('ivs:license:verify')
  end
end)
