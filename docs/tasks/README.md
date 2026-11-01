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
