-- 
-- 21 March 24 Updated
-- 17 Sep 2023 Created
-- 
--select current_timestamp, current_database(), pg_backend_pid() ;

--select version() ;

select d.datname as "DB name"
, case
when d.size >= 1099511627776
THEN to_char(d.size / 1099511627776.0, '999D999') || ' TB'
WHEN d.size >= 1073741824
THEN to_char(d.size / 1073741824.0, '999D999') || ' GB'
WHEN d.size >= 1048576
THEN to_char(d.size / 1048576.0, '999D999') || ' MB'
WHEN d.size >= 1024
THEN to_char(d.size / 1024.0, '999D999') || ' KB'
ELSE to_char(d.size, '999') || ' byte(s)' END AS "DB size"
, to_char(age, '9,999,999,999') AS "DB age"
, d.dattablespace
, d.encoding
from (
select d.datname
--, d.oid
, pg_database_size(d.oid) AS "size"
, age(d.datfrozenxid) AS "age"
, d.dattablespace
, pg_encoding_to_char(d.encoding) AS "encoding"
--, d.encoding
--, d.datistemplate
--, d.datallowconn, d.datconnlimit
from pg_database d
where d.datname not in ('edb', 'postgres', 'template1', 'template0')
and d.datistemplate = false
) d ;

--\l+

--select *
--from pg_tablespace ;

--\db+
