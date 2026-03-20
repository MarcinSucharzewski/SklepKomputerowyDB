#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Łączy się z bazą sklep_komputerowy i generuje dwa pliki Markdown:

  wyniki_baza_tabele.md  – podgląd każdej tabeli (LIMIT TABLE_LIMIT)
  wyniki_baza_widoki.md  – blok SQL z pg_views + wynik jako tabela Markdown (LIMIT QUERY_LIMIT)

Wymagania: psycopg2-binary
  pip install psycopg2-binary
"""

import psycopg2

# ---------------------------------------------------------------------------
# Konfiguracja
# ---------------------------------------------------------------------------
CONN = dict(
    host="localhost",
    port=5432,
    dbname="sklep_komputerowy",
    user="postgres",
    password="postgres",
)

TABLE_LIMIT = 5
QUERY_LIMIT = 10

TABLES = [
    "kategorie",
    "producenci",
    "produkty",
    "dostawcy",
    "klienci",
    "pracownicy",
    "transakcje",
    "pozycje_transakcji",
    "dostawy",
    "pozycje_dostawy",
]

VIEWS = [
    ("k1",  "v_sprzedaz_kategoria",    "Sprzedaż wg kategorii"),
    ("k2",  "v_sprzedaz_producent",    "Sprzedaż wg producenta"),
    ("k3",  "v_top_produkty",          "Top 10 produktów wg wartości sprzedaży"),
    ("k4",  "v_marza_produkty",        "Obrót i marża na produktach"),
    ("k5",  "v_obrot_sklep",           "Całkowity obrót i zysk sklepu"),
    ("k6",  "v_statystyki_pracownicy", "Statystyki pracowników"),
    ("k7",  "v_niski_stan",            "Produkty z niskim stanem magazynowym"),
    ("k8",  "v_wartosc_magazyn",       "Wartość magazynu wg kategorii"),
    ("k9",  "v_sprzedaz_miesiac",      "Sprzedaż miesięczna"),
    ("k10", "v_aktywnosc_klientow",    "Aktywność zarejestrowanych klientów"),
    ("k11", "v_zestawienie_dostaw",    "Zestawienie dostaw wg dostawcy"),
    ("k12", "v_sprzedaz_vs_zakupy",    "Sprzedaż vs zakupy wg kategorii"),
]


# ---------------------------------------------------------------------------
# Pomocnicze
# ---------------------------------------------------------------------------
def md_table(columns: list[str], rows: list[tuple]) -> str:
    """Zwraca tabelkę Markdown z podanych kolumn i wierszy."""
    str_rows = [
        [str(v) if v is not None else "NULL" for v in row]
        for row in rows
    ]
    widths = [len(c) for c in columns]
    for row in str_rows:
        for i, v in enumerate(row):
            widths[i] = max(widths[i], len(v))

    def fmt_row(cells):
        return "| " + " | ".join(c.ljust(widths[i]) for i, c in enumerate(cells)) + " |"

    sep = "| " + " | ".join("-" * w for w in widths) + " |"
    lines = [fmt_row(columns), sep] + [fmt_row(row) for row in str_rows]
    return "\n".join(lines)


def get_view_sql(cur, view_name: str) -> str:
    """Pobiera definicję widoku z pg_views (czysty SELECT)."""
    cur.execute(
        "SELECT definition FROM pg_views WHERE schemaname = 'sklep' AND viewname = %s",
        (view_name,),
    )
    row = cur.fetchone()
    return row[0].strip().rstrip(";") if row else ""


# ---------------------------------------------------------------------------
# Generowanie wyniki_baza_tabele.md
# ---------------------------------------------------------------------------
def generate_tables_md(cur) -> str:
    lines = [
        "# Podgląd tabel – sklep komputerowy",
        "",
        f"Każda tabela pokazana z limitem **{TABLE_LIMIT} rekordów**.",
        "",
    ]

    for table in TABLES:
        lines.append(f"## `sklep.{table}`")
        lines.append("")
        lines.append(f"```sql")
        lines.append(f"SELECT * FROM sklep.{table} LIMIT {TABLE_LIMIT};")
        lines.append("```")
        lines.append("")

        cur.execute(f"SELECT * FROM sklep.{table} LIMIT {TABLE_LIMIT}")
        rows = cur.fetchall()
        columns = [desc[0] for desc in cur.description]

        if rows:
            lines.append(md_table(columns, rows))
        else:
            lines.append("*(tabela pusta)*")

        lines.append("")

    return "\n".join(lines)


# ---------------------------------------------------------------------------
# Generowanie wyniki_baza_widoki.md
# ---------------------------------------------------------------------------
def generate_queries_md(cur) -> str:
    lines = [
        "# Wyniki kwerend analitycznych – sklep komputerowy",
        "",
        f"Każdy wynik ograniczony do **{QUERY_LIMIT} rekordów**.",
        "",
    ]

    for alias, view_name, description in VIEWS:
        lines.append(f"## {alias.upper()} – {description}")
        lines.append("")

        # Blok SQL: szybkie wywołanie + pełna definicja widoku
        full_sql = get_view_sql(cur, view_name)
        lines.append("```sql")
        lines.append(f"-- Szybkie wywołanie:")
        lines.append(f"SELECT * FROM sklep.{alias};")
        lines.append("")
        lines.append(f"-- Pełna definicja (widok {view_name}):")
        lines.append(full_sql + ";")
        lines.append("```")
        lines.append("")

        # Wynik kwerendy
        cur.execute(f"SELECT * FROM sklep.{alias} LIMIT {QUERY_LIMIT}")
        rows = cur.fetchall()
        columns = [desc[0] for desc in cur.description]

        if rows:
            lines.append(md_table(columns, rows))
        else:
            lines.append("*(brak wyników)*")

        lines.append("")

    return "\n".join(lines)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main():
    print("Łączenie z bazą danych...")
    with psycopg2.connect(**CONN) as conn:
        with conn.cursor() as cur:

            print("Generuję wyniki_baza_tabele.md ...")
            content = generate_tables_md(cur)
            with open("wyniki_baza_tabele.md", "w", encoding="utf-8") as f:
                f.write(content)
            print("  ✓ wyniki_baza_tabele.md")

            print("Generuję wyniki_baza_widoki.md ...")
            content = generate_queries_md(cur)
            with open("wyniki_baza_widoki.md", "w", encoding="utf-8") as f:
                f.write(content)
            print("  ✓ wyniki_baza_widoki.md")

    print("\nGotowe!")


if __name__ == "__main__":
    main()
