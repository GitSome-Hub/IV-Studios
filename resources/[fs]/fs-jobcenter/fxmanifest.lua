fx_version 'cerulean'
game 'gta5'
lua54 'yes'

description 'FS Job Center'
author 'Fantasy Scripts'
version '1.0.0'

shared_script {
    '@ox_lib/init.lua',
    'config.lua',
}

client_script 'client.lua'
server_script 'server.lua'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/fonts/*.*',
    'html/img/*.*',
}

escrow_ignore {
    'config.lua',
}
dependency '/assetpacks'