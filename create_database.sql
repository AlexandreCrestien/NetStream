-- Supprime puis recree la base.
DROP DATABASE IF EXISTS netstream;
CREATE DATABASE netstream;

-- Connexion a la base.
\c netstream

-- Champs modifiables d'un user.
CREATE TYPE user_update AS ENUM ('user_name', 'user_mail', 'user_password', 'is_admin');

-- Langue du film.
CREATE TYPE movie_langage AS ENUM ('french', 'english', 'portuguese');

-- Studio du film.
CREATE TYPE movie_studio AS ENUM ('Disney', 'Netflix', 'CANAL+', 'Warner Bros');

-- Age conseille.
CREATE TYPE movie_age AS ENUM ('all_ages', '+6', '+12', '+16', '+18');

-- Sexe (M/F/Other).
CREATE TYPE person_genre AS ENUM ('M', 'F', 'O');

-- Champs modifiables d'une personne.
CREATE TYPE person_update AS ENUM ('person_name', 'person_last_name', 'person_birthdate');

-- Champs modifiables d'un film.
CREATE TYPE movie_update AS ENUM ('title', 'synopsis', 'duration');

-- Table des utilisateurs.
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    is_admin BOOLEAN DEFAULT FALSE ,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_name VARCHAR(50) UNIQUE NOT NULL,
    user_mail VARCHAR(100) UNIQUE NOT NULL,
    user_password VARCHAR(255) NOT NULL
);

-- Table des films.
CREATE TABLE movies (
    movie_id SERIAL PRIMARY KEY,
    created_by INT NOT NULL REFERENCES users(user_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    movie_title varchar(180) NOT NULL,
    movie_release_date date NOT NULL,
    movie_duration smallint,
    movie_language movie_langage,
    movie_synopsis text,
    movie_rating decimal(3,2),
    movie_studio movie_studio,
    movie_age_classification movie_age DEFAULT '+6'
);

-- Table des Acteurs et realisateurs.
CREATE TABLE persons (
    person_id SERIAL PRIMARY KEY,
    created_by INT NOT NULL REFERENCES users(user_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    person_first_name varchar(30) NOT NULL,
    person_last_name varchar(30) NOT NULL,
    person_birthdate date,
    person_sex person_genre,
    is_actor boolean DEFAULT FALSE,
    is_director boolean DEFAULT FALSE
);

-- Historique des users.
CREATE TABLE user_updates (
    user_update_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(user_id),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_field user_update NOT NULL,
    old_value varchar(100),
    new_value varchar(100)
);

-- Historique des personnes.
CREATE TABLE person_updates (
    person_update_id SERIAL PRIMARY KEY,
    update_by INT NOT NULL REFERENCES users(user_id),
    person_id INT NOT NULL REFERENCES persons(person_id),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_field person_update NOT NULL
);

-- Historique des films.
CREATE TABLE movie_updates (
    movie_update_id SERIAL PRIMARY KEY,
    update_by INT NOT NULL REFERENCES users(user_id),
    movie_id INT NOT NULL REFERENCES movies(movie_id),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_field movie_update NOT NULL
);

-- Personnes favorites d'un user.
CREATE TABLE user_favorite_persons (
    user_id INT NOT NULL REFERENCES users(user_id),
    person_id INT NOT NULL REFERENCES persons(person_id),
    PRIMARY KEY (user_id, person_id)
);

-- Avis sur un film d'un user.
CREATE TABLE movie_reviews(
    user_id INT NOT NULL REFERENCES users(user_id),
    movie_id INT NOT NULL REFERENCES movies(movie_id),
    user_rating SMALLINT CHECK (user_rating BETWEEN 0 AND 5),
    user_comment text,
    user_favorite_movie boolean DEFAULT FALSE,
    PRIMARY KEY (user_id, movie_id)
);

-- Personnes liees aux films.
CREATE TABLE movie_persons (
    movie_id INT NOT NULL REFERENCES movies(movie_id),
    person_id INT NOT NULL REFERENCES persons(person_id),
    person_movie_job varchar(30),
    actor_movie_role varchar(200),
    is_main_actor boolean DEFAULT FALSE
);

-- Les genres de film.
CREATE TABLE genres (
    genre_id SERIAL PRIMARY KEY,
    created_by INT NOT NULL REFERENCES users(user_id),
    genre_name varchar(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Lien film <-> genre.
CREATE TABLE movie_genres (
    genre_id INT NOT NULL REFERENCES genres(genre_id),
    movie_id INT NOT NULL REFERENCES movies(movie_id),
    PRIMARY KEY (movie_id, genre_id)
);


--DONNEES DE TEST 

-- Users (edilene = admin, id 1).
INSERT INTO users (is_admin, user_name, user_mail, user_password) VALUES
(TRUE, 'edilene', 'edilene@netstream.com', 'hash_edilene'),
(FALSE, 'flora', 'flora@netstream.com', 'hash_flora'),
(FALSE, 'alex', 'alex@netstream.com', 'hash_alex');

-- Realisateurs.
INSERT INTO persons (created_by, person_first_name, person_last_name, person_birthdate, person_sex, is_director) VALUES
(1, 'Christopher', 'Nolan', '1970-07-30', 'M', TRUE),
(1, 'Steven', 'Spielberg', '1946-12-18', 'M', TRUE),
(1, 'Jon', 'Watts', '1981-06-28', 'M', TRUE);

-- Acteurs.
INSERT INTO persons (created_by, person_first_name, person_last_name, person_birthdate, person_sex, is_actor) VALUES
(1, 'Matt', 'Damon', '1970-10-08', 'M', TRUE),
(1, 'Tom', 'Holland', '1996-06-01', 'M', TRUE),
(1, 'Zendaya', 'Coleman', '1996-09-01', 'F', TRUE),
(1, 'Anne', 'Hathaway', '1982-11-12', 'F', TRUE);

-- Films.
INSERT INTO movies
(created_by, movie_title, movie_release_date, movie_duration, movie_language, movie_synopsis, movie_studio, movie_age_classification) VALUES
(1, 'The Odyssey', '2026-07-17', 173, 'english', 'Grand cheval a Troie', 'Warner Bros', '+12'),
(1, 'Spider-Man: Homecoming', '2017-07-05', 133, 'english', 'spidermannnn', 'Disney', '+6'),
(1, 'Jurassic Park', '1993-06-11', 127, 'english', 'tintintin tin tintintin ', 'Disney', '+12');

-- Casting et equipe.
INSERT INTO movie_persons (movie_id, person_id, person_movie_job, actor_movie_role, is_main_actor) VALUES
((SELECT movie_id FROM movies WHERE movie_title='The Odyssey'), (SELECT person_id FROM persons WHERE person_first_name='Christopher' AND person_last_name='Nolan'), 'director', NULL, FALSE),
((SELECT movie_id FROM movies WHERE movie_title='The Odyssey'), (SELECT person_id FROM persons WHERE person_first_name='Matt' AND person_last_name='Damon'), 'actor', 'Ulysse', TRUE),
((SELECT movie_id FROM movies WHERE movie_title='The Odyssey'), (SELECT person_id FROM persons WHERE person_first_name='Tom' AND person_last_name='Holland'), 'actor', 'Telemaque', TRUE),
((SELECT movie_id FROM movies WHERE movie_title='The Odyssey'), (SELECT person_id FROM persons WHERE person_first_name='Zendaya' AND person_last_name='Coleman'), 'actor', 'Athena', TRUE),
((SELECT movie_id FROM movies WHERE movie_title='The Odyssey'), (SELECT person_id FROM persons WHERE person_first_name='Anne' AND person_last_name='Hathaway'), 'actor', 'Penelope', FALSE),
((SELECT movie_id FROM movies WHERE movie_title='Spider-Man: Homecoming'), (SELECT person_id FROM persons WHERE person_first_name='Jon' AND person_last_name='Watts'), 'director', NULL, FALSE),
((SELECT movie_id FROM movies WHERE movie_title='Spider-Man: Homecoming'), (SELECT person_id FROM persons WHERE person_first_name='Tom' AND person_last_name='Holland'), 'actor', 'Peter Parker', TRUE),
((SELECT movie_id FROM movies WHERE movie_title='Spider-Man: Homecoming'), (SELECT person_id FROM persons WHERE person_first_name='Zendaya' AND person_last_name='Coleman'), 'actor', 'MJ', TRUE),
((SELECT movie_id FROM movies WHERE movie_title='Jurassic Park'), (SELECT person_id FROM persons WHERE person_first_name='Steven' AND person_last_name='Spielberg'), 'director', NULL, FALSE);