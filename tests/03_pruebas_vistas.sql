--VISTA 1
--Cuando el usuario actual no está en la tabla users no se muestra nada en la vista:
select * from my_data;

--Insertamos al usuario
INSERT INTO USERS(USER_ID, ID_CARD, NAME, SURNAME1, BIRTHDATE, TOWN, PROVINCE, ADDRESS, PHONE, TYPE) 
VALUES(USER, 'ESP>>123456789101', 'Nombre', 'Apellido1', to_date('02/04/05', 'DD/MM/YY'), 'Valvacas de los Viajeros', 'Sevilla', 'Dirección 1', 123456789, 'P');

--Volvemos a comprobar la vista
select * from my_data;

--Borramos al usuario actual para dejar la base de datos tal y como estaba:
DELETE FROM USERS where user_id = USER;



--VISTA 2
-- Insertamos usuario
INSERT INTO USERS(USER_ID, ID_CARD, NAME, SURNAME1, BIRTHDATE, TOWN, PROVINCE, ADDRESS, PHONE, TYPE) 
VALUES(USER, 'ESP>>123456789101', 'Nombre', 'Apellido1', to_date('02/04/05', 'DD/MM/YY'), 'Valvacas de los Viajeros', 'Sevilla', 'Dirección 1', 123456789, 'P');

-- Insertamos ruta 
INSERT INTO routes VALUES('Ruta1');

-- Insertamos conductores
INSERT INTO drivers(passport, email, fullname, birthdate, phone, address, cont_start)
VALUES('ESP>>123456789101', 'Email', 'Bibusero 1', to_date('02/02/03', 'DD/MM/YY'), 123456789, 'Dirección 1', TRUNC(sysdate) - 365);

-- Insertamos asignaciones de los conductores
INSERT INTO assign_drv VALUES('ESP>>123456789101', to_date('03/12/24', 'DD/MM/YY'), 'Ruta1');
INSERT INTO assign_drv VALUES('ESP>>123456789101', to_date('03/01/25', 'DD/MM/YY'), 'Ruta1');

-- Insertamos bibuses
INSERT INTO bibuses VALUES('Bibus1', to_date('01/01/25', 'DD/MM/YY'), to_date('01/01/26', 'DD/MM/YY'));

-- Insertamos asignaciones a los bibuses
INSERT INTO assign_bus VALUES('Bibus1', to_date('03/12/24', 'DD/MM/YY'), 'Ruta1');
INSERT INTO assign_bus VALUES('Bibus1', to_date('03/01/25', 'DD/MM/YY'), 'Ruta1');

-- Insertamos municipios
INSERT INTO municipalities VALUES('Ciudad 1', 'Provincia 1', 6473);

-- Insertamos paradas
INSERT INTO stops VALUES('Ciudad 1', 'Provincia 1', 'Dirección 1', 'Ruta1', 40);

-- Insertamos services
INSERT INTO services VALUES('Ciudad 1', 'Provincia 1', 'Bibus1', to_date('03/12/24', 'DD/MM/YY'), 'ESP>>123456789101');
INSERT INTO services VALUES('Ciudad 1', 'Provincia 1', 'Bibus1', to_date('03/01/25', 'DD/MM/YY'), 'ESP>>123456789101');

-- Insertamos préstamos
INSERT INTO loans VALUES('AH582', USER, to_date('03/12/24', 'DD/MM/YY'), 'Ciudad 1', 'Provincia 1', 'L', 0, to_date('17/12/24', 'DD/MM/YY'));
INSERT INTO loans VALUES('AH578', USER, to_date('03/01/25', 'DD/MM/YY'), 'Ciudad 1', 'Provincia 1', 'L', 0, NULL);

-- Insertamos publicaciones
INSERT INTO posts VALUES ('AH582', USER, to_date('03/12/24','DD/MM/YY'), to_date('05/12/24', 'DD/MM/YY'), 'HOLA', 100, 0);

-- Comprobamos que la vista funciona
select * from my_loans;

-- Probar el primer trigger (UPDATE POST)
UPDATE my_loans SET post = 'ADIOS' where signature = 'AH582' AND stopdate = to_date('03/12/24','DD/MM/YY');
UPDATE my_loans SET post = 'HOLA' where signature = 'AH578';
select * from my_loans;

--Probamos que no se puede actualizar algún atributo distinto de post
UPDATE my_loans SET type = 'R' where signature = 'AH580';
UPDATE my_loans SET type = 'R', post = 'ADIOS' where signature = 'AH580';

-- Probar el segundo trigger (INSERT y DELETE)
DELETE from my_loans;
INSERT into my_loans VALUES ('AH581',USER,to_date('03/12/24','DD/MM/YY'),NULL,'L',0,NULL,NULL,NULL,NULL);

-- Tras terminar la prueba eliminamos todos los datos insertados durante esta
DELETE FROM posts where signature = 'AH578' AND user_id = USER AND stopdate = to_date('03/01/25', 'DD/MM/YY');
DELETE FROM posts where signature = 'AH582' AND user_id = USER AND stopdate = to_date('03/12/24', 'DD/MM/YY');

DELETE FROM loans where signature = 'AH578' AND user_id = USER AND stopdate = to_date('03/01/25', 'DD/MM/YY');
DELETE FROM loans where signature = 'AH582' AND user_id = USER AND stopdate = to_date('03/12/24', 'DD/MM/YY');

DELETE FROM services where town = 'Ciudad 1' AND province = 'Provincia 1' AND taskdate = to_date('03/12/24', 'DD/MM/YY');
DELETE FROM services where town = 'Ciudad 1' AND province = 'Provincia 1' AND taskdate = to_date('03/01/25', 'DD/MM/YY');

DELETE FROM stops where town = 'Ciudad 1' AND province = 'Provincia 1';

DELETE FROM municipalities where town = 'Ciudad 1' AND province = 'Provincia 1';

DELETE FROM assign_bus where plate = 'Bibus1' AND taskdate = to_date('03/12/24', 'DD/MM/YY');
DELETE FROM assign_bus where plate = 'Bibus1' AND taskdate = to_date('03/01/25', 'DD/MM/YY');

DELETE FROM bibuses where plate = 'Bibus1';

DELETE FROM assign_drv WHERE passport = 'ESP>>123456789101' and taskdate = to_date('03/12/24', 'DD/MM/YY');
DELETE FROM assign_drv WHERE passport = 'ESP>>123456789101' and taskdate = to_date('03/01/25', 'DD/MM/YY');

DELETE FROM drivers WHERE passport = 'ESP>>123456789101';

DELETE FROM routes WHERE route_id = 'Ruta1';

DELETE FROM users where user_id = USER;



--VISTA 3
--Hacemos las inserciones correspondientes para probar la vista.
INSERT INTO USERS(USER_ID, ID_CARD, NAME, SURNAME1, BIRTHDATE, TOWN, PROVINCE, ADDRESS, PHONE, TYPE) 
VALUES(USER, 'ESP>>123456789101', 'Nombre', 'Apellido1', to_date('02/04/05', 'DD/MM/YY'), 'Valvacas de los Viajeros', 'Sevilla', 'Dirección 1', 123456789, 'P');

INSERT INTO ASSIGN_BUS VALUES('BUS-011', to_date('01/01/25', 'DD/MM/YY'), 'AN-01');

INSERT INTO ASSIGN_DRV VALUES('ESP>>101010101010', to_date('01/01/25', 'DD/MM/YY'), 'AN-01');

INSERT INTO ASSIGN_BUS VALUES('BUS-011', to_date('02/01/25', 'DD/MM/YY'), 'AN-01');

INSERT INTO ASSIGN_DRV VALUES('ESP>>101010101010', to_date('02/01/25', 'DD/MM/YY'), 'AN-01');

INSERT INTO SERVICES VALUES('Atalaya de las Ardillas', 'Sevilla', 'BUS-011', to_date('01/01/25', 'DD/MM/YY'), 'ESP>>101010101010');

INSERT INTO SERVICES VALUES('Atalaya de las Ardillas', 'Sevilla', 'BUS-011', to_date('02/01/25', 'DD/MM/YY'), 'ESP>>101010101010');

--Insertamos una nueva reserva disponible
INSERT INTO my_reservations VALUES('ZM237', USER, to_date('01/01/25', 'DD/MM/YY'), 'Atalaya de las Ardillas', 'Sevilla', 'R', 0, NULL);

--Vemos si aparece en la vista.
select * from my_reservations;

--Insertamos la misma reserva esperando a que nos reserve la otra signatura existente con el mismo isbn (NC732)
INSERT INTO my_reservations VALUES('ZM237', USER, to_date('01/01/25', 'DD/MM/YY'), 'Atalaya de las Ardillas', 'Sevilla', 'R', 0, NULL);

--Vemos si aparece en la vista.
select * from my_reservations;

--Insertamos la misma reserva esperando a que nos diga que no hay copias disponibles.
INSERT INTO my_reservations VALUES('NC732', USER, to_date('01/01/25', 'DD/MM/YY'), 'Atalaya de las Ardillas', 'Sevilla', 'R', 0, NULL);
select * from my_reservations;

--Borramos todo para hacer la última prueba de inserciones
DELETE FROM loans where user_id = USER;

INSERT INTO my_reservations VALUES('YB164', USER, to_date('01/01/25', 'DD/MM/YY'), 'Atalaya de las Ardillas', 'Sevilla', 'R', 0, NULL);
INSERT INTO my_reservations VALUES('YB164', USER, to_date('01/01/25', 'DD/MM/YY'), 'Atalaya de las Ardillas', 'Sevilla', 'R', 0, NULL);
select * from my_reservations;

--Al hacer la segunda inserción nos dice que no hay copias disponibles con el mismo isbn

--Procedemos a realizar las actualizaciones
UPDATE my_reservations SET stopdate = to_date('02/01/25', 'DD/MM/YY') where user_id = USER and signature = 'YB164';
select * from my_reservations;

--Ahora vamos a tratar de borrar sobre la vista para comprobar que funciona el borrado
DELETE FROM my_reservations where user_id = USER;
select * from my_reservations;

--Volvemos a probar la actualización para asegurarnos de que salta el mensaje de error
UPDATE my_reservations SET stopdate = to_date('02/01/25', 'DD/MM/YY') where user_id = USER and signature = 'YB164';

--Volvemos a probar la eliminación para comprobar que si eliminamos filas que no existe salta un error
DELETE FROM my_reservations where user_id = USER;

--Borramos los datos para dejar la base como estaba antes
DELETE FROM services where town = 'Atalaya de las Ardillas' and province = 'Sevilla' and passport = 'ESP>>101010101010' and bus = 'BUS-011' and taskdate = to_date('01/01/25', 'DD/MM/YY');
DELETE FROM ASSIGN_DRV where passport = 'ESP>>101010101010' and route_id = 'AN-01' and taskdate = to_date('01/01/25', 'DD/MM/YY');
DELETE FROM ASSIGN_BUS where plate = 'BUS-011' and route_id = 'AN-01' and taskdate = to_date('01/01/25', 'DD/MM/YY');
DELETE FROM USERS where user_id = USER;



