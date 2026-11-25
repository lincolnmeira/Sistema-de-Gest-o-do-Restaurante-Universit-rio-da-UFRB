-- Dados ficticios para demonstracao do modelo do Restaurante Universitario.
-- Execute depois de Banco_Restaurante_UFRB.sql (MySQL 8+).
-- Os IDs sao informados explicitamente para manter as referencias previsiveis.

USE ru_ufrb;

START TRANSACTION;

INSERT INTO `CATEGORIA_USUARIO` (`id_categoria`, `nome`, `descricao`) VALUES
(1, 'Discente', 'Estudante regularmente matriculado na UFRB'),
(2, 'Docente', 'Servidor docente da UFRB'),
(3, 'Tecnico-administrativo', 'Servidor tecnico-administrativo da UFRB'),
(4, 'Visitante', 'Pessoa visitante autorizada a utilizar o RU');

INSERT INTO `PERFIL_ACESSO` (`id_perfil`, `nome`, `permissoes`) VALUES
(1, 'Administrador', 'Gerenciar usuarios, horarios, pagamentos, acessos e penalidades'),
(2, 'Atendente', 'Registrar acessos e consultar agendamentos'),
(3, 'Financeiro', 'Conferir pagamentos Pix e consultar carteiras');

INSERT INTO `TIPO_REFEICAO` (`id_tipo`, `nome`, `valor`, `descricao`) VALUES
(1, 'Almoco', 8.00, 'Refeicao do periodo do almoco'),
(2, 'Jantar', 6.00, 'Refeicao do periodo noturno');

INSERT INTO `FUNCIONARIO` (`id_funcionario`, `id_perfil`, `nome`, `email_institucional`, `identificacao`, `status`) VALUES
(1, 1, 'Mariana Souza', 'mariana.souza@ufrb.edu.br', 'SIAPE 100001', 'ATIVO'),
(2, 2, 'Joao Santos', 'joao.santos@ufrb.edu.br', 'SIAPE 100002', 'ATIVO'),
(3, 3, 'Aline Costa', 'aline.costa@ufrb.edu.br', 'SIAPE 100003', 'ATIVO');

INSERT INTO `HORARIO_ATENDIMENTO` (`id_horario`, `id_tipo`, `data`, `inicio`, `termino`, `capacidade_maxima`, `status`) VALUES
(1, 1, '2026-11-26', '11:00:00', '13:30:00', 300, 'ABERTO'),
(2, 2, '2026-11-26', '17:30:00', '19:30:00', 220, 'ABERTO'),
(3, 1, '2026-11-25', '11:00:00', '13:30:00', 300, 'ENCERRADO');

INSERT INTO `USUARIO` (`id_usuario`, `id_categoria`, `nome`, `email`, `contato`, `matricula_ou_siape`, `curso_ou_lotacao`, `identificacao_visitante`, `status`) VALUES
(1, 1, 'Lucas Almeida', 'lucas.almeida@aluno.ufrb.edu.br', '(75) 99911-2200', '202610001', 'Engenharia de Computacao', NULL, 'ATIVO'),
(2, 1, 'Beatriz Santos', 'beatriz.santos@aluno.ufrb.edu.br', '(75) 99922-3300', '202610002', 'Nutrição', NULL, 'ATIVO'),
(3, 2, 'Rafael Oliveira', 'rafael.oliveira@ufrb.edu.br', '(75) 99933-4400', 'SIAPE 200001', 'Centro de Ciencias Agrarias', NULL, 'ATIVO'),
(4, 3, 'Camila Ferreira', 'camila.ferreira@ufrb.edu.br', '(75) 99944-5500', 'SIAPE 200002', 'Biblioteca Universitaria', NULL, 'ATIVO'),
(5, 4, 'Pedro Lima', 'pedro.lima@email.com', '(75) 99955-6600', NULL, NULL, 'Visitante - evento academico 2026', 'ATIVO');

INSERT INTO `AGENDAMENTO` (`id_agendamento`, `id_usuario`, `id_horario`, `data_solicitacao`, `status`, `codigo_qr`) VALUES
(1, 1, 3, '2026-11-24 09:15:00', 'ATENDIDO', 'RU-20261125-0001'),
(2, 1, 1, '2026-11-25 08:10:00', 'AGENDADO', 'RU-20261126-0002'),
(3, 3, 1, '2026-11-25 08:25:00', 'AGENDADO', 'RU-20261126-0003'),
(4, 2, 2, '2026-11-25 09:00:00', 'CANCELADO', 'RU-20261126-0004');

INSERT INTO `AUDITORIA` (`id_auditoria`, `id_funcionario`, `operacao`, `entidade_afetada`, `id_registro_afetado`, `data_hora`, `detalhes`) VALUES
(1, 1, 'CADASTRO', 'HORARIO_ATENDIMENTO', 1, '2026-11-24 14:00:00', 'Horario de almoco aberto para 26/11/2026'),
(2, 3, 'CONFERENCIA', 'PAGAMENTO_PIX', 1, '2026-11-24 15:05:00', 'Pagamento confirmado e creditado na carteira');

INSERT INTO `CARTEIRA` (`id_carteira`, `id_usuario`, `saldo`, `data_criacao`) VALUES
(1, 1, 22.00, '2026-10-01 08:00:00'),
(2, 2, 0.00, '2026-10-02 08:00:00'),
(3, 3, 12.00, '2026-10-03 08:00:00'),
(4, 4, 0.00, '2026-10-04 08:00:00'),
(5, 5, 0.00, '2026-10-05 08:00:00');

INSERT INTO `PAGAMENTO_PIX` (`id_pagamento`, `id_carteira`, `id_transacao_pix`, `valor`, `data_pagamento`, `comprovante`, `status`) VALUES
(1, 1, 'E1234567820261124A1B2C3D4E5F6G7H8', 30.00, '2026-11-24 14:30:00', 'comprovante_pix_001.pdf', 'CONFIRMADO'),
(2, 2, 'E8765432120261124H8G7F6E5D4C3B2A1', 20.00, '2026-11-24 16:10:00', 'comprovante_pix_002.pdf', 'AGUARDANDO_CONFERENCIA'),
(3, 3, 'E9988776620261124C1D2E3F4G5H6I7J8', 20.00, '2026-11-24 17:00:00', 'comprovante_pix_003.pdf', 'CONFIRMADO');

INSERT INTO `REGISTRO_ACESSO` (`id_registro`, `id_agendamento`, `id_funcionario`, `data_hora`, `tipo_evento`, `dispositivo`) VALUES
(1, 1, 2, '2026-11-25 11:42:00', 'ENTRADA', 'Leitor QR - Refeitorio'),
(2, 1, 2, '2026-11-25 12:18:00', 'SAIDA', 'Leitor QR - Refeitorio');

INSERT INTO `CONFERENCIA` (`id_conferencia`, `id_pagamento`, `id_funcionario`, `data_analise`, `decisao`, `justificativa`) VALUES
(1, 1, 3, '2026-11-24 15:05:00', 'CONFIRMADO', 'Transacao localizada e valor validado.'),
(2, 3, 3, '2026-11-24 17:10:00', 'CONFIRMADO', 'Transacao localizada e valor validado.');

INSERT INTO `MOVIMENTACAO` (`id_movimentacao`, `id_carteira`, `id_pagamento`, `id_agendamento`, `data_hora`, `tipo`, `valor`, `descricao`) VALUES
(1, 1, 1, NULL, '2026-11-24 15:05:00', 'CREDITO', 30.00, 'Credito referente ao pagamento Pix confirmado'),
(2, 1, NULL, 1, '2026-11-25 11:00:00', 'DEBITO', 8.00, 'Debito da refeicao: almoco de 25/11/2026'),
(3, 1, NULL, 2, '2026-11-25 08:10:00', 'DEBITO', 8.00, 'Reserva da refeicao: almoco de 26/11/2026'),
(4, 3, 3, NULL, '2026-11-24 17:10:00', 'CREDITO', 20.00, 'Credito referente ao pagamento Pix confirmado'),
(5, 3, NULL, 3, '2026-11-25 08:25:00', 'DEBITO', 8.00, 'Reserva da refeicao: almoco de 26/11/2026');

INSERT INTO `OCORRENCIA` (`id_ocorrencia`, `id_usuario`, `id_registro`, `id_funcionario`, `data_ocorrencia`, `descricao`, `regra`, `status`) VALUES
(1, 1, 1, 1, '2026-11-25 13:00:00', 'Registro demonstrativo de orientacao sobre uso individual do codigo QR.', 'Uso individual do codigo QR', 'IMPROCEDENTE');

INSERT INTO `CONTESTACAO` (`id_contestacao`, `id_ocorrencia`, `id_usuario`, `data_envio`, `justificativa`, `status`) VALUES
(1, 1, 1, '2026-11-25 13:20:00', 'Informei que o codigo QR foi apresentado somente para minha propria entrada.', 'ACEITA');

INSERT INTO `PENALIDADE` (`id_penalidade`, `id_ocorrencia`, `id_funcionario`, `tipo`, `data_aplicacao`, `inicio_vigencia`, `fim_vigencia`, `justificativa`, `status`) VALUES
(1, 1, 1, 'Advertencia', '2026-11-25', NULL, NULL, 'Registro historico de exemplo, posteriormente revogado apos analise.', 'REVOGADA');

COMMIT;
