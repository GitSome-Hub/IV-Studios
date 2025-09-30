fx_version 'cerulean'
game 'gta5'
lua54 'yes'

description 'FS Clothing'
author 'Fantasy Scripts'
version '1.0.0'

shared_script {
    'config.lua',
}

client_script 'client.lua'
server_scripts {
    'server.lua',
}

escrow_ignore {
    'config.lua',
}
dependency '/assetpacks'