--
-- 22 Sep 2023 Created
--
\set n_row 10
\echo n_row is set to :n_row
\set strLen 80
\echo strLen is set to :strLen
\echo

SELECT current_timestamp, current_schema, current_database() ;
SELECT current_user, session_user, pg_backend_pid() ;
SELECT version() ;

SELECT stats_reset, dealloc FROM pg_stat_statements_info ;

SELECT name, setting FROM pg_settings WHERE name LIKE 'pg_stat_statements.%' ;

\echo SQL by duration (elapsed time)
\echo
SELECT u.usename
, s.queryid, s.calls
, s.max_exec_time
--, s.stddev_plan_time AS stddev_time
, s.mean_exec_time, s.min_exec_time 
, substring(s.query for :strLen)
FROM pg_stat_statements s
, pg_user u
WHERE s.userid = u.usesysid
AND s.toplevel
--AND u.usename NOT IN ('enterprisedb', 'postgres')
ORDER BY s.max_exec_time DESC
LIMIT :n_row ;

\echo SQL by temporary blocks
\echo
SELECT u.usename
, s.queryid, s.calls
, s.temp_blks_read, s.temp_blks_written
, substring(s.query for :strLen)
FROM pg_stat_statements s
, pg_user u
WHERE s.userid = u.usesysid
AND s.toplevel
--AND u.usename NOT IN ('enterprisedb', 'postgres')
ORDER BY s.temp_blks_written DESC
LIMIT :n_row ;

\echo SQL by execution (count)
\echo
SELECT u.usename
, s.queryid, s.calls
, substring(s.query for :strLen)
FROM pg_stat_statements s
, pg_user u
WHERE s.userid = u.usesysid
AND s.toplevel
--AND u.usename NOT IN ('enterprisedb', 'postgres')
ORDER BY s.calls DESC
LIMIT :n_row ;