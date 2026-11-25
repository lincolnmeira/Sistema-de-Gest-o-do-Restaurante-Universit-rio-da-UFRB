USE ru_ufrb;

SET @data_inicio = '2026-11-01';
SET @data_fim = '2026-12-01'; -- limite exclusivo

-- 1. Ocupacao por horario: reservas ativas, vagas disponiveis e atendimentos.
SELECT
    h.id_horario,
    h.data,
    t.nome AS refeicao,
    h.inicio,
    h.termino,
    h.capacidade_maxima,
    SUM(CASE WHEN a.status IN ('AGENDADO', 'ATENDIDO') THEN 1 ELSE 0 END) AS vagas_reservadas,
    h.capacidade_maxima - SUM(CASE WHEN a.status IN ('AGENDADO', 'ATENDIDO') THEN 1 ELSE 0 END) AS vagas_disponiveis,
    SUM(CASE WHEN a.status = 'ATENDIDO' THEN 1 ELSE 0 END) AS atendimentos,
    ROUND(100.0 * SUM(CASE WHEN a.status IN ('AGENDADO', 'ATENDIDO') THEN 1 ELSE 0 END)
          / NULLIF(h.capacidade_maxima, 0), 1) AS ocupacao_percentual
FROM HORARIO_ATENDIMENTO h
JOIN TIPO_REFEICAO t ON t.id_tipo = h.id_tipo
LEFT JOIN AGENDAMENTO a ON a.id_horario = h.id_horario
WHERE h.data >= @data_inicio AND h.data < @data_fim
GROUP BY h.id_horario, h.data, t.nome, h.inicio, h.termino, h.capacidade_maxima
ORDER BY h.data, h.inicio;

-- 2. Agendamentos por dia, refeicao e categoria de usuario.
SELECT
    h.data,
    t.nome AS refeicao,
    c.nome AS categoria,
    COUNT(*) AS total_agendamentos,
    SUM(a.status = 'ATENDIDO') AS atendidos,
    SUM(a.status = 'AGENDADO') AS ainda_agendados,
    SUM(a.status = 'FALTA') AS faltas,
    SUM(a.status = 'CANCELADO') AS cancelados
FROM AGENDAMENTO a
JOIN HORARIO_ATENDIMENTO h ON h.id_horario = a.id_horario
JOIN TIPO_REFEICAO t ON t.id_tipo = h.id_tipo
JOIN USUARIO u ON u.id_usuario = a.id_usuario
JOIN CATEGORIA_USUARIO c ON c.id_categoria = u.id_categoria
WHERE h.data >= @data_inicio AND h.data < @data_fim
GROUP BY h.data, t.nome, c.nome
ORDER BY h.data, t.nome, c.nome;

-- 3. Faltas e cancelamentos por periodo e refeicao.
SELECT
    h.data,
    t.nome AS refeicao,
    SUM(a.status = 'FALTA') AS faltas,
    SUM(a.status = 'CANCELADO') AS cancelamentos,
    COUNT(*) AS total_agendamentos,
    ROUND(100.0 * SUM(a.status = 'FALTA') / NULLIF(COUNT(*), 0), 1) AS percentual_faltas
FROM AGENDAMENTO a
JOIN HORARIO_ATENDIMENTO h ON h.id_horario = a.id_horario
JOIN TIPO_REFEICAO t ON t.id_tipo = h.id_tipo
WHERE h.data >= @data_inicio AND h.data < @data_fim
GROUP BY h.data, t.nome
ORDER BY h.data, t.nome;

-- 4. Pagamentos Pix aguardando conferencia, com identificacao do usuario.
SELECT
    p.id_pagamento,
    u.id_usuario,
    u.nome AS usuario,
    p.valor,
    p.data_pagamento,
    p.id_transacao_pix
FROM PAGAMENTO_PIX p
JOIN CARTEIRA c ON c.id_carteira = p.id_carteira
JOIN USUARIO u ON u.id_usuario = c.id_usuario
WHERE p.status = 'AGUARDANDO_CONFERENCIA'
ORDER BY p.data_pagamento;

-- 5. Extrato de uma carteira. Informe o id da carteira em @id_carteira.
SET @id_carteira = 1;
SELECT
    m.data_hora,
    m.tipo,
    m.valor,
    m.descricao,
    m.id_pagamento,
    m.id_agendamento
FROM MOVIMENTACAO m
WHERE m.id_carteira = @id_carteira
ORDER BY m.data_hora, m.id_movimentacao;

-- 6. Ocorrencias abertas ou em analise e quantidade de contestacoes recebidas.
SELECT
    o.id_ocorrencia,
    u.nome AS usuario,
    o.data_ocorrencia,
    o.regra,
    o.descricao,
    o.status,
    (SELECT COUNT(*) FROM CONTESTACAO ct WHERE ct.id_ocorrencia = o.id_ocorrencia) AS total_contestacoes
FROM OCORRENCIA o
JOIN USUARIO u ON u.id_usuario = o.id_usuario
WHERE o.status IN ('ABERTA', 'EM_ANALISE')
ORDER BY o.data_ocorrencia;

-- 7. Permanencia: associa cada entrada a primeira saida posterior do mesmo agendamento.
-- Entradas sem saida ainda ficam visiveis, com permanencia NULL.
SELECT
    a.id_agendamento,
    u.nome AS usuario,
    h.data AS data_refeicao,
    t.nome AS refeicao,
    entrada.data_hora AS hora_entrada,
    saida.data_hora AS hora_saida,
    TIMESTAMPDIFF(MINUTE, entrada.data_hora, saida.data_hora) AS permanencia_minutos
FROM REGISTRO_ACESSO entrada
JOIN AGENDAMENTO a ON a.id_agendamento = entrada.id_agendamento
JOIN USUARIO u ON u.id_usuario = a.id_usuario
JOIN HORARIO_ATENDIMENTO h ON h.id_horario = a.id_horario
JOIN TIPO_REFEICAO t ON t.id_tipo = h.id_tipo
LEFT JOIN REGISTRO_ACESSO saida
    ON saida.id_registro = (
        SELECT r2.id_registro
        FROM REGISTRO_ACESSO r2
        WHERE r2.id_agendamento = entrada.id_agendamento
          AND r2.tipo_evento = 'SAIDA'
          AND r2.data_hora >= entrada.data_hora
        ORDER BY r2.data_hora, r2.id_registro
        LIMIT 1
    )
WHERE entrada.tipo_evento = 'ENTRADA'
  AND entrada.data_hora >= @data_inicio
  AND entrada.data_hora < @data_fim
ORDER BY entrada.data_hora;
