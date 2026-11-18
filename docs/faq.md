# Perguntas frequentes

## Sobre o Donnar

**O que é o Donnar?**
Sistema de gestão de igreja para organizar ministérios, voluntários, escalas, cultos e eventos, visitantes, batismos, certificados, financeiro e relatórios — com notificação automática por WhatsApp.

**Para quem é?**
Pastores, liderança, coordenadores de ministérios, voluntários, recepção, secretaria e tesouraria. Igrejas de diferentes tamanhos, em português e no Brasil.

**Quanto custa?**
- **Gratuito:** R$ 0/mês, até 60 voluntários.
- **Essencial:** R$ 59/mês, até 150 voluntários.
- **Pro:** R$ 99/mês, até 1.000 voluntários.

**O plano gratuito pede cartão?**
Não. O cadastro é gratuito, sem cartão de crédito.

**As notificações de WhatsApp são pagas?**
Não. Notificações de escala por app e WhatsApp são gratuitas e ilimitadas em todos os planos. Número de WhatsApp próprio e envio/agendamento em grupos fazem parte dos planos pagos.

**Tem plano anual?**
Ainda não. A cobrança é mensal; o plano anual está em breve.

**Preciso instalar algo?**
Para a plataforma, não: é web. O voluntário pode usar o app. Para a integração com IA, basta conectar o aplicativo (Claude, ChatGPT etc.) ao endereço do MCP.

**A igreja precisa ter site ou equipe técnica?**
Não. O cadastro é guiado e a integração com IA é feita por login OAuth.

**Como começar?**
Crie a conta em https://dash.donnar.app. Depois cadastre a igreja, os ministérios, convide os voluntários e monte a primeira escala.

**Como migrar da planilha?**
Cadastre os ministérios e cultos recorrentes, convide a equipe e monte a próxima escala. O histórico antigo é opcional; o importante é começar pela escala seguinte. Veja [comparativo.md](comparativo.md).

---

## Sobre o MCP e a IA

**O que é MCP?**
Model Context Protocol: um padrão aberto que permite que assistentes de IA (Claude, ChatGPT, Cursor) consultem e alterem dados de um sistema com segurança. O Donnar tem um servidor MCP oficial.

**Qual é o endereço do MCP?**
`https://mcp.donnar.app/start`

**O MCP é oficial?**
Sim. É mantido pelo Donnar, documentado neste repositório e usa OAuth 2.1 com registro dinâmico de cliente, PKCE e tokens com hash no banco.

**Como conectar no Claude?**
Pelo conector oficial em https://claude.ai/directory/donnar-app ou por um conector personalizado com a URL do MCP. Veja [guias/conexao.md](guias/conexao.md).

**Como conectar no ChatGPT?**
Enquanto o conector está em aprovação no diretório, use o modo de desenvolvedor: Configurações › Aplicativos › criar app com a URL do MCP e autenticação OAuth.

**Funciona no Claude Code e no Cursor?**
Sim. Claude Code: `claude mcp add --transport http donnar https://mcp.donnar.app/start`. Cursor: use o exemplo em [`../exemplos/cursor.mcp.json`](../exemplos/cursor.mcp.json).

**A IA pode alterar dados?**
Só se a conexão tiver escopo `escrita` e o usuário tiver nível adequado. O escopo `leitura` nunca altera nada. Criar/editar cultos e excluir escalas exigem Administração.

**A IA vê telefone, e-mail ou documento dos voluntários?**
Não. O MCP nunca devolve contato, documento, ano de nascimento/idade, foto, endereço, gênero, estado civil, respostas de formulário ou motivo de indisponibilidade.

**O que a IA vê das pessoas?**
Apenas `id` e `nome`. Aniversariantes aparecem somente com dia e mês.

**Como funciona a confirmação em duas etapas?**
`notificar_escala` e `excluir_escala` devolvem primeiro um resumo e um código válido por 10 minutos. Nada é executado até o usuário aprovar e a IA repetir a chamada com o código.

**Quem pode usar o MCP?**
Usuários com vínculo ativo com a organização, nos níveis Administração ou Liderança. Liderança acessa apenas os ministérios vinculados. Super admin sem vínculo não gera conexão.

**Como revogar o acesso?**
Abra https://dash.donnar.app/ia, encontre o aplicativo em **Conectados** e clique em **Desconectar**. O acesso cai na hora.

**O que acontece se o plano vencer ou a organização for bloqueada?**
A conexão para de funcionar sozinha. A resposta do MCP informa o motivo e as instruções de conexão, sem devolver dados.

**Existe limite de uso?**
Sim: 60 chamadas/minuto, 1.500/hora e 20 escritas/minuto por conexão.

**Posso usar só leitura para relatórios?**
Sim. É o modo recomendado para análises e conversas que não devem alterar nada.

**O MCP substitui a plataforma?**
Não. Ele é uma interface para IA sobre os mesmos dados e permissões. A plataforma web continua sendo o lugar para configurações, financeiro, certificados e tarefas que o MCP não cobre.

**O financeiro está no MCP?**
Não. Lançamentos e relatórios financeiros são feitos no módulo **Financeiro** da plataforma.

**A IA pode inventar dados?**
Ela não deve. As instruções do servidor pedem para usar apenas o que as ferramentas devolvem. Ainda assim, revise nomes, datas e resumos antes de aprovar qualquer ação.

**O que é `donnar_contexto`?**
A primeira ferramenta a ser chamada. Mostra organização, nível, escopo, alcance e ministérios disponíveis.

**Onde encontro todas as ferramentas?**
Em [ferramentas.md](ferramentas.md), com campos de entrada e permissões.

**O Donnar tem WebMCP no site?**
O site expõe ações básicas via WebMCP quando o navegador suporta a API (planos, link de cadastro e suporte). O MCP oficial, com dados da igreja, é o `https://mcp.donnar.app/start`.

---

## Suporte e privacidade

**Onde falar com o suporte?**
https://donnar.app/suporte/ ou suporte@donnar.app

**Onde está a política de privacidade?**
https://donnar.app/politica-privacidade/

**Como reportar uma vulnerabilidade?**
Veja [SECURITY.md](../SECURITY.md). Não abra issue pública com detalhes sensíveis.

**Posso contribuir com o repositório?**
Sim. Veja [CONTRIBUTING.md](../CONTRIBUTING.md). Nunca envie dados reais de igrejas, voluntários ou visitantes.
