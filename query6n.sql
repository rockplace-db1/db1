--
-- 01 Aug 2023 Created, pg_stat_database 
--
\set PG_DB_NAME pagila
\connect :PG_DB_NAME

SELECT current_timestamp, current_database()
;

SELECT datid, datname
, sessions, sessions_killed, sessions_abandoned, sessions_fatal
, session_time, active_time, idle_in_transaction_time
, stats_reset
FROM pg_stat_database
WHERE datname = :'PG_DB_NAME'
;

SELECT datid, datname
, xact_commit, xact_rollback
, tup_inserted, tup_updated, tup_deleted
, tup_fetched, tup_returned
, stats_reset
FROM pg_stat_database
WHERE datname = :'PG_DB_NAME'
;

SELECT datid, datname
, blks_read, blks_hit
, blk_read_time, blk_write_time
, stats_reset
FROM pg_stat_database
WHERE datname = :'PG_DB_NAME'
;

-- parameters
SELECT name, setting, unit
, boot_val, reset_val, pending_restart
, source, sourceline, sourcefile
, category, short_desc
FROM pg_settings
WHERE name = 'shared_buffers'
;