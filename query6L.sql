--
-- 02 Aug 2023 Created, pg_locks
--
\set PV_DB_NAME pagila
\set PV_DB_OID 16620
\set PV_TAB_OID 16740
\set PV_OS_PID 24228

SELECT current_timestamp
, current_database()
;

SELECT locktype, mode, pid, granted, waitstart
, database, relation, page, tuple
FROM pg_locks
WHERE mode LIKE '%ExclusiveLock'
--WHERE mode in ('', 'RowExclusiveLock')
AND database = :PV_DB_OID
;

SELECT locktype, mode, pid, granted, waitstart
, database, relation, page, tuple
FROM pg_locks
WHERE database = :PV_DB_OID
;

SELECT l.locktype, l.mode, l.pid, l.granted, l.waitstart
, l.database, l.relation, l.page, l.tuple, c.relname
FROM pg_locks l
, pg_class c
WHERE l.relation = c.oid
AND mode LIKE '%ExclusiveLock'
AND database = :PV_DB_OID
;

SELECT l.locktype, l.mode, l.pid, l.granted, l.waitstart
, l.database, l.relation, l.page, l.tuple, c.relname
FROM pg_locks l
, pg_class c
WHERE l.relation = c.oid
AND database = :PV_DB_OID
;

SELECT oid, relname, relkind, reltablespace, relfilenode
FROM pg_class
WHERE oid = :PV_TAB_OID
;

SELECT pg_blocking_pids(:PV_OS_PID) ;

SELECT oid, datname
FROM pg_database
WHERE datname = :'PV_DB_NAME'
;
