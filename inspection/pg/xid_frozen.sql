-- 
-- 07 July 24 Created
-- 
\conninfo
\echo ****************************************
\echo * User Tables by Age
\echo ****************************************
SELECT c.relnamespace::regnamespace, c.relname
--, c.oid
, GREATEST(age(t.c_xid), age(t.t_xid)) AS age
, t.c_oid, age(t.c_xid) AS c_age, t.c_xid
, t.t_oid, age(t.t_xid) AS t_age, t.t_xid
FROM
( -- TOASTed tables
  SELECT c.oid AS c_oid
  , c.relfrozenxid AS c_xid
  , t.oid AS t_oid
  , t.relfrozenxid AS t_xid
  FROM pg_class c
  INNER JOIN
  ( SELECT oid
    , reltoastrelid
    , relfrozenxid
    FROM pg_class
  ) t
  ON c.reltoastrelid = t.oid
  UNION ALL
  -- not TOASTed
  SELECT c.oid AS c_oid
  , c.relfrozenxid AS c_xid
  , c.oid AS t_oid
  , c.relfrozenxid AS t_xid
  FROM pg_class c
  INNER JOIN
  ( SELECT oid
    FROM pg_class
    WHERE relfrozenxid <> 0
    EXCEPT
    SELECT oid
    FROM pg_class
    WHERE reltoastrelid <> 0
    EXCEPT 
    SELECT reltoastrelid 
    FROM pg_class
    WHERE reltoastrelid <> 0
  ) t
  ON c.oid = t.oid
) t
INNER JOIN pg_class c
ON t.c_oid = c.oid
INNER JOIN pg_namespace n
ON c.relnamespace = n.oid
WHERE n.nspname NOT IN ('sys', 'pg_catalog', 'information_schema')
ORDER BY age DESC
