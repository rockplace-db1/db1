--
-- Rockplace, internal use only
--
-- 07 June 2023 Created, stats of user tables in a database

select current_timestamp
, current_database() ;

select schemaname, relname
, n_live_tup, n_dead_tup
, to_char(last_autovacuum, 'YYYY-MM-DD') AS last_autovac
, autovacuum_count AS autovac_count
, to_char(last_analyze, 'YYYY-MM-DD') AS last_analyze
, analyze_count
from pg_stat_user_tables
order by schemaname, relname ;