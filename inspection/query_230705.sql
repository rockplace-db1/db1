--
-- 05 July 2023 Created
--
\set PG_DB_NAME pagila
\connect :PG_DB_NAME

-- tables
SELECT relid
, schemaname, relname
, n_live_tup, n_dead_tup
FROM pg_stat_all_tables
WHERE n_dead_tup > 0
ORDER BY n_live_tup 
;

-- indexes
SELECT count(*) AS "index(es) not valid"
FROM pg_index
WHERE indisvalid = false  -- indisvalid != true
;

-- statistics: transaction and cache
SELECT datid, datname
, xact_commit, xact_rollback
, blks_read, blks_hit
FROM pg_stat_database
WHERE blks_read > 0
AND datname = :'PG_DB_NAME'
;

SELECT datid, datname
, xact_commit / (xact_commit + xact_rollback) * 100 
, blks_hit / ( blks_read + blks_hit ) * 100 
FROM pg_stat_database
WHERE blks_read > 0
AND datname = :'PG_DB_NAME'
;

-- parameters
show archive_mode ;
show autovacuum ;
show log_directory ;