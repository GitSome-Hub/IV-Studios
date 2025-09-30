fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'ivs_example'
author 'IV Studios'
description 'Tiny child resource that proves ivs_core exports/events'
version '0.1.0'

-- Hard start AFTER core
dependency 'ivs_core'

-- Bringing in the public signatures file from core (purely for dev clarity)
shared_scripts {
  '@ivs_core/shared/api.lua'
}

client_scripts {
  'client/main.lua'
}

server_scripts {
  'server/main.lua'
}
