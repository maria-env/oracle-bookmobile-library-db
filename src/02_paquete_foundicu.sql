--Paquete con los procedimientos
CREATE OR REPLACE PACKAGE foundicu AS
	PROCEDURE insertar_prestamo(signatura CHAR);
	PROCEDURE insertar_reserva (isbn_input VARCHAR2, fecha_input date);
	PROCEDURE registrar_devolucion(signatura CHAR);
END foundicu;
/

CREATE OR REPLACE PACKAGE BODY foundicu AS

PROCEDURE insertar_prestamo(signatura CHAR) IS
usuario CHAR(10);
existe_prestamo NUMBER;
tipo CHAR(1);
libro_disponible NUMBER;
prestamos NUMBER;
fecha_ban DATE;
ciudad VARCHAR2(50);
provincia VARCHAR2(22);
hora NUMBER;
dia DATE;
begin
select user_id, type into usuario, tipo from users where user_id = USER;
select count('x') into existe_prestamo from loans where signature = signatura and stopdate = TRUNC(sysdate) and type = 'R' and user_id = usuario;
if existe_prestamo > 0 and tipo = 'P' then
    UPDATE loans SET type = 'L' where user_id = USER and signature = signatura and stopdate = TRUNC(sysdate) and type = 'R';
    dbms_output.put_line('¡El préstamo se ha registrado de manera exitosa!');
elsif existe_prestamo = 0 and tipo = 'P' then
    select count('x') into libro_disponible from loans where stopdate >= TRUNC(sysdate) and stopdate <= TRUNC(sysdate) + 14 and signature = signatura;
    if libro_disponible = 0 then
        select count(user_id) into prestamos from loans where user_id = USER;
        if prestamos >= 2 then
                dbms_output.put_line('El número de préstamos y/o reservas del usuario coincide con el límite permitido');
        else
            select ban_up2 into fecha_ban from users where user_id = USER;
            if fecha_ban is not NULL then
                    dbms_output.put_line('El usuario está baneado');
            else
                select town, province, taskdate INTO ciudad, provincia, dia from services where rownum = 1 and taskdate = TRUNC(sysdate);
                select stoptime into hora from stops where town = ciudad and province = provincia;
                INSERT INTO loans VALUES(signatura, usuario, dia, ciudad, provincia, 'L', hora, dia + 14);
                dbms_output.put_line('¡El préstamo se ha registrado de manera exitosa!');
            end if;
        end if;
    else
        dbms_output.put_line('La copia seleccionada no está disponible');
    end if;
else
    dbms_output.put_line('No se ha podido realizar el préstamo o el usuario en cuestión no es tipo "persona"');
end if;

EXCEPTION
    when NO_DATA_FOUND then dbms_output.put_line('No se han encontrado los datos que se necesitaban');
    when OTHERS then dbms_output.put_line('Se ha producido un error');
end;


PROCEDURE insertar_reserva (isbn_input VARCHAR2, fecha_input date) IS
usuario CHAR(10);
tipo CHAR(1);
prestamos number;
fecha_ban date;
num_copias number := 0;
copia CHAR(5);
ciudad VARCHAR2(50);
provincia VARCHAR2(22);
hora NUMBER;
dia DATE;
begin
select user_id, type into usuario, tipo from users where user_id = USER;
select count(user_id) into prestamos from loans where user_id = USER;
if prestamos >= 2 and tipo = 'P' then
    dbms_output.put_line('El número de préstamos y/o reservas del usuario coincide con el límite permitido');
elsif prestamos < 2 and tipo = 'P' then
    select ban_up2 into fecha_ban from users where user_id = USER;
    if fecha_ban is not NULL then
        dbms_output.put_line('El usuario está baneado');
    else
        select sum(count(signature)) into num_copias from copies natural join 
        (select signature from copies minus select signature from loans) where isbn = isbn_input group by signature;
        if num_copias is NULL then
            dbms_output.put_line('No hay copias disponibles');
        else
            select signature into copia from copies natural join (select signature from copies minus select signature from loans)
            where rownum = 1 and isbn = isbn_input;
            select town, province, taskdate INTO ciudad, provincia, dia from services where rownum = 1 and taskdate = fecha_input;
            select stoptime into hora from stops where town = ciudad and province = provincia;

            INSERT INTO loans VALUES(copia, usuario, dia, ciudad, provincia, 'R', hora, NULL); 
            dbms_output.put_line('Reserva insertada con éxito');
        end if;
    end if;
else
    dbms_output.put_line('El usuario que intenta hacer la reserva no es de tipo "persona"');
end if;

EXCEPTION
    when NO_DATA_FOUND then dbms_output.put_line('No se han encontrado los datos que se necesitaban');
    when OTHERS then dbms_output.put_line('Se ha producido un error');
end;


PROCEDURE registrar_devolucion(signatura CHAR) IS
usuario CHAR(10);
verificar number;
begin
select user_id into usuario from users where user_id = USER;
select count('x') into verificar from loans where signature = signatura and user_id = USER;
if verificar = 0 then
    dbms_output.put_line('El usuario no tiene prestado el libro seleccionado');
else
    UPDATE loans SET return = sysdate where signature = signatura and user_id = USER;
    dbms_output.put_line('Devolución registrada con éxito');
end if;

EXCEPTION
    when NO_DATA_FOUND then dbms_output.put_line('No se han encontrado los datos que se necesitaban');
    when OTHERS then dbms_output.put_line('Ha ocurrido un error');
end;
  			
END foundicu;
/



