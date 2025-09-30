fx_version 'cerulean'
game 'gta5'
lua54 'yes'
description 'Developed by Vanguard Labs'
version '1.0.4'

shared_scripts {
	'@ox_lib/init.lua',
	'configuration/config.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/*.lua'

}

client_scripts {
	'client/*.lua'
}


ui_page 'ui/index.html'
files {
	'imports.lua',
	'ui/*.*',
	'ui/notify/*.*',
	'ui/menu/*.*'
}

escrow_ignore {
	'configuration/*.lua'
  }


dependency '/assetpacks'