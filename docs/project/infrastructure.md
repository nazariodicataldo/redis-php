# Infrastruttura

Stato previsto dell'ambiente locale. Le configurazioni non sono ancora implementate; i task proposti ne definiscono la sequenza. Il backend Laravel esistente si trova in `backend/`.

## Servizi Compose

Previsti: `app` (PHP-FPM 8.5), `nginx`, `postgres` e `redis`, collegati a una rete interna. Non sono previsti worker, scheduler o servizi cloud. Il file Compose è nella root del repository come da convenzione descritta in `AGENTS.md`; la denominazione del Dockerfile e i percorsi di configurazione nginx restano da definire durante i rispettivi task.

Sequenza di configurazione M1:

1. Avviare Postgres e Redis e creare `app_test` con uno script Postgres in `/docker-entrypoint-initdb.d`.
2. Aggiungere `app`, il bind mount del backend e i volumi persistenti per la cache Composer e `vendor`.
3. Aggiungere nginx e verificare il passaggio HTTP verso Laravel con `GET /`.

## PHP e Composer

- Obiettivo PHP: 8.5 sia nel CLI locale usato per il primo task Composer sia nell'immagine PHP-FPM.
- Per T-001 il CLI PHP 8.5 locale è un'eccezione temporanea alla regola di eseguire i comandi PHP nel container. Non si usa l'ambiente web o DNS di Lerd. Una volta disponibile l'ambiente Docker, Composer e gli altri comandi PHP vanno eseguiti nel container `app`.
- Base immagine prevista: `php:8.5-fpm`; il tag va verificato su Docker Hub durante T-002.
- Estensioni previste: `pdo_pgsql` (con `libpq-dev`), `redis` tramite PECL oppure `predis/predis` se la compilazione PECL non è compatibile, `bcmath`, `intl`, `zip`, `pcntl` e `opcache`.
- Composer nell'immagine va copiato dall'immagine ufficiale `composer:2`.
- La scelta dell'estensione Redis e la compatibilità delle dipendenze con PHP 8.5 sono da verificare, non assunte.

## Database

- Database applicativo: `app`.
- Database test: `app_test`, separato da `app`.
- Lo script in `/docker-entrypoint-initdb.d` viene eseguito solo quando il volume Postgres viene inizializzato per la prima volta. Con un volume già esistente, la creazione di `app_test` richiede un'azione manuale documentata.
- Le prove Pest devono collegarsi al Postgres reale nel container, non a SQLite o a un fake.

## Redis e isolamento dei test

- Sviluppo: Redis DB `1`.
- Test: Redis DB `2` e prefisso `test_`, configurati in `backend/phpunit.xml`.
- Le prove Pest usano dati temporanei ma reali: scrivono e leggono da `app_test` e dalla cache Laravel collegata a Redis DB `2`, con prefisso `test_`. Non devono modificare il database `app` o Redis DB `1`.

## Variabili e volumi

- Le variabili di connessione a Postgres e Redis vanno documentate nell'esempio ambiente del backend (`backend/.env.example`); la modalità con cui Compose carica questo file va verificata nel task Compose.
- `backend/phpunit.xml` imposta `DB_CONNECTION=pgsql`, `DB_HOST=postgres`, `DB_DATABASE=app_test`, `CACHE_STORE=redis`, `REDIS_CACHE_DB=2` e `CACHE_PREFIX=test_`.
- Compose conserva cache Composer e `vendor` in volumi associati al servizio `app`. Se `composer.lock` cambia, Composer deve riallineare il volume `vendor` prima di eseguire i comandi PHP.
- Il volume Postgres è persistente. Le istruzioni devono spiegare il limite di inizializzazione one-shot dello script per `app_test`.

## Comandi di verifica previsti

Per il Dockerfile, prima che il servizio Compose `app` esista, si costruisce e si avvia un container singolo per controllare PHP 8.5, le estensioni e l'esecuzione di Artisan con il backend montato. Dopo aver aggiunto il servizio `app`, i comandi PHP e Composer si eseguono nel container:

- `docker compose up -d`
- `docker compose ps`
- `docker compose exec app composer install`
- `docker compose exec app php artisan --version`
- `docker compose exec app vendor/bin/pest`
- `docker compose exec app vendor/bin/pint --test`
- `docker compose exec app vendor/bin/phpstan analyse --memory-limit=1G`
- `curl -i http://localhost/`

I controlli e i relativi output vanno registrati nei task; questa documentazione non attesta che siano già stati eseguiti.
