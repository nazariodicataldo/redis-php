# T-003 — Compose Postgres e Redis

- **Stato:** completato
- **Milestone:** M1 — Ambiente di sviluppo
- **Data di apertura:** 2026-10-31
- **Data di chiusura:** 2026-11-11

## Contesto

T-002 verifica l'immagine PHP. Questo task aggiunge i servizi dati indipendenti dall'app: PostgreSQL e Redis. Il database di test deve esistere prima che Pest venga configurato in T-005. Nell'ordine concordato per M1 viene dopo T-002; non richiede il servizio `app`.

## Obiettivo

Avviare Postgres e Redis con Docker Compose, conservare i dati Postgres in un volume e creare `app_test` durante la prima inizializzazione del volume.

## Fuori scope

- Servizio Laravel `app`, nginx e bind mount del backend.
- Collegamento di `compose.env` al servizio `app` e verifica che il processo PHP usi i valori.
- Configurazione PHPUnit/Pest e connessioni dal processo PHP.
- Migrazioni applicative e dati di dominio.
- Modifica di `backend/.env.example`.
- Persistenza dei dati Redis.
- Utente Postgres separato per i test.

## File modificabili

- `compose.yml` nella root.
- `compose.env.example` nella root: modello delle variabili usate da `compose.yml` e della variabile `REDIS_DB`.
- `.gitignore`: voce per `compose.env`, più `backend/node_modules` e `backend/vendor` (vedi "Decisioni emerse").
- `docker/postgres/init/01-create-database.sql`: script di inizializzazione, montato in `/docker-entrypoint-initdb.d`. Contiene anche il commento che documenta il comportamento one-shot.
- Spostamento del Dockerfile da `docker/Dockerfile` a `docker/backend/`, con contenuto invariato. Motivo annotato in "Problemi residui".
- `docs/project/changelog.md`: aggiornamento del percorso del Dockerfile e voci `Added` per Compose, Postgres e Redis.

## File non modificabili

- Contenuto del Dockerfile e codice in `backend/app/**`.
- `backend/.env.example`, che resta quello predefinito di Laravel.
- `backend/phpunit.xml` e `backend/tests/**`, che appartengono a T-005.
- Configurazione nginx.
- `compose.env` locale (ignorato da Git) e segreti dello sviluppatore, con l'eccezione dell'allineamento di `REDIS_DB` e della correzione dello spazio finale su `POSTGRES_PASSWORD`.

## Requisiti

- Definire servizi `postgres` e `redis` sulla rete interna Compose.
- Usare un volume persistente (`postgres-data`) per i dati Postgres.
- Creare i database `app` e `app_test`.
  - `app` viene creato dall'entrypoint tramite `POSTGRES_DB`.
  - `app_test` viene creato dallo script in `/docker-entrypoint-initdb.d`.
- Caricare le variabili di Compose da `compose.env` con l'opzione `--env-file compose.env` su ogni comando `docker compose`.
  - Senza il flag, Compose interpola stringhe vuote e il comando di healthcheck risulta rotto.
  - `compose.env` è ignorato da Git; `compose.env.example` è versionato.
  - Le variabili arrivano ai container tramite Compose; `backend/.env` non viene usato per i servizi dati.
- Configurare l'healthcheck Postgres con `pg_isready -h 127.0.0.1`, per interrogare il server via TCP, con `start_period: 30s`.
- Configurare l'healthcheck Redis con `redis-cli ping`, così `up --wait` attende anche Redis.
- Predisporre l'indice Redis di sviluppo: `compose.env.example` contiene `REDIS_DB=1`. Il container Redis non legge la variabile, perché l'indice viene scelto dal client con `SELECT`. Il valore viene consumato dal servizio `app`, introdotto in un task successivo.
- Documentare con un commento in testa a `01-create-database.sql` che lo script gira solo alla prima inizializzazione del volume. Per un volume esistente senza `app_test`, la procedura è `docker compose --env-file compose.env down -v`, con perdita di tutti i dati Postgres.
- Verificare che Postgres e Redis siano avviati e `healthy`, che Redis risponda, che gli indici `0` e `1` siano separati sul server e che Postgres contenga `app_test` dopo una prima inizializzazione pulita.

## Strategia di test

Smoke test dell'infrastruttura senza Laravel: avvio dei due servizi, controllo dello stato, ping Redis e verifica della presenza del database `app_test` dopo la prima inizializzazione. Non usare Pest per questo task, perché il servizio `app` non è ancora in Compose.

Prova aggiuntiva sull'healthcheck, con uno script temporaneo `pg_sleep` in `docker/postgres/init/` (ordinato dopo lo script di `app_test` e rimosso a fine prova), da volume pulito: controllo TCP con init di circa 20 secondi. Atteso: `starting` per tutta la durata dello sleep, poi `healthy`.

## Comandi da eseguire

Tutti i comandi `docker compose` usano `--env-file compose.env`.

- `git status --short`
- `git check-ignore -v compose.env`
- `git add -N .` per includere i file nuovi, poi `git diff --stat` e `git diff --check`
- `docker compose --env-file compose.env config`
- `docker compose config` (senza flag, per documentare i warning)
- `docker compose --env-file compose.env.example config` (copertura delle variabili nel file di esempio)
- `docker compose --env-file compose.env down -v`
- `docker compose --env-file compose.env up -d --wait postgres redis`
- `docker compose --env-file compose.env ps`
- `docker compose --env-file compose.env logs postgres`
- `docker compose --env-file compose.env exec postgres psql -U app -d app -c "SELECT datname FROM pg_database"`
- `docker compose --env-file compose.env exec redis redis-cli ping`
- `docker compose --env-file compose.env exec redis redis-cli -n 1 set prova 1`
- `docker compose --env-file compose.env exec redis redis-cli -n 1 dbsize`
- `docker compose --env-file compose.env exec redis redis-cli -n 0 dbsize`
- `docker compose --env-file compose.env exec redis redis-cli -n 1 flushdb`, poi `-n 1 dbsize`
- `docker volume ls --filter name=redis-php`

Registrare i comandi effettivi e l'output senza credenziali. I comandi con errore di battitura non vanno riportati.

## Criteri di accettazione

- [x] Postgres e Redis si avviano con Compose e risultano disponibili.
- [x] Postgres conserva i dati tramite un volume.
- [x] Una prima inizializzazione pulita crea `app_test` oltre al database applicativo.
- [x] Redis risponde, gli indici `0` e `1` sono separati sul server e `compose.env.example` contiene `REDIS_DB=1`.
- [x] Un commento in `01-create-database.sql` spiega il comportamento one-shot e la procedura per un volume esistente senza `app_test`.
- [x] `compose.env.example` contiene tutte le variabili usate da `compose.yml` più `REDIS_DB`, ed è allineato a `compose.env`.
- [x] L'healthcheck TCP è verificato con la prova su init di circa 20 secondi.

## Rischi e assunzioni

- **Versioni delle immagini:** `postgres:17` e `redis:8-alpine`.
  - Postgres 17 è la versione già usata in progetti recenti dello sviluppatore.
  - Redis 8 è considerato affidabile rispetto alla 7.
  - I tag seguono le release minori e patch, quindi due macchine possono ottenere versioni diverse. La riproducibilità è rimandata a una decisione successiva (tag con versione minore o digest).
  - Un passaggio a Postgres 18 richiede di controllare il percorso dei dati nell'immagine e il mount `/var/lib/postgresql/data`.
- **Utente unico:** `app` è superuser e proprietario di `app` e `app_test`. La separazione tra sviluppo e test dipende dal nome del database configurato in T-005. Una separazione con due ruoli richiede uno script `.sh`, variabili aggiuntive e password per ogni ruolo.
- **Script one-shot:** su un volume già creato lo script non viene rieseguito, e una verifica senza volume pulito darebbe un risultato fuorviante. `CREATE DATABASE` non ammette `IF NOT EXISTS`, quindi lo script non è rieseguibile a mano. Il comportamento è confermato dal log `Skipping initialization` su volume esistente.
- **`start_period: 30s`:** con il controllo TCP resta un margine per inizializzazioni lente. Il valore non è verificato con una prova dedicata. Su un'init più lunga di circa 55 secondi il container può risultare `unhealthy` e `up --wait` fallisce; in locale si risolve rilanciando il comando.
- **Redis senza volume:** i dati si perdono a ogni `down`. È accettato in sviluppo.
- **`REDIS_DB` senza consumatore:** Compose non segnala variabili presenti in `compose.env` e assenti da `compose.yml`. La variabile non produce effetti finché il servizio `app` non la riceve.
- **`backend/.env.example` su SQLite:** chi lancia `artisan` fuori da Compose usa SQLite finché il servizio `app` non esiste.

## Verifica manuale

- Avviare i servizi con un volume Postgres nuovo e controllare che `app_test` esista.
- Creare una tabella in `app`, eseguire `down` senza `-v`, riavviare e verificare che i dati persistano.

## Decisioni emerse

- Servizi dati separati da `app` e nginx.
- `app_test` viene creato allo startup iniziale Postgres e i test non useranno il DB di sviluppo.
- Le variabili di Compose stanno in `compose.env`, passato con `--env-file`. Il nome evita confusione con `backend/.env`, che non alimenta i servizi dati.
- `compose.env` è in `.gitignore`; `compose.env.example` è versionato.
- `.gitignore` contiene anche `backend/node_modules` e `backend/vendor`, che anticipano `composer install` e `npm install` del backend. Le due voci sono fuori dal perimetro iniziale e sono state accettate.
- `backend/.env.example` resta quello predefinito di Laravel e non rientra in T-003. Il processo PHP riceverà i valori da Compose, che hanno la precedenza sul file `.env`.
- Healthcheck Postgres via TCP (`-h 127.0.0.1`). Il server temporaneo dell'entrypoint ascolta solo sul socket Unix, come mostra il log (`listening on Unix socket` senza righe `IPv4`/`IPv6` nella fase di init). Un controllo via socket può segnare `healthy` prima della fine degli script di init.
- `start_period: 30s` confermato per l'healthcheck Postgres.
- Healthcheck Redis con `redis-cli ping`, aggiunto al `compose.yml` per rendere `up --wait` significativo anche per Redis.
- Procedura per `app_test` su volume esistente: `down -v`. `\gexec` di `psql` resta un'alternativa idempotente non adottata.
- La procedura è documentata in un commento nello script SQL, perché nessun file documentale (README incluso) rientra nel perimetro del task.
- Utente Postgres unico, con i rischi descritti sopra.
- Redis di sviluppo usa l'indice `1`, impostato con la variabile `REDIS_DB` (connessione Laravel `default`) in `compose.env.example`. Il test di isolamento usa `-n 1` e `-n 0`. Redis di test viene impostato in T-005.
- Il Dockerfile è stato spostato in `docker/backend/` dallo sviluppatore.

## File modificati

- `compose.yml` (nuovo, 28 righe)
- `compose.env.example` (nuovo, 4 righe)
- `.gitignore` (nuovo, 6 righe)
- `docker/postgres/init/01-create-database.sql` (nuovo, 3 righe)
- `docker/backend/Dockerfile` (spostato da `docker/Dockerfile`, contenuto invariato)
- `docs/project/changelog.md` (percorso del Dockerfile aggiornato, quattro voci `Added`)
- `docs/tasks/active/T-003-compose-postgres-redis.md` (spostato da `docs/tasks/proposed/`)

`git diff HEAD --stat`: 8 file, 233 inserimenti, 101 cancellazioni.

## Risultati dei controlli

Eseguiti il 2026-11-09 e il 2026-11-11. Password non riportate.

- `git check-ignore -v compose.env`: `.gitignore:2:compose.env`.
- `docker compose --env-file compose.env config`: valori risolti correttamente; healthcheck Postgres `pg_isready -h 127.0.0.1 -U app -d app`, con `start_period: 30s`; healthcheck Redis `redis-cli ping`.
- `docker compose config` senza flag: cinque warning di variabili non impostate e healthcheck `pg_isready -h 127.0.0.1 -U  -d `.
- `docker compose --env-file compose.env.example config`: nessun warning di variabili non impostate.
- Variabili: i nomi in `compose.env` e in `compose.env.example` coincidono (`POSTGRES_DB`, `POSTGRES_PASSWORD`, `POSTGRES_USER`, `REDIS_DB`). `grep REDIS_DB compose.env.example` restituisce `REDIS_DB=1`. `grep -n ' $' compose.env` non restituisce righe.
- `down -v` seguito da `up -d --wait postgres redis`: entrambi i servizi `Healthy` (Redis 5.9 s, Postgres 6.4 s nella prima sessione; Redis 6.1 s, Postgres 6.6 s nella seconda). `ps` mostra `Up (healthy)` per entrambi.
- `logs postgres` su volume nuovo: due `CREATE DATABASE`, il primo da `POSTGRES_DB=app`, il secondo da `01-create-database.sql`; il server definitivo ascolta su IPv4 e IPv6 solo dopo la fine dell'init.
- Query su `pg_database` dopo avvio pulito: `postgres`, `app`, `template1`, `template0`, `app_test`.
- Persistenza: riga inserita in `foo`, `down` senza `-v`, `up`, `select` restituisce `1`. Tabella eliminata a fine prova.
- `logs postgres` su volume esistente: `Skipping initialization`.
- Redis: `ping` risponde `PONG`; `-n 1 set prova 1` restituisce `OK`; `-n 1 dbsize` restituisce `1`; `-n 0 dbsize` restituisce `0`; `-n 1 flushdb` restituisce `OK`; `-n 1 dbsize` dopo il flush restituisce `0`.
- Prova sull'healthcheck (script temporaneo `02-pgsleep.sql`, init di circa 20 secondi, `up -d postgres` senza `--wait`): `ps` mostra `starting` a 6, 12 e 17 secondi e `healthy` a 28 secondi. Nel log l'init termina alle 21:09:31.6, il server definitivo ascolta su IPv4 e IPv6 alle 21:09:31.9 ed è pronto alle 21:09:32.0. Lo script temporaneo è stato rimosso; `ls docker/postgres/init` mostra solo `01-create-database.sql`.
- `git add -N .` seguito da `git diff --check`: nessun output.
- `git diff HEAD --stat`: 8 file, 233 inserimenti, 101 cancellazioni. Il Dockerfile risulta rinominato con 0 modifiche.

## Problemi residui

- Il Dockerfile è stato spostato in `docker/backend/` per lasciare `docker/` organizzata per servizio, in vista di `docker/nginx/`. Il contenuto è invariato.
- Nome dello script (`01-create-database.sql`) poco esplicito. Rinomina in `01-create-app-test-database.sql` rimandata.
- Tag immagini non fissati a una versione minore.
- `start_period: 30s` non verificato con una prova dedicata.
- Collegamento di `compose.env` al servizio `app` e verifica lato PHP rimandati al task che introduce `app`.

## Riepilogo finale

Compose avvia `postgres` (17) e `redis` (8) con healthcheck. I dati Postgres stanno nel volume `postgres-data`. Il database `app_test` viene creato dallo script di init alla prima inizializzazione del volume, e il commento nello script documenta la procedura `down -v` per un volume esistente senza `app_test`. Gli indici Redis `0` e `1` sono separati. `compose.env.example` contiene le variabili usate da `compose.yml` e `REDIS_DB=1`. La prova sull'healthcheck conferma che il controllo TCP resta `starting` fino alla fine dell'init. Il Dockerfile è in `docker/backend/` e il CHANGELOG riporta il nuovo percorso e le voci di Compose, Postgres e Redis.