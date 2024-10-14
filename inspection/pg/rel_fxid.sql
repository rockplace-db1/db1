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
\t on
SELECT CURRENT_TIMESTAMP ;
\t off
\echo ------------------------------------------------------------
\echo * Database Size and Age (Database '''':vc_db_name'''')
\echo ------------------------------------------------------------
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
\echo ------------------------------------------------------------
\echo * User Tables by Age (Top :N_ROWS_RETURNED)
\echo ------------------------------------------------------------
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
