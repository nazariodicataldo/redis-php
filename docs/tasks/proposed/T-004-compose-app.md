# T-004 — Servizio app in Compose

- **Stato:** proposta
- **Milestone:** M1 — Ambiente di sviluppo
- **Data di apertura:** 2026-10-31
- **Data di chiusura:**

## Contesto

T-002 prepara l'immagine PHP-FPM; T-003 avvia Postgres e Redis. Il backend Laravel vive in `backend/`. Questo task integra questi componenti in un servizio Compose utilizzabile durante lo sviluppo. Dipende da T-002 e T-003.

## Obiettivo

Aggiungere il servizio `app`, montare il backend, collegarlo a Postgres e Redis e conservare cache Composer e `vendor` in volumi. Installare le dipendenze nel container.

## Fuori scope

- Configurazione nginx e richieste HTTP da host, che appartengono a T-006.
- Configurazione dell'isolamento PHPUnit, che appartiene a T-005.
- Modifiche al codice dell'applicazione.

## File modificabili

- File Compose nella root, assunto `docker-compose.yml`.
- `backend/.env.example` per le variabili usate dal servizio `app`.
- Eventuale documentazione operativa dei volumi, solo se necessaria per renderne chiaro l'uso.

## File non modificabili

- Dockerfile già verificato in T-002, salvo bug direttamente collegato emerso nella build Compose e registrato.
- Script di init Postgres e configurazione dei servizi dati di T-003, salvo correzioni direttamente necessarie alla connessione dell'app.
- `backend/app/**`, route e test.
- Configurazione nginx.

## Requisiti

- Aggiungere `app` alla stessa rete Compose di `postgres` e `redis`, usando l'immagine verificata in T-002.
- Montare `backend/` nel container per lo sviluppo.
- Configurare volumi persistenti per la cache Composer e per `vendor`.
- Configurare il servizio per collegarsi a Postgres e Redis usando i nomi dei servizi Compose e Redis DB `1` in sviluppo.
- Eseguire `composer install` dentro il container, così la compatibilità del lock è verificata con PHP 8.5 e le estensioni effettive dell'immagine.
- Verificare dal container che Artisan parta e che l'app raggiunga Postgres e Redis con controlli smoke.

## Strategia di test

Controllo di integrazione Compose: avviare `app`, verificare il bind mount, installare le dipendenze usando i volumi, avviare Artisan e verificare le connessioni reali a Postgres e Redis. Le connessioni di test a `app_test` e Redis DB `2` vengono dimostrate separatamente da T-005.

## Comandi da eseguire

- `git status --short`
- `git diff --stat`
- `git diff --check`
- `docker compose up -d app postgres redis`
- `docker compose ps`
- `docker compose exec app composer install`
- `docker compose exec app php artisan --version`
- `docker compose exec app php artisan db:show`
- `docker compose exec app php artisan tinker --execute='dump(\Illuminate\Support\Facades\Redis::connection()->ping())'`

Registrare i comandi effettivi dei due smoke test quando scelti durante l'implementazione.

## Criteri di accettazione

- [ ] Il servizio `app` parte con PHP 8.5 e vede i file montati da `backend/`.
- [ ] I volumi Composer e `vendor` persistono al riavvio del servizio.
- [ ] `composer install` termina nel container senza incompatibilità di piattaforma.
- [ ] `php artisan --version` termina nel container.
- [ ] Il processo `app` raggiunge Postgres e Redis tramite la rete interna Compose.
- [ ] Redis di sviluppo usa DB `1`; le connessioni test non vengono configurate qui.

## Rischi e assunzioni

- Se il volume `vendor` contiene dipendenze non allineate al lock, `composer install` deve riallinearle; il volume non deve nascondere un'installazione obsoleta.
- La verifica Composer in container può far emergere incompatibilità non osservabili sul PHP host di T-001.
- La strategia di caricamento delle variabili `.env` deve essere verificata con il layout backend/root.

## Verifica manuale

Riavviare il servizio `app`, verificare che `vendor` resti disponibile e ripetere Artisan e i controlli di connessione senza usare l'host come runtime PHP.

## Decisioni emerse

- I volumi per cache Composer e `vendor` appartengono al servizio Compose `app`, non al Dockerfile.
- Composer viene verificato una seconda volta nell'immagine effettiva per rilevare differenze di estensioni rispetto all'host.
- L'app in sviluppo usa Redis DB `1`.

## File modificati

Da compilare dopo l'implementazione leggendo il diff.

## Risultati dei controlli

Nessun controllo è stato eseguito per questo task proposto. Registrare output Composer, Artisan e smoke test DB/Redis.

## Problemi residui

Nessuno noto in fase di proposta; persistenza e caricamento ambiente vanno verificati.

## Riepilogo finale

Da compilare dopo l'implementazione e la verifica dei criteri.
