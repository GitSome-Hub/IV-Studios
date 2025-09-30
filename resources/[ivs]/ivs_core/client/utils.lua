IVS = IVS or {}
function IVS.DrawDebugText3D(coords, text)
  if not (IVS.Config and IVS.Config.Debug) then return end
  SetDrawOrigin(coords.x, coords.y, coords.z, 0)
  SetTextScale(0.35, 0.35)
  SetTextFont(4)
  SetTextProportional(1)
  SetTextOutline()
  SetTextCentre(1)
  BeginTextCommandDisplayText("STRING")
  AddTextComponentSubstringPlayerName(text)
  EndTextCommandDisplayText(0.0, 0.0)
  ClearDrawOrigin()
end
