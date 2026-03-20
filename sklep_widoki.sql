-- Widoki analityczne – stacjonarny sklep z częściami komputerowymi
-- Schemat: sklep
--
-- Uruchom raz po załadowaniu danych, aby zarejestrować widoki:
-- \i 'C:/sciezka/do/projektu/sklep_widoki.sql'
--
-- Następnie każdą analizę uruchamiasz jedną komendą, np.:
-- SELECT * FROM sklep.v_sprzedaz_kategoria;
--
-- Lista widoków:
--   v_sprzedaz_kategoria    – K1  Sprzedaż wg kategorii
--   v_sprzedaz_producent    – K2  Sprzedaż wg producenta
--   v_top_produkty          – K3  Top 10 produktów wg wartości sprzedaży
--   v_marza_produkty        – K4  Obrót i marża na każdym produkcie
--   v_obrot_sklep           – K5  Całkowity obrót i zysk sklepu
--   v_statystyki_pracownicy – K6  Statystyki pracowników
--   v_niski_stan            – K7  Produkty z niskim stanem (≤ 5 szt.)
--   v_wartosc_magazyn       – K8  Wartość magazynu wg kategorii
--   v_sprzedaz_miesiac      – K9  Sprzedaż miesięczna
--   v_aktywnosc_klientow    – K10 Aktywność zarejestrowanych klientów
--   v_zestawienie_dostaw    – K11 Zestawienie dostaw wg dostawcy
--   v_sprzedaz_vs_zakupy    – K12 Sprzedaż vs zakupy wg kategorii
-- ============================================================


-- ============================================================
-- K1 – Sprzedaż wg kategorii produktów
-- ============================================================
CREATE OR REPLACE VIEW sklep.v_sprzedaz_kategoria AS
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
-- ============================================================
CREATE OR REPLACE VIEW sklep.v_sprzedaz_producent AS
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


-- ============================================================
-- K3 – Top 10 produktów wg wartości sprzedaży
-- ============================================================
CREATE OR REPLACE VIEW sklep.v_top_produkty AS
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
-- ============================================================
CREATE OR REPLACE VIEW sklep.v_marza_produkty AS
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


-- ============================================================
-- K5 – Całkowity obrót i zysk sklepu
-- ============================================================
CREATE OR REPLACE VIEW sklep.v_obrot_sklep AS
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
-- K6 – Statystyki pracowników
-- ============================================================
CREATE OR REPLACE VIEW sklep.v_statystyki_pracownicy AS
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


-- ============================================================
-- K7 – Produkty z niskim stanem magazynowym (≤ 5 szt.)
-- ============================================================
CREATE OR REPLACE VIEW sklep.v_niski_stan AS
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
-- K8 – Wartość całego magazynu wg kategorii
-- ============================================================
CREATE OR REPLACE VIEW sklep.v_wartosc_magazyn AS
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
-- ============================================================
CREATE OR REPLACE VIEW sklep.v_sprzedaz_miesiac AS
SELECT
    TO_CHAR(t.data_transakcji, 'YYYY-MM')          AS miesiac,
    COUNT(DISTINCT t.transakcja_id)                 AS liczba_transakcji,
    SUM(pt.ilosc * pt.cena_jednostkowa)             AS wartosc_sprzedazy
FROM sklep.transakcje          t
JOIN sklep.pozycje_transakcji  pt ON pt.transakcja_id = t.transakcja_id
WHERE t.status = 'zrealizowana'
GROUP BY TO_CHAR(t.data_transakcji, 'YYYY-MM')
ORDER BY miesiac;


-- ============================================================
-- K10 – Aktywność zarejestrowanych klientów
-- ============================================================
CREATE OR REPLACE VIEW sklep.v_aktywnosc_klientow AS
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
-- ============================================================
CREATE OR REPLACE VIEW sklep.v_zestawienie_dostaw AS
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
-- K12 – Sprzedaż vs zakupy wg kategorii
-- ============================================================
CREATE OR REPLACE VIEW sklep.v_sprzedaz_vs_zakupy AS
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


-- ============================================================
-- SZYBKIE WYWOŁANIA – po uruchomieniu tego skryptu
-- wystarczy jedna linia:
-- ============================================================
-- SELECT * FROM sklep.v_sprzedaz_kategoria;
-- SELECT * FROM sklep.v_sprzedaz_producent;
-- SELECT * FROM sklep.v_top_produkty;
-- SELECT * FROM sklep.v_marza_produkty;
-- SELECT * FROM sklep.v_obrot_sklep;
-- SELECT * FROM sklep.v_statystyki_pracownicy;
-- SELECT * FROM sklep.v_niski_stan;
-- SELECT * FROM sklep.v_wartosc_magazyn;
-- SELECT * FROM sklep.v_sprzedaz_miesiac;
-- SELECT * FROM sklep.v_aktywnosc_klientow;
-- SELECT * FROM sklep.v_zestawienie_dostaw;
-- SELECT * FROM sklep.v_sprzedaz_vs_zakupy;

-- Wyświetl listę wszystkich widoków w schemacie sklep:
-- SELECT viewname FROM pg_views WHERE schemaname = 'sklep' ORDER BY viewname;


-- ============================================================
-- SKRÓCONE ALIASY k1 – k12
--   Wywołanie: SELECT * FROM sklep.k1;  … SELECT * FROM sklep.k12;
-- ============================================================
CREATE OR REPLACE VIEW sklep.k1  AS SELECT * FROM sklep.v_sprzedaz_kategoria;
CREATE OR REPLACE VIEW sklep.k2  AS SELECT * FROM sklep.v_sprzedaz_producent;
CREATE OR REPLACE VIEW sklep.k3  AS SELECT * FROM sklep.v_top_produkty;
CREATE OR REPLACE VIEW sklep.k4  AS SELECT * FROM sklep.v_marza_produkty;
CREATE OR REPLACE VIEW sklep.k5  AS SELECT * FROM sklep.v_obrot_sklep;
CREATE OR REPLACE VIEW sklep.k6  AS SELECT * FROM sklep.v_statystyki_pracownicy;
CREATE OR REPLACE VIEW sklep.k7  AS SELECT * FROM sklep.v_niski_stan;
CREATE OR REPLACE VIEW sklep.k8  AS SELECT * FROM sklep.v_wartosc_magazyn;
CREATE OR REPLACE VIEW sklep.k9  AS SELECT * FROM sklep.v_sprzedaz_miesiac;
CREATE OR REPLACE VIEW sklep.k10 AS SELECT * FROM sklep.v_aktywnosc_klientow;
CREATE OR REPLACE VIEW sklep.k11 AS SELECT * FROM sklep.v_zestawienie_dostaw;
CREATE OR REPLACE VIEW sklep.k12 AS SELECT * FROM sklep.v_sprzedaz_vs_zakupy;
