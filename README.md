# mri_Qchat — Manual

Chat moderno para FiveM (QBox/QBCore) com NUI em React + `@mriqbox/ui-kit`.
Comandos de roleplay, chat de staff, anúncios, logs no Discord e tematização
sincronizada com a suite MRI.

---

## Sumário

1. [Dependências](#dependências)
2. [Instalação](#instalação)
3. [Comandos](#comandos)
4. [Configuração (`shared/config.lua`)](#configuração-sharedconfiglua)
5. [Cor de destaque](#cor-de-destaque)
6. [Cores por canal](#cores-por-canal)
7. [Logs e integração](#logs-e-integração)
8. [Permissões de staff](#permissões-de-staff)
9. [Estrutura de arquivos](#estrutura-de-arquivos)

---

## Dependências

| Recurso | Obrigatório | Observação |
|---|---|---|
| `qbx_core` | Sim | Permissões de staff (`/staffc`, `/anuncioc`) |
| `ox_lib` | Não | Sincronização automática da cor do tema |

---

## Instalação

1. Copie a pasta `mri_Qchat` para `resources/`.
2. Adicione ao `server.cfg`:
   ```
   ensure mri_Qchat
   ```
3. Desative o chat nativo/legado do seu framework para evitar conflito de comandos.

---

## Comandos

| Comando | Descrição |
|---|---|
| `/g [msg]` | Chat global |
| `/l [msg]` | Chat local (por distância — `Config.LocalDistance`) |
| `/ooc [msg]` | Fora do personagem |
| `/me [ação]` | Ação do personagem |
| `/do [estado]` | Descrição de ambiente |
| `/staffc [msg]` | Chat da staff (admin+) |
| `/anuncioc [msg]` | Anúncio global (admin+) |
| `/limpar` | Limpa o histórico do chat local |

Os nomes dos comandos são customizáveis em `Config.Commands`.

---

## Configuração (`shared/config.lua`)

| Opção | Padrão | Descrição |
|---|---|---|
| `Config.LocalDistance` | `20.0` | Distância máxima (m) para ouvir o chat local (`/l`) |
| `Config.ShowID` | `true` | Exibe o ID do jogador antes do nome (ex.: `[12] João`) |
| `Config.DiscordWebhook` | `""` | URL do webhook do Discord (vazio desativa) |
| `Config.EnableCustomEvent` | `true` | Dispara evento de servidor a cada mensagem |
| `Config.CustomEventName` | `mri_Qchat:server:onMessage` | Nome do evento disparado |
| `Config.Debug` | `false` | Prints de debug no console |
| `Config.Commands` | *(tabela)* | Renomeia os comandos do chat |

---

## Cor de destaque

A cor de destaque da UI (bordas, botões, ícones) lê primeiro a convar global
`mri:color`, compartilhada com toda a suite MRI (`mri_Qmultichar`, `mri_Qspawn`,
`mri_Qadmin`, `mri_Qloadscreen`). Defina com:

```
setr mri:color "#00E699"
```

ou pelo painel do `mri_Qadmin`. Se a convar não estiver setada, cai no fallback
`Config.UIPrimaryColor`. A troca em runtime é propagada automaticamente para a NUI.

---

## Cores por canal

Paleta independente da cor de destaque, em `Config.Colors`:

| Canal | Padrão |
|---|---|
| `GLOBAL` | `#9406f9` (roxo neon) |
| `LOCAL` | `#ffffff` (branco) |
| `STAFF` | `#ff0000` (vermelho) |
| `ANUNCIOS` | `#ffd700` (dourado) |
| `OOC` | `#00ffff` (ciano) |
| `RP` | `#ff00ff` (magenta) |

---

## Logs e integração

- **Discord**: preencha `Config.DiscordWebhook` para logar mensagens.
- **Evento custom**: com `Config.EnableCustomEvent = true`, cada mensagem dispara
  `Config.CustomEventName` no servidor, permitindo integração com outros recursos.

---

## Permissões de staff

`/staffc` e `/anuncioc` exigem permissão de administrador via `qbx_core`. Jogadores
sem permissão não conseguem usar esses comandos.

---

## Estrutura de arquivos

```
mri_Qchat/
├── client/cl_chat.lua      # NUI callbacks, triggers, foco
├── server/sv_chat.lua      # comandos, permissões, logs
├── shared/
│   ├── config.lua          # configuração
│   └── sh_utils.lua        # utilitários compartilhados
├── html/                   # build da NUI (gerado — não editar à mão)
└── fxmanifest.lua
```

> A interface é desenvolvida em `web/` (React + Vite) no repositório de fonte
> privado `mri_Qchat-source`. O repositório público recebe apenas o build.

---

Desenvolvido com ❤️ pela **MRI QBox Brasil**.
