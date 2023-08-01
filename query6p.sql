--
-- 01 Aug 2023 Created, pg_settings 
--
\set PARAM_NAME shared_buffers

SELECT current_timestamp, current_database()
;

SELECT name, setting, unit, vartype
, boot_val, reset_val, pending_restart
FROM pg_settings
WHERE name = :'PARAM_NAME'
;
SELECT name, source, sourceline, sourcefile
FROM pg_settings
WHERE name = :'PARAM_NAME'
;
SELECT name, category, short_desc
FROM pg_settings
WHERE name = :'PARAM_NAME'
;