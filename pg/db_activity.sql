--
-- 17 Nov 2023 Updated, pg_stat_database
-- 19 Oct 2023 Created
--
--
\conninfo
SELECT current_timestamp, current_database(), pg_backend_pid() ;

SELECT name, setting, unit, context
FROM pg_settings
WHERE name IN
( 'compute_query_id', 'track_io_timing'
, 'track_activities', 'track_activity_query_size'
, 'log_hostname', 'max_connections'
)
;

\echo SQL statistics
\echo
SELECT datname, xact_rollback, xact_commit
, tup_updated, tup_deleted, tup_inserted
, tup_returned, tup_fetched
FROM pg_stat_database
;

\echo Current database processes and I/O statistics 
\echo
SELECT datname, numbackends 
, temp_files, temp_bytes
, blk_read_time, blk_write_time
, stats_reset
FROM pg_stat_database
;

\echo Session statistics 
\echo
SELECT datname, idle_in_transaction_time, active_time, session_time
, sessions_killed, sessions_fatal, sessions_abandoned
, sessions AS sessions_established
FROM pg_stat_database
;

\echo Summary of session state
\echo
SELECT state, COUNT(*)
FROM pg_stat_activity
GROUP BY state
ORDER BY state
;

SELECT usename --, usesysid
, datname --, datid
, state, state_change
, wait_event_type, wait_event
, xact_start
, application_name
--, query_id, query_start, query
, client_addr, client_port
, pid
--, backend_type, backend_start
FROM pg_stat_activity
WHERE state is NOT NULL
;

\echo State of Transaction
\echo
SELECT *
FROM (VALUES ('active', 'executing a query.')
, ('idle', 'waiting for a new client command.')
, ('idle in transaction', 'in a transaction, but not currently executing a query.')
, ('idle in transaction (aborted)', 'similar to idle in transaction, except one of the statements in the transaction caused an error.')
, ('fastpath function call', 'executing a fast-path function.')
, ('disabled', 'track_activities is disabled')
) AS state_backend (state, description)
ORDER BY state
;
