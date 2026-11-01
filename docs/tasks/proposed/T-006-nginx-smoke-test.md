# T-006 — nginx e smoke test HTTP

- **Stato:** proposta
- **Milestone:** M1 — Ambiente di sviluppo
- **Data di apertura:** 2026-10-31
- **Data di chiusura:**

## Contesto

T-004 integra `app` con Postgres e Redis; T-005 verifica l'ambiente di test. La rotta `GET /` esiste già in `backend/routes/web.php` e restituisce la pagina Laravel predefinita. Non esistono ancora endpoint dell'API prodotti. È il task finale M1 e dipende da T-004 e T-005.

## Obiettivo

Aggiungere nginx a Compose, inoltrare le richieste a PHP-FPM e verificare da host il collegamento HTTP fino a Laravel con `GET /`.

## Fuori scope

- Modifica della rotta `/` o implementazione di endpoint API.
- Test di comportamento dei prodotti: verranno aggiunti in M2.
- Nuovi servizi oltre nginx e l'app già esistente.

## File modificabili

- File Compose nella root, assunto `docker-compose.yml`.
- Nuova configurazione nginx (percorso da definire durante l'implementazione).

## File non modificabili

- `backend/routes/web.php`, `backend/app/**` e `backend/tests/**`.
- Dockerfile e servizi Postgres/Redis, salvo correzione diretta e registrata di un errore d'integrazione.
- Variabili ambiente e configurazione test.

## Requisiti

- Aggiungere il servizio nginx alla rete Compose.
- Inoltrare le richieste HTTP al servizio PHP-FPM `app` e rendere l'app raggiungibile da host su localhost.
- Verificare `GET /` e una risposta HTTP riuscita dalla rotta esistente.
- Dichiarare esplicitamente che questo smoke test prova il collegamento nginx → Laravel, non il comportamento dell'API.

## Strategia di test

Smoke test d'integrazione finale: avviare lo stack completo e inviare una richiesta HTTP da host con curl. La prova è valida se nginx raggiunge PHP-FPM e Laravel risponde sulla rotta `/` esistente. Non aggiungere una nuova rotta solo per il test.

## Comandi da eseguire

- `git status --short`
- `git diff --stat`
- `git diff --check`
- `docker compose up -d`
- `docker compose ps`
- `curl -i http://localhost/`

## Criteri di accettazione

- [ ] I servizi nginx e app risultano avviati e collegati alla rete Compose.
- [ ] nginx inoltra la richiesta HTTP a PHP-FPM.
- [ ] `GET /` da host riceve una risposta di successo da Laravel.
- [ ] La verifica è descritta come smoke test di rete e non come test di un endpoint API.

## Rischi e assunzioni

- Il percorso della configurazione nginx e la porta host non sono stati decisi nel grill; registrarli nell'implementazione.
- La rotta `/` restituisce la pagina welcome Laravel e non è un endpoint API; gli endpoint saranno verificati da M2.

## Verifica manuale

Aprire `http://localhost/` oppure eseguire curl e verificare la risposta Laravel attraverso nginx.

## Decisioni emerse

- La verifica finale M1 usa la rotta esistente `GET /`; non introduce una rotta di test.
- I test dell'API restano fuori da M1.

## File modificati

Da compilare dopo l'implementazione leggendo il diff.

## Risultati dei controlli

Nessun controllo è stato eseguito per questo task proposto. Registrare output `docker compose ps` e risposta HTTP.

## Problemi residui

Nessuno noto in fase di proposta; porta e percorso nginx restano da definire.

## Riepilogo finale

Da compilare dopo l'implementazione e la verifica dei criteri.
