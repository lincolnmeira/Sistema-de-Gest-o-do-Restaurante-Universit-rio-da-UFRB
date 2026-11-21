-- Modelo relacional do Restaurante Universitario da UFRB
-- Construido a partir de DER_Restaurante_Universitario_UFRB(3).drawio
-- Tipos de string, tamanhos e nulabilidade nao constam no diagrama original;
-- as escolhas abaixo sao propostas para MySQL 8+. As cardinalidades 1:1 e
-- 1:0..1 sao representadas por UNIQUE sobre chaves estrangeiras.

CREATE DATABASE IF NOT EXISTS ru_ufrb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ru_ufrb;

-- Ordem de criacao respeita as dependencias de chaves estrangeiras.

CREATE TABLE `CATEGORIA_USUARIO` (
  `id_categoria` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(255),
  `descricao` TEXT,
  PRIMARY KEY (`id_categoria`)
) ENGINE=InnoDB;

CREATE TABLE `PERFIL_ACESSO` (
  `id_perfil` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(255),
  `permissoes` TEXT,
  PRIMARY KEY (`id_perfil`)
) ENGINE=InnoDB;

CREATE TABLE `TIPO_REFEICAO` (
  `id_tipo` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(255),
  `valor` DECIMAL(12,2),
  `descricao` TEXT,
  PRIMARY KEY (`id_tipo`)
) ENGINE=InnoDB;

CREATE TABLE `FUNCIONARIO` (
  `id_funcionario` INT NOT NULL AUTO_INCREMENT,
  `id_perfil` INT,
  `nome` VARCHAR(255),
  `email_institucional` VARCHAR(254),
  `identificacao` VARCHAR(255),
  `status` VARCHAR(255),
  PRIMARY KEY (`id_funcionario`),
  CONSTRAINT `fk_funcionario_id_perfil` FOREIGN KEY (`id_perfil`) REFERENCES `PERFIL_ACESSO` (`id_perfil`)
) ENGINE=InnoDB;

CREATE TABLE `HORARIO_ATENDIMENTO` (
  `id_horario` INT NOT NULL AUTO_INCREMENT,
  `id_tipo` INT,
  `data` DATE,
  `inicio` TIME,
  `termino` TIME,
  `capacidade_maxima` INT,
  `status` VARCHAR(255),
  PRIMARY KEY (`id_horario`),
  CONSTRAINT `fk_horario_atendimento_id_tipo` FOREIGN KEY (`id_tipo`) REFERENCES `TIPO_REFEICAO` (`id_tipo`)
) ENGINE=InnoDB;

CREATE TABLE `USUARIO` (
  `id_usuario` INT NOT NULL AUTO_INCREMENT,
  `id_categoria` INT,
  `nome` VARCHAR(255),
  `email` VARCHAR(254),
  `contato` VARCHAR(255),
  `matricula_ou_siape` VARCHAR(255),
  `curso_ou_lotacao` VARCHAR(255),
  `identificacao_visitante` VARCHAR(255),
  `status` VARCHAR(255),
  PRIMARY KEY (`id_usuario`),
  CONSTRAINT `fk_usuario_id_categoria` FOREIGN KEY (`id_categoria`) REFERENCES `CATEGORIA_USUARIO` (`id_categoria`)
) ENGINE=InnoDB;

CREATE TABLE `AGENDAMENTO` (
  `id_agendamento` INT NOT NULL AUTO_INCREMENT,
  `id_usuario` INT,
  `id_horario` INT,
  `data_solicitacao` DATETIME,
  `status` VARCHAR(255),
  `codigo_qr` VARCHAR(255),
  PRIMARY KEY (`id_agendamento`),
  CONSTRAINT `fk_agendamento_id_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `USUARIO` (`id_usuario`),
  CONSTRAINT `fk_agendamento_id_horario` FOREIGN KEY (`id_horario`) REFERENCES `HORARIO_ATENDIMENTO` (`id_horario`),
  CONSTRAINT `uq_agendamento_codigo_qr` UNIQUE (`codigo_qr`)
) ENGINE=InnoDB;

CREATE TABLE `AUDITORIA` (
  `id_auditoria` INT NOT NULL AUTO_INCREMENT,
  `id_funcionario` INT,
  `operacao` VARCHAR(255),
  `entidade_afetada` VARCHAR(255),
  `id_registro_afetado` INT,
  `data_hora` DATETIME,
  `detalhes` TEXT,
  PRIMARY KEY (`id_auditoria`),
  CONSTRAINT `fk_auditoria_id_funcionario` FOREIGN KEY (`id_funcionario`) REFERENCES `FUNCIONARIO` (`id_funcionario`)
) ENGINE=InnoDB;

CREATE TABLE `CARTEIRA` (
  `id_carteira` INT NOT NULL AUTO_INCREMENT,
  `id_usuario` INT,
  `saldo` DECIMAL(12,2),
  `data_criacao` DATETIME,
  PRIMARY KEY (`id_carteira`),
  CONSTRAINT `uq_carteira_id_usuario` UNIQUE (`id_usuario`),
  CONSTRAINT `fk_carteira_id_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `USUARIO` (`id_usuario`)
) ENGINE=InnoDB;

CREATE TABLE `PAGAMENTO_PIX` (
  `id_pagamento` INT NOT NULL AUTO_INCREMENT,
  `id_carteira` INT,
  `id_transacao_pix` VARCHAR(255),
  `valor` DECIMAL(12,2),
  `data_pagamento` DATETIME,
  `comprovante` VARCHAR(255),
  `status` VARCHAR(255),
  PRIMARY KEY (`id_pagamento`),
  CONSTRAINT `fk_pagamento_pix_id_carteira` FOREIGN KEY (`id_carteira`) REFERENCES `CARTEIRA` (`id_carteira`),
  CONSTRAINT `uq_pagamento_pix_id_transacao_pix` UNIQUE (`id_transacao_pix`)
) ENGINE=InnoDB;

CREATE TABLE `REGISTRO_ACESSO` (
  `id_registro` INT NOT NULL AUTO_INCREMENT,
  `id_agendamento` INT,
  `id_funcionario` INT,
  `data_hora` DATETIME,
  `tipo_evento` VARCHAR(255),
  `dispositivo` VARCHAR(255),
  PRIMARY KEY (`id_registro`),
  CONSTRAINT `fk_registro_acesso_id_agendamento` FOREIGN KEY (`id_agendamento`) REFERENCES `AGENDAMENTO` (`id_agendamento`),
  CONSTRAINT `fk_registro_acesso_id_funcionario` FOREIGN KEY (`id_funcionario`) REFERENCES `FUNCIONARIO` (`id_funcionario`)
) ENGINE=InnoDB;

CREATE TABLE `CONFERENCIA` (
  `id_conferencia` INT NOT NULL AUTO_INCREMENT,
  `id_pagamento` INT,
  `id_funcionario` INT,
  `data_analise` DATETIME,
  `decisao` VARCHAR(255),
  `justificativa` TEXT,
  PRIMARY KEY (`id_conferencia`),
  CONSTRAINT `fk_conferencia_id_pagamento` FOREIGN KEY (`id_pagamento`) REFERENCES `PAGAMENTO_PIX` (`id_pagamento`),
  CONSTRAINT `fk_conferencia_id_funcionario` FOREIGN KEY (`id_funcionario`) REFERENCES `FUNCIONARIO` (`id_funcionario`)
) ENGINE=InnoDB;

CREATE TABLE `MOVIMENTACAO` (
  `id_movimentacao` INT NOT NULL AUTO_INCREMENT,
  `id_carteira` INT,
  `id_pagamento` INT,
  `id_agendamento` INT,
  `data_hora` DATETIME,
  `tipo` VARCHAR(255),
  `valor` DECIMAL(12,2),
  `descricao` TEXT,
  PRIMARY KEY (`id_movimentacao`),
  CONSTRAINT `fk_movimentacao_id_carteira` FOREIGN KEY (`id_carteira`) REFERENCES `CARTEIRA` (`id_carteira`),
  CONSTRAINT `uq_movimentacao_id_pagamento` UNIQUE (`id_pagamento`),
  CONSTRAINT `fk_movimentacao_id_pagamento` FOREIGN KEY (`id_pagamento`) REFERENCES `PAGAMENTO_PIX` (`id_pagamento`),
  CONSTRAINT `uq_movimentacao_id_agendamento` UNIQUE (`id_agendamento`),
  CONSTRAINT `fk_movimentacao_id_agendamento` FOREIGN KEY (`id_agendamento`) REFERENCES `AGENDAMENTO` (`id_agendamento`)
) ENGINE=InnoDB;

CREATE TABLE `OCORRENCIA` (
  `id_ocorrencia` INT NOT NULL AUTO_INCREMENT,
  `id_usuario` INT,
  `id_registro` INT,
  `id_funcionario` INT,
  `data_ocorrencia` DATETIME,
  `descricao` TEXT,
  `regra` VARCHAR(255),
  `status` VARCHAR(255),
  PRIMARY KEY (`id_ocorrencia`),
  CONSTRAINT `fk_ocorrencia_id_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `USUARIO` (`id_usuario`),
  CONSTRAINT `fk_ocorrencia_id_registro` FOREIGN KEY (`id_registro`) REFERENCES `REGISTRO_ACESSO` (`id_registro`),
  CONSTRAINT `fk_ocorrencia_id_funcionario` FOREIGN KEY (`id_funcionario`) REFERENCES `FUNCIONARIO` (`id_funcionario`)
) ENGINE=InnoDB;

CREATE TABLE `CONTESTACAO` (
  `id_contestacao` INT NOT NULL AUTO_INCREMENT,
  `id_ocorrencia` INT,
  `id_usuario` INT,
  `data_envio` DATETIME,
  `justificativa` TEXT,
  `status` VARCHAR(255),
  PRIMARY KEY (`id_contestacao`),
  CONSTRAINT `fk_contestacao_id_ocorrencia` FOREIGN KEY (`id_ocorrencia`) REFERENCES `OCORRENCIA` (`id_ocorrencia`),
  CONSTRAINT `fk_contestacao_id_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `USUARIO` (`id_usuario`)
) ENGINE=InnoDB;

CREATE TABLE `PENALIDADE` (
  `id_penalidade` INT NOT NULL AUTO_INCREMENT,
  `id_ocorrencia` INT,
  `id_funcionario` INT,
  `tipo` VARCHAR(255),
  `data_aplicacao` DATE,
  `inicio_vigencia` DATE,
  `fim_vigencia` DATE,
  `justificativa` TEXT,
  `status` VARCHAR(255),
  PRIMARY KEY (`id_penalidade`),
  CONSTRAINT `fk_penalidade_id_ocorrencia` FOREIGN KEY (`id_ocorrencia`) REFERENCES `OCORRENCIA` (`id_ocorrencia`),
  CONSTRAINT `fk_penalidade_id_funcionario` FOREIGN KEY (`id_funcionario`) REFERENCES `FUNCIONARIO` (`id_funcionario`)
) ENGINE=InnoDB;
