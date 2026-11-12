-- ============================================
-- Projeto Fisico - Lava-jato
-- SQL padrao (SQLite) - roda no myCompiler SQL Editor
-- ============================================

PRAGMA foreign_keys = OFF;

DROP TABLE IF EXISTS avaliacao;
DROP TABLE IF EXISTS servico_fornecedor;
DROP TABLE IF EXISTS fornecedor;
DROP TABLE IF EXISTS pagamento;
DROP TABLE IF EXISTS agendamento;
DROP TABLE IF EXISTS higienizacao;
DROP TABLE IF EXISTS polimento;
DROP TABLE IF EXISTS lavagem;
DROP TABLE IF EXISTS atividade;
DROP TABLE IF EXISTS comissao;
DROP TABLE IF EXISTS servico;
DROP TABLE IF EXISTS especialista;
DROP TABLE IF EXISTS funcionario;
DROP TABLE IF EXISTS pessoa_juridica;
DROP TABLE IF EXISTS pessoa_fisica;
DROP TABLE IF EXISTS cliente;

PRAGMA foreign_keys = ON;

-- ========== TABELAS ==========

CREATE TABLE cliente (
    id_cliente      INTEGER PRIMARY KEY AUTOINCREMENT,
    nome            VARCHAR(120) NOT NULL,
    cpf             VARCHAR(14) UNIQUE,
    email           VARCHAR(120) NOT NULL,
    telefone        VARCHAR(20),
    data_nascimento DATE,
    tipo            TEXT NOT NULL CHECK (tipo IN ('PF','PJ'))
);

CREATE TABLE pessoa_fisica (
    id_cliente INTEGER PRIMARY KEY,
    cnh        VARCHAR(20),
    veiculo    VARCHAR(100),
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente) ON DELETE CASCADE
);

CREATE TABLE pessoa_juridica (
    id_cliente          INTEGER PRIMARY KEY,
    cnpj                VARCHAR(18) NOT NULL UNIQUE,
    contato_empresarial VARCHAR(120),
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente) ON DELETE CASCADE
);

CREATE TABLE funcionario (
    id_func  INTEGER PRIMARY KEY AUTOINCREMENT,
    nome     VARCHAR(120) NOT NULL,
    cpf      VARCHAR(14) NOT NULL UNIQUE,
    email    VARCHAR(120),
    cargo    VARCHAR(60),
    salario  DECIMAL(10,2) NOT NULL DEFAULT 0
);

CREATE TABLE especialista (
    id_espe      INTEGER PRIMARY KEY AUTOINCREMENT,
    nome         VARCHAR(120) NOT NULL,
    cpf          VARCHAR(14) NOT NULL UNIQUE,
    email        VARCHAR(120),
    curriculo    TEXT,
    area_atuacao VARCHAR(100)
);

CREATE TABLE servico (
    id_servico  INTEGER PRIMARY KEY AUTOINCREMENT,
    nome        VARCHAR(120) NOT NULL,
    data_inicio DATE NOT NULL,
    data_fim    DATE,
    local       VARCHAR(120),
    descricao   TEXT
);

CREATE TABLE comissao (
    id_servico INTEGER NOT NULL,
    id_func    INTEGER NOT NULL,
    PRIMARY KEY (id_servico, id_func),
    FOREIGN KEY (id_servico) REFERENCES servico(id_servico) ON DELETE CASCADE,
    FOREIGN KEY (id_func)    REFERENCES funcionario(id_func)
);

CREATE TABLE atividade (
    id_ativ             INTEGER PRIMARY KEY AUTOINCREMENT,
    id_servico          INTEGER NOT NULL,
    id_func_responsavel INTEGER NOT NULL,
    titulo              VARCHAR(120) NOT NULL,
    duracao_min         INTEGER NOT NULL,
    data_atividade      DATE NOT NULL,
    horario             TIME NOT NULL,
    box                 VARCHAR(30) NOT NULL,
    tipo                TEXT NOT NULL CHECK (tipo IN ('LAVAGEM','POLIMENTO','HIGIENIZACAO')),
    FOREIGN KEY (id_servico)          REFERENCES servico(id_servico),
    FOREIGN KEY (id_func_responsavel) REFERENCES funcionario(id_func)
);

CREATE TABLE lavagem (
    id_ativ      INTEGER PRIMARY KEY,
    tipo_produto VARCHAR(100) NOT NULL,
    id_espe      INTEGER NOT NULL,
    FOREIGN KEY (id_ativ) REFERENCES atividade(id_ativ) ON DELETE CASCADE,
    FOREIGN KEY (id_espe) REFERENCES especialista(id_espe)
);

CREATE TABLE polimento (
    id_ativ           INTEGER PRIMARY KEY,
    maquina_utilizada VARCHAR(100),
    cera              VARCHAR(100),
    FOREIGN KEY (id_ativ) REFERENCES atividade(id_ativ) ON DELETE CASCADE
);

CREATE TABLE higienizacao (
    id_ativ                  INTEGER PRIMARY KEY,
    custo_adicional_produto  DECIMAL(10,2) DEFAULT 0,
    FOREIGN KEY (id_ativ) REFERENCES atividade(id_ativ) ON DELETE CASCADE
);

CREATE TABLE agendamento (
    id_agendamento   INTEGER PRIMARY KEY AUTOINCREMENT,
    id_cliente       INTEGER NOT NULL,
    id_ativ          INTEGER NOT NULL,
    data_agendamento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status           TEXT DEFAULT 'AGENDADO'
                     CHECK (status IN ('AGENDADO','CONCLUIDO','CANCELADO')),
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
    FOREIGN KEY (id_ativ)    REFERENCES atividade(id_ativ)
);

CREATE TABLE pagamento (
    id_pagamento    INTEGER PRIMARY KEY AUTOINCREMENT,
    id_agendamento  INTEGER NOT NULL UNIQUE,
    valor           DECIMAL(10,2) NOT NULL,
    data_pagamento  DATETIME NULL,
    status          TEXT NOT NULL DEFAULT 'PENDENTE'
                    CHECK (status IN ('PAGO','PENDENTE','CANCELADO')),
    forma_pagamento VARCHAR(40),
    FOREIGN KEY (id_agendamento) REFERENCES agendamento(id_agendamento)
);

CREATE TABLE fornecedor (
    id_fornecedor      INTEGER PRIMARY KEY AUTOINCREMENT,
    nome_fantasia      VARCHAR(120) NOT NULL,
    cnpj               VARCHAR(18) NOT NULL UNIQUE,
    valor_fornecimento DECIMAL(10,2) NOT NULL DEFAULT 0,
    tipo_fornecimento  TEXT NOT NULL CHECK (tipo_fornecimento IN ('OURO','PRATA','BRONZE'))
);

CREATE TABLE servico_fornecedor (
    id_servico    INTEGER NOT NULL,
    id_fornecedor INTEGER NOT NULL,
    PRIMARY KEY (id_servico, id_fornecedor),
    FOREIGN KEY (id_servico)    REFERENCES servico(id_servico) ON DELETE CASCADE,
    FOREIGN KEY (id_fornecedor) REFERENCES fornecedor(id_fornecedor)
);

CREATE TABLE avaliacao (
    id_avali       INTEGER PRIMARY KEY AUTOINCREMENT,
    id_cliente     INTEGER NOT NULL,
    id_ativ        INTEGER NOT NULL,
    nota           DECIMAL(3,1) NOT NULL,
    comentario     TEXT,
    data_avaliacao DATE NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
    FOREIGN KEY (id_ativ)    REFERENCES atividade(id_ativ),
    CHECK (nota BETWEEN 0 AND 10)
);

-- ========== DADOS ==========

INSERT INTO cliente (id_cliente, nome, cpf, email, telefone, data_nascimento, tipo) VALUES
(1, 'Ana Souza', '111.111.111-11', 'ana@exemplo.com', '31999990001', '1999-04-10', 'PF'),
(2, 'Empresa Horizonte', NULL, 'contato@horizonte.exemplo', '3133330000', NULL, 'PJ'),
(3, 'Bruno Lima', '222.222.222-22', 'bruno@exemplo.com', '31999990003', '1996-08-20', 'PF');

INSERT INTO pessoa_fisica (id_cliente, cnh, veiculo) VALUES
(1, 'MG12345678', 'Sedan prata'),
(3, 'MG87654321', 'SUV branco');

INSERT INTO pessoa_juridica (id_cliente, cnpj, contato_empresarial) VALUES
(2, '12.345.678/0001-90', 'Carla - compras');

INSERT INTO funcionario (id_func, nome, cpf, email, cargo, salario) VALUES
(1, 'Lucas Pereira', '333.333.333-33', 'lucas@exemplo.com', 'Gerente', 2800.00),
(2, 'Marina Costa', '444.444.444-44', 'marina@exemplo.com', 'Atendente', 1900.00);

INSERT INTO especialista (id_espe, nome, cpf, email, curriculo, area_atuacao) VALUES
(1, 'Pedro Martins', '555.555.555-55', 'pedro@exemplo.com',
 'Experiencia em lavagem tecnica', 'Lavagem');

INSERT INTO servico (id_servico, nome, data_inicio, data_fim, local, descricao) VALUES
(1, 'Limpeza automotiva', '2026-11-01', '2026-12-31',
 'Unidade Centro', 'Lavagem, polimento e higienizacao de veiculos');

INSERT INTO comissao (id_servico, id_func) VALUES
(1, 1),
(1, 2);

INSERT INTO atividade (id_ativ, id_servico, id_func_responsavel, titulo, duracao_min,
                       data_atividade, horario, box, tipo) VALUES
(1, 1, 1, 'Lavagem completa',     60, '2026-11-15', '09:00:00', 'BOX 1', 'LAVAGEM'),
(2, 1, 2, 'Polimento de pintura', 120, '2026-11-15', '10:00:00', 'BOX 2', 'POLIMENTO'),
(3, 1, 1, 'Higienizacao interna',  90, '2026-11-16', '14:00:00', 'BOX 1', 'HIGIENIZACAO');

INSERT INTO lavagem (id_ativ, tipo_produto, id_espe) VALUES
(1, 'Shampoo automotivo neutro', 1);

INSERT INTO polimento (id_ativ, maquina_utilizada, cera) VALUES
(2, 'Politriz orbital', 'Cera sintetica');

INSERT INTO higienizacao (id_ativ, custo_adicional_produto) VALUES
(3, 35.00);

INSERT INTO agendamento (id_agendamento, id_cliente, id_ativ, status) VALUES
(1, 1, 1, 'AGENDADO'),
(2, 2, 2, 'AGENDADO'),
(3, 3, 3, 'CONCLUIDO');

INSERT INTO pagamento (id_agendamento, valor, data_pagamento, status, forma_pagamento) VALUES
(1, 80.00, NULL, 'PENDENTE', NULL),
(2, 250.00, NULL, 'PENDENTE', NULL),
(3, 180.00, '2026-11-16 15:30:00', 'PAGO', 'PIX');

INSERT INTO fornecedor (id_fornecedor, nome_fantasia, cnpj, valor_fornecimento, tipo_fornecimento) VALUES
(1, 'Produtos AutoBrilho', '98.765.432/0001-10', 650.00, 'PRATA');

INSERT INTO servico_fornecedor (id_servico, id_fornecedor) VALUES
(1, 1);

INSERT INTO avaliacao (id_cliente, id_ativ, nota, comentario, data_avaliacao) VALUES
(3, 3, 9.5, 'Servico muito bom', '2026-11-16');

-- ========== CONSULTAS ==========

-- CONSULTA 1: Listar todos os clientes
SELECT id_cliente, nome, tipo, email
FROM cliente
ORDER BY nome;

-- CONSULTA 2: Atividades, servicos e responsaveis
SELECT a.id_ativ, a.titulo, a.tipo,
       s.nome AS servico,
       f.nome AS responsavel
FROM atividade a
JOIN servico s     ON s.id_servico = a.id_servico
JOIN funcionario f ON f.id_func = a.id_func_responsavel;

-- CONSULTA 3: Agendamentos e clientes
SELECT ag.id_agendamento, c.nome, a.titulo, ag.status
FROM agendamento ag
JOIN cliente c   ON c.id_cliente = ag.id_cliente
JOIN atividade a ON a.id_ativ = ag.id_ativ;

-- CONSULTA 4: Pagamentos pendentes
SELECT p.id_pagamento, c.nome, p.valor
FROM pagamento p
JOIN agendamento ag ON ag.id_agendamento = p.id_agendamento
JOIN cliente c      ON c.id_cliente = ag.id_cliente
WHERE p.status = 'PENDENTE';

-- CONSULTA 5: Media das avaliacoes por atividade
SELECT a.titulo, ROUND(AVG(av.nota), 2) AS media_nota
FROM avaliacao av
JOIN atividade a ON a.id_ativ = av.id_ativ
GROUP BY a.id_ativ, a.titulo;
