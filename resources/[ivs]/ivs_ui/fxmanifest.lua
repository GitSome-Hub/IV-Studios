fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'ivs_ui'
author 'IV Studios'
description 'Shared NUI components & UI bridge'
version '0.1.0'

ui_page 'web/index.html'
files { 'web/index.html','web/app.js','web/styles.css' }

escrow_ignore { 'config.lua','locales/*.lua' }

shared_scripts { 'config.lua','locales/*.lua','shared/ui_api.lua' }
client_scripts { 'client/main.lua','client/api.lua' }

client_exports { 'IVSUI_Open','IVSUI_Close','IVSUI_Toast','IVSUI_OpenConfirm' }
