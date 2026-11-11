/* Lo script gira solo alla prima inizializzazione del volume */
/* Per un volume esistente, senza app_test esistente, lanciare docker compose --env-file compose.env down -v con perdita di tutti i dati Postgres  */
CREATE DATABASE app_test;