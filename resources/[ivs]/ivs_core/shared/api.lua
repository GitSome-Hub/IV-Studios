-- Server-side exported signatures:
--   IVS_GetPlayer(source) -> table|nil    -- unified player wrapper
--   IVS_RegisterScript(name, metaTable)   -- register child script into core
--   IVS_NotifyAll(message, type?)         -- broadcast notify
--   IVS_GetFramework() -> 'qb'|'esx'|'ox'|'standalone'

-- Client-side exported signatures:
--   IVS_Notify(msg, type?)                -- uses ox_lib or chat fallback
--   IVS_GetKeybinds() -> table            -- centralizes keybinds later
