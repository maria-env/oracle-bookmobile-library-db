--Vista 1
CREATE OR REPLACE VIEW my_data AS (
	SELECT * 
		FROM users 
		WHERE user_id = USER
	) WITH READ ONLY;
/



--Vista 2
CREATE OR REPLACE VIEW my_loans AS (
	SELECT loans.signature, loans.user_id, loans.stopdate, loans.return, loans.type, loans.time, 
		posts.text AS post, posts.post_date, posts.likes, posts.dislikes
		FROM loans
		LEFT JOIN posts 
    			ON loans.signature = posts.signature AND loans.user_id = posts.user_id 
			AND loans.stopdate = posts.stopdate
		WHERE loans.user_id = USER );
/


CREATE OR REPLACE TRIGGER actualizar_post
	INSTEAD OF UPDATE ON my_loans
	FOR EACH ROW
	DECLARE existe_post NUMBER;
	BEGIN
            
            -- En el caso de que se esté modificando un atributo diferente a post
            IF :OLD.signature != :NEW.signature OR :OLD.user_id != :NEW.user_id OR :OLD.stopdate != :NEW.stopdate OR 
            :OLD.return != :NEW.return OR :OLD.type != :NEW.type OR :OLD.time != :NEW.time OR 
            :OLD.post_date != :NEW.post_date OR :OLD.likes != :NEW.likes OR :OLD.dislikes != :NEW.dislikes THEN
                RAISE_APPLICATION_ERROR(-20025, 'No está permitido modificar un atributo distinto de post');

            ELSE
            
            -- Miramos si para el préstamo correspondiente ya se ha publicado un post 
                SELECT COUNT('x') INTO existe_post
                FROM posts
                WHERE signature = :OLD.signature AND user_id = USER 
                AND stopdate = :OLD.stopdate;
    
                -- En caso de que sí exista un post, lo actualizamos 
                IF existe_post > 0 THEN
                    UPDATE posts SET text = :NEW.post, post_date = SYSDATE 
                    WHERE signature = :OLD.signature AND user_id = USER 
                    AND stopdate = :OLD.stopdate;
                ELSE
                    -- En caso de que no exista un post, lo insertamos 
                    INSERT INTO posts (signature, user_id, stopdate, post_date, text, likes, dislikes)
                        VALUES (:OLD.signature, USER, :OLD.stopdate, SYSDATE, :NEW.post, 0, 0);
                END IF;
            END IF;
    	END;
/


CREATE OR REPLACE TRIGGER prohibir_borrar_insertar
	INSTEAD OF DELETE OR INSERT ON my_loans
	FOR EACH ROW
	BEGIN
   		RAISE_APPLICATION_ERROR(-20001, 'No está permitido borrar o insertar datos en esta vista');
	END;
/



--Vista 3
CREATE OR REPLACE VIEW my_reservations AS 
select * from loans where user_id = USER and type = 'R';
/

CREATE OR REPLACE TRIGGER trigger_insertar_reserva
INSTEAD OF INSERT ON my_reservations
FOR EACH ROW
DECLARE
disponible NUMBER;
isbn_copia VARCHAR2(20);
copias_disponibles NUMBER;
nueva_copia CHAR(5);
disponible_copia NUMBER;
CURSOR copias IS select signature from copies where signature != :NEW.signature and 
isbn = (select isbn from copies where signature = :NEW.signature);
begin
select count('x') into disponible from loans where signature = :NEW.signature;
if disponible = 0 then
    INSERT INTO loans(signature, user_id, stopdate, town, province, type, time)
    VALUES (:NEW.signature, :NEW.user_id, :NEW.stopdate, :NEW.town, :NEW.province, :NEW.type, :NEW.time);

else
    select isbn into isbn_copia from copies where signature = :NEW.signature;
    select count('x') into copias_disponibles from copies where isbn = isbn_copia and signature != :NEW.signature;
    if copias_disponibles = 0 then
        RAISE_APPLICATION_ERROR(-20010, 'No hay más copias con el mismo isbn');
    else
        OPEN copias;
        LOOP
            FETCH copias into nueva_copia;
            EXIT WHEN copias%NOTFOUND;
            
            select count('x') into disponible_copia from loans where signature = nueva_copia;
                if disponible_copia = 0 then
                    INSERT INTO loans(signature, user_id, stopdate, town, province, type, time)
                    VALUES (nueva_copia, :NEW.user_id, :NEW.stopdate, :NEW.town, :NEW.province, :NEW.type, :NEW.time);
                    exit;
                end if;
        end loop;
        if disponible_copia > 0 then
            dbms_output.put_line('No hay copias disponibles');
        end if;
    end if;
end if;
end;
/

CREATE OR REPLACE TRIGGER trigger_eliminar_reserva
INSTEAD OF DELETE ON my_reservations
FOR EACH ROW
DECLARE
copias NUMBER;
begin
select count('x') into copias from loans where signature = :OLD.signature and user_id = :OLD.user_id and type = 'R';
if copias = 0 then
    RAISE_APPLICATION_ERROR(-20011, 'No existen reservas para el usuario indicado');
else
    DELETE FROM loans where signature = :OLD.signature and user_id = :OLD.user_id and type = 'R';
end if;

EXCEPTION
    when NO_DATA_FOUND then dbms_output.put_line('No se han encontrado los datos que se necesitaban');
    when OTHERS then dbms_output.put_line('Ha ocurrido un error');
end;
/

CREATE OR REPLACE TRIGGER trigger_actualizar_reserva
INSTEAD OF UPDATE ON my_reservations
FOR EACH ROW
DECLARE
verificar NUMBER;
begin
select count('x') into verificar from loans where user_id = :OLD.user_id and signature = :OLD.signature and type = 'R';
if verificar = 0 then
    RAISE_APPLICATION_ERROR(-20012, 'No existen reservas para el usuario indicado');
else
    UPDATE loans SET stopdate = :NEW.stopdate
    where user_id = :OLD.user_id
    and signature = :OLD.signature;
end if;
    
EXCEPTION
    when NO_DATA_FOUND then dbms_output.put_line('No se han encontrado los datos que se necesitaban');
    when OTHERS then dbms_output.put_line('Ha ocurrido un error');
end;
/



