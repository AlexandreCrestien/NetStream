-- ============================================================
--  NetStream — Données de test (seed)
--  À exécuter APRÈS la création de la base (create_database.sql).
--  Hypothèse : base fraîche, donc l'utilisateur 'admin' sera user_id = 1.
--  Toutes les valeurs respectent tes ENUM :
--    movie_langage : FRENCH / ENGLISH / PORTUGUESE
--    movie_studio  : Disney / Netflix / CANAL+ / Warner Bros
--    movie_age     : Tous publics / +6 / +12 / +16 / +18
--    person_genre  : M / F / OTHER
-- ============================================================


-- ------------------------------------------------------------
-- 1) UTILISATEURS  (créés en premier : tout dépend d'eux via created_by)
-- ------------------------------------------------------------
INSERT INTO users (is_admin, user_name, user_mail, user_password) VALUES
(TRUE,  'admin', 'admin@netstream.com', 'hash_admin'),
(FALSE, 'alice', 'alice@netstream.com', 'hash_alice'),
(FALSE, 'bob',   'bob@netstream.com',   'hash_bob');


-- ------------------------------------------------------------
-- 2) PERSONNES  (réalisateurs + acteurs)
--    created_by = 1  -> l'utilisateur admin
--    Réalisateurs : is_director = TRUE
--    Acteurs      : is_actor = TRUE
--    Dates de naissance variées pour tester le filtre "plus de 30 ans".
-- ------------------------------------------------------------

-- Réalisateurs
INSERT INTO persons (created_by, person_first_name, person_last_name, person_birthdate, person_sex, is_director) VALUES
(1, 'Christopher', 'Nolan',     '1970-07-30', 'M', TRUE),
(1, 'Steven',      'Spielberg', '1946-12-18', 'M', TRUE),
(1, 'David',       'Fincher',   '1962-08-28', 'M', TRUE),
(1, 'Quentin',     'Tarantino', '1963-03-27', 'M', TRUE),
(1, 'Jean-Pierre', 'Jeunet',    '1953-09-03', 'M', TRUE),
(1, 'Fernando',    'Meirelles', '1955-11-09', 'M', TRUE);

-- Acteurs / actrices
INSERT INTO persons (created_by, person_first_name, person_last_name, person_birthdate, person_sex, is_actor) VALUES
(1, 'Brad',    'Pitt',         '1963-12-18', 'M', TRUE),
(1, 'Leonardo','DiCaprio',     '1974-11-11', 'M', TRUE),
(1, 'Morgan',  'Freeman',      '1937-06-01', 'M', TRUE),
(1, 'Marion',  'Cotillard',    '1975-09-30', 'F', TRUE),
(1, 'Tom',     'Hardy',        '1977-09-15', 'M', TRUE),
(1, 'Joseph',  'Gordon-Levitt','1981-02-20', 'M', TRUE),
(1, 'Michael', 'Caine',        '1933-03-14', 'M', TRUE),
(1, 'Audrey',  'Tautou',       '1976-08-09', 'F', TRUE),
(1, 'Matthew', 'McConaughey',  '1969-11-04', 'M', TRUE),
(1, 'Anne',    'Hathaway',     '1982-11-12', 'F', TRUE),
(1, 'Edward',  'Norton',       '1969-08-18', 'M', TRUE),
(1, 'Jacob',   'Elordi',       '1997-06-26', 'M', TRUE);   -- < 30 ans : doit être EXCLU par la requête 2


-- ------------------------------------------------------------
-- 3) FILMS
--    created_by = 1
--    Langues, studios et classifications choisis dans tes ENUM.
-- ------------------------------------------------------------
INSERT INTO movies
(created_by, movie_title, movie_release_date, movie_duration, movie_language, movie_synopsis, movie_rating, movie_studio, movie_age_classification) VALUES
(1, 'Inception',                      '2010-07-16', 148, 'ENGLISH',    'Un voleur s''infiltre dans les rêves pour voler des secrets.',           4.80, 'Warner Bros', '+12'),
(1, 'Fight Club',                     '1999-11-11', 139, 'ENGLISH',    'Un employé insomniaque fonde un club de combat clandestin.',            4.70, 'CANAL+',      '+16'),
(1, 'Se7en',                          '1995-09-22', 127, 'ENGLISH',    'Deux inspecteurs traquent un tueur en série inspiré des péchés capitaux.', 4.60, 'Warner Bros', '+16'),
(1, 'Jurassic Park',                  '1993-06-11', 127, 'ENGLISH',    'Des dinosaures clonés sèment le chaos dans un parc d''attractions.',      4.50, 'Disney',      '+12'),
(1, 'City of God',                    '2002-08-30', 130, 'PORTUGUESE', 'La montée de la violence dans une favela de Rio.',                       4.70, 'Netflix',     '+18'),
(1, 'Amélie',                         '2001-04-25', 122, 'FRENCH',     'Une jeune serveuse parisienne décide de changer la vie des autres.',      4.40, 'CANAL+',      '+6'),
(1, 'Interstellar',                   '2014-11-05', 169, 'ENGLISH',    'Des explorateurs franchissent un trou de ver pour sauver l''humanité.',   4.60, 'Warner Bros', '+6'),
(1, 'E.T.',                           '1982-12-03', 115, 'ENGLISH',    'Un enfant se lie d''amitié avec un extraterrestre égaré sur Terre.',      4.30, 'Disney',      'Tous publics'),
(1, 'Schindler''s List',              '1994-03-11', 195, 'ENGLISH',    'Un industriel sauve des centaines de Juifs pendant la Shoah.',           4.90, 'Netflix',     '+16'),
(1, 'Once Upon a Time in Hollywood',  '2019-08-14', 161, 'ENGLISH',    'Un acteur sur le déclin et sa doublure dans le Hollywood de 1969.',      4.20, 'CANAL+',      '+16');


-- ------------------------------------------------------------
-- 4) LIAISONS FILMS <-> PERSONNES  (table movie_persons)
--    On retrouve les IDs par les noms (robuste : l'ordre des IDs n'importe pas).
--    Réalisateur : job 'Director', is_main_actor = FALSE
--    Acteur      : job 'Actor',    is_main_actor = TRUE (sauf Michael Caine, second rôle)
-- ------------------------------------------------------------
INSERT INTO movie_persons (movie_id, person_id, person_movie_job, actor_movie_role, is_main_actor) VALUES
-- Inception
((SELECT movie_id FROM movies WHERE movie_title='Inception'), (SELECT person_id FROM persons WHERE person_first_name='Christopher' AND person_last_name='Nolan'),      'Director', NULL,          FALSE),
((SELECT movie_id FROM movies WHERE movie_title='Inception'), (SELECT person_id FROM persons WHERE person_first_name='Leonardo'    AND person_last_name='DiCaprio'),   'Actor',    'Dom Cobb',    TRUE),
((SELECT movie_id FROM movies WHERE movie_title='Inception'), (SELECT person_id FROM persons WHERE person_first_name='Marion'      AND person_last_name='Cotillard'),  'Actor',    'Mal',         TRUE),
((SELECT movie_id FROM movies WHERE movie_title='Inception'), (SELECT person_id FROM persons WHERE person_first_name='Tom'         AND person_last_name='Hardy'),      'Actor',    'Eames',       TRUE),
((SELECT movie_id FROM movies WHERE movie_title='Inception'), (SELECT person_id FROM persons WHERE person_first_name='Joseph'      AND person_last_name='Gordon-Levitt'),'Actor',  'Arthur',      TRUE),
((SELECT movie_id FROM movies WHERE movie_title='Inception'), (SELECT person_id FROM persons WHERE person_first_name='Michael'     AND person_last_name='Caine'),      'Actor',    'Miles',       FALSE), -- second rôle : exclu par la requête 3

-- Fight Club
((SELECT movie_id FROM movies WHERE movie_title='Fight Club'), (SELECT person_id FROM persons WHERE person_first_name='David'  AND person_last_name='Fincher'), 'Director', NULL,            FALSE),
((SELECT movie_id FROM movies WHERE movie_title='Fight Club'), (SELECT person_id FROM persons WHERE person_first_name='Brad'   AND person_last_name='Pitt'),    'Actor',    'Tyler Durden',  TRUE),
((SELECT movie_id FROM movies WHERE movie_title='Fight Club'), (SELECT person_id FROM persons WHERE person_first_name='Edward' AND person_last_name='Norton'),  'Actor',    'Le narrateur',  TRUE),

-- Se7en
((SELECT movie_id FROM movies WHERE movie_title='Se7en'), (SELECT person_id FROM persons WHERE person_first_name='David'  AND person_last_name='Fincher'), 'Director', NULL,                  FALSE),
((SELECT movie_id FROM movies WHERE movie_title='Se7en'), (SELECT person_id FROM persons WHERE person_first_name='Brad'   AND person_last_name='Pitt'),    'Actor',    'Inspecteur Mills',    TRUE),
((SELECT movie_id FROM movies WHERE movie_title='Se7en'), (SELECT person_id FROM persons WHERE person_first_name='Morgan' AND person_last_name='Freeman'), 'Actor',    'Inspecteur Somerset', TRUE),

-- Jurassic Park
((SELECT movie_id FROM movies WHERE movie_title='Jurassic Park'), (SELECT person_id FROM persons WHERE person_first_name='Steven' AND person_last_name='Spielberg'), 'Director', NULL, FALSE),

-- City of God
((SELECT movie_id FROM movies WHERE movie_title='City of God'), (SELECT person_id FROM persons WHERE person_first_name='Fernando' AND person_last_name='Meirelles'), 'Director', NULL, FALSE),

-- Amélie
((SELECT movie_id FROM movies WHERE movie_title='Amélie'), (SELECT person_id FROM persons WHERE person_first_name='Jean-Pierre' AND person_last_name='Jeunet'), 'Director', NULL,              FALSE),
((SELECT movie_id FROM movies WHERE movie_title='Amélie'), (SELECT person_id FROM persons WHERE person_first_name='Audrey'      AND person_last_name='Tautou'), 'Actor',    'Amélie Poulain',  TRUE),

-- Interstellar
((SELECT movie_id FROM movies WHERE movie_title='Interstellar'), (SELECT person_id FROM persons WHERE person_first_name='Christopher' AND person_last_name='Nolan'),       'Director', NULL,      FALSE),
((SELECT movie_id FROM movies WHERE movie_title='Interstellar'), (SELECT person_id FROM persons WHERE person_first_name='Matthew'     AND person_last_name='McConaughey'), 'Actor',    'Cooper',  TRUE),
((SELECT movie_id FROM movies WHERE movie_title='Interstellar'), (SELECT person_id FROM persons WHERE person_first_name='Anne'        AND person_last_name='Hathaway'),    'Actor',    'Brand',   TRUE),

-- E.T.
((SELECT movie_id FROM movies WHERE movie_title='E.T.'), (SELECT person_id FROM persons WHERE person_first_name='Steven' AND person_last_name='Spielberg'), 'Director', NULL, FALSE),

-- Schindler's List
((SELECT movie_id FROM movies WHERE movie_title='Schindler''s List'), (SELECT person_id FROM persons WHERE person_first_name='Steven' AND person_last_name='Spielberg'), 'Director', NULL, FALSE),

-- Once Upon a Time in Hollywood
((SELECT movie_id FROM movies WHERE movie_title='Once Upon a Time in Hollywood'), (SELECT person_id FROM persons WHERE person_first_name='Quentin'  AND person_last_name='Tarantino'), 'Director', NULL,          FALSE),
((SELECT movie_id FROM movies WHERE movie_title='Once Upon a Time in Hollywood'), (SELECT person_id FROM persons WHERE person_first_name='Brad'     AND person_last_name='Pitt'),      'Actor',    'Cliff Booth', TRUE),
((SELECT movie_id FROM movies WHERE movie_title='Once Upon a Time in Hollywood'), (SELECT person_id FROM persons WHERE person_first_name='Leonardo' AND person_last_name='DiCaprio'),  'Actor',    'Rick Dalton', TRUE);


-- ============================================================
--  BONUS : genres, notes et favoris (pour remplir tout le schéma)
--  Aucune des 12 requêtes n'en a besoin, mais ça exerce les autres tables.
-- ============================================================

-- ------------------------------------------------------------
-- 5) GENRES
-- ------------------------------------------------------------
INSERT INTO genres (created_by, genre_name) VALUES
(1, 'Science-Fiction'),
(1, 'Drame'),
(1, 'Thriller'),
(1, 'Comédie'),
(1, 'Crime');

-- ------------------------------------------------------------
-- 6) LIAISONS FILMS <-> GENRES
-- ------------------------------------------------------------
INSERT INTO movie_genres (genre_id, movie_id) VALUES
((SELECT genre_id FROM genres WHERE genre_name='Science-Fiction'), (SELECT movie_id FROM movies WHERE movie_title='Inception')),
((SELECT genre_id FROM genres WHERE genre_name='Thriller'),        (SELECT movie_id FROM movies WHERE movie_title='Inception')),
((SELECT genre_id FROM genres WHERE genre_name='Science-Fiction'), (SELECT movie_id FROM movies WHERE movie_title='Interstellar')),
((SELECT genre_id FROM genres WHERE genre_name='Drame'),           (SELECT movie_id FROM movies WHERE movie_title='Interstellar')),
((SELECT genre_id FROM genres WHERE genre_name='Drame'),           (SELECT movie_id FROM movies WHERE movie_title='Fight Club')),
((SELECT genre_id FROM genres WHERE genre_name='Thriller'),        (SELECT movie_id FROM movies WHERE movie_title='Fight Club')),
((SELECT genre_id FROM genres WHERE genre_name='Thriller'),        (SELECT movie_id FROM movies WHERE movie_title='Se7en')),
((SELECT genre_id FROM genres WHERE genre_name='Crime'),           (SELECT movie_id FROM movies WHERE movie_title='Se7en')),
((SELECT genre_id FROM genres WHERE genre_name='Comédie'),         (SELECT movie_id FROM movies WHERE movie_title='Amélie')),
((SELECT genre_id FROM genres WHERE genre_name='Crime'),           (SELECT movie_id FROM movies WHERE movie_title='City of God')),
((SELECT genre_id FROM genres WHERE genre_name='Drame'),           (SELECT movie_id FROM movies WHERE movie_title='City of God')),
((SELECT genre_id FROM genres WHERE genre_name='Drame'),           (SELECT movie_id FROM movies WHERE movie_title='Once Upon a Time in Hollywood'));

-- ------------------------------------------------------------
-- 7) NOTES / AVIS  (movie_reviews)  — PK (user_id, movie_id)
-- ------------------------------------------------------------
INSERT INTO movie_reviews (user_id, movie_id, user_rating, user_comment, user_favorite_movie) VALUES
((SELECT user_id FROM users WHERE user_name='alice'), (SELECT movie_id FROM movies WHERE movie_title='Inception'), 5, 'Un chef-d''œuvre.',      TRUE),
((SELECT user_id FROM users WHERE user_name='alice'), (SELECT movie_id FROM movies WHERE movie_title='Amélie'),    4, 'Très poétique.',         FALSE),
((SELECT user_id FROM users WHERE user_name='bob'),   (SELECT movie_id FROM movies WHERE movie_title='Inception'), 4, 'Complexe mais génial.',  FALSE),
((SELECT user_id FROM users WHERE user_name='bob'),   (SELECT movie_id FROM movies WHERE movie_title='Se7en'),     5, 'Fin inoubliable.',       TRUE);

-- ------------------------------------------------------------
-- 8) PERSONNES FAVORITES  (user_favorite_persons)  — PK (user_id, person_id)
-- ------------------------------------------------------------
INSERT INTO user_favorite_persons (user_id, person_id) VALUES
((SELECT user_id FROM users WHERE user_name='alice'), (SELECT person_id FROM persons WHERE person_first_name='Leonardo' AND person_last_name='DiCaprio')),
((SELECT user_id FROM users WHERE user_name='alice'), (SELECT person_id FROM persons WHERE person_first_name='Marion'   AND person_last_name='Cotillard')),
((SELECT user_id FROM users WHERE user_name='bob'),   (SELECT person_id FROM persons WHERE person_first_name='Brad'     AND person_last_name='Pitt'));
