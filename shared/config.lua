Config = {}

-- [[ CONFIGURAÇÕES DO CHAT ]] --

-- Distância para o chat local (/l)
Config.LocalDistance = 20.0

-- Mostrar ID do jogador no chat? (Ex: [12] João Silva)
Config.ShowID = true

-- [[ CONFIGURAÇÕES DE LOGS E EVENTOS ]] --
Config.DiscordWebhook = "" -- URL do Webhook do Discord (Deixe vazio para desativar)
Config.EnableCustomEvent = true -- Ativa o trigger de evento para outros recursos
Config.CustomEventName = "mri_Qchat:server:onMessage"

-- Ativar debug de prints no console
Config.Debug = false

-- Nomes dos Comandos (Caso queira mudar no futuro)
Config.Commands = {
    global = 'g',
    localChat = 'l',
    ooc = 'ooc',
    me = 'me',
    doCmd = 'do',
    staff = 'staffc',
    anuncio = 'anuncioc',
    clear = 'limpar'
}

-- [[ PALETA DE CORES (HEX) ]] --

-- Cor de destaque da UI (bordas, botões, ícones). Lê primeiro da convar
-- global `mri:color` (compartilhada com toda a suite MRI: mri_Qmultichar,
-- mri_Qspawn, mri_Qadmin, mri_Qloadscreen). Defina via
-- `setr mri:color "#hex"` no server.cfg ou pelo painel admin do mri_Qadmin.
-- Se a convar não estiver setada, cai no fallback abaixo.
Config.UIPrimaryColor = GetConvar('mri:color', '#00E699')

-- Cores por canal de mensagem (paleta independente, não confundir com a
-- cor de destaque acima).
Config.Colors = {
    ['GLOBAL'] = '#9406f9',   -- Roxo Neon
    ['LOCAL'] = '#ffffff',    -- Branco
    ['STAFF'] = '#ff0000',    -- Vermelho
    ['ANUNCIOS'] = '#ffd700', -- Dourado/Amarelo
    ['OOC'] = '#00ffff',      -- Ciano
    ['RP'] = '#ff00ff'        -- Magenta
}

