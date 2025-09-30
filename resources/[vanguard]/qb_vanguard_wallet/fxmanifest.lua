fx_version 'cerulean'
game 'gta5'
lua54 'yes'
description 'Developed by Vanguard Labs'
version '1.0.1'

shared_scripts {
  '@ox_lib/init.lua',
  'configuration/config.lua'
}

client_scripts {
  'client/*.lua'
}

server_scripts {
  'server/*.lua'
}

dependencies {
  'ox_inventory',
  'ox_target',
  'ox_lib'
}

escrow_ignore {
  'client/*.lua',
  'server/*.lua',
  'configuration/config.lua',
  'inventory-images/*.png'
}
dependency '/assetpacks'