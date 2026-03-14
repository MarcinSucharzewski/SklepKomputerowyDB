-- Scenariusz administracyjny – stacjonarny sklep z częściami komputerowymi
-- Schemat: sklep
--
-- Uruchom po załadowaniu danych:
-- \i 'C:/sciezka/do/projektu/sklep_admin.sql'
-- ============================================================


-- ============================================================
-- A1 – NOWA TABELA: promocje
--      Sklep może przypisywać czasowe obniżki do produktów.
-- ============================================================
CREATE TABLE sklep.promocje
(
    promocja_id    serial         NOT NULL,
    produkt_id     int            NOT NULL,  -- FK → produkty
    nazwa          varchar(150)   NOT NULL,  -- np. "Wyprzedaż wiosenna"
    rabat_proc     numeric(5, 2)  NOT NULL,  -- np. 10.00 = 10%
    data_od        date           NOT NULL,
    data_do        date           NOT NULL,
    aktywna        boolean        NOT NULL DEFAULT true,
    CONSTRAINT pk_promocje PRIMARY KEY (promocja_id),
    CONSTRAINT fk_promocje_produkt FOREIGN KEY (produkt_id) REFERENCES sklep.produkty (produkt_id),
    CONSTRAINT ck_promocje_rabat   CHECK (rabat_proc  BETWEEN 0 AND 100),
    CONSTRAINT ck_promocje_daty    CHECK (data_do >= data_od)
);

-- Przykładowe promocje
INSERT INTO sklep.promocje (produkt_id, nazwa, rabat_proc, data_od, data_do, aktywna) VALUES
( 3, 'Wyprzedaż wiosenna – AMD Ryzen 5',        5.00, '2026-03-15', '2026-03-31', true),
( 4, 'Wyprzedaż wiosenna – AMD Ryzen 7',        5.00, '2026-03-15', '2026-03-31', true),
(17, 'Promocja starter – chłodzenie budżetowe', 15.00, '2026-03-10', '2026-03-20', true),
(11, 'Clearance – dyski HDD',                  10.00, '2026-02-01', '2026-02-28', false);


-- ============================================================
-- A2 – NOWY UŻYTKOWNIK PostgreSQL z ograniczonymi uprawnieniami
--
--      Rola "sprzedawca_ro" – tylko odczyt (raportowanie).
--      Uruchom poniższe polecenia jako superuser (np. postgres):
-- ============================================================

-- Utwórz rolę tylko do odczytu
CREATE ROLE sprzedawca_ro
    NOSUPERUSER
    NOCREATEDB
    NOCREATEROLE
    LOGIN
    PASSWORD 'ZmienMnie123!';   -- zmień hasło przed wdrożeniem!

-- Nadaj uprawnienia do połączenia z bazą
GRANT CONNECT ON DATABASE sklep_komputerowy TO sprzedawca_ro;

-- Nadaj uprawnienia do schematu
GRANT USAGE ON SCHEMA sklep TO sprzedawca_ro;

-- Nadaj dostęp tylko do odczytu do wszystkich tabel schematu
GRANT SELECT ON ALL TABLES IN SCHEMA sklep TO sprzedawca_ro;

-- Upewnij się, że przyszłe tabele w schemacie także będą widoczne
ALTER DEFAULT PRIVILEGES IN SCHEMA sklep
    GRANT SELECT ON TABLES TO sprzedawca_ro;

-- Weryfikacja uprawnień (uruchom jako sprzedawca_ro lub superuser):
-- \du sprzedawca_ro
-- SELECT table_name FROM information_schema.role_table_grants
-- WHERE grantee = 'sprzedawca_ro';


-- ============================================================
-- A3 – OPERACJE DML: CREATE / UPDATE / DELETE
-- ============================================================

-- --- A3a: INSERT – nowy pracownik ---
INSERT INTO sklep.pracownicy (imie, nazwisko, stanowisko, data_zatrudnienia, wynagrodzenie, telefon, email)
VALUES ('Natalia', 'Kowalczyk', 'sprzedawca', '2026-03-14', 4000.00, '601100007', 'nkowalczyk@sklep.pl');

-- --- A3b: INSERT – nowy klient zarejestrowany przy kasie ---
INSERT INTO sklep.klienci (imie, nazwisko, telefon, email, data_rejestracji)
VALUES ('Bartosz', 'Ostrowski', '598765432', NULL, CURRENT_DATE);

-- --- A3c: UPDATE – korekta ceny sprzedaży produktu po zmianie cen rynkowych ---
UPDATE sklep.produkty
SET cena_sprzedazy = 1149.00
WHERE produkt_id = 1;  -- Intel Core i5-13600K

-- --- A3d: UPDATE – przyjęcie zwróconego towaru do magazynu ---
--     Transakcja nr 15 to zwrot karty MSI RX 7800 XT (produkt_id = 6)
UPDATE sklep.produkty
SET ilosc_na_stanie = ilosc_na_stanie + 1
WHERE produkt_id = 6;  -- MSI Radeon RX 7800 XT

-- --- A3e: UPDATE – dezaktywacja wygasłej promocji ---
UPDATE sklep.promocje
SET aktywna = false
WHERE data_do < CURRENT_DATE AND aktywna = true;

-- --- A3f: DELETE – usunięcie testowej promocji (tylko jeśli nie była użyta) ---
--     Bezpieczne usunięcie: tylko rekordy bez powiązań
DELETE FROM sklep.promocje
WHERE nazwa = 'Clearance – dyski HDD'
  AND aktywna = false;

-- --- A3g: DELETE – usunięcie klienta bez żadnych transakcji ---
--     (np. wpis testowy – klient_id sprawdź przed usunięciem!)
DELETE FROM sklep.klienci
WHERE klient_id NOT IN (SELECT DISTINCT klient_id FROM sklep.transakcje WHERE klient_id IS NOT NULL)
  AND data_rejestracji = CURRENT_DATE;  -- tylko dzisiejsze rejestracje (bezpiecznik)


-- ============================================================
-- A4 – WERYFIKACJA po operacjach
-- ============================================================

-- Nowi pracownicy zatrudnieni w 2026 r.
SELECT pracownik_id, imie, nazwisko, stanowisko, data_zatrudnienia
FROM sklep.pracownicy
WHERE EXTRACT(YEAR FROM data_zatrudnienia) = 2026;

-- Aktualne promocje
SELECT pr.nazwa AS produkt, p.nazwa, p.rabat_proc, p.data_od, p.data_do
FROM sklep.promocje p
JOIN sklep.produkty pr ON pr.produkt_id = p.produkt_id
WHERE p.aktywna = true
ORDER BY p.data_do;

-- Stan magazynowy karty MSI po zwrocie
SELECT nazwa, ilosc_na_stanie FROM sklep.produkty WHERE produkt_id = 6;
