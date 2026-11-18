# Como conectar o Donnar à sua IA

O Donnar usa **MCP (Model Context Protocol)** com **OAuth 2.1**. Na maioria dos aplicativos, basta informar o endereço e fazer login — sem cadastrar chave, sem copiar token.

- **Endereço do MCP:** `https://mcp.donnar.app/start`
- **Página de conexões:** https://dash.donnar.app/ia
- **Pré-requisitos:** conta no Donnar e vínculo ativo com uma organização (Administração ou Liderança).

---

## Claude

### Opção A — conector oficial (recomendado)

1. Acesse https://claude.ai/directory/donnar-app.
2. Clique em **Conectar**.
3. Faça login no Donnar e escolha a organização e o escopo.
4. Autorize. O Claude passa a listar as ferramentas do Donnar.

### Opção B — conector personalizado

1. No Claude, abra **Configurações › Conectores**.
2. Clique em **Adicionar conector personalizado**.
3. Informe o nome `Donnar` e a URL `https://mcp.donnar.app/start`.
4. Clique em **Conectar** e conclua o login no Donnar.

> O Claude faz o registro do cliente e o PKCE sozinho. Não é preciso configurar client ID ou secret.

---

## ChatGPT

O conector do Donnar está em aprovação no diretório do ChatGPT. Enquanto isso, use o modo de desenvolvedor:

1. No ChatGPT, abra **Configurações › Aplicativos**.
2. Ative o **modo de desenvolvedor**.
3. Crie um aplicativo/conector com:
   - **URL do MCP:** `https://mcp.donnar.app/start`
   - **Autenticação:** OAuth
4. Na primeira chamada, o ChatGPT abre a tela de autorização do Donnar.
5. Faça login, escolha a organização e o escopo e autorize.

> Se o ChatGPT pedir escopos, use `leitura` e `escrita`. O Donnar aceita os dois.

---

## Claude Code

No terminal:

```bash
claude mcp add --transport http donnar https://mcp.donnar.app/start
```

Depois:

1. Abra o Claude Code.
2. Rode `/mcp` e escolha `donnar`.
3. Autentique no navegador.
4. Peça: “Mostre o contexto da conexão do Donnar.”

Para deixar a configuração no projeto, use o `.mcp.json` deste repositório:

```json
{
  "mcpServers": {
    "donnar": {
      "type": "streamable-http",
      "url": "https://mcp.donnar.app/start"
    }
  }
}
```

---

## Cursor

Crie `.cursor/mcp.json` na raiz do projeto:

```json
{
  "mcpServers": {
    "donnar": {
      "url": "https://mcp.donnar.app/start"
    }
  }
}
```

Reinicie o Cursor e abra a aba **MCP**. Clique em **Connect** no servidor `donnar` e conclua o login no Donnar.

O exemplo pronto está em [`../../exemplos/cursor.mcp.json`](../../exemplos/cursor.mcp.json).

---

## Outros aplicativos MCP

Qualquer cliente que suporte **Streamable HTTP + OAuth 2.1** pode conectar:

- **URL:** `https://mcp.donnar.app/start`
- **Auth:** OAuth com Dynamic Client Registration
- **Escopos:** `leitura` e/ou `escrita`
- **Redirect:** `https://…` exato ou loopback (`http://localhost:…` / `http://127.0.0.1:…`)

Exemplos de clientes: Claude Desktop (via conector remoto), VS Code com extensão MCP, Cline, Continue, Zed e agentes próprios.

### Se o cliente não fizer OAuth

Use o **token manual**:

1. Abra https://dash.donnar.app/ia.
2. Escolha **Só consultar** ou **Consultar e alterar**.
3. Gere a chave e copie na hora — ela não aparece de novo.
4. Configure o cliente com:

```http
Authorization: Bearer dmcp_...
```

ou use a URL:

```text
https://mcp.donnar.app/mcp/dmcp_...
```

> O modo manual pode ser desligado pelo operador (`MCP_SOMENTE_OFICIAL=true`). Nesse caso, só o OAuth funciona.

---

## Escolher o escopo

| Escopo | A IA pode | Quando usar |
|---|---|---|
| **Leitura** | Consultar ministérios, eventos, escalas, disponibilidade, visitantes e relatórios. | Análises, relatórios e conversas sem alteração. |
| **Escrita** | Tudo de leitura + criar/editar eventos, montar/ajustar/publicar escalas, avisar voluntários e excluir escalas (Administração). | Operação do dia a dia. |

Você pode mudar de ideia depois: desconecte e conecte de novo com outro escopo.

---

## Permissões por nível

| | Administração | Liderança |
|---|---|---|
| Consultar | organização inteira | só ministérios vinculados |
| Montar/ajustar/publicar escalas | sim, com escrita | sim, nos próprios ministérios |
| Criar/editar cultos e eventos | sim, com escrita | não |
| Excluir escala | sim, com escrita + confirmação | não |
| Notificar voluntários | sim, com escrita + confirmação | sim, nos próprios ministérios + confirmação |

> O nível é lido do banco a cada chamada. Se o vínculo com a organização cair, a conexão para de funcionar sozinha.

---

## Confirmar ações sensíveis

`notificar_escala` e `excluir_escala` nunca executam na primeira chamada.

1. A IA mostra um resumo e recebe um código.
2. Você aprova (ou não).
3. Só então a IA repete a chamada com o código.

Se o código expirar (10 minutos), peça para a IA gerar outro.

---

## Desconectar e revogar

1. Abra https://dash.donnar.app/ia.
2. Em **Conectados**, encontre o aplicativo.
3. Clique em **Desconectar**.

O acesso é revogado na hora. Para usar de novo, repita o login.

Também é possível revogar via OAuth:

```bash
curl -s -X POST https://mcp.donnar.app/oauth/revoke \
  -H 'content-type: application/json' \
  -d '{"token":"SEU_TOKEN"}'
```

---

## Problemas comuns

| Sintoma | Causa provável | O que fazer |
|---|---|---|
| `401` / “Conexão necessária” | Sem token, token expirado ou revogado | Refaça o login no aplicativo ou gere nova chave na página IA. |
| Só aparece `donnar_como_conectar` | A conexão não foi concluída | Finalize o OAuth; confira se escolheu a organização. |
| “Origem não permitida” | Origem de navegador fora da lista | Use o cliente oficial ou configure `MCP_ORIGENS_PERMITIDAS` no servidor. |
| “Esta conexão é somente leitura” | Escopo `leitura` | Reconecte escolhendo **Consultar e alterar**. |
| “Somente a Administração…” | Nível Liderança | Peça a um administrador ou use uma conta de Administração. |
| “Organização bloqueada ou sem plano” | Assinatura/plano inativo | Regularize o plano da organização. |
| `405 Method Not Allowed` | Cliente usando GET/DELETE | Use `POST` (Streamable HTTP sem sessão). |
| “Muitas solicitações” | Limite de 60/min, 1.500/h ou 20 escritas/min | Aguarde um minuto e tente de novo. |
| “Código de confirmação inválido” | Expirou ou foi gerado para outro alvo | Chame a ferramenta sem `confirmacao` para gerar outro. |
| Claude/ChatGPT não lista ferramentas | URL errada ou rede bloqueada | Confira `https://mcp.donnar.app/start` e libere o tráfego da Anthropic/OpenAI. |

### Teste rápido do servidor

```bash
curl -s https://mcp.donnar.app/start \
  -H 'content-type: application/json' \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'
```

Sem token, a resposta lista o catálogo de ferramentas (sem dados). Se isso funcionar, o servidor está no ar.

---

## Ajuda

- Página IA: https://dash.donnar.app/ia
- Suporte: https://donnar.app/suporte/
- Referência técnica: [../mcp.md](../mcp.md)
- Catálogo de ferramentas: [../ferramentas.md](../ferramentas.md)
