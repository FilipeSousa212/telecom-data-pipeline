Pipeline de Análise de Clientes Telecom
Projeto de portfólio de Engenharia de Dados 
— pipeline ETL completo com Python, SQL e visualização no Power BI.

Sobre o projeto
Pipeline de dados end-to-end simulando o ambiente de uma operadora de telecomunicações. 
O projeto cobre todas as etapas de uma pilha moderna de dados: aquisição, limpeza, modelagem em camadas e visualização de KPIs operacionais.

Arquitetura
[Excel Bruto]  →  [Python: ETL]  →  [SQLite: Silver/Gold]  →  [Power BI: Dashboard]
   Bronze               ↓                    ↓
                  limpeza_clientes.py   modelagem_gold.sql
                  
Camadas de dados (Medalhão Arquitetura)
Camada	Arquivo	Descrição

Bronze	bronze_clientes_bruto.xlsx	
Dados brutos com problemas de qualidade simulados
Prata	silver_clientes_limpo.xlsx	
Dados limpos e graduados
Ouro	gold_kpis_telecom.xlsx/telecom_clientes.db
KPIs agregados por região, plano e canal

Painel — KPIs principais
indica	Valentia
Total de clientes	1.000
Receita total	R$ 163.970
NPS médio	5,02
Taxa de churn	41,4%
Plano com menor churn	Premium (38,7%)
Canal mais eficiente	Central de Atendimento (38,1%)
Região com maior receita	Oeste (R$ 37.247)

Tecnologias utilizadas
Python — geração de dados simulados e pipeline de limpeza (Pandas, NumPy, OpenPyXL)
SQL (SQLite) — modelagem relacional com camadas Silver e Gold
Power BI — dashboard interativo com segmentação de clientes
Excel — camadas Bronze e Prata como formato de entrega

Estrutura do repositório

telecom-pipeline/

 ┣  bronze_clientes_bruto.xlsx   # Dados brutos (1.030 linhas com problemas)
 ┣  silver_clientes_limpo.xlsx   # Dados limpos + log de limpeza
 ┣  gold_kpis_telecom.xlsx       # KPIs agregados (4 abas)
 ┣  telecom_clientes.db          # Banco SQLite com views Gold
 ┣  limpeza_clientes.py          # Script ETL Bronze → Silver
 ┣  modelagem_gold.sql           # Modelagem SQL Silver → Gold
 ┗  README.md
 
Problemas de qualidade tratados (Bronze → Prata)

Problema Quantidade tratada
Duplicatas	30
Dados inválidos corrigidos	46
NPS fora do intervalo (>10) 47
Ticket com prefixo "R$" (texto) ~30
Nulos preenchidos com mediana	~115
Status inconsistente padronizado	~60

Modelagem Gold (Views SQL)
    ├── Silver_clientes
    ├── gold_kpis_por_regiao       → receita, churn e NPS por região
    ├── gold_kpis_por_plano        → comparativo entre planos
    ├── gold_kpis_por_canal        → performance por canal de aquisição
    └── gold_segmentacao_clientes  → VIP / Alto / Médio / Baixo Valor
    
Como executar

# 1. Instalar dependências
pip install pandas openpyxl numpy

# 2. Executar limpeza (Bronze → Silver)
python limpeza_clientes.py

# 3. Abrir o banco no DB Browser for SQLite ou conectar no Power BI
#    Arquivo: telecom_clientes.db

Autor
Filipe Analista | Engenharia de Dados | Telecomunicações

<img width="934" height="594" alt="Capturar" src="https://github.com/user-attachments/assets/08941b1f-1238-4ab7-9e6a-8173d16128e9" />
