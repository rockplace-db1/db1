--
-- 27 June 2023 Created
--
\set PV_DB_NAME 'edb'

SELECT current_timestamp
, current_database()
;

SELECT pg_size_pretty(pg_database_size(:'PV_DB_NAME'))
, pg_database_size(:'PV_DB_NAME')
;

SELECT datname, age(datfrozenxid) 
FROM pg_database
WHERE datname = :'PV_DB_NAME'
;
--SELECT c.oid::regclass as table_name,
--       greatest(age(c.relfrozenxid),age(t.relfrozenxid)) as age
--FROM pg_class c
--LEFT JOIN pg_class t ON c.reltoastrelid = t.oid
--WHERE c.relkind IN ('r', 'm')
--;

SELECT count(*)
FROM pg_stat_activity
;
\unset PV_DB_NAME