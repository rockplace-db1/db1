--
-- 19 Oct 2023 Created
--
SELECT current_timestamp, current_database(), pg_backend_pid() ;

--
-- To detect whether this is an EDB Postgres or PG
--
SELECT COUNT(*) AS is_edb_pg
FROM pg_settings
WHERE name = 'oracle_home'
\gset

--
-- EDB Postgres
--
\if :is_edb_pg
SELECT username, user_id, account_status
, lock_date, expiry_date
--, default_tablespace
FROM dba_users
WHERE account_status != 'OPEN'
;
--
-- PG
--
\else
SELECT rolname, oid
, rolcanlogin, rolvaliduntil
FROM pg_roles
WHERE rolcanlogin
;
\endif
