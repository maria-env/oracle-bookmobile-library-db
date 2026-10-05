# Library & Bookmobile Database in Oracle PL/SQL

Second lab assignment for *Ficheros y Bases de Datos* (Files and Databases) at Universidad Carlos III de Madrid. It works on a database that manages libraries, bibuses (bookmobiles), books, loans and reservations, with different types of users. It includes complex queries, a package of stored procedures, updatable views and triggers, together with the scripts used to test them.

## What's included

| File | Content |
|---|---|
| `src/01_consultas.sql` | **Query 1:** works with editions in 3 or more languages and copies that have not been lent. **Query 2:** per-driver statistics for the bibuses (age, seniority, active years, average stops and loans per year, percentage of loans not returned), built with chained CTEs |
| `src/02_paquete_foundicu.sql` | PL/SQL package `foundicu` with the procedures `insertar_prestamo`, `insertar_reserva` and `registrar_devolucion`, which validate the user type, the loan limit, bans and copy availability |
| `src/03_vistas.sql` | Views `my_data` (read-only), `my_loans` (loans with their posts) and `my_reservations`, with `INSTEAD OF` triggers that make them updatable |
| `src/04_disparadores.sql` | Triggers: block posts from institutional users, record the withdrawal date of damaged books, and count the reads of each book |
| `tests/` | One test script per block: they insert valid and invalid cases, check the results and delete the test data afterwards |

## Technologies

Oracle Database · SQL · PL/SQL (packages, procedures, views, triggers, CTEs)

## How to run it

This repository **does not include the course's base schema or data** (tables `books`, `editions`, `copies`, `loans`, `users`, `drivers`, etc.), so that schema must be loaded into Oracle first.

With the schema loaded, from SQL*Plus or SQL Developer:

```sql
SET SERVEROUTPUT ON
@src/01_consultas.sql
@src/02_paquete_foundicu.sql
@src/03_vistas.sql
@src/04_disparadores.sql
```

Notes:

- `04_disparadores.sql` runs an `ALTER TABLE books ADD num_lecturas ...`, so it must be executed only once.
- The procedures report their results with `DBMS_OUTPUT`, which is why `SET SERVEROUTPUT ON` is needed.
- The scripts in `tests/` are designed for the original dataset (for example, query 1 returned 60 rows before the test cases were inserted). Each one removes the data it inserts at the end.
- Identifiers, comments and messages in the code are in Spanish, as in the original assignment.

## Authors

Team project (3 people): María Arias Rodríguez, Jorge Ignacio Castañeda Vallenilla and Marta Veber.
