fx_version 'adamant'
game 'gta5'

author "MT"
description 'MT-Chat Enhanced for qb-core'
version '1.1.0'

provide 'chat'

dependency 'ox_lib'

ui_page "html/index.html"

files {
    "html/index.html",
    "html/assets/index.css",
    "html/assets/index.js"
}

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua',
    'shared/sh_utils.lua'
}

client_script "client/cl_chat.lua"

server_script 'server/sv_chat.lua'
