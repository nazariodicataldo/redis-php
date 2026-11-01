# T-002 — Dockerfile PHP 8.5

- **Stato:** proposta
- **Milestone:** M1 — Ambiente di sviluppo
- **Data di apertura:** 2026-10-31
- **Data di chiusura:**

## Contesto

T-001 prepara il PHP CLI 8.5 locale e il lock Composer. L'app Laravel esistente è in `backend/`; l'immagine PHP-FPM deve riprodurre il target PHP 8.5 e includere le estensioni necessarie. Il servizio Compose `app` e i suoi volumi verranno aggiunti in T-004. Dipende da T-001.

## Obiettivo

Creare a mano un Dockerfile per PHP 8.5-FPM, costruire l'immagine e avviare un container singolo per verificare runtime, estensioni e bind mount del backend.

## Fuori scope

- Servizi e volumi Compose, Postgres, Redis e nginx.
- `composer install` con i volumi persistenti, che verrà verificato nel task Compose di `app`.
- Aggiornamento del PHP CLI locale.

## File modificabili

- Nuovo Dockerfile dell'applicazione (percorso da definire durante l'implementazione).
- Eventuali file di supporto strettamente necessari alla build dell'immagine, con percorso da registrare nel diff.

## File non modificabili

- `backend/composer.json` e `backend/composer.lock`, gestiti da T-001 salvo incompatibilità runtime documentata.
- File Compose, `.env.example`, script Postgres, configurazione nginx e `backend/phpunit.xml`.
- Codice applicativo e test.

## Requisiti

- Usare la base `php:8.5-fpm` e verificare che il tag esista su Docker Hub.
- Installare `pdo_pgsql` (con `libpq-dev`), `redis` tramite PECL o adottare `predis/predis` se PECL non compila con PHP 8.5, oltre a `bcmath`, `intl`, `zip`, `pcntl` e `opcache`.
- Copiare Composer dall'immagine `composer:2`.
- Costruire l'immagine e avviare un container singolo con il backend montato; verificare PHP 8.5, le estensioni previste e `php artisan --version`.
- Registrare ogni incompatibilità tra host e immagine. Se la verifica nel container richiede una correzione a `composer.json` o al lock, concordare e registrare il cambiamento prima di eseguirlo; i volumi Composer e `vendor` non fanno parte di questo task.

## Strategia di test

È un task di immagine, non un cambiamento di comportamento API. Verificare il tag upstream, la build, l'avvio del container e il comportamento osservabile del bind mount: i comandi PHP devono leggere il backend montato e riportare la versione Laravel. La build deve fallire visibilmente se un'estensione non è disponibile o non compila.

## Comandi da eseguire

- `git status --short`
- `git diff --stat`
- `git diff --check`
- Controllo del tag `php:8.5-fpm` su Docker Hub.
- `docker build` usando il Dockerfile e il build context scelti per il progetto.
- `docker run` dell'immagine con bind mount del backend.
- Nel container avviato: `php -v`, `php -m` e `php artisan --version`.

Registrare i percorsi e i comandi completi scelti quando il Dockerfile viene implementato.

## Criteri di accettazione

- [ ] Il tag `php:8.5-fpm` è stato verificato su Docker Hub.
- [ ] L'immagine si costruisce senza errori e il container si avvia.
- [ ] `php -v` nel container riporta PHP 8.5.
- [ ] `php -m` conferma tutte le estensioni concordate; l'opzione Redis effettivamente scelta è documentata.
- [ ] Il bind mount rende disponibile il progetto e `php artisan --version` termina correttamente.
- [ ] Incompatibilità con il lock Composer o tra estensioni host/container sono registrate e non nascoste.

## Rischi e assunzioni

- Il percorso del Dockerfile e il build context non sono stati decisi durante il grill.
- `php:8.5-fpm` e la compilazione PECL possono cambiare disponibilità; il task non è completo senza la verifica reale.
- La presenza di Composer nell'immagine non prova ancora l'installazione dei pacchetti nel container; ciò viene verificato in T-004 con i volumi Compose.

## Verifica manuale

Avviare il container costruito montando `backend/` e verificare dalla shell del container che i file Laravel siano visibili e che Artisan riporti la versione attesa.

## Decisioni emerse

- L'immagine obiettivo usa PHP 8.5-FPM e Composer 2.
- La scelta PECL Redis/Predis dipende dalla compatibilità verificata con PHP 8.5.
- Bind mount e prova dell'immagine precedono l'integrazione Compose.

## File modificati

Da compilare dopo l'implementazione leggendo il diff.

## Risultati dei controlli

Nessun controllo è stato eseguito per questo task proposto. Lo sviluppatore deve registrare output di build e avvio, versione PHP, estensioni e comando Artisan.

## Problemi residui

Nessuno noto in fase di proposta; tag e build restano da verificare.

## Riepilogo finale

Da compilare dopo l'implementazione e la verifica dei criteri.
