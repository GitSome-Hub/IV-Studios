fx_version 'cerulean'
game 'gta5'
lua54 'yes'
description 'Developed by Vanguard Labs'
version '1.0.0'

ui_page 'html/index.html'

client_scripts {
    'configuration/config.lua',
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'configuration/config.lua',
    'server/main.lua'
}

files {
    'html/index.html',
    'html/css/style.css',
    'html/js/script.js',
    'html/img/*.png',
    'html/fonts/*.ttf'
}

dependencies {
    'qb-core',
    'oxmysql'
}

escrow_ignore {
    'configuration/config.lua',
    'client/*.lua',
    'server/*.lua'
}
dependency '/assetpacks'