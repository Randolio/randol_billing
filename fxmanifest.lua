fx_version 'cerulean'
game 'gta5'

author 'Randolio'
description 'Billing System'

shared_scripts {
    'config.lua',
    '@ox_lib/init.lua',
}

client_scripts {
    'cl_charge.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'sv_charge.lua'
}

lua54 'yes'
