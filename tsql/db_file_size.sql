--
-- 01 Nov 2023 Replaced sys.data_spaces with sys.master_files
-- 31 Oct 2023 Updated, f.is_sparse, Logical and Physical Filename
-- 11 Oct 2023 Created
--
SELECT d.name+' ('+CAST(d.database_id AS VARCHAR)+')'
, f.name+' ('+CAST(f.file_id AS varchar)+')' AS "Logical Filename(id)"
, f.type_desc+' ('+CAST(f.type AS varchar)+')' AS "File type"
, f.is_sparse
, CASE WHEN f.data_space_id = 0 THEN '0 (Log)'
ELSE CAST(f.data_space_id AS varchar)
END AS "Data space"
, CAST(f.size * 8192 / 1048576 AS decimal(8,2)) AS "File size (MB)"
, f.growth
, CASE WHEN f.is_percent_growth = 1 THEN '%'
WHEN f.is_percent_growth = 0 THEN 'Pages'
ELSE CHAR(f.is_percent_growth) END AS "Growth Unit"
, f.max_size
, f.physical_name AS "Physical Filename"
FROM sys.databases d
INNER JOIN sys.master_files f
ON d.database_id = f.database_id
--WHERE d.name NOT IN ('tempdb', 'master', 'msdb', 'model')
ORDER BY 1
