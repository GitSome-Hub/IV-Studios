fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'ivs_core'
author 'IV Studios'
description 'IVS Core dependency layer'
version '0.1.0'

escrow_ignore { 'config.lua','locales/*.lua','README.md','docs/**' }

shared_scripts {
  '@ox_lib/init.lua',      -- optional; guard if missing
  'config.lua',
  'locales/*.lua',
  'shared/consts.lua',
  'shared/bridge.lua',
  'shared/api.lua'
}
server_scripts { 'server/init.lua','server/events.lua','server/players.lua','server/license.lua' }
client_scripts { 'client/init.lua','client/utils.lua' }

server_exports { 'IVS_GetFramework','IVS_GetPlayer','IVS_RegisterScript','IVS_NotifyAll' }
client_exports { 'IVS_Notify','IVS_GetKeybinds' }
