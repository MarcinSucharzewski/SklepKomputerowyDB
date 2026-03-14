-- Definicja tabel bazy danych stacjonarnego sklepu z częściami komputerowymi
-- Schemat: sklep | Baza danych: PostgreSQL
--
-- === INSTRUKCJA URUCHOMIENIA ===
--
-- Otwórz psql i zaloguj się do dowolnej istniejącej bazy (np. postgres)
-- jako użytkownik z uprawnieniami do tworzenia baz danych.
--
-- Utwórz bazę danych poleceniem:
-- CREATE DATABASE sklep_komputerowy;
--
-- Połącz się z nową bazą:
-- \c sklep_komputerowy
--
-- Utwórz schemat:
-- CREATE SCHEMA IF NOT EXISTS sklep;
--
-- Uruchom ten skrypt (podaj właściwą ścieżkę):
-- \i 'C:/sciezka/do/projektu/sklep_tabele.sql'
--
-- Sprawdź utworzone tabele:
-- \dt sklep.*
--
-- Wypełnij tabelę danymi przykładowymi:
-- \i 'C:/sciezka/do/projektu/sklep_dane.sql'
--
-- Przykładowe sprawdzenie danych:
-- SELECT * FROM sklep.produkty LIMIT 5;
--
-- Po tych krokach baza jest gotowa do pracy.
-- Możesz uruchamiać kwerendy analityczne z pliku sklep_kwerendy.sql
-- ============================================================


-- ------------------------------------------------------------
-- 1. KATEGORIE
--    Kategorie części komputerowych (np. Procesory, Karty graficzne)
-- ------------------------------------------------------------
CREATE TABLE sklep.kategorie
(
    kategoria_id  serial        NOT NULL,
    nazwa         varchar(100)  NOT NULL,
    opis          text          NULL,
    CONSTRAINT pk_kategorie PRIMARY KEY (kategoria_id),
    CONSTRAINT uq_kategorie_nazwa UNIQUE (nazwa)
);


-- ------------------------------------------------------------
-- 2. PRODUCENCI
--    Producenci / marki sprzedawanych podzespołów
-- ------------------------------------------------------------
CREATE TABLE sklep.producenci
(
    producent_id    serial       NOT NULL,
    nazwa           varchar(100) NOT NULL,
    kraj_pochodzenia varchar(60) NULL,
    CONSTRAINT pk_producenci PRIMARY KEY (producent_id),
    CONSTRAINT uq_producenci_nazwa UNIQUE (nazwa)
);


-- ------------------------------------------------------------
-- 3. PRODUKTY
--    Podzespoły komputerowe dostępne w sklepie
-- ------------------------------------------------------------
CREATE TABLE sklep.produkty
(
    produkt_id       serial          NOT NULL,
    nazwa            varchar(255)    NOT NULL,
    kategoria_id     int             NOT NULL,  -- FK → kategorie
    producent_id     int             NOT NULL,  -- FK → producenci
    cena_zakupu      numeric(10, 2)  NOT NULL,  -- cena netto od dostawcy
    cena_sprzedazy   numeric(10, 2)  NOT NULL,  -- cena detaliczna brutto
    ilosc_na_stanie  int             NOT NULL DEFAULT 0,
    opis             text            NULL,
    CONSTRAINT pk_produkty PRIMARY KEY (produkt_id),
    CONSTRAINT fk_produkty_kategoria  FOREIGN KEY (kategoria_id)  REFERENCES sklep.kategorie  (kategoria_id),
    CONSTRAINT fk_produkty_producent  FOREIGN KEY (producent_id)  REFERENCES sklep.producenci (producent_id),
    CONSTRAINT ck_produkty_cena_zakupu    CHECK (cena_zakupu    >= 0),
    CONSTRAINT ck_produkty_cena_sprzedazy CHECK (cena_sprzedazy >= 0),
    CONSTRAINT ck_produkty_ilosc          CHECK (ilosc_na_stanie >= 0)
);


-- ------------------------------------------------------------
-- 4. DOSTAWCY
--    Hurtownie i dystrybutorzy, od których sklep kupuje towar
-- ------------------------------------------------------------
CREATE TABLE sklep.dostawcy
(
    dostawca_id  serial       NOT NULL,
    nazwa        varchar(150) NOT NULL,
    nip          char(10)     NULL,
    miasto       varchar(100) NULL,
    ulica        varchar(150) NULL,
    telefon      varchar(20)  NULL,
    email        varchar(150) NULL,
    CONSTRAINT pk_dostawcy PRIMARY KEY (dostawca_id),
    CONSTRAINT uq_dostawcy_nip UNIQUE (nip)
);


-- ------------------------------------------------------------
-- 5. KLIENCI
--    Klienci odwiedzający sklep stacjonarny
--    Zakup możliwy też anonimowo (klient_id może być NULL w transakcji)
-- ------------------------------------------------------------
CREATE TABLE sklep.klienci
(
    klient_id        serial       NOT NULL,
    imie             varchar(60)  NOT NULL,
    nazwisko         varchar(60)  NOT NULL,
    telefon          varchar(20)  NULL,
    email            varchar(150) NULL,
    data_rejestracji date         NOT NULL DEFAULT CURRENT_DATE,
    CONSTRAINT pk_klienci PRIMARY KEY (klient_id)
);


-- ------------------------------------------------------------
-- 6. PRACOWNICY
--    Pracownicy sklepu – sprzedawcy i magazynierzy
-- ------------------------------------------------------------
CREATE TABLE sklep.pracownicy
(
    pracownik_id      serial          NOT NULL,
    imie              varchar(60)     NOT NULL,
    nazwisko          varchar(60)     NOT NULL,
    stanowisko        varchar(60)     NULL,  -- np. 'sprzedawca', 'magazynier', 'kierownik'
    data_zatrudnienia date            NOT NULL,
    wynagrodzenie     numeric(10, 2)  NULL,
    telefon           varchar(20)     NULL,
    email             varchar(150)    NULL,
    CONSTRAINT pk_pracownicy PRIMARY KEY (pracownik_id),
    CONSTRAINT ck_pracownicy_wynagrodzenie CHECK (wynagrodzenie IS NULL OR wynagrodzenie >= 0)
);


-- ------------------------------------------------------------
-- 7. TRANSAKCJE
--    Paragony / transakcje sprzedaży przy kasie
--    klient_id może być NULL dla sprzedaży anonimowej
-- ------------------------------------------------------------
CREATE TABLE sklep.transakcje
(
    transakcja_id    serial       NOT NULL,
    klient_id        int          NULL,  -- FK → klienci (NULL = klient anonimowy)
    pracownik_id     int          NOT NULL,  -- FK → pracownicy (obsługujący transakcję)
    data_transakcji  timestamp(0) NOT NULL DEFAULT now(),
    metoda_platnosci varchar(30)  NOT NULL,  -- np. 'gotówka', 'karta', 'blik'
    status           varchar(20)  NOT NULL DEFAULT 'zrealizowana',  -- 'zrealizowana', 'zwrot', 'anulowana'
    CONSTRAINT pk_transakcje PRIMARY KEY (transakcja_id),
    CONSTRAINT fk_transakcje_klient    FOREIGN KEY (klient_id)    REFERENCES sklep.klienci    (klient_id),
    CONSTRAINT fk_transakcje_pracownik FOREIGN KEY (pracownik_id) REFERENCES sklep.pracownicy (pracownik_id),
    CONSTRAINT ck_transakcje_metoda CHECK (metoda_platnosci IN ('gotówka', 'karta', 'blik', 'przelew')),
    CONSTRAINT ck_transakcje_status  CHECK (status IN ('zrealizowana', 'zwrot', 'anulowana'))
);


-- ------------------------------------------------------------
-- 8. POZYCJE_TRANSAKCJI
--    Poszczególne linie produktów na paragonie
-- ------------------------------------------------------------
CREATE TABLE sklep.pozycje_transakcji
(
    pozycja_id        serial         NOT NULL,
    transakcja_id     int            NOT NULL,  -- FK → transakcje
    produkt_id        int            NOT NULL,  -- FK → produkty
    ilosc             int            NOT NULL,
    cena_jednostkowa  numeric(10, 2) NOT NULL,  -- cena w momencie sprzedaży (snapshot)
    CONSTRAINT pk_pozycje_transakcji PRIMARY KEY (pozycja_id),
    CONSTRAINT fk_poz_trans_transakcja FOREIGN KEY (transakcja_id) REFERENCES sklep.transakcje (transakcja_id),
    CONSTRAINT fk_poz_trans_produkt    FOREIGN KEY (produkt_id)    REFERENCES sklep.produkty   (produkt_id),
    CONSTRAINT ck_poz_trans_ilosc         CHECK (ilosc            > 0),
    CONSTRAINT ck_poz_trans_cena          CHECK (cena_jednostkowa >= 0)
);


-- ------------------------------------------------------------
-- 9. DOSTAWY
--    Przyjęcia towaru od dostawców (dokumenty PZ)
-- ------------------------------------------------------------
CREATE TABLE sklep.dostawy
(
    dostawa_id    serial       NOT NULL,
    dostawca_id   int          NOT NULL,  -- FK → dostawcy
    pracownik_id  int          NOT NULL,  -- FK → pracownicy (przyjmujący dostawę)
    data_dostawy  date         NOT NULL DEFAULT CURRENT_DATE,
    status        varchar(20)  NOT NULL DEFAULT 'przyjęta',  -- 'oczekiwana', 'przyjęta', 'reklamacja'
    CONSTRAINT pk_dostawy PRIMARY KEY (dostawa_id),
    CONSTRAINT fk_dostawy_dostawca  FOREIGN KEY (dostawca_id)  REFERENCES sklep.dostawcy  (dostawca_id),
    CONSTRAINT fk_dostawy_pracownik FOREIGN KEY (pracownik_id) REFERENCES sklep.pracownicy (pracownik_id),
    CONSTRAINT ck_dostawy_status CHECK (status IN ('oczekiwana', 'przyjęta', 'reklamacja'))
);


-- ------------------------------------------------------------
-- 10. POZYCJE_DOSTAWY
--     Poszczególne pozycje towarowe w dostawie
-- ------------------------------------------------------------
CREATE TABLE sklep.pozycje_dostawy
(
    pozycja_id              serial         NOT NULL,
    dostawa_id              int            NOT NULL,  -- FK → dostawy
    produkt_id              int            NOT NULL,  -- FK → produkty
    ilosc                   int            NOT NULL,
    cena_zakupu_jednostkowa numeric(10, 2) NOT NULL,  -- cena netto zapłacona dostawcy
    CONSTRAINT pk_pozycje_dostawy PRIMARY KEY (pozycja_id),
    CONSTRAINT fk_poz_dost_dostawa FOREIGN KEY (dostawa_id) REFERENCES sklep.dostawy  (dostawa_id),
    CONSTRAINT fk_poz_dost_produkt FOREIGN KEY (produkt_id) REFERENCES sklep.produkty (produkt_id),
    CONSTRAINT ck_poz_dost_ilosc CHECK (ilosc                   > 0),
    CONSTRAINT ck_poz_dost_cena  CHECK (cena_zakupu_jednostkowa >= 0)
);
