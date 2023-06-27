--
-- 20 June 2023 Created
--
SELECT current_timestamp
, current_database()
;
SELECT version()
;

SELECT name, setting
FROM pg_settings
WHERE name in
( 'listen_addresses'
, 'max_connections'
)
;

SELECT name, setting
FROM pg_settings
WHERE name in
( 'shared_buffers'
, 'work_mem', 'maintenance_work_mem'
)
;

SELECT name, setting
FROM pg_settings
WHERE name in 
( 'synchronous_commit'
, 'min_wal_size', 'max_wal_size'
, 'checkpoint_completion_target'
)
;

SELECT name, setting
FROM pg_settings
WHERE name in 
( 'wal_level'
, 'archive_mode'
, 'archive_command'
, 'archive_library'
)
;

SELECT name, setting
FROM pg_settings
WHERE name in 
( 'random_page_cost'
, 'effective_cache_size'
)
;

SELECT name, setting
FROM pg_settings
WHERE name in 
( 'log_destination'
, 'logging_collector'
)
;

SELECT name, setting
FROM pg_settings
WHERE name in 
( 'client_min_messages'
, 'log_min_messages'
, 'log_min_error_statement'
, 'log_min_duration_statement'
)
;

\if true
SELECT name, setting
FROM pg_settings
WHERE name in
( 'log_directory', 'log_filename', 'log_file_mode'
, 'log_rotation_age', 'log_rotation_size', 'log_truncate_on_rotation'
)
\endif
