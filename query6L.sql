--
-- 27 July 2023 Created at 18:01
--
\set PV_DB_NAME 'template1'
\set PV_ID_ROLE 10

SELECT current_timestamp
, current_database()
;

PREPARE select11(varchar) AS
SELECT datname
, (aclexplode(datacl)).grantor
, (aclexplode(datacl)).grantee
, (aclexplode(datacl)).privilege_type
, (aclexplode(datacl)).is_grantable
FROM pg_database
WHERE datname = $1
;

PREPARE select21(int) AS
SELECT oid, rolname
, rolsuper, rolcanlogin
FROM pg_roles
WHERE oid = $1
;

EXECUTE select11(:'PV_DB_NAME') ;
SELECT oid, rolname
, rolsuper, rolcanlogin
FROM pg_roles
;

DEALLOCATE select11 ;
DEALLOCATE select21 ;