RegisterNetEvent('ivs:license:verify', function()
  if not IVS.Config or not IVS.Config.License or not IVS.Config.License.Enable then return end
  -- Minimal stub; you can implement HTTP validation to your backend.
  -- Keep in escrow; only expose Config fields for editing.
  if (IVS.Config.License.Key or '') == '' then
    IVS.Log('INFO', 'License: SKIPPED (no key)')
    return
  end
  IVS.Log('INFO', 'License: OK (offline key loaded)')
end)
