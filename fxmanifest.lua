fx_version 'bodacious'
game 'gta5'

author "Raad | Hipe Development"
description 'Raad MADE'
url 'https://discord.gg/a5z73uvx47'


shared_script 'shared.lua'
client_script "client/main.lua"
server_script {
	"server/server.lua",
	"permissions.lua"
}

ui_page 'client/index.html'

files {
	'client/index.html'
}

