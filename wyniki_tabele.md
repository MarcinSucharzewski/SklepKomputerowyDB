# Podgląd tabel – sklep komputerowy

Każda tabela pokazana z limitem **5 rekordów**.

## `sklep.kategorie`

```sql
SELECT * FROM sklep.kategorie LIMIT 5;
```

| kategoria_id | nazwa           | opis                                               |
| ------------ | --------------- | -------------------------------------------------- |
| 1            | Procesory       | Jednostki centralne – Intel Core, AMD Ryzen        |
| 2            | Karty graficzne | Dedykowane układy GPU – NVIDIA GeForce, AMD Radeon |
| 3            | Pamięci RAM     | Moduły DDR4 i DDR5 do komputerów stacjonarnych     |
| 4            | Dyski SSD       | Dyski półprzewodnikowe M.2 NVMe oraz SATA          |
| 5            | Dyski HDD       | Mechaniczne dyski twarde 3,5"                      |

## `sklep.producenci`

```sql
SELECT * FROM sklep.producenci LIMIT 5;
```

| producent_id | nazwa    | kraj_pochodzenia |
| ------------ | -------- | ---------------- |
| 1            | Intel    | USA              |
| 2            | AMD      | USA              |
| 3            | Samsung  | Korea Południowa |
| 4            | Kingston | USA              |
| 5            | Crucial  | USA              |

## `sklep.produkty`

```sql
SELECT * FROM sklep.produkty LIMIT 5;
```

| produkt_id | nazwa                         | kategoria_id | producent_id | cena_zakupu | cena_sprzedazy | ilosc_na_stanie | opis                                         |
| ---------- | ----------------------------- | ------------ | ------------ | ----------- | -------------- | --------------- | -------------------------------------------- |
| 1          | Intel Core i5-13600K          | 1            | 1            | 900         | 1199           | 8               | 14 rdzeni (6P+8E), 125 W TDP, socket LGA1700 |
| 2          | Intel Core i7-13700K          | 1            | 1            | 1400        | 1799           | 5               | 16 rdzeni (8P+8E), 125 W TDP, socket LGA1700 |
| 3          | AMD Ryzen 5 7600X             | 1            | 2            | 850         | 1099           | 10              | 6 rdzeni / 12 wątków, 105 W TDP, socket AM5  |
| 4          | AMD Ryzen 7 7700X             | 1            | 2            | 1100        | 1449           | 6               | 8 rdzeni / 16 wątków, 105 W TDP, socket AM5  |
| 5          | ASUS GeForce RTX 4070 DUAL OC | 2            | 6            | 2200        | 2799           | 4               | 12 GB GDDR6X, PCIe 4.0, DLSS 3               |

## `sklep.dostawcy`

```sql
SELECT * FROM sklep.dostawcy LIMIT 5;
```

| dostawca_id | nazwa                          | nip        | miasto   | ulica                 | telefon   | email                   |
| ----------- | ------------------------------ | ---------- | -------- | --------------------- | --------- | ----------------------- |
| 1           | AB S.A.                        | 5270024931 | Wrocław  | ul. Prostej 52        | 713606000 | handel@ab.pl            |
| 2           | ALSO Polska Sp. z o.o.         | 5213031215 | Warszawa | ul. Kolejowa 22/26    | 226684588 | info@also.com           |
| 3           | Action S.A.                    | 5240306415 | Warszawa | ul. Zamieniecka 62    | 226077800 | sprzedaz@action.pl      |
| 4           | Tech Data Polska Sp. z o.o.    | 5260006725 | Warszawa | ul. Postępu 6         | 225723000 | pl.sales@techdata.com   |
| 5           | Ingram Micro Poland Sp. z o.o. | 5262214831 | Warszawa | Al. Jerozolimskie 162 | 222504400 | info.pl@ingrammicro.com |

## `sklep.klienci`

```sql
SELECT * FROM sklep.klienci LIMIT 5;
```

| klient_id | imie      | nazwisko   | telefon   | email                | data_rejestracji |
| --------- | --------- | ---------- | --------- | -------------------- | ---------------- |
| 1         | Marek     | Kowalczyk  | 501234567 | mkowalczyk@gmail.com | 2025-05-12       |
| 2         | Joanna    | Pawlak     | 512345678 | jpawlak@gmail.com    | 2025-08-03       |
| 3         | Robert    | Wierzbicki | 523456789 | NULL                 | 2025-09-15       |
| 4         | Magdalena | Dąbrowska  | 534567890 | mdabrowska@wp.pl     | 2025-10-01       |
| 5         | Paweł     | Jankowski  | NULL      | pjankowski@wp.pl     | 2025-11-20       |

## `sklep.pracownicy`

```sql
SELECT * FROM sklep.pracownicy LIMIT 5;
```

| pracownik_id | imie     | nazwisko   | stanowisko | data_zatrudnienia | wynagrodzenie | telefon   | email                 |
| ------------ | -------- | ---------- | ---------- | ----------------- | ------------- | --------- | --------------------- |
| 1            | Jan      | Kowalski   | kierownik  | 2022-01-15        | 6500          | 601100001 | jkowalski@sklep.pl    |
| 2            | Anna     | Wiśniewska | kierownik  | 2021-06-01        | 6200          | 601100002 | awiszniewska@sklep.pl |
| 3            | Piotr    | Nowak      | sprzedawca | 2023-03-10        | 4200          | 601100003 | pnowak@sklep.pl       |
| 4            | Karolina | Zając      | sprzedawca | 2023-07-22        | 4200          | 601100004 | kzajac@sklep.pl       |
| 5            | Michał   | Wróbel     | sprzedawca | 2024-01-08        | 4000          | 601100005 | mwrobel@sklep.pl      |

## `sklep.transakcje`

```sql
SELECT * FROM sklep.transakcje LIMIT 5;
```

| transakcja_id | klient_id | pracownik_id | data_transakcji     | metoda_platnosci | status       |
| ------------- | --------- | ------------ | ------------------- | ---------------- | ------------ |
| 1             | 1         | 3            | 2026-01-05 10:30:00 | gotówka          | zrealizowana |
| 2             | NULL      | 4            | 2026-01-08 14:15:00 | karta            | zrealizowana |
| 3             | 2         | 3            | 2026-01-12 11:00:00 | blik             | zrealizowana |
| 4             | 3         | 5            | 2026-01-20 16:45:00 | karta            | zrealizowana |
| 5             | NULL      | 4            | 2026-01-25 13:20:00 | gotówka          | zrealizowana |

## `sklep.pozycje_transakcji`

```sql
SELECT * FROM sklep.pozycje_transakcji LIMIT 5;
```

| pozycja_id | transakcja_id | produkt_id | ilosc | cena_jednostkowa |
| ---------- | ------------- | ---------- | ----- | ---------------- |
| 1          | 1             | 1          | 1     | 1199             |
| 2          | 1             | 9          | 1     | 369              |
| 3          | 1             | 16         | 1     | 369              |
| 4          | 2             | 6          | 1     | 2199             |
| 5          | 3             | 7          | 2     | 249              |

## `sklep.dostawy`

```sql
SELECT * FROM sklep.dostawy LIMIT 5;
```

| dostawa_id | dostawca_id | pracownik_id | data_dostawy | status   |
| ---------- | ----------- | ------------ | ------------ | -------- |
| 1          | 1           | 6            | 2025-12-05   | przyjęta |
| 2          | 2           | 6            | 2025-12-20   | przyjęta |
| 3          | 1           | 6            | 2026-01-10   | przyjęta |
| 4          | 3           | 6            | 2026-01-28   | przyjęta |
| 5          | 2           | 6            | 2026-02-15   | przyjęta |

## `sklep.pozycje_dostawy`

```sql
SELECT * FROM sklep.pozycje_dostawy LIMIT 5;
```

| pozycja_id | dostawa_id | produkt_id | ilosc | cena_zakupu_jednostkowa |
| ---------- | ---------- | ---------- | ----- | ----------------------- |
| 1          | 1          | 1          | 5     | 900                     |
| 2          | 1          | 2          | 3     | 1400                    |
| 3          | 1          | 9          | 10    | 280                     |
| 4          | 2          | 5          | 3     | 2200                    |
| 5          | 2          | 6          | 5     | 1700                    |
