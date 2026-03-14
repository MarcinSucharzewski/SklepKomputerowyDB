-- Dane przykładowe dla bazy danych stacjonarnego sklepu komputerowego
-- Schemat: sklep
--
-- Uruchom po wykonaniu sklep_tabele.sql:
-- \i 'C:/sciezka/do/projektu/sklep_dane.sql'
-- ============================================================


-- ============================================================
-- 1. KATEGORIE  (10 rekordów)
-- ============================================================
INSERT INTO sklep.kategorie (nazwa, opis) VALUES
('Procesory',       'Jednostki centralne – Intel Core, AMD Ryzen'),
('Karty graficzne', 'Dedykowane układy GPU – NVIDIA GeForce, AMD Radeon'),
('Pamięci RAM',     'Moduły DDR4 i DDR5 do komputerów stacjonarnych'),
('Dyski SSD',       'Dyski półprzewodnikowe M.2 NVMe oraz SATA'),
('Dyski HDD',       'Mechaniczne dyski twarde 3,5"'),
('Płyty główne',    'Płyty główne ATX i mATX dla platform AMD i Intel'),
('Zasilacze',       'Zasilacze ATX z certyfikatem 80 PLUS'),
('Chłodzenie',      'Coolery powietrzne i zestawy AIO'),
('Obudowy',         'Obudowy komputerowe Midi-Tower i Full-Tower'),
('Karty sieciowe',  'Karty LAN 2.5G/10G oraz karty Wi-Fi 6E');


-- ============================================================
-- 2. PRODUCENCI  (12 rekordów)
-- ============================================================
INSERT INTO sklep.producenci (nazwa, kraj_pochodzenia) VALUES
('Intel',     'USA'),
('AMD',       'USA'),
('Samsung',   'Korea Południowa'),
('Kingston',  'USA'),
('Crucial',   'USA'),
('ASUS',      'Tajwan'),
('MSI',       'Tajwan'),
('Gigabyte',  'Tajwan'),
('Corsair',   'USA'),
('be quiet!', 'Niemcy'),
('Noctua',    'Austria'),
('Seagate',   'USA');


-- ============================================================
-- 3. PRODUKTY  (20 rekordów)
--    kategoria_id: 1=Procesory 2=GPU 3=RAM 4=SSD 5=HDD
--                  6=Płyty 7=Zasilacze 8=Chłodzenie 9=Obudowy
--    producent_id: 1=Intel 2=AMD 3=Samsung 4=Kingston 5=Crucial
--                  6=ASUS 7=MSI 8=Gigabyte 9=Corsair 10=be quiet!
--                  11=Noctua 12=Seagate
-- ============================================================
INSERT INTO sklep.produkty
    (nazwa, kategoria_id, producent_id, cena_zakupu, cena_sprzedazy, ilosc_na_stanie, opis)
VALUES
( 'Intel Core i5-13600K',               1,  1,  900.00, 1199.00,  8, '14 rdzeni (6P+8E), 125 W TDP, socket LGA1700'),
( 'Intel Core i7-13700K',               1,  1, 1400.00, 1799.00,  5, '16 rdzeni (8P+8E), 125 W TDP, socket LGA1700'),
( 'AMD Ryzen 5 7600X',                  1,  2,  850.00, 1099.00, 10, '6 rdzeni / 12 wątków, 105 W TDP, socket AM5'),
( 'AMD Ryzen 7 7700X',                  1,  2, 1100.00, 1449.00,  6, '8 rdzeni / 16 wątków, 105 W TDP, socket AM5'),
( 'ASUS GeForce RTX 4070 DUAL OC',      2,  6, 2200.00, 2799.00,  4, '12 GB GDDR6X, PCIe 4.0, DLSS 3'),
( 'MSI Radeon RX 7800 XT GAMING X',     2,  7, 1700.00, 2199.00,  7, '16 GB GDDR6, PCIe 4.0, FSR 3'),
( 'Kingston FURY Beast 16 GB DDR5',     3,  4,  180.00,  249.00, 25, 'DDR5-5200 CL40, 1×16 GB, XMP 3.0'),
( 'Corsair Vengeance 32 GB DDR5',       3,  9,  320.00,  429.00, 18, 'DDR5-6000 CL30, 2×16 GB, Intel XMP 3.0'),
( 'Samsung 990 Pro 1 TB NVMe',          4,  3,  280.00,  369.00, 20, 'PCIe 4.0 x4, odczyt do 7450 MB/s, M.2 2280'),
( 'Crucial P3 Plus 2 TB NVMe',          4,  5,  320.00,  419.00, 15, 'PCIe 4.0 x4, odczyt do 5000 MB/s, M.2 2280'),
( 'Seagate Barracuda 2 TB HDD',         5, 12,  160.00,  219.00, 12, '256 MB cache, 7200 RPM, SATA III, 3,5"'),
( 'ASUS ROG Strix B650E-F Gaming',      6,  6,  800.00, 1049.00,  6, 'Socket AM5, DDR5, ATX, 4×M.2'),
( 'MSI MAG X670E Tomahawk WiFi',        6,  7,  950.00, 1249.00,  4, 'Socket AM5, DDR5, ATX, PCIe 5.0'),
( 'Corsair RM850x 850 W',               7,  9,  420.00,  549.00, 10, '80 PLUS Gold, modularny, 135 mm wentylator'),
( 'be quiet! Straight Power 11 750 W',  7, 10,  360.00,  469.00,  8, '80 PLUS Platinum, modularny'),
( 'Noctua NH-D15',                      8, 11,  250.00,  369.00,  9, '2×wentylator 140 mm, TDP 250 W, LGA1700/AM5'),
( 'be quiet! Pure Rock 2',              8, 10,   90.00,  129.00, 22, 'Wentylator 120 mm, TDP 150 W, LGA1700/AM5'),
( 'be quiet! Pure Base 500DX',          9, 10,  280.00,  379.00, 11, 'Midi-Tower ATX, 3×wentylator 140 mm, ARGB'),
( 'Gigabyte GeForce RTX 4060 EAGLE',    2,  8, 1350.00, 1749.00,  9, '8 GB GDDR6, PCIe 4.0, DLSS 3, 115 W TDP'),
( 'Kingston A2000 1 TB SSD',            4,  4,  220.00,  299.00, 17, 'PCIe 3.0 x4 NVMe, odczyt do 2200 MB/s, M.2 2280');


-- ============================================================
-- 4. DOSTAWCY  (5 rekordów)
-- ============================================================
INSERT INTO sklep.dostawcy (nazwa, nip, miasto, ulica, telefon, email) VALUES
( 'AB S.A.',                         '5270024931', 'Wrocław',  'ul. Prostej 52',            '713606000', 'handel@ab.pl'),
( 'ALSO Polska Sp. z o.o.',          '5213031215', 'Warszawa', 'ul. Kolejowa 22/26',         '226684588', 'info@also.com'),
( 'Action S.A.',                     '5240306415', 'Warszawa', 'ul. Zamieniecka 62',         '226077800', 'sprzedaz@action.pl'),
( 'Tech Data Polska Sp. z o.o.',     '5260006725', 'Warszawa', 'ul. Postępu 6',              '225723000', 'pl.sales@techdata.com'),
( 'Ingram Micro Poland Sp. z o.o.',  '5262214831', 'Warszawa', 'Al. Jerozolimskie 162',      '222504400', 'info.pl@ingrammicro.com');


-- ============================================================
-- 5. KLIENCI  (12 rekordów)
-- ============================================================
INSERT INTO sklep.klienci (imie, nazwisko, telefon, email, data_rejestracji) VALUES
( 'Marek',      'Kowalczyk',   '501234567', 'mkowalczyk@gmail.com',   '2025-05-12'),
( 'Joanna',     'Pawlak',      '512345678', 'jpawlak@gmail.com',       '2025-08-03'),
( 'Robert',     'Wierzbicki',  '523456789', NULL,                       '2025-09-15'),
( 'Magdalena',  'Dąbrowska',   '534567890', 'mdabrowska@wp.pl',        '2025-10-01'),
( 'Paweł',      'Jankowski',   NULL,        'pjankowski@wp.pl',        '2025-11-20'),
( 'Beata',      'Wysocka',     '545678901', NULL,                       '2025-12-05'),
( 'Łukasz',     'Król',        '556789012', 'lkrol@onet.pl',           '2026-01-14'),
( 'Karolina',   'Nowak',       '567890123', NULL,                       '2026-01-22'),
( 'Damian',     'Szymański',   '578901234', 'dszymanski@gmail.com',    '2026-02-03'),
( 'Monika',     'Lewandowska', NULL,        'mlewandowska@gmail.com',  '2026-02-18'),
( 'Krzysztof',  'Wiśniewski',  '589012345', NULL,                       '2026-03-01'),
( 'Agnieszka',  'Kamińska',    '590123456', 'akaminska@onet.pl',       '2026-03-07');


-- ============================================================
-- 6. PRACOWNICY  (6 rekordów)
-- ============================================================
INSERT INTO sklep.pracownicy (imie, nazwisko, stanowisko, data_zatrudnienia, wynagrodzenie, telefon, email) VALUES
( 'Jan',      'Kowalski',   'kierownik',  '2022-01-15', 6500.00, '601100001', 'jkowalski@sklep.pl'),
( 'Anna',     'Wiśniewska', 'kierownik',  '2021-06-01', 6200.00, '601100002', 'awiszniewska@sklep.pl'),
( 'Piotr',    'Nowak',      'sprzedawca', '2023-03-10', 4200.00, '601100003', 'pnowak@sklep.pl'),
( 'Karolina', 'Zając',      'sprzedawca', '2023-07-22', 4200.00, '601100004', 'kzajac@sklep.pl'),
( 'Michał',   'Wróbel',     'sprzedawca', '2024-01-08', 4000.00, '601100005', 'mwrobel@sklep.pl'),
( 'Tomasz',   'Dąbrowski',  'magazynier', '2022-11-01', 4500.00, '601100006', 'tdabrowski@sklep.pl');


-- ============================================================
-- 7. TRANSAKCJE  (15 rekordów)
--    pracownicy 3,4,5 = Piotr Nowak, Karolina Zając, Michał Wróbel
-- ============================================================
INSERT INTO sklep.transakcje (klient_id, pracownik_id, data_transakcji, metoda_platnosci, status) VALUES
( 1,    3, '2026-01-05 10:30:00', 'gotówka', 'zrealizowana'),  --  1
( NULL, 4, '2026-01-08 14:15:00', 'karta',   'zrealizowana'),  --  2
( 2,    3, '2026-01-12 11:00:00', 'blik',    'zrealizowana'),  --  3
( 3,    5, '2026-01-20 16:45:00', 'karta',   'zrealizowana'),  --  4
( NULL, 4, '2026-01-25 13:20:00', 'gotówka', 'zrealizowana'),  --  5
( 4,    3, '2026-02-02 09:00:00', 'karta',   'zrealizowana'),  --  6
( 5,    5, '2026-02-07 15:30:00', 'blik',    'zrealizowana'),  --  7
( NULL, 3, '2026-02-10 11:45:00', 'gotówka', 'zrealizowana'),  --  8
( 6,    4, '2026-02-14 14:00:00', 'karta',   'zrealizowana'),  --  9
( 7,    5, '2026-02-20 10:15:00', 'blik',    'zrealizowana'),  -- 10
( 8,    3, '2026-02-25 16:00:00', 'karta',   'zrealizowana'),  -- 11
( NULL, 4, '2026-03-01 12:30:00', 'gotówka', 'zrealizowana'),  -- 12
( 9,    5, '2026-03-05 09:45:00', 'karta',   'zrealizowana'),  -- 13
( 10,   3, '2026-03-10 14:20:00', 'blik',    'zrealizowana'),  -- 14
( NULL, 4, '2026-03-12 11:00:00', 'gotówka', 'zwrot');         -- 15


-- ============================================================
-- 8. POZYCJE TRANSAKCJI  (27 rekordów)
-- ============================================================

-- t1 – Marek: procesor i5 + SSD + chłodzenie Noctua
INSERT INTO sklep.pozycje_transakcji (transakcja_id, produkt_id, ilosc, cena_jednostkowa) VALUES
( 1,  1, 1, 1199.00),
( 1,  9, 1,  369.00),
( 1, 16, 1,  369.00);

-- t2 – anonim: karta graficzna RX 7800 XT
INSERT INTO sklep.pozycje_transakcji (transakcja_id, produkt_id, ilosc, cena_jednostkowa) VALUES
( 2,  6, 1, 2199.00);

-- t3 – Joanna: pamięci ×2 + SSD Crucial
INSERT INTO sklep.pozycje_transakcji (transakcja_id, produkt_id, ilosc, cena_jednostkowa) VALUES
( 3,  7, 2,  249.00),
( 3, 10, 1,  419.00);

-- t4 – Robert: kompletny zestaw AMD (procesor + płyta + zasilacz)
INSERT INTO sklep.pozycje_transakcji (transakcja_id, produkt_id, ilosc, cena_jednostkowa) VALUES
( 4,  3, 1, 1099.00),
( 4, 12, 1, 1049.00),
( 4, 14, 1,  549.00);

-- t5 – anonim: dyski HDD ×2
INSERT INTO sklep.pozycje_transakcji (transakcja_id, produkt_id, ilosc, cena_jednostkowa) VALUES
( 5, 11, 2,  219.00);

-- t6 – Magdalena: pamięci DDR5 Corsair
INSERT INTO sklep.pozycje_transakcji (transakcja_id, produkt_id, ilosc, cena_jednostkowa) VALUES
( 6,  8, 1,  429.00);

-- t7 – Paweł: karta RTX 4060 + obudowa
INSERT INTO sklep.pozycje_transakcji (transakcja_id, produkt_id, ilosc, cena_jednostkowa) VALUES
( 7, 19, 1, 1749.00),
( 7, 18, 1,  379.00);

-- t8 – anonim: dwa coolery (budżetowy + premium)
INSERT INTO sklep.pozycje_transakcji (transakcja_id, produkt_id, ilosc, cena_jednostkowa) VALUES
( 8, 17, 1,  129.00),
( 8, 16, 1,  369.00);

-- t9 – Beata: procesor AMD Ryzen 7
INSERT INTO sklep.pozycje_transakcji (transakcja_id, produkt_id, ilosc, cena_jednostkowa) VALUES
( 9,  4, 1, 1449.00);

-- t10 – Łukasz: kompletny zestaw Intel (procesor + płyta + zasilacz)
INSERT INTO sklep.pozycje_transakcji (transakcja_id, produkt_id, ilosc, cena_jednostkowa) VALUES
(10,  2, 1, 1799.00),
(10, 13, 1, 1249.00),
(10, 15, 1,  469.00);

-- t11 – Karolina: dyski SSD ×2 różne modele
INSERT INTO sklep.pozycje_transakcji (transakcja_id, produkt_id, ilosc, cena_jednostkowa) VALUES
(11,  9, 2,  369.00),
(11, 20, 1,  299.00);

-- t12 – anonim: karta graficzna RTX 4070
INSERT INTO sklep.pozycje_transakcji (transakcja_id, produkt_id, ilosc, cena_jednostkowa) VALUES
(12,  5, 1, 2799.00);

-- t13 – Damian: pamięci ×4 + zasilacz
INSERT INTO sklep.pozycje_transakcji (transakcja_id, produkt_id, ilosc, cena_jednostkowa) VALUES
(13,  7, 4,  249.00),
(13, 14, 1,  549.00);

-- t14 – Monika: procesor AMD + chłodzenie budżetowe
INSERT INTO sklep.pozycje_transakcji (transakcja_id, produkt_id, ilosc, cena_jednostkowa) VALUES
(14,  3, 1, 1099.00),
(14, 17, 1,  129.00);

-- t15 – anonim: zwrot karty graficznej RX 7800 XT
INSERT INTO sklep.pozycje_transakcji (transakcja_id, produkt_id, ilosc, cena_jednostkowa) VALUES
(15,  6, 1, 2199.00);


-- ============================================================
-- 9. DOSTAWY  (6 rekordów)
--    pracownik_id=6 = Tomasz Dąbrowski (magazynier)
-- ============================================================
INSERT INTO sklep.dostawy (dostawca_id, pracownik_id, data_dostawy, status) VALUES
( 1, 6, '2025-12-05', 'przyjęta'),   -- AB – procesory Intel + SSD Samsung
( 2, 6, '2025-12-20', 'przyjęta'),   -- ALSO – karty graficzne
( 1, 6, '2026-01-10', 'przyjęta'),   -- AB – procesory AMD + pamięci
( 3, 6, '2026-01-28', 'przyjęta'),   -- Action – dyski SSD + HDD
( 2, 6, '2026-02-15', 'przyjęta'),   -- ALSO – płyty główne + zasilacze
( 4, 6, '2026-03-08', 'oczekiwana'); -- Tech Data – chłodzenie + obudowy


-- ============================================================
-- 10. POZYCJE DOSTAWY  (20 rekordów)
-- ============================================================

-- Dostawa 1 – procesory Intel + SSD (AB, grudzień 2025)
INSERT INTO sklep.pozycje_dostawy (dostawa_id, produkt_id, ilosc, cena_zakupu_jednostkowa) VALUES
( 1,  1,  5,  900.00),   -- Intel Core i5-13600K ×5
( 1,  2,  3, 1400.00),   -- Intel Core i7-13700K ×3
( 1,  9, 10,  280.00);   -- Samsung 990 Pro 1 TB ×10

-- Dostawa 2 – karty graficzne (ALSO, grudzień 2025)
INSERT INTO sklep.pozycje_dostawy (dostawa_id, produkt_id, ilosc, cena_zakupu_jednostkowa) VALUES
( 2,  5,  3, 2200.00),   -- ASUS RTX 4070 ×3
( 2,  6,  5, 1700.00),   -- MSI RX 7800 XT ×5
( 2, 19,  5, 1350.00);   -- Gigabyte RTX 4060 ×5

-- Dostawa 3 – procesory AMD + pamięci (AB, styczeń 2026)
INSERT INTO sklep.pozycje_dostawy (dostawa_id, produkt_id, ilosc, cena_zakupu_jednostkowa) VALUES
( 3,  3,  7,  850.00),   -- AMD Ryzen 5 7600X ×7
( 3,  4,  4, 1100.00),   -- AMD Ryzen 7 7700X ×4
( 3,  7, 20,  180.00),   -- Kingston FURY Beast 16 GB ×20
( 3,  8, 15,  320.00);   -- Corsair Vengeance 32 GB ×15

-- Dostawa 4 – dyski SSD + HDD (Action, styczeń 2026)
INSERT INTO sklep.pozycje_dostawy (dostawa_id, produkt_id, ilosc, cena_zakupu_jednostkowa) VALUES
( 4, 11, 10,  160.00),   -- Seagate Barracuda 2 TB ×10
( 4, 10, 10,  320.00),   -- Crucial P3 Plus 2 TB ×10
( 4, 20, 12,  220.00);   -- Kingston A2000 1 TB ×12

-- Dostawa 5 – płyty główne + zasilacze (ALSO, luty 2026)
INSERT INTO sklep.pozycje_dostawy (dostawa_id, produkt_id, ilosc, cena_zakupu_jednostkowa) VALUES
( 5, 12,  4,  800.00),   -- ASUS ROG Strix B650E-F ×4
( 5, 13,  3,  950.00),   -- MSI MAG X670E Tomahawk ×3
( 5, 14,  6,  420.00),   -- Corsair RM850x 850 W ×6
( 5, 15,  5,  360.00);   -- be quiet! Straight Power 11 750 W ×5

-- Dostawa 6 – chłodzenie + obudowy (Tech Data, marzec 2026 – oczekiwana)
INSERT INTO sklep.pozycje_dostawy (dostawa_id, produkt_id, ilosc, cena_zakupu_jednostkowa) VALUES
( 6, 16,  5,  250.00),   -- Noctua NH-D15 ×5
( 6, 17, 10,   90.00),   -- be quiet! Pure Rock 2 ×10
( 6, 18,  6,  280.00);   -- be quiet! Pure Base 500DX ×6
