--
-- 10 Oct 2023 Created
--
SELECT DB_NAME(s.database_id)+' ('+CAST(s.database_id AS varchar)+')' AS "DB name"
, OBJECT_NAME(i.object_id)+' ('+CAST(i.object_id AS varchar)+')' AS "Table name"
, i.name+' ('+CAST(i.index_id AS varchar)+')' AS "index name"
, s.avg_fragmentation_in_percent 
, i.type_desc+' ('+CAST(type AS varchar)+')' AS "index type"
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'DETAILED') s
INNER JOIN sys.indexes i
ON i.object_id = s.object_id
WHERE s.avg_fragmentation_in_percent > 50
AND i.index_id = s.index_id
ORDER BY 2, 3
