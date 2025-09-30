fx_version 'cerulean'
game 'gta5'

author 'IV Studios'
description 'Example resource'
version '1.0.0'

lua54 'yes'

shared_scripts {
  '@ox_lib/init.lua',
  'config.lua',
  'locales/*.lua'
}

client_scripts {
  'client.lua'
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'server.lua'
}

ui_page 'nui/index.html' -- remove if no NUI

files {
  'nui/index.html',
  'nui/*.js',
  'nui/*.css',
  'nui/assets/*'
}
