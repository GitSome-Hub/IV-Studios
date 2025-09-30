fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'ivs_core'
author 'IV Studios'
description 'IVS Core Brain-Frameworks'
version '0.1.0'

-- Keep these editable for customers
escrow_ignore {
  'config.lua',
  'locales/*.lua'
}

-- If you use ox_lib, leave it as optional; we hard-check at runtime.
shared_scripts {
  '@ox_lib/init.lua',      -- optional (won't crash if missing; we guard)
  'config.lua',
  'locales/*.lua',
  'shared/consts.lua',
  'shared/bridge.lua',
  'shared/api.lua'
}

server_scripts {
  'server/init.lua',
  'server/events.lua',
  'server/players.lua',
  'server/license.lua'
}

client_scripts {
  'client/init.lua',
  'client/events.lua',
  'client/utils.lua'
}

-- Exports: the public API other IVS scripts will call
exports {
  -- shared exports are declared in shared/api.lua (signatures),
  -- but FiveM requires actual side-specific export declarations:
}
server_exports {
  'IVS_GetPlayer',
  'IVS_RegisterScript',
  'IVS_NotifyAll',
  'IVS_GetFramework' -- returns 'qb','esx','ox','standalone'
}
client_exports {
  'IVS_Notify',
  'IVS_GetKeybinds'
}

-- Optional hard dependencies for start order (comment out if not used)
-- dependency 'ox_lib'
