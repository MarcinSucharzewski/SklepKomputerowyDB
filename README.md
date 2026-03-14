# Sklep Komputerowy – Baza Danych

Projekt portfoliowy: relacyjna baza danych PostgreSQL dla **stacjonarnego sklepu z częściami komputerowymi**.

---

## Struktura projektu

| Plik | Opis |
|------|------|
| `sklep_tabele.sql` | Definicje tabel (schemat `sklep`) |
| `sklep_dane.sql` | Dane przykładowe (INSERT) |
| `sklep_diagram_er.md` | Diagram ER w formacie Mermaid |
| `sklep_widoki.sql` | Widoki analityczne (CREATE VIEW) – uruchom raz |
| `sklep_kwerendy.sql` | Kwerendy analityczne – pełne SQL + szybkie wywołania widoków |
| `sklep_admin.sql` | Scenariusz administracyjny |

---

## Instrukcja uruchomienia

### 1. Wymagania
- PostgreSQL ≥ 14
- `psql` (klient wiersza poleceń)

### 2. Utwórz bazę i schemat

```sql
-- Zaloguj się do psql jako superuser:
psql -U postgres

-- Utwórz bazę:
CREATE DATABASE sklep_komputerowy;

-- Połącz się z bazą:
\c sklep_komputerowy

-- Utwórz schemat:
CREATE SCHEMA IF NOT EXISTS sklep;
```

### 3. Uruchom skrypty w kolejności

```sql
\i 'C:/sciezka/do/projektu/sklep_tabele.sql'
\i 'C:/sciezka/do/projektu/sklep_dane.sql'
\i 'C:/sciezka/do/projektu/sklep_widoki.sql'
```

### 4. Uruchamianie kwerend analitycznych jedną linią

Po zaRejestrowaniu widoków każdą analizę uruchamiasz bez wklejania pełnego SQL-a:

```sql
SELECT * FROM sklep.v_sprzedaz_kategoria;
SELECT * FROM sklep.v_top_produkty;
SELECT * FROM sklep.v_obrot_sklep;
SELECT * FROM sklep.v_niski_stan;
-- itd. – pełna lista w sklep_widoki.sql
```

### 5. Zweryfikuj

```sql
\dt sklep.*
SELECT * FROM sklep.produkty LIMIT 5;
```

---

## Schemat bazy – tabele

```
sklep
├── kategorie           – 10 kategorii (Procesory, GPU, RAM, SSD …)
├── producenci          – 12 producentów (Intel, AMD, Samsung …)
├── produkty            – 20 podzespołów z ceną zakupu i sprzedaży
├── dostawcy            – 5 hurtowni / dystrybutorów
├── klienci             – 12 zarejestrowanych klientów
├── pracownicy          – 6 pracowników (2 kierowników, 3 sprzedawców, 1 magazynier)
├── transakcje          – 15 paragonów (styczeń–marzec 2026)
├── pozycje_transakcji  – 27 linii produktów na paragonach
├── dostawy             – 6 dokumentów PZ (grudzień 2025 – marzec 2026)
└── pozycje_dostawy     – 20 pozycji towarowych w dostawach
```

---

## Kwerendy analityczne (`sklep_kwerendy.sql`)

| # | Zapytanie |
|---|-----------|
| K1 | Sprzedaż wg kategorii produktów |
| K2 | Sprzedaż wg producenta |
| K3 | Najlepiej sprzedające się produkty (Top 10) |
| K4 | Obrót i marża na każdym produkcie |
| K5 | Całkowity obrót i zysk sklepu |
| K6 | Statystyki pracowników – wartość sprzedaży |
| K7 | Stany magazynowe – produkty z niskim stanem (≤ 5 szt.) |
| K8 | Wartość całego magazynu wg kategorii |
| K9 | Sprzedaż miesięczna |
| K10 | Aktywność klientów zarejestrowanych |
| K11 | Zestawienie dostaw wg dostawcy |
| K12 | Sprzedaż vs zakupy wg kategorii |

---

## Scenariusz administracyjny (`sklep_admin.sql`)

- **A1** – Nowa tabela `sklep.promocje` z przykładowymi rekordami
- **A2** – Nowa rola PostgreSQL `sprzedawca_ro` (tylko odczyt, dla raportowania)
- **A3** – Operacje DML:
  - INSERT nowego pracownika i klienta
  - UPDATE ceny produktu po zmianie rynkowej
  - UPDATE stanu magazynowego po przyjęciu zwrotu
  - UPDATE dezaktywacja wygasłych promocji
  - DELETE wygasłej promocji
  - DELETE testowego klienta bez transakcji
- **A4** – Zapytania weryfikacyjne po każdej operacji

---

## Diagram ER

Plik `sklep_diagram_er.md` zawiera diagram w formacie **Mermaid**.

Jak wyświetlić:
- VS Code: zainstaluj rozszerzenie *Markdown Preview Mermaid Support* i otwórz podgląd (`Ctrl+Shift+V`)
- Online: wklej kod diagramu na [mermaid.live](https://mermaid.live)
