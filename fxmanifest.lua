fx_version 'adamant'
game 'gta5'

author "MT"
description 'MT-Chat Enhanced for qb-core'
version '1.0.1'

provide 'chat'

ui_page "html/index.html"

files {
    "html/index.html",
    "html/assets/index.css",
    "html/assets/index.js"
}

shared_scripts {
    'shared/config.lua',
    'shared/sh_utils.lua'
}

client_script "client/cl_chat.lua"

server_script 'server/sv_chat.lua'
