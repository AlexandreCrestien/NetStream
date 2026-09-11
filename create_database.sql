CREATE DATABASE netstream;

\c netstream

CREATE TYPE user_update AS ENUM ('name', 'mail', 'password');
CREATE TYPE movie_langage AS ENUM ('FRENCH', 'ENGLISH', 'PORTUGUESE');
CREATE TYPE movie_studio AS ENUM ('Disney', 'Netflix', 'CANAL+');
CREATE TYPE movie_age AS ENUM ('+6', '+12', '+16', '+18');
CREATE TYPE person_genre AS ENUM ('MALE', 'FEMALE', 'OTHER');
CREATE TYPE person_update AS ENUM ('name', 'lastname', 'birth_date');
CREATE TYPE movie_update AS ENUM ('title', 'synopsis', 'duration');

CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    is_admin BOOLEAN DEFAULT FALSE ,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_name VARCHAR(50) UNIQUE NOT NULL,
    user_mail VARCHAR(100) UNIQUE NOT NULL,
    user_password VARCHAR(255) NOT NULL
);

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
    movie_age_classification movie_age DEFAULT '+6',
    movie_favorites INTEGER
);

CREATE TABLE persons (
    person_id SERIAL PRIMARY KEY,
    created_by INT NOT NULL REFERENCES users(user_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    person_first_name varchar(30) NOT NULL,
    person_last_name varchar(30) NOT NULL,
    person_birthdate date,
    person_sex person_genre,
    is_actor boolean DEFAULT FALSE,
    is_director boolean DEFAULT FALSE,
    user_favorites INTEGER
);

CREATE TABLE user_updates (
    user_update_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(user_id),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_field user_update NOT NULL,
    old_value varchar(100),
    new_value varchar(100)
);

CREATE TABLE person_updates (
    person_update_id SERIAL PRIMARY KEY,
    update_by INT NOT NULL REFERENCES users(user_id),
    person_id INT NOT NULL REFERENCES persons(person_id),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_field person_update NOT NULL
);

CREATE TABLE movie_updates (
    movie_update_id SERIAL PRIMARY KEY,
    update_by INT NOT NULL REFERENCES users(user_id),
    movie_id INT NOT NULL REFERENCES movies(movie_id),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_field movie_update NOT NULL
);

CREATE TABLE user_favorite_persons (
    user_id INT NOT NULL REFERENCES users(user_id),
    person_id INT NOT NULL REFERENCES persons(person_id)
);

CREATE TABLE movie_reviews(
    user_id INT NOT NULL REFERENCES users(user_id),
    movie_id INT NOT NULL REFERENCES movies(movie_id),
    user_rating SMALLINT CHECK (user_rating BETWEEN 0 AND 5),
    user_comment text,
    user_favorite_movie boolean DEFAULT FALSE
);

CREATE TABLE movie_persons (
    movie_id INT NOT NULL REFERENCES movies(movie_id),
    person_id INT NOT NULL REFERENCES persons(person_id),
    person_movie_job varchar(30),
    actor_movie_role varchar(200),
    is_main_actor boolean DEFAULT FALSE
);

CREATE TABLE genres (
    genre_id SERIAL PRIMARY KEY,
    created_by INT NOT NULL REFERENCES users(user_id),
    genre_name varchar(50),
    movies_number integer,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE movie_genres (
    genre_id INT NOT NULL REFERENCES genres(genre_id),
    movie_id INT NOT NULL REFERENCES movies(movie_id)
);