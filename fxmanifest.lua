fx_version 'cerulean'
game 'gta5'

description 'pengu_pawnshops'
version '1.0.0'

shared_scripts {
	'config.lua',
	'@ox_lib/init.lua',

}


client_script {

	'@PolyZone/client.lua',
	'@PolyZone/BoxZone.lua',
	'@PolyZone/EntityZone.lua',
	'@PolyZone/CircleZone.lua',
	'@PolyZone/ComboZone.lua',
	'client/main.lua',
}
server_script 'server/main.lua'

lua54 'yes'
