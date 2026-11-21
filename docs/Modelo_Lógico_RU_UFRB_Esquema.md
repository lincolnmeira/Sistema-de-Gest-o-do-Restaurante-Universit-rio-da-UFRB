# Modelo Relacional — Restaurante Universitário da UFRB

**Fonte:** `DER_Restaurante_Universitario_UFRB(3).drawio`.

Convenções: **PK** = chave primária; **FK** = chave estrangeira; **UQ** = valor único.

## Relações (tabelas)
- **CATEGORIA_USUARIO**(`id_categoria` [PK], `nome`, `descricao`)
- **PERFIL_ACESSO**(`id_perfil` [PK], `nome`, `permissoes`)
- **TIPO_REFEICAO**(`id_tipo` [PK], `nome`, `valor`, `descricao`)
- **FUNCIONARIO**(`id_funcionario` [PK], `id_perfil` [FK], `nome`, `email_institucional`, `identificacao`, `status`)
- **HORARIO_ATENDIMENTO**(`id_horario` [PK], `id_tipo` [FK], `data`, `inicio`, `termino`, `capacidade_maxima`, `status`)
- **USUARIO**(`id_usuario` [PK], `id_categoria` [FK], `nome`, `email`, `contato`, `matricula_ou_siape`, `curso_ou_lotacao`, `identificacao_visitante`, `status`)
- **AGENDAMENTO**(`id_agendamento` [PK], `id_usuario` [FK], `id_horario` [FK], `data_solicitacao`, `status`, `codigo_qr` [UQ])
- **AUDITORIA**(`id_auditoria` [PK], `id_funcionario` [FK], `operacao`, `entidade_afetada`, `id_registro_afetado`, `data_hora`, `detalhes`)
- **CARTEIRA**(`id_carteira` [PK], `id_usuario` [FK, UQ], `saldo`, `data_criacao`)
- **PAGAMENTO_PIX**(`id_pagamento` [PK], `id_carteira` [FK], `id_transacao_pix` [UQ], `valor`, `data_pagamento`, `comprovante`, `status`)
- **REGISTRO_ACESSO**(`id_registro` [PK], `id_agendamento` [FK], `id_funcionario` [FK], `data_hora`, `tipo_evento`, `dispositivo`)
- **CONFERENCIA**(`id_conferencia` [PK], `id_pagamento` [FK], `id_funcionario` [FK], `data_analise`, `decisao`, `justificativa`)
- **MOVIMENTACAO**(`id_movimentacao` [PK], `id_carteira` [FK], `id_pagamento` [FK, UQ], `id_agendamento` [FK, UQ], `data_hora`, `tipo`, `valor`, `descricao`)
- **OCORRENCIA**(`id_ocorrencia` [PK], `id_usuario` [FK], `id_registro` [FK], `id_funcionario` [FK], `data_ocorrencia`, `descricao`, `regra`, `status`)
- **CONTESTACAO**(`id_contestacao` [PK], `id_ocorrencia` [FK], `id_usuario` [FK], `data_envio`, `justificativa`, `status`)
- **PENALIDADE**(`id_penalidade` [PK], `id_ocorrencia` [FK], `id_funcionario` [FK], `tipo`, `data_aplicacao`, `inicio_vigencia`, `fim_vigencia`, `justificativa`, `status`)

## Relacionamentos e referências
- **TIPO_REFEICAO** → **HORARIO_ATENDIMENTO** — define (1:N); `HORARIO_ATENDIMENTO.id_tipo` referencia `TIPO_REFEICAO.id_tipo`.
- **CATEGORIA_USUARIO** → **USUARIO** — classifica (1:N); `USUARIO.id_categoria` referencia `CATEGORIA_USUARIO.id_categoria`.
- **PERFIL_ACESSO** → **FUNCIONARIO** — atribui (1:N); `FUNCIONARIO.id_perfil` referencia `PERFIL_ACESSO.id_perfil`.
- **HORARIO_ATENDIMENTO** → **AGENDAMENTO** — recebe (1:N); `AGENDAMENTO.id_horario` referencia `HORARIO_ATENDIMENTO.id_horario`.
- **USUARIO** → **AGENDAMENTO** — realiza (1:N); `AGENDAMENTO.id_usuario` referencia `USUARIO.id_usuario`.
- **USUARIO** → **CARTEIRA** — possui (1:1); `CARTEIRA.id_usuario` referencia `USUARIO.id_usuario`.
- **FUNCIONARIO** → **AUDITORIA** — executa (1:N); `AUDITORIA.id_funcionario` referencia `FUNCIONARIO.id_funcionario`.
- **AGENDAMENTO** → **REGISTRO_ACESSO** — possui (1:0..N); `REGISTRO_ACESSO.id_agendamento` referencia `AGENDAMENTO.id_agendamento`.
- **FUNCIONARIO** → **REGISTRO_ACESSO** — registra (1:0..N); `REGISTRO_ACESSO.id_funcionario` referencia `FUNCIONARIO.id_funcionario`.
- **REGISTRO_ACESSO** → **OCORRENCIA** — origina (1:0..N); `OCORRENCIA.id_registro` referencia `REGISTRO_ACESSO.id_registro`.
- **FUNCIONARIO** → **OCORRENCIA** — registra (1:0..N); `OCORRENCIA.id_funcionario` referencia `FUNCIONARIO.id_funcionario`.
- **USUARIO** → **OCORRENCIA** — recebe (1:N); `OCORRENCIA.id_usuario` referencia `USUARIO.id_usuario`.
- **FUNCIONARIO** → **CONFERENCIA** — realiza (1:N); `CONFERENCIA.id_funcionario` referencia `FUNCIONARIO.id_funcionario`.
- **PAGAMENTO_PIX** → **CONFERENCIA** — submetido (1:0..N); `CONFERENCIA.id_pagamento` referencia `PAGAMENTO_PIX.id_pagamento`.
- **CARTEIRA** → **PAGAMENTO_PIX** — recebe (1:N); `PAGAMENTO_PIX.id_carteira` referencia `CARTEIRA.id_carteira`.
- **CARTEIRA** → **MOVIMENTACAO** — registra (1:N); `MOVIMENTACAO.id_carteira` referencia `CARTEIRA.id_carteira`.
- **PAGAMENTO_PIX** → **MOVIMENTACAO** — gera crédito (1:0..1); `MOVIMENTACAO.id_pagamento` referencia `PAGAMENTO_PIX.id_pagamento`.
- **AGENDAMENTO** → **MOVIMENTACAO** — gera débito (1:0..1); `MOVIMENTACAO.id_agendamento` referencia `AGENDAMENTO.id_agendamento`.
- **OCORRENCIA** → **PENALIDADE** — resulta (1:0..N); `PENALIDADE.id_ocorrencia` referencia `OCORRENCIA.id_ocorrencia`.
- **FUNCIONARIO** → **PENALIDADE** — aplica (1:N); `PENALIDADE.id_funcionario` referencia `FUNCIONARIO.id_funcionario`.
- **OCORRENCIA** → **CONTESTACAO** — recebe (1:0..N); `CONTESTACAO.id_ocorrencia` referencia `OCORRENCIA.id_ocorrencia`.
- **USUARIO** → **CONTESTACAO** — realiza (1:N); `CONTESTACAO.id_usuario` referencia `USUARIO.id_usuario`.

## Observações de implementação

- O DER identifica campos genéricos como `string` e `decimal`, mas não define comprimento, nulabilidade nem todas as restrições: o SQL propõe tipos compatíveis com MySQL 8.
- `CARTEIRA.id_usuario` é exclusivo para refletir o relacionamento 1:1.
- `MOVIMENTACAO.id_pagamento` e `MOVIMENTACAO.id_agendamento` são exclusivos para refletir as cardinalidades 1:0..1.
- Os campos `AGENDAMENTO.codigo_qr` e `PAGAMENTO_PIX.id_transacao_pix` são únicos, conforme marcados no arquivo.
- Não foram criadas tabelas ou especializações que não estejam presentes no DER original.
