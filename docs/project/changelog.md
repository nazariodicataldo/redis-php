# Changelog

Il formato segue [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) e il [Semantic Versioning](https://semver.org/lang/it/). Finché l'API non è stabile si usa `0.x.y`; la chiusura di una milestone incrementa la versione minore.

Categorie disponibili: `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`.

## [Unreleased]

### Added

- Struttura iniziale della documentazione di progetto e dei task.
- Dockerfile PHP 8.5-FPM in `docker/Dockerfile` con Composer 2 e le estensioni `pdo_pgsql`, `intl`, `zip`, `bcmath`, `pcntl` e `redis` (PECL).