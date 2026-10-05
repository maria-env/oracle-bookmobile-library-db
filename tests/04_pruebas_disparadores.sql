--TRIGGER 1
--Insertamos al usuario y le ponemos un libro prestado:
INSERT INTO USERS(USER_ID, ID_CARD, NAME, SURNAME1, BIRTHDATE, TOWN, PROVINCE, ADDRESS, PHONE, TYPE) 
VALUES(USER, 'ESP>>123456789101', 'Nombre', 'Apellido1', to_date('02/04/05', 'DD/MM/YY'), 'Valvacas de los Viajeros', 'Sevilla', 'Dirección 1', 123456789, 'P');

INSERT INTO ASSIGN_BUS VALUES('BUS-011', to_date('01/01/25', 'DD/MM/YY'), 'AN-01');

INSERT INTO ASSIGN_DRV VALUES('ESP>>101010101010', to_date('01/01/25', 'DD/MM/YY'), 'AN-01');

INSERT INTO SERVICES VALUES('Atalaya de las Ardillas', 'Sevilla', 'BUS-011', to_date('01/01/25', 'DD/MM/YY'), 'ESP>>101010101010');

INSERT INTO LOANS(SIGNATURE, USER_ID, STOPDATE, TOWN, PROVINCE, TYPE, TIME) VALUES('AH582', USER, to_date('01/01/25', 'DD/MM/YY'), 'Atalaya de las Ardillas', 'Sevilla', 'L', 0);

--Tratamos de insertar en posts sabiendo que el tipo del usuario es correcto:
INSERT INTO POSTS VALUES('AH582', USER, to_date('01/01/25', 'DD/MM/YY'), TRUNC(sysdate), 'Texto de prueba', 0, 0);

--Comprobamos que aparece en la tabla:
select * from posts where user_id = USER;

--Borramos el post y le cambiamos el tipo al usuario:
DELETE FROM POSTS where user_id = USER;
UPDATE users SET type = 'L' where user_id = USER;

--Probamos a insertar el post otra vez:
INSERT INTO POSTS VALUES('AH582', USER, to_date('01/01/25', 'DD/MM/YY'), TRUNC(sysdate), 'Texto de prueba', 0, 0);

--Nos salta el error del disparador, por lo que este funciona correctamente.
--Comprobamos que NO aparece en la tabla:
select * from posts where user_id = USER;

--Dejamos la base de datos tal y como estaba:
DELETE FROM POSTS where user_id = USER;
DELETE FROM loans where user_id = USER;
DELETE FROM services where town = 'Atalaya de las Ardillas' and province = 'Sevilla' and passport = 'ESP>>101010101010' and bus = 'BUS-011' and taskdate = to_date('01/01/25', 'DD/MM/YY');
DELETE FROM ASSIGN_DRV where passport = 'ESP>>101010101010' and route_id = 'AN-01' and taskdate = to_date('01/01/25', 'DD/MM/YY');
DELETE FROM ASSIGN_BUS where plate = 'BUS-011' and route_id = 'AN-01' and taskdate = to_date('01/01/25', 'DD/MM/YY');
DELETE FROM USERS where user_id = USER;



--TRIGGER 2
--Insertamos un libro y una copia para probar el trigger, inicialmente el estado será bueno:
INSERT INTO books(TITLE, AUTHOR) VALUES('Prueba 1', 'Autor 1');
INSERT INTO editions(ISBN, TITLE, AUTHOR, LANGUAGE, NATIONAL_LIB_ID) VALUES('0-00-123456-1', 'Prueba 1', 'Autor 1', 'Español', 'BNE12345678910');
INSERT INTO copies(SIGNATURE, ISBN, CONDITION) VALUES('AA123', '0-00-123456-1', 'G');

--Probamos a cambiar el estado a deteriorado y vemos si ha actualizado al fecha de baja:
UPDATE copies SET condition = 'D' where signature = 'AA123';
select * from copies where signature = 'AA123';
--Se puede ver que su fecha de baja ha pasado de null a la actual, el trigger funciona.

--Dejamos la base de datos original:
DELETE FROM copies WHERE signature IN ('AA123');
DELETE FROM editions WHERE title = 'Prueba 1' and author = 'Autor 1';
DELETE FROM books WHERE title = 'Prueba 1' and author = 'Autor 1';



--TRIGGER 3
-- Tras insertar el atributo num_lecturas a la tabla books, comprobamos que está y todos los valores de esa columna equivalen al valor 0 impuesto por defecto. 
SELECT num_lecturas FROM books WHERE rownum <= 10;

-- Ahora definimos las pruebas para este último disparador. 
-- Insertamos un libro nuevo para probar el disparador en las tablas books, copies, editions

INSERT INTO books(title, author) VALUES ('AAA', 'aaa');
INSERT INTO editions(ISBN, title, author, language, national_lib_id) 
	VALUES ('123456789', 'AAA', 'aaa', 'Spanish', 'idtrig3');
INSERT INTO copies(signature, ISBN, condition) 
	VALUES ('trig3', '123456789', 'G');

-- Comprobamos que ese libro está en la tabla books y su número de lecturas es 0, por defecto.
SELECT num_lecturas FROM books WHERE title = 'AAA' AND author = 'aaa';

-- Insertamos en loans un nuevo préstamo del libro insertado previamente
INSERT INTO loans(signature, user_id, stopdate, town, province, type, time) 
	VALUES ('trig3', '0016965023', to_date('16/11/24', 'DD/MM/YY'), 'Atalaya de Debajo', 'Córdoba', 'L', 00000);

--Comprobamos en la tabla books que el número de préstamos se ha actualizado de 0 a 1
SELECT num_lecturas FROM books WHERE title = 'AAA' AND author = 'aaa';

--Dejamos la base de datos como estaba inicialmente eliminando el ejemplo de prueba
DELETE FROM loans WHERE signature = 'trig3' AND user_id = '0016965023' AND stopdate = to_date('16/11/24', 'DD/MM/YY');
DELETE FROM copies WHERE signature = 'trig3' AND ISBN = '123456789' AND condition = 'G';
