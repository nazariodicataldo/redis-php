# Changelog

Il formato segue [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) e il [Semantic Versioning](https://semver.org/lang/it/). Finché l'API non è stabile si usa `0.x.y`; la chiusura di una milestone incrementa la versione minore.

Categorie disponibili: `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`.

## [Unreleased]

### Added

- Struttura iniziale della documentazione di progetto e dei task.
- Dockerfile PHP 8.5-FPM in `docker/backend/Dockerfile` con Composer 2 e le estensioni `pdo_pgsql`, `intl`, `zip`, `bcmath`, `pcntl` e `redis` (PECL).
- `compose.yml` con i servizi `postgres` (PostgreSQL 17) e `redis` (Redis 8), entrambi con healthcheck.
- Volume `postgres-data` per la persistenza dei dati Postgres. Redis non ha volume.
- Script `docker/postgres/init/01-create-database.sql`, che crea il database `app_test` alla prima inizializzazione del volume.
- `compose.env.example` con le variabili di Compose e `REDIS_DB=1`. `compose.env` è ignorato da Git e va passato a Compose con `--env-file`.