# Wyniki kwerend analitycznych – sklep komputerowy

Każdy wynik ograniczony do **10 rekordów**.

## K1 – Sprzedaż wg kategorii

```sql
-- Szybkie wywołanie:
SELECT * FROM sklep.k1;

-- Pełna definicja (widok v_sprzedaz_kategoria):
SELECT k.nazwa AS kategoria,
    sum(((pt.ilosc)::numeric * pt.cena_jednostkowa)) AS wartosc_sprzedazy,
    count(DISTINCT pt.transakcja_id) AS liczba_transakcji,
    sum(pt.ilosc) AS sprzedane_szt
   FROM (((sklep.pozycje_transakcji pt
     JOIN sklep.produkty p ON ((p.produkt_id = pt.produkt_id)))
     JOIN sklep.kategorie k ON ((k.kategoria_id = p.kategoria_id)))
     JOIN sklep.transakcje t ON ((t.transakcja_id = pt.transakcja_id)))
  WHERE ((t.status)::text = 'zrealizowana'::text)
  GROUP BY k.nazwa.;..;.;;.  plkp[kpo[ iopo uiohi ugug gjhbmbkm ]]
  ORDER BY (sum(((pt.ilosc)::numeric * pt.cena_jednostkowa))) DESC;
```

| kategoria       | wartosc_sprzedazy | liczba_transakcji | sprzedane_szt |
| --------------- | ----------------- | ----------------- | ------------- |
| Karty graficzne | 6747              | 3                 | 3             |
| Procesory       | 6645              | 5                 | 5             |
| Płyty główne    | 2298              | 2                 | 2             |
| Pamięci RAM     | 1923              | 3                 | 7             |
| Dyski SSD       | 1825              | 3                 | 5             |
| Zasilacze       | 1567              | 3                 | 3             |
| Chłodzenie      | 996               | 3                 | 4             |
| Dyski HDD       | 438               | 1                 | 2             |
| Obudowy         | 379               | 1                 | 1             |

## K2 – Sprzedaż wg producenta

```sql
-- Szybkie wywołanie:
SELECT * FROM sklep.k2;

-- Pełna definicja (widok v_sprzedaz_producent):
SELECT pr.nazwa AS producent,
    sum(((pt.ilosc)::numeric * pt.cena_jednostkowa)) AS wartosc_sprzedazy,
    sum(pt.ilosc) AS sprzedane_szt
   FROM (((sklep.pozycje_transakcji pt
     JOIN sklep.produkty p ON ((p.produkt_id = pt.produkt_id)))
     JOIN sklep.producenci pr ON ((pr.producent_id = p.producent_id)))
     JOIN sklep.transakcje t ON ((t.transakcja_id = pt.transakcja_id)))
  WHERE ((t.status)::text = 'zrealizowana'::text)
  GROUP BY pr.nazwa
  ORDER BY (sum(((pt.ilosc)::numeric * pt.cena_jednostkowa))) DESC;
```

| producent | wartosc_sprzedazy | sprzedane_szt |
| --------- | ----------------- | ------------- |
| ASUS      | 3848              | 2             |
| AMD       | 3647              | 3             |
| MSI       | 3448              | 2             |
| Intel     | 2998              | 2             |
| Kingston  | 1793              | 7             |
| Gigabyte  | 1749              | 1             |
| Corsair   | 1527              | 3             |
| Samsung   | 1107              | 3             |
| be quiet! | 1106              | 4             |
| Noctua    | 738               | 2             |

## K3 – Top 10 produktów wg wartości sprzedaży

```sql
-- Szybkie wywołanie:
SELECT * FROM sklep.k3;

-- Pełna definicja (widok v_top_produkty):
SELECT p.produkt_id,
    p.nazwa AS produkt,
    k.nazwa AS kategoria,
    sum(pt.ilosc) AS sprzedane_szt,
    sum(((pt.ilosc)::numeric * pt.cena_jednostkowa)) AS wartosc_sprzedazy
   FROM (((sklep.pozycje_transakcji pt
     JOIN sklep.produkty p ON ((p.produkt_id = pt.produkt_id)))
     JOIN sklep.kategorie k ON ((k.kategoria_id = p.kategoria_id)))
     JOIN sklep.transakcje t ON ((t.transakcja_id = pt.transakcja_id)))
  WHERE ((t.status)::text = 'zrealizowana'::text)
  GROUP BY p.produkt_id, p.nazwa, k.nazwa
  ORDER BY (sum(((pt.ilosc)::numeric * pt.cena_jednostkowa))) DESC
 LIMIT 10;
```

| produkt_id | produkt                         | kategoria       | sprzedane_szt | wartosc_sprzedazy |
| ---------- | ------------------------------- | --------------- | ------------- | ----------------- |
| 5          | ASUS GeForce RTX 4070 DUAL OC   | Karty graficzne | 1             | 2799              |
| 6          | MSI Radeon RX 7800 XT GAMING X  | Karty graficzne | 1             | 2199              |
| 3          | AMD Ryzen 5 7600X               | Procesory       | 2             | 2198              |
| 2          | Intel Core i7-13700K            | Procesory       | 1             | 1799              |
| 19         | Gigabyte GeForce RTX 4060 EAGLE | Karty graficzne | 1             | 1749              |
| 7          | Kingston FURY Beast 16 GB DDR5  | Pamięci RAM     | 6             | 1494              |
| 4          | AMD Ryzen 7 7700X               | Procesory       | 1             | 1449              |
| 13         | MSI MAG X670E Tomahawk WiFi     | Płyty główne    | 1             | 1249              |
| 1          | Intel Core i5-13600K            | Procesory       | 1             | 1199              |
| 9          | Samsung 990 Pro 1 TB NVMe       | Dyski SSD       | 3             | 1107              |

## K4 – Obrót i marża na produktach

```sql
-- Szybkie wywołanie:
SELECT * FROM sklep.k4;

-- Pełna definicja (widok v_marza_produkty):
SELECT p.nazwa AS produkt,
    k.nazwa AS kategoria,
    p.cena_zakupu,
    p.cena_sprzedazy,
    (p.cena_sprzedazy - p.cena_zakupu) AS marza_szt,
    round((((p.cena_sprzedazy - p.cena_zakupu) / p.cena_zakupu) * (100)::numeric), 2) AS marza_proc,
    COALESCE(sum(pt.ilosc), (0)::bigint) AS sprzedane_szt,
    COALESCE(sum(((pt.ilosc)::numeric * (pt.cena_jednostkowa - p.cena_zakupu))), (0)::numeric) AS zysk_laczny
   FROM (((sklep.produkty p
     JOIN sklep.kategorie k ON ((k.kategoria_id = p.kategoria_id)))
     LEFT JOIN sklep.pozycje_transakcji pt ON ((pt.produkt_id = p.produkt_id)))
     LEFT JOIN sklep.transakcje t ON (((t.transakcja_id = pt.transakcja_id) AND ((t.status)::text = 'zrealizowana'::text))))
  GROUP BY p.produkt_id, p.nazwa, k.nazwa, p.cena_zakupu, p.cena_sprzedazy
  ORDER BY COALESCE(sum(((pt.ilosc)::numeric * (pt.cena_jednostkowa - p.cena_zakupu))), (0)::numeric) DESC;
```

| produkt                         | kategoria       | cena_zakupu | cena_sprzedazy | marza_szt | marza_proc | sprzedane_szt | zysk_laczny |
| ------------------------------- | --------------- | ----------- | -------------- | --------- | ---------- | ------------- | ----------- |
| MSI Radeon RX 7800 XT GAMING X  | Karty graficzne | 1700        | 2199           | 499       | 29.35      | 2             | 998         |
| ASUS GeForce RTX 4070 DUAL OC   | Karty graficzne | 2200        | 2799           | 599       | 27.23      | 1             | 599         |
| AMD Ryzen 5 7600X               | Procesory       | 850         | 1099           | 249       | 29.29      | 2             | 498         |
| Kingston FURY Beast 16 GB DDR5  | Pamięci RAM     | 180         | 249            | 69        | 38.33      | 6             | 414         |
| Intel Core i7-13700K            | Procesory       | 1400        | 1799           | 399       | 28.5       | 1             | 399         |
| Gigabyte GeForce RTX 4060 EAGLE | Karty graficzne | 1350        | 1749           | 399       | 29.56      | 1             | 399         |
| AMD Ryzen 7 7700X               | Procesory       | 1100        | 1449           | 349       | 31.73      | 1             | 349         |
| Intel Core i5-13600K            | Procesory       | 900         | 1199           | 299       | 33.22      | 1             | 299         |
| MSI MAG X670E Tomahawk WiFi     | Płyty główne    | 950         | 1249           | 299       | 31.47      | 1             | 299         |
| Samsung 990 Pro 1 TB NVMe       | Dyski SSD       | 280         | 369            | 89        | 31.79      | 3             | 267         |

## K5 – Całkowity obrót i zysk sklepu

```sql
-- Szybkie wywołanie:
SELECT * FROM sklep.k5;

-- Pełna definicja (widok v_obrot_sklep):
SELECT sum(((pt.ilosc)::numeric * pt.cena_jednostkowa)) AS przychod_brutto,
    sum(((pt.ilosc)::numeric * p.cena_zakupu)) AS koszt_zakupu,
    sum(((pt.ilosc)::numeric * (pt.cena_jednostkowa - p.cena_zakupu))) AS zysk_brutto,
    round(((sum(((pt.ilosc)::numeric * (pt.cena_jednostkowa - p.cena_zakupu))) / sum(((pt.ilosc)::numeric * pt.cena_jednostkowa))) * (100)::numeric), 2) AS marza_proc
   FROM ((sklep.pozycje_transakcji pt
     JOIN sklep.produkty p ON ((p.produkt_id = pt.produkt_id)))
     JOIN sklep.transakcje t ON ((t.transakcja_id = pt.transakcja_id)))
  WHERE ((t.status)::text = 'zrealizowana'::text);
```

| przychod_brutto | koszt_zakupu | zysk_brutto | marza_proc |
| --------------- | ------------ | ----------- | ---------- |
| 22818           | 17360        | 5458        | 23.92      |

## K6 – Statystyki pracowników

```sql
-- Szybkie wywołanie:
SELECT * FROM sklep.k6;

-- Pełna definicja (widok v_statystyki_pracownicy):
SELECT pr.pracownik_id,
    (((pr.imie)::text || ' '::text) || (pr.nazwisko)::text) AS pracownik,
    pr.stanowisko,
    count(DISTINCT t.transakcja_id) AS liczba_transakcji,
    sum(((pt.ilosc)::numeric * pt.cena_jednostkowa)) AS wartosc_sprzedazy
   FROM ((sklep.pracownicy pr
     LEFT JOIN sklep.transakcje t ON (((t.pracownik_id = pr.pracownik_id) AND ((t.status)::text = 'zrealizowana'::text))))
     LEFT JOIN sklep.pozycje_transakcji pt ON ((pt.transakcja_id = t.transakcja_id)))
  GROUP BY pr.pracownik_id, pr.imie, pr.nazwisko, pr.stanowisko
  ORDER BY (sum(((pt.ilosc)::numeric * pt.cena_jednostkowa))) DESC NULLS LAST;
```

| pracownik_id | pracownik        | stanowisko | liczba_transakcji | wartosc_sprzedazy |
| ------------ | ---------------- | ---------- | ----------------- | ----------------- |
| 5            | Michał Wróbel    | sprzedawca | 4                 | 9887              |
| 4            | Karolina Zając   | sprzedawca | 4                 | 6885              |
| 3            | Piotr Nowak      | sprzedawca | 6                 | 6046              |
| 1            | Jan Kowalski     | kierownik  | 0                 | NULL              |
| 2            | Anna Wiśniewska  | kierownik  | 0                 | NULL              |
| 6            | Tomasz Dąbrowski | magazynier | 0                 | NULL              |

## K7 – Produkty z niskim stanem magazynowym

```sql
-- Szybkie wywołanie:
SELECT * FROM sklep.k7;

-- Pełna definicja (widok v_niski_stan):
SELECT p.produkt_id,
    p.nazwa AS produkt,
    k.nazwa AS kategoria,
    p.ilosc_na_stanie AS stan_magazynowy
   FROM (sklep.produkty p
     JOIN sklep.kategorie k ON ((k.kategoria_id = p.kategoria_id)))
  WHERE (p.ilosc_na_stanie <= 5)
  ORDER BY p.ilosc_na_stanie;
```

| produkt_id | produkt                       | kategoria       | stan_magazynowy |
| ---------- | ----------------------------- | --------------- | --------------- |
| 5          | ASUS GeForce RTX 4070 DUAL OC | Karty graficzne | 4               |
| 13         | MSI MAG X670E Tomahawk WiFi   | Płyty główne    | 4               |
| 2          | Intel Core i7-13700K          | Procesory       | 5               |

## K8 – Wartość magazynu wg kategorii

```sql
-- Szybkie wywołanie:
SELECT * FROM sklep.k8;

-- Pełna definicja (widok v_wartosc_magazyn):
SELECT k.nazwa AS kategoria,
    sum(p.ilosc_na_stanie) AS szt_na_stanie,
    sum(((p.ilosc_na_stanie)::numeric * p.cena_zakupu)) AS wartosc_zakupu,
    sum(((p.ilosc_na_stanie)::numeric * p.cena_sprzedazy)) AS wartosc_sprzedazy
   FROM (sklep.produkty p
     JOIN sklep.kategorie k ON ((k.kategoria_id = p.kategoria_id)))
  GROUP BY k.nazwa
  ORDER BY (sum(((p.ilosc_na_stanie)::numeric * p.cena_zakupu))) DESC;
```

| kategoria       | szt_na_stanie | wartosc_zakupu | wartosc_sprzedazy |
| --------------- | ------------- | -------------- | ----------------- |
| Karty graficzne | 20            | 32850          | 42330             |
| Procesory       | 29            | 29300          | 38271             |
| Dyski SSD       | 52            | 14140          | 18748             |
| Pamięci RAM     | 43            | 10260          | 13947             |
| Płyty główne    | 10            | 8600           | 11290             |
| Zasilacze       | 18            | 7080           | 9242              |
| Chłodzenie      | 31            | 4230           | 6159              |
| Obudowy         | 11            | 3080           | 4169              |
| Dyski HDD       | 12            | 1920           | 2628              |

## K9 – Sprzedaż miesięczna

```sql
-- Szybkie wywołanie:
SELECT * FROM sklep.k9;

-- Pełna definicja (widok v_sprzedaz_miesiac):
SELECT to_char(t.data_transakcji, 'YYYY-MM'::text) AS miesiac,
    count(DISTINCT t.transakcja_id) AS liczba_transakcji,
    sum(((pt.ilosc)::numeric * pt.cena_jednostkowa)) AS wartosc_sprzedazy
   FROM (sklep.transakcje t
     JOIN sklep.pozycje_transakcji pt ON ((pt.transakcja_id = t.transakcja_id)))
  WHERE ((t.status)::text = 'zrealizowana'::text)
  GROUP BY (to_char(t.data_transakcji, 'YYYY-MM'::text))
  ORDER BY (to_char(t.data_transakcji, 'YYYY-MM'::text));
```

| miesiac | liczba_transakcji | wartosc_sprzedazy |
| ------- | ----------------- | ----------------- |
| 2026-01 | 5                 | 8188              |
| 2026-02 | 6                 | 9058              |
| 2026-03 | 3                 | 5572              |

## K10 – Aktywność zarejestrowanych klientów

```sql
-- Szybkie wywołanie:
SELECT * FROM sklep.k10;

-- Pełna definicja (widok v_aktywnosc_klientow):
SELECT kl.klient_id,
    (((kl.imie)::text || ' '::text) || (kl.nazwisko)::text) AS klient,
    count(DISTINCT t.transakcja_id) AS liczba_wizyt,
    sum(((pt.ilosc)::numeric * pt.cena_jednostkowa)) AS wydano_lacznie
   FROM ((sklep.klienci kl
     JOIN sklep.transakcje t ON (((t.klient_id = kl.klient_id) AND ((t.status)::text = 'zrealizowana'::text))))
     JOIN sklep.pozycje_transakcji pt ON ((pt.transakcja_id = t.transakcja_id)))
  GROUP BY kl.klient_id, kl.imie, kl.nazwisko
  ORDER BY (sum(((pt.ilosc)::numeric * pt.cena_jednostkowa))) DESC;
```

| klient_id | klient              | liczba_wizyt | wydano_lacznie |
| --------- | ------------------- | ------------ | -------------- |
| 7         | Łukasz Król         | 1            | 3517           |
| 3         | Robert Wierzbicki   | 1            | 2697           |
| 5         | Paweł Jankowski     | 1            | 2128           |
| 1         | Marek Kowalczyk     | 1            | 1937           |
| 9         | Damian Szymański    | 1            | 1545           |
| 6         | Beata Wysocka       | 1            | 1449           |
| 10        | Monika Lewandowska  | 1            | 1228           |
| 8         | Karolina Nowak      | 1            | 1037           |
| 2         | Joanna Pawlak       | 1            | 917            |
| 4         | Magdalena Dąbrowska | 1            | 429            |

## K11 – Zestawienie dostaw wg dostawcy

```sql
-- Szybkie wywołanie:
SELECT * FROM sklep.k11;

-- Pełna definicja (widok v_zestawienie_dostaw):
SELECT d.nazwa AS dostawca,
    count(DISTINCT dost.dostawa_id) AS liczba_dostaw,
    sum(((pd.ilosc)::numeric * pd.cena_zakupu_jednostkowa)) AS wartosc_dostaw
   FROM ((sklep.dostawcy d
     JOIN sklep.dostawy dost ON ((dost.dostawca_id = d.dostawca_id)))
     JOIN sklep.pozycje_dostawy pd ON ((pd.dostawa_id = dost.dostawa_id)))
  WHERE ((dost.status)::text = 'przyjęta'::text)
  GROUP BY d.nazwa
  ORDER BY (sum(((pd.ilosc)::numeric * pd.cena_zakupu_jednostkowa))) DESC;
```

| dostawca               | liczba_dostaw | wartosc_dostaw |
| ---------------------- | ------------- | -------------- |
| ALSO Polska Sp. z o.o. | 2             | 32220          |
| AB S.A.                | 2             | 30250          |
| Action S.A.            | 1             | 7440           |

## K12 – Sprzedaż vs zakupy wg kategorii

```sql
-- Szybkie wywołanie:
SELECT * FROM sklep.k12;

-- Pełna definicja (widok v_sprzedaz_vs_zakupy):
SELECT k.nazwa AS kategoria,
    COALESCE(sum(pd.ilosc), (0)::bigint) AS zakupiono_szt,
    COALESCE(sum(pt_agg.sprzedano_szt), (0)::numeric) AS sprzedano_szt
   FROM (((sklep.kategorie k
     LEFT JOIN sklep.produkty p ON ((p.kategoria_id = k.kategoria_id)))
     LEFT JOIN sklep.pozycje_dostawy pd ON ((pd.produkt_id = p.produkt_id)))
     LEFT JOIN ( SELECT pt.produkt_id,
            sum(pt.ilosc) AS sprzedano_szt
           FROM (sklep.pozycje_transakcji pt
             JOIN sklep.transakcje t ON ((t.transakcja_id = pt.transakcja_id)))
          WHERE ((t.status)::text = 'zrealizowana'::text)
          GROUP BY pt.produkt_id) pt_agg ON ((pt_agg.produkt_id = p.produkt_id)))
  GROUP BY k.nazwa
  ORDER BY k.nazwa;
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
