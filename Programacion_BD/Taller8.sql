use ejemplo;


/*Punto 1*/
DELIMITER $$
CREATE PROCEDURE `negativo`(in numero numeric(10,2), out respuesta varchar(50))
BEGIN
IF numero = 0 THEN
	SET respuesta = 'El numero es CERO';
	ELSEIF numero > 0 THEN
    SET respuesta = 'El numero es POSITIVO';
    ELSEIF numero < 0 THEN
    SET respuesta = 'El numero es NEGATIVO';
    END IF;
END;

DELIMITER $$

CALL negativo(0,@respuesta)
select @respuesta;

/*Punto 2*/

DELIMITER $$
CREATE PROCEDURE notas(in nota_numerica numeric(10,2), out nota_texto varchar(20))
BEGIN
    CASE
        WHEN nota_numerica BETWEEN 0 AND 5 THEN
            SET nota_texto = 'Insuficiente';
        WHEN  nota_numerica BETWEEN 5.1 AND 6 THEN
            SET nota_texto = 'Aprovado';
        WHEN nota_numerica BETWEEN 6.1 AND 7 THEN
            SET nota_texto = 'Bien';
        WHEN nota_numerica BETWEEN 7.1 AND 9 THEN
            SET  nota_texto = 'Notable';
        WHEN nota_numerica BETWEEN 9.1 AND 10 THEN
            SET nota_texto = 'Sobresaliente';
        ELSE
            SET nota_texto = 'No valido';
        END CASE;
END $$
DELIMITER ;

CALL notas(8.5,@nota_texto);
select @nota_texto;

/*Punto 3*/

DELIMITER $$
CREATE PROCEDURE nombre_dia(in dia_numero int, out dia_nombre varchar(20))
BEGIN
    CASE
    WHEN dia_numero = 1 THEN
        SET dia_nombre = 'Lunes';
    WHEN  dia_numero  = 2 THEN
        SET dia_nombre = 'Martes';
    WHEN dia_numero = 3 THEN
        SET dia_nombre = 'Miercoles';
    WHEN dia_numero = 4 THEN
        SET  dia_nombre = 'Jueves';
    WHEN dia_numero = 5 THEN
        SET dia_nombre = 'Viernes';
    WHEN dia_numero = 6 THEN
        SET dia_nombre = 'Sabado';
    WHEN dia_numero = 7 THEN
        SET dia_nombre = 'Domingo';
    ELSE
        SET dia_nombre = 'No valido';
    END CASE;
END;
DELIMITER ;
CALL nombre_dia(7,@dia_nombre);
select @dia_nombre;


/*Punto 4*/
use world;

CREATE PROCEDURE consulta_ciudades(in cod_pais varchar(3))
BEGIN
   SELECT name
       FROM city
    WHERE CountryCode = cod_pais;
END;

CALL consulta_ciudades('COL')


/*Punto 5*/

CREATE PROCEDURE aumenta_poblacion(in area numeric(10,2), in porcentaje numeric(10,2), out total_filas int)
BEGIN
   DROP TABLE IF EXISTS city_copia;
   CREATE TABLE city_copia AS (
       SELECT A.*
       FROM city AS A INNER JOIN country AS B ON A.CountryCode = B.Code
       WHERE B.SurfaceArea > area
   );
   UPDATE city_copia SET Population = (Population*(1+(porcentaje/100)));
   SET total_filas = (SELECT COUNT(*) FROM city_copia);
END;

CALL aumenta_poblacion(200000,10,@TOTALFILAS);
SELECT @TOTALFILAS;