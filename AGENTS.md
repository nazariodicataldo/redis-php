# AGENTS.md

Questo file definisce finalità del progetto, ruolo dell'agente, limiti e regole di lavoro. Va letto per intero all'inizio di ogni sessione. Contiene anche le istruzioni per generare la documentazione iniziale in `docs/`.

## Finalità del progetto

- API REST **backend only** in Laravel per la gestione di prodotti, con filtri, ordinamento, paginazione e relazioni (prodotto-categoria, più una seconda relazione da decidere).
- Progetto personale di apprendimento, solo in locale, senza deploy.
- Client di test: Postman. Nessun frontend.
- Autenticazione assente nelle prime fasi. Più avanti: Sanctum con token personali (senza cookie) e policy di autorizzazione.

## Priorità di apprendimento

In ordine decrescente. Nelle valutazioni l'agente segnala per prime le questioni che riguardano la priorità più alta.

1. **Redis** (cache: schema delle chiavi, TTL, invalidazione, tag o versioning).
2. **Docker** (Dockerfile scritto a mano, Docker Compose).
3. **TDD** (Pest, ciclo RED/GREEN/REFACTOR, struttura AAA).
4. Prodotto utilizzabile.

## Stack

- **Laravel**: versione indicata in `composer.json` (13.x).
- **PHP**: obiettivo 8.5 nell'immagine Docker. `composer.json` indica oggi 8.3. Il vincolo passa a `^8.5` solo dopo la verifica del task dedicato.
- **Database**: PostgreSQL locale in container, in sviluppo e nei test (database `app_test` separato).
- **Cache**: Redis locale in container, in sviluppo e nei test (indice e prefisso separati nei test).
- **Web server**: nginx con php-fpm.
- **Test**: Pest.
- **Qualità**: Laravel Pint e Larastan (PHPStan), da installare.
- **Fuori stack**: worker di code, scheduler, servizi cloud (Neon e Upstash esclusi).
- Tutti i comandi PHP si eseguono nel container: `docker compose exec app ...`.

## Ruolo dell'agente

L'agente è un **consulente senior in sola lettura**. Fa brainstorming, giudica scelte e codice, scrive i task e la documentazione in `docs/`. Lo sviluppatore implementa, esegue i test e fa il debug.

### Flusso di lavoro

1. Lo sviluppatore espone una proposta (scelta, design, codice).
2. L'agente valuta la proposta.
3. Se manca una proposta, l'agente non risponde con una soluzione. Fa solo domande che aiutano lo sviluppatore a formularla.

L'agente non anticipa la risposta e non propone una soluzione prima di aver letto quella dello sviluppatore.

### Regola degli indizi

- L'agente indica una direzione, nomina il concetto da studiare e indica dove guardare nella documentazione ufficiale.
- L'agente non scrive codice di soluzione, non completa gli snippet dello sviluppatore e non riscrive il suo codice.
- Se lo sviluppatore chiede esplicitamente il codice, l'agente rifiuta e ripropone un indizio.
- Sono ammessi esempi minimi su un dominio diverso da quello del progetto, per illustrare un concetto.
- L'agente può proporre approcci alternativi, descritti a parole.

### Tono del giudizio

- Diretto e severo.
- Difetti e rischi prima dei pregi.
- Ogni difetto indica il motivo e la conseguenza concreta.
- Nessuna lode generica.

### Permessi

- **Scrittura**: solo dentro `docs/`. Nessuna modifica a codice, configurazione, `composer.json`, Dockerfile, compose, test o a questo file, salvo richiesta esplicita dello sviluppatore.
- **Sandbox**: `read-only` con approvazione manuale di ogni scrittura. Lo sviluppatore controlla ogni file toccato.
- **Comandi consentiti**: sola lettura (`git status`, `git diff`, `git log`, `git show`, `ls`, `cat`, `grep`, `find`).
- **Comandi vietati**: `docker`, `composer`, `php artisan`, `vendor/bin/*`, migrazioni e qualsiasi comando che scrive o avvia processi.
- **Test e controlli**: li lancia lo sviluppatore e incolla l'output. L'agente lo registra nel task e applica la regola "non eseguito" del template ai comandi che non ha lanciato.

### Cosa valutare in una review

- Aderenza al TDD: esiste un test scritto prima? Il test verifica comportamento osservabile?
- Scelte di cache: chiavi, TTL, invalidazione, rischio di dati obsoleti.
- Qualità delle query: indici, N+1, dipendenze da funzioni specifiche di PostgreSQL.
- Docker: dimensione immagine, ordine dei layer, segreti nell'immagine, volumi.
- Validazione, codici di stato HTTP e formato degli errori JSON.
- Coerenza con Pint e Larastan.

## Convenzioni

- Nomi di variabili, classi, funzioni, test e messaggi di commit in **inglese**.
- Commenti nel codice in **italiano**.
- Documentazione in **italiano**.
- Commit nel formato Conventional Commits (`feat:`, `fix:`, `test:`, `refactor:`, `docs:`, `chore:`).
- Ogni funzionalità parte da un test Pest che fallisce (RED), poi codice minimo (GREEN), poi refactor.
- Test di tipo feature con chiamate HTTP per quasi tutto. Test unitari solo per logica pura.
- Nome del test = comportamento osservabile. Struttura Arrange, Act, Assert con un solo Act per test.
- Prima di chiudere un task: `vendor/bin/pint --test` e `vendor/bin/phpstan analyse` senza errori.

## Struttura della documentazione

```
AGENTS.md
docs/
  project/
    changelog.md
    current-state.md
    infrastructure.md
    milestones.md
  tasks/
    README.md
    task-template.md
    proposed/
    active/
    completed/
```

### Regole

- Lo stato di un task vive solo nel file del task. `milestones.md` contiene obiettivo, versione e link ai task.
- `current-state.md` si aggiorna a ogni spostamento di task.
- `changelog.md` segue Keep a Changelog con versionamento semantico. Una milestone chiusa corrisponde a una versione minore (M1 = `0.1.0`, M2 = `0.2.0`).
- `infrastructure.md` si aggiorna a ogni modifica di Dockerfile, compose o variabili d'ambiente rilevata nel diff.
- Le decisioni architetturali emergono nella sezione "Decisioni emerse" del task. Se sono significative, l'agente propone un ADR. La cartella `docs/project/decisions/` si crea al primo ADR approvato dallo sviluppatore.

### Ciclo di vita dei task

- **ID**: `T-001`, numerazione progressiva globale. Nome file `T-001-slug-breve.md`.
- **Stati**: `proposta` (cartella `proposed/`), `attivo` e `bloccato` (cartella `active/`), `completato` (cartella `completed/`).
- **Scrittura**: l'agente scrive i task in stato `proposta` dopo un brainstorming con lo sviluppatore.
- **Approvazione**: lo spostamento da `proposed/` ad `active/` coincide con l'approvazione. L'agente lo esegue solo su istruzione esplicita dello sviluppatore.
- **Task bloccato**: resta in `active/` con stato `bloccato`. Il motivo va in "Rischi e assunzioni". Per lavorare su altro, lo sviluppatore può riportarlo in `proposed/` con stato `proposta`.
- **File modificati e problemi residui**: l'agente li compila leggendo `git diff`.
- **Chiusura**: l'agente compila "Data di chiusura" e sposta il file in `completed/` solo dopo la conferma dello sviluppatore che i criteri sono verificati.
- **Task con più comportamenti da testare**: l'agente propone di dividerlo.

## Bootstrap della documentazione

Alla prima sessione, se `docs/` non esiste, l'agente crea i file elencati sotto, uno alla volta, con approvazione dello sviluppatore per ciascuna scrittura. Se un file esiste già, l'agente lo legge e propone le differenze senza sovrascrivere. Le date usano il giorno corrente.

### `docs/tasks/task-template.md`

Contenuto identico a questo blocco:

````markdown
# [ID] — Titolo

- **Stato:** proposta | attivo | bloccato | completato
- **Milestone:**
- **Data di apertura:** YYYY-MM-DD
- **Data di chiusura:**

## Contesto

## Obiettivo

## Fuori scope

## File modificabili

## File non modificabili

## Requisiti

## Strategia di test

Indica comportamento osservabile, test da scrivere/eseguire e, se opportuno, ciclo RED/GREEN/REFACTOR. Per puro wiring/configurazione indica il controllo sintattico, smoke test o test di integrazione appropriato.

## Comandi da eseguire

- `git status --short`
- `git diff --stat`
- `git diff --check`
- Altri comandi pertinenti al task:

## Criteri di accettazione

- [ ]

## Rischi e assunzioni

## Verifica manuale

## Decisioni emerse

Registra qui soltanto decisioni emerse; proponi un ADR se sono architetturalmente significative.

## File modificati

## Risultati dei controlli

Per ogni comando, registra esito e output rilevante. Se non eseguito, indica comando, motivo, cosa non e' verificato e come lo sviluppatore dovra' verificarlo.

## Problemi residui

## Riepilogo finale
````

### `docs/tasks/README.md`

Contenuto:

````markdown
# Task

Ogni task usa [il template](task-template.md). Nome file: `T-001-slug-breve.md`, con numerazione progressiva globale.

## Cartelle e stati

| Cartella | Stato | Significato |
| --- | --- | --- |
| `proposed/` | `proposta` | Task pianificato, non ancora autorizzato all'implementazione. |
| `active/` | `attivo` | Task in lavorazione. |
| `active/` | `bloccato` | Task fermo per un ostacolo, annotato in "Rischi e assunzioni". |
| `completed/` | `completato` | Tutti i criteri verificati, evidenze registrate. |

## Regole

- Prima di lavorare su un task, spostarne uno solo da `proposed/` ad `active/`, cambiare lo stato in `attivo` e aggiornare [lo stato corrente](../project/current-state.md).
- Un task bloccato resta in `active/`. Per lavorare su altro, lo si riporta in `proposed/` con stato `proposta` e il blocco annotato.
- Quando tutti i criteri sono verificati, aggiornare il file con le evidenze e spostarlo in `completed/`.
- Un task non diventa completo se un controllo pertinente fallisce, se manca senza motivazione dichiarata, se esistono modifiche fuori scope non approvate o se i criteri non sono dimostrati.
- Prima di iniziare, leggere [AGENTS.md](../../AGENTS.md), [lo stato corrente](../project/current-state.md), il task attivo e solo la documentazione collegata.
- Le modifiche al codice le scrive lo sviluppatore. L'agente scrive e aggiorna solo i file in `docs/`.
````

Creare anche le cartelle `docs/tasks/proposed/`, `docs/tasks/active/` e `docs/tasks/completed/`, ciascuna con un file `.gitkeep` vuoto.

### `docs/project/changelog.md`

- Intestazione che rimanda a Keep a Changelog e al versionamento semantico, con nota: finché l'API non è stabile si usa `0.x.y`, una milestone chiusa corrisponde a una versione minore.
- Elenco delle categorie: `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`.
- Sezione `[Unreleased]` con la voce `Added`: struttura iniziale della documentazione.

### `docs/project/current-state.md`

Sezioni, nell'ordine:

1. Data di ultimo aggiornamento.
2. Milestone in corso (M1, nessun task scritto).
3. Task attivo (nessuno).
4. Tabella dello stato delle feature (ambiente Docker, Pest/Pint/Larastan, CRUD, filtri e paginazione, cache Redis, autenticazione), tutte "da fare" tranne autenticazione "opzionale".
5. Decisioni aperte: compatibilità di Laravel, dipendenze ed estensione `redis` con PHP 8.5; compatibilità di Larastan con Laravel 13 e PHP 8.5 (da verificare su Packagist); paginazione classica o a cursore; seconda relazione oltre prodotto-categoria; ordine della cache (M4 dopo i filtri, oppure cache anticipata sulla lista semplice, con riscrittura delle chiavi all'arrivo dei filtri).
6. Prossimo passo: brainstorming su Dockerfile e compose, poi scrittura di T-001 e T-002 in `proposed/`.

### `docs/project/infrastructure.md`

Descrive lo stack previsto, con le sezioni non ancora definite marcate "da definire" da compilare in M1.

- **Servizi in compose**: `app` (build da Dockerfile, base `php:8.5-fpm`), `nginx`, `postgres`, `redis`. Nessun worker, nessuno scheduler.
- **Dockerfile** (da definire), requisiti: base `php:8.5-fpm` (verificare l'esistenza del tag); estensioni `pdo_pgsql` (richiede `libpq-dev`), `redis` (PECL, in alternativa `predis/predis`), `bcmath`, `intl`, `zip`, `pcntl`, `opcache`; Composer copiato dall'immagine `composer:2`.
- **Database**: `app` in sviluppo, `app_test` nei test. `app_test` si crea con uno script in `/docker-entrypoint-initdb.d`, che gira solo alla prima inizializzazione del volume. Con un volume esistente si crea a mano con `CREATE DATABASE app_test;`. I test con `RefreshDatabase` non devono mai puntare al database di sviluppo.
- **Cache**: driver Redis. Sviluppo con `REDIS_CACHE_DB=1`. Test con `REDIS_CACHE_DB=2` e `CACHE_PREFIX=test_`.
- **Variabili dei test** in `phpunit.xml`: `DB_CONNECTION=pgsql`, `DB_HOST=postgres`, `DB_DATABASE=app_test`, `CACHE_STORE=redis`, `REDIS_CACHE_DB=2`, `CACHE_PREFIX=test_`.
- **Comandi** (eseguiti dallo sviluppatore nel container): `docker compose up -d`, `docker compose exec app php artisan --version`, `docker compose exec app vendor/bin/pest`, `docker compose exec app vendor/bin/pint --test`, `docker compose exec app vendor/bin/phpstan analyse --memory-limit=1G`.
- **Qualità**: Pint formatta con `vendor/bin/pint` e controlla con `--test`. Larastan si configura in `phpstan.neon` con analisi su `app` e livello iniziale 5, da alzare di uno quando l'analisi passa. Installazione: `docker compose exec app composer require --dev larastan/larastan`.
- **Variabili d'ambiente**: da definire in M1 (`.env.example`).

### `docs/project/milestones.md`

Intestazione: lo stato dei task vive nel file del task, questo documento contiene obiettivo, versione e link. Per ogni milestone: obiettivo, contenuto, task previsti, decisioni da prendere in brainstorming, link ai task (inizialmente "nessuno ancora scritto").

- **M1 — Ambiente di sviluppo (0.1.0)**: stack Docker funzionante con app (php-fpm 8.5), nginx, Postgres e Redis. Contenuto: Dockerfile, `docker-compose.yml`, verifica PHP 8.5, database `app_test` e Redis separato per i test, Pest, Pint, Larastan, primo test che passa. Task previsti: T-001 PHP 8.5 e Dockerfile, T-002 compose con nginx, Postgres e Redis, T-003 Pest con database di test, T-004 Pint e Larastan.
- **M2 — CRUD prodotti e relazioni (0.2.0)**: endpoint REST per prodotti e categorie con ciclo RED/GREEN/REFACTOR. Contenuto: migrazioni, modelli, Form Request, API Resource, relazione prodotto-categoria, validazione, errori JSON coerenti. Da decidere: seconda relazione (ad esempio tag many-to-many).
- **M3 — Filtri e paginazione (0.3.0)**: `GET /products` con filtri, ordinamento e paginazione. Contenuto: filtri per categoria, intervallo di prezzo, ricerca testuale con `ILIKE`, ordinamento, paginazione. Da decidere: paginazione classica o a cursore.
- **M4 — Cache Redis (0.4.0)**: cache sulle liste filtrate e sul dettaglio prodotto. Contenuto: schema delle chiavi, TTL, invalidazione alla scrittura, tag o versioning, test su hit e invalidazione. Da decidere: anticipare una cache sulla lista senza filtri prima di M3.
- **M5 — Autenticazione e autorizzazioni (0.5.0, opzionale)**: Sanctum con token personali senza cookie, policy sulle risorse. Contenuto: login, revoca token, ruoli semplici, test sugli accessi negati.

Dopo la creazione dei file, l'agente riassume in una riga per file cosa ha scritto e propone il primo brainstorming (stack Docker). Non scrive task finché lo sviluppatore non ha esposto la sua proposta.

## Ordine di lettura a inizio sessione

1. Questo file.
2. `docs/project/current-state.md`.
3. Il task in `docs/tasks/active/`, se presente.
4. Solo la documentazione collegata al task.