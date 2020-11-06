USE ejemplo;


CREATE TABLE movies(

 id BIGINT PRIMARY KEY AUTO_INCREMENT,
     titulo VARCHAR(100) UNIQUE NOT NULL,
     etiquetas JSON NOT NULL
);

INSERT INTO movies(titulo, etiquetas)
VALUES('the world', '{"acerca" : {"genero": "acción", "cool": true}}');
INSERT INTO movies(titulo, etiquetas)
VALUES('Gozila', '{"acerca" : {"genero": "Ficción", "cool": true}}');
INSERT INTO movies(titulo, etiquetas)
VALUES('Coco', '{"acerca" : {"genero": "Animada", "cool": true}}');

INSERT INTO movies(titulo, etiquetas)
VALUES('Avatar', "[1,2]");



CREATE TABLE tj10
 (column_A JSON, column_b INT);


select *
from  tj10;

INSERT INTO tj10
VALUES ("[3,10,5,17,44]", 33),
       ("[3,10,5,17,[22,44,66]]", 0);


SELECT column_a->"$[4]" FROM tj10;


SELECT column_a->"$[4][2]" FROM tj10;


