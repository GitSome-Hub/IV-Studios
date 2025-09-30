fx_version 'cerulean'
game 'gta5'
lua54 'yes'
description 'Developed by Vanguard Labs'
version '1.0.1'

shared_scripts { 
    '@ox_lib/init.lua', 
    '@Vanguard_Bridge/imports.lua', 
    'configuration/*.lua' 
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}

files {
    'configuration/data/vehicles.meta',
    'configuration/data/carvariations.meta',
    'configuration/data/handling.meta'
}

data_file 'DLC_ITYP_REQUEST' 'stream/mads.ytyp'
data_file 'HANDLING_FILE' 'configuration/data/handling.meta'
data_file 'VEHICLE_METADATA_FILE' 'configuration/data/vehicles.meta'
data_file 'VEHICLE_VARIATION_FILE' 'configuration/data/carvariations.meta'

escrow_ignore {
    'configuration/*.lua',
    'server/*.lua',
    'client/*.lua',
    'inventory-images/*.png'
}

dependencies { 
    'Vanguard_Bridge' 
}
dependency '/assetpacks'