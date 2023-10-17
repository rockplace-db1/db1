--
-- 17 Sep 2023 Created
--
select current_timestamp, current_database(), pg_backend_pid() ;

select version() ;

select d.datname, d.oid
, pg_size_pretty(pg_database_size(d.oid)) 
, age(d.datfrozenxid)
, d.dattablespace
, pg_encoding_to_char(d.encoding)
, d.encoding
, d.datistemplate
, d.datallowconn, d.datconnlimit
from pg_database d ;

\l+

select *
from pg_tablespace ;

\db+
