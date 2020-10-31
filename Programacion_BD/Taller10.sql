CREATE DATABASE DWH;
USE DWH;
/*
NOTA:
EJECUTAR EN EL ORDEN DEL ARCHIVO PARA EL CORRECTO FUNCIONAMIENTO DEL PROCEDIMIENTO PRINCIPAL.
Autor:Edwin Alberto Nieto Fagua
*/
/*CREACION DE PREREQUISITOS
  creacion de funcion de nombramiento de mes en español.
  */
DELIMITER |
CREATE FUNCTION nombre_mes(campofecha DATE)
RETURNS VARCHAR(20) DETERMINISTIC
READS SQL DATA
BEGIN
    declare mes varchar(20);
    SELECT
    CASE WHEN MONTH(campofecha) = 1 THEN 'enero'
    WHEN MONTH(campofecha) = 2 THEN 'febrero'
    WHEN MONTH(campofecha) = 3 THEN 'marzo'
    WHEN MONTH(campofecha) = 4 THEN 'abril'
    WHEN MONTH(campofecha) = 5 THEN 'mayo'
    WHEN MONTH(campofecha) = 6 THEN 'junio'
    WHEN MONTH(campofecha) = 7 THEN 'julio'
    WHEN MONTH(campofecha) = 8 THEN 'agosto'
    WHEN MONTH(campofecha) = 9 THEN 'septiembre'
    WHEN MONTH(campofecha) = 10 THEN 'octubre'
    WHEN MONTH(campofecha) = 11 THEN 'noviembre'
    WHEN MONTH(campofecha) = 12 THEN 'diciembre'
    ELSE 'esto no es un mes' END mes_nombre into mes;
    return mes;
END|
DELIMITER ;


/*Funcion dia de pascua*/
DELIMITER |
CREATE  FUNCTION dia_pascua(anio VARCHAR(4))
RETURNS  DATE DETERMINISTIC
BEGIN
    DECLARE p_m INTEGER;
    DECLARE p_n INTEGER;
    DECLARE p_a INTEGER;
    DECLARE p_b INTEGER;
    DECLARE  p_c INTEGER;
    DECLARE  p_d INTEGER;
    DECLARE  p_e INTEGER;
    DECLARE  p_dia INTEGER;
    DECLARE  p_mes INTEGER;
    DECLARE f_pascua date;
    SET p_m = 24;
    set p_n = 5;
    set p_a = mod(anio,19);
    set p_b = mod(anio,4);
    set p_c = mod(anio,7);
    set p_d = mod((19*p_a+p_m),30);
    set p_e = mod((2*p_b+4*p_c+6*p_d+p_n),7);
    if p_d+p_e < 10 then
        set p_dia = p_d+p_e+22;
        set p_mes = 3;
    else
        set p_dia = p_d+p_e-9;
        set p_mes = 4;
    end if;
    if p_dia = 26 and p_mes = 4 then
        set p_dia = 19;
    else if p_dia = 25 and p_mes = 4 and p_d = 28 and p_e = 6 and p_a > 10 then
            set p_dia = 18;
        end if ;
    end if ;
    set f_pascua =  str_to_date(concat(anio,'-',p_mes,'-',p_dia),'%Y-%m-%d');
    return f_pascua;
END|
DELIMITER ;

/*
funcion mover lunes
*/

DELIMITER |
CREATE  FUNCTION mover_lunes(fecha date)
RETURNS  DATE DETERMINISTIC
BEGIN
    declare var_lunes date;
    WHILE DAYOFWEEK(fecha) != 2 do
        set fecha =  date_add(fecha, interval 1 day);
    end while ;
    set var_lunes = fecha;
    return var_lunes;
end |
DELIMITER ;
/*
Funcion de conte de dias habiles
*/
CREATE FUNCTION ConteoHabiles(fecha date, is_anio bool)
    RETURNS integer deterministic
    READS SQL DATA
BEGIN
    DECLARE v_fecha_inicial date;
    DECLARE v_conteo_habiles integer;
    if is_anio then
        set v_fecha_inicial = DATE_FORMAT(fecha, '%Y-01-01');
        SELECT count(*) into v_conteo_habiles from dim_fecha where FE_FECHA between v_fecha_inicial and  fecha and MC_HABIL = 1;
        return v_conteo_habiles;
        else
        set v_fecha_inicial = DATE_FORMAT(fecha, '%Y-%m-01');
        SELECT count(*) into v_conteo_habiles from dim_fecha where FE_FECHA between v_fecha_inicial and  fecha and MC_HABIL = 1;
        return v_conteo_habiles;
    end if;
END;
/*
Funcion de conte de dias NO HABILES
*/
CREATE FUNCTION ConteoNoHabiles(fecha date, is_anio bool)
    RETURNS integer deterministic
    READS SQL DATA
BEGIN
    DECLARE v_fecha_inicial date;
    DECLARE v_conteo_No_habiles integer;
    if is_anio then
        set v_fecha_inicial = DATE_FORMAT(fecha, '%Y-01-01');
        SELECT count(*) into v_conteo_No_habiles from dim_fecha where FE_FECHA between v_fecha_inicial and  fecha and MC_HABIL = 0;
        return v_conteo_No_habiles;
        else
        set v_fecha_inicial = DATE_FORMAT(fecha, '%Y-%m-01');
        SELECT count(*) into v_conteo_No_habiles from dim_fecha where FE_FECHA between v_fecha_inicial and  fecha and MC_HABIL = 0;
        return v_conteo_No_habiles;
    end if;
END;

/*
Procedimiento de dias festivos
*/
DROP PROCEDURE IF EXISTS PROC_DIAS_FESTIVOS;
DELIMITER |
CREATE PROCEDURE PROC_DIAS_FESTIVOS(IN anio_ini INTEGER, in anio_fin INTEGER)
BEGIN
    DECLARE anio_var integer;
    DROP TABLE IF EXISTS festivos;
    CREATE TABLE IF NOT EXISTS dwh.festivos(
        FECHA DATE
    );
    set anio_var = anio_ini;
    WHILE anio_var <= anio_fin DO
        /*FIJOS*/
        INSERT INTO festivos VALUE (str_to_date(concat(anio_var,'-',01,'-',01),'%Y-%m-%d'));
        INSERT INTO festivos VALUE (str_to_date(concat(anio_var,'-',05,'-',01),'%Y-%m-%d'));
        INSERT INTO festivos VALUE (str_to_date(concat(anio_var,'-',07,'-',20),'%Y-%m-%d'));
        INSERT INTO festivos VALUE (str_to_date(concat(anio_var,'-',08,'-',07),'%Y-%m-%d'));
        INSERT INTO festivos VALUE (str_to_date(concat(anio_var,'-',12,'-',08),'%Y-%m-%d'));
        INSERT INTO festivos VALUE (str_to_date(concat(anio_var,'-',12,'-',25),'%Y-%m-%d'));
        /*SEGUN PASCUA*/
        INSERT INTO festivos VALUE (date_add(dia_pascua(anio_var), interval -3 day));
        INSERT INTO festivos VALUE (date_add(dia_pascua(anio_var), interval -2 day));
        INSERT INTO festivos VALUE (date_add(dia_pascua(anio_var), interval 43 day));
        INSERT INTO festivos VALUE (date_add(dia_pascua(anio_var), interval 64 day));
        INSERT INTO festivos VALUE (date_add(dia_pascua(anio_var), interval 71 day));
        /*FESTIVOS QUE PUEDEN SER MOVIDOS*/
        IF DAYOFWEEK(str_to_date(concat(anio_var,'-',01,'-',06),'%Y-%m-%d')) != 2 THEN
            INSERT INTO festivos VALUE (mover_lunes(str_to_date(concat(anio_var,'-',01,'-',06),'%Y-%m-%d')));
            ELSE
            INSERT INTO festivos VALUE (str_to_date(concat(anio_var,'-',01,'-',06),'%Y-%m-%d'));
        end if ;

        IF DAYOFWEEK(str_to_date(concat(anio_var,'-',03,'-',19),'%Y-%m-%d')) != 2 THEN
            INSERT INTO festivos VALUE (mover_lunes(str_to_date(concat(anio_var,'-',03,'-',19),'%Y-%m-%d')));
            ELSE
            INSERT INTO festivos VALUE (str_to_date(concat(anio_var,'-',03,'-',19),'%Y-%m-%d'));
        end if ;

        IF DAYOFWEEK(str_to_date(concat(anio_var,'-',06,'-',29),'%Y-%m-%d')) != 2 THEN
            INSERT INTO festivos VALUE (mover_lunes(str_to_date(concat(anio_var,'-',06,'-',29),'%Y-%m-%d')));
            ELSE
            INSERT INTO festivos VALUE (str_to_date(concat(anio_var,'-',06,'-',29),'%Y-%m-%d'));
        end if ;

        IF DAYOFWEEK(str_to_date(concat(anio_var,'-',08,'-',15),'%Y-%m-%d')) != 2 THEN
            INSERT INTO festivos VALUE (mover_lunes(str_to_date(concat(anio_var,'-',08,'-',15),'%Y-%m-%d')));
            ELSE
            INSERT INTO festivos VALUE (str_to_date(concat(anio_var,'-',08,'-',15),'%Y-%m-%d'));
        end if ;

        IF DAYOFWEEK(str_to_date(concat(anio_var,'-',10,'-',12),'%Y-%m-%d')) != 2 THEN
            INSERT INTO festivos VALUE (mover_lunes(str_to_date(concat(anio_var,'-',10,'-',12),'%Y-%m-%d')));
            ELSE
            INSERT INTO festivos VALUE (str_to_date(concat(anio_var,'-',10,'-',12),'%Y-%m-%d'));
        end if ;

        IF DAYOFWEEK(str_to_date(concat(anio_var,'-',11,'-',01),'%Y-%m-%d')) != 2 THEN
            INSERT INTO festivos VALUE (mover_lunes(str_to_date(concat(anio_var,'-',11,'-',01),'%Y-%m-%d')));
            ELSE
            INSERT INTO festivos VALUE (str_to_date(concat(anio_var,'-',11,'-',01),'%Y-%m-%d'));
        end if ;

        IF DAYOFWEEK(str_to_date(concat(anio_var,'-',11,'-',11),'%Y-%m-%d')) != 2 THEN
            INSERT INTO festivos VALUE (mover_lunes(str_to_date(concat(anio_var,'-',11,'-',11),'%Y-%m-%d')));
            ELSE
            INSERT INTO festivos VALUE (str_to_date(concat(anio_var,'-',11,'-',11),'%Y-%m-%d'));
        end if ;
        SET anio_var = anio_var +1;
    END WHILE ;

END|
DELIMITER ;

DROP PROCEDURE IF EXISTS PROC_HABILES;
delimiter |
CREATE PROCEDURE PROC_HABILES(out num_items integer)
BEGIN
   DECLARE done BOOL DEFAULT FALSE;
   DECLARE V_FECHA DATE;
   DECLARE V_HABILES_MES INTEGER;
   DECLARE V_NO_HABILES_MES INTEGER;
   DECLARE V_HABILES_ANIO INTEGER;
   DECLARE V_NO_HABILES_ANIO INTEGER;
   DECLARE cur CURSOR FOR select FE_FECHA from dim_fecha;
   declare continue handler for not found set done = true;
   open cur;
   READ_LOOP:
    LOOP
       FETCH cur INTO V_FECHA;
       IF done THEN
           LEAVE READ_LOOP;
       end if ;
       set V_HABILES_ANIO = ConteoHabiles(V_FECHA,1);
       set V_HABILES_MES = ConteoHabiles(V_FECHA,0);
       set V_NO_HABILES_ANIO = ConteoNoHabiles(V_FECHA,1);
       set V_NO_HABILES_MES = ConteoNoHabiles(V_FECHA,0);
       UPDATE dim_fecha SET NM_DIAS_HABILES_MES = V_HABILES_MES , NM_DIAS_HABILES_ANIO = V_HABILES_ANIO,
                            NM_DIAS_NO_HABILES_MES = V_NO_HABILES_MES, NM_DIAS_NO_HABILES_ANIO = V_NO_HABILES_ANIO,
                            FE_CREACION = CURDATE()
       WHERE FE_FECHA = V_FECHA;
       set num_items = num_items + 1;
   end loop ;

END |
DELIMITER ;
/*
  ***************************CREACION DEL PROCEDIMIENTO ALMACENADO PRINCIPAL*******************************
  */
DROP PROCEDURE IF EXISTS PROC_DIM_TIEMPO;
delimiter |
CREATE PROCEDURE PROC_DIM_TIEMPO(IN anio_inicial INTEGER,IN anio_final INTEGER)
BEGIN
    DECLARE fecha_comodin DATE;
    DECLARE var_fecha_ini DATE;
    DECLARE var_fecha_fin DATE;
    DECLARE var_num_datos INTEGER;
    declare var_inicio_proc timestamp;
    declare var_fin_proc timestamp;
    set var_inicio_proc = current_timestamp;
    SET var_fecha_ini = str_to_date(concat(anio_inicial,'-',01,'-',01),'%Y-%m-%d');
    SET var_fecha_fin = str_to_date(concat(anio_final,'-',12,'-',31),'%Y-%m-%d');
    /*Creacion de la tabla e insersion del primer registro*/
    DROP TABLE IF EXISTS DIM_FECHA;
    CREATE TABLE IF NOT EXISTS DIM_FECHA(
        SK_FECHA INTEGER UNIQUE,
        FE_FECHA DATE,
        NM_ANIO INTEGER,
        NM_MES INTEGER,
        NM_DIA INTEGER,
        DS_MES VARCHAR(20),
        NM_DIA_SEMANA SMALLINT,
        DS_DIA_SEMANA VARCHAR(20),
        MC_FESTIVO SMALLINT,
        MC_HABIL SMALLINT,
        NM_DIAS_HABILES_MES INTEGER,
        NM_DIAS_HABILES_ANIO INTEGER,
        NM_DIAS_NO_HABILES_MES INTEGER,
        NM_DIAS_NO_HABILES_ANIO INTEGER,
        FE_CREACION TIMESTAMP
    );
    INSERT INTO DIM_FECHA VALUE (19000101,'1900-01-01',1900,01,01,'Enero',DAYOFWEEK('1900-01-01')-1,
                             ELT(WEEKDAY('1900-01-01') + 1, 'Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado', 'Domingo'),
                            0,0,0,0,0,0,current_timestamp());
    /*Insersion de rango de fechas*/
    SET fecha_comodin = var_fecha_ini;
    WHILE fecha_comodin <= var_fecha_fin DO
        insert into dwh.DIM_FECHA(SK_FECHA,FE_FECHA,NM_ANIO,NM_MES,NM_DIA,DS_MES,NM_DIA_SEMANA,DS_DIA_SEMANA)
        values(CAST(DATE_FORMAT(fecha_comodin, "%Y%m%d") AS UNSIGNED),fecha_comodin,year(fecha_comodin),MONTH(fecha_comodin),DAY(fecha_comodin),
               nombre_mes(fecha_comodin),WEEKDAY(fecha_comodin)+1,ELT(WEEKDAY(fecha_comodin) + 1, 'Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado', 'Domingo')
               );
    set fecha_comodin = date_add(fecha_comodin, interval 1 day );
    END WHILE ;

    /*Llamado del procedimiento que crea los dias festivos y llenado del campo MC_FESTIVO en la dimension*/
    CALL PROC_DIAS_FESTIVOS(anio_inicial, anio_final);
    UPDATE DWH.dim_fecha SET MC_FESTIVO = 1 WHERE FE_FECHA IN(SELECT FECHA FROM festivos);
    UPDATE DWH.dim_fecha SET MC_FESTIVO =  0 WHERE MC_FESTIVO IS NULL;

    /*Actualizacion del campo MC_HABIL*/
    UPDATE DWH.dim_fecha SET MC_HABIL = 0 WHERE MC_FESTIVO = 1 OR NM_DIA_SEMANA IN (6,7);
    UPDATE DWH.dim_fecha SET MC_HABIL = 1 WHERE MC_FESTIVO = 0 AND  NM_DIA_SEMANA IN (1,2,3,4,5);
    /*Calculo conteo de habiles
     llamando procedimiento almacenado que calcula los dias habiles y no habiles, actualizando la tabla dimension
      */
    CALL PROC_HABILES(var_num_datos);
    /*Limpiando temporales y basura*/
    DROP TABLE IF EXISTS DWH.FESTIVOS;

    /*Mensaje final*/
    set var_fin_proc = current_timestamp;
END|
delimiter ;
/*PRUEBA DE FUNCIONAMIENTO*/
CALL PROC_DIM_TIEMPO(2018, 2020);

SELECT
*
FROM DWH.DIM_FECHA
