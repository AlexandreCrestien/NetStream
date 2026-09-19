# Choix du SGBDR — NetStream

## Objectif

NetStream est un projet de plateforme de streaming (films, séries, documentaires et contenus exclusifs). L'objectif est de proposer un site web permettant de rechercher des films, des acteurs et des réalisateurs, et de gérer une vaste bibliothèque de films.

Avant de développer le site, la première étape est de concevoir et mettre en place la **base de données** qui stockera toutes ces informations : les films, les personnes (acteurs et réalisateurs), les rôles, ainsi que les préférences des utilisateurs (films et acteurs favoris).

Le choix du SGBDR est donc une décision importante : c'est la fondation sur laquelle reposera toute la plateforme. Ce document compare quelques solutions et explique pourquoi nous avons retenu **PostgreSQL**.

## Les candidats

- **PostgreSQL** : SGBDR open source complet, réputé pour sa robustesse et son respect du standard SQL.
- **MySQL / MariaDB** : SGBDR open source très populaire, souvent utilisé pour les applications web.
- **SQLite** : moteur léger, sans serveur, stocké dans un simple fichier.

## Comparaison

| Critère | PostgreSQL | MySQL | SQLite |
|---|---|---|---|
| Gratuit / open source | Oui | Oui | Oui |
| Architecture | Serveur | Serveur | Fichier local |
| Clés étrangères | Oui | Oui | Oui |
| Type ENUM | Oui | Oui | Non |
| Procédures stockées | Oui | Oui | Non |
| Triggers | Oui | Oui | Limités |
| Respect du standard SQL | Très bon | Moyen | Partiel |
| Types de données avancés | Nombreux | Corrects | Basiques |
| Plusieurs utilisateurs à la fois | Oui | Oui | Faible |
| Adapté aux gros projets | Oui | Oui | Non |
| Communauté / documentation | Très large | Très large | Large |

## Analyse

**SQLite** est un moteur léger, pratique pour de petites applications locales. Mais il n'a pas de procédures stockées, gère mal plusieurs utilisateurs en même temps et ne supporte pas les types ENUM. Il est donc écarté pour NetStream.

**MySQL / MariaDB** est un bon candidat, très utilisé et solide. Il gère les clés étrangères, les procédures stockées et les triggers. Ses limites sont un respect moins fidèle du standard SQL et des types de données moins riches que PostgreSQL.

**PostgreSQL** couvre tous les besoins du projet : types ENUM, procédures stockées, triggers et contraintes avancées.

## Conclusion

Nous choisissons **PostgreSQL** pour NetStream. Il est gratuit, robuste, respecte bien le standard SQL et offre nativement tout ce dont le projet a besoin. Nous l'avons utilisé concrètement pour créer des types ENUM, des procédures stockées, un trigger d'historique et plusieurs contraintes. Sa large communauté et sa documentation complète facilitent aussi son apprentissage et sa maintenance.