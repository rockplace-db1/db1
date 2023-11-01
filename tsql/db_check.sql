--
-- 31 Oct 2023
-- 
SELECT 'dbcc checkdb('''+name+''') with NO_INFOMSGS '
--, PHYSICAL_ONLY
FROM sys.databases
--WHERE name NOT IN ('tempdb', 'master', 'msdb', 'model')
ORDER BY name ASC
