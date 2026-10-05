--CONSULTA 1
--Insertamos 4 libros, 2 de ellos que cumplen con todas las características de la consulta, otro que no cumple los idiomas y el último que no cumple los préstamos.
--Si al volver a comprobar la consulta aparecen 62 filas, podríamos decir que la consulta ha sido exitosa ya que ha filtrado los libros que cumplen las características que pide el enunciado. Por otro lado, también podríamos hacer una consulta mostrando la cantidad de idiomas que tiene cada libro para asegurarnos que todos los libros que aparecen tienen 3 o más.
--Libro 1
INSERT INTO books(TITLE, AUTHOR) VALUES('Prueba 1', 'Autor 1');

INSERT INTO editions(ISBN, TITLE, AUTHOR, LANGUAGE, NATIONAL_LIB_ID) VALUES('0-00-123456-1', 'Prueba 1', 'Autor 1', 'Español', 'BNE12345678910');
INSERT INTO editions(ISBN, TITLE, AUTHOR, LANGUAGE, NATIONAL_LIB_ID) VALUES('0-00-123456-2', 'Prueba 1', 'Autor 1', 'Inglés', 'BNE12345678911');
INSERT INTO editions(ISBN, TITLE, AUTHOR, LANGUAGE, NATIONAL_LIB_ID) VALUES('0-00-123456-3', 'Prueba 1', 'Autor 1', 'Italiano', 'BNE12345678912');

INSERT INTO copies(SIGNATURE, ISBN, CONDITION) VALUES('AA123', '0-00-123456-1', 'G');
INSERT INTO copies(SIGNATURE, ISBN, CONDITION) VALUES('AA456', '0-00-123456-2', 'G');
INSERT INTO copies(SIGNATURE, ISBN, CONDITION) VALUES('AA789', '0-00-123456-3', 'G');

--Libro 2
INSERT INTO books(TITLE, AUTHOR) VALUES('Prueba 2', 'Autor 2');

INSERT INTO editions(ISBN, TITLE, AUTHOR, LANGUAGE, NATIONAL_LIB_ID) VALUES('0-00-123456-4', 'Prueba 2', 'Autor 2', 'Español', 'BNE12345678913');
INSERT INTO editions(ISBN, TITLE, AUTHOR, LANGUAGE, NATIONAL_LIB_ID) VALUES('0-00-123456-5', 'Prueba 2', 'Autor 2', 'Inglés', 'BNE12345678914');
INSERT INTO editions(ISBN, TITLE, AUTHOR, LANGUAGE, NATIONAL_LIB_ID) VALUES('0-00-123456-6', 'Prueba 2', 'Autor 2', 'Italiano', 'BNE12345678915');

INSERT INTO copies(SIGNATURE, ISBN, CONDITION) VALUES('BB123', '0-00-123456-4', 'G');
INSERT INTO copies(SIGNATURE, ISBN, CONDITION) VALUES('BB456', '0-00-123456-5', 'G');
INSERT INTO copies(SIGNATURE, ISBN, CONDITION) VALUES('BB789', '0-00-123456-6', 'G');

--Libro 3
INSERT INTO books(TITLE, AUTHOR) VALUES('Prueba 3', 'Autor 3');

INSERT INTO editions(ISBN, TITLE, AUTHOR, LANGUAGE, NATIONAL_LIB_ID) VALUES('0-00-123456-7', 'Prueba 3', 'Autor 3', 'Español', 'BNE12345678916');

INSERT INTO copies(SIGNATURE, ISBN, CONDITION) VALUES('CC123', '0-00-123456-7', 'G');

--Libro 4 (Hacemos inserciones con 4 idiomas para comprobar que aunque 3 de ellos no sean prestados (3 idiomas distintos) no se añade este libro a la consulta)
INSERT INTO books(TITLE, AUTHOR) VALUES('Prueba 4', 'Autor 4');

INSERT INTO editions(ISBN, TITLE, AUTHOR, LANGUAGE, NATIONAL_LIB_ID) VALUES('0-00-123456-8', 'Prueba 4', 'Autor 4', 'Español', 'BNE12345678917');
INSERT INTO editions(ISBN, TITLE, AUTHOR, LANGUAGE, NATIONAL_LIB_ID) VALUES('0-00-123456-9', 'Prueba 4', 'Autor 4', 'Inglés', 'BNE12345678918');
INSERT INTO editions(ISBN, TITLE, AUTHOR, LANGUAGE, NATIONAL_LIB_ID) VALUES('0-00-123456-0', 'Prueba 4', 'Autor 4', 'Italiano', 'BNE12345678919');
INSERT INTO editions(ISBN, TITLE, AUTHOR, LANGUAGE, NATIONAL_LIB_ID) VALUES('0-00-123457-1', 'Prueba 4', 'Autor 4', 'Francés', 'BNE12345678920');

INSERT INTO copies(SIGNATURE, ISBN, CONDITION) VALUES('DD123', '0-00-123456-8', 'G');
INSERT INTO copies(SIGNATURE, ISBN, CONDITION) VALUES('DD456', '0-00-123456-9', 'G');
INSERT INTO copies(SIGNATURE, ISBN, CONDITION) VALUES('DD789', '0-00-123456-0', 'G');
INSERT INTO copies(SIGNATURE, ISBN, CONDITION) VALUES('CC456', '0-00-123457-1', 'G');

INSERT INTO loans(SIGNATURE, USER_ID, STOPDATE, TOWN, PROVINCE, TYPE, TIME) VALUES('CC456', '0488743850', to_date('14/11/24', 'DD/MM/YY'), 'Villanieves', 'León', 'L', 0);

--Volvemos a hacer la consulta y comprobamos que el número de filas ha aumentado en 2 únicamente.
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
    select e.title, e.author, count(e.language) as num_idiomas
    from editions e
    join C on e.title = C.title and e.author = C.author
    group by e.title, e.author, C.isbn_actuales
    having count(e.isbn) = C.isbn_actuales)
select * from D;

--Borramos los datos insertados ya que hemos terminado con las comprobaciones y nos quedamos con la base original
DELETE FROM loans WHERE signature = 'CC456';
DELETE FROM copies WHERE signature IN ('AA123', 'AA456', 'AA789', 'BB123', 'BB456', 'BB789', 'CC123' , 'CC456', 'DD123', 'DD456', 'DD789');
DELETE FROM editions WHERE title = 'Prueba 1' and author = 'Autor 1';
DELETE FROM editions WHERE title = 'Prueba 2' and author = 'Autor 2';
DELETE FROM editions WHERE title = 'Prueba 3' and author = 'Autor 3';
DELETE FROM editions WHERE title = 'Prueba 4' and author = 'Autor 4';
DELETE FROM books WHERE title = 'Prueba 1' and author = 'Autor 1';
DELETE FROM books WHERE title = 'Prueba 2' and author = 'Autor 2';
DELETE FROM books WHERE title = 'Prueba 3' and author = 'Autor 3';
DELETE FROM books WHERE title = 'Prueba 4' and author = 'Autor 4';



--CONSULTA 2
--Los datos de fullname y passport son datos que vienen directamente de la tabla, por lo que podemos asegurarnos de que son correctos.
--Por otro lado, vamos a ir comprobando uno por uno que los datos de cada conductor son correctos:
--EDAD. Se comprueba mostrando la fecha de cumpleaños del usuario y viendo cuánto nos da la resta con sysdate.

select fullname, passport, birthdate, ROUND((sysdate - birthdate)/365.2422, 2) as edad from drivers;

--Si comparamos los resultados con los de la consulta completa podemos ver que son iguales, por lo tanto este atributo está bien.
--ANTIGÜEDAD. Se comprueba mostrando la fecha de inicio del contrato del conductor y viendo cuánto nos da la resta con sysdate.

select fullname, passport, cont_start, ROUND((sysdate - cont_start)/365.2422, 2) as años_antiguedad from drivers;

--Si comparamos los resultados con los de la consulta completa podemos ver que son iguales, por lo tanto este atributo está bien.
--AÑOS ACTIVO. Estos años son los que ha estado trabajando, al menos, un día durante ese año, es decir, que al menos haya realizado una ruta ese año. Para ello comprobamos en qué años (distintos) se le asignó rutas al conductor en cuestión y comparamos si coincide con el resultado de la consulta.

select distinct fullname, passport, to_char(taskdate, 'YYYY') as año from assign_drv natural join drivers;

--Si vemos los resultados que genera esta consulta, podemos ver que para cada trabajador únicamente ha tenido rutas durante 2024, lo que coincide con nuestra consulta principal que indica que cada conductor lleva únicamente un año activo.
--MEDIA PARADAS SEGÚN LOS AÑOS ACTIVO. Podemos comprobar que el resultado es correcto viendo únicamente cuántas paradas realizó cada trabajador, ya que como vimos en el paso anterior, solo han trabajado durante un año, por lo que la media de paradas entre los años activo debe ser igual al total.

select passport, count(passport) as paradas from assign_drv natural join stops group by passport;

--Si comparamos los resultados con los de nuestra consulta, podemos ver que el número de paradas coincide, por lo que teniendo en cuenta lo dicho anteriormente podemos afirmar que el número de paradas totales coincide con el número de paradas medias y por lo tanto este atributo también es correcto.
--MEDIA PRÉSTAMOS SEGÚN LOS AÑOS ACTIVO. Las condiciones en este caso son similares a las del caso anterior, sabiendo que los años activos de cada conductor son uno, podemos calcular únicamente los préstamos totales y la consulta debería coincidir.

select passport, count(passport) as prestamos from services natural join loans group by passport;

--Si comparamos los resultados con los de nuestra consulta, vemos que el número de préstamos coincide, por lo que podemos afirmar que este dato también aparece correctamente en la consulta.
--PORCENTAJE. Para este dato simplemente comprobamos la cantidad de préstamos no devueltos de loans, que como ya mencionamos antes es 0, es por eso que no aparece nada en el apartado de porcentaje de ninguno de los conductores.

select count(signature) as prestamos_no_devueltos from loans where return is NULL;

--Tal y como hemos mencionado el resultado es 0, lo que coincide con que no exista porcentaje para ningún conductor.

--Con todas estas pruebas podemos afirmar que la consulta creada que junta todos los datos pedidos de los conductores coincide con los datos reales por lo que la consulta es correcta.

--Insertamos un nuevo bibusero
INSERT INTO drivers(passport, email, fullname, birthdate, phone, address, cont_start)
VALUES('ESP>>123456789101', 'Email', 'Bibusero 1', to_date('02/02/03', 'DD/MM/YY'), 123456789, 'Dirección 1', TRUNC(sysdate) - 365);

--Insertamos un usuario
INSERT INTO users(USER_ID, ID_CARD, NAME, SURNAME1, BIRTHDATE, TOWN, PROVINCE, ADDRESS, PHONE, TYPE)
VALUES(USER, 'ESP>>123456789102', 'Nombre', 'Apellido1', to_date('02/04/05', 'DD/MM/YY'), 'Valvacas de los Viajeros', 'Sevilla', 'Dirección 1', 123456789, 'P');

--Creamos una ruta
INSERT INTO routes VALUES('Ruta1');

--Creamos un bibus
INSERT INTO bibuses VALUES('Bibus1', to_date('01/01/25', 'DD/MM/YY'), to_date('01/01/26', 'DD/MM/YY'));

--Asignamos dos rutas nuevas a un bibus
INSERT INTO assign_bus VALUES('Bibus1', to_date('03/12/24', 'DD/MM/YY'), 'Ruta1');
INSERT INTO assign_bus VALUES('Bibus1', to_date('03/01/25', 'DD/MM/YY'), 'Ruta1');

--Asignamos al bibusero las mismas rutas (2 años distintos)
INSERT INTO assign_drv VALUES('ESP>>123456789101', to_date('03/12/24', 'DD/MM/YY'), 'Ruta1');
INSERT INTO assign_drv VALUES('ESP>>123456789101', to_date('03/01/25', 'DD/MM/YY'), 'Ruta1');

--Creamos una ciudad
INSERT INTO municipalities VALUES('Ciudad 1', 'Provincia 1', 6473);

--Creamos una parada
INSERT INTO stops VALUES('Ciudad 1', 'Provincia 1', 'Dirección 1', 'Ruta1', 40);

--Creamos dos servicios
INSERT INTO services VALUES('Ciudad 1', 'Provincia 1', 'Bibus1', to_date('03/12/24', 'DD/MM/YY'), 'ESP>>123456789101');
INSERT INTO services VALUES('Ciudad 1', 'Provincia 1', 'Bibus1', to_date('03/01/25', 'DD/MM/YY'), 'ESP>>123456789101');

--Creamos dos préstamos, uno con devolución y otro sin ella
INSERT INTO loans VALUES('AH582', USER, to_date('03/12/24', 'DD/MM/YY'), 'Ciudad 1', 'Provincia 1', 'L', 0, to_date('17/12/24', 'DD/MM/YY'));
INSERT INTO loans VALUES('AH580', USER, to_date('03/01/25', 'DD/MM/YY'), 'Ciudad 1', 'Provincia 1', 'L', 0, NULL);

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

--Vemos cómo aparece el nuevo bibusero en la consulta. Podemos comprobar que los datos que se muestran coinciden con los insertados, comprobando además que nuestro atributo porcentaje correctamente, ya que aparece que el 50% de sus préstamos no fueron devueltos, lo que es cierto gracias a la última inserción

--Borramos los datos insertados y recuperamos la base de datos original
DELETE FROM loans where user_id = USER;
DELETE FROM services where bus = 'Bibus1';
DELETE FROM stops where route_id = 'Ruta1';
DELETE FROM municipalities where town = 'Ciudad 1';
DELETE FROM assign_drv where passport = 'ESP>>123456789101';
DELETE FROM assign_bus where taskdate = to_date('03/12/24', 'DD/MM/YY');
DELETE FROM assign_bus where taskdate = to_date('03/01/25', 'DD/MM/YY');
DELETE FROM bibuses where plate = 'Bibus1';
DELETE FROM routes where route_id = 'Ruta1';
DELETE FROM users where user_id = USER;
DELETE FROM drivers where passport = 'ESP>>123456789101';



