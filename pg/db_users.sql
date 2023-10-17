--
-- 13 Oct 2023 Created
--
-- https://www.enterprisedb.com/docs/epas/11/epas_compat_cat_views/56_dba_users/
-- https://www.postgresql.org/docs/16/monitoring-stats.html#MONITORING-PG-STAT-ACTIVITY-VIEW
--
SELECT current_timestamp, current_database(), pg_backend_pid() 
;

SELECT name, setting, unit, context
FROM pg_settings
WHERE name IN
( 'compute_query_id'
, 'track_activities', 'track_activity_query_size'
, 'log_hostname', 'max_connections'
)
;

SELECT COUNT(*) 
FROM pg_stat_activity 
;

SELECT usename, usesysid, datname, datid
, state, state_change, wait_event_type, wait_event
, xact_start
, application_name
, query_id, query_start
, client_addr, client_port
, pid, backend_type, backend_start
FROM pg_stat_activity
WHERE state is NOT NULL
;

SELECT state, COUNT(*)
FROM pg_stat_activity
GROUP BY state
ORDER BY state
;

SELECT *
FROM (VALUES ('active', 'executing a query.')
, ('idle', 'waiting for a new client command.')
, ('idle in transaction', 'in a transaction, but not currently executing a query.')
, ('idle in transaction (aborted)', 'similar to idle in transaction, except one of the statements in the transaction caused an error.')
, ('fastpath function call', 'executing a fast-path function.')
, ('disabled', 'track_activities is disabled')
) AS state_backend (str, description)
ORDER BY str
;

SELECT username, user_id
, account_status, lock_date, expiry_date
--, default_tablespace
FROM dba_users
WHERE account_status != 'OPEN'
;
