-- Kwerendy analityczne – stacjonarny sklep z częściami komputerowymi
-- Schemat: sklep
--
-- Widoki zdefiniowane są w pliku sklep_widoki.sql.
-- Uruchom go raz, a następnie każdą kwerendę wywołaj jedną linią:
--   SELECT * FROM sklep.v_<nazwa>;
--
-- Poniżej znajdują się pełne definicje SQL (wersja referencyjna).
-- ============================================================


-- ============================================================
-- K1 – Sprzedaż wg kategorii produktów
--      Łączna wartość sprzedaży (brutto) i liczba transakcji
--      dla każdej kategorii, posortowane malejąco.
--
--  Szybkie wywołanie: SELECT * FROM sklep.v_sprzedaz_kategoria;
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


-- ============================================================
-- K2 – Sprzedaż wg producenta
--      Ranking producentów wg przychodu ze sprzedaży.
--
--  Szybkie wywołanie: SELECT * FROM sklep.v_sprzedaz_producent;
-- ============================================================
SELECT
    pr.nazwa                                     AS producent,
    SUM(pt.ilosc * pt.cena_jednostkowa)          AS wartosc_sprzedazy,
    SUM(pt.ilosc)                                AS sprzedane_szt
FROM sklep.pozycje_transakcji  pt
JOIN sklep.produkty            p  ON p.produkt_id   = pt.produkt_id
JOIN sklep.producenci          pr ON pr.producent_id = p.producent_id
JOIN sklep.transakcje          t  ON t.transakcja_id = pt.transakcja_id
WHERE t.status = 'zrealizowana'
GROUP BY pr.nazwa
ORDER BY wartosc_sprzedazy DESC;


-- ============================================================
-- K3 – Najlepiej sprzedające się produkty (Top 10)
--      Ranking wg łącznej wartości sprzedaży.
--
--  Szybkie wywołanie: SELECT * FROM sklep.v_top_produkty;
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


-- ============================================================
-- K4 – Obrót i marża na każdym produkcie
--      Marża = cena_sprzedaży - cena_zakupu (na sztukę)
--      Marża % = marża / cena_zakupu × 100
--
--  Szybkie wywołanie: SELECT * FROM sklep.v_marza_produkty;
-- ============================================================
SELECT
    p.nazwa                                               AS produkt,
    k.nazwa                                               AS kategoria,
    p.cena_zakupu,
    p.cena_sprzedazy,
    (p.cena_sprzedazy - p.cena_zakupu)                    AS marza_szt,
    ROUND(
        (p.cena_sprzedazy - p.cena_zakupu)
        / p.cena_zakupu * 100, 2
    )                                                     AS marza_proc,
    COALESCE(SUM(pt.ilosc), 0)                            AS sprzedane_szt,
    COALESCE(
        SUM(pt.ilosc * (pt.cena_jednostkowa - p.cena_zakupu)),
        0
    )                                                     AS zysk_laczny
FROM sklep.produkty            p
JOIN sklep.kategorie           k   ON k.kategoria_id  = p.kategoria_id
LEFT JOIN sklep.pozycje_transakcji pt ON pt.produkt_id = p.produkt_id
LEFT JOIN sklep.transakcje         t  ON t.transakcja_id = pt.transakcja_id
                                     AND t.status = 'zrealizowana'
GROUP BY p.produkt_id, p.nazwa, k.nazwa, p.cena_zakupu, p.cena_sprzedazy
ORDER BY zysk_laczny DESC;


-- ============================================================
-- K5 – Całkowity obrót i zysk sklepu
--
--  Szybkie wywołanie: SELECT * FROM sklep.v_obrot_sklep;
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


-- ============================================================
-- K6 – Statystyki pracowników (sprzedawców)
--      Liczba obsłużonych transakcji i wartość sprzedaży.
--
--  Szybkie wywołanie: SELECT * FROM sklep.v_statystyki_pracownicy;
-- ============================================================
SELECT
    pr.pracownik_id,
    pr.imie || ' ' || pr.nazwisko                        AS pracownik,
    pr.stanowisko,
    COUNT(DISTINCT t.transakcja_id)                       AS liczba_transakcji,
    SUM(pt.ilosc * pt.cena_jednostkowa)                   AS wartosc_sprzedazy
FROM sklep.pracownicy          pr
LEFT JOIN sklep.transakcje     t  ON t.pracownik_id  = pr.pracownik_id
                                 AND t.status = 'zrealizowana'
LEFT JOIN sklep.pozycje_transakcji pt ON pt.transakcja_id = t.transakcja_id
GROUP BY pr.pracownik_id, pr.imie, pr.nazwisko, pr.stanowisko
ORDER BY wartosc_sprzedazy DESC NULLS LAST;


-- ============================================================
-- K7 – Stany magazynowe (produkty z niskim stanem)
--      Produkty, których stan jest ≤ 5 sztuk.
--
--  Szybkie wywołanie: SELECT * FROM sklep.v_niski_stan;
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


-- ============================================================
-- K8 – Wartość całego magazynu (cena zakupu)
--
--  Szybkie wywołanie: SELECT * FROM sklep.v_wartosc_magazyn;
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


-- ============================================================
-- K9 – Sprzedaż miesięczna
--      Przychód w każdym miesiącu (zrealizowane transakcje).
--
--  Szybkie wywołanie: SELECT * FROM sklep.v_sprzedaz_miesiac;
-- ============================================================
SELECT
    TO_CHAR(t.data_transakcji, 'YYYY-MM')          AS miesiac,
    COUNT(DISTINCT t.transakcja_id)                 AS liczba_transakcji,
    SUM(pt.ilosc * pt.cena_jednostkowa)             AS wartosc_sprzedazy
FROM sklep.transakcje          t
JOIN sklep.pozycje_transakcji  pt ON pt.transakcja_id = t.transakcja_id
WHERE t.status = 'zrealizowana'
GROUP BY miesiac
ORDER BY miesiac;


-- ============================================================
-- K10 – Aktywność klientów
--       Ile transakcji i ile wydali zarejestrowani klienci.
--
--  Szybkie wywołanie: SELECT * FROM sklep.v_aktywnosc_klientow;
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


-- ============================================================
-- K11 – Zestawienie dostaw wg dostawcy
--       Suma wartości (po cenach zakupu) dla każdego dostawcy.
--
--  Szybkie wywołanie: SELECT * FROM sklep.v_zestawienie_dostaw;
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


-- ============================================================
-- K12 – Zestawienie sprzedaży vs zakupów wg kategorii
--       Ile sprzedano vs ile zakupiono od dostawców.
--
--  Szybkie wywołanie: SELECT * FROM sklep.v_sprzedaz_vs_zakupy;
-- ============================================================
SELECT
    k.nazwa                                             AS kategoria,
    COALESCE(SUM(pd.ilosc), 0)                          AS zakupiono_szt,
    COALESCE(SUM(pt_agg.sprzedano_szt), 0)              AS sprzedano_szt
FROM sklep.kategorie k
LEFT JOIN sklep.produkty p ON p.kategoria_id = k.kategoria_id
LEFT JOIN sklep.pozycje_dostawy pd ON pd.produkt_id = p.produkt_id
LEFT JOIN (
    SELECT pt.produkt_id, SUM(pt.ilosc) AS sprzedano_szt
    FROM sklep.pozycje_transakcji  pt
    JOIN sklep.transakcje          t ON t.transakcja_id = pt.transakcja_id
    WHERE t.status = 'zrealizowana'
    GROUP BY pt.produkt_id
) pt_agg ON pt_agg.produkt_id = p.produkt_id
GROUP BY k.nazwa
ORDER BY k.nazwa;
