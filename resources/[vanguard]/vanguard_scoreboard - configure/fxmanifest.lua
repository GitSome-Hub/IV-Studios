fx_version 'cerulean'
game 'gta5'
lua54 'yes'
description 'Developed by Vanguard Labs'
version '1.0.1'

ui_page 'ui/index.html'

shared_scripts {
    'configuration/config.lua'
}

client_scripts {
    'client/client.lua'
}

server_scripts {
    'server/server.lua'
}

files {
    'ui/index.html',
    'ui/styles.css',
    'ui/script.js'
}

escrow_ignore {
    'client/client.lua',
    'server/server.lua',
    'configuration/config.lua'
}
dependency '/assetpacks'