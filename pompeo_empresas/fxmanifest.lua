server_script "@event_logger/log_register.lua"
fx_version 'bodacious'
game 'gta5'
lua54 'yes'

author "ga"

client_scripts {
	'client-side/*',
}

server_scripts {
	'server-side/*',
}

shared_scripts {
	'@vrp/lib/utils.lua',
	'config.lua'
}