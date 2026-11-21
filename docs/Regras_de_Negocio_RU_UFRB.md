# Regras de Negócio — Restaurante Universitário da UFRB

**Tema:** Sistema de Gestão do Restaurante Universitário da UFRB
**Base:** Minimundo, Modelo Conceitual (Chen), Modelo Relacional e `Banco_Restaurante_UFRB.sql`.

## Como ler este documento

Cada regra tem um código (`RN-xx`), um enunciado e a forma de implementação sugerida:

- **NN** = `NOT NULL`
- **UQ** = `UNIQUE`
- **CK** = `CHECK`
- **TR** = *trigger* ou transação no banco
- **APP** = validação na aplicação (regra que depende de consulta a várias tabelas ou de política institucional)

Regras marcadas com ⚠️ dependem de decisão da equipe (ver seção 11).

---

## 1. Domínios de valores (status e tipos)

| Campo | Valores permitidos |
|---|---|
| `USUARIO.status` | `ATIVO`, `INATIVO`, `SUSPENSO` |
| `FUNCIONARIO.status` | `ATIVO`, `INATIVO` |
| `HORARIO_ATENDIMENTO.status` | `ABERTO`, `LOTADO`, `ENCERRADO`, `CANCELADO` |
| `AGENDAMENTO.status` | `AGENDADO`, `CANCELADO`, `ATENDIDO`, `FALTA` |
| `PAGAMENTO_PIX.status` | `AGUARDANDO_CONFERENCIA`, `CONFIRMADO`, `REJEITADO` |
| `CONFERENCIA.decisao` | `CONFIRMADO`, `REJEITADO` |
| `MOVIMENTACAO.tipo` | `CREDITO`, `DEBITO` |
| `REGISTRO_ACESSO.tipo_evento` | `ENTRADA`, `SAIDA` |
| `OCORRENCIA.status` | `ABERTA`, `EM_ANALISE`, `PROCEDENTE`, `IMPROCEDENTE` |
| `CONTESTACAO.status` | `PENDENTE`, `ACEITA`, `REJEITADA` |
| `PENALIDADE.status` | `VIGENTE`, `CUMPRIDA`, `REVOGADA` |

**RN-01.** Os campos acima só aceitam os valores listados. *(CK ou ENUM)*

---

## 2. Usuários e categorias

**RN-02.** Todo usuário pertence a exatamente uma categoria (discente, docente, técnico administrativo ou visitante); uma categoria pode ter vários usuários. *(NN em `USUARIO.id_categoria`)*

**RN-03.** Nome, e-mail e contato são obrigatórios para qualquer usuário. *(NN)*

**RN-04.** O e-mail do usuário é único no sistema. *(UQ em `USUARIO.email`)*

**RN-05.** Usuários vinculados à universidade (discente, docente, técnico administrativo) devem ter `matricula_ou_siape` e `curso_ou_lotacao` preenchidos. *(TR ou APP)*

**RN-06.** Visitantes devem ter `identificacao_visitante` preenchida e não possuem matrícula/SIAPE. *(TR ou APP)*

**RN-07.** A matrícula/SIAPE é única entre os usuários que a possuem. *(UQ em `USUARIO.matricula_ou_siape`; o MySQL aceita vários `NULL` em colunas UNIQUE)*

**RN-08.** Usuário com status `INATIVO` ou `SUSPENSO` não pode realizar novos agendamentos. *(TR ou APP)*

---

## 3. Funcionários e perfis de acesso

**RN-09.** Todo funcionário possui exatamente um perfil de acesso; um perfil pode ser atribuído a vários funcionários. *(NN em `FUNCIONARIO.id_perfil`)*

**RN-10.** Nome, e-mail institucional e identificação do funcionário são obrigatórios, e o e-mail institucional é único. *(NN + UQ em `FUNCIONARIO.email_institucional`)*

**RN-11.** Cada operação administrativa só pode ser executada por funcionário `ATIVO` cujo perfil tenha a permissão correspondente (cadastrar horários, conferir pagamentos, registrar acessos, analisar ocorrências, aplicar penalidades). *(APP)*

**RN-12.** Toda operação relevante gera um registro em `AUDITORIA` com o funcionário responsável, a operação, a entidade e o registro afetados e a data/hora. Registros de auditoria nunca são alterados nem excluídos. *(NN em `AUDITORIA.id_funcionario`, `operacao`, `entidade_afetada`, `data_hora`; TR para gerar o registro; permissões de UPDATE/DELETE negadas)*

---

## 4. Tipos de refeição e horários de atendimento

**RN-13.** Todo horário de atendimento está associado a exatamente um tipo de refeição (almoço, jantar etc.). *(NN em `HORARIO_ATENDIMENTO.id_tipo`)*

**RN-14.** Data, início, término e capacidade máxima são obrigatórios. *(NN)*

**RN-15.** O término deve ser posterior ao início. *(CK: `termino > inicio`)*

**RN-16.** A capacidade máxima deve ser maior que zero. *(CK: `capacidade_maxima > 0`)*

**RN-17.** O valor do tipo de refeição deve ser maior que zero. *(CK: `valor > 0`)*

**RN-18.** Não pode haver dois horários do mesmo tipo de refeição na mesma data com intervalos sobrepostos. *(TR ou APP)*

**RN-19.** Para cada horário, o sistema deve controlar:
- **vagas ofertadas** = `capacidade_maxima`;
- **vagas reservadas** = agendamentos com status `AGENDADO` ou `ATENDIDO`;
- **vagas disponíveis** = ofertadas − reservadas;
- **demanda atendida** = agendamentos `ATENDIDO`.

São atributos **derivados**, calculados por consulta ou *view*, e não gravados em coluna. *(VIEW)*

**RN-20.** Quando as vagas disponíveis chegam a zero, o horário passa a `LOTADO`; ao liberar vaga (cancelamento), volta a `ABERTO`. *(TR ou APP)*

---

## 5. Agendamentos

**RN-21.** Todo agendamento pertence a exatamente um usuário e a exatamente um horário de atendimento. *(NN em `AGENDAMENTO.id_usuario` e `id_horario`)*

**RN-22.** O usuário não pode ter dois agendamentos ativos (`AGENDADO` ou `ATENDIDO`) para o mesmo horário. *(UQ em `(id_usuario, id_horario)` impede duplicidade simples; ⚠️ se o cancelamento permitir reagendar no mesmo horário, usar regra por TR em vez de UNIQUE)*

**RN-23.** O usuário não pode ter mais de um agendamento ativo para o mesmo tipo de refeição na mesma data. *(TR ou APP; é a regra de "agendamento duplicado incompatível")*

**RN-24.** Não é permitido agendar em horário cuja ocupação já atingiu a capacidade máxima. *(TR ou APP)*

**RN-25.** Só é permitido agendar horários com status `ABERTO` e que ainda não tenham começado. *(APP)*

**RN-26.** O agendamento só é concluído se o usuário possuir saldo suficiente na carteira para o valor do tipo de refeição (ver RN-37). *(TR ou APP, na mesma transação do débito)*

**RN-27.** O agendamento não referencia pagamento algum. A ligação financeira é feita apenas por `MOVIMENTACAO`, o que permite que um único pagamento financie várias refeições. *(Modelo: não existe FK de `AGENDAMENTO` para `PAGAMENTO_PIX`)*

**RN-28.** Cada agendamento recebe um `codigo_qr` único, gerado no momento da criação. *(NN + UQ em `AGENDAMENTO.codigo_qr`)*

**RN-29.** Os agendamentos respeitam os limites definidos pela administração (por exemplo, máximo de refeições por dia ou por semana por usuário). *(⚠️ APP; os limites precisam ser definidos)*

**RN-30.** O status só evolui nos sentidos permitidos:
- `AGENDADO` → `ATENDIDO`, `CANCELADO` ou `FALTA`;
- `ATENDIDO`, `CANCELADO` e `FALTA` são estados finais. *(TR ou APP)*

---

## 6. Carteira de créditos

**RN-31.** Cada usuário possui no máximo uma carteira, e cada carteira pertence a um único usuário. *(NN + UQ em `CARTEIRA.id_usuario`)*

**RN-32.** A carteira é criada automaticamente com saldo zero no cadastro do usuário. *(TR ou APP)*

**RN-33.** O saldo nunca pode ser negativo. *(CK: `saldo >= 0`)*

**RN-34.** O saldo é resultado das movimentações: **saldo = soma dos créditos − soma dos débitos**. Qualquer alteração de saldo deve ocorrer na mesma transação que grava a movimentação. O saldo não pode ser editado diretamente. *(TR ou APP; ⚠️ decidir entre saldo armazenado com *trigger* ou saldo apenas calculado por *view*)*

---

## 7. Pagamentos Pix e conferência

**RN-35.** Todo pagamento pertence a uma carteira e deve ter valor, data/hora, comprovante e identificador da transação Pix. *(NN em `id_carteira`, `valor`, `data_pagamento`, `comprovante`, `id_transacao_pix`)*

**RN-36.** O valor do pagamento deve ser maior que zero. *(CK: `valor > 0`)*

**RN-37.** O identificador da transação Pix é único, para que a mesma transação não gere créditos duplicados. *(UQ em `PAGAMENTO_PIX.id_transacao_pix`)*

**RN-38.** O mesmo comprovante não pode ser usado em mais de um pagamento. *(UQ sobre o `comprovante`; recomenda-se guardar um *hash* do arquivo em coluna própria)*

**RN-39.** Todo pagamento nasce com status `AGUARDANDO_CONFERENCIA`. *(DEFAULT)*

**RN-40.** Apenas um funcionário autorizado pode conferir um pagamento, registrando decisão, data da análise e responsável. *(NN em `CONFERENCIA.id_pagamento`, `id_funcionario`, `data_analise`, `decisao`)*

**RN-41.** Se a decisão for `REJEITADO`, a justificativa é obrigatória. *(CK: `decisao <> 'REJEITADO' OR justificativa IS NOT NULL`)*

**RN-42.** O status do pagamento deve refletir a última conferência: `CONFIRMADO` ou `REJEITADO`. *(TR)*

**RN-43.** Pagamento `CONFIRMADO` gera exatamente um lançamento de `CREDITO` na carteira, no valor do pagamento, e o saldo aumenta. *(TR; garantido por UQ em `MOVIMENTACAO.id_pagamento`)*

**RN-44.** Pagamento `REJEITADO` ou `AGUARDANDO_CONFERENCIA` nunca gera crédito. *(TR)*

**RN-45.** Pagamento já conferido não pode ter a decisão alterada. Eventual correção é feita por nova conferência, com justificativa, preservando o histórico. ⚠️ *(APP)*

---

## 8. Movimentações financeiras

**RN-46.** Toda movimentação pertence a uma carteira e tem data/hora, tipo, valor e descrição. *(NN em `id_carteira`, `data_hora`, `tipo`, `valor`)*

**RN-47.** O valor da movimentação deve ser maior que zero; o sentido (entrada ou saída) é dado apenas pelo tipo. *(CK: `valor > 0`)*

**RN-48.** Movimentação do tipo `CREDITO` deve referenciar um pagamento e nenhum agendamento. *(CK: `tipo <> 'CREDITO' OR (id_pagamento IS NOT NULL AND id_agendamento IS NULL)`)*

**RN-49.** Movimentação do tipo `DEBITO` deve referenciar um agendamento e nenhum pagamento. *(CK: `tipo <> 'DEBITO' OR (id_agendamento IS NOT NULL AND id_pagamento IS NULL)`)*

**RN-50.** A carteira da movimentação deve ser a mesma do pagamento (crédito) ou a do usuário do agendamento (débito). *(TR)*

**RN-51.** Movimentações são imutáveis: não se altera nem se exclui uma movimentação. Correções são feitas por novo lançamento (estorno). *(TR ou permissões)*

**RN-52.** O valor do débito é o valor do tipo de refeição do horário agendado, no momento do lançamento. *(TR ou APP)*

**RN-53.** O extrato da carteira lista as movimentações em ordem cronológica, com a origem de cada uma (pagamento ou agendamento). *(VIEW)*

---

## 9. Controle de acesso e permanência

**RN-54.** Todo registro de acesso está ligado a um agendamento e tem data/hora e tipo de evento (`ENTRADA` ou `SAIDA`). *(NN em `id_agendamento`, `data_hora`, `tipo_evento`)*

**RN-55.** O funcionário e o dispositivo são informados apenas quando aplicável (por exemplo, leitura por QR Code sem operador). *(Nulo permitido em `id_funcionario` e `dispositivo`)*

**RN-56.** Só é permitido registrar acesso para agendamento com status `AGENDADO` (ou `ATENDIDO`, no caso da saída) e na data do horário agendado. *(TR ou APP)*

**RN-57.** A sequência de eventos de um agendamento deve ser coerente: toda `SAIDA` exige `ENTRADA` anterior, e não se registra duas entradas seguidas sem saída. *(TR ou APP)*

**RN-58.** Ao registrar a primeira `ENTRADA` do agendamento, o status passa para `ATENDIDO` (consumo confirmado). ⚠️ *(TR ou APP)*

**RN-59.** O tempo de permanência é derivado: **saída − entrada** do mesmo agendamento. Não é armazenado. *(VIEW)*

**RN-60.** Agendamento `AGENDADO` sem nenhuma entrada até o fim do horário passa para `FALTA`. *(rotina agendada ou APP)*

---

## 10. Ocorrências, contestações e penalidades

### Ocorrências

**RN-61.** Toda ocorrência refere-se a um usuário e a uma regra descumprida, e tem data e descrição. *(NN em `id_usuario`, `data_ocorrencia`, `descricao`, `regra`)*

**RN-62.** A ocorrência pode se originar de um registro de acesso (por exemplo, permanência excedida) ou ser lançada manualmente. *(Nulo permitido em `id_registro`)*

**RN-63.** Quando a ocorrência vem de um registro de acesso, o usuário da ocorrência deve ser o dono do agendamento desse registro. *(TR)*

**RN-64.** Ocorrências só são registradas se houver política institucional que defina a regra. *(APP)*

**RN-65.** O funcionário que analisa a ocorrência é registrado, e a análise altera o status para `PROCEDENTE` ou `IMPROCEDENTE`. *(NN em `id_funcionario` ao sair de `ABERTA`)*

### Contestações

**RN-66.** Uma contestação pertence a uma ocorrência e a um usuário, com justificativa e data de envio. *(NN em `id_ocorrencia`, `id_usuario`, `data_envio`, `justificativa`)*

**RN-67.** Apenas o usuário atingido pela ocorrência pode contestá-la. *(TR ou APP: `CONTESTACAO.id_usuario = OCORRENCIA.id_usuario`)*

**RN-68.** Uma ocorrência pode ter várias contestações, e todas são preservadas no histórico. *(Modelo 1:0..N)*

### Penalidades

**RN-69.** Uma ocorrência pode não gerar penalidade ou gerar uma ou mais penalidades. *(Modelo 1:0..N)*

**RN-70.** Toda penalidade referencia uma ocorrência e o funcionário responsável pela decisão, e registra tipo, data de aplicação e justificativa. *(NN em `id_ocorrencia`, `id_funcionario`, `tipo`, `data_aplicacao`, `justificativa`)*

**RN-71.** Só se aplica penalidade sobre ocorrência julgada `PROCEDENTE`. *(TR ou APP)*

**RN-72.** O fim da vigência não pode ser anterior ao início. *(CK: `fim_vigencia IS NULL OR fim_vigencia >= inicio_vigencia`)*

**RN-73.** A vigência é opcional (medidas como advertência não têm período). *(Nulo permitido em `inicio_vigencia` e `fim_vigencia`; se houver fim, deve haver início)*

**RN-74.** Enquanto houver penalidade `VIGENTE` do tipo suspensão, o usuário não pode agendar refeições. *(APP, junto com RN-08)*

**RN-75.** Penalidades não são excluídas. Quando aplicadas indevidamente, passam para `REVOGADA`, preservando o histórico, com registro do responsável pela revisão, da data e da justificativa. ⚠️ *(requer novos campos ou entidade de revisão; ver seção 11)*

---

## 11. Decisões pendentes da equipe

O minimundo é ambíguo em três pontos. Sugestão de decisão para cada um, que a equipe deve confirmar e registrar:

| # | Questão | Opção sugerida | Impacto no modelo |
|---|---|---|---|
| 1 | **Quando ocorre o débito?** O texto diz "quando o consumo for confirmado" e também "no momento do agendamento". | **Débito no momento do agendamento** (reserva o saldo e garante o pagamento). É a leitura do trecho que trata da separação entre pagamento e agendamento. | Nenhum na estrutura. |
| 2 | **Cancelamento e estorno.** Se o débito ocorre no agendamento, o cancelamento precisa devolver o valor. | Criar movimentação `CREDITO` de estorno referenciando o agendamento. | Trocar `UNIQUE (id_agendamento)` por `UNIQUE (id_agendamento, tipo)`, e ajustar RN-48 para permitir crédito com `id_agendamento` em caso de estorno (ou criar o tipo `ESTORNO`). |
| 3 | **Revisão de penalidades.** O texto exige histórico e revisão. | Status `REVOGADA` mais campos `id_funcionario_revisao`, `data_revisao`, `justificativa_revisao` em `PENALIDADE`. | Novas colunas, ou nova entidade `REVISAO_PENALIDADE` se a revisão puder ocorrer várias vezes. |

Outras definições necessárias: limites de agendamentos por usuário (RN-29), política de permanência (RN-64), saldo armazenado ou calculado (RN-34) e imutabilidade da conferência (RN-45).

---

## 12. Atributos derivados e relatórios

| Informação | Origem | Forma sugerida |
|---|---|---|
| Vagas reservadas, disponíveis e atendidas | `AGENDAMENTO` por horário | *View* |
| Taxa de ocupação do horário | reservadas ÷ capacidade | *View* |
| Saldo da carteira | `MOVIMENTACAO` | *View* ou coluna mantida por *trigger* |
| Tempo de permanência | `REGISTRO_ACESSO` (saída − entrada) | *View* |
| Tempo médio de permanência | média da permanência | *View* |
| Faltas e cancelamentos por período | `AGENDAMENTO.status` | *View* |
| Agendamentos por período e categoria | `AGENDAMENTO` + `USUARIO` + `CATEGORIA_USUARIO` | *View* |
| Pagamentos confirmados e pendentes | `PAGAMENTO_PIX.status` | *View* |
| Créditos e débitos realizados | `MOVIMENTACAO.tipo` | *View* |
| Ocorrências registradas | `OCORRENCIA` | *View* |

No diagrama de Chen, esses atributos devem aparecer como **elipse tracejada** (derivados).

---

## 13. Resumo da implementação no SQL

| Tipo | Itens a acrescentar em `Banco_Restaurante_UFRB.sql` |
|---|---|
| **NOT NULL** | Todas as FKs de cardinalidade (1,1) e os campos obrigatórios citados acima (exceto `REGISTRO_ACESSO.id_funcionario`, `OCORRENCIA.id_registro` e as datas de vigência) |
| **UNIQUE** | `USUARIO.email`, `USUARIO.matricula_ou_siape`, `FUNCIONARIO.email_institucional`, `AGENDAMENTO(id_usuario, id_horario)`, hash/comprovante do pagamento |
| **CHECK** | Domínios de status (RN-01); `valor > 0`; `capacidade_maxima > 0`; `termino > inicio`; `saldo >= 0`; justificativa obrigatória na rejeição; regras de crédito/débito; vigência da penalidade |
| **DEFAULT** | `PAGAMENTO_PIX.status = 'AGUARDANDO_CONFERENCIA'`; `CARTEIRA.saldo = 0`; datas de criação com `CURRENT_TIMESTAMP` |
| **TRIGGER** | Crédito automático na confirmação; débito no agendamento; controle de capacidade; coerência de acesso; auditoria; imutabilidade de movimentações |
| **VIEW** | Vagas, ocupação, saldo, extrato, permanência e relatórios gerenciais |
