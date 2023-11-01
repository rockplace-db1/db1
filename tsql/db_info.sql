--
-- 31 Oct 2023 Updated, VALUES from CASE
-- 05 Oct 2023 Created, CASE
-- 
SELECT d.name+' ('+CAST(d.database_id AS VARCHAR)+')', d.source_database_id
, c.str+' ('+CAST(d.compatibility_level AS VARCHAR)+')'AS compatibility_level
, d.recovery_model_desc+' ('+CAST(d.recovery_model AS VARCHAR)+')' AS recovery_model_info
, d.state_desc+' ('+CAST(d.state AS VARCHAR)+')' AS state_info
, d.is_auto_update_stats_on, d.is_auto_create_stats_on
FROM sys.databases d
LEFT OUTER JOIN (VALUES (70, '7.0 through 10.0.x (2008)')
, (80, '8.x (2000) through 10.50.x (2008 R2)')
, (90, '10.0.x (2008) through 10.50.x (2008 R2)')
, (100, '10.0.x, 2008')
, (110, '11.x, 2012')
, (120, '12.x, 2014')
, (130, '13.x, 2016')
, (140, '14.x, 2017')
, (150, '15.x, 2019')
, (160, '16.x, 2022')
) AS c (num, str)
ON d.compatibility_level = c.num
WHERE d.name NOT IN ('tempdb', 'master', 'msdb', 'model')
ORDER BY d.name ASC
