-- 
-- 11 Sep 24 Updated
-- 15 Aug 28 Created
-- 
\set N_ROWS_RETURNED 10
\pset footer off
SELECT COUNT(*) AS n_user_tables
FROM pg_stat_user_tables
\gset
SELECT COUNT(*) AS n_not_collected
FROM pg_stat_user_tables
--WHERE last_analyze IS NULL AND last_autoanalyze IS NULL
WHERE analyze_count = 0 AND autoanalyze_count = 0
\gset
SELECT COUNT(*) AS n_collected
FROM pg_stat_user_tables
--WHERE last_analyze IS NOT NULL OR last_autoanalyze IS NOT NULL
WHERE analyze_count > 0 OR autoanalyze_count > 0
\gset
\echo ------------------------------------------------------------
\echo * User tables by planner statistics collection (ANALYZE)
\echo ------------------------------------------------------------
SELECT current_database()
, :n_user_tables AS user_tables
, :n_collected AS stats_collected
, :n_not_collected AS not_collected
--, pg_backend_pid()
;
\pset footer on
\echo ------------------------------------------------------------
\echo * User tables by time that stats. collected (Top :N_ROWS_RETURNED)
\echo ------------------------------------------------------------
WITH u AS
( SELECT relid
  , schemaname, relname
  , n_dead_tup, n_live_tup
  , 'M' AS b
  , last_analyze AS t
  FROM pg_stat_user_tables
  WHERE last_analyze IS NOT NULL AND last_autoanalyze IS NULL
  UNION ALL
  SELECT relid
  , schemaname, relname
  , n_dead_tup, n_live_tup
  , 'A' AS b
  , last_autoanalyze AS t
  FROM pg_stat_user_tables
  WHERE last_analyze IS NULL AND last_autoanalyze IS NOT NULL
  UNION ALL
  SELECT relid
  , schemaname, relname
  , n_dead_tup, n_live_tup
  , CASE WHEN last_analyze > last_autoanalyze 
      THEN 'M'
      ELSE 'A'
    END AS b
  , CASE WHEN last_analyze > last_autoanalyze 
      THEN last_analyze
      ELSE last_autoanalyze
    END AS t
  FROM pg_stat_user_tables
  WHERE last_analyze IS NOT NULL AND last_autoanalyze IS NOT NULL
)
SELECT schemaname AS schema
, relname AS table_name
, t AS time_collected
, CASE
    WHEN b = 'M' THEN 'Manual'
    WHEN b = 'A' THEN 'Auto'
    END AS collect_by
--, n_dead_tup AS dead_tuples
--, n_live_tup AS live_tuples
FROM u
ORDER BY t ASC
LIMIT :N_ROWS_RETURNED
;
\echo ----------------------------------------------------------------------
\echo * User tables by dead tuples (Top :N_ROWS_RETURNED)
\echo ----------------------------------------------------------------------
WITH u AS
( SELECT relid
  , schemaname, relname
  , n_dead_tup, n_live_tup
  , 'M' AS b
  , last_analyze AS t
  FROM pg_stat_user_tables
  WHERE last_analyze IS NOT NULL AND last_autoanalyze IS NULL
  UNION ALL
  SELECT relid
  , schemaname, relname
  , n_dead_tup, n_live_tup
  , 'A' AS b
  , last_autoanalyze AS t
  FROM pg_stat_user_tables
  WHERE last_analyze IS NULL AND last_autoanalyze IS NOT NULL
  UNION ALL
  SELECT relid
  , schemaname, relname
  , n_dead_tup, n_live_tup
  , CASE WHEN last_analyze > last_autoanalyze 
      THEN 'M'
      ELSE 'A'
    END AS b
  , CASE WHEN last_analyze > last_autoanalyze 
      THEN last_analyze
      ELSE last_autoanalyze
    END AS t
  FROM pg_stat_user_tables
  WHERE last_analyze IS NOT NULL AND last_autoanalyze IS NOT NULL
)
SELECT schemaname AS schema
, relname AS table_name
, n_dead_tup AS dead_tuples
, n_live_tup AS live_tuples
--, t AS time_collected
, CASE
    WHEN b = 'M' THEN 'Manual'
    WHEN b = 'A' THEN 'Auto'
    END AS collect_by
, pg_relation_size(relid) AS table_size
FROM u
ORDER BY dead_tuples DESC
, live_tuples DESC
, table_size DESC
LIMIT :N_ROWS_RETURNED
;
\echo ----------------------------------------------------------------------
\echo * User tables by dead tuples per live ones in percent (Top :N_ROWS_RETURNED)
\echo ----------------------------------------------------------------------
WITH u AS
( SELECT relid
  , schemaname, relname
  , n_dead_tup, n_live_tup
  , 'M' AS b
  , last_analyze AS t
  FROM pg_stat_user_tables
  WHERE last_analyze IS NOT NULL AND last_autoanalyze IS NULL
  UNION ALL
  SELECT relid
  , schemaname, relname
  , n_dead_tup, n_live_tup
  , 'A' AS b
  , last_autoanalyze AS t
  FROM pg_stat_user_tables
  WHERE last_analyze IS NULL AND last_autoanalyze IS NOT NULL
  UNION ALL
  SELECT relid
  , schemaname, relname
  , n_dead_tup, n_live_tup
  , CASE WHEN last_analyze > last_autoanalyze 
      THEN 'M'
      ELSE 'A'
    END AS b
  , CASE WHEN last_analyze > last_autoanalyze 
      THEN last_analyze
      ELSE last_autoanalyze
    END AS t
  FROM pg_stat_user_tables
  WHERE last_analyze IS NOT NULL AND last_autoanalyze IS NOT NULL
)
SELECT schemaname AS schema
, relname AS table_name
, TO_CHAR(n_dead_tup::numeric / n_live_tup * 100, '999,990D999') AS percent
, n_dead_tup AS dead_tuples
, n_live_tup AS live_tuples
--, t AS time_collected
--, b AS collected_by
, pg_relation_size(relid) AS table_size
FROM u
WHERE n_live_tup > 0  -- ERROR:  division by zero
ORDER BY percent DESC
, dead_tuples DESC
, live_tuples DESC
, table_size DESC
LIMIT :N_ROWS_RETURNED
;
\pset footer on
--  , pg_indexes_size(relid) AS index_size
--  , pg_total_relation_size(relid) AS total_size
