
fx_version 'cerulean'
games { 'rdr3', 'gta5' }

author 'ByPislik'
description 'elastik family'
version '1.0.0'




ui_page 'nui/index.html'


files {
    'nui/index.html',
    'nui/*.js',
    'nui/*.wav',
    'nui/*.png',
    'nui/*.svg',
    'nui/*.woff',
    'nui/*.otf',
    'nui/*.css'
    


}





client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
    'config.lua',
    'client.lua',
    'familymission.lua'
}
server_script {
    '@mysql-async/lib/MySQL.lua',
    'config.lua',
    'elssff.lua',
    'server.lua'

}


lua54 'yes'

escrow_ignore {
  'config.lua',
}

