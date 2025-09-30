fx_version 'cerulean'
game 'gta5'

name 'ivs-weapon-bridge'
author 'IVS'
version '1.0.0'

dependencies {
    'ox_lib',
    'ox_inventory'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

server_scripts {
    'server.lua'
}

client_scripts {
    'client.lua'
}
