
INSERT INTO category (id, name, description ) VALUES ('ac1b039a866e153381866e298c1d0001', 'Shonen','El manga que va dirigido a los chicos adolescentes recibe el nombre de shōnen. Son series con grandes dosis de acción, en las que a menudo se dan situaciones humorísticas. Destaca el compañerismo entre miembros de un colectivo o de un equipo de combate');
INSERT INTO category (id, name, description ) VALUES ('ac1b039a866e153381866e298c1d0002', 'Seinen','El seinen.');

INSERT INTO manga (id, author, description, name, poster_path, publisher, release_date) VALUES ('ac1b039a866e153381866e298c1d0003','Masashi Kishimoto','Manga de ninjas','Jujutsu Kaisen','image2.jpg','Norma Editorial', '2020-03-03');
INSERT INTO manga (id, author, description, name, poster_path, publisher, release_date) VALUES('ac1b039a866e153381866e298c1d0004','Gege Akutami', 'Manga de hechizeros','Jujutsu Kaisen','image1.jpg','Norma Editorial','2020-04-04');
INSERT INTO manga (id, author, description, name, poster_path, publisher, release_date) VALUES('ac1b039a866e153381866e298c1d0005','Gege Akutami', 'Manga de hechizeros','Jujutsu Kaisen','image.jpg','Norma Editorial','2020-04-04');
INSERT INTO manga (id, author, description, name, poster_path, publisher, release_date) VALUES('ac1b039a866e153381866e298c1d0006','Gege Akutami', 'Manga de hechizeros','Jujutsu Kaisen','image3.jpg','Norma Editorial','2020-04-04');
INSERT INTO manga (id, author, description, name, poster_path, publisher, release_date) VALUES('ac1b039a866e153381866e298c1d0007','Gege Akutami', 'Manga de hechizeros','Jujutsu Kaisen','image4.webp','Norma Editorial','2020-04-04');
INSERT INTO manga (id, author, description, name, poster_path, publisher, release_date) VALUES('ac1b039a866e153381866e298c1d0008','Gege Akutami', 'Manga de hechizeros','Jujutsu Kaisen','image4.webp','Norma Editorial','2020-04-04');
INSERT INTO manga (id, author, description, name, poster_path, publisher, release_date) VALUES('ac1b039a866e153381866e298c1d0009','Gege Akutami', 'Manga de hechizeros','Jujutsu Kaisen','image5.jpeg','Norma Editorial','2020-04-04');
INSERT INTO manga (id, author, description, name, poster_path, publisher, release_date) VALUES('ac1b039a866e153381866e298c1d0010','Gege Akutami', 'Manga de hechizeros','Jujutsu Kaisen','image6.jpeg','Norma Editorial','2020-04-04');
INSERT INTO manga (id, author, description, name, poster_path, publisher, release_date) VALUES('ac1b039a866e153381866e298c1d0011','Gege Akutami', 'Manga de hechizeros','Jujutsu Kaisen','image7.jpg','Norma Editorial','2020-04-04');
INSERT INTO manga (id, author, description, name, poster_path, publisher, release_date) VALUES('ac1b039a866e153381866e298c1d0012','Gege Akutami', 'Manga de hechizeros','Jujutsu Kaisen','image8.jpg','Norma Editorial','2020-04-04');
INSERT INTO manga (id, author, description, name, poster_path, publisher, release_date) VALUES('ac1b039a866e153381866e298c1d0013','Gege Akutami', 'Manga de hechizeros','Jujutsu Kaisen','image7.jpeg','Norma Editorial','2020-04-04');
INSERT INTO manga (id, author, description, name, poster_path, publisher, release_date) VALUES('ac1b039a866e153381866e298c1d0014','Gege Akutami', 'Manga de hechizeros','Jujutsu Kaisen','image9.jpg','Norma Editorial','2020-04-04');


INSERT INTO users (id, username, password, full_name, email, image, account_non_expired, account_non_locked, credentials_non_expired, enabled, created_at,role) VALUES ('1ed3d641-b9e8-4a8b-bf13-f6caef2e36ce', 'admin', '{bcrypt}$2a$12$1hfnQew5F5qsdr5u/qbIze7/jt1asO58g8YmxJZeIKew8gWnYyyky', 'admin', 'admin@admin.admin', 'https://i.ibb.co/stxTwKC/user.png', true, true, true, true, '2022-02-01','1');
INSERT INTO users (id, username, password, full_name, email, image, account_non_expired, account_non_locked, credentials_non_expired, enabled, created_at,role) VALUES ('1ed3d641-b9e8-4a8b-bf13-f6caef2e37ce', 'user', '{bcrypt}$2a$12$e53KEezkDm.zogcBWKwgeO.rgqrsOnWJQ1nmLTf79wsnVJ4Dcq.kW', 'user', 'user@admin.admin', 'https://i.ibb.co/stxTwKC/user.png', true, true, true, true, '2022-02-01','1');


INSERT INTO categories(manga_id, category_id)VALUES ('ac1b039a866e153381866e298c1d0003','ac1b039a866e153381866e298c1d0001');
INSERT INTO categories(manga_id, category_id)VALUES ('ac1b039a866e153381866e298c1d0004','ac1b039a866e153381866e298c1d0001');
INSERT INTO categories(manga_id, category_id)VALUES ('ac1b039a866e153381866e298c1d0005','ac1b039a866e153381866e298c1d0001');
INSERT INTO categories(manga_id, category_id)VALUES ('ac1b039a866e153381866e298c1d0009','ac1b039a866e153381866e298c1d0001');
INSERT INTO categories(manga_id, category_id)VALUES ('ac1b039a866e153381866e298c1d0010','ac1b039a866e153381866e298c1d0001');
INSERT INTO categories(manga_id, category_id)VALUES ('ac1b039a866e153381866e298c1d0011','ac1b039a866e153381866e298c1d0001');
INSERT INTO categories(manga_id, category_id)VALUES ('ac1b039a866e153381866e298c1d0012','ac1b039a866e153381866e298c1d0001');

INSERT INTO categories(manga_id, category_id)VALUES ('ac1b039a866e153381866e298c1d0006','ac1b039a866e153381866e298c1d0002');
INSERT INTO categories(manga_id, category_id)VALUES ('ac1b039a866e153381866e298c1d0007','ac1b039a866e153381866e298c1d0002');
INSERT INTO categories(manga_id, category_id)VALUES ('ac1b039a866e153381866e298c1d0008','ac1b039a866e153381866e298c1d0002');
INSERT INTO categories(manga_id, category_id)VALUES ('ac1b039a866e153381866e298c1d0013','ac1b039a866e153381866e298c1d0002');
INSERT INTO categories(manga_id, category_id)VALUES ('ac1b039a866e153381866e298c1d0014','ac1b039a866e153381866e298c1d0002');