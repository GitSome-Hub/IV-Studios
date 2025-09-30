IVS = IVS or {}

exports('IVS_GetFramework', function()
  return IVS.GetFramework and IVS.GetFramework() or 'standalone'
end)

exports('IVS_RegisterScript', function(name, meta)
  IVS.Registered = IVS.Registered or {}; IVS.Registered[name] = meta or {}
  TriggerEvent('ivs:scriptRegistered', name, meta or {})
end)

exports('IVS_GetPlayer', function(src)
  local fw = IVS.GetFramework and IVS.GetFramework() or 'standalone'
  if fw == 'qb' and IVS.QBCore then return IVS.QBCore.Functions.GetPlayer(src) end
  if fw == 'esx' and IVS.ESX   then return IVS.ESX.GetPlayerFromId(src) end
  local ids = {}; for i=0,GetNumPlayerIdentifiers(src)-1 do ids[#ids+1]=GetPlayerIdentifier(src,i) end
  return { source=src, identifiers=ids }
end)

exports('IVS_NotifyAll', function(msg, typ)
  TriggerClientEvent('ivs:notify', -1, msg, typ or 'info')
end)
