--
--
--
SELECT current_timestamp, current_database(), pg_backend_pid() ;

\echo Statistics by Relations
\echo
SELECT schemaname, relname
, n_live_tup, n_dead_tup
, last_autoanalyze, last_analyze
FROM pg_stat_user_tables
WHERE n_dead_tup > 0
ORDER BY n_live_tup DESC
;

\echo Space usage by Relations
\echo
SELECT pg_table_size(c.oid), pg_indexes_size(c.oid)
, pg_total_relation_size(c.oid), n.nspname, c.relname
FROM pg_namespace n
INNER JOIN pg_class c
ON n.oid = c.relnamespace
WHERE n.nspname NOT IN ('pg_toast', 'pg_catalog', 'information_schema')
ORDER BY 1 DESC
;
