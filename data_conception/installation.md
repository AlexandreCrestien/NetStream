# Installation de la base NetStream

## 1. Prérequis

- PostgreSQL 16 installé.

Vérifier :

```bash
psql --version
```

## 2. Démarrer PostgreSQL

```bash
sudo systemctl start postgresql
```

## 3. Créer la base

Le fichier `create_database.sql` crée la base, les tables et quelques données.

```bash
sudo -u postgres psql -f create_database.sql
```

> Le script supprime la base existante avant de la recréer : ferme toute connexion à `netstream` (DBeaver...) avant de le lancer.

## 4. Se connecter

```bash
sudo -u postgres psql -d netstream
```

Commandes utiles : `\dt` (lister les tables), `\q` (quitter).