fx_version 'cerulean'
game 'gta5'
lua54 'yes'
description 'Developed by Vanguard Labs'
version '1.0.2'

shared_scripts {
    '@ox_lib/init.lua', 
    'configuration/*.lua',
}

client_script {
    'client/*.lua',
}

server_script {
    'server/*.lua',
}

dependencies {
    'ox_inventory',
    'ox_lib',
    'ox_target',
    'qb_vanguard_k9_addon',
}
    
escrow_ignore {
    'client/*.lua',
    'server/*.lua',
    'configuration/*.lua',
}

dependency '/assetpacks'