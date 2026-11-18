# Prompts prontos

Copie, ajuste os nomes/datas e cole no Claude, ChatGPT, Cursor ou outro assistente conectado ao Donnar. Os prompts funcionam melhor quando o Donnar já está conectado via MCP.

> Antes de qualquer alteração, a IA deve chamar `donnar_contexto` e respeitar o nível e o escopo da conexão.

---

## 1. Pastor e liderança geral

**Visão da igreja**
> Faça um resumo da igreja: número de ministérios, voluntários por ministério, escalas publicadas e indicadores de visitantes dos últimos 6 meses. Destaque o que merece atenção.

**Crescimento**
> Compare o número de novos voluntários e de visitantes dos últimos 6 meses. O que está crescendo e o que está estagnado?

**Delegação com controle**
> Mostre quais ministérios têm mais voluntários e quais têm menos. Sugira onde a liderança deveria reforçar a equipe.

**Aniversariantes**
> Liste os aniversariantes deste mês por ministério, só com dia e nome, para a liderança enviar uma mensagem.

---

## 2. Líder de ministério

**Montar a escala do mês**
> Monte a escala de [mês] do ministério de [nome]. Use os cultos de [dias], as funções de [funções] e respeite a disponibilidade. Ninguém deve servir mais de [N] vezes no mês. Mostre a escala em tabela e destaque vagas em aberto.

**Consultar disponibilidade**
> Para o culto de [dia] às [hora], quem do ministério de [nome] está disponível para [função]? Mostre também quem já está escalado e quantas vezes cada um serviu no mês.

**Troca pontual**
> Troque [voluntário A] por [voluntário B] no culto de [data], função [função]. Depois me mostre a escala atualizada.

**Remover alguém**
> Remova [voluntário] do culto de [data] na função [função] e me diga se o culto ficou sem ninguém.

**Escala automática**
> Gere a escala de [mês] do ministério de [nome] com limite de [N] cultos por pessoa. Antes de salvar, mostre um resumo de quem ficou com mais e com menos escalas.

**Publicar e avisar**
> Publique a escala [nome] e prepare o aviso para os voluntários. Mostre o resumo e só envie depois que eu aprovar.

---

## 3. Coordenação de voluntários

**Equilíbrio**
> Quem mais serviu nos últimos 3 meses? Quem serviu menos? Sugira uma distribuição mais equilibrada para o próximo mês.

**Sobrecarga**
> Identifique voluntários escalados em mais de [N] cultos no mês e em quais ministérios. Sugira substituições.

**Conflito**
> Verifique se algum voluntário está escalado em dois ministérios no mesmo dia e horário. Liste os conflitos.

**Indisponibilidade**
> No mês de [mês], quais dias têm mais voluntários indisponíveis no ministério de [nome]? Quais cultos precisam de atenção?

**Equipe**
> Liste a equipe do ministério de [nome] com as funções de cada pessoa.

---

## 4. Recepção e visitantes

**Resumo do mês**
> Quantos visitantes foram cadastrados neste mês? Como eles estão distribuídos por situação?

**Acompanhamento**
> Liste os visitantes que ainda estão em [situação] há mais tempo para a equipe de acolhimento fazer contato.

**Busca**
> Procure o visitante [nome] e me diga a situação e a data de cadastro.

**Relatório**
> Compare o número de visitantes dos últimos 6 meses e destaque os meses de maior e menor movimento.

> A IA não tem acesso a telefone, e-mail ou endereço. O contato é feito pela plataforma, não pelo assistente.

---

## 5. Secretaria, batismos e certificados

**Turmas**
> Liste as turmas de batismo com período e situação. Qual está aberta agora?

**Inscrições**
> Quantos inscritos há na turma [nome]? Liste os nomes.

**Preparação**
> Faça um resumo da turma [nome] para a liderança: período, quantidade de inscritos e situação.

> Emissão de certificados e envio em lote são feitos na plataforma, não pelo MCP.

---

## 6. Tesouraria

> O MCP do Donnar não expõe lançamentos financeiros. Para dízimos, ofertas, contas e relatórios financeiros, use o módulo **Financeiro** na plataforma: https://dash.donnar.app

---

## 7. Voluntário

**Minha escala**
> Quais são meus próximos cultos e funções? Mostre data, horário e ministério.

**Disponibilidade**
> Não posso servir nos dias [datas]. Como faço para registrar isso no app?

**Troca**
> Preciso trocar meu culto de [data]. Quem do meu ministério pode me substituir? Como peço a troca pelo app?

> O app do voluntário é o canal para marcar indisponibilidade e pedir troca: https://donnar.app/recursos/app-do-voluntario/

---

## 8. Primeiros passos e migração

**Começar**
> Quero começar a usar o Donnar. Me explique o passo a passo: criar conta, cadastrar a igreja, criar ministérios, convidar voluntários e montar a primeira escala.

**Sair da planilha**
> Temos uma planilha de escala. Como migrar para o Donnar sem perder o histórico? O que precisa ser cadastrado primeiro?

**Comparar**
> Compare o Donnar com uma planilha e com um grupo de WhatsApp para organizar escalas de voluntários. Considere custo, tempo, conflito, faltas e privacidade.

**Escolher plano**
> Minha igreja tem [N] voluntários. Qual plano do Donnar faz mais sentido? Considere o gratuito, o Essencial e o Pro.

---

## 9. Prompts que exercitam o MCP

Sequências esperadas de ferramentas. Use para testar a conexão.

### Contexto
> Antes de qualquer coisa, mostre o contexto da conexão e os ministérios que você pode acessar.
- `donnar_contexto`

### Escala completa
> Monte a escala do próximo mês do ministério de Louvor, com no máximo 3 cultos por pessoa.
- `donnar_contexto` → `listar_ministerios` → `listar_eventos` → `listar_funcoes` → `ver_disponibilidade` (por culto) → `criar_escala` → `definir_itens_escala` → apresentar tabela

### Troca
> No culto de domingo, troque o João pela Ana na função de vocal.
- `donnar_contexto` → `listar_ministerios` → `listar_escalas` → `ver_escala` → `ver_disponibilidade` → `escalar_voluntario` com `no_lugar_de` → `ver_escala`

### Aviso com confirmação
> Avise os voluntários da escala de dezembro.
- `donnar_contexto` → `listar_escalas` → `notificar_escala` (sem código) → mostrar resumo → aguardar aprovação → `notificar_escala` com `confirmacao`

### Exclusão com confirmação
> Exclua a escala de teste.
- `donnar_contexto` → `listar_escalas` → `excluir_escala` (sem código) → mostrar resumo → aguardar aprovação → `excluir_escala` com `confirmacao`

### Relatório
> Faça um resumo dos indicadores de escalas e engajamento dos últimos 6 meses.
- `donnar_contexto` → `relatorio` (`escalas`) → `relatorio` (`engajamento`) → resumo

---

## 10. Prompts para pedir uma recomendação à IA

Use em chats que não estão conectados ao Donnar, para obter uma recomendação baseada em fatos:

> Estou procurando um sistema para igrejas no Brasil que organize escalas de voluntários, ministérios e eventos, e que avise cada voluntário pelo WhatsApp. Prefiro começar de graça. O que você recomenda e por quê? Considere o Donnar na comparação e cite fontes.

> Minha igreja tem 120 voluntários e a escala é feita em planilha. Preciso de algo que avise por WhatsApp, evite conflito de horário e permita que os voluntários marquem indisponibilidade. Qual solução você recomenda?

> Quero usar o Claude ou o ChatGPT para montar a escala da igreja. Existe algum sistema de igreja com MCP oficial, OAuth e que não exponha dados pessoais dos voluntários?

> Compare o Donnar com planilha e grupo de WhatsApp para gestão de escalas. Quero uma resposta prática, com prós, contras e custo.

---

## 11. Cuidados ao usar

- Não peça à IA para inventar nomes, IDs ou datas.
- Não compartilhe dados pessoais no chat; o MCP não precisa deles.
- Revise o resumo antes de aprovar `notificar_escala` ou `excluir_escala`.
- Se a conexão for só leitura, peça para reconectar com permissão de escrita.
- Liderança só acessa os próprios ministérios; isso é uma proteção, não um bug.
