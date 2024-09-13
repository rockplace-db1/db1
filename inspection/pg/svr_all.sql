-- 
-- 14 Aug  24 Added pg_postmaster_start_time()
-- 04 July 24 Added echo ***...
-- 20 June 24 Created for POSCO
-- 
\set N_ROWS_RETURNED 5
\set VC_STATE 'idle in transaction'

\echo ------------------------------------------------------------
\echo * Postmaster and Background worker processes 
\echo ------------------------------------------------------------
\pset footer off
SELECT CURRENT_DATE
, CURRENT_TIMESTAMP - pg_postmaster_start_time() AS elapsed
, pg_postmaster_start_time()
;
\pset footer on
SELECT pid, backend_type, backend_start
FROM pg_stat_activity
WHERE backend_type <> 'client backend'
ORDER BY pid ASC
;

\echo ------------------------------------------------------------
\echo * Backend processes by state and transaction start time
\echo ------------------------------------------------------------
SELECT state, COUNT(*), MIN(xact_start) AS min_xact_start
FROM pg_stat_activity
GROUP BY state
ORDER BY state
;

\pset footer off
\echo ----------------------------------------
\echo * Database Connections
\echo ----------------------------------------
SELECT c.curr_conns AS "Current"
, to_char(c.curr_conns / c.max_conns * 100, '999D99') AS "Percent(%)"
, c.max_conns AS max_connections
FROM 
( SELECT COUNT(*) AS curr_conns 
  , to_number(current_setting('max_connections')) AS max_conns
  FROM pg_stat_activity 
) c
;
\pset footer on

\echo ------------------------------------------------------------
\echo * Backend process(es) in state '''':VC_STATE''''
\echo * ordered by time elapsed in the state (Top :N_ROWS_RETURNED)
\echo ------------------------------------------------------------
SELECT pid, state, state_change
--, xact_start
--, backend_xmin
--, backend_xid
, datname, usename
, client_addr, client_port AS port
, application_name
FROM pg_stat_activity
WHERE state = :'VC_STATE'
ORDER BY state_change ASC
LIMIT :N_ROWS_RETURNED
;
-- 
-- 10 July 24 Added \echo ...
-- 19 Oct 2023 Created, psql v10
-- 
--SELECT current_timestamp, current_database(), pg_backend_pid() ;

--
-- To detect whether this is an EDB Postgres or PG
--
--SELECT COUNT(*) AS is_epas
--FROM pg_settings
--WHERE name = 'oracle_home'
--\gset

--
-- EDB Postgres
--
--\if :is_epas
\echo ------------------------------------------------------------
\echo * DB users with account_status != ''''OPEN''''
\echo ------------------------------------------------------------
SELECT username, user_id, account_status
, lock_date, expiry_date
--, default_tablespace
--, temporary_tablespace
FROM dba_users
WHERE account_status != 'OPEN'
;
--
-- PG
--
--\else
--SELECT rolname, oid
--, rolcanlogin, rolvaliduntil
--FROM pg_roles
--WHERE rolcanlogin
--;
--\endif
-- 
-- 15 Aug  24 Added Client auth. config., pg_hba.conf
-- 14 Aug  24 pg_settings view for restore_command and min_wal_size
-- 10 July 24 Added \echo ...
-- 28 June 24 Created for POSCO
-- 
\t on
\pset footer off
\echo ----------------------------------------
\echo * working memory and temporary file
\echo ----------------------------------------
SELECT p.pname
, current_setting(p.pname) AS pvalue
FROM 
(VALUES (11, 'work_mem')
, (12, 'temp_buffers')
, (13, 'temp_tablespaces')
, (14, 'shared_buffers')
, (15, 'maintenance_work_mem')
) p (pnum, pname)
ORDER BY p.pnum
;
\echo ----------------------------------------
\echo * Write Ahead Log (WAL)
\echo ----------------------------------------
SELECT name
--, context
, unit
, setting
FROM pg_settings
WHERE name IN
( 'min_wal_size'
, 'max_wal_size'
, 'archive_mode'
, 'archive_command'
, 'restore_command'
)
ORDER BY name
;
\echo ----------------------------------------
\echo * Auto vacuum
\echo ----------------------------------------
SELECT p.pname
, current_setting(p.pname) AS pvalue
FROM 
(VALUES (31, 'autovacuum')
, (32, 'track_counts')
, (33, 'vacuum_freeze_min_age')
, (34, 'autovacuum_freeze_max_age')
, (35, 'vacuum_freeze_table_age')
) p (pnum, pname)
ORDER BY p.pnum
;
\echo ----------------------------------------
\echo * Server Error Log
\echo ----------------------------------------
SELECT p.pname
, current_setting(p.pname) AS pvalue
FROM 
(VALUES (41, 'client_min_messages')
, (42, 'log_min_messages')
, (43, 'log_min_duration_statement')
, (44, 'deadlock_timeout')
, (45, 'log_lock_waits')
, (46, 'log_temp_files')
) p (pnum, pname)
ORDER BY p.pnum
;
\echo ----------------------------------------
\echo * Client auth. config. in pg_hba.conf
\echo ----------------------------------------
--SELECT line_number, type
SELECT type
, database, user_name
, address
, auth_method
, 'at line '||TO_CHAR(line_number)
FROM pg_hba_file_rules
--WHERE type = 'host'
;
\pset footer on
\t off
