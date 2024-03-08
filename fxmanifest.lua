fx_version 'cerulean'
game 'gta5'

author 'Randolio'
description 'Billing System'

shared_scripts {'config.lua', '@ox_lib/init.lua', }

client_scripts {'bridge/client/**.lua', 'cl_charge.lua', }

server_scripts {'bridge/server/**.lua', 'sv_charge.lua' }

lua54 'yes'
