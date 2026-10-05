--Consulta 1
WITH
A as (
    select signature from copies
        minus
    select signature from loans),
B as (
    select isbn from copies natural join A),
C as (
    select title, author, count(isbn) as isbn_actuales
    from editions natural join B
    group by title, author
    having count(distinct language)>=3),
D as (
    select e.title, e.author
    from editions e
    join C on e.title = C.title and e.author = C.author
    group by e.title, e.author, C.isbn_actuales
    having count(e.isbn) = C.isbn_actuales)
select * from D;
/



--Consulta 2
WITH
A as (
    select passport, count(passport) as paradas
    from assign_drv natural join stops
    group by passport),  
B as (
    select passport, count(passport) as prestamos
    from services natural join loans
    group by passport),  
C as (
    select passport, count(passport) as no_devueltos
    from services natural join loans
    where return is NULL
    group by passport),   
D as (
    select passport, (no_devueltos/prestamos)*100 as porcentaje
    from B natural join C),
E as (
    select passport, count(passport) as años_activo
    from (select distinct passport, to_char(taskdate, 'YYYY') from assign_drv)
    group by passport),  
F as (
    select fullname, passport, ROUND((sysdate - birthdate)/365.2422, 2) as edad, ROUND((sysdate - cont_start)/365.2422, 2) as antiguedad
    from drivers), 
G as (
    select F.fullname, F.passport, F.edad, F.antiguedad, E.años_activo, (A.paradas/E.años_activo) as media_paradas,
    (B.prestamos/E.años_activo) as media_prestamos, D.porcentaje
    from F
    left join E on F.passport = E.passport
    left join D on F.passport = D.passport
    left join B on F.passport = B.passport
    left join A on F.passport = A.passport)  
select * from G;
/



