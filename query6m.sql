--
-- 08 May 2023 Created
--
-- 54.2. pg_available_extensions (15)
-- 54.3. pg_available_extension_versions (15)
--
PREPARE select11 AS
SELECT oid, extname, extversion, extnamespace, extowner
FROM pg_extension
ORDER BY extname
;

PREPARE select21 AS 
SELECT name, installed_version, default_version, comment
FROM pg_available_extensions 
--WHERE name in ('edb_dblink_oci', 'edb_dblink_libpq', 'postgres_fdw')
ORDER BY name
;

SELECT current_timestamp
, current_database()
;

execute select11 ;
execute select21 ;

DEALLOCATE select11 ;
DEALLOCATE select21 ;