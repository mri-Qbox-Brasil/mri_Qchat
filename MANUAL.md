# mri_Qchat - Manual Funcional

Chat moderno e otimizado para Qbox Framework com interface React, tabs de canais, emoji picker, draggable window e integração com Discord webhook.

## O que o recurso faz

O mri_Qchat substitui o chat padrão do FiveM por uma interface moderna baseada em React, organizando mensagens em 6 canais com tabs (GLOBAL, LOCAL, OOC, RP, STAFF, ANÚNCIOS), com janela arrastável, emoji picker integrado, autocomplete de comandos, settings persistidos e envio de mensagens para Discord via webhook.

## Funcionalidades principais

- **6 canais com tabs**: GLOBAL, LOCAL, OOC, RP, STAFF, ANÚNCIOS
- **Janela arrastável**: Reposicione o chat via drag and drop com constraints de borda
- **Emoji picker**: Integrado com `emoji-picker-react` (tema dark)
- **Autocomplete de comandos**: Tab-completion para comandos registrados
- **Settings persistidos**: Modo colapsado, timestamps, fade time (localStorage)
- **Tema dinâmico**: Sincroniza com cores do `ox_lib` via convars
- **Discord webhook**: Todas as mensagens enviadas como embeds
- **Evento customizável**: Outros recursos podem ouvir mensagens via evento
- **Cores por canal**: Cada canal com cor única configurável

## Como funciona

1. Jogador carrega e NUI React inicializa com canais e settings salvos
2. Mensagens são enviadas via comandos específicos para cada canal
3. Servidor processa mensagem, envia para destinatários conforme canal
4. Mensagem é exibida via NUI message `ON_MESSAGE`
5. Se configurado, mensagem é enviada ao Discord via webhook como embed

## Configurações disponíveis (shared/config.lua)

### Opções gerais
| Opção | Padrão | Descrição |
|-------|---------|-----------|
| `Config.LocalDistance` | `20.0` | Distância máxima do chat local |
| `Config.ShowID` | `true` | Mostrar ID do jogador no nome `[ID] Nome` |
| `Config.DiscordWebhook` | `""` | URL do Discord webhook (vazio = desabilitado) |
| `Config.EnableCustomEvent` | `true` | Habilitar evento custom para outros recursos |
| `Config.CustomEventName` | `"mri_Qchat:server:onMessage"` | Nome do evento custom |
| `Config.SyncWithOx` | `true` | Sincronizar tema com ox_lib convars |
| `Config.UIPrimaryColor` | `"#7BF906"` | Cor primária da UI (neon green) |

### Comandos configuráveis
| Config | Padrão | Descrição |
|--------|---------|-----------|
| `Config.Commands.global` | `'g'` | Chat global (`/g`) |
| `Config.Commands.localChat` | `'l'` | Chat local (`/l`) |
| `Config.Commands.ooc` | `'ooc'` | Chat OOC (`/ooc`) |
| `Config.Commands.me` | `'me'` | Ação RP (`/me`) |
| `Config.Commands.doCmd` | `'do'` | Descrição RP (`/do`) |
| `Config.Commands.staff` | `'staffc'` | Chat staff (`/staffc`) |
| `Config.Commands.anuncio` | `'anuncioc'` | Anúncios admin (`/anuncioc`) |
| `Config.Commands.clear` | `'limpar'` | Limpar chat (`/limpar`) |

### Cores dos canais
| Canal | Cor | HEX |
|-------|------|-----|
| GLOBAL | Roxo neon | `#9406f9` |
| LOCAL | Branco | `#ffffff` |
| STAFF | Vermelho | `#ff0000` |
| ANÚNCIOS | Dourado | `#ffd700` |
| OOC | Ciano | `#00ffff` |
| RP | Magenta | `#ff00ff` |

## Convars

| Convar | Tipo | Descrição |
|--------|------|-----------|
| `ox:primaryColor` | string | Cor Mantine ou hex |
| `ox:primaryShade` | int | Nível de shade 0-9 |
| `chat:uiColor` | string | Override da cor primária da UI |
| `chat:globalColor` | string | Override cor do canal global |
| `chat:localColor` | string | Override cor do canal local |
| `chat:oocColor` | string | Override cor do canal OOC |
| `chat:rpColor` | string | Override cor do canal RP |
| `chat:staffColor` | string | Override cor do canal staff |
| `chat:anunciosColor` | string | Override cor do canal anúncios |

Exemplo no `server.cfg`:
```
set chat:uiColor "#ff5500"
set chat:globalColor "blue.6"
set ox:primaryColor "green"
set ox:primaryShade 7
```

## Canais de Chat

| Canal | Comando | Descrição | Permissão |
|-------|---------|-----------|-----------|
| GLOBAL | `/g <msg>` | Mensagem para todos | Todos |
| LOCAL | `/l <msg>` | Mensagem por proximidade (20m) | Todos |
| OOC | `/ooc <msg>` | Out-of-character global | Todos |
| RP | `/me <msg>` | Ação roleplay (próximo) | Todos |
| RP | `/do <msg>` | Descrição roleplay (próximo) | Todos |
| STAFF | `/staffc <msg>` | Chat exclusivo staff | admin/god |
| ANÚNCIOS | `/anuncioc <msg>` | Anúncio global | admin/god |

**Chat padrão** (sem comando): Roteado para chat local por proximidade.

## Settings da UI

| Setting | Descrição |
|---------|-----------|
| **Always Collapsed** | Chat sempre colapsado (expand on hover) |
| **Show Time** | Mostrar timestamps nas mensagens |
| **Fade Time** | Tempo para fade automático (1-30s, padrão 15s) |

## Eventos

### Custom Event (configurável)
Outros recursos podem ouvir mensagens de chat:
```lua
AddEventHandler('mri_Qchat:server:onMessage', function(data)
    -- data: { source, author, message, channel, timestamp }
end)
```

### NUI Messages (Server → Client)
| Type | Descrição |
|------|-----------|
| `ON_MESSAGE` | Nova mensagem |
| `ON_SUGGESTION_ADD` | Adicionar suggestion |
| `ON_SUGGESTION_REMOVE` | Remover suggestion |
| `ON_CLEAR` | Limpar chat |
| `ON_UPDATE_THEME` | Atualizar tema |
| `ON_SCREEN_STATE_CHANGE` | Hide/show (pause menu) |

### NUI Callbacks
| Callback | Descrição |
|----------|-----------|
| `chatResult` | Resultado do input do usuário |
| `loaded` | NUI carregada |

## Integração com outros recursos MRI

### Obrigatórias
- `qbx_core` — Nomes de personagens, permissões staff

### Opcionais
- `ox_lib` — Sincronização de tema via convars

### Evento customizado
Outros recursos podem consumir mensagens via `mri_Qchat:server:onMessage`:
```lua
AddEventHandler('mri_Qchat:server:onMessage', function(data)
    local src = data.source
    local author = data.author
    local message = data.message
    local channel = data.channel
    local timestamp = data.timestamp
    -- processar mensagem
end)
```

## Exemplos práticos

### Enviar mensagem via evento server
```lua
TriggerClientEvent('mri_Qchat:client:ON_MESSAGE', -1, {
    channel = 'ANÚNCIOS',
    author = 'Sistema',
    message = 'Bem-vindos ao servidor!',
    timestamp = os.time()
})
```

### Escutar mensagens para filtragem/moderação
```lua
AddEventHandler('mri_Qchat:server:onMessage', function(data)
    if string.find(string.lower(data.message), "palavrao") then
        -- punir jogador
        DropPlayer(data.source, "Linguagem inapropriada")
    end
end)
```

### Configurar webhook Discord
```lua
Config.DiscordWebhook = "https://discord.com/api/webhooks/..."
```

## Solução de problemas

- **Chat não aparece**: Verifique se o recurso iniciou e NUI carregou (callback `loaded`)
- **Tema não sincroniza**: Confirme `Config.SyncWithOx = true` e convars do ox_lib definidas
- **Discord webhook não envia**: Verifique se a URL está correta e o Discord aceita a conexão
- **Janela não arrasta**: Constraints de borda impedem sair da tela
- **Comandos não completam**: Suggestions atualizados no `chat:init` e resource start
- **Settings não persistem**: Salvos em `localStorage` do navegador do jogador
- **Chat padrão não funciona**: Sem comando, envia para canal LOCAL por proximidade (20m)
