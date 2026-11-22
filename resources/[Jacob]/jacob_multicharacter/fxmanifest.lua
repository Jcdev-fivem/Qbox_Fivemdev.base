fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'jacob_multicharacter'
author 'Jacob'
description 'Shifu Town multicharacter, character registration and staging'
version '2.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/staging.lua',
    'client/register.lua',
    'client/select.lua',
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/common.css',
    'html/css/register.css',
    'html/css/select.css',
    'html/js/common.js',
    'html/js/app.js',
    'html/js/register.js',
    'html/js/select.js'
}
