# T-002 — Dockerfile PHP 8.5

- **Stato:** completato
- **Milestone:** M1 — Ambiente di sviluppo
- **Data di apertura:** 2026-10-31
- **Data di chiusura:** 2026-11-04

## Contesto

T-001 prepara il PHP CLI 8.5 locale e il lock Composer. L'app Laravel esistente è in `backend/`; l'immagine PHP-FPM deve riprodurre il target PHP 8.5 e includere le estensioni necessarie. Il servizio Compose `app` e i suoi volumi verranno aggiunti in T-004. Dipende da T-001.

## Obiettivo

Creare a mano un Dockerfile per PHP 8.5-FPM, costruire l'immagine e avviare un container singolo per verificare runtime, estensioni e bind mount del backend.

## Fuori scope

- Servizi e volumi Compose, Postgres, Redis e nginx.
- `composer install` con i volumi persistenti, che verrà verificato nel task Compose di `app`.
- Aggiornamento del PHP CLI locale.

## File modificabili

- Nuovo Dockerfile dell'applicazione.
- Eventuali file di supporto strettamente necessari alla build dell'immagine, con percorso da registrare nel diff. Nessun file di supporto è stato necessario.

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
- `docker pull php:8.5-fpm`
- `docker build -t redis-php-app .`, lanciato dalla cartella `docker/`.
- `docker run -it -v $(pwd)/../backend:/var/www/html redis-php-app bash`, lanciato dalla cartella `docker/`.
- Nel container avviato: `php -v`, `php -m` e `php artisan --version`.

## Criteri di accettazione

- [x] Il tag `php:8.5-fpm` è stato verificato su Docker Hub.
- [x] L'immagine si costruisce senza errori e il container si avvia.
- [x] `php -v` nel container riporta PHP 8.5.
- [x] `php -m` conferma tutte le estensioni concordate; l'opzione Redis effettivamente scelta è documentata.
- [x] Il bind mount rende disponibile il progetto e `php artisan --version` termina correttamente.
- [x] Incompatibilità con il lock Composer o tra estensioni host/container sono registrate e non nascoste.

## Rischi e assunzioni

- Il percorso del Dockerfile e il build context sono stati decisi durante l'implementazione (vedi "Decisioni emerse").
- `php:8.5-fpm` e la compilazione PECL possono cambiare disponibilità; la verifica è valida alla data di chiusura.
- La presenza di Composer nell'immagine non prova l'installazione dei pacchetti nel container; ciò viene verificato in T-004.

## Risultati dei controlli

- **Tag:** `docker pull php:8.5-fpm` termina con `Image is up to date for php:8.5-fpm`, digest `sha256:c34bcf437ed61bd5e4c1114494eaf1ffd54253bce2b95d263bfa18b350ee8432`. Lo stesso digest è stato usato da `docker build`. Anche `composer:2` è stato scaricato dalla build.
- **Build:** terminata con `FINISHED` su 9 step su 9. Lo step di `apt-get` e compilazione delle estensioni ha richiesto circa 257 secondi. Questo output è della build precedente all'aggiunta di `rm -rf /var/lib/apt/lists/*` e `WORKDIR`. Esito della ricostruzione con il Dockerfile finale: [da confermare].
- **Avvio:** il container con comando predefinito avvia PHP-FPM (`fpm is running`, `ready to handle connections`).
- **`php -v`:** PHP 8.5.12 (cli), NTS, con Zend OPcache v8.5.12.
- **`php -m`:** presenti `bcmath`, `intl`, `pcntl`, `pdo_pgsql`, `redis`, `zip` e `Zend OPcache`. Presenti anche `pdo_sqlite` e `sodium`, forniti dall'immagine base.
- **Bind mount:** `ls` in `/var/www/html` mostra i file di `backend/`, tra cui `artisan`, `composer.json`, `composer.lock` e `vendor`.
- **`php artisan --version`:** Laravel Framework 13.39.0, termina senza errori.
- **Comandi git:** `git status --short` riporta solo `?? docker/` (cartella nuova, non tracciata). `git diff --stat` e `git diff --check` non producono output, perché `docker/Dockerfile` non è ancora tracciato. Nessun file tracciato risulta modificato.

## Problemi residui

- Nessuna incompatibilità tra immagine e lock Composer. Artisan funziona con la cartella `vendor` creata in T-001 sull'host.
- La versione di PHP dell'host non è registrata. Se differisce da 8.5.12, va annotata accanto a quella del container.
- `composer install` dentro il container non è verificato e resta a T-004.

## Riepilogo finale

L'immagine `redis-php-app` si costruisce da `docker/Dockerfile` con PHP 8.5.12-FPM, Composer 2 e le estensioni richieste. Redis usa l'estensione PECL. Con il backend montato, Artisan riporta Laravel 13.39.0.