# Milestone

Lo stato operativo vive nei singoli task. Questo documento riassume obiettivi, contenuti, decisioni aperte e collegamenti. Una milestone chiusa corrisponde a una versione minore `0.x.0`.

## M1 — Ambiente di sviluppo (`0.1.0`)

**Obiettivo:** ambiente locale ripetibile con PHP 8.5, Docker Compose, nginx, Postgres, Redis, Pest e controlli di qualità.

**Contenuto:** PHP 8.5 CLI locale per il primo controllo Composer; immagine Docker PHP-FPM 8.5; Compose con Postgres e Redis, poi `app` e nginx; `app_test` separato; cache Composer e `vendor` persistenti; Pest con connessioni reali e spazi di test isolati; Pint e Larastan.

**Task proposti:**

- [T-001 — PHP 8.5 locale, Composer e qualità](../tasks/proposed/T-001-php-85-locale-composer-qualita.md)
- [T-002 — Dockerfile PHP 8.5](../tasks/proposed/T-002-dockerfile-php-85.md)
- [T-003 — Compose Postgres e Redis](../tasks/proposed/T-003-compose-postgres-redis.md)
- [T-004 — Compose app](../tasks/proposed/T-004-compose-app.md)
- [T-005 — Pest con Postgres e Redis di test](../tasks/proposed/T-005-pest-postgres-redis-test.md)
- [T-006 — nginx e smoke test HTTP](../tasks/proposed/T-006-nginx-smoke-test.md)

**Decisioni e verifiche:** PHP 8.5 è il target; il CLI locale serve solo al primo task Composer, poi i comandi PHP girano nel container. Compatibilità del tag PHP, delle estensioni e di Larastan da verificare nei task. La rotta `GET /` esistente è una verifica di rete nginx → Laravel, non un test dell'API.

## M2 — CRUD prodotti e categorie (`0.2.0`)

**Obiettivo:** API REST per gestire prodotti e categorie e la loro relazione.

**Contenuto previsto:** migrazioni, modelli, Form Request, API Resource, validazione e risposte JSON coerenti. I dettagli dei task e del contratto API verranno definiti in un grill dopo M1.

**Decisioni già emerse:** prodotti e categorie saranno gestibili via API e collegati many-to-many con una pivot contenente solo le due chiavi esterne. **Decisioni aperte:** il design dettagliato dei flussi API e l'eventuale seconda relazione verranno discussi nel grill M2. L'autenticazione resta rinviata alla milestone opzionale M5.

**Task:** nessuno ancora scritto.

## M3 — Filtri e paginazione (`0.3.0`)

**Obiettivo:** `GET /products` con filtri, ordinamento e paginazione a cursore.

**Contenuto previsto:** filtri per categoria e intervallo di prezzo, ricerca testuale con `ILIKE`, ordinamento e `cursorPaginate`.

**Conseguenze della paginazione a cursore:** ogni ordinamento deve includere una colonna univoca come spareggio; la risposta non offre un totale dei record né il salto diretto alla pagina N.

**Task:** nessuno ancora scritto.

## M4 — Cache Redis (`0.4.0`)

**Obiettivo:** cache delle liste filtrate e del dettaglio prodotto, con TTL e invalidazione sulle scritture.

**Decisioni aperte:** stabilire se introdurre la cache delle liste dopo i filtri M3 o anticipare una cache sulla lista semplice. Una chiave di lista include anche il token del cursore; le varianti per cursore rendono necessaria un'invalidazione coerente tramite tag o versioning delle chiavi.

**Task:** nessuno ancora scritto.

## M5 — Autenticazione e autorizzazioni (opzionale, `0.5.0`)

**Obiettivo:** valutare Sanctum con token personali senza cookie e policy di autorizzazione.

**Contenuto previsto:** login, revoca dei token, ruoli semplici e test degli accessi negati. Il design verrà affrontato dopo le milestone precedenti.

**Task:** nessuno ancora scritto.
