-- 
-- 13 Sep  24 Renamed VC_DB_NAME to vc_db_name then removed \connect :VC_DB_NAME
-- 19 Aug  24 Replaced regnamespace with nspname for v9.4
-- 12 July 24 Added \pset footer off
-- 09 July 24 Common Table Expression (CTE)
-- 08 July 24 Added pg_database
-- 07 July 24 Created
-- 
\set N_ROWS_RETURNED 5

SELECT current_database() AS vc_db_name
\gset
\pset footer off
--\t on
--SELECT CURRENT_TIMESTAMP ;
--\t off
\echo ------------------------------
\echo * Database Size and Age 
\echo ------------------------------
SELECT d.datname AS "DB name"
--, pg_size_pretty(pg_database_size(oid)) AS "DB size"
, CASE
WHEN d.size >= 1099511627776
THEN to_char(d.size / 1099511627776.0, '999D999') || ' TB'
WHEN d.size >= 1073741824
THEN to_char(d.size / 1073741824.0, '999D999') || ' GB'
WHEN d.size >= 1048576
THEN to_char(d.size / 1048576.0, '999D999') || ' MB'
WHEN d.size >= 1024
THEN to_char(d.size / 1024.0, '999D999') || ' KB'
ELSE to_char(d.size, '999') || ' byte(s)' END AS "DB size"
, to_char(age(d.datfrozenxid), '9,999,999,999') AS "DB age"
, d.datfrozenxid AS "DB Frozen xid"
FROM 
( SELECT datname
  , pg_database_size(oid) AS size
  , datfrozenxid
  FROM pg_database
  WHERE datname = :'vc_db_name'
) d
;
\echo ----------------------------------------
\echo * User Tables by Age (Top :N_ROWS_RETURNED)
\echo ----------------------------------------
WITH v AS
( -- TOASTed tables
  SELECT m.oid AS m_oid
  , m.relfrozenxid AS m_fxid
  , t.oid AS t_oid
  , t.relfrozenxid AS t_fxid
  FROM pg_class m
  INNER JOIN
  ( SELECT oid
    , reltoastrelid
    , relfrozenxid
    FROM pg_class
  ) t
  ON m.reltoastrelid = t.oid
  UNION ALL
  -- not TOASTed
  SELECT m.oid AS m_oid
  , m.relfrozenxid AS m_fxid
  , m.oid AS t_oid
  , m.relfrozenxid AS t_fxid
  FROM pg_class m
  INNER JOIN
  ( SELECT oid
    FROM pg_class
    WHERE age(relfrozenxid) <> 2147483647  -- relfrozenxid::integer <> 0
    EXCEPT
    SELECT oid
    FROM pg_class
    WHERE reltoastrelid <> 0  -- oid <> integer
    EXCEPT 
    SELECT reltoastrelid 
    FROM pg_class
    WHERE reltoastrelid <> 0
  ) t
  ON m.oid = t.oid
)  
SELECT n.nspname AS schema
, c.relname AS table
--, c.oid
, to_char(GREATEST(age(v.m_fxid), age(v.t_fxid)), '9,999,999,999') AS age
, CASE WHEN age(v.m_fxid) > age(v.t_fxid) THEN v.m_fxid ELSE v.t_fxid END AS "frozen xid"
--, CASE WHEN v.m_oid = v.t_oid THEN 'N' ELSE 'Y' END AS "TOASTed"
--, v.m_oid AS main_oid
--, to_char(age(v.m_fxid), '9,999,999,999') AS main_age
--, v.m_fxid AS m_frozenxid
--, v.t_oid AS toast_oid
--, to_char(age(v.t_fxid), '9,999,999,999') AS toast_age
--, v.t_fxid AS t_frozenxid
FROM v
INNER JOIN pg_class c
ON v.m_oid = c.oid
INNER JOIN pg_namespace n
ON c.relnamespace = n.oid
WHERE n.nspname NOT IN ('sys', 'pg_catalog', 'information_schema')
ORDER BY age DESC
LIMIT :N_ROWS_RETURNED
;
\pset footer off

-- 
-- 13 Sep 24 Renamed to tab_size from rel_size
-- 12 Sep 24 Tested on v9.4
-- 
\set N_ROWS_RETURNED 10
\set N_BINS 8

\echo ----------------------------------------
\echo * User tables by size in histograms
\echo ----------------------------------------
SELECT COUNT(relid) AS n_tables
FROM pg_stat_user_tables
\gset
--\echo :n_tables

WITH t AS
( SELECT pg_relation_size(relid, 'main') AS tab_size
  FROM pg_stat_user_tables
)
SELECT MAX(tab_size) AS n_max
, MIN(tab_size) AS n_min
, div(MAX(tab_size) - MIN(tab_size), :'N_BINS') AS n_quotient
, (MAX(tab_size) - MIN(tab_size)) % :'N_BINS' AS n_remainder
FROM t
\gset
\echo *
\echo * Distribution of the sizes of user tables within a
\echo * Height-balanced histogram with Max. :N_BINS bucktes(bins)
\echo *
\pset footer off
SELECT current_database() AS current_db
, :n_tables AS n_tables
, :n_max AS max_size
, :n_min AS min_size
, :N_BINS AS n_bins
;
\pset footer on
WITH t AS
( SELECT relid
  , pg_relation_size(relid, 'main') AS n_bytes
  FROM pg_stat_user_tables
)
,v AS
( SELECT relid
  , n_bytes
  , NTILE(:N_BINS) OVER (ORDER BY n_bytes) AS bin_num
  FROM t
)
SELECT v.bin_num
, MIN(v.n_bytes) AS lower_bound
, MAX(v.n_bytes) AS upper_bound
, COUNT(v.relid) AS frequency
FROM v
GROUP BY v.bin_num
ORDER BY v.bin_num
;
\echo *
\echo * Distribution of the sizes of user tables within a
\echo * Frequency histogram with :N_BINS + 1 buckets(bins)
\echo *
\pset footer off
SELECT current_database() AS current_db
, :n_tables AS n_tables
, :n_max AS max_size
, :n_min AS min_size
, :N_BINS + 1 AS n_bins
, :n_quotient AS bin_size
--, :n_remainder AS n_remainder
;
\pset footer on
--\pset fieldsep ','
--\pset format unaligned
WITH b1 AS
( SELECT generate_series(1, :N_BINS + 1) AS bin_num
)
, b2 AS
( SELECT b1.bin_num
  , :n_min + :n_quotient::numeric * (b1.bin_num - 1) AS lower_bound
  , (:n_min + :n_quotient::numeric * b1.bin_num) - 1 AS upper_bound
  FROM b1
)
, t AS
( SELECT relid
  , pg_relation_size(relid, 'main') AS n_bytes
  FROM pg_stat_user_tables
)
, b3 AS
( SELECT width_bucket(n_bytes, :n_min, :n_max, :N_BINS) AS bin_num
  , COUNT(relid) AS frequency
  FROM t
  GROUP BY bin_num
)
SELECT b2.bin_num
, b2.lower_bound
, b2.upper_bound
, COALESCE(b3.frequency, 0) AS frequency
FROM b2
LEFT OUTER JOIN b3
ON b2.bin_num = b3.bin_num
ORDER BY 1
;
--\pset fieldsep '|'
--\pset format aligned
\echo --------------------------------------------------
\echo * User tables ordered by size (Top :N_ROWS_RETURNED)
\echo --------------------------------------------------
WITH t AS
( SELECT u.relid
  , u.schemaname AS ns_name
  , u.relname AS tab_name
  , u.n_dead_tup, u.n_live_tup
  , pg_relation_size(relid) AS n_bytes
  FROM pg_stat_user_tables u
)
SELECT ns_name AS schema_name
, tab_name AS table_name
, CASE
  WHEN n_bytes >= 1099511627776
  THEN to_char(n_bytes / 1099511627776.0, '999D999') || ' TB'
  WHEN n_bytes >= 1073741824
  THEN to_char(n_bytes / 1073741824.0, '999D999') || ' GB'
  WHEN n_bytes >= 1048576
  THEN to_char(n_bytes / 1048576.0, '999D999') || ' MB'
  WHEN n_bytes >= 1024
  THEN to_char(n_bytes / 1024.0, '999D999') || ' KB'
  ELSE to_char(n_bytes, '999') || ' byte(s)' END AS table_size
, n_dead_tup AS dead_tuples
, n_live_tup AS live_tuples
FROM t
ORDER BY n_bytes DESC
LIMIT :N_ROWS_RETURNED
;
