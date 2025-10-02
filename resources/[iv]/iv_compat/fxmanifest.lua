fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'IV Studios'
description 'Compatibility/bridge layer for IV stack'

shared_scripts {
  '@ox_lib/init.lua',
}

client_scripts {
  'client/*.lua'
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'server/*.lua'
}

dependency 'ox_lib'
