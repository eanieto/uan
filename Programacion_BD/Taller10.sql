CREATE DATABASE DWH;

USE DWH;
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



/*
  CREACION DEL PROCEDIMIENTO ALMACENADO PRINCIPAL
  */
DROP PROCEDURE IF EXISTS PROC_DIM_TIEMPO;
CREATE PROCEDURE PROC_DIM_TIEMPO(IN fecha_inicial date,IN fecha_final date)
BEGIN
    DECLARE fecha_comodin DATE;
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
    SET fecha_comodin = fecha_inicial;
    WHILE fecha_comodin <= fecha_final DO
        insert into dwh.DIM_FECHA(SK_FECHA,FE_FECHA,NM_ANIO,NM_MES,NM_DIA,DS_MES,NM_DIA_SEMANA,DS_DIA_SEMANA)
        values(CAST(DATE_FORMAT(fecha_comodin, "%Y%m%d") AS UNSIGNED),fecha_comodin,year(fecha_comodin),MONTH(fecha_comodin),DAY(fecha_comodin),
               nombre_mes(fecha_comodin),WEEKDAY(fecha_comodin),ELT(WEEKDAY(fecha_comodin) + 1, 'Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado', 'Domingo')
               );
    set fecha_comodin = date_add(fecha_comodin, interval 1 day );
    END WHILE ;
END;

CALL PROC_DIM_TIEMPO('2020-09-01', CURDATE())

SELECT * FROM DWH.DIM_FECHA