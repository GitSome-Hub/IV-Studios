fx_version 'cerulean'
game 'gta5'
lua54 'yes'
description 'Developed by Vanguard Labs'
version '1.0.4'

shared_script { 
	'configuration/*.lua',
	'@ox_lib/init.lua',
}

client_scripts {
	'client/*.lua'
}

server_script { 
	'server/*.lua'
}

escrow_ignore {
  'client/*.lua',
  'server/*.lua',	
  'configuration/*.lua',
  'inventory-images/*.png',
}
dependency '/assetpacks'