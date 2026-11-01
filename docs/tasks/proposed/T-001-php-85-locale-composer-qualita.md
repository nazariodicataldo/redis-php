# T-001 — PHP 8.5 locale, Composer e qualità

- **Stato:** proposta
- **Milestone:** M1 — Ambiente di sviluppo
- **Data di apertura:** 2026-10-31
- **Data di chiusura:**

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

- [ ] PHP CLI sul PC riporta la versione 8.5 e non dipende dall'avvio del web server/DNS Lerd.
- [ ] Il vincolo Composer è `^8.5` e l'installazione delle dipendenze esistenti termina correttamente.
- [ ] I requisiti delle estensioni risultano compatibili; l'alternativa Redis scelta è annotata.
- [ ] La compatibilità Larastan è stata verificata su Packagist prima dell'installazione; se fallisce, task bloccato con evidenza.
- [ ] Pint è presente e `vendor/bin/pint --test` termina senza errori.
- [ ] Larastan è configurato in `backend/phpstan.neon`; PHPStan passa al livello 5 senza errori e l'eventuale livello successivo è registrato.
- [ ] La suite eseguita con `E_ALL` non lascia deprecazioni PHP 8.5 non annotate.

## Rischi e assunzioni

- L'installazione del PHP CLI 8.5 è una modifica locale al PC e non è riproducibile dal repository; nel task vanno annotate la sorgente d'installazione e le estensioni abilitate.
- Il task non dimostra ancora che la stessa combinazione funzioni nell'immagine Docker. Questa verifica è T-002/T-004.
- Larastan può non supportare la combinazione Laravel 13/PHP 8.5 oppure l'analisi può trovare problemi nel codice esistente.
- Il percorso e il metodo d'installazione del PHP CLI 8.5 locale non sono stati scelti durante il grill.

## Verifica manuale

Confermare che `php -v` eseguito dal terminale del PC mostri PHP 8.5 e che il progetto usi ancora il percorso web/DNS previsto solo quando sarà avviato tramite Docker.

## Decisioni emerse

- Per T-001 Composer usa il PHP CLI 8.5 locale; è un'eccezione limitata al primo task.
- Il vincolo Composer obiettivo è `^8.5`.
- Pint e Larastan fanno parte del setup di qualità M1; PHPStan parte dal livello 5.

## File modificati

Da compilare dopo l'implementazione leggendo il diff.

## Risultati dei controlli

Nessun controllo è stato eseguito per questo task proposto. Lo sviluppatore deve eseguire i comandi elencati, registrare gli output rilevanti e indicare eventuali comandi non eseguiti e il motivo.

## Problemi residui

Nessuno noto in fase di proposta; compatibilità e risultati restano da verificare.

## Riepilogo finale

Da compilare dopo l'implementazione e la verifica dei criteri.
