# MCP do Donnar — referência técnica

O Donnar expõe um servidor **MCP (Model Context Protocol)** para assistentes de IA. Ele permite consultar e alterar dados da igreja com as mesmas permissões, limites e regras de privacidade da plataforma.

- **Endpoint público:** `https://mcp.donnar.app/start`
- **Endpoint legado:** `https://mcp.donnar.app/mcp` (continua válido para conexões já configuradas)
- **Descoberta OAuth:** `https://mcp.donnar.app/.well-known/oauth-protected-resource`

---

## 1. Transporte e protocolo

| Item | Detalhe |
|---|---|
| Transporte | Streamable HTTP, **sem sessão**, respostas em JSON (não SSE) |
| Métodos HTTP | Somente `POST`. `GET` e `DELETE` respondem `405` com `Allow: POST`. |
| Versões aceitas | `2025-06-18` (padrão), `2025-03-26`, `2024-11-05` |
| JSON-RPC | 2.0. Lotes (arrays) não são suportados. |
| Notificações | Requisições sem `id` respondem `202 Accepted` sem corpo. |
| Tamanho máximo de argumentos | 32 KB |
| Tamanho máximo de resposta | 80 KB (respostas maiores são cortadas com aviso) |

### Métodos implementados

| Método | Comportamento |
|---|---|
| `initialize` | Devolve `protocolVersion`, capabilities de tools e instruções de uso. |
| `ping` | Responde `{}`. |
| `tools/list` | Lista as ferramentas. Sem token, lista o catálogo real (nomes, descrições e schemas), sem dados. |
| `tools/call` | Executa uma ferramenta. Exige conexão autenticada. |
| `resources/list` | Lista vazia. |
| `prompts/list` | Lista vazia. |
| `notifications/*` | Aceito e ignorado (`202`). |
| Qualquer outro | `-32601` (método não encontrado). |

### Exemplo de `initialize`

```bash
curl -s https://mcp.donnar.app/start \
  -H 'content-type: application/json' \
  -H 'accept: application/json, text/event-stream' \
  -d '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "initialize",
    "params": {
      "protocolVersion": "2025-06-18",
      "capabilities": {},
      "clientInfo": { "name": "exemplo", "version": "1.0.0" }
    }
  }'
```

### Exemplo de `tools/list` sem token

```bash
curl -s https://mcp.donnar.app/start \
  -H 'content-type: application/json' \
  -d '{"jsonrpc":"2.0","id":2,"method":"tools/list"}'
```

Sem conexão, `tools/call` responde `401` com `WWW-Authenticate`, e o cliente inicia o login OAuth.

---

## 2. Descoberta OAuth (RFC 9728 / RFC 8414)

Rotas públicas na raiz do domínio do MCP:

| Rota | Conteúdo |
|---|---|
| `GET /.well-known/oauth-protected-resource` | Metadados do recurso protegido (`resource`, authorization server, escopos). |
| `GET /.well-known/oauth-protected-resource/mcp` | Idem, para clientes que sondam o caminho legado. |
| `GET /.well-known/oauth-protected-resource/start` | Idem, para clientes que sondam o caminho oficial. |
| `GET /.well-known/oauth-authorization-server` | Metadados do servidor de autorização (endpoints e capabilities). |
| `GET /.well-known/openai-apps-challenge` | Token de verificação de domínio do OpenAI (quando configurado). |

Resposta sem conexão:

```http
HTTP/1.1 401 Unauthorized
WWW-Authenticate: Bearer resource_metadata="https://mcp.donnar.app/.well-known/oauth-protected-resource", scope="leitura escrita"
```

O corpo segue JSON-RPC:

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "error": {
    "code": -32001,
    "message": "Conexão necessária. Faça login pelo aplicativo ou gere uma conexão em https://dash.donnar.app/ia."
  }
}
```

---

## 3. Fluxo OAuth 2.1 (oficial)

Claude, ChatGPT e Claude Code fazem login sozinhos. O fluxo é:

1. O cliente chama `tools/call` sem token e recebe `401` + `WWW-Authenticate`.
2. Lê `/.well-known/oauth-protected-resource` e `/.well-known/oauth-authorization-server`.
3. Registra-se dinamicamente em `POST /oauth/register` (cliente público, sem secret).
4. Abre `GET /oauth/authorize` com **PKCE S256 obrigatório**.
5. O Donnar redireciona para a tela **`/ia/autorizar`** na plataforma. O usuário logado escolhe a organização e o escopo (leitura ou escrita).
6. O pedido de consentimento é assinado com HMAC e vale **15 minutos**; o front apenas exibe, não altera.
7. `POST /oauth/token` troca o código (uso único, **10 minutos**) por:
   - **access token:** 1 hora
   - **refresh token:** 90 dias, **rotativo**
8. `POST /oauth/revoke` revoga um token (RFC 7009).

### Endpoints

| Endpoint | Método | Observação |
|---|---|---|
| `/oauth/register` | `POST` | Dynamic Client Registration; limite de 20 registros por hora. |
| `/oauth/authorize` | `GET` | Redireciona para a plataforma (`APP_URL/ia/autorizar`). |
| `/oauth/token` | `POST` | Código de uso único; access 1 h + refresh 90 dias rotativo; limite de 120 por 15 min. |
| `/oauth/revoke` | `POST` | Revogação RFC 7009. |

### Redirect URIs aceitas

- `https://…` exato, cadastrado no registro dinâmico.
- Loopback (`http://localhost:…` ou `http://127.0.0.1:…`) com porta livre, para Claude Code e clientes locais.
- Erros antes da validação de `client_id`/`redirect_uri` vão para uma página da plataforma, nunca para o aplicativo.

### O que fica no banco

Somente **hash SHA-256** de access tokens, refresh tokens e códigos de autorização. O valor em claro existe apenas no momento da emissão.

---

## 4. Token manual (clientes sem OAuth)

Para clientes que não implementam o fluxo OAuth:

1. Entre na plataforma e abra **IA** (`/ia`).
2. Escolha o escopo: **Só consultar** (`leitura`) ou **Consultar e alterar** (`escrita`).
3. Gere a chave. Ela aparece **uma única vez** e começa com `dmcp_` (256 bits).
4. Use em um dos formatos:
   - `Authorization: Bearer dmcp_…`
   - `POST https://mcp.donnar.app/mcp/dmcp_…` (token no caminho)

Regras:

- Uma conexão manual por **usuário e organização**. Gerar outra substitui a anterior.
- O token no caminho é redigido em todos os logs.
- `MCP_SOMENTE_OFICIAL=true` desliga o modo manual na hora: tokens manuais e token no caminho param de valer.
- A chave pode ser revogada a qualquer momento na página **IA**.

> Recomendação: use OAuth sempre que o cliente suportar. O token manual é uma compatibilidade, não o modo principal.

---

## 5. Níveis de acesso e escopo

O nível é lido **do banco a cada chamada**, nunca do token. A organização também nunca vem do cliente.

| | Administração | Liderança |
|---|---|---|
| Alcance | organização inteira | só ministérios vinculados (`usuarios_v_ministerios`) |
| Consultar | sim | sim (aniversariantes apenas dos seus ministérios) |
| Montar, ajustar, publicar e avisar escalas | conexão de escrita | conexão de escrita, nos seus ministérios |
| Criar/editar cultos e eventos | conexão de escrita | não |
| Excluir escala | conexão de escrita + confirmação | não |

Regras adicionais:

- **Escopo `leitura`** nunca altera nada, qualquer que seja o nível.
- **Nível desconhecido** cai no mais restrito (`Lideranca`).
- **Super admin sem vínculo** com a organização não gera conexão.
- **Fora do alcance = não encontrado:** um ministério ou escala de outro ministério/organização responde igual a inexistente.
- **Schemas fechados:** `additionalProperties: false`; campo extra é recusado.
- **Referências validadas:** evento da organização, função do ministério, voluntário ativo na equipe do ministério e data dentro do período da escala.

---

## 6. Confirmação em duas etapas

Duas ferramentas nunca executam na primeira chamada:

- `notificar_escala`
- `excluir_escala`

Primeira chamada (sem `confirmacao`): devolve um resumo do que será feito e um código HMAC válido por **10 minutos**, preso à conexão, à ferramenta e ao alvo. Nada é executado.

Segunda chamada (com `confirmacao`): executa. Código inválido ou expirado gera erro e é preciso gerar outro.

O cliente deve mostrar o resumo ao usuário e só confirmar após aprovação explícita.

---

## 7. Limites e concorrência

| Limite | Valor |
|---|---|
| Chamadas por minuto | 60 |
| Chamadas por hora | 1.500 |
| Escritas por minuto | 20 |

- Os limites são por conexão. Com Redis, valem entre instâncias; sem Redis, ficam em memória.
- Alterações de escala são serializadas por escala (`comLock`), evitando que duas escritas simultâneas se sobrescrevam.
- A serialização preserva a confirmação de quem continua na mesma função/culto.

---

## 8. Privacidade

Regra absoluta: **dados pessoais não saem**.

**Nunca são devolvidos:**

- WhatsApp e e-mail
- documento (CPF etc.)
- ano de nascimento e idade
- foto
- endereço
- gênero e estado civil
- respostas de formulário
- motivo de indisponibilidade
- segredos

**Como é garantido:**

1. `apresentar.ts` copia apenas campos permitidos, um a um.
2. `blindagem.ts` remove chaves sensíveis em qualquer profundidade e mascara e-mail/CPF/telefone em textos livres.

Pessoas aparecem somente com `id` e `nome`. Aniversariantes, somente dia e mês.

**Logs:**

- `/mcp/<token>` é redigido no log de requisições, no filtro de erros e no Sentry.
- O nginx do front não registra `/api/mcp`.
- A auditoria `[audit] mcp_*` registra escrita, negação e erro — **nunca os argumentos**.

---

## 9. Erros

| Código | Quando |
|---|---|
| `-32000` | Origem de navegador não permitida; método HTTP não permitido. |
| `-32001` | Conexão necessária, inválida, expirada ou revogada (HTTP `401`). |
| `-32600` | Requisição inválida ou lote não suportado. |
| `-32601` | Método não encontrado. |
| `-32603` | Falha interna inesperada (mensagem genérica, sem detalhes sensíveis). |

Erros de ferramenta voltam como resultado com `isError: true` e uma mensagem amigável em português.

Quando a organização está bloqueada ou sem plano, a resposta é `200` com o motivo e as instruções de conexão — sem dados.

---

## 10. Variáveis de ambiente (operadores)

| Variável | Uso |
|---|---|
| `MCP_PUBLIC_URL` | Endereço público do MCP (`resource` do OAuth). Ex.: `https://mcp.donnar.app/start`. O domínio deve apontar direto para a API, pois os `/.well-known/*` ficam na raiz. |
| `MCP_ISSUER` | Emissor OAuth. Padrão: origem de `MCP_PUBLIC_URL`. |
| `APP_URL` | Origem da plataforma (tela `/ia/autorizar` e página `/ia`). |
| `MCP_SOMENTE_OFICIAL` | `true` desliga tokens manuais e token no caminho. |
| `OPENAI_APPS_CHALLENGE` | Token de verificação de domínio do OpenAI. |
| `MCP_ORIGENS_PERMITIDAS` | Origens de navegador aceitas além de `CORS_ORIGINS`. Sem `Origin`, requisições de servidor são aceitas. |

---

## 11. Catálogo e instruções

- Catálogo completo das 25 ferramentas: [ferramentas.md](ferramentas.md)
- Instruções de conexão por aplicativo: [guias/conexao.md](guias/conexao.md)
- Regras para agentes: [../AGENTS.md](../AGENTS.md)
- `llms.txt` do produto: https://donnar.app/llms.txt

Toda ferramenta declara `title`, `readOnlyHint`, `destructiveHint`, `idempotentHint` e `openWorldHint`, além do `securitySchemes` OAuth exigido por clientes como o ChatGPT.
