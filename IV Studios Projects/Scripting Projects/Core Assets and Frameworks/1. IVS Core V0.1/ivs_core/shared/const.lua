IVS = IVS or {}
IVS.Consts = {
  ResourceName = GetCurrentResourceName(),
  Events = {
    PlayerLoaded = 'ivs:playerLoaded',
    PlayerDropped = 'ivs:playerDropped',
    ScriptRegistered = 'ivs:scriptRegistered'
  }
}

-- tiny, safe logger used everywhere (respects Config.Debug)
function IVS.Log(level, ...)
  local msg = ('[IVS:%s] '):format(level)
  if level == 'DEBUG' and not (IVS.Config and IVS.Config.Debug) then return end
  print(msg, ...)
end
