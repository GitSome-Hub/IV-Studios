fx_version 'cerulean'
game 'gta5'
lua54 'yes'
description 'Developed by Vanguard Labs'
version '1.0.0'

shared_scripts { '@Vanguard_Bridge/imports.lua', 'configuration/*.lua' }

client_scripts { 'configuration/*.lua', 'client/*.lua', }

server_scripts { '@oxmysql/lib/MySQL.lua', 'configuration/*.lua', 'server/*.lua', }

ui_page { 'html/ui.html' }

files {	'html/ui.html', 'html/font/*.ttf', 'html/font/*.otf', 'html/css/*.css', 'html/images/*.jpg', 'html/images/*.png', 'html/js/*.js', }

escrow_ignore {
	'configuration/config.lua',
	'client/*.lua',
	'server/*.lua',
}  

dependencies { '/assetpacks', 'ox_lib', 'ox_target', 'Vanguard_Bridge' }
dependency '/assetpacks'