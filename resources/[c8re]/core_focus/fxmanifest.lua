fx_version 'cerulean'
game 'gta5'

lua54 'yes'
use_experimental_fxv2_oal 'yes'

author 'C8RE'
description 'Radial Targeting System for FiveM'
version '1.1.1'

ui_page 'html/index.html'

shared_script 'config.lua'

client_scripts {
	'@PolyZone/client.lua',
	'@PolyZone/BoxZone.lua',
	'@PolyZone/EntityZone.lua',
	'@PolyZone/CircleZone.lua',
	'@PolyZone/ComboZone.lua',
	'integration_main.lua',
	'modules/augmentedwindow.lua',
	'modules/benches.lua',
	'modules/bones.lua',
	'modules/props.lua',
	'modules/admininteractions.lua',
	'modules/playerinteractions.lua',
	'client.lua',
	'bridge.lua'
}

server_scripts {
	'server/admininteractions.lua',
	'server/playerinteractions.lua',
	'server/playertags.lua',
	'server/props.lua',
}

files {
	'html/*.html',
	'html/border/*.html',
	'html/border/*.css',
	'html/border/*.js',
	'html/window/*.html',
	'html/window/*.css',
	'html/window/*.js',
	'sounds/*.mp3',
	'html/*.css',
	'html/*.js'
}

provide 'ox_target'
provide 'qb-target'
provide 'qtarget'


dependency 'PolyZone'

escrow_ignore {
	'config.lua',
	'bridge.lua',
	'integration_main.lua',
	'server/admininteractions.json',
	'server/playerinteractions.lua',
	'server/props.lua',
	'server/playertags.lua',
	'modules/admininteractions.lua',
	'modules/augmentedwindow.lua',
	'modules/benches.lua',
	'modules/bones.lua',
	'modules/playerinteractions.lua',
	'modules/props.lua'
}
dependency '/assetpacks'