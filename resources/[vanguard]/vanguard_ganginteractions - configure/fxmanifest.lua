fx_version 'cerulean'
game 'gta5'
lua54 'yes'
description 'Developed by Vanguard Labs'
version '1.0.0'


shared_scripts { '@ox_lib/init.lua', '@Vanguard_Bridge/imports.lua', 'html/icons/*.png', 'configuration/*.lua' }

client_scripts { 'client/*.lua' }

server_scripts { 'server/*.lua' }

ui_page 'html/index.html'

files { 'html/index.html', 'html/style.css', 'html/script.js', 'html/icons/*.png' }

escrow_ignore {
    'configuration/*.lua',
    'client/*.lua',
    'server/*.lua',
    'html/icons/*.png'
  }


dependencies { 'Vanguard_Bridge' }
dependency '/assetpacks'