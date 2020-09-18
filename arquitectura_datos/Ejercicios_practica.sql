SET search_path = courses;
select instructor.instructor_id,count(section_id) as Number_of_sections
from instructor natural left outer join teaches
group by instructor.instructor_id;

/*PROPUESTA PARA RESOLVER SIN USAR SUBCONSULTAS*/

select instructor.instructor_id,count(section_id) as Number_of_sections
from instructor left join teaches on teaches.teaches_id = instructor.instructor_id
group by instructor.instructor_id;
/*
lefrt outer join-> toma la interseccion mas el conjunto de la derecha.
numero de secciones enseñadas por cada instructor.
*/
------------------------------------------------
select I.instructor_id,
(select
count(*) as Number_of_sections
from teaches T where T.teaches_id = I.instructor_id)
from instructor I;


------------------------------------------------
select
course_id, section_id, instructor_id, instructor.name
--,decode(instructor.name, null, '*', instructor.name) as name
,COALESCE(instructor.name,'-')
from (section natural left outer join teaches)
natural left outer join instructor
--where semester='Spring' and year= 2018
;

select decode('ZW5jb2RlIGJhc2U2NCBzdHJpbmc=', 'base64');
select encode('encode base64 string', 'base64');




------------------------------------------------
select dept_name,
count(instructor_id)
from department natural left outer join instructor
group by dept_name;