-- ============================================================
-- MODELAGEM DE DADOS — Camada Silver → Gold
-- Projeto: Análise de Clientes Telecom
-- Autor: Filipe | Portfólio de Engenharia de Dados
-- Banco: SQLite (compatível com PostgreSQL com ajustes mínimos)
-- ============================================================


-- ── CAMADA SILVER ────────────────────────────────────────────
-- Tabela central com dados já limpos (origem: bronze_clientes_bruto)

CREATE TABLE IF NOT EXISTS silver_clientes (
    cliente_id              TEXT PRIMARY KEY,
    regiao                  TEXT,
    estado                  TEXT,
    canal_aquisicao         TEXT,
    plano                   TEXT,
    status_contrato         TEXT,       -- Ativo | Inativo | Suspenso
    data_contrato           TEXT,       -- formato YYYY-MM-DD
    tempo_contrato_meses    INTEGER,
    consumo_dados_gb        REAL,
    ticket_medio            REAL,
    nps_score               INTEGER,    -- 0 a 10
    chamados_abertos        INTEGER,
    churn                   INTEGER     -- 0 = não, 1 = sim
);


-- ── CAMADA GOLD — View 1: KPIs por Região ────────────────────
-- Principais indicadores de negócio agrupados por região.
-- Útil para análises geográficas no Power BI.

CREATE VIEW IF NOT EXISTS gold_kpis_por_regiao AS
SELECT
    regiao,
    COUNT(*)                                        AS total_clientes,
    SUM(CASE WHEN status_contrato = 'Ativo'
             THEN 1 ELSE 0 END)                     AS clientes_ativos,
    ROUND(AVG(ticket_medio), 2)                     AS ticket_medio_r$,
    ROUND(AVG(consumo_dados_gb), 2)                 AS consumo_medio_gb,
    ROUND(AVG(nps_score), 1)                        AS nps_medio,
    ROUND(AVG(chamados_abertos), 1)                 AS chamados_medio,
    SUM(churn)                                      AS total_churn,
    ROUND(SUM(churn) * 100.0 / COUNT(*), 1)         AS taxa_churn_pct,
    ROUND(SUM(ticket_medio), 2)                     AS receita_total_r$
FROM silver_clientes
GROUP BY regiao
ORDER BY receita_total_r$ DESC;


-- ── CAMADA GOLD — View 2: KPIs por Plano ─────────────────────
-- Compara desempenho entre planos: Básico, Intermediário,
-- Premium e Empresarial. Identifica qual plano gera mais receita
-- e tem menor churn.

CREATE VIEW IF NOT EXISTS gold_kpis_por_plano AS
SELECT
    plano,
    COUNT(*)                                        AS total_clientes,
    ROUND(AVG(ticket_medio), 2)                     AS ticket_medio_r$,
    ROUND(AVG(consumo_dados_gb), 2)                 AS consumo_medio_gb,
    ROUND(AVG(nps_score), 1)                        AS nps_medio,
    SUM(churn)                                      AS total_churn,
    ROUND(SUM(churn) * 100.0 / COUNT(*), 1)         AS taxa_churn_pct,
    ROUND(AVG(tempo_contrato_meses), 1)             AS permanencia_media_meses,
    ROUND(SUM(ticket_medio), 2)                     AS receita_total_r$
FROM silver_clientes
GROUP BY plano
ORDER BY receita_total_r$ DESC;


-- ── CAMADA GOLD — View 3: KPIs por Canal de Aquisição ────────
-- Avalia qual canal traz clientes mais rentáveis e com menor
-- taxa de churn (LTV indireto).

CREATE VIEW IF NOT EXISTS gold_kpis_por_canal AS
SELECT
    canal_aquisicao,
    COUNT(*)                                        AS total_clientes,
    ROUND(AVG(ticket_medio), 2)                     AS ticket_medio_r$,
    ROUND(AVG(nps_score), 1)                        AS nps_medio,
    SUM(churn)                                      AS total_churn,
    ROUND(SUM(churn) * 100.0 / COUNT(*), 1)         AS taxa_churn_pct,
    ROUND(AVG(chamados_abertos), 1)                 AS chamados_medio,
    ROUND(SUM(ticket_medio), 2)                     AS receita_total_r$
FROM silver_clientes
GROUP BY canal_aquisicao
ORDER BY total_clientes DESC;


-- ── CAMADA GOLD — View 4: Segmentação de Clientes ────────────
-- Classifica cada cliente em segmento de valor e nível de risco,
-- permitindo ações de retenção direcionadas.

CREATE VIEW IF NOT EXISTS gold_segmentacao_clientes AS
SELECT
    cliente_id,
    plano,
    regiao,
    status_contrato,
    ticket_medio,
    consumo_dados_gb,
    nps_score,
    chamados_abertos,
    churn,

    -- Segmento de Valor (baseado em ticket + NPS)
    CASE
        WHEN ticket_medio >= 200 AND nps_score >= 8  THEN 'VIP'
        WHEN ticket_medio >= 150 AND nps_score >= 6  THEN 'Alto Valor'
        WHEN ticket_medio >= 80                       THEN 'Médio Valor'
        ELSE                                               'Baixo Valor'
    END AS segmento_valor,

    -- Risco de Churn (baseado em chamados)
    CASE
        WHEN chamados_abertos >= 10 THEN 'Risco Alto'
        WHEN chamados_abertos >= 5  THEN 'Risco Médio'
        ELSE                             'Risco Baixo'
    END AS risco_churn

FROM silver_clientes;


-- ── CONSULTAS DE VALIDAÇÃO ────────────────────────────────────

-- Verificar total de clientes por segmento
SELECT segmento_valor, risco_churn, COUNT(*) AS total
FROM gold_segmentacao_clientes
GROUP BY segmento_valor, risco_churn
ORDER BY segmento_valor, risco_churn;

-- Top 5 regiões por receita
SELECT regiao, receita_total_r$, taxa_churn_pct
FROM gold_kpis_por_regiao
LIMIT 5;

-- Plano com menor taxa de churn
SELECT plano, taxa_churn_pct, ticket_medio_r$
FROM gold_kpis_por_plano
ORDER BY taxa_churn_pct ASC
LIMIT 1;
