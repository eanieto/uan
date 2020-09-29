use world;

/*PUNTO 1*/
DELIMITER |
CREATE FUNCTION multiplo3(numero integer)
    RETURNS text deterministic
BEGIN
   DECLARE num integer;
   SET num = numero;
   IF MOD(num, 3) = 0 THEN
       RETURN CONCAT('Múltiplo de 3');
       ELSE RETURN 'NA';
   end if;
END |
DELIMITER ;

SELECT multiplo3(9);


/*PUNTO 2*/

DELIMITER |
CREATE FUNCTION  Hipotenusa(lado_a numeric, lado_b numeric)
    RETURNS numeric deterministic
BEGIN
    DECLARE l_a, l_b, h numeric;
    set l_a = lado_a;
    set l_b = lado_b;
    set h = SQRT(POW(l_a,2)+ POW(l_b,2));
    return h;
end |
DELIMITER ;

SELECT Hipotenusa(5,12);

/*PUNTO 3*/

DELIMITER |
CREATE FUNCTION ConteoDomingos(fecha_ini date, fecha_fin date)
    RETURNS integer deterministic
BEGIN
    DECLARE conteo_domingos int;
    DECLARE fecha date;
    set conteo_domingos = 0;
    set fecha = fecha_ini;
    WHILE fecha <= fecha_fin DO
        IF dayofweek(fecha) = 1 THEN
            set conteo_domingos = conteo_domingos +1;
        end if ;
        set fecha = date_add(fecha, interval 1 day );
        end while;
    return conteo_domingos;
end |
DELIMITER ;

select ConteoDomingos('2020-09-01','2020-09-30');


/*PUNTO 4 */
DELIMITER |
CREATE  FUNCTION NumeroMayor(num1 numeric(10,2), num2 numeric(10,2), num3 numeric(10,2) )
    RETURNS NUMERIC(10,2) DETERMINISTIC
BEGIN
   IF num1 > num2 and num1 > num3 THEN
       RETURN num1;
       ELSEIF num2 > num1 and num2 > num3 then
       return num2;
       ELSE
       RETURN num3;
   end if;
END |
DELIMITER ;

SELECT NumeroMayor(10,15,9);
/*PUNTO 5*/

delimiter |
create  function AVGPopulationCountries(cod_pais varchar(20))
    returns numeric(10,2)
    DETERMINISTIC
    READS SQL DATA
begin
    declare avgPopulation numeric(10,2);
    SELECT  avg(Population) INTO avgPopulation FROM city  WHERE CountryCode = cod_pais;
    return avgPopulation;
end |
DELIMITER ;
SELECT AVGPopulationCountries('COL');

/*PUNTO 6*/
DELIMITER |
CREATE FUNCTION MaxSurfaceArea(continente varchar(20))
    RETURNS VARCHAR(20) DETERMINISTIC
    READS SQL DATA
BEGIN
    declare pais varchar(20);
    SELECT Name INTO pais
    FROM(
        SELECT name,
               SurfaceArea,
               ROW_NUMBER() over (PARTITION BY Continent ORDER BY SurfaceArea DESC) as numero
        FROM country
            where Continent = continente
            ) as tabla
    WHERE numero = 1;
    return pais;
end;

DELIMITER ;

select MaxSurfaceArea('Asia');

/*PUNTO 7*/

create table ejemplo.festivos
(
	nombre_festivo varchar(50) null,
	fecha_festivo date null
);


use ejemplo;

DELIMITER |
CREATE FUNCTION ConteoHabilesColombia(fecha_ini date, fecha_fin date)
    RETURNS integer deterministic
    READS SQL DATA
BEGIN
    DECLARE conteo_habiles int;
    DECLARE fecha date;
    set conteo_habiles = 0;
    set fecha = fecha_ini;
    WHILE fecha <= fecha_fin DO
        IF dayofweek(fecha) in (2,3,4,5,6) AND fecha NOT IN (select fecha_festivo from festivos) THEN
            set conteo_habiles = conteo_habiles +1;
        end if ;
        set fecha = date_add(fecha, interval 1 day );
        end while;
    return conteo_habiles;
end |
DELIMITER ;
#DROP FUNCTION ConteoHabilesColombia
select ConteoHabilesColombia('2020-10-01','2020-10-31');


