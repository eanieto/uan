CREATE DATABASE world2;

use world2;

CREATE TABLE country(
    code varchar(4),
    name varchar(52),
    INFORMATION json
);


SET SESSION group_concat_max_len = 102400;

DELIMITER |
CREATE PROCEDURE CARGA_COUNTRY()
BEGIN
TRUNCATE TABLE country;
insert into country
select
       code,
       a.Name,
    JSON_OBJECT(
    'Continent',Continent,
    'Region',Region,
    'SurfaceArea',SurfaceArea,
    'IndepYear',IndepYear,
    'Population',a.Population,
    'LifeExpectancy',LifeExpectancy,
    'Capital',b.Name,
    'Language_oficial',oficial.oficial_array,
    'all_Language',all_Language.all_array,
    'Cities',(select json_array(group_concat(name separator ',')) from world.city where CountryCode = a.code))
from world.country as  a
left join   world.city as b on a.Capital = b.ID
inner join(
    SELECT JSON_ARRAY(group_concat(Language separator ',')) as oficial_array,CountryCode
FROM world.countrylanguage WHERE IsOfficial = 'T'
group by CountryCode
    ) as oficial on oficial.CountryCode = a.Code
inner join(
    SELECT JSON_ARRAY(group_concat(Language separator ',')) as all_array,CountryCode
FROM world.countrylanguage WHERE IsOfficial = 'F'
group by CountryCode
    ) as all_Language on all_Language.CountryCode = a.Code ;
end|
DELIMITER ;


CALL CARGA_COUNTRY();

select * from country
;
