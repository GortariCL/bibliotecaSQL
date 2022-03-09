-- Parte 2 - Creando el modelo en la base de datos

-- 1. Crear el modelo en una base de datos llamada biblioteca, considerando las tablas
-- definidas y sus atributos.

CREATE DATABASE biblioteca;
\c biblioteca

SET DATESTYLE TO 'European'; -- Formateo de fecha a estilo Europeo (dd-mm-aaaa)

DROP TABLE IF EXISTS libros_autor;
DROP TABLE IF EXISTS autor;
DROP TABLE IF EXISTS prestamos;
DROP TABLE IF EXISTS libros;
DROP TABLE IF EXISTS socios;

CREATE TABLE socios(
    rut VARCHAR(15) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    direccion VARCHAR(100) NOT NULL,
    telefono INT NOT NULL
);

CREATE TABLE libros(
    isbn VARCHAR(15) PRIMARY KEY,
    titulo VARCHAR(200) NOT NULL,
    num_paginas INT NOT NULL
);

CREATE TABLE prestamos(
    prestamo_id SERIAL PRIMARY KEY,
    libros_isbn VARCHAR NOT NULL REFERENCES libros(isbn),
    socio_rut VARCHAR NOT NULL REFERENCES socios(rut),
    fecha_inicio DATE NOT NULL,
    fecha_esperada_dev DATE NOT NULL, 
    fecha_real_dev DATE    
);

CREATE TABLE autor(
    cod_autor INT PRIMARY KEY,
    nombre_autor VARCHAR(50) NOT NULL,
    apellido_autor VARCHAR(50) NOT NULL,
    fecha_nac INT NOT NULL,
    fecha_muerte INT,
    tipo_autor VARCHAR (50) NOT NULL
);

CREATE TABLE libros_autor(
    libros_isbn VARCHAR UNIQUE NOT NULL REFERENCES libros(isbn),
    autor_cod_autor INT UNIQUE NOT NULL REFERENCES autor(cod_autor),
    PRIMARY KEY (libros_isbn, autor_cod_autor)
);

-- 2. Se deben insertar los registros en las tablas correspondientes.

BEGIN TRANSACTION;

INSERT INTO socios(rut, nombre, apellido, direccion, telefono)
VALUES('1111111-1','JUAN','SOTO','AVENIDA 1, SANTIAGO',911111111),
      ('2222222-2','ANA','PEREZ','PASAJE 2, SANTIAGO ',922222222),
      ('3333333-3','SANDRA','AGUILAR','PASAJE 2, SANTIAGO',933333333),
      ('4444444-4','ESTEBAN','JEREZ','AVENIDA 3, SANTIAGO',944444444),
      ('5555555-5','SILVANA','MUNOZ','PASAJE 3, SANTIAGO',955555555);

INSERT INTO libros(isbn, titulo, num_paginas)
VALUES('111-1111111-111','CUENTOS DE TERROR',344),
      ('222-2222222-222','POESIAS CONTEMPORANEAS',167),
      ('333-3333333-333','HISTORIA DE ASIA',511),
      ('444-4444444-444','MANUAL DE MECANICA',298);

INSERT INTO autor(cod_autor, nombre_autor, apellido_autor, fecha_nac, fecha_muerte, tipo_autor)
VALUES(3,'JOSE','SALGADO',1968,2020,'PRINCIPAL'),
      (4,'ANA','SALGADO',1972,NULL,'COAUTOR'),
      (1,'ANDRES','ULLOA',1982,NULL,'PRINCIPAL'),
      (2,'SERGIO','MARDONES',1950,2012,'PRINCIPAL'),
      (5,'MARTIN','PORTA',1976,NULL,'PRINCIPAL');

INSERT INTO prestamos(libros_isbn, socio_rut, fecha_inicio, fecha_esperada_dev, fecha_real_dev)
VALUES((SELECT isbn FROM libros WHERE titulo = 'CUENTOS DE TERROR'),
      (SELECT rut FROM socios WHERE nombre = 'JUAN' AND apellido = 'SOTO'),
      '20-01-2020','27-01-2020', NULL),

      ((SELECT isbn FROM libros WHERE titulo = 'POESIAS CONTEMPORANEAS'),
      (SELECT rut FROM socios WHERE nombre = 'SILVANA' AND apellido = 'MUNOZ'),
      '20-01-2020','30-01-2020', NULL),

      ((SELECT isbn FROM libros WHERE titulo = 'HISTORIA DE ASIA'),
      (SELECT rut FROM socios WHERE nombre = 'SANDRA' AND apellido = 'AGUILAR'),
      '22-01-2020','30-01-2020', NULL),

      ((SELECT isbn FROM libros WHERE titulo = 'MANUAL DE MECANICA'),
      (SELECT rut FROM socios WHERE nombre = 'ESTEBAN' AND apellido = 'JEREZ'),
      '23-01-2020','30-01-2020', NULL),

      ((SELECT isbn FROM libros WHERE titulo = 'CUENTOS DE TERROR'),
      (SELECT rut FROM socios WHERE nombre = 'ANA' AND apellido = 'PEREZ'),
      '27-01-2020','04-02-2020', NULL),

      ((SELECT isbn FROM libros WHERE titulo = 'MANUAL DE MECANICA'),
      (SELECT rut FROM socios WHERE nombre = 'JUAN' AND apellido = 'SOTO'),
      '31-01-2020','12-02-2020', NULL),

      ((SELECT isbn FROM libros WHERE titulo = 'POESIAS CONTEMPORANEAS'),
      (SELECT rut FROM socios WHERE nombre = 'SANDRA' AND apellido = 'AGUILAR'),
      '31-01-2020','12-02-2020', NULL);
      
COMMIT;

-- 3. Realizar las siguientes consultas:
-- a. Mostrar todos los libros que posean menos de 300 páginas.

SELECT titulo, num_paginas 
FROM libros 
WHERE num_paginas < 300
ORDER BY num_paginas ASC;

-- b. Mostrar todos los autores que hayan nacido después del 01-01-1970.

SELECT nombre_autor || ' ' || apellido_autor AS autor, fecha_nac 
FROM autor 
WHERE fecha_nac > 1970
ORDER BY fecha_nac ASC;

-- c. ¿Cuál es el libro más solicitado?.

SELECT libros.titulo, COUNT(prestamos.libros_isbn) AS cuenta 
FROM libros 
INNER JOIN prestamos
ON libros.isbn = prestamos.libros_isbn
GROUP BY libros.titulo
HAVING COUNT(prestamos.libros_isbn) > 1 --HAVING COUNT(*) > 1
ORDER BY cuenta DESC
LIMIT 1; 

-- d. Si se cobrara una multa de $100 por cada día de atraso, mostrar cuánto
-- debería pagar cada usuario que entregue el préstamo después de 7 días.

SELECT socios.nombre || ' ' || socios.apellido AS socio,
libros.titulo,
((prestamos.fecha_esperada_dev - prestamos.fecha_inicio) - 7) AS dias_atraso,
((prestamos.fecha_esperada_dev - prestamos.fecha_inicio) - 7) * 100 AS multa 
FROM prestamos
INNER JOIN socios
ON socios.rut = prestamos.socio_rut
INNER JOIN libros
ON libros.isbn = prestamos.libros_isbn
WHERE (prestamos.fecha_esperada_dev - prestamos.fecha_inicio) > 7
ORDER BY multa ASC;