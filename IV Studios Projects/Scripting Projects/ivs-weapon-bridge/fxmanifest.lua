fx_version 'cerulean'
game 'gta5'

name 'ivs-weapon-bridge'
description 'Auto-bridge add-on weapons (.meta) to ox_inventory items + dev shop'
author 'IVS'
version '1.0.0'

-- you said you use ox_lib + ox_inventory
dependencies {
    'ox_lib',
    'ox_inventory'
}

shared_script '@ox_lib/init.lua'
server_scripts {
    'server.lua',
    'config.lua'
}
client_scripts {
    'client.lua'
}
