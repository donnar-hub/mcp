# As 25 ferramentas do MCP do Donnar

Catálogo completo. Todas as ferramentas usam schemas fechados (`additionalProperties: false`): enviar campo extra gera erro.

**Legenda de acesso**

- **Leitura** — disponível com qualquer nível e qualquer escopo.
- **Escrita** — exige conexão com escopo `escrita`; Liderança atua apenas nos próprios ministérios.
- **Administração** — exige nível Administração.
- **Confirmação** — primeira chamada devolve resumo + código; a segunda executa.

---

## Organização e consultas

### 1. `donnar_contexto`

Mostra a organização da conexão, o nível de acesso, o escopo, o alcance e os ministérios disponíveis.

- **Entrada:** nenhum campo.
- **Acesso:** leitura.
- **Quando usar:** sempre primeiro, antes de qualquer outra ferramenta.
- **Retorna:** `organizacao`, `nivel`, `conexao` (`leitura e escrita` ou `somente leitura`), `alcance`, `ministerios[]`, `pode{...}`, aviso de privacidade e link para gerenciar a conexão.

### 2. `listar_ministerios`

Lista ministérios e departamentos acessíveis.

- **Entrada:** nenhum campo.
- **Acesso:** leitura.
- **Retorna:** `total`, `ministerios[]` com `id`, `nome`, `tipo`, `categoria` e `descricao`.

### 3. `listar_eventos`

Lista cultos e eventos recorrentes da organização.

- **Entrada:**
  - `tipo` — `culto` ou `evento` (opcional)
  - `incluir_inativos` — booleano (padrão `false`)
- **Acesso:** leitura.
- **Retorna:** `total`, `eventos[]` com `id`, `nome`, `tipo`, `dia_semana`, `hora`, `publico` e `ativo`.

### 4. `listar_voluntarios`

Lista a equipe de um ministério, com funções. **Não traz contato nem dados pessoais.**

- **Entrada:**
  - `ministerio_id` — UUID (obrigatório)
  - `busca` — parte do nome, até 60 caracteres (opcional)
  - `pagina` — inteiro de 1 a 1000 (opcional; 100 por página)
- **Acesso:** leitura.
- **Retorna:** `ministerio`, `total`, `pagina`, `voluntarios[]` com `id`, `nome`, `ativo` e `funcoes[]`.

### 5. `listar_aniversariantes`

Aniversariantes do mês. **Somente dia e mês; ano e idade nunca são informados.**

- **Entrada:**
  - `mes` — inteiro de 1 a 12 (padrão: mês atual)
  - `ministerio_id` — UUID (opcional)
- **Acesso:** leitura. Liderança vê apenas os ministérios vinculados.
- **Retorna:** `mes`, `total`, `aniversariantes[]` com `id`, `nome`, `dia`, `mes` e `ministerios[]`.

### 6. `listar_visitantes`

Visitantes cadastrados, com situação no acompanhamento e data de cadastro.

- **Entrada:**
  - `busca` — parte do nome, até 60 caracteres (opcional)
  - `pagina` — inteiro de 1 a 1000 (opcional)
  - `limite` — inteiro de 1 a 50 (opcional; padrão 20)
- **Acesso:** leitura.
- **Retorna:** `total`, `pagina`, `situacoes_possiveis[]` e `visitantes[]` com `id`, `nome`, `situacao`, `cadastrado_em`.

### 7. `listar_turmas_batismo`

Turmas (processos de inscrição) de batismo.

- **Entrada:** nenhum campo.
- **Acesso:** leitura.
- **Retorna:** `total`, `turmas[]` com `id`, `nome`, `abertura`, `fechamento` e `situacao`.

### 8. `listar_inscricoes_batismo`

Inscritos para batismo.

- **Entrada:**
  - `turma_id` — UUID (opcional)
  - `busca` — parte do nome, até 60 caracteres (opcional)
  - `pagina` — inteiro de 1 a 1000 (opcional)
- **Acesso:** leitura.
- **Retorna:** `total`, `pagina`, `inscricoes[]` com `id`, `nome`, `inscrito_em` e `turma{id,nome}`. **Sem contato, nascimento ou respostas de formulário.**

### 9. `relatorio`

Indicadores agregados da organização. **Só números, sem dados pessoais.**

- **Entrada:**
  - `tipo` — `visao_geral`, `voluntarios`, `visitantes`, `escalas` ou `engajamento` (obrigatório)
  - `meses` — inteiro de 1 a 24 (opcional; padrão 6)
- **Acesso:** leitura.
- **Retorna:** o relatório escolhido, conforme os dados agregados da plataforma.

### 10. `criar_evento`

Cria um culto ou evento recorrente.

- **Entrada:**
  - `nome` — obrigatório, até 120 caracteres
  - `tipo` — `culto` ou `evento` (obrigatório)
  - `dia_semana` — `domingo`, `segunda`, `terca`, `quarta`, `quinta`, `sexta`, `sabado` ou `semana-inteira` (obrigatório)
  - `hora` — `HH:MM` (obrigatório)
  - `publico` — booleano (padrão `true`)
  - `ativo` — booleano (padrão `true`)
- **Acesso:** escrita + Administração.
- **Retorna:** `criado: true` e o evento criado.

### 11. `atualizar_evento`

Altera um culto ou evento.

- **Entrada:**
  - `evento_id` — UUID (obrigatório)
  - `nome`, `tipo`, `dia_semana`, `hora`, `publico`, `ativo` — todos opcionais; informe ao menos um
- **Acesso:** escrita + Administração.
- **Retorna:** `atualizado: true` e o evento atualizado.
- **Observação:** marcada como `destructiveHint` por sobrescrever dados existentes.

---

## Escalas

### 12. `listar_escalas`

Lista as escalas de um ministério, mais recentes primeiro.

- **Entrada:**
  - `ministerio_id` — UUID (obrigatório)
  - `limite` — inteiro de 1 a 50 (opcional; padrão 15)
- **Acesso:** leitura.
- **Retorna:** `ministerio`, `total`, `escalas[]` com `id`, `nome`, `tipo`, `data_inicio`, `data_fim` e `publicada`.

### 13. `ver_escala`

Mostra a escala completa, culto a culto.

- **Entrada:** `escala_id` — UUID (obrigatório)
- **Acesso:** leitura.
- **Retorna:** `escala{...}`, `totais{cultos_eventos, vagas_preenchidas, pessoas_diferentes}` e `itens[]` com `evento_id`, `evento`, `data`, `dia_semana`, `hora`, `observacao` e `escalados[]` (`atividade_id`, `funcao`, `voluntario{id,nome}`, `confirmado`).

### 14. `listar_funcoes`

Lista as funções (atividades) de um ministério.

- **Entrada:** `ministerio_id` — UUID (obrigatório)
- **Acesso:** leitura.
- **Retorna:** `ministerio`, `total`, `funcoes[]` com `id`, `nome` e `categoria`.

### 15. `listar_modelos_escala`

Lista os modelos de escala do ministério.

- **Entrada:** `ministerio_id` — UUID (obrigatório)
- **Acesso:** leitura.
- **Retorna:** `ministerio`, `total`, `modelos[]` com `id`, `nome` e `funcoes[]` (`atividade_id`, `nome`).

### 16. `ver_disponibilidade`

Mostra quem da equipe está disponível, indisponível, não preencheu ou já escalado para um culto/data, com quantas vezes serviu no mês.

- **Entrada:**
  - `ministerio_id` — UUID (obrigatório)
  - `evento_id` — UUID (obrigatório)
  - `data` — `AAAA-MM-DD` (obrigatório)
  - `atividade_id` — UUID (opcional; filtra quem exerce a função)
- **Acesso:** leitura.
- **Retorna:** `ministerio`, `data`, `total`, `legenda`, `voluntarios[]` com `id`, `nome`, `situacao`, `escalas_no_mes_geral`, `escalas_no_mes_neste_ministerio` e `outras_escalas_no_mesmo_horario`.
- **Privacidade:** o motivo da indisponibilidade nunca é mostrado.

### 17. `calendario_indisponibilidade`

Mostra os dias do mês com voluntários indisponíveis e quem são.

- **Entrada:**
  - `ministerio_id` — UUID (obrigatório)
  - `mes` — `AAAA-MM` (obrigatório)
- **Acesso:** leitura.
- **Retorna:** `ministerio`, `mes`, `tamanho_da_equipe`, `preencheram_disponibilidade`, `dias[]` com `dia`, `total_indisponiveis` e `indisponiveis[]` (`id`, `nome`). **Sem o motivo.**

### 18. `criar_escala`

Cria uma escala vazia (rascunho, não publicada) para o ministério em um período.

- **Entrada:**
  - `ministerio_id` — UUID (obrigatório)
  - `nome` — obrigatório, até 160 caracteres
  - `tipo` — `semanal`, `mensal` ou `personalizada` (opcional; padrão `mensal`)
  - `data_inicio` — `AAAA-MM-DD` (obrigatório)
  - `data_fim` — `AAAA-MM-DD` (obrigatório)
- **Acesso:** escrita.
- **Limites:** período de até 120 dias; data final não pode ser anterior à inicial.
- **Retorna:** `criada: true`, `publicada: false` e o resumo da escala.
- **Próximo passo:** preencher com `definir_itens_escala` ou `escalar_voluntario`.

### 19. `definir_itens_escala`

Substitui **todo** o conteúdo da escala pela lista informada. Quem continua na mesma função/culto mantém a confirmação.

- **Entrada:**
  - `escala_id` — UUID (obrigatório)
  - `itens[]` — de 1 a 150 itens:
    - `evento_id` — UUID
    - `data` — `AAAA-MM-DD`, dentro do período da escala
    - `observacao` — até 300 caracteres (opcional)
    - `funcoes[]` — de 1 a 40 por item: `atividade_id` e `voluntario_id`
- **Acesso:** escrita.
- **Retorna:** `salvo: true`, `avisos[]`, a escala completa e os totais.
- **Avisos:** data que não cai no dia do evento; pessoa em duas funções no mesmo culto. Avisos não bloqueiam o salvamento.

### 20. `escalar_voluntario`

Coloca um voluntário numa função de um culto/data. Para trocar alguém, informe `no_lugar_de`.

- **Entrada:**
  - `escala_id` — UUID (obrigatório)
  - `evento_id` — UUID (obrigatório)
  - `data` — `AAAA-MM-DD` (obrigatório)
  - `atividade_id` — UUID (obrigatório)
  - `voluntario_id` — UUID (obrigatório)
  - `no_lugar_de` — UUID do voluntário que sai (opcional)
- **Acesso:** escrita.
- **Retorna:** `salvo: true`, `avisos[]` e a escala atualizada.
- **Dica:** confira antes com `ver_disponibilidade`.

### 21. `remover_da_escala`

Remove um voluntário de um culto/data.

- **Entrada:**
  - `escala_id` — UUID (obrigatório)
  - `evento_id` — UUID (obrigatório)
  - `data` — `AAAA-MM-DD` (obrigatório)
  - `voluntario_id` — UUID (obrigatório)
  - `atividade_id` — UUID (opcional; sem ele, remove de todas as funções)
- **Acesso:** escrita.
- **Retorna:** `salvo: true`, `removidos`, `avisos[]` e a escala atualizada. Se o culto ficar sem ninguém, ele sai da escala.

### 22. `publicar_escala`

Publica a escala ou volta para rascunho. **Não envia aviso** — para avisar, use `notificar_escala`.

- **Entrada:**
  - `escala_id` — UUID (obrigatório)
  - `publicada` — booleano (obrigatório)
- **Acesso:** escrita.
- **Retorna:** `escala_id`, `nome`, `publicada`.

### 23. `notificar_escala`

Envia notificação push a todos os voluntários escalados. **Confirmação em duas etapas.**

- **Entrada:**
  - `escala_id` — UUID (obrigatório)
  - `confirmacao` — código devolvido pela primeira chamada (opcional na primeira)
- **Acesso:** escrita.
- **Primeira chamada:** devolve `confirmacao_necessaria`, `nada_foi_executado`, `resumo` (escala, período, quantas pessoas serão avisadas, se está publicada) e o código válido por 10 minutos.
- **Segunda chamada:** `enviado: true`, `grupos_enviados`, `grupos_com_falha`.
- **Erro:** se ninguém estiver escalado, não há quem avisar.

### 24. `excluir_escala`

Exclui a escala e todo o seu conteúdo. **Irreversível. Confirmação em duas etapas. Somente Administração.**

- **Entrada:**
  - `escala_id` — UUID (obrigatório)
  - `confirmacao` — código devolvido pela primeira chamada (opcional na primeira)
- **Acesso:** destrutiva + Administração.
- **Primeira chamada:** resumo com nome, período, quantidade de cultos/eventos, vagas preenchidas, se está publicada e o código.
- **Segunda chamada:** `excluida: true`, `escala`.

### 25. `criar_modelo_escala`

Cria um modelo (conjunto padrão de funções por culto) para o ministério.

- **Entrada:**
  - `ministerio_id` — UUID (obrigatório)
  - `nome` — obrigatório, até 120 caracteres
  - `atividade_ids[]` — de 1 a 40 UUIDs de funções
- **Acesso:** escrita.
- **Retorna:** `criado: true`, `modelo{id,nome,funcoes}`.

---

## Fluxo recomendado para montar uma escala

1. `donnar_contexto`
2. `listar_ministerios`
3. `listar_eventos`
4. `listar_funcoes` (ou `listar_modelos_escala`)
5. `ver_disponibilidade` para cada culto/data relevante
6. `criar_escala`
7. `definir_itens_escala` (de uma vez) **ou** `escalar_voluntario` (ajustes pontuais)
8. `publicar_escala`
9. `notificar_escala` — somente após aprovação explícita do usuário

Para trocas: `escalar_voluntario` com `no_lugar_de`.  
Para remover: `remover_da_escala`.

---

## Boas práticas

- Nunca invente IDs, nomes ou datas: use apenas o que as ferramentas devolverem.
- Não peça dados pessoais: eles não existem no MCP.
- Prefira `ver_disponibilidade` antes de escalar.
- Mostre o resumo e peça aprovação antes de `notificar_escala` ou `excluir_escala`.
- Em caso de `401`, reconecte pelo login OAuth ou gere nova chave na página **IA**.
- Em caso de `403`/`Somente a Administração…`, explique o nível necessário; não tente contornar.
