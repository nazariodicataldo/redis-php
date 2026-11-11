# Stato corrente

- **Ultimo aggiornamento:** 2026-11-11
- **Milestone in corso:** M1 — Ambiente di sviluppo (`0.1.0`)
- **Task attivo:** nessuno
- **Task proposti:** [T-004](../tasks/proposed/T-004-compose-app.md), [T-005](../tasks/proposed/T-005-pest-postgres-redis-test.md), [T-006](../tasks/proposed/T-006-nginx-smoke-test.md)

## Stato delle feature

| Feature | Stato |
| --- | --- |
| Ambiente Docker | In corso: Postgres e Redis in Compose (T-003); servizio `app` e nginx da fare |
| Pest, Pint e Larastan | Da fare |
| CRUD prodotti e categorie | Da fare |
| Filtri e paginazione a cursore | Da fare |
| Cache Redis | Da fare |
| Autenticazione | Opzionale, da valutare più avanti |

## Decisioni aperte

- Compatibilità di Laravel 13 e delle dipendenze esistenti con PHP 8.5 nel container: `php artisan --version` funziona con il `vendor` creato sull'host, mentre `composer install` nel container resta da verificare in T-004. L'estensione Redis PECL compila con PHP 8.5 (T-002).
- Compatibilità di Larastan con Laravel 13 e PHP 8.5: da verificare su Packagist prima dell'installazione.
- Riproducibilità delle immagini `postgres:17` e `redis:8-alpine`: i tag seguono release minori e patch. La scelta tra tag con versione minore e digest è rimandata.
- In M2 sono emersi prodotti e categorie collegati many-to-many tramite pivot con sole chiavi esterne; contratto API, eventuale ulteriore relazione e task di CRUD si definiranno con un grill dopo M1.
- Ordine della cache in M4: cache delle liste dopo i filtri M3 oppure anticipo sulla lista semplice.
- Politica di invalidazione M4: scegliere tag o versioning tenendo conto delle chiavi che includono il cursore.

## Prossimo passo

Attivare un solo task proposto con istruzione esplicita dello sviluppatore. M2 verrà pianificata dopo la chiusura di M1.