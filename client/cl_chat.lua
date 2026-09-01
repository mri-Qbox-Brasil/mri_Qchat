local chatInputActive = false
local chatInputActivating = false
local chatHidden = false
local chatLoaded = false

RegisterNetEvent('chat:addMessage')
RegisterNetEvent('chat:addSuggestion')
RegisterNetEvent('chat:addSuggestions')
RegisterNetEvent('chat:removeSuggestion')
RegisterNetEvent('chat:clear')
RegisterNetEvent('chatMessage')
RegisterNetEvent('__cfx_internal:serverPrint')

-- Adicionar Mensagem
AddEventHandler('chat:addMessage', function(data)
  -- Fallback de segurança caso `data` seja string
  if type(data) == 'string' then
    data = { args = { data } }
  end
  
  SendNUIMessage({
    type = 'ON_MESSAGE',
    message = data
  })
end)

-- Fallback para chatMessage antigo
AddEventHandler('chatMessage', function(author, color, text)
  local args = { text }
  if author ~= "" then
    table.insert(args, 1, author)
  end
  SendNUIMessage({
    type = 'ON_MESSAGE',
    message = {
      args = args,
      color = color
    }
  })
end)

local isClientAdmin = false

RegisterNetEvent('mri_Qchat:client:syncAdminStatus', function(status)
  isClientAdmin = status
end)

-- Comando temporário para debug manual:
RegisterCommand('debugchatadmin', function()
  isClientAdmin = not isClientAdmin
  print("[mri_Qchat] Modo visualização do ServerPrint: " .. tostring(isClientAdmin))
end, false)

-- Server Print hook
AddEventHandler('__cfx_internal:serverPrint', function(msg)
  if msg and msg ~= "" then
    if isClientAdmin then
      -- Passamos a mensagem original sem gsub para garantir que não é ele quebrando
      SendNUIMessage({
        type = 'ON_MESSAGE',
        message = {
          args = { '[SERVER]', msg },
          color = { 255, 255, 255 }
        }
      })
    end
  end
end)

-- Adicionar Sugestão
AddEventHandler('chat:addSuggestion', function(name, help, params)
  SendNUIMessage({
    type = 'ON_SUGGESTION_ADD',
    suggestion = {
      name = name,
      help = help,
      params = params or {}
    }
  })
end)

-- Adicionar Várias Sugestões
AddEventHandler('chat:addSuggestions', function(suggestions)
  for _, suggestion in ipairs(suggestions) do
    SendNUIMessage({
      type = 'ON_SUGGESTION_ADD',
      suggestion = suggestion
    })
  end
end)

-- Remover Sugestão
AddEventHandler('chat:removeSuggestion', function(name)
  SendNUIMessage({
    type = 'ON_SUGGESTION_REMOVE',
    name = name
  })
end)

-- Limpar Chat
AddEventHandler('chat:clear', function()
  SendNUIMessage({
    type = 'ON_CLEAR'
  })
end)

-- Callbacks NUI
RegisterNUICallback('chatResult', function(data, cb)
  chatInputActive = false
  SetNuiFocus(false)

  if not data.canceled then
    local id = PlayerId()
    local sayId = NetworkGetNetworkIdFromEntity(GetPlayerPed(-1))

    if data.message:sub(1, 1) == '/' then
      ExecuteCommand(data.message:sub(2))
    else
      TriggerServerEvent('_chat:messageEntered', GetPlayerName(id), { r, g, b }, data.message)
    end
  end

  cb('ok')
end)

RegisterNUICallback('loaded', function(data, cb)
  TriggerServerEvent('chat:init')
  chatLoaded = true
  
  -- Envia a cor de destaque (mri:color) assim que a UI carrega
  SendNUIMessage({
    action = 'updateAccentColor',
    accentColor = Config.UIPrimaryColor
  })

  cb('ok')
end)

-- Broadcast: convar `mri:color` mudou no server, propaga pra NUI.
RegisterNetEvent('mri_Qchat:client:accentColorChanged', function(newColor)
  Config.UIPrimaryColor = newColor
  SendNUIMessage({
    action = 'updateAccentColor',
    accentColor = newColor
  })
end)

-- Thread de Controle de Input
Citizen.CreateThread(function()
  SetTextChatEnabled(false)
  Wait(100)

  while true do
    Wait(0)

    if not chatInputActive then
      if IsControlPressed(0, 245) --[[ INPUT_MP_TEXT_CHAT_ALL ]] then
        chatInputActive = true
        chatInputActivating = true

        SendNUIMessage({
          type = 'ON_OPEN'
        })
        
        if Config.Debug then print("^5[mri_Qchat] Tentando abrir o chat...^7") end

        SendNUIMessage({
          action = 'updateAccentColor',
          accentColor = Config.UIPrimaryColor
        })

        Wait(50) -- Pequeno delay para a UI processar a mensagem
        SetNuiFocus(true, true) -- Foco com Teclado e Mouse
        chatInputActivating = false
        if Config.Debug then print("^2[mri_Qchat] Foco NUI definido com sucesso.^7") end
      end
    end

    if chatLoaded then
      local shouldBeHidden = false

      if IsScreenFadedOut() or IsPauseMenuActive() then
        shouldBeHidden = true
      end

      if (shouldBeHidden and not chatHidden) or (not shouldBeHidden and chatHidden) then
        chatHidden = shouldBeHidden

        SendNUIMessage({
          type = 'ON_SCREEN_STATE_CHANGE',
          shouldHide = shouldBeHidden
        })
      end
    end
  end
end)

-- Registro de comando (Fora do Loop!)
Citizen.CreateThread(function()
  while not chatLoaded do Wait(100) end
  RegisterCommand(Config.Commands.clear, function(source, args)
    TriggerEvent('chat:clear')
  end, false)
end)
