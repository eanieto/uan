/*PUNTO 1*/
create database test2;
use test2;

create table alumnos
(
    id               integer unsigned primary key,
    nombre           varchar(50),
    apellido1        varchar(50),
    apellido2        varchar(50),
    fecha_nacimiento date
);
INSERT INTO alumnos
values (1, 'Miryam', 'Fagua', 'Fabra', '1970-01-18');
INSERT INTO alumnos
values (2, 'Laura', 'Nieto', 'Fagua', '2002-11-14');
INSERT INTO alumnos
values (3, 'Gineth', 'Nieto', 'Fagua', '2001-10-14');
INSERT INTO alumnos
values (4, 'Karen', 'Reyes', 'Medina', '1993-04-27');

ALTER TABLE alumnos
    add column (edad integer);

DELIMITER |
create function calcular_edad(fecha date)
    returns integer deterministic
begin
    declare edad integer;
    SET edad = timestampdiff(year, fecha, curdate());
    return edad;
end |
DELIMITER ;


DROP PROCEDURE IF EXISTS actualizar_columna_edad;
delimiter  $$
CREATE PROCEDURE actualizar_columna_edad()
BEGIN
    DECLARE v_id integer;
    DECLARE v_fecha DATE;
    DECLARE done BOOL DEFAULT FALSE;
    DECLARE cur CURSOR FOR select id, fecha_nacimiento from alumnos;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    OPEN cur;
    read_loop :
    LOOP
        FETCH cur INTO v_id,v_fecha;
        IF done THEN
            LEAVE read_loop;
        END IF;
        UPDATE alumnos SET edad = calcular_edad(v_fecha) WHERE id = v_id;
    end loop;
    CLOSE cur;
END;
delimiter ;

CALL actualizar_columna_edad();

select *
from alumnos;

/*
Punto 2
*/

ALTER TABLE alumnos
    ADD COLUMN (email varchar(100));


CREATE PROCEDURE crear_email(IN nombre VARCHAR(50), IN apellido1 VARCHAR(50), IN apellido2 VARCHAR(50),
                             IN dominio VARCHAR(50), OUT emaiL VARCHAR(100))
BEGIN
    SET emaiL = CONCAT(substr(nombre, 1, 1), substr(apellido1, 1, 3), substr(apellido2, 1, 3), '@', dominio);
END;

CREATE PROCEDURE actualizar_columna_email()
BEGIN
    DECLARE v_nombre, v_apellido1, v_apellido2 VARCHAR(50);
    DECLARE done BOOL DEFAULT FALSE;
    DECLARE v_id INTEGER;
    DECLARE v_email VARCHAR(100);
    DECLARE cur1 CURSOR FOR select id, nombre, apellido1, apellido2 from alumnos;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    OPEN cur1;
    read_loop:
    LOOP
        FETCH cur1 into v_id,v_nombre,v_apellido1,v_apellido2;
        IF done THEN
            LEAVE read_loop;
        END IF;
        CALL crear_email(v_nombre, v_apellido1, v_apellido2, 'gmail.com', v_email);
        UPDATE alumnos SET email = v_email WHERE id = v_id;
    END LOOP;
END;
call actualizar_columna_email;
select *
from alumnos;

/*
Punto 3
*/
DROP PROCEDURE IF EXISTS crear_lista_emails_alumnos;
CREATE PROCEDURE crear_lista_emails_alumnos(OUT lista varchar(500))
BEGIN
    DECLARE done BOOL DEFAULT FALSE;
    DECLARE V_email VARCHAR(100);
    DECLARE cur CURSOR FOR select email from alumnos;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    OPEN cur;
    read_loop:
    LOOP
        FETCH cur INTO V_email;
        IF done THEN
            LEAVE read_loop;
        END IF;
        SET lista = CONCAT(lista, ';', V_email);
    END LOOP;
    SELECT lista;

END;


CALL crear_lista_emails_alumnos(@LISTA);
SELECT @LISTA;

/*
TRIGGERS
Punto 1
*/

DROP TRIGGER IF EXISTS trigger_crear_email_before_insert;
delimiter $$
CREATE TRIGGER trigger_crear_email_before_insert
    BEFORE INSERT
    ON alumnos
    FOR EACH ROW
BEGIN
    if NEW.email is null then
        call test2.crear_email(NEW.nombre, NEW.apellido1, NEW.apellido2, 'gmail.com', @mail);
        set new.email = @mail;
    end if;
END $$
delimiter ;
INSERT INTO test2.alumnos
values (5, 'Edwin', 'Nieto', 'Fabra', '1993-05-25', 27, null);

/*
Punto 3
*/
CREATE TABLE log_cambios_email
(
    id         integer primary key AUTO_INCREMENT,
    id_alumno  integer,
    fecha_hora datetime,
    old_email  varchar(100),
    new_email  varchar(100)
);



DROP TRIGGER IF EXISTS trigger_guardar_email_after_update;
delimiter $$
CREATE TRIGGER trigger_guardar_email_after_update
    BEFORE UPDATE
    ON alumnos
    FOR EACH ROW
BEGIN
    if NEW.email <> OLD.email THEN
        INSERT INTO log_cambios_email(ID_ALUMNO, FECHA_HORA, OLD_EMAIL, NEW_EMAIL)
        VALUES (OLD.id, CURRENT_TIMESTAMP, OLD.email, NEW.email);
    end if;
END;
DELIMITER ;

UPDATE alumnos
SET email = 'eanieto.9305@gmail.com'
WHERE id = 5;
SELECT *
FROM alumnos;
SELECT*
FROM log_cambios_email;

/*
Punto 4
*/

CREATE TABLE log_alumnos_eliminados
(
    id         integer primary key AUTO_INCREMENT,
    id_alumno  integer,
    fecha_hora datetime,
    nombre     varchar(50),
    apellido1  varchar(50),
    apellido2  varchar(50),
    email      varchar(100)
);

DROP TRIGGER IF EXISTS trigger_guardar_alumnos_eliminados;
DELIMITER $$
CREATE TRIGGER trigger_guardar_alumnos_eliminados
    BEFORE DELETE
    ON alumnos
    FOR EACH ROW
BEGIN
    INSERT INTO log_alumnos_eliminados(id_alumno, fecha_hora, nombre, apellido1, apellido2, email)
    VALUES (OLD.id, CURRENT_TIMESTAMP, OLD.nombre, OLD.apellido1, OLD.apellido2, OLD.email);
end;
DELIMITER ;


DELETE  FROM alumnos WHERE ID = 5;
SELECT * FROM alumnos;
SELECT * FROM log_alumnos_eliminados;