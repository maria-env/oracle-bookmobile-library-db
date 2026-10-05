--Trigger 1
CREATE OR REPLACE TRIGGER evitar_post_usuario_inst
	BEFORE INSERT ON posts
	FOR EACH ROW
	DECLARE
    		tipo_usuario CHAR(1);
	BEGIN
    		SELECT type INTO tipo_usuario
    		FROM users
		-- Usamos el atributo user_id ya que es la referencia de relación entre las tablas posts y users
   		WHERE user_id = USER;
    		IF tipo_usuario = 'L' 
        		THEN RAISE_APPLICATION_ERROR(-20002, 'Opción "post" deshabilitada para usuarios institucionales');
                END IF;
END evitar_post_usuario_inst;
/



--Trigger 2
CREATE OR REPLACE TRIGGER libro_deteriorado
BEFORE UPDATE ON copies
FOR EACH ROW
begin
    if :NEW.condition = 'D'
        then :NEW.deregistered := sysdate;
    end if;
end;
/


--Trigger 3
ALTER TABLE books 
	ADD num_lecturas NUMBER(5) DEFAULT 0;

CREATE OR REPLACE TRIGGER numero_lecturas
	AFTER INSERT ON loans
	FOR EACH ROW
	DECLARE
		titulo VARCHAR2(200);
		autor VARCHAR2(100);

	BEGIN
		IF :NEW.type = 'L'
		THEN SELECT title, author INTO titulo, autor
				FROM copies JOIN editions ON copies.ISBN = editions.ISBN
				WHERE signature = :NEW.signature;

			UPDATE books
				SET num_lecturas = num_lecturas + 1
				WHERE title = titulo AND author = autor; 
		END IF;
END numero_lecturas;
