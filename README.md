# NetStream — Base de données

Base de données PostgreSQL pour NetStream, une plateforme de streaming (films, séries, documentaires). Elle stocke les films, les acteurs, les réalisateurs, leurs rôles et les préférences des utilisateurs.

## Prérequis

- PostgreSQL installé (version 16 recommandée)

## Installation

Le fichier `create_database.sql` crée la base, les tables et insère quelques données de test.

Depuis un terminal :

```bash
sudo -u postgres psql -f create_database.sql
```

La base `netstream` est alors créée et prête à l'emploi.

> Le script commence par `DROP DATABASE IF EXISTS netstream;` : il supprime la base existante avant de la recréer. Pense à fermer toute connexion à `netstream` (DBeaver, etc.) avant de le lancer.

Pour te connecter ensuite à la base :

```bash
sudo -u postgres psql -d netstream
```

---

## Requêtes

### 1. Les titres et dates de sortie des films du plus récent au plus ancien

```sql
SELECT movie_title, movie_release_date
FROM movies
ORDER BY movie_release_date DESC;
```

### 2. Les noms, prénoms et âges des acteurs/actrices de plus de 30 ans dans l'ordre alphabétique

```sql
SELECT person_first_name, person_last_name,
EXTRACT(YEAR FROM AGE(CURRENT_DATE, person_birthdate)) AS age
FROM persons
WHERE is_actor
AND EXTRACT(YEAR FROM AGE(CURRENT_DATE, person_birthdate)) > 30
ORDER BY person_last_name, person_first_name;
```

### 3. La liste des acteurs/actrices principaux pour un film donné

```sql
SELECT m.movie_title, p.person_first_name, p.person_last_name
FROM movies AS m
JOIN movie_persons AS mp ON m.movie_id = mp.movie_id
JOIN persons AS p ON mp.person_id = p.person_id
WHERE m.movie_title = 'The Odyssey'
AND mp.is_main_actor;
```

### 4. La liste des films pour un acteur/actrice donné

```sql
SELECT CONCAT(p.person_first_name,' ', p.person_last_name) as actor, m.movie_title
FROM movies as m
JOIN movie_persons as mp ON m.movie_id = mp.movie_id
JOIN persons as p ON mp.person_id = p.person_id
WHERE mp.person_movie_job = 'actor'
AND p.person_first_name = 'Tom' AND p.person_last_name = 'Holland' --(ou p.person_id = 1234)
ORDER BY m.movie_title;
```

### 5. Ajouter un film

```sql
INSERT INTO movies (created_by, movie_title, movie_release_date, movie_duration, movie_language)
VALUES (1, 'Titanic', '1998-01-07', 194, 'english');
```

### 6. Ajouter un acteur/actrice

```sql
INSERT INTO persons (created_by, person_first_name, person_last_name, person_birthdate, person_sex, is_actor)
VALUES (1, 'Jennifer', 'Lawrence', '1990-08-15', 'F', TRUE);
```

### 7. Modifier un film

```sql
UPDATE movies
SET movie_studio = 'Warner Bros', movie_age_classification = 'all_ages'
WHERE movie_title = 'The Odyssey'; --(ou movie_id = 123)
```

### 8. Supprimer un acteur/actrice

```sql
DELETE FROM movie_persons
WHERE person_id = (SELECT person_id FROM persons
                   WHERE person_first_name = 'Anne' AND person_last_name = 'Hathaway');
DELETE FROM user_favorite_persons
WHERE person_id = (SELECT person_id FROM persons
                   WHERE person_first_name = 'Anne' AND person_last_name = 'Hathaway');
DELETE FROM persons
WHERE person_first_name = 'Anne' AND person_last_name = 'Hathaway'; --(ou person_id = 1234)
```

### 9. Afficher les 3 derniers acteurs/actrices ajouté(e)s

```sql
SELECT person_first_name, person_last_name
FROM persons
WHERE is_actor
ORDER BY created_at DESC
LIMIT 3;
```

### 10. Lister grâce à une procédure stockée les films d'un réalisateur donné

```sql
CREATE OR REPLACE PROCEDURE ListDirectorFilms(
    director_first_name varchar,
    director_last_name varchar,
    INOUT result refcursor
)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN result FOR
    SELECT m.movie_title
    FROM persons AS p
    JOIN movie_persons AS mp
        ON p.person_id = mp.person_id
    JOIN movies AS m
        ON mp.movie_id = m.movie_id
    WHERE p.is_director = TRUE
      AND p.person_first_name = director_first_name
      AND p.person_last_name = director_last_name;
END;
$$;

-- pour appeler et montrer le résultat:
BEGIN;
CALL ListDirectorFilms('Steven', 'Spielberg', 'liste_de_films');
FETCH ALL FROM liste_de_films;
COMMIT;
```

### 11. CRUD d'un acteur dans un film via des procédures stockées

```sql
CREATE OR REPLACE PROCEDURE AddNewActorToMovie(
	p_created_by     int,
    p_first_name     varchar,
    p_last_name      varchar,
    p_birthdate      date,
    p_sex            varchar,
    p_movie_id       int,
    p_actor_role     varchar,
    p_is_main_actor  boolean
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_person_id int;
BEGIN
    INSERT INTO persons (created_by,person_first_name, person_last_name, person_birthdate,
                          person_sex, is_actor, is_director, created_at)
    VALUES (p_created_by, p_first_name, p_last_name, p_birthdate, p_sex::person_genre, TRUE, FALSE, now())
    RETURNING person_id INTO v_person_id;

    INSERT INTO movie_persons (movie_id, person_id, person_movie_job,
                                actor_movie_role, is_main_actor)
    VALUES (p_movie_id, v_person_id, 'actor', p_actor_role, p_is_main_actor);

    COMMIT;
END;
$$;

-- Appel :
CALL AddNewActorToMovie(1, 'Elliot', 'Page', '1987-02-21', 'M', 1, 'Sinon', TRUE);
-- READ : lister les acteurs d'un film donné

CREATE OR REPLACE PROCEDURE ListActorsOfMovie(
    p_movie_id   int,
    INOUT result refcursor
)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN result FOR
        SELECT p.person_id, p.person_first_name, p.person_last_name,
               mp.actor_movie_role, mp.is_main_actor
        FROM persons AS p
        JOIN movie_persons AS mp
            ON p.person_id = mp.person_id
        WHERE mp.movie_id = p_movie_id
          AND mp.person_movie_job = 'actor';
END;
$$;

-- Appel :
BEGIN;
CALL ListActorsOfMovie(1, 'cursor_acteurs');
FETCH ALL FROM cursor_acteurs;
COMMIT;


-- UPDATE : modifier le rôle / statut d'un acteur dans un film

CREATE OR REPLACE PROCEDURE UpdateActorRoleInMovie(
    p_movie_id       int,
    p_person_id      int,
    p_actor_role     varchar,
    p_is_main_actor  boolean
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE movie_persons
    SET actor_movie_role = p_actor_role,
        is_main_actor    = p_is_main_actor
    WHERE movie_id  = p_movie_id
      AND person_id = p_person_id
      AND person_movie_job = 'actor';

    COMMIT;
END;
$$;

-- Appel :
CALL UpdateActorRoleInMovie(1, 5, 'Telemaque (fils de Ulysse)', TRUE);


-- DELETE : retirer un acteur d'un film

CREATE OR REPLACE PROCEDURE RemoveActorFromMovie(
    p_movie_id   int,
    p_person_id  int
)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM movie_persons
    WHERE movie_id  = p_movie_id
      AND person_id = p_person_id
      AND person_movie_job = 'actor';

    COMMIT;
END;
$$;

-- Appel :
CALL RemoveActorFromMovie(1, 5);
```

### 12. Trigger : historique des modifications de la table des utilisateurs

```sql
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

CREATE TRIGGER  user_update_trigger
	AFTER UPDATE ON users
	FOR EACH ROW
	EXECUTE FUNCTION log_update();
```