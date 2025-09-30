fx_version 'cerulean'
game 'gta5'

author 'Fantasy Scripts'
description 'Comprehensive Government Management System for ESX/QBCore/QBox'
version '1.0.0'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'shared/*.lua'
}

client_scripts {
    'client/*.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}


dependencies {
    'ox_lib',
    'oxmysql'
}

escrow_ignore {
    'config.lua',
    'shared/*.lua',
    'installation/*.*'
}
dependency '/assetpacks'