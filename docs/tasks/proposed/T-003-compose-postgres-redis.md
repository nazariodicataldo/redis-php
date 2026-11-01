# T-003 — Compose Postgres e Redis

- **Stato:** proposta
- **Milestone:** M1 — Ambiente di sviluppo
- **Data di apertura:** 2026-10-31
- **Data di chiusura:**

## Contesto

T-002 verifica l'immagine PHP. Questo task aggiunge i servizi dati indipendenti dall'app: PostgreSQL e Redis. Il database di test deve esistere prima che Pest venga configurato in T-005. Nell'ordine concordato per M1 viene dopo T-002; non richiede il servizio `app`.

## Obiettivo

Avviare Postgres e Redis con Docker Compose, conservare i dati Postgres in un volume e creare `app_test` durante la prima inizializzazione del volume.

## Fuori scope

- Servizio Laravel `app`, nginx e bind mount del backend.
- Configurazione PHPUnit/Pest e connessioni dal processo PHP.
- Migrazioni applicative e dati di dominio.

## File modificabili

- File Compose nella root (si assume `docker-compose.yml`, come nella convenzione di progetto).
- `backend/.env.example` per le variabili di sviluppo Postgres e Redis.
- Nuovo script di inizializzazione Postgres; il percorso host va deciso durante l'implementazione e il percorso nel container è `/docker-entrypoint-initdb.d`.

## File non modificabili

- Dockerfile e codice in `backend/app/**`.
- `backend/phpunit.xml` e `backend/tests/**`, che appartengono a T-005.
- Configurazione nginx.
- `.env` locale e segreti dello sviluppatore.

## Requisiti

- Definire servizi `postgres` e `redis` sulla rete interna Compose.
- Usare un volume persistente per i dati Postgres.
- Creare i database `app` e `app_test`; `app_test` viene creato dallo script in `/docker-entrypoint-initdb.d`.
- Documentare che lo script gira solo alla prima inizializzazione del volume e descrivere come creare `app_test` se il volume esiste già.
- Configurare Redis di sviluppo sull'indice DB `1`.
- Aggiungere in `backend/.env.example` le variabili applicative necessarie per collegarsi a questi servizi. La modalità con cui Compose carica il file ambiente va esplicitata.
- Verificare che Postgres e Redis siano avviati, che Redis risponda e che Postgres contenga `app_test` dopo una prima inizializzazione pulita.

## Strategia di test

Smoke test dell'infrastruttura senza Laravel: avvio dei due servizi, controllo dello stato, ping Redis e verifica della presenza del database `app_test` dopo la prima inizializzazione. Non usare Pest per questo task, perché il servizio `app` non è ancora in Compose.

## Comandi da eseguire

- `git status --short`
- `git diff --stat`
- `git diff --check`
- `docker compose up -d postgres redis`
- `docker compose ps`
- `docker compose exec redis redis-cli ping`
- Verifica Postgres con `pg_isready` e query che elenca `app` e `app_test`.

Registrare i comandi effettivi e l'output senza credenziali.

## Criteri di accettazione

- [ ] Postgres e Redis si avviano con Compose e risultano disponibili.
- [ ] Postgres conserva i dati tramite un volume.
- [ ] Una prima inizializzazione pulita crea `app_test` oltre al database applicativo.
- [ ] Redis risponde e l'ambiente di sviluppo usa DB `1`.
- [ ] La documentazione spiega il comportamento one-shot dello script e il caso volume già esistente.
- [ ] `backend/.env.example` contiene i nomi delle variabili necessarie senza segreti.

## Rischi e assunzioni

- Le versioni delle immagini Postgres e Redis non sono state definite nel grill e vanno scelte/documentate nell'implementazione.
- Il percorso host dello script e il caricamento delle variabili da parte di Compose non sono ancora definiti.
- Uno script di inizializzazione non viene rieseguito su un volume già creato; una verifica senza volume pulito darebbe un risultato fuorviante.

## Verifica manuale

Avviare i servizi con un volume Postgres nuovo e controllare che `app_test` esista; riavviare poi senza cancellare il volume e verificare che i dati persistano.

## Decisioni emerse

- Servizi dati separati da `app` e nginx.
- `app_test` viene creato allo startup iniziale Postgres e i test non useranno il DB di sviluppo.
- Redis di sviluppo usa DB `1`; i parametri di test vengono impostati in T-005.

## File modificati

Da compilare dopo l'implementazione leggendo il diff.

## Risultati dei controlli

Nessun controllo è stato eseguito per questo task proposto. Lo sviluppatore deve registrare output Compose, ping Redis e verifica dei database.

## Problemi residui

Nessuno noto in fase di proposta; tag immagine e percorsi restano da decidere.

## Riepilogo finale

Da compilare dopo l'implementazione e la verifica dei criteri.
