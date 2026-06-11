<img width="1220" height="558" alt="Capturar" src="https://github.com/user-attachments/assets/e9f34b3d-2b56-4180-885b-623e2b2bdd8e" />

# 📡 Pipeline de Análise de Clientes Telecom

> Projeto de portfólio de Engenharia de Dados — pipeline ETL completo com Python, SQL e visualização no Power BI.

---

## 📌 Sobre o projeto

Pipeline de dados end-to-end simulando o ambiente de uma operadora de telecomunicações. O projeto cobre todas as etapas de uma stack moderna de dados: ingestão, limpeza, modelagem em camadas e visualização de KPIs operacionais.

---

## 🏗️ Arquitetura

```
[Excel Bruto]  →  [Python: ETL]  →  [SQLite: Silver/Gold]  →  [Power BI: Dashboard]
   Bronze               ↓                    ↓
                  limpeza_clientes.py   modelagem_gold.sql
```

### Camadas de dados (Medallion Architecture)

| Camada | Arquivo | Descrição |
|--------|---------|-----------|
| 🥉 Bronze | `bronze_clientes_bruto.xlsx` | Dados brutos com problemas de qualidade simulados |
| 🥈 Silver | `silver_clientes_limpo.xlsx` | Dados limpos e padronizados |
| 🥇 Gold | `gold_kpis_telecom.xlsx` / `telecom_clientes.db` | KPIs agregados por região, plano e canal |

---

## 📊 Dashboard — KPIs principais

| Indicador | Valor |
|-----------|-------|
| Total de clientes | 1.000 |
| Receita total | R$ 163.970 |
| NPS médio | 5,02 |
| Taxa de churn | 41,4% |
| Plano com menor churn | Premium (38,7%) |
| Canal mais eficiente | Call Center (38,1%) |
| Região com maior receita | Oeste (R$ 37.247) |

---

## 🛠️ Tecnologias utilizadas

- **Python** — geração de dados simulados e pipeline de limpeza (Pandas, NumPy, OpenPyXL)
- **SQL (SQLite)** — modelagem relacional com camadas Silver e Gold
- **Power BI** — dashboard interativo com segmentação de clientes
- **Excel** — camadas Bronze e Silver como formato de entrega

---

## 📁 Estrutura do repositório

```
📦 telecom-pipeline/
 ┣ 📄 bronze_clientes_bruto.xlsx   # Dados brutos (1.030 linhas com problemas)
 ┣ 📄 silver_clientes_limpo.xlsx   # Dados limpos + log de limpeza
 ┣ 📄 gold_kpis_telecom.xlsx       # KPIs agregados (4 abas)
 ┣ 🗄️ telecom_clientes.db          # Banco SQLite com views Gold
 ┣ 🐍 limpeza_clientes.py          # Script ETL Bronze → Silver
 ┣ 🗃️ modelagem_gold.sql           # Modelagem SQL Silver → Gold
 ┗ 📄 README.md
```

---

## 🔍 Problemas de qualidade tratados (Bronze → Silver)

| Problema | Quantidade tratada |
|----------|--------------------|
| Duplicatas removidas | 30 |
| Datas inválidas corrigidas | 46 |
| NPS fora do range (>10) | 47 |
| Ticket com prefixo "R$" (texto) | ~30 |
| Nulos preenchidos com mediana | ~115 |
| Status inconsistentes padronizados | ~60 |

---

## 🧩 Modelagem Gold (Views SQL)

```sql
silver_clientes
    ├── gold_kpis_por_regiao       → receita, churn e NPS por região
    ├── gold_kpis_por_plano        → comparativo entre planos
    ├── gold_kpis_por_canal        → performance por canal de aquisição
    └── gold_segmentacao_clientes  → VIP / Alto / Médio / Baixo Valor
```

---

## ▶️ Como executar

```bash
# 1. Instalar dependências
pip install pandas openpyxl numpy

# 2. Executar limpeza (Bronze → Silver)
python limpeza_clientes.py

# 3. Abrir o banco no DB Browser for SQLite ou conectar no Power BI
#    Arquivo: telecom_clientes.db
```

---

## 👤 Autor

**Filipe**
Analista | Engenharia de Dados | Telecom

[![LinkedIn](https://img.shields.io/badge/LinkedIn-blue?logo=linkedin)](https://linkedin.com/in/seu-perfil)


---

