fx_version 'cerulean'
game 'gta5'
lua54 'yes'
description 'Developed by Vanguard Labs'
version '2.0.0'

shared_scripts {
  '@ox_lib/init.lua',
  'configuration/*.lua'
}

client_scripts {
    'client/**.lua'
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'server/**.lua'
}

dependencies {
  'ox_inventory',
  'ox_target',
  'ox_lib'
}

data_file 'DLC_ITYP_REQUEST' 'customBackpacks/*.ytyp'
files {
    'customBackpacks/*.ydr',
    'customBackpacks/*.ytyp'
}

escrow_ignore {
  'client/*.lua',
  'server/*.lua',
  'configuration/*.lua',
  'inventory-images/*.png',
  'customBackpacks/*.ydr',
  'customBackpacks/*.ytyp'
}
dependency '/assetpacks'