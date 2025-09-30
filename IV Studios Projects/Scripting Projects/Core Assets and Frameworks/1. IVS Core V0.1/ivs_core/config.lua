IVS = IVS or {}
IVS.Config = {
  FrameworkMode = 'auto',        -- 'auto'|'qb'|'esx'|'ox'|'standalone'
  Debug = true,                  -- toggle verbose logs in dev, off in prod
  Locale = 'en',

  Notifications = {
    UseOxLib = true,             -- if ox_lib exists, use its notify/ui helpers
    FallbackChat = true          -- fallback to chat notifications
  },

  License = {
    Enable = false,              -- flip to true when you wire license check
    Key = '',                    -- optional offline key slot
    Endpoint = ''                -- your license verify API (optional)
  }
}
