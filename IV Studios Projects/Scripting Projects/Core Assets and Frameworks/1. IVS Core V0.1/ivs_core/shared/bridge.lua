IVS = IVS or {}
local fw = 'standalone'
local qb = nil
local esx = nil

CreateThread(function()
  -- QBCore
  if GetResourceState('qb-core') == 'started' then
    local ok, QBCore = pcall(function() return exports['qb-core']:GetCoreObject() end)
    if ok and QBCore then fw = 'qb'; qb = QBCore end
  end

  -- ESX
  if fw == 'standalone' and GetResourceState('es_extended') == 'started' then
    local ok, ESX = pcall(function() return exports['es_extended']:getSharedObject() end)
    if ok and ESX then fw = 'esx'; esx = ESX end
  end

  -- ox_core (optional future)
  if fw == 'standalone' and GetResourceState('ox_core') == 'started' then
    fw = 'ox'
  end

  if (IVS.Config or {}).FrameworkMode and IVS.Config.FrameworkMode ~= 'auto' then
    fw = IVS.Config.FrameworkMode
  end

  IVS.Log('INFO', 'Framework detected:', fw)
  IVS.Framework = fw
  IVS.QBCore = qb
  IVS.ESX = esx
end)

function IVS.GetFramework()
  return IVS.Framework or 'standalone'
end
