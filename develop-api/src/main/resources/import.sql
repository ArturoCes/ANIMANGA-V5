-- Datos de demostración del catálogo.
-- Los usuarios, carritos y compras de ejemplo se crean en DataSeeder (contraseñas cifradas en arranque).
-- Las portadas se copian desde resources/seed/covers al directorio de subidas al arrancar.

INSERT INTO category (id, name, description) VALUES ('c47e1a10-0000-4000-8000-000000000001', 'Shōnen', 'Dirigido a un público adolescente: acción, superación personal y compañerismo.');
INSERT INTO category (id, name, description) VALUES ('c47e1a10-0000-4000-8000-000000000002', 'Acción', 'Combates, persecuciones y ritmo trepidante.');
INSERT INTO category (id, name, description) VALUES ('c47e1a10-0000-4000-8000-000000000003', 'Sobrenatural', 'Maldiciones, espíritus y poderes más allá de lo humano.');
INSERT INTO category (id, name, description) VALUES ('c47e1a10-0000-4000-8000-000000000004', 'Fantasía oscura', 'Mundos sombríos donde el horror y la fantasía se mezclan.');
INSERT INTO category (id, name, description) VALUES ('c47e1a10-0000-4000-8000-000000000005', 'Escolar', 'Historias ambientadas en institutos y academias.');
INSERT INTO category (id, name, description) VALUES ('c47e1a10-0000-4000-8000-000000000006', 'Seinen', 'Dirigido a un público adulto, con tramas más maduras.');

INSERT INTO manga (id, name, author, publisher, release_date, poster_path, description) VALUES ('a1b2c3d4-0000-4000-8000-000000000001', 'Jujutsu Kaisen', 'Gege Akutami', 'Norma Editorial', '2018-03-05', 'jjk-01.jpg', 'Yuji Itadori es un estudiante con una fuerza física fuera de lo común. Tras tragarse un dedo maldito para salvar a sus amigos, pasa a compartir cuerpo con Ryomen Sukuna, el rey de las maldiciones, e ingresa en la Escuela Técnica de Hechicería de Tokio.');
INSERT INTO manga (id, name, author, publisher, release_date, poster_path, description) VALUES ('a1b2c3d4-0000-4000-8000-000000000002', 'Jujutsu Kaisen 0', 'Gege Akutami', 'Norma Editorial', '2017-04-28', 'jjk-00.jpg', 'Precuela de Jujutsu Kaisen. Yuta Okkotsu está atormentado por el espíritu de Rika, su amiga de la infancia, convertida en una maldición de grado especial. Satoru Gojo lo lleva a la escuela de hechicería para que aprenda a controlarla.');

INSERT INTO categories (manga_id, category_id) VALUES ('a1b2c3d4-0000-4000-8000-000000000001', 'c47e1a10-0000-4000-8000-000000000001');
INSERT INTO categories (manga_id, category_id) VALUES ('a1b2c3d4-0000-4000-8000-000000000001', 'c47e1a10-0000-4000-8000-000000000002');
INSERT INTO categories (manga_id, category_id) VALUES ('a1b2c3d4-0000-4000-8000-000000000001', 'c47e1a10-0000-4000-8000-000000000003');
INSERT INTO categories (manga_id, category_id) VALUES ('a1b2c3d4-0000-4000-8000-000000000001', 'c47e1a10-0000-4000-8000-000000000004');
INSERT INTO categories (manga_id, category_id) VALUES ('a1b2c3d4-0000-4000-8000-000000000002', 'c47e1a10-0000-4000-8000-000000000001');
INSERT INTO categories (manga_id, category_id) VALUES ('a1b2c3d4-0000-4000-8000-000000000002', 'c47e1a10-0000-4000-8000-000000000003');
INSERT INTO categories (manga_id, category_id) VALUES ('a1b2c3d4-0000-4000-8000-000000000002', 'c47e1a10-0000-4000-8000-000000000005');

-- ISBN de ejemplo (ficticios)
INSERT INTO volumen (id, nombre, precio, isbn, cantidad, poster_path, manga_id) VALUES ('b0b0b0b0-0000-4000-8000-000000000001', 'Jujutsu Kaisen 1', 8.50, '9788467940015', 25, 'jjk-01.jpg', 'a1b2c3d4-0000-4000-8000-000000000001');
INSERT INTO volumen (id, nombre, precio, isbn, cantidad, poster_path, manga_id) VALUES ('b0b0b0b0-0000-4000-8000-000000000002', 'Jujutsu Kaisen 2', 8.50, '9788467940022', 18, 'jjk-02.jpg', 'a1b2c3d4-0000-4000-8000-000000000001');
INSERT INTO volumen (id, nombre, precio, isbn, cantidad, poster_path, manga_id) VALUES ('b0b0b0b0-0000-4000-8000-000000000003', 'Jujutsu Kaisen 3', 8.50, '9788467940039', 12, 'jjk-03.jpg', 'a1b2c3d4-0000-4000-8000-000000000001');
INSERT INTO volumen (id, nombre, precio, isbn, cantidad, poster_path, manga_id) VALUES ('b0b0b0b0-0000-4000-8000-000000000005', 'Jujutsu Kaisen 5', 8.50, '9788467940053', 9, 'jjk-05.jpg', 'a1b2c3d4-0000-4000-8000-000000000001');
INSERT INTO volumen (id, nombre, precio, isbn, cantidad, poster_path, manga_id) VALUES ('b0b0b0b0-0000-4000-8000-000000000006', 'Jujutsu Kaisen 6', 8.50, '9788467940060', 3, 'jjk-06.jpg', 'a1b2c3d4-0000-4000-8000-000000000001');
INSERT INTO volumen (id, nombre, precio, isbn, cantidad, poster_path, manga_id) VALUES ('b0b0b0b0-0000-4000-8000-000000000007', 'Jujutsu Kaisen 7', 8.50, '9788467940077', 15, 'jjk-07.jpg', 'a1b2c3d4-0000-4000-8000-000000000001');
INSERT INTO volumen (id, nombre, precio, isbn, cantidad, poster_path, manga_id) VALUES ('b0b0b0b0-0000-4000-8000-000000000010', 'Jujutsu Kaisen 10', 8.95, '9788467940107', 0, 'jjk-10.jpg', 'a1b2c3d4-0000-4000-8000-000000000001');
INSERT INTO volumen (id, nombre, precio, isbn, cantidad, poster_path, manga_id) VALUES ('b0b0b0b0-0000-4000-8000-000000000013', 'Jujutsu Kaisen 13', 8.95, '9788467940138', 20, 'jjk-13.jpg', 'a1b2c3d4-0000-4000-8000-000000000001');
INSERT INTO volumen (id, nombre, precio, isbn, cantidad, poster_path, manga_id) VALUES ('b0b0b0b0-0000-4000-8000-000000000100', 'Jujutsu Kaisen 0', 9.50, '9788467941004', 30, 'jjk-00.jpg', 'a1b2c3d4-0000-4000-8000-000000000002');

INSERT INTO characters (id, name, age, description, image_url, manga_id) VALUES ('d0d0d0d0-0000-4000-8000-000000000001', 'Yuji Itadori', 15, 'Protagonista. Recipiente de Ryomen Sukuna y estudiante de primer año.', 'char-yuji.jpg', 'a1b2c3d4-0000-4000-8000-000000000001');
INSERT INTO characters (id, name, age, description, image_url, manga_id) VALUES ('d0d0d0d0-0000-4000-8000-000000000002', 'Megumi Fushiguro', 15, 'Hechicero que invoca shikigamis a través de sombras con la técnica de las Diez Sombras.', 'char-megumi.jpg', 'a1b2c3d4-0000-4000-8000-000000000001');
INSERT INTO characters (id, name, age, description, image_url, manga_id) VALUES ('d0d0d0d0-0000-4000-8000-000000000003', 'Nobara Kugisaki', 16, 'Hechicera de primer año que combate con martillo y clavos malditos.', 'char-nobara.jpg', 'a1b2c3d4-0000-4000-8000-000000000001');
INSERT INTO characters (id, name, age, description, image_url, manga_id) VALUES ('d0d0d0d0-0000-4000-8000-000000000004', 'Aoi Todo', 18, 'Estudiante de la escuela de Kioto, excéntrico y extraordinariamente fuerte.', 'char-todo.jpg', 'a1b2c3d4-0000-4000-8000-000000000001');
INSERT INTO characters (id, name, age, description, image_url, manga_id) VALUES ('d0d0d0d0-0000-4000-8000-000000000005', 'Yuta Okkotsu', 16, 'Estudiante maldito por el espíritu de Rika Orimoto.', 'char-yuta.jpg', 'a1b2c3d4-0000-4000-8000-000000000002');
