-- 1/ Les titres et dates de sortie des films du plus récent au plus ancien

SELECT movie_title, movie_release_date
FROM movies
ORDER BY movie_release_date DESC;

-- 2/ Les noms, prénoms et âges des acteurs/actrices de plus de 30 ans dans l'ordre alphabétique

SELECT person_first_name, person_last_name,
EXTRACT(YEAR FROM AGE(CURRENT_DATE, person_birthdate)) AS age
FROM persons
WHERE is_actor
AND EXTRACT(YEAR FROM AGE(CURRENT_DATE, person_birthdate)) > 30
ORDER BY person_last_name, person_first_name;

-- 3/ La liste des acteurs/actrices principaux pour un film donné

SELECT m.movie_titrle, p.person_first_name, p.person_last_name
FROM movies AS m
JOIN movie_persons AS mp ON m.movie_id = mp.movie_id
JOIN persons AS p ON mp.person_id = p.person_id
WHERE m.movie_title = 'Inception'
AND mp.is_main_actor;

-- 4/ La liste des films pour un acteur/actrice donné

SELECT CONCAT(p.person_first_name,' ', p.person_last_name) as actor, m.title
FROM movies as m
JOIN movie_persons as mp ON m.movie_id = mp.movie_id
JOIN persons as p ON mp.person_id = p.person_id
WHERE mp.is_actor
AND p.person_first_name = 'Brad' AND p.person_last_name = 'Pitt' --(ou p.person_id = 1234)
ORDER BY m.title;

-- 5/ Ajouter un film

INSERT INTO movies (created_by, movie_title, movie_release_date, movie_duration, movie_language)
VALUES (1, 'Titanic', '1998-01-07', 194, 'English');

-- 6/ Ajouter un acteur/actrice

INSERT INTO persons (person_first_name, person_last_name, person_birthdate, person_sex)
VALUES ('Jennifer', 'Lawrence', '1990-08-15', 'F');

-- 7/ Modifier un film

UPDATE movies
SET movie_studio = 'Warner Bros', movie_age_classification = 'Tous publics'
WHERE movie_title = 'Inception'; --(ou movie_id = 123)

-- 8/ Supprimer un acteur/actrice

DELETE FROM persons
WHERE person_first_name = 'Brad' AND person_last_name = 'Pitt'; --(ou person_id = 1234)

-- 9/ Afficher les 3 derniers acteurs/actrices ajouté(e)s

SELECT person_first_name, person_last_name
FROM persons
WHERE is_actor
ORDER BY created_at DESC
LIMIT 3;

-- 10/ Lister grâce à une procédure stockée les films d'un réalisateur donné en paramètre

-- 11/ Gérer les opérations de CRUD pour l'ajout d'un nouvel acteur au sein d'un film via des procédures stockées

-- 12/ Garder grâce à un trigger une trace de toutes les modifications apportées à la table des utilisateurs. Ainsi, une table d'archive conservera la date de la mise à jour, l'identifiant de l'utilisateur concerné, l'ancienne valeur ainsi que la nouvelle.

CREATE OR REPLACE FUNCTION log_update() RETURNS TRIGGER AS $$
	BEGIN
		IF NEW.user_name IS DISTINCT FROM OLD.user_name THEN
			INSERT INTO user_updates (user_id, updated_field, old_value, new_value)
			VALUES (NEW.user_id, 'user_name', OLD.user_name, NEW.user_name);
		END IF;
		IF NEW.user_mail IS DISTINCT FROM OLD.user_mail THEN
			INSERT INTO user_updates (user_id, updated_field, old_value, new_value)
			VALUES (NEW.user_id, 'user_mail', OLD.user_mail, NEW.user_mail);
		END IF;
		IF NEW.user_password IS DISTINCT FROM OLD.user_password THEN
			INSERT INTO user_updates (user_id, updated_field)
			VALUES (NEW.user_id, 'user_password');
		END IF;
		IF NEW.is_admin IS DISTINCT FROM OLD.is_admin THEN
			INSERT INTO user_updates (user_id, updated_field, old_value, new_value)
			VALUES (NEW.user_id, 'is_admin', OLD.is_admin::TEXT, NEW.is_admin::TEXT); -- car le champ est un varchar alors que is_admin est un booléen
		END IF;
		RETURN NEW;
	END;

$$ LANGUAGE plpgsql;

CREATE TRIGGER user_update_trigger
	AFTER UPDATE ON users
	FOR EACH ROW
	EXECUTE FUNCTION log_update();
