--PROCEDIMIENTO 1
--Comprobamos que si el USER actual tiene una reserva con el ejemplar especificado, se actualiza en la tabla LOANS
set serveroutput on
INSERT INTO USERS(USER_ID, ID_CARD, NAME, SURNAME1, BIRTHDATE, TOWN, PROVINCE, ADDRESS, PHONE, TYPE) 
VALUES(USER, 'ESP>>123456789101', 'Nombre', 'Apellido1', to_date('02/04/05', 'DD/MM/YY'), 'Valvacas de los Viajeros', 'Sevilla', 'Dirección 1', 123456789, 'P');

INSERT INTO ASSIGN_BUS VALUES('BUS-011', TRUNC(sysdate), 'AN-01');

INSERT INTO ASSIGN_DRV VALUES('ESP>>101010101010', TRUNC(sysdate), 'AN-01');

INSERT INTO SERVICES VALUES('Atalaya de las Ardillas', 'Sevilla', 'BUS-011', TRUNC(sysdate), 'ESP>>101010101010');

INSERT INTO LOANS(SIGNATURE, USER_ID, STOPDATE, TOWN, PROVINCE, TYPE, TIME) VALUES('AH582', USER, TRUNC(sysdate), 'Atalaya de las Ardillas', 'Sevilla', 'R', 0);

--Después de realizar las inserciones necesarias ejecutamos el procedimiento:
EXEC foundicu.insertar_prestamo('AH582');

--Comprobamos que se han hecho los cambios correspondientes en loans:
select * from loans where user_id = USER;

--Podemos comprobar que el atributo type ha pasado de 'R' a 'L', además de que se ha mostrado por pantalla "¡Reserva convertida a préstamo exitosamente!", lo que confirma que este procedimiento modifica las reservas correctamente

--Ahora vamos a comprobar que si no tiene reserva, pero la copia está disponible, inserta el préstamo

DELETE FROM loans where user_id = USER;
EXEC foundicu.insertar_prestamo('AH580');
select * from loans where user_id = USER;

--Volvemos a ver que el préstamo ha sido exitoso, por lo que nuestras dos pruebas "correctas" se cumplen. Ahora vamos a pasar a los errores.
--Vamos a comprobar que si algún dato es incorrecto o hay algo que no se cumple, nos notificará por pantalla de ello y no se realizará ningún cambio:

--1. El usuario no es tipo "P" (persona):
DELETE FROM loans where user_id = USER;
UPDATE users SET type = 'L' where user_id = USER;
EXEC foundicu.insertar_prestamo('AH580');
select * from loans where user_id = USER;
--Observamos que nos informa de lo que ha sucedido, que era lo que nos esperábamos y además no existen filas en loans con el user actual

--2. El usuario tiene 2 o más préstamos:
UPDATE users SET type = 'P' where user_id = USER;
EXEC foundicu.insertar_prestamo('AH580');
EXEC foundicu.insertar_prestamo('AH579');
EXEC foundicu.insertar_prestamo('AH578');
select * from loans where user_id = USER;
--Al intentar hacer el tercer préstamo nos notifica de que supera el límite de préstamo que puede tener y no hace la inserción

--3. El usuario está baneado:
DELETE FROM loans where user_id = USER;
UPDATE users SET ban_up2 = to_date('20/05/25', 'DD/MM/YY') where user_id = USER;
EXEC foundicu.insertar_prestamo('AH580');
select * from loans where user_id = USER;
--Al intentar hace el préstamo nos indica que el usuario está baneado y no hace la inserción

--4. La copia que el usuario quiere sin tener reserva ya está prestada:
UPDATE users SET ban_up2 = NULL where user_id = USER;
EXEC foundicu.insertar_prestamo('AH580');
EXEC foundicu.insertar_prestamo('AH580');
select * from loans where user_id = USER;
--Al intentar realizar el segundo préstamo, salta el mensaje de que no fue posible.

--Al terminar de hacer las pruebas dejamos la base de datos tal y como estaba antes:
DELETE FROM loans where user_id = USER;
DELETE FROM services where town = 'Atalaya de las Ardillas' and province = 'Sevilla' and passport = 'ESP>>101010101010' and bus = 'BUS-011' and taskdate != to_date('14/11/24', 'DD/MM/YY');
DELETE FROM ASSIGN_DRV where passport = 'ESP>>101010101010' and route_id = 'AN-01' and taskdate != to_date('11/11/24', 'DD/MM/YY');
DELETE FROM ASSIGN_BUS where plate = 'BUS-011' and route_id = 'AN-01' and taskdate != to_date('11/11/24', 'DD/MM/YY');
DELETE FROM USERS where user_id = USER;



--PROCEDIMIENTO 2
--Comprobamos que si el USER cumple con los requisitos, pueda hacer la reserva
INSERT INTO USERS(USER_ID, ID_CARD, NAME, SURNAME1, BIRTHDATE, TOWN, PROVINCE, ADDRESS, PHONE, TYPE) 
VALUES(USER, 'ESP>>123456789101', 'Nombre', 'Apellido1', to_date('02/04/05', 'DD/MM/YY'), 'Valvacas de los Viajeros', 'Sevilla', 'Dirección 1', 123456789, 'P');

INSERT INTO ASSIGN_BUS VALUES('BUS-011', to_date('01/06/25', 'DD/MM/YY'), 'AN-01');

INSERT INTO ASSIGN_DRV VALUES('ESP>>101010101010', to_date('01/06/25', 'DD/MM/YY'), 'AN-01');

INSERT INTO SERVICES VALUES('Atalaya de las Ardillas', 'Sevilla', 'BUS-011', to_date('01/06/25', 'DD/MM/YY'), 'ESP>>101010101010');

--Después de realizar las inserciones ejecutamos:
EXEC foundicu.insertar_reserva('84-7844-352-5', to_date('01/06/25', 'DD/MM/YY'));

--Comprobamos que se han hecho los cambios correspondientes en loans:
select * from loans where user_id = USER;

--Vamos a comprobar que si algún dato es incorrecto o hay algo que no se cumple, nos notificará por pantalla de ello y no se realizará ningún cambio:
--1. El usuario no es tipo "P" (persona):
DELETE FROM loans where user_id = USER;
UPDATE users SET type = 'L' where user_id = USER;
EXEC foundicu.insertar_reserva('84-7844-352-5', to_date('01/06/25', 'DD/MM/YY'));
select * from loans where user_id = USER;
--Observamos que nos informa de lo que ha sucedido, que era lo que nos esperábamos y además no existen filas en loans con el user actual

--2. El usuario tiene 2 o más préstamos:
UPDATE users SET type = 'P' where user_id = USER;
EXEC foundicu.insertar_reserva('84-7844-352-5', to_date('01/06/25', 'DD/MM/YY'));
EXEC foundicu.insertar_reserva('84-8403-291-4', to_date('01/06/25', 'DD/MM/YY'));
EXEC foundicu.insertar_reserva('84-600-6797-1', to_date('01/06/25', 'DD/MM/YY'));
select * from loans where user_id = USER;
--Al intentar hacer la reserva nos notifica de que supera el límite de préstamo que puede tener y no hace la inserción

--3. El usuario está baneado:
DELETE FROM loans where user_id = USER;
UPDATE users SET ban_up2 = to_date('20/05/25', 'DD/MM/YY') where user_id = USER;
EXEC foundicu.insertar_reserva('84-7844-352-5', to_date('01/06/25', 'DD/MM/YY'));
select * from loans where user_id = USER;
--Al intentar hace el préstamo nos indica que el usuario está baneado y no hace la inserción

--4. No hay copias disponibles (Del isbn seleccionado solo existe una copia disponible, al hacer la segunda inserción nos avisará)
UPDATE users SET ban_up2 = NULL where user_id = USER;
DELETE FROM loans where user_id = USER;
EXEC foundicu.insertar_reserva('84-7844-352-5', to_date('01/06/25', 'DD/MM/YY'));
EXEC foundicu.insertar_reserva('84-7844-352-5', to_date('01/06/25', 'DD/MM/YY'));
select * from loans where user_id = USER;
--Al intentar realizar la segunda inserción nos avisa de que no hay copias disponibles y no realiza esa inserción, es decir, solo se muestra la primera

--Al terminar de hacer las pruebas dejamos la base de datos tal y como estaba antes:
DELETE FROM loans where user_id = USER;
DELETE FROM services where town = 'Atalaya de las Ardillas' and province = 'Sevilla' and passport = 'ESP>>101010101010' and bus = 'BUS-011' and taskdate = to_date('01/06/25', 'DD/MM/YY');
DELETE FROM ASSIGN_DRV where passport = 'ESP>>101010101010' and route_id = 'AN-01' and taskdate = to_date('01/06/25', 'DD/MM/YY');
DELETE FROM ASSIGN_BUS where plate = 'BUS-011' and route_id = 'AN-01' and taskdate = to_date('01/06/25', 'DD/MM/YY');
DELETE FROM USERS where user_id = USER;



--PROCEDIMIENTO 3
--Primero comprobamos que si el préstamo no existe nos avisa y no realiza ningún cambio en la tabla
INSERT INTO USERS(USER_ID, ID_CARD, NAME, SURNAME1, BIRTHDATE, TOWN, PROVINCE, ADDRESS, PHONE, TYPE) 
VALUES(USER, 'ESP>>123456789101', 'Nombre', 'Apellido1', to_date('02/04/05', 'DD/MM/YY'), 'Valvacas de los Viajeros', 'Sevilla', 'Dirección 1', 123456789, 'P');

EXEC foundicu.registrar_devolucion('AH582');
select * from loans where user_id = USER;
--Como era de esperar, nos dice que el usuario no tiene prestado el libro y no realiza cambios en la tabla

--Ahora comprobamos el otro caso, cuando tiene el libro prestado (realizamos las mismas inserciones que en el procedimiento 1)
INSERT INTO ASSIGN_BUS VALUES('BUS-011', TRUNC(sysdate), 'AN-01');

INSERT INTO ASSIGN_DRV VALUES('ESP>>101010101010', TRUNC(sysdate), 'AN-01');

INSERT INTO SERVICES VALUES('Atalaya de las Ardillas', 'Sevilla', 'BUS-011', TRUNC(sysdate), 'ESP>>101010101010');

INSERT INTO LOANS(SIGNATURE, USER_ID, STOPDATE, TOWN, PROVINCE, TYPE, TIME) VALUES('AH582', USER, TRUNC(sysdate), 'Atalaya de las Ardillas', 'Sevilla', 'R', 0);

EXEC foundicu.insertar_prestamo('AH582');

--Comprobamos que actualiza "return" del préstamo:
EXEC foundicu.registrar_devolucion('AH582');
select * from loans where user_id = USER;
--Como se puede ver en la consulta, se ha actualizado la fecha de return a la actual, por lo tanto el procedimiento funciona correctamente

--Al terminar de hacer las pruebas dejamos la base de datos tal y como estaba antes:
DELETE FROM loans where user_id = USER;
DELETE FROM services where town = 'Atalaya de las Ardillas' and province = 'Sevilla' and passport = 'ESP>>101010101010' and bus = 'BUS-011' and taskdate != to_date('14/11/24', 'DD/MM/YY');
DELETE FROM ASSIGN_DRV where passport = 'ESP>>101010101010' and route_id = 'AN-01' and taskdate != to_date('11/11/24', 'DD/MM/YY');
DELETE FROM ASSIGN_BUS where plate = 'BUS-011' and route_id = 'AN-01' and taskdate != to_date('11/11/24', 'DD/MM/YY');
DELETE FROM USERS where user_id = USER;



