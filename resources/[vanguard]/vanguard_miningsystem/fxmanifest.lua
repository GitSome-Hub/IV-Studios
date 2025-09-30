fx_version 'cerulean'
game 'gta5'
lua54 'yes'
description 'Developed by Vanguard Labs'
version '1.0.2'

shared_scripts { '@ox_lib/init.lua', '@Vanguard_Bridge/imports.lua', 'configuration/*.lua' }

client_scripts { 'client/*.lua' }

server_scripts { 'server/*.lua' }


ui_page 'ui/index.html'

files { 'ui/*.*', 'ui/songs/*.*' }

escrow_ignore {
  'configuration/*.lua',
  'server/*.lua',
  'client/*.lua',
  'inventory-images/*.png'
}


dependencies { 'ox_lib', 'ox_target', 'Vanguard_Bridge' }
dependency '/assetpacks'