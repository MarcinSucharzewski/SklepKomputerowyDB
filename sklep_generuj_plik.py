#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Wersja 2 – treść kwerend z pliku sklep_widoki.sql (nie z bazy).

Generuje dwa pliki Markdown:
  wyniki_plik_tabele.md  – podgląd każdej tabeli (LIMIT TABLE_LIMIT)
  wyniki_plik_widoki.md  – blok SQL z pliku + wynik kwerendy (LIMIT QUERY_LIMIT)

Wymagania: psycopg2-binary
"""

import re
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

QUERIES_FILE = "sklep_widoki.sql"

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


# ---------------------------------------------------------------------------
# Parsowanie sklep_widoki.sql
# ---------------------------------------------------------------------------
def parse_queries(filepath: str) -> list[dict]:
    r"""
    Parsuje sklep_widoki.sql szukając nagłówków "-- K\d+" bezpośrednio.

    Struktura bloku:
      -- ============================================================
      -- K1 – Tytuł
      -- ============================================================
      CREATE OR REPLACE VIEW sklep.v_NAME AS
      SELECT ...;

    Zwraca listę dict: alias, title, view_name, raw_block, sql.
    Bloki aliasów (k1-k12 na dole) nie mają nagłówka K\d+ – są pomijane.
    """
    with open(filepath, encoding="utf-8") as f:
        raw_lines = f.read().splitlines()

    HEADER  = re.compile(r"^-- (K[0-9]+)\s+[–\-]+\s+(.+)")
    SEP     = re.compile(r"^-- =+$")
    VIEW_RE = re.compile(r"^CREATE OR REPLACE VIEW\s+\S+\.(\S+)\s+AS\s*$", re.IGNORECASE)

    queries = []
    i = 0
    while i < len(raw_lines):
        # Szukamy nagłówka "-- K1 – Tytuł" bezpośrednio
        m = HEADER.match(raw_lines[i])
        if not m:
            i += 1
            continue

        alias = m.group(1)   # np. "K1"
        title = m.group(2).strip()
        i += 1

        # Pomijamy linie (komentarze) do zamykającego separatora
        while i < len(raw_lines) and not SEP.match(raw_lines[i]):
            i += 1
        i += 1  # pomiń zamykający separator

        # Pierwsza niepusta linia po separatorze: opcjonalnie CREATE VIEW
        while i < len(raw_lines) and raw_lines[i].strip() == "":
            i += 1
        if i >= len(raw_lines):
            break

        vm = VIEW_RE.match(raw_lines[i])
        view_name = vm.group(1) if vm else ""
        if vm:
            i += 1  # pomiń linię CREATE OR REPLACE VIEW

        # Zbieramy SQL aż do kolejnego SEP lub końca pliku
        sql_lines = []
        while i < len(raw_lines) and not SEP.match(raw_lines[i]):
            sql_lines.append(raw_lines[i])
            i += 1

        # Przytnij puste linie z obu końców
        while sql_lines and not sql_lines[0].strip():
            sql_lines.pop(0)
        while sql_lines and not sql_lines[-1].strip():
            sql_lines.pop()

        if not sql_lines:
            continue

        sep_line = "-- " + "=" * 60
        raw_block = (
            sep_line + "\n"
            + f"-- {alias} \u2013 {title}\n"
            + sep_line + "\n"
            + "\n".join(sql_lines)
        )
        sql_clean = "\n".join(sql_lines).rstrip().rstrip(";").strip()

        queries.append({
            "alias":      alias,
            "title":      title,
            "view_name":  view_name,
            "raw_block":  raw_block,
            "sql":        sql_clean,
        })

    return queries


# ---------------------------------------------------------------------------
# Pomocnicze
# ---------------------------------------------------------------------------
def md_table(columns: list[str], rows: list[tuple]) -> str:
    """Zwraca tabelkę Markdown."""
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
    return "\n".join([fmt_row(columns), sep] + [fmt_row(r) for r in str_rows])


def run_query(cur, sql: str, limit: int) -> tuple[list[str], list[tuple]]:
    """Wykonuje zapytanie opakowane w LIMIT i zwraca (kolumny, wiersze)."""
    wrapped = f"SELECT * FROM (\n{sql}\n) AS _q LIMIT {limit}"
    cur.execute(wrapped)
    rows = cur.fetchall()
    columns = [desc[0] for desc in cur.description]
    return columns, rows


# ---------------------------------------------------------------------------
# Generowanie wyniki_plik_tabele.md
# ---------------------------------------------------------------------------
def generate_tables_md(cur) -> str:
    lines = [
        "# Podgląd tabel – sklep komputerowy",
        "",
        f"Każda tabela pokazana z limitem **{TABLE_LIMIT} rekordów**.",
        "",
    ]
    for table in TABLES:
        lines += [
            f"## `sklep.{table}`",
            "",
            "```sql",
            f"SELECT * FROM sklep.{table} LIMIT {TABLE_LIMIT};",
            "```",
            "",
        ]
        cur.execute(f"SELECT * FROM sklep.{table} LIMIT {TABLE_LIMIT}")
        rows = cur.fetchall()
        columns = [desc[0] for desc in cur.description]
        lines.append(md_table(columns, rows) if rows else "*(tabela pusta)*")
        lines.append("")
    return "\n".join(lines)


# ---------------------------------------------------------------------------
# Generowanie wyniki_plik_widoki.md
# ---------------------------------------------------------------------------
def generate_queries_md(cur, queries: list[dict]) -> str:
    lines = [
        "# Wyniki kwerend analitycznych – sklep komputerowy",
        "",
        f"Kod kwerend pochodzi z pliku `{QUERIES_FILE}`. "
        f"Wyniki ograniczone do **{QUERY_LIMIT} rekordów**.",
        "",
    ]
    for q in queries:
        alias_lower = q["alias"].lower()   # K1 → k1
        lines += [
            f"## {q['alias']} – {q['title']}",
            "",
            "```sql",
            q["raw_block"],
            "```",
            "",
        ]
        try:
            cur.execute(f"SELECT * FROM sklep.{alias_lower} LIMIT {QUERY_LIMIT}")
            rows = cur.fetchall()
            columns = [desc[0] for desc in cur.description]
            lines.append(md_table(columns, rows) if rows else "*(brak wyników)*")
        except Exception as e:
            lines.append(f"> **Błąd wykonania:** `{e}`")
        lines.append("")
    return "\n".join(lines)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main():
    print(f"Parsowanie {QUERIES_FILE} ...")
    queries = parse_queries(QUERIES_FILE)
    print(f"  Znaleziono {len(queries)} kwerend: {', '.join(q['alias'] for q in queries)}")

    print("Łączenie z bazą danych...")
    with psycopg2.connect(**CONN) as conn:
        with conn.cursor() as cur:

            print("Generuję wyniki_plik_tabele.md ...")
            with open("wyniki_plik_tabele.md", "w", encoding="utf-8") as f:
                f.write(generate_tables_md(cur))
            print("  ✓ wyniki_plik_tabele.md")

            print("Generuję wyniki_plik_widoki.md ...")
            with open("wyniki_plik_widoki.md", "w", encoding="utf-8") as f:
                f.write(generate_queries_md(cur, queries))
            print("  ✓ wyniki_plik_widoki.md")

    print("\nGotowe!")


if __name__ == "__main__":
    main()
