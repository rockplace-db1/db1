--
-- 23 Oct 2023 N_ROWS internal variable (psql)
-- 07 June 2023 Created
--
\set N_ROWS 10
SELECT current_timestamp, current_database(), pg_backend_pid() ;

\echo Statistics by Relations (Top :N_ROWS)
\echo
SELECT schemaname, relname
, n_live_tup, n_dead_tup
, n_ins_since_vacuum
, last_autovacuum, last_vacuum
--, autovacuum_count AS autovac_count
, n_mod_since_analyze
, last_autoanalyze, last_analyze
--, analyze_count
FROM pg_stat_user_tables
WHERE n_dead_tup > 0
ORDER BY n_dead_tup DESC
LIMIT :N_ROWS
;

\echo Space usage by Relations (Top :N_ROWS)
\echo
SELECT pg_table_size(c.oid), pg_indexes_size(c.oid)
, pg_total_relation_size(c.oid), n.nspname, c.relname 
FROM pg_namespace n
INNER JOIN pg_class c
ON n.oid = c.relnamespace
WHERE n.nspname NOT IN ('pg_toast', 'pg_catalog', 'information_schema')
ORDER BY 1 DESC
LIMIT :N_ROWS
;
\unset N_ROWS

\echo index(es) not valid
\echo
SELECT indrelid::regclass AS "Table name"
, indexrelid::regclass AS "index name"
, CASE indisvalid WHEN true THEN 'YES' ELSE 'NO' END AS "is valid"
FROM pg_index 
WHERE indisvalid = false
;
