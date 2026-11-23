# Sistema de Gestão do Restaurante Universitário da UFRB

Projeto da disciplina de Banco de Dados da Universidade Federal do Recôncavo da Bahia (UFRB).

O objetivo é modelar e implementar o banco de dados de um sistema de gestão do
Restaurante Universitário (RU), cobrindo cadastro de usuários, agendamento de
refeições, carteira de créditos com pagamentos via Pix, controle de acesso e
permanência, ocorrências e penalidades, e administração da demanda.

## Conteúdo do repositório

| Arquivo | Descrição |
|---|---|
| `Minimundo.pdf` | Descrição do problema |
| `Modelo_Conceitual.pdf` | Diagrama entidade-relacionamento, com entidades em retângulos e relacionamentos representados por dois triângulos |
| `Modelo_Lógico.md` | Esquema relacional com chaves primárias e estrangeiras |
| `Regras_de_Negocio.md` | Restrições e regras de negócio do sistema |
| `Banco_Restaurante_UFRB.sql` | Script de criação do banco físico (MySQL 8+) |

## Como executar

1. Instale o MySQL 8 ou superior.
2. Execute o script: `mysql -u usuario -p < Banco_Restaurante_UFRB.sql`
3. O banco `ru_ufrb` será criado com todas as tabelas.

## Principais decisões de projeto

- Pagamentos são tratados como créditos na carteira do usuário, separados dos
  agendamentos. Um pagamento pode financiar várias refeições.
- Cada movimentação financeira tem origem em um pagamento (crédito) ou em um
  agendamento (débito).

## Equipe

- Rafael Silva
- Lincoln Meira
- João Pedro Silva
- Mateus Cardoso
- Luiz Henrique


**Disciplina:** Banco de Dados | **Professor(a):** _(Lincoln, Mateus, João, Rafael e Luiz)_ | **Semestre:** _(ex.: 2026.2)_
