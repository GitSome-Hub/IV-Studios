fx_version 'cerulean'
game 'gta5'
lua54 'yes'
description 'Developed by Vanguard Labs'
version '1.0.0'

ui_page 'ui/index.html'

shared_scripts { '@Vanguard_Bridge/imports.lua', '@ox_lib/init.lua', 'configuration/config.lua', }

client_scripts { 'client/client.lua' }

server_scripts { '@oxmysql/lib/MySQL.lua', 'server/server.lua' }

files { 'ui/index.html', 'ui/style.css', 'ui/script.js' }

dependencies { 'Vanguard_Bridge' }

escrow_ignore {
    'configuration/*.lua',
    'client/client.lua',
    'server/server.lua'
  }


dependency '/assetpacks'