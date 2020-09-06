USE sakila;

/*PUNTO 1*/
SELECT distinct name
FROM category
WHERE NOT EXISTS(
        SELECT *
        FROM film
                 join film_category fc on film.film_id = fc.film_id
                 JOIN film_actor fa on film.film_id = fa.film_id
                 join actor a on a.actor_id = fa.actor_id
        where category.category_id = fc.category_id
          AND a.first_name = 'PENELOPE'
          and a.last_name = 'CRONYN'
    );

/*PUNTO 2*/

SELECT
title,
name
FROM (
         SELECT title,
                c.name,
                RANK() OVER (PARTITION BY fc.category_id ORDER BY length desc ) ranking_duration
         FROM film
                JOIN film_category fc on film.film_id = fc.film_id
                JOIN category c on fc.category_id = c.category_id
     ) AS a
WHERE A.ranking_duration = 1;


/*PUNTO 3*/

SELECT COUNT(distinct fa.actor_id) counteo
FROM film
JOIN language L ON film.language_id = L.language_id
JOIN film_actor fa on film.film_id = fa.film_id
WHERE
L.name ='English';


/*PUNTO 4*/

SELECT
       title,
       COUNT(*) veces_vista,
       count(distinct customer_id)cantidad_clientes

FROM film
JOIN inventory i on film.film_id = i.film_id
JOIN rental r on i.inventory_id = r.inventory_id
group by title
order by 2 desc
LIMIT 1;

/*PUNTO 5*/

SELECT
       title,
       COUNT(*) veces_vista,
       count(distinct customer_id)cantidad_clientes,
       count(distinct city_id)ciudades_diferentes

FROM film
JOIN inventory i on film.film_id = i.film_id
JOIN rental r on i.inventory_id = r.inventory_id
JOIN store s on i.store_id = s.store_id
JOIN address a on s.address_id = a.address_id
group by title
order by 2 desc
LIMIT 1

