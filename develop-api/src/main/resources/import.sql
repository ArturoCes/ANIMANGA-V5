-- Datos de demostración del catálogo.
-- Los usuarios, carritos y compras de ejemplo se crean en DataSeeder (contraseñas cifradas en arranque).
-- Las portadas se copian desde resources/seed/covers al directorio de subidas al arrancar.

INSERT INTO category (id, name, description) VALUES ('c47e1a10-0000-4000-8000-000000000001', 'Shōnen', 'Dirigido a un público adolescente: acción, superación personal y compañerismo.');
INSERT INTO category (id, name, description) VALUES ('c47e1a10-0000-4000-8000-000000000002', 'Acción', 'Combates, persecuciones y ritmo trepidante.');
INSERT INTO category (id, name, description) VALUES ('c47e1a10-0000-4000-8000-000000000003', 'Sobrenatural', 'Maldiciones, espíritus y poderes más allá de lo humano.');
INSERT INTO category (id, name, description) VALUES ('c47e1a10-0000-4000-8000-000000000004', 'Fantasía oscura', 'Mundos sombríos donde el horror y la fantasía se mezclan.');
INSERT INTO category (id, name, description) VALUES ('c47e1a10-0000-4000-8000-000000000005', 'Escolar', 'Historias ambientadas en institutos y academias.');
INSERT INTO category (id, name, description) VALUES ('c47e1a10-0000-4000-8000-000000000006', 'Aventura', 'Viajes, exploración y grandes objetivos.');
INSERT INTO category (id, name, description) VALUES ('c47e1a10-0000-4000-8000-000000000007', 'Comedia', 'Humor y situaciones disparatadas.');
INSERT INTO category (id, name, description) VALUES ('c47e1a10-0000-4000-8000-000000000008', 'Drama', 'Historias con gran carga emocional.');

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

-- ---------- Más series

INSERT INTO manga (id, name, author, publisher, release_date, poster_path, description) VALUES ('a1b2c3d4-0000-4000-8000-000000000003', 'One Piece', 'Eiichirō Oda', 'Planeta Cómic', '1997-12-24', 'op-01.jpg', 'Monkey D. Luffy, un joven con el cuerpo de goma tras comer una fruta del diablo, zarpa con su tripulación en busca del legendario tesoro One Piece para convertirse en el Rey de los Piratas.');
INSERT INTO categories (manga_id, category_id) VALUES ('a1b2c3d4-0000-4000-8000-000000000003', 'c47e1a10-0000-4000-8000-000000000001');
INSERT INTO categories (manga_id, category_id) VALUES ('a1b2c3d4-0000-4000-8000-000000000003', 'c47e1a10-0000-4000-8000-000000000002');
INSERT INTO categories (manga_id, category_id) VALUES ('a1b2c3d4-0000-4000-8000-000000000003', 'c47e1a10-0000-4000-8000-000000000006');
INSERT INTO categories (manga_id, category_id) VALUES ('a1b2c3d4-0000-4000-8000-000000000003', 'c47e1a10-0000-4000-8000-000000000007');
INSERT INTO volumen (id, nombre, precio, isbn, cantidad, poster_path, manga_id) VALUES ('b0b0b0b0-0000-4000-8000-000000003001', 'One Piece 1', 8.50, '9788403000001', 30, 'op-01.jpg', 'a1b2c3d4-0000-4000-8000-000000000003');
INSERT INTO volumen (id, nombre, precio, isbn, cantidad, poster_path, manga_id) VALUES ('b0b0b0b0-0000-4000-8000-000000003002', 'One Piece 2', 8.50, '9788403000002', 22, 'op-02.jpg', 'a1b2c3d4-0000-4000-8000-000000000003');
INSERT INTO volumen (id, nombre, precio, isbn, cantidad, poster_path, manga_id) VALUES ('b0b0b0b0-0000-4000-8000-000000003003', 'One Piece 3', 8.50, '9788403000003', 14, 'op-03.jpg', 'a1b2c3d4-0000-4000-8000-000000000003');
INSERT INTO volumen (id, nombre, precio, isbn, cantidad, poster_path, manga_id) VALUES ('b0b0b0b0-0000-4000-8000-000000003004', 'One Piece 4', 8.50, '9788403000004', 9, 'op-04.jpg', 'a1b2c3d4-0000-4000-8000-000000000003');
INSERT INTO characters (id, name, age, description, image_url, manga_id) VALUES ('d0d0d0d0-0000-4000-8000-000000000006', 'Monkey D. Luffy', 17, 'Capitán de los Piratas del Sombrero de Paja.', 'char-luffy.jpg', 'a1b2c3d4-0000-4000-8000-000000000003');

INSERT INTO manga (id, name, author, publisher, release_date, poster_path, description) VALUES ('a1b2c3d4-0000-4000-8000-000000000004', 'Naruto', 'Masashi Kishimoto', 'Planeta Cómic', '2000-03-03', 'nar-01.jpg', 'Naruto Uzumaki, un ninja revoltoso que lleva sellado en su interior al zorro de nueve colas, sueña con ser reconocido por su aldea y convertirse en Hokage.');
INSERT INTO categories (manga_id, category_id) VALUES ('a1b2c3d4-0000-4000-8000-000000000004', 'c47e1a10-0000-4000-8000-000000000001');
INSERT INTO categories (manga_id, category_id) VALUES ('a1b2c3d4-0000-4000-8000-000000000004', 'c47e1a10-0000-4000-8000-000000000002');
INSERT INTO categories (manga_id, category_id) VALUES ('a1b2c3d4-0000-4000-8000-000000000004', 'c47e1a10-0000-4000-8000-000000000006');
INSERT INTO volumen (id, nombre, precio, isbn, cantidad, poster_path, manga_id) VALUES ('b0b0b0b0-0000-4000-8000-000000004001', 'Naruto 1', 8.95, '9788404000001', 18, 'nar-01.jpg', 'a1b2c3d4-0000-4000-8000-000000000004');
INSERT INTO volumen (id, nombre, precio, isbn, cantidad, poster_path, manga_id) VALUES ('b0b0b0b0-0000-4000-8000-000000004002', 'Naruto 2', 8.95, '9788404000002', 15, 'nar-02.jpg', 'a1b2c3d4-0000-4000-8000-000000000004');
INSERT INTO volumen (id, nombre, precio, isbn, cantidad, poster_path, manga_id) VALUES ('b0b0b0b0-0000-4000-8000-000000004003', 'Naruto 3', 8.95, '9788404000003', 4, 'nar-03.jpg', 'a1b2c3d4-0000-4000-8000-000000000004');
INSERT INTO volumen (id, nombre, precio, isbn, cantidad, poster_path, manga_id) VALUES ('b0b0b0b0-0000-4000-8000-000000004004', 'Naruto 4', 8.95, '9788404000004', 11, 'nar-04.jpg', 'a1b2c3d4-0000-4000-8000-000000000004');
INSERT INTO characters (id, name, age, description, image_url, manga_id) VALUES ('d0d0d0d0-0000-4000-8000-000000000007', 'Naruto Uzumaki', 12, 'Ninja de la Hoja que aspira a ser Hokage.', 'char-naruto.jpg', 'a1b2c3d4-0000-4000-8000-000000000004');

INSERT INTO manga (id, name, author, publisher, release_date, poster_path, description) VALUES ('a1b2c3d4-0000-4000-8000-000000000005', 'Ataque a los Titanes', 'Hajime Isayama', 'Norma Editorial', '2010-03-17', 'snk-01.jpg', 'La humanidad sobrevive tras enormes murallas que la protegen de los titanes. Cuando un titán colosal abre una brecha, Eren Jaeger jura exterminarlos a todos.');
INSERT INTO categories (manga_id, category_id) VALUES ('a1b2c3d4-0000-4000-8000-000000000005', 'c47e1a10-0000-4000-8000-000000000001');
INSERT INTO categories (manga_id, category_id) VALUES ('a1b2c3d4-0000-4000-8000-000000000005', 'c47e1a10-0000-4000-8000-000000000002');
INSERT INTO categories (manga_id, category_id) VALUES ('a1b2c3d4-0000-4000-8000-000000000005', 'c47e1a10-0000-4000-8000-000000000004');
INSERT INTO categories (manga_id, category_id) VALUES ('a1b2c3d4-0000-4000-8000-000000000005', 'c47e1a10-0000-4000-8000-000000000008');
INSERT INTO volumen (id, nombre, precio, isbn, cantidad, poster_path, manga_id) VALUES ('b0b0b0b0-0000-4000-8000-000000005001', 'Ataque a los Titanes 1', 8.50, '9788405000001', 20, 'snk-01.jpg', 'a1b2c3d4-0000-4000-8000-000000000005');
INSERT INTO volumen (id, nombre, precio, isbn, cantidad, poster_path, manga_id) VALUES ('b0b0b0b0-0000-4000-8000-000000005002', 'Ataque a los Titanes 2', 8.50, '9788405000002', 0, 'snk-02.jpg', 'a1b2c3d4-0000-4000-8000-000000000005');
INSERT INTO volumen (id, nombre, precio, isbn, cantidad, poster_path, manga_id) VALUES ('b0b0b0b0-0000-4000-8000-000000005003', 'Ataque a los Titanes 3', 8.50, '9788405000003', 12, 'snk-03.jpg', 'a1b2c3d4-0000-4000-8000-000000000005');
INSERT INTO volumen (id, nombre, precio, isbn, cantidad, poster_path, manga_id) VALUES ('b0b0b0b0-0000-4000-8000-000000005004', 'Ataque a los Titanes 4', 8.50, '9788405000004', 7, 'snk-04.jpg', 'a1b2c3d4-0000-4000-8000-000000000005');
INSERT INTO characters (id, name, age, description, image_url, manga_id) VALUES ('d0d0d0d0-0000-4000-8000-000000000008', 'Mikasa Ackerman', 15, 'Soldado prodigio y protectora incondicional de Eren.', 'char-mikasa.jpg', 'a1b2c3d4-0000-4000-8000-000000000005');

INSERT INTO manga (id, name, author, publisher, release_date, poster_path, description) VALUES ('a1b2c3d4-0000-4000-8000-000000000006', 'Guardianes de la Noche', 'Koyoharu Gotōge', 'Norma Editorial', '2016-06-03', 'kny-01.jpg', 'Tras la masacre de su familia, Tanjiro Kamado se une a los cazadores de demonios para devolver la humanidad a su hermana Nezuko, convertida en demonio.');
INSERT INTO categories (manga_id, category_id) VALUES ('a1b2c3d4-0000-4000-8000-000000000006', 'c47e1a10-0000-4000-8000-000000000001');
INSERT INTO categories (manga_id, category_id) VALUES ('a1b2c3d4-0000-4000-8000-000000000006', 'c47e1a10-0000-4000-8000-000000000002');
INSERT INTO categories (manga_id, category_id) VALUES ('a1b2c3d4-0000-4000-8000-000000000006', 'c47e1a10-0000-4000-8000-000000000003');
INSERT INTO categories (manga_id, category_id) VALUES ('a1b2c3d4-0000-4000-8000-000000000006', 'c47e1a10-0000-4000-8000-000000000004');
INSERT INTO volumen (id, nombre, precio, isbn, cantidad, poster_path, manga_id) VALUES ('b0b0b0b0-0000-4000-8000-000000006001', 'Guardianes de la Noche 1', 8.50, '9788406000001', 25, 'kny-01.jpg', 'a1b2c3d4-0000-4000-8000-000000000006');
INSERT INTO volumen (id, nombre, precio, isbn, cantidad, poster_path, manga_id) VALUES ('b0b0b0b0-0000-4000-8000-000000006002', 'Guardianes de la Noche 2', 8.50, '9788406000002', 19, 'kny-02.jpg', 'a1b2c3d4-0000-4000-8000-000000000006');
INSERT INTO volumen (id, nombre, precio, isbn, cantidad, poster_path, manga_id) VALUES ('b0b0b0b0-0000-4000-8000-000000006003', 'Guardianes de la Noche 3', 8.50, '9788406000003', 16, 'kny-03.jpg', 'a1b2c3d4-0000-4000-8000-000000000006');
INSERT INTO volumen (id, nombre, precio, isbn, cantidad, poster_path, manga_id) VALUES ('b0b0b0b0-0000-4000-8000-000000006004', 'Guardianes de la Noche 4', 8.50, '9788406000004', 2, 'kny-04.jpg', 'a1b2c3d4-0000-4000-8000-000000000006');
INSERT INTO characters (id, name, age, description, image_url, manga_id) VALUES ('d0d0d0d0-0000-4000-8000-000000000009', 'Tanjiro Kamado', 13, 'Cazador de demonios con un olfato excepcional.', 'char-tanjiro.jpg', 'a1b2c3d4-0000-4000-8000-000000000006');
INSERT INTO characters (id, name, age, description, image_url, manga_id) VALUES ('d0d0d0d0-0000-4000-8000-000000000010', 'Zenitsu Agatsuma', 16, 'Cobarde... hasta que se queda dormido.', 'char-zenitsu.jpg', 'a1b2c3d4-0000-4000-8000-000000000006');

INSERT INTO manga (id, name, author, publisher, release_date, poster_path, description) VALUES ('a1b2c3d4-0000-4000-8000-000000000007', 'Chainsaw Man', 'Tatsuki Fujimoto', 'Norma Editorial', '2019-03-04', 'csm-01.jpg', 'Denji, ahogado en deudas, se fusiona con su perro-demonio motosierra Pochita y acaba trabajando como cazador de demonios para el gobierno.');
INSERT INTO categories (manga_id, category_id) VALUES ('a1b2c3d4-0000-4000-8000-000000000007', 'c47e1a10-0000-4000-8000-000000000001');
INSERT INTO categories (manga_id, category_id) VALUES ('a1b2c3d4-0000-4000-8000-000000000007', 'c47e1a10-0000-4000-8000-000000000002');
INSERT INTO categories (manga_id, category_id) VALUES ('a1b2c3d4-0000-4000-8000-000000000007', 'c47e1a10-0000-4000-8000-000000000003');
INSERT INTO categories (manga_id, category_id) VALUES ('a1b2c3d4-0000-4000-8000-000000000007', 'c47e1a10-0000-4000-8000-000000000004');
INSERT INTO volumen (id, nombre, precio, isbn, cantidad, poster_path, manga_id) VALUES ('b0b0b0b0-0000-4000-8000-000000007001', 'Chainsaw Man 1', 8.95, '9788407000001', 14, 'csm-01.jpg', 'a1b2c3d4-0000-4000-8000-000000000007');
INSERT INTO volumen (id, nombre, precio, isbn, cantidad, poster_path, manga_id) VALUES ('b0b0b0b0-0000-4000-8000-000000007002', 'Chainsaw Man 2', 8.95, '9788407000002', 10, 'csm-02.jpg', 'a1b2c3d4-0000-4000-8000-000000000007');
INSERT INTO volumen (id, nombre, precio, isbn, cantidad, poster_path, manga_id) VALUES ('b0b0b0b0-0000-4000-8000-000000007003', 'Chainsaw Man 3', 8.95, '9788407000003', 8, 'csm-03.jpg', 'a1b2c3d4-0000-4000-8000-000000000007');
INSERT INTO volumen (id, nombre, precio, isbn, cantidad, poster_path, manga_id) VALUES ('b0b0b0b0-0000-4000-8000-000000007004', 'Chainsaw Man 4', 8.95, '9788407000004', 5, 'csm-04.jpg', 'a1b2c3d4-0000-4000-8000-000000000007');
INSERT INTO characters (id, name, age, description, image_url, manga_id) VALUES ('d0d0d0d0-0000-4000-8000-000000000011', 'Power', NULL, 'Demonio de la sangre, caótica y egocéntrica.', 'char-power.jpg', 'a1b2c3d4-0000-4000-8000-000000000007');

INSERT INTO manga (id, name, author, publisher, release_date, poster_path, description) VALUES ('a1b2c3d4-0000-4000-8000-000000000008', 'Spy×Family', 'Tatsuya Endō', 'Ivrea', '2019-07-04', 'sxf-01.jpg', 'El espía Twilight forma una familia falsa para cumplir su misión, sin saber que su hija adoptiva lee mentes y su esposa es una asesina profesional.');
INSERT INTO categories (manga_id, category_id) VALUES ('a1b2c3d4-0000-4000-8000-000000000008', 'c47e1a10-0000-4000-8000-000000000001');
INSERT INTO categories (manga_id, category_id) VALUES ('a1b2c3d4-0000-4000-8000-000000000008', 'c47e1a10-0000-4000-8000-000000000002');
INSERT INTO categories (manga_id, category_id) VALUES ('a1b2c3d4-0000-4000-8000-000000000008', 'c47e1a10-0000-4000-8000-000000000007');
INSERT INTO volumen (id, nombre, precio, isbn, cantidad, poster_path, manga_id) VALUES ('b0b0b0b0-0000-4000-8000-000000008001', 'Spy×Family 1', 9.00, '9788408000001', 28, 'sxf-01.jpg', 'a1b2c3d4-0000-4000-8000-000000000008');
INSERT INTO volumen (id, nombre, precio, isbn, cantidad, poster_path, manga_id) VALUES ('b0b0b0b0-0000-4000-8000-000000008002', 'Spy×Family 2', 9.00, '9788408000002', 21, 'sxf-02.jpg', 'a1b2c3d4-0000-4000-8000-000000000008');
INSERT INTO volumen (id, nombre, precio, isbn, cantidad, poster_path, manga_id) VALUES ('b0b0b0b0-0000-4000-8000-000000008003', 'Spy×Family 3', 9.00, '9788408000003', 13, 'sxf-03.jpg', 'a1b2c3d4-0000-4000-8000-000000000008');
INSERT INTO volumen (id, nombre, precio, isbn, cantidad, poster_path, manga_id) VALUES ('b0b0b0b0-0000-4000-8000-000000008004', 'Spy×Family 4', 9.00, '9788408000004', 6, 'sxf-04.jpg', 'a1b2c3d4-0000-4000-8000-000000000008');
INSERT INTO characters (id, name, age, description, image_url, manga_id) VALUES ('d0d0d0d0-0000-4000-8000-000000000012', 'Loid Forger', 27, 'El espía Twilight, padre de familia por encargo.', 'char-loid.jpg', 'a1b2c3d4-0000-4000-8000-000000000008');
INSERT INTO characters (id, name, age, description, image_url, manga_id) VALUES ('d0d0d0d0-0000-4000-8000-000000000013', 'Anya Forger', 6, 'Niña telépata adoptada por Loid.', 'char-anya.jpg', 'a1b2c3d4-0000-4000-8000-000000000008');
INSERT INTO characters (id, name, age, description, image_url, manga_id) VALUES ('d0d0d0d0-0000-4000-8000-000000000014', 'Yor Forger', 27, 'Funcionaria de día y asesina a sueldo de noche.', 'char-yor.jpg', 'a1b2c3d4-0000-4000-8000-000000000008');
