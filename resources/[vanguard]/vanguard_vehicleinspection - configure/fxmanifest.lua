fx_version 'cerulean'
game 'gta5'
lua54 'yes'
description 'Developed by Vanguard Labs'
version '1.0.4'

shared_scripts { 
    '@ox_lib/init.lua', 
    '@Vanguard_Bridge/imports.lua', 
    'configuration/*.lua' 
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

escrow_ignore {
    'client/*.lua',
    'server/*.lua',
    'configuration/*.lua',
    'inventory-images/*.png',
}

dependencies { 
    'ox_target', 
    'Vanguard_Bridge' 
}
dependency '/assetpacks'