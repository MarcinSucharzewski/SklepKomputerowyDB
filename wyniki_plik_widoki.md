# Wyniki kwerend analitycznych – sklep komputerowy

Kod kwerend pochodzi z pliku `sklep_widoki.sql`. Wyniki ograniczone do **10 rekordów**.

## K1 – Sprzedaż wg kategorii produktów

```sql
-- ============================================================
-- K1 – Sprzedaż wg kategorii produktów
-- ============================================================
SELECT
    k.nazwa                                      AS kategoria,
    SUM(pt.ilosc * pt.cena_jednostkowa)          AS wartosc_sprzedazy,
    COUNT(DISTINCT pt.transakcja_id)             AS liczba_transakcji,
    SUM(pt.ilosc)                                AS sprzedane_szt
FROM sklep.pozycje_transakcji  pt
JOIN sklep.produkty            p  ON p.produkt_id    = pt.produkt_id
JOIN sklep.kategorie           k  ON k.kategoria_id  = p.kategoria_id
JOIN sklep.transakcje          t  ON t.transakcja_id = pt.transakcja_id
WHERE t.status = 'zrealizowana'
GROUP BY k.nazwa
ORDER BY wartosc_sprzedazy DESC;
```

| kategoria       | wartosc_sprzedazy | liczba_transakcji | sprzedane_szt |
| --------------- | ----------------- | ----------------- | ------------- |
| Karty graficzne | 6747.00           | 3                 | 3             |
| Procesory       | 6645.00           | 5                 | 5             |
| Płyty główne    | 2298.00           | 2                 | 2             |
| Pamięci RAM     | 1923.00           | 3                 | 7             |
| Dyski SSD       | 1825.00           | 3                 | 5             |
| Zasilacze       | 1567.00           | 3                 | 3             |
| Chłodzenie      | 996.00            | 3                 | 4             |
| Dyski HDD       | 438.00            | 1                 | 2             |
| Obudowy         | 379.00            | 1                 | 1             |

## K2 – Sprzedaż wg producenta

```sql
-- ============================================================
-- K2 – Sprzedaż wg producenta
-- ============================================================
SELECT
    pr.nazwa                                     AS producent,
    SUM(pt.ilosc * pt.cena_jednostkowa)          AS wartosc_sprzedazy,
    SUM(pt.ilosc)                                AS sprzedane_szt
FROM sklep.pozycje_transakcji  pt
JOIN sklep.produkty            p  ON p.produkt_id    = pt.produkt_id
JOIN sklep.producenci          pr ON pr.producent_id = p.producent_id
JOIN sklep.transakcje          t  ON t.transakcja_id = pt.transakcja_id
WHERE t.status = 'zrealizowana'
GROUP BY pr.nazwa
ORDER BY wartosc_sprzedazy DESC;
```

| producent | wartosc_sprzedazy | sprzedane_szt |
| --------- | ----------------- | ------------- |
| ASUS      | 3848.00           | 2             |
| AMD       | 3647.00           | 3             |
| MSI       | 3448.00           | 2             |
| Intel     | 2998.00           | 2             |
| Kingston  | 1793.00           | 7             |
| Gigabyte  | 1749.00           | 1             |
| Corsair   | 1527.00           | 3             |
| Samsung   | 1107.00           | 3             |
| be quiet! | 1106.00           | 4             |
| Noctua    | 738.00            | 2             |

## K3 – Top 10 produktów wg wartości sprzedaży

```sql
-- ============================================================
-- K3 – Top 10 produktów wg wartości sprzedaży
-- ============================================================
SELECT
    p.produkt_id,
    p.nazwa                                       AS produkt,
    k.nazwa                                       AS kategoria,
    SUM(pt.ilosc)                                 AS sprzedane_szt,
    SUM(pt.ilosc * pt.cena_jednostkowa)           AS wartosc_sprzedazy
FROM sklep.pozycje_transakcji  pt
JOIN sklep.produkty            p  ON p.produkt_id    = pt.produkt_id
JOIN sklep.kategorie           k  ON k.kategoria_id  = p.kategoria_id
JOIN sklep.transakcje          t  ON t.transakcja_id = pt.transakcja_id
WHERE t.status = 'zrealizowana'
GROUP BY p.produkt_id, p.nazwa, k.nazwa
ORDER BY wartosc_sprzedazy DESC
LIMIT 10;
```

| produkt_id | produkt                         | kategoria       | sprzedane_szt | wartosc_sprzedazy |
| ---------- | ------------------------------- | --------------- | ------------- | ----------------- |
| 5          | ASUS GeForce RTX 4070 DUAL OC   | Karty graficzne | 1             | 2799.00           |
| 6          | MSI Radeon RX 7800 XT GAMING X  | Karty graficzne | 1             | 2199.00           |
| 3          | AMD Ryzen 5 7600X               | Procesory       | 2             | 2198.00           |
| 2          | Intel Core i7-13700K            | Procesory       | 1             | 1799.00           |
| 19         | Gigabyte GeForce RTX 4060 EAGLE | Karty graficzne | 1             | 1749.00           |
| 7          | Kingston FURY Beast 16 GB DDR5  | Pamięci RAM     | 6             | 1494.00           |
| 4          | AMD Ryzen 7 7700X               | Procesory       | 1             | 1449.00           |
| 13         | MSI MAG X670E Tomahawk WiFi     | Płyty główne    | 1             | 1249.00           |
| 1          | Intel Core i5-13600K            | Procesory       | 1             | 1199.00           |
| 9          | Samsung 990 Pro 1 TB NVMe       | Dyski SSD       | 3             | 1107.00           |

## K4 – Obrót i marża na każdym produkcie

```sql
-- ============================================================
-- K4 – Obrót i marża na każdym produkcie
-- ============================================================
SELECT
    p.nazwa AS produkt,
    k.nazwa AS kategoria,
    p.cena_zakupu,
    p.cena_sprzedazy,
    (p.cena_sprzedazy - p.cena_zakupu) AS marza_szt,
    ROUND(
        (p.cena_sprzedazy - p.cena_zakupu) / p.cena_zakupu * 100,
        2
    ) AS marza_proc,
    COALESCE(sprz.sprzedane_szt, 0) AS sprzedane_szt,
    COALESCE(sprz.zysk_laczny, 0) AS zysk_laczny
FROM sklep.produkty p
JOIN sklep.kategorie k ON k.kategoria_id = p.kategoria_id
LEFT JOIN (
    SELECT
        pt.produkt_id,
        SUM(pt.ilosc) AS sprzedane_szt,
        SUM(pt.ilosc * (pt.cena_jednostkowa - p.cena_zakupu)) AS zysk_laczny
    FROM sklep.pozycje_transakcji pt
    JOIN sklep.transakcje t
        ON t.transakcja_id = pt.transakcja_id
    JOIN sklep.produkty p
        ON p.produkt_id = pt.produkt_id
    WHERE t.status = 'zrealizowana'
    GROUP BY pt.produkt_id
) sprz
    ON sprz.produkt_id = p.produkt_id
ORDER BY zysk_laczny DESC;
```

| produkt                         | kategoria       | cena_zakupu | cena_sprzedazy | marza_szt | marza_proc | sprzedane_szt | zysk_laczny |
| ------------------------------- | --------------- | ----------- | -------------- | --------- | ---------- | ------------- | ----------- |
| MSI Radeon RX 7800 XT GAMING X  | Karty graficzne | 1700.00     | 2199.00        | 499.00    | 29.35      | 2             | 998.00      |
| ASUS GeForce RTX 4070 DUAL OC   | Karty graficzne | 2200.00     | 2799.00        | 599.00    | 27.23      | 1             | 599.00      |
| AMD Ryzen 5 7600X               | Procesory       | 850.00      | 1099.00        | 249.00    | 29.29      | 2             | 498.00      |
| Kingston FURY Beast 16 GB DDR5  | Pamięci RAM     | 180.00      | 249.00         | 69.00     | 38.33      | 6             | 414.00      |
| Intel Core i7-13700K            | Procesory       | 1400.00     | 1799.00        | 399.00    | 28.50      | 1             | 399.00      |
| Gigabyte GeForce RTX 4060 EAGLE | Karty graficzne | 1350.00     | 1749.00        | 399.00    | 29.56      | 1             | 399.00      |
| AMD Ryzen 7 7700X               | Procesory       | 1100.00     | 1449.00        | 349.00    | 31.73      | 1             | 349.00      |
| Intel Core i5-13600K            | Procesory       | 900.00      | 1199.00        | 299.00    | 33.22      | 1             | 299.00      |
| MSI MAG X670E Tomahawk WiFi     | Płyty główne    | 950.00      | 1249.00        | 299.00    | 31.47      | 1             | 299.00      |
| Samsung 990 Pro 1 TB NVMe       | Dyski SSD       | 280.00      | 369.00         | 89.00     | 31.79      | 3             | 267.00      |

## K5 – Całkowity obrót i zysk sklepu

```sql
-- ============================================================
-- K5 – Całkowity obrót i zysk sklepu
-- ============================================================
SELECT
    SUM(pt.ilosc * pt.cena_jednostkowa)                   AS przychod_brutto,
    SUM(pt.ilosc * p.cena_zakupu)                         AS koszt_zakupu,
    SUM(pt.ilosc * (pt.cena_jednostkowa - p.cena_zakupu)) AS zysk_brutto,
    ROUND(
        SUM(pt.ilosc * (pt.cena_jednostkowa - p.cena_zakupu))
        / SUM(pt.ilosc * pt.cena_jednostkowa) * 100, 2
    )                                                     AS marza_proc
FROM sklep.pozycje_transakcji  pt
JOIN sklep.produkty            p  ON p.produkt_id    = pt.produkt_id
JOIN sklep.transakcje          t  ON t.transakcja_id = pt.transakcja_id
WHERE t.status = 'zrealizowana';
```

| przychod_brutto | koszt_zakupu | zysk_brutto | marza_proc |
| --------------- | ------------ | ----------- | ---------- |
| 22818.00        | 17360.00     | 5458.00     | 23.92      |

## K6 – Statystyki pracowników

```sql
-- ============================================================
-- K6 – Statystyki pracowników
-- ============================================================
SELECT
    pr.pracownik_id,
    pr.imie || ' ' || pr.nazwisko                         AS pracownik,
    pr.stanowisko,
    COUNT(DISTINCT t.transakcja_id)                        AS liczba_transakcji,
    SUM(pt.ilosc * pt.cena_jednostkowa)                    AS wartosc_sprzedazy
FROM sklep.pracownicy          pr
LEFT JOIN sklep.transakcje     t  ON t.pracownik_id  = pr.pracownik_id
                                 AND t.status = 'zrealizowana'
LEFT JOIN sklep.pozycje_transakcji pt ON pt.transakcja_id = t.transakcja_id
GROUP BY pr.pracownik_id, pr.imie, pr.nazwisko, pr.stanowisko
ORDER BY wartosc_sprzedazy DESC NULLS LAST;
```

| pracownik_id | pracownik        | stanowisko | liczba_transakcji | wartosc_sprzedazy |
| ------------ | ---------------- | ---------- | ----------------- | ----------------- |
| 5            | Michał Wróbel    | sprzedawca | 4                 | 9887.00           |
| 4            | Karolina Zając   | sprzedawca | 4                 | 6885.00           |
| 3            | Piotr Nowak      | sprzedawca | 6                 | 6046.00           |
| 1            | Jan Kowalski     | kierownik  | 0                 | NULL              |
| 2            | Anna Wiśniewska  | kierownik  | 0                 | NULL              |
| 6            | Tomasz Dąbrowski | magazynier | 0                 | NULL              |

## K7 – Produkty z niskim stanem magazynowym (≤ 5 szt.)

```sql
-- ============================================================
-- K7 – Produkty z niskim stanem magazynowym (≤ 5 szt.)
-- ============================================================
SELECT
    p.produkt_id,
    p.nazwa                  AS produkt,
    k.nazwa                  AS kategoria,
    p.ilosc_na_stanie        AS stan_magazynowy
FROM sklep.produkty  p
JOIN sklep.kategorie k ON k.kategoria_id = p.kategoria_id
WHERE p.ilosc_na_stanie <= 5
ORDER BY p.ilosc_na_stanie ASC;
```

| produkt_id | produkt                       | kategoria       | stan_magazynowy |
| ---------- | ----------------------------- | --------------- | --------------- |
| 5          | ASUS GeForce RTX 4070 DUAL OC | Karty graficzne | 4               |
| 13         | MSI MAG X670E Tomahawk WiFi   | Płyty główne    | 4               |
| 2          | Intel Core i7-13700K          | Procesory       | 5               |

## K8 – Wartość całego magazynu wg kategorii

```sql
-- ============================================================
-- K8 – Wartość całego magazynu wg kategorii
-- ============================================================
SELECT
    k.nazwa                                           AS kategoria,
    SUM(p.ilosc_na_stanie)                            AS szt_na_stanie,
    SUM(p.ilosc_na_stanie * p.cena_zakupu)            AS wartosc_zakupu,
    SUM(p.ilosc_na_stanie * p.cena_sprzedazy)         AS wartosc_sprzedazy
FROM sklep.produkty  p
JOIN sklep.kategorie k ON k.kategoria_id = p.kategoria_id
GROUP BY k.nazwa
ORDER BY wartosc_zakupu DESC;
```

| kategoria       | szt_na_stanie | wartosc_zakupu | wartosc_sprzedazy |
| --------------- | ------------- | -------------- | ----------------- |
| Karty graficzne | 20            | 32850.00       | 42330.00          |
| Procesory       | 29            | 29300.00       | 38271.00          |
| Dyski SSD       | 52            | 14140.00       | 18748.00          |
| Pamięci RAM     | 43            | 10260.00       | 13947.00          |
| Płyty główne    | 10            | 8600.00        | 11290.00          |
| Zasilacze       | 18            | 7080.00        | 9242.00           |
| Chłodzenie      | 31            | 4230.00        | 6159.00           |
| Obudowy         | 11            | 3080.00        | 4169.00           |
| Dyski HDD       | 12            | 1920.00        | 2628.00           |

## K9 – Sprzedaż miesięczna

```sql
-- ============================================================
-- K9 – Sprzedaż miesięczna
-- ============================================================
SELECT
    TO_CHAR(t.data_transakcji, 'YYYY-MM')          AS miesiac,
    COUNT(DISTINCT t.transakcja_id)                 AS liczba_transakcji,
    SUM(pt.ilosc * pt.cena_jednostkowa)             AS wartosc_sprzedazy
FROM sklep.transakcje          t
JOIN sklep.pozycje_transakcji  pt ON pt.transakcja_id = t.transakcja_id
WHERE t.status = 'zrealizowana'
GROUP BY TO_CHAR(t.data_transakcji, 'YYYY-MM')
ORDER BY miesiac;
```

| miesiac | liczba_transakcji | wartosc_sprzedazy |
| ------- | ----------------- | ----------------- |
| 2026-01 | 5                 | 8188.00           |
| 2026-02 | 6                 | 9058.00           |
| 2026-03 | 3                 | 5572.00           |

## K10 – Aktywność zarejestrowanych klientów

```sql
-- ============================================================
-- K10 – Aktywność zarejestrowanych klientów
-- ============================================================
SELECT
    kl.klient_id,
    kl.imie || ' ' || kl.nazwisko                  AS klient,
    COUNT(DISTINCT t.transakcja_id)                 AS liczba_wizyt,
    SUM(pt.ilosc * pt.cena_jednostkowa)             AS wydano_lacznie
FROM sklep.klienci             kl
JOIN sklep.transakcje          t  ON t.klient_id    = kl.klient_id
                                 AND t.status = 'zrealizowana'
JOIN sklep.pozycje_transakcji  pt ON pt.transakcja_id = t.transakcja_id
GROUP BY kl.klient_id, kl.imie, kl.nazwisko
ORDER BY wydano_lacznie DESC;
```

| klient_id | klient              | liczba_wizyt | wydano_lacznie |
| --------- | ------------------- | ------------ | -------------- |
| 7         | Łukasz Król         | 1            | 3517.00        |
| 3         | Robert Wierzbicki   | 1            | 2697.00        |
| 5         | Paweł Jankowski     | 1            | 2128.00        |
| 1         | Marek Kowalczyk     | 1            | 1937.00        |
| 9         | Damian Szymański    | 1            | 1545.00        |
| 6         | Beata Wysocka       | 1            | 1449.00        |
| 10        | Monika Lewandowska  | 1            | 1228.00        |
| 8         | Karolina Nowak      | 1            | 1037.00        |
| 2         | Joanna Pawlak       | 1            | 917.00         |
| 4         | Magdalena Dąbrowska | 1            | 429.00         |

## K11 – Zestawienie dostaw wg dostawcy

```sql
-- ============================================================
-- K11 – Zestawienie dostaw wg dostawcy
-- ============================================================
SELECT
    d.nazwa                                            AS dostawca,
    COUNT(DISTINCT dost.dostawa_id)                    AS liczba_dostaw,
    SUM(pd.ilosc * pd.cena_zakupu_jednostkowa)         AS wartosc_dostaw
FROM sklep.dostawcy            d
JOIN sklep.dostawy             dost ON dost.dostawca_id = d.dostawca_id
JOIN sklep.pozycje_dostawy     pd   ON pd.dostawa_id    = dost.dostawa_id
WHERE dost.status = 'przyjęta'
GROUP BY d.nazwa
ORDER BY wartosc_dostaw DESC;
```

| dostawca               | liczba_dostaw | wartosc_dostaw |
| ---------------------- | ------------- | -------------- |
| ALSO Polska Sp. z o.o. | 2             | 32220.00       |
| AB S.A.                | 2             | 30250.00       |
| Action S.A.            | 1             | 7440.00        |

## K12 – Sprzedaż vs zakupy wg kategorii

```sql
-- ============================================================
-- K12 – Sprzedaż vs zakupy wg kategorii
-- ============================================================
SELECT
    k.nazwa AS kategoria,
    COALESCE(SUM(pd_agg.zakupiono_szt), 0) AS zakupiono_szt,
    COALESCE(SUM(pt_agg.sprzedano_szt), 0) AS sprzedano_szt
FROM sklep.kategorie k
LEFT JOIN sklep.produkty p
    ON p.kategoria_id = k.kategoria_id
LEFT JOIN (
    SELECT
        produkt_id,
        SUM(ilosc) AS zakupiono_szt
    FROM sklep.pozycje_dostawy
    GROUP BY produkt_id
) pd_agg
    ON pd_agg.produkt_id = p.produkt_id
LEFT JOIN (
    SELECT
        pt.produkt_id,
        SUM(pt.ilosc) AS sprzedano_szt
    FROM sklep.pozycje_transakcji pt
    JOIN sklep.transakcje t
        ON t.transakcja_id = pt.transakcja_id
    WHERE t.status = 'zrealizowana'
    GROUP BY pt.produkt_id
) pt_agg
    ON pt_agg.produkt_id = p.produkt_id
GROUP BY k.nazwa
ORDER BY k.nazwa
LIMIT 10;
```

| kategoria       | zakupiono_szt | sprzedano_szt |
| --------------- | ------------- | ------------- |
| Chłodzenie      | 15            | 4             |
| Dyski HDD       | 10            | 2             |
| Dyski SSD       | 32            | 5             |
| Karty graficzne | 13            | 3             |
| Karty sieciowe  | 0             | 0             |
| Obudowy         | 6             | 1             |
| Pamięci RAM     | 35            | 7             |
| Płyty główne    | 7             | 2             |
| Procesory       | 19            | 5             |
| Zasilacze       | 11            | 3             |
