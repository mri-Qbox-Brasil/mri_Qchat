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
| `ox_lib` | Sim | Tema da suíte (`/adminui`) e `lib.callback` |

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

## Tema da suíte

A NUI segue o tema da suíte MRI pelo `@mriqbox/ui-kit` (guia: `THEMING.md` do kit),
junto com ox_lib, ox_inventory e mri_Qadmin, sem restart:

| O que | De onde vem | Atualiza ao vivo por |
|---|---|---|
| Cor de destaque | convar `mri:color` | `mri_Qchat:client:accentColorChanged` |
| Cor de fundo | convar `mri:backgroundColor` (vazio = padrão da suíte) | `mri_Qchat:client:backgroundColorChanged` |
| Tema dark/glass, opacidade, fonte, radius, cores de status, overrides de cor | `/adminui` do ox_lib (`ox_lib:getUiConfig`) | `ox_lib:uiConfigChanged` |

```
setr mri:color "#00E699"
```

A janela do chat, a caixa de digitação, a lista de sugestões e o painel de
configurações são superfícies do glass (`mri-surface`). O painel de
configurações fica quase opaco pra não misturar com o chat por baixo. As cores das
mensagens (códigos `^1`, cores por canal) são conteúdo e não seguem o tema.

---

## Canais na interface

O canal aparece como etiqueta ao lado do nome, tirada do campo `channel` da
mensagem ou do prefixo `[X]` do autor (prefixo numérico, do `Config.ShowID`,
vira `#id`). As cores seguem o tema: `STAFF` na cor de erro, `ANÚNCIO` na de
aviso, `OOC` neutra e os demais na cor de destaque. `GLOBAL` não tem etiqueta.

`Config.Colors` continua indo no evento `chat:addMessage` (pra quem ouvir de
fora), mas a interface não usa mais essas cores.

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
