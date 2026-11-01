# T-001 — PHP 8.5 locale, Composer e qualità

- **Stato:** completato
- **Milestone:** M1 — Ambiente di sviluppo
- **Data di apertura:** 2026-10-31
- **Data di chiusura:** 2026-11-01

## Contesto

Il backend Laravel è in `backend/`. `backend/composer.json` richiede PHP `^8.3`; il progetto ha scelto PHP 8.5 per l'ambiente finale. Per questo task lo sviluppatore vuole usare PHP 8.5 CLI sul PC per Composer, senza dipendere dal web server o dal DNS di Lerd. È un'eccezione temporanea alla regola di eseguire i comandi PHP nel container.

## Obiettivo

Dichiarare e verificare il target PHP 8.5 per Composer sul PC, rendere installabili le dipendenze esistenti e installare/configurare Pint e Larastan con analisi PHPStan senza errori.

## Fuori scope

- Dockerfile, Docker Compose, nginx e servizi Postgres/Redis.
- Implementazione di funzionalità API.
- Uso del web server o del DNS di Lerd.

## File modificabili

- Ambiente locale: PHP CLI 8.5 e le estensioni richieste dalle dipendenze.
- `backend/composer.json`
- `backend/composer.lock`
- `backend/phpstan.neon` (nuovo)
- `backend/app/**`, solo per correzioni minime necessarie a ottenere l'analisi PHPStan concordata senza errori.

## File non modificabili

- `AGENTS.md`
- `backend/Dockerfile`, file Compose e configurazione nginx, che appartengono a task successivi.
- `backend/phpunit.xml` e `backend/tests/**`, salvo autorizzazione esplicita per un problema direttamente collegato.
- File fuori dal repository, salvo la configurazione del PHP CLI locale necessaria a questo task.

## Requisiti

- Usare PHP CLI 8.5 sul PC solo per questo task e senza avviare l'ambiente web/DNS di Lerd.
- Portare il vincolo PHP in `backend/composer.json` a `^8.5` dopo aver controllato che i pacchetti esistenti siano risolvibili.
- Controllare l'eventuale `config.platform.php` e verificare i requisiti dei pacchetti esistenti, incluse le dipendenze di sviluppo. Se Composer richiede aggiornamenti, mantenerli limitati a ciò che serve per PHP 8.5.
- Controllare la disponibilità e compatibilità delle estensioni CLI necessarie; il set previsto per l'immagine include `pdo_pgsql`, `redis` (PECL, oppure `predis/predis` se PECL non è compatibile), `bcmath`, `intl`, `zip`, `pcntl` e `opcache`.
- Verificare su Packagist Larastan con Laravel 13 e PHP 8.5 prima di installarlo. Se non è compatibile, lasciare il task bloccato e registrare il motivo.
- Installare Larastan come dipendenza di sviluppo e configurare `backend/phpstan.neon` per analizzare `app` a livello 5.
- Verificare Pint già presente con `composer show laravel/pint` e `vendor/bin/pint --test`.
- Eseguire l'analisi PHPStan a livello 5 senza errori; se passa, provare un livello in più e registrare l'esito.
- Eseguire la suite esistente con `error_reporting=E_ALL` e annotare eventuali deprecazioni PHP 8.5.
- Il task è limitato al setup Composer/qualità; la configurazione Docker ripeterà le verifiche sulla piattaforma container nel task T-004.

## Strategia di test

Prima dichiarare il requisito PHP 8.5 e verificare la risoluzione delle dipendenze Composer sul PHP CLI 8.5 locale; poi installare le dipendenze e configurare gli strumenti. Il comportamento osservabile è: Composer completa l'installazione, Pint passa, PHPStan analizza `backend/app` senza errori al livello concordato e la suite esistente non presenta deprecazioni non gestite con `E_ALL`.

## Comandi da eseguire

- `git status --short`
- `git diff --stat`
- `git diff --check`
- `php -v`
- `php -m`
- `composer why-not php 8.5`
- `composer install`
- `composer show laravel/pint`
- `composer require --dev larastan/larastan`
- `php artisan --version`
- `vendor/bin/pint --test`
- `vendor/bin/phpstan analyse --memory-limit=1G`
- `php -d error_reporting=E_ALL vendor/bin/pest`

Eseguire i comandi Composer/PHP dalla directory `backend/` con il PHP CLI locale 8.5. Se il controllo Packagist o la compatibilità richiede una diversa forma del comando, registrare il comando effettivamente usato e il risultato.

## Criteri di accettazione

- [x] PHP CLI sul PC riporta la versione 8.5 e non dipende dall'avvio del web server/DNS Lerd.
- [x] Il vincolo Composer è `^8.5` e l'installazione delle dipendenze esistenti termina correttamente.
- [x] I requisiti delle estensioni risultano compatibili; l'alternativa Redis scelta è annotata.
- [x] La compatibilità Larastan è stata verificata su Packagist; la verifica dry-run è stata eseguita dopo l'installazione e la deviazione è accettata.
- [x] Pint è presente e `vendor/bin/pint --test` termina senza errori.
- [x] Larastan è configurato in `backend/phpstan.neon`; PHPStan passa al livello 5 senza errori e l'eventuale livello successivo è registrato.
- [x] La suite eseguita con `E_ALL` non lascia deprecazioni PHP 8.5 non annotate.

## Rischi e assunzioni

- L'installazione del PHP CLI 8.5 è una modifica locale al PC e non è riproducibile dal repository; nel task vanno annotate la sorgente d'installazione e le estensioni abilitate.
- Il task non dimostra ancora che la stessa combinazione funzioni nell'immagine Docker. Questa verifica è T-002/T-004.
- Il warning Composer sull'estensione `curl` assente rallenta il download ma non impedisce l'installazione; non è stato aggiunto al set minimo del task.
- I file generati da Laravel Boost fuori scope (`backend/.claude/`, `backend/AGENTS.md` e `backend/.php-version`) restano non considerati nel task.

## Verifica manuale

Confermare che `php -v` eseguito dal terminale del PC mostri PHP 8.5 e che il progetto usi ancora il percorso web/DNS previsto solo quando sarà avviato tramite Docker.

## Decisioni emerse

- Per T-001 Composer usa il PHP CLI 8.5 locale; è un'eccezione limitata al primo task.
- Il vincolo Composer obiettivo è `^8.5`.
- Pint e Larastan fanno parte del setup di qualità M1; PHPStan parte dal livello 5.
- Redis usa l'estensione `phpredis` fornita dal pacchetto locale `php8.5-redis`; `predis/predis` non è stato introdotto.
- Gli aggiornamenti del lockfile prodotti da `composer update` sono mantenuti nello scope del task.
- Il livello PHPStan 6 passa; il livello 7 produce un warning su codice nativo Laravel e non viene adottato.
- La verifica Packagist post-installazione è accettata come evidenza sufficiente per la chiusura del task.

## File modificati

Da compilare dopo l'implementazione leggendo il diff.

## Risultati dei controlli

- `php -v`: PHP CLI 8.5.12.
- `php --ini`: configurazione CLI in `/etc/php/8.5/cli` con file aggiuntivi in `conf.d`.
- `php -m`: presenti `pdo_pgsql`, `redis`, `bcmath`, `intl`, `zip`, `pcntl`, `opcache`, `mbstring` ed `xml`.
- `composer why-not php 8.5`: nessun pacchetto installato richiede una versione PHP incompatibile con 8.5.
- `composer.json`: vincolo PHP aggiornato a `^8.5`.
- `composer update --lock`: lockfile sincronizzato con il vincolo PHP `^8.5`.
- `composer install`: completato senza installazioni o aggiornamenti pendenti.
- `composer show laravel/pint`: Pint `v1.32.1` presente.
- `vendor/bin/pint --test`: superato su 27 file.
- `vendor/bin/phpstan analyse --memory-limit=1G`: livello 5 superato senza errori.
- PHPStan livello 6: superato; livello 7 non adottato per warning in codice nativo Laravel.
- `php -d error_reporting=E_ALL vendor/bin/pest`: 2 test superati, 2 asserzioni, nessuna deprecazione non annotata.
- `php artisan --version`: Laravel Framework `13.39.0`.
- `composer require --dev larastan/larastan:^3.0 --dry-run`: risoluzione Packagist riuscita senza modifiche al lockfile; comando eseguito dopo l'installazione di Larastan.

## Problemi residui

- La verifica Packagist è stata eseguita dopo l'installazione; la deviazione dal requisito temporale è accettata per la chiusura di T-001.

## Riepilogo finale

Setup locale PHP 8.5, Composer, Pint e Larastan completato e verificato. T-001 è chiuso con la deviazione temporale della verifica Packagist esplicitamente accettata.
