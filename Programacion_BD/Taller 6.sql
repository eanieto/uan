use ejemplo;

create table familia(
    id integer,
    nombre varchar(50),
    id_madre integer
);

create table jerarquia(
    nivel integer,
    nombre_jerarquia varchar(20)
);
/*insert Jerarquia*/
insert into jerarquia values (1,'bisabuela');
insert into jerarquia values (2,'Abuela');
insert into jerarquia values (3,'Madre');
insert into jerarquia values (4,'Hija');
/*Insert Familia*/
insert into familia values (1,'Alicia',null);
insert into familia values (2,'Brigida',1);
insert into familia values (3,'Beatriz',1);
insert into familia values (4,'Benita',1);

insert into familia values (5,'Corina',2);
insert into familia values (6,'Carol',2);
insert into familia values (7,'Carmen',2);
insert into familia values (8,'Claudia',2);

insert into familia values (9,'Dalila',6);
insert into familia values (10,'Diana',6);



prepare consulta from  "
WITH RECURSIVE familia_jerarquia as (
    select id,
           nombre,
           id_madre,
           1 as jerarquia
    from familia
    where id_madre is null
    union all
    select f.id,
           f.nombre,
           f.id_madre,
           jerarquia + 1 as jerarquia
    from familia as f inner join familia_jerarquia as fj on f.id_madre = fj.id
    where jerarquia < ?
)
select *
from familia_jerarquia inner join jerarquia on familia_jerarquia.jerarquia = jerarquia.nivel
order by 4,2 asc"

set @jerarquia = 2
execute consulta using @jerarquia
;
