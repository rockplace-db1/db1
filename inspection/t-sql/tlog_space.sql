--USE iowa ;
SELECT DB_NAME(database_id) AS "DB name", database_id
, STR(used_in_percent, 7, 3) + ' %' AS "Used %"
, STR(free_in_percent, 7, 3) + ' %' AS "Free %"
, CASE
WHEN used_in_bytes >= 1099511627776
THEN STR(used_in_bytes / 1099511627776.0, 7, 3) + ' TB'
WHEN used_in_bytes >= 1073741824
THEN STR(used_in_bytes / 1073741824.0, 7, 3) + ' GB'
WHEN used_in_bytes >= 1048576
THEN STR(used_in_bytes / 1048576.0, 7, 3) + ' MB'
WHEN used_in_bytes >= 1024
THEN STR(used_in_bytes / 1024.0, 7, 3) + ' KB'
ELSE CAST(used_in_bytes AS varchar) + ' byte(s)' END AS Used
, CASE
WHEN free_in_bytes >= 1099511627776
THEN STR(free_in_bytes / 1099511627776.0, 7, 3) + ' TB'
WHEN free_in_bytes >= 1073741824
THEN STR(free_in_bytes / 1073741824.0, 7, 3) + ' GB'
WHEN free_in_bytes >= 1048576
THEN STR(free_in_bytes / 1048576.0, 7, 3) + ' MB'
WHEN free_in_bytes >= 1024
THEN STR(free_in_bytes / 1024.0, 7, 3) + ' KB'
ELSE CAST(free_in_bytes AS varchar) + ' byte(s)' END AS Free
, CASE
WHEN total_in_bytes >= 1099511627776
THEN STR(total_in_bytes / 1099511627776.0, 7, 3) + ' TB'
WHEN total_in_bytes >= 1073741824
THEN STR(total_in_bytes / 1073741824.0, 7, 3) + ' GB'
WHEN total_in_bytes >= 1048576
THEN STR(total_in_bytes / 1048576.0, 7, 3) + ' MB'
WHEN total_in_bytes >= 1024
THEN STR(total_in_bytes / 1024.0, 7, 3) + ' KB'
ELSE CAST(total_in_bytes AS varchar) + ' byte(s)' END AS Total
FROM
( SELECT database_id
  , used_log_space_in_percent AS used_in_percent
  , ((total_log_size_in_bytes - used_log_space_in_bytes) * 100.0 / total_log_size_in_bytes)  AS free_in_percent
  , used_log_space_in_bytes AS used_in_bytes
  , total_log_size_in_bytes - used_log_space_in_bytes AS free_in_bytes
  , total_log_size_in_bytes AS total_in_bytes
  FROM sys.dm_db_log_space_usage
) v
