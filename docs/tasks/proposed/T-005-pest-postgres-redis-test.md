# T-005 — Pest con Postgres e Redis di test

- **Stato:** proposta
- **Milestone:** M1 — Ambiente di sviluppo
- **Data di apertura:** 2026-10-31
- **Data di chiusura:**

## Contesto

Pest è già presente nel progetto Laravel, ma `backend/phpunit.xml` usa SQLite in memoria e la cache `array`. T-003 crea `app_test`; T-004 rende Postgres e Redis raggiungibili dal servizio `app`. Dipende da T-004.

## Obiettivo

Configurare Pest per usare il Postgres reale `app_test` e Redis reale DB `2` con prefisso `test_`, poi verificare con dati temporanei che le letture e scritture funzionino e restino separate dall'ambiente di sviluppo.

## Fuori scope

- Creazione del database `app_test` e avvio dei servizi, coperti da T-003.
- Configurazione del servizio Compose `app`, coperta da T-004.
- Test di funzionalità di prodotti/categorie o endpoint API non ancora implementati.
- Test con servizi simulati al posto di Postgres e Redis reali.

## File modificabili

- `backend/phpunit.xml`
- `backend/tests/Pest.php` e `backend/tests/Feature/**`
- Eventuale configurazione test strettamente necessaria in `backend/config/**`, da motivare.

## File non modificabili

- File Compose, Dockerfile, script Postgres e configurazione nginx, salvo correzione direttamente necessaria e registrata.
- `backend/app/**` e codice di prodotto, fuori scope per un test di infrastruttura.
- `.env` locale e credenziali.

## Requisiti

- Mantenere Pest come framework e verificare che il comando funzioni dentro `app`.
- Configurare `DB_CONNECTION=pgsql`, `DB_HOST=postgres`, `DB_DATABASE=app_test`, `CACHE_STORE=redis`, `REDIS_CACHE_DB=2` e `CACHE_PREFIX=test_`.
- Prima della configurazione, scrivere il test di raggiungibilità e osservare un RED dovuto alla configurazione attuale SQLite/array o all'assenza della connessione prevista; registrare il motivo preciso dell'errore.
- Portare il test a GREEN eseguendo una scrittura e una lettura Postgres con dati temporanei e una scrittura/lettura tramite la cache Laravel su Redis reale. Usare la cache Laravel per verificare anche il prefisso `test_`.
- Tenere separati il caso Postgres e il caso cache Redis: un test per comportamento, Arrange/Act/Assert e un solo Act per test.
- Dimostrare che il test usa `app_test` e Redis DB `2` con prefisso `test_`, senza scrivere sul database `app` o Redis DB `1`.
- Pulire o isolare i dati temporanei perché esecuzioni successive non interferiscano.

## Strategia di test

RED/GREEN: creare test Pest d'integrazione separati per Postgres e cache Redis, con un Act ciascuno e vere operazioni di scrittura/lettura; per Redis usare la cache Laravel così viene applicato `CACHE_PREFIX`. Eseguirli prima della modifica di `phpunit.xml` e registrare i fallimenti corretti; configurare l'ambiente; ripetere i test e la suite. I dati possono essere fittizi, ma le connessioni non sono fake.

## Comandi da eseguire

- `git status --short`
- `git diff --stat`
- `git diff --check`
- `docker compose exec app composer show pestphp/pest`
- `docker compose exec app vendor/bin/pest <percorso-del-test>`
- `docker compose exec app vendor/bin/pest`
- Verifica esplicita dei database configurati in PHPUnit e di Redis DB/prefisso usati dal test.

Nel task completato registrare l'output RED, l'output GREEN e i controlli dell'isolamento.

## Criteri di accettazione

- [ ] È stato osservato un RED per i test d'integrazione prima della configurazione e la causa è quella attesa, non un errore sintattico o un servizio semplicemente spento.
- [ ] Il test passa usando Postgres `app_test` e Redis DB `2` con prefisso `test_`.
- [ ] Il test esegue vere operazioni di scrittura e lettura su Postgres e sulla cache Laravel collegata a Redis, con dati temporanei.
- [ ] Nessun test usa `backend/.env` per puntare al database `app` o Redis DB `1`.
- [ ] La suite Pest completa passa dentro il container.

## Rischi e assunzioni

- `app_test` deve esistere già; l'inizializzazione del volume Postgres è one-shot e T-003 documenta il caso volume preesistente.
- Redis non offre rollback transazionale equivalente a `RefreshDatabase`; le chiavi di prova devono essere isolate e pulite.
- Un test che legge solo i valori di configurazione senza eseguire operazioni reali non dimostra la raggiungibilità dei servizi.

## Verifica manuale

Eseguire Pest dal container `app` e controllare che il test usi valori temporanei, riesca a leggerli dai servizi reali e non alteri i dati di sviluppo.

## Decisioni emerse

- I test usano Postgres `app_test` e Redis DB `2` con prefisso `test_`.
- Le prove usano dati fittizi temporanei ma connessioni reali; non si usano fake per simulare l'infrastruttura.
- Il test di infrastruttura viene scritto prima della configurazione e osservato in RED.

## File modificati

Da compilare dopo l'implementazione leggendo il diff.

## Risultati dei controlli

Nessun controllo è stato eseguito per questo task proposto. Registrare gli output RED e GREEN e l'esito della suite completa.

## Problemi residui

Nessuno noto in fase di proposta; isolamento e pulizia dei dati vanno dimostrati.

## Riepilogo finale

Da compilare dopo l'implementazione e la verifica dei criteri.
