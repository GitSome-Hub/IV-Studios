fx_version 'cerulean'
game 'gta5'
lua54 'yes'
description 'Developed by Vanguard Labs (QBCore Version)'
version '1.0.1'

shared_scripts {
  '@ox_lib/init.lua',
  'configuration/*.lua'
}

client_scripts {
  'wrapper/cl_wrapper.lua',
  'wrapper/*.lua',
  'client/*.lua'
}

server_scripts {
  'wrapper/sv_wrapper.lua',
  'wrapper/*.lua',
  'server/*.lua',
  '@oxmysql/lib/MySQL.lua'
}

dependencies {
  'qb-core',
  'oxmysql',
  'ox_lib'
}

escrow_ignore {
  'client/*.lua',
  'server/*.lua',
  'configuration/*.lua',
  'client/cl_customize.lua',
}

provides {
  'qb-policejob'
}

dependency '/assetpacks'
dependency '/assetpacks'