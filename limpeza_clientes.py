"""
Pipeline de Limpeza de Dados - Camada Bronze → Silver
Projeto: Análise de Clientes Telecom
Autor: Filipe | Portfólio de Engenharia de Dados
"""

import pandas as pd
import numpy as np

def limpar_ticket(v):
    """Remove 'R$' e converte para float."""
    try:
        return float(str(v).replace("R$", "").replace(",", ".").strip())
    except:
        return np.nan

def normalizar_status(v):
    """Padroniza variações de texto no campo status_contrato."""
    if pd.isna(v):
        return "Desconhecido"
    mapa = {"ativo": "Ativo", "inativo": "Inativo", "suspenso": "Suspenso"}
    return mapa.get(str(v).strip().lower(), "Desconhecido")

def corrigir_data(v):
    """Converte strings de data, retorna NaT para datas inválidas."""
    try:
        return pd.to_datetime(str(v), dayfirst=True, errors="raise")
    except:
        return pd.NaT

def executar_limpeza(input_path: str, output_path: str):
    df = pd.read_excel(input_path, sheet_name="Dados_Brutos")
    log = []

    # 1. Remover duplicatas por cliente_id
    antes = len(df)
    df = df.drop_duplicates(subset="cliente_id", keep="first")
    log.append(f"Duplicatas removidas: {antes - len(df)}")

    # 2. Padronizar status_contrato
    df["status_contrato"] = df["status_contrato"].apply(normalizar_status)
    log.append("Status padronizados: ✓")

    # 3. Limpar ticket_medio (remover prefixo 'R$')
    df["ticket_medio_r$"] = df["ticket_medio_r$"].apply(limpar_ticket)
    log.append("Ticket limpo (removido 'R$'): ✓")

    # 4. Corrigir datas inválidas
    df["data_contrato"] = df["data_contrato"].apply(corrigir_data)
    n_datas = df["data_contrato"].isna().sum()
    log.append(f"Datas inválidas → NaT: {n_datas}")

    # 5. Remover NPS fora do range 0-10
    invalidos_nps = (df["nps_score"] > 10).sum()
    df.loc[df["nps_score"] > 10, "nps_score"] = np.nan
    log.append(f"NPS fora do range (>10) → NaN: {invalidos_nps}")

    # 6. Preencher nulos numéricos com mediana
    colunas_num = ["consumo_dados_gb", "tempo_contrato_meses",
                   "chamados_abertos", "ticket_medio_r$", "nps_score"]
    for col in colunas_num:
        n_nulos = df[col].isna().sum()
        df[col] = df[col].fillna(df[col].median())
        log.append(f"Nulos em '{col}' → mediana: {n_nulos}")

    # 7. Garantir tipos corretos
    df["tempo_contrato_meses"] = df["tempo_contrato_meses"].round(0).astype("Int64")
    df["chamados_abertos"]     = df["chamados_abertos"].round(0).astype("Int64")
    df["nps_score"]            = df["nps_score"].round(0).astype("Int64")
    df["consumo_dados_gb"]     = df["consumo_dados_gb"].round(2)
    df["ticket_medio_r$"]      = df["ticket_medio_r$"].round(2)

    # Salvar resultado limpo
    df.to_excel(output_path, index=False, sheet_name="Dados_Limpos")

    print("📋 LOG DE LIMPEZA:")
    for linha in log:
        print(f"   {linha}")
    print(f"\n✅ Silver salvo em: {output_path}")
    print(f"   {len(df)} clientes × {df.shape[1]} colunas")

    return df


if __name__ == "__main__":
    executar_limpeza(
        input_path="bronze_clientes_bruto.xlsx",
        output_path="silver_clientes_limpo.xlsx"
    )
