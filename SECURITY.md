# Segurança

## Como reportar

Se você encontrou uma vulnerabilidade no Donnar, no servidor MCP ou neste repositório, **não abra uma issue pública**.

Envie um e-mail para **suporte@donnar.app** com o assunto `[SECURITY] Donnar — resumo do problema` e inclua:

- descrição do problema e impacto;
- passos para reproduzir;
- versão/endpoint afetado;
- provas de conceito, se houver;
- como você prefere ser contatado.

Não envie dados reais de igrejas, voluntários ou visitantes. Use uma organização de teste com dados fictícios.

## Escopo

- Servidor MCP: `https://mcp.donnar.app/start`
- Endpoints OAuth: `/oauth/register`, `/oauth/authorize`, `/oauth/token`, `/oauth/revoke`
- Descoberta: `/.well-known/oauth-protected-resource`, `/.well-known/oauth-authorization-server`
- Página IA e tela de consentimento: `https://dash.donnar.app/ia` e `/ia/autorizar`
- Este repositório de documentação

## Fora de escopo

- Ataques de força bruta ou negação de serviço contra a infraestrutura.
- Engenharia social contra usuários ou equipe.
- Testes em contas ou organizações de terceiros sem autorização.
- Vulnerabilidades em dependências sem impacto demonstrável no Donnar.
- Relatos sem passos de reprodução.

## Compromissos

- Investigamos relatos de boa-fé e respondemos assim que possível.
- Não tomamos medidas legais contra pesquisadores que ajam de boa-fé, dentro do escopo e sem expor dados de terceiros.
- Pedimos que você não divulgue detalhes publicamente antes de uma correção.

## Práticas do produto

- OAuth 2.1 com PKCE S256 e Dynamic Client Registration.
- Tokens armazenados apenas como hash SHA-256.
- Permissões lidas do banco a cada chamada.
- Schemas fechados e validação estrita de entrada.
- Limites de uso por conexão.
- Confirmação em duas etapas para ações destrutivas.
- Dados pessoais nunca são enviados à IA.
- Logs e auditoria não registram argumentos sensíveis.

Detalhes: [docs/mcp.md](docs/mcp.md) e https://donnar.app/politica-privacidade/
