RegisterServerEvent('chat:init')
RegisterServerEvent('chat:addTemplate')
RegisterServerEvent('chat:addMessage')
RegisterServerEvent('chat:addSuggestion')
RegisterServerEvent('chat:removeSuggestion')
RegisterServerEvent('_chat:messageEntered')
RegisterServerEvent('chat:clear')
RegisterServerEvent('__cfx_internal:commandFallback')

-- Broadcast em runtime quando a convar `mri:color` muda (admin via painel
-- mri_Qadmin ou `setr mri:color` no console). 
AddConvarChangeListener('mri:color', function(name)
    if name ~= 'mri:color' then return end
    local color = GetConvar('mri:color', '#00E699')
    if not color:match('^#%x%x%x%x%x%x$') then return end
    Config.UIPrimaryColor = color
    TriggerClientEvent('mri_Qchat:client:accentColorChanged', -1, color)
end)

-- Função auxiliar para enviar mensagens com canal
local function sendToChannel(target, author, message, channel, color)
    TriggerClientEvent('chat:addMessage', target, {
        channel = channel or 'GLOBAL',
        args = { author, message },
        color = color or { 255, 255, 255 }
    })
end

-- Função para processar LOGS e EVENTOS
local function TriggerLog(source, author, message, channel)
    -- 1. Evento Customizado para outros scripts
    if Config.EnableCustomEvent then
        TriggerEvent(Config.CustomEventName, {
            source = source,
            author = author,
            message = message,
            channel = channel,
            timestamp = os.time()
        })
    end

    -- 2. Log no Discord via Webhook
    if Config.DiscordWebhook and Config.DiscordWebhook ~= "" then
        local embed = {
            {
                ["color"] = 7559430, -- Cor temática
                ["title"] = "📝 Log de Chat - " .. (channel or "GLOBAL"),
                ["description"] = string.format("**Autor:** %s\n**Mensagem:** %s\n**Source ID:** %s", author, message, source),
                ["footer"] = {
                    ["text"] = "mri_Qchat | " .. os.date("%d/%m/%Y %H:%M:%S"),
                },
            }
        }
        PerformHttpRequest(Config.DiscordWebhook, function(err, text, headers) end, 'POST', json.encode({username = "mri_Qchat Logs", embeds = embed}), { ['Content-Type'] = 'application/json' })
    end
end

-- Função auxiliar para envio local (proximidade)
local function sendLocal(source, author, message, channel, color)
    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    for _, target in ipairs(GetPlayers()) do
        local targetCoords = GetEntityCoords(GetPlayerPed(target))
        if #(playerCoords - targetCoords) <= Config.LocalDistance then
            sendToChannel(target, author, message, channel, color)
        end
    end
end

-- Função para puxar o nome do personagem (QBX)
local function GetCharacterName(source)
    local name = GetPlayerName(source)
    local player = exports.qbx_core:GetPlayer(source)
    
    if player and player.PlayerData and player.PlayerData.charinfo then
        name = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname
    end

    if Config.ShowID then
        return string.format("[%d] %s", source, name)
    end
    return name
end

-- Função auxiliar para verificar permissão
local function HasAdminPermission(source)
    if source == 0 then return true end -- Console sempre tem permissão
    return exports.qbx_core:HasPermission(source, 'admin') or exports.qbx_core:HasPermission(source, 'god')
end

-- Chat Global
RegisterCommand(Config.Commands.global, function(source, args, rawCommand)
    local message = table.concat(args, ' ')
    if message ~= "" then
        local author = GetCharacterName(source)
        sendToChannel(-1, author, message, 'GLOBAL', Config.Colors['GLOBAL'])
        TriggerLog(source, author, message, 'GLOBAL')
    end
end, false)

-- Chat Local
RegisterCommand(Config.Commands.localChat, function(source, args, rawCommand)
    local message = table.concat(args, ' ')
    if message ~= "" then
        local author = GetCharacterName(source)
        sendLocal(source, author, message, 'LOCAL', Config.Colors['LOCAL'])
        TriggerLog(source, author, message, 'LOCAL')
    end
end, false)

-- Chat Staff
RegisterCommand(Config.Commands.staff, function(source, args, rawCommand)
    if not HasAdminPermission(source) then
        return TriggerClientEvent('chat:addMessage', source, {
            color = { 255, 0, 0 },
            args = { "SISTEMA", "Você não tem permissão para usar este comando." }
        })
    end

    local message = table.concat(args, ' ')
    if message ~= "" then
        local author = GetCharacterName(source)
        for _, target in ipairs(GetPlayers()) do
            if HasAdminPermission(tonumber(target)) then
                sendToChannel(target, author, message, 'STAFF', Config.Colors['STAFF'])
            end
        end
        TriggerLog(source, author, message, 'STAFF')
    end
end, false)

-- Chat Anúncio
RegisterCommand(Config.Commands.anuncio, function(source, args, rawCommand)
    if not HasAdminPermission(source) then
        return TriggerClientEvent('chat:addMessage', source, {
            color = { 255, 0, 0 },
            args = { "SISTEMA", "Você não tem permissão para usar este comando." }
        })
    end

    local message = table.concat(args, ' ')
    if message ~= "" then
        local author = "ANÚNCIO"
        sendToChannel(-1, author, message, 'ANUNCIOS', Config.Colors['ANUNCIOS'])
        TriggerLog(source, author, message, 'ANUNCIOS')
    end
end, false)

-- Chat OOC (Global)
RegisterCommand(Config.Commands.ooc, function(source, args, rawCommand)
    local message = table.concat(args, ' ')
    if message ~= "" then
        local author = GetCharacterName(source)
        sendToChannel(-1, author, "[OOC] " .. message, 'OOC', Config.Colors['OOC'])
        TriggerLog(source, author, message, 'OOC')
    end
end, false)

-- Chat ME (Local)
RegisterCommand(Config.Commands.me, function(source, args, rawCommand)
    local message = table.concat(args, ' ')
    if message ~= "" then
        local author = GetCharacterName(source)
        sendLocal(source, author, "[ME] " .. message, 'RP', Config.Colors['RP'])
        TriggerLog(source, author, message, 'RP_ME')
    end
end, false)

-- Chat DO (Local)
RegisterCommand(Config.Commands.doCmd, function(source, args, rawCommand)
    local message = table.concat(args, ' ')
    if message ~= "" then
        local author = GetCharacterName(source)
        sendLocal(source, author, "[DO] " .. message, 'RP', Config.Colors['RP'])
        TriggerLog(source, author, message, 'RP_DO')
    end
end, false)

-- Padrão ao digitar sem comando (Chat Local)
AddEventHandler('_chat:messageEntered', function(authorPassed, color, message)
    if not message then return end
    
    local source = source
    if message:sub(1, 1) == '/' then return end
    
    local author = GetCharacterName(source)
    sendLocal(source, author, message, 'LOCAL', Config.Colors['LOCAL'])
    TriggerLog(source, author, message, 'LOCAL')
end)

-- Resto das funções originais (Suggestions, Clear, etc)
local function refreshCommands(player)
    if GetRegisteredCommands then
        local registeredCommands = GetRegisteredCommands()
        local suggestions = {}
        
        -- Lista de comandos que queremos mostrar explicitamente com ajuda
        local customSuggestions = {
            ['/' .. Config.Commands.global] = "Enviar uma mensagem global",
            ['/' .. Config.Commands.localChat] = "Enviar uma mensagem local",
            ['/' .. Config.Commands.ooc] = "Mensagem fora de personagem (OOC)",
            ['/' .. Config.Commands.me] = "Descrever uma ação do seu personagem",
            ['/' .. Config.Commands.doCmd] = "Descrever o ambiente ou situação",
            ['/' .. Config.Commands.clear] = "Limpar as mensagens do seu chat",
        }

        for _, command in ipairs(registeredCommands) do
            local cmdName = '/' .. command.name
            if IsPlayerAceAllowed(player, ('command.%s'):format(command.name)) then
                table.insert(suggestions, {
                    name = cmdName,
                    help = customSuggestions[cmdName] or ''
                })
            end
        end
        TriggerClientEvent('chat:addSuggestions', player, suggestions)
        
        -- Sincroniza o status de admin para o client (usado no serverPrint)
        local isAdmin = HasAdminPermission(player)
        TriggerClientEvent('mri_Qchat:client:syncAdminStatus', player, isAdmin)
    end
end

AddEventHandler('chat:init', function()
    refreshCommands(source)
end)

AddEventHandler('onServerResourceStart', function(resName)
    if GetCurrentResourceName() ~= resName then return end
    Wait(500)
    for _, player in ipairs(GetPlayers()) do
        refreshCommands(player)
    end
end)
