# mri_Qchat — Manual

Substituto do chat padrão do FiveM com UI em React, canais separados (global, local, OOC, RP, staff, anúncios) e log opcional no Discord.

---

## Sumário

1. [Dependências](#dependências)
2. [Instalação](#instalação)
3. [Configuração](#configuração)
4. [Comandos](#comandos)
5. [Canais e cores](#canais-e-cores)
6. [Cor de destaque](#cor-de-destaque)
7. [Log e evento de mensagens](#log-e-evento-de-mensagens)
8. [Entrypoints para outros recursos](#entrypoints-para-outros-recursos)
9. [Build da UI](#build-da-ui)
10. [Estrutura de arquivos](#estrutura-de-arquivos)

---

## Dependências

| Recurso | Obrigatório | Observação |
|---|---|---|
| `qbx_core` | Sim | Nome do personagem (`GetPlayer`) e permissão de staff (`HasPermission`) |

O recurso não usa `ox_lib` nem banco de dados.

---

## Instalação

1. Copie a pasta `mri_Qchat` para `resources/`.
2. Adicione ao `server.cfg`:
   ```
   ensure mri_Qchat
   ```
3. **Remova ou desabilite o recurso `chat` padrão do cfx-server-data** — os dois declaram `ui_page` e registram os mesmos eventos (`chat:addMessage`, `chat:addSuggestion`, `chat:clear`, `_chat:messageEntered`) e não podem rodar juntos.
4. Opcional: defina a cor de destaque e o webhook de log (veja [Configuração](#configuração)).

---

## Configuração

Arquivo: `shared/config.lua`.

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `Config.LocalDistance` | number | Sim | Raio em metros do chat local (`/l`, `/me`, `/do` e mensagens sem comando) |
| `Config.ShowID` | bool | Sim | Prefixa o autor com o server id (`[12] João Silva`) |
| `Config.DiscordWebhook` | string | Não | URL do webhook do Discord. Vazio desativa o log |
| `Config.EnableCustomEvent` | bool | Sim | Dispara um evento de servidor a cada mensagem |
| `Config.CustomEventName` | string | Sim | Nome do evento disparado. Padrão: `mri_Qchat:server:onMessage` |
| `Config.Debug` | bool | Sim | Prints de diagnóstico no console do client (abertura do chat, foco NUI) |
| `Config.Commands.global` | string | Sim | Nome do comando de chat global. Padrão: `g` |
| `Config.Commands.localChat` | string | Sim | Nome do comando de chat local. Padrão: `l` |
| `Config.Commands.ooc` | string | Sim | Nome do comando OOC. Padrão: `ooc` |
| `Config.Commands.me` | string | Sim | Nome do comando de ação RP. Padrão: `me` |
| `Config.Commands.doCmd` | string | Sim | Nome do comando de descrição RP. Padrão: `do` |
| `Config.Commands.staff` | string | Sim | Nome do comando de chat da staff. Padrão: `staffc` |
| `Config.Commands.anuncio` | string | Sim | Nome do comando de anúncio. Padrão: `anuncioc` |
| `Config.Commands.clear` | string | Sim | Nome do comando de limpar o chat. Padrão: `limpar` |
| `Config.UIPrimaryColor` | string hex | Sim | Cor de destaque da UI. Lida da convar `mri:color`, com fallback `#00E699` |
| `Config.Colors` | tabela | Sim | Cor hex por canal. Convertida para RGB em runtime por `shared/sh_utils.lua` |

---

## Comandos

| Comando | Permissão | Descrição |
|---|---|---|
| `/g <msg>` | Todos | Mensagem para todos os jogadores |
| `/l <msg>` | Todos | Mensagem por proximidade (`Config.LocalDistance`) |
| `/ooc <msg>` | Todos | Mensagem global fora de personagem, prefixada com `[OOC]` |
| `/me <msg>` | Todos | Ação de RP por proximidade, prefixada com `[ME]` |
| `/do <msg>` | Todos | Descrição de RP por proximidade, prefixada com `[DO]` |
| `/staffc <msg>` | `admin` ou `god` (qbx_core) | Mensagem visível apenas para quem também é staff |
| `/anuncioc <msg>` | `admin` ou `god` (qbx_core) | Anúncio global, assinado como `ANÚNCIO` |
| `/limpar` | Todos | Limpa o chat do próprio jogador (só client, não apaga o de ninguém mais) |
| `/debugchatadmin` | Todos | Alterna localmente a exibição das mensagens de `__cfx_internal:serverPrint` no chat |

Digitar sem barra envia a mensagem para o canal **LOCAL**, respeitando o raio de `Config.LocalDistance`.

A permissão de staff é resolvida por `exports.qbx_core:HasPermission(source, 'admin')` ou `'god'` — o console (`source == 0`) sempre passa. As sugestões de comando exibidas no autocomplete são filtradas por `IsPlayerAceAllowed(player, 'command.<nome>')`, ou seja, cada jogador só vê os comandos que pode executar.

---

## Canais e cores

| Canal | Origem | Cor padrão |
|---|---|---|
| `GLOBAL` | `/g` | `#9406f9` |
| `LOCAL` | `/l` e mensagens sem comando | `#ffffff` |
| `STAFF` | `/staffc` | `#ff0000` |
| `ANUNCIOS` | `/anuncioc` | `#ffd700` |
| `OOC` | `/ooc` | `#00ffff` |
| `RP` | `/me` e `/do` | `#ff00ff` |

Essa paleta é independente da cor de destaque da UI: ela colore a mensagem, não a interface.

---

## Cor de destaque

A cor de destaque da UI (bordas, botões, ícones) vem da convar global `mri:color`, compartilhada com o resto da suite MRI:

```
setr mri:color "#00E699"
```

Se a convar não estiver definida, o fallback é `#00E699`. Mudanças em runtime são detectadas por `AddConvarChangeListener` no servidor: a nova cor é validada (`#RRGGBB`) e propagada imediatamente para todos os clientes via `mri_Qchat:client:accentColorChanged`, sem restart.

---

## Log e evento de mensagens

Toda mensagem que passa pelos comandos do recurso aciona duas saídas opcionais:

- **Evento de servidor** — se `Config.EnableCustomEvent` for `true`, o evento nomeado em `Config.CustomEventName` é disparado com `{ source, author, message, channel, timestamp }`. O `channel` recebe `RP_ME` e `RP_DO` para `/me` e `/do` (mais específico que o canal `RP` usado na cor).
- **Webhook do Discord** — se `Config.DiscordWebhook` estiver preenchido, um embed com autor, mensagem, canal e source id é enviado via `PerformHttpRequest`.

---

## Entrypoints para outros recursos

### Enviar mensagem para o chat

O recurso implementa os eventos padrão do chat do FiveM, então qualquer código já escrito para o `chat` original funciona:

```lua
TriggerClientEvent('chat:addMessage', source, {
    channel = 'ANUNCIOS',
    args = { 'Sistema', 'Manutenção em 10 minutos.' },
    color = { 255, 215, 0 }
})

TriggerClientEvent('chat:clear', source)
TriggerClientEvent('chat:addSuggestion', source, '/meucomando', 'Descrição', {})
TriggerClientEvent('chat:removeSuggestion', source, '/meucomando')
```

O evento legacy `chatMessage(author, color, text)` também é aceito no client.

### Consumir as mensagens (moderação, logs, tradução)

```lua
AddEventHandler('mri_Qchat:server:onMessage', function(data)
    -- data.source, data.author, data.message, data.channel, data.timestamp
end)
```

Renomeie o evento em `Config.CustomEventName` se precisar de outro nome.

### Trocar a cor de destaque em runtime

```lua
SetConvarReplicated('mri:color', '#FF5500')
```

O listener do `mri_Qchat` aplica a cor em todos os clientes na hora.

---

## Build da UI

A interface fica em `web/` (React + Vite + Tailwind) e o bundle compilado em `html/`, que é o que o `fxmanifest.lua` carrega. Para alterar a UI, edite `web/src/` e gere um novo build; sem rebuild, mudanças no código-fonte não aparecem no jogo.

---

## Estrutura de arquivos

```
mri_Qchat/
├── client/
│   └── cl_chat.lua       — ponte NUI, foco do input, hide no pause/fade, comando /limpar
├── server/
│   └── sv_chat.lua       — comandos de canal, proximidade, sugestões, webhook, evento custom
├── shared/
│   ├── config.lua        — toda a configuração
│   └── sh_utils.lua      — conversão hex -> RGB das cores de canal
├── html/
│   ├── index.html        — UI compilada (carregada pelo fxmanifest)
│   └── assets/           — JS, CSS e imagem do build
├── web/                  — código-fonte React da UI (Vite + Tailwind)
│   ├── src/
│   │   ├── App.tsx
│   │   ├── components/Chat/
│   │   │   ├── ChatWindow.tsx    — janela arrastável e lista de mensagens
│   │   │   ├── InputBox.tsx      — input, autocomplete de comandos
│   │   │   ├── Message.tsx       — render de uma mensagem
│   │   │   ├── SettingsPanel.tsx — preferências do jogador
│   │   │   ├── Tabs.tsx          — abas de canal
│   │   │   └── TopBar.tsx        — barra superior
│   │   ├── hooks/useNuiEvent.ts
│   │   ├── lib/accentColor.ts    — aplica a cor de destaque recebida do client
│   │   └── utils/                — fetchNui, debugData, misc
│   └── vite.config.ts
└── fxmanifest.lua
```
