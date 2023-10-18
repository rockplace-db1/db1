--
-- Server Parameters
--
-- 26 Sep 2023 Created at 12:36:57
--
-- Storage
-- Standby
-- Checkpoint
-- Archiving
-- Configuration Files and Directories
-- Network
-- Constants for Cost based optimizer
-- Lock
-- SQL Exec
--
-- https://www.postgresql.org/docs/16/view-pg-settings.html
--
SELECT current_timestamp, pg_backend_pid() ;
SELECT current_user, current_database() ;
SELECT version() ;

SELECT r.pnum, r.pname, r.pvalue AS "Recommended Value"
, c.setting AS "Current Value", c.unit
--, c.context
FROM 
(VALUES (-100, 'cluster_name', '')
, (-59, 'default_tablespace', '')
, (-58, 'block_size', '')
, (-57, 'fsync', 'on')
, (-56, 'log_temp_files', '')
, (-49, 'hot_standby', '')
, (-48, 'synchronous_commit', 'on')
, (-47, 'max_wal_senders', '')
, (-39, 'checkpoint_timeout', '')
, (-38, 'checkpoint_warning', '')
, (-37, 'checkpoint_completion_target', '0.5 - 0.9')
, (-36, 'max_wal_size', '(3 * checkpoint_segments) * 16MB < free space')
, (-35, 'checkpoint_segments', '')
, (-34, 'min_wal_size', '> 80MB')
, (-29, 'archive_mode', 'on')
, (-28, 'archive_command', 'cp %p /.../%f')
, (1, 'data_directory', '')
, (2, 'config_file', '')
, (3, 'hba_file', '')
, (4, 'ident_file', '')
, (5, 'external_pid_file', '')
, (6, 'log_directory', '')
, (7, 'log_filename', '')
, (11, 'listen_addresses', '')
, (12, 'max_connections', '')
, (21, 'shared_buffers', 'between 25% and 40%')
, (22, 'work_mem', 'the formular')
, (23, 'maintenance_work_mem', '256 - 512MB')
, (31, 'compute_query_id', '')
, (32, 'random_page_cost', '')
, (33, 'seq_page_cost', '')
, (34, 'effective_cache_size', '75%')
, (41, 'log_min_messages', 'warning')
, (42, 'client_min_messages', 'notice')
, (43, 'logging_collector', 'on')
, (44, 'log_destination', '')
, (45, 'log_line_prefix', '')
, (46, 'log_timezone', '')
, (51, 'deadlock_timeout', '')
, (52, 'log_lock_waits', '')
, (71, 'log_min_error_statement', 'error')
, (72, 'log_min_duration_statement', '< 5000ms')
, (81, 'track_activities', '')
, (82, 'track_activity_query_size', '')
, (83, 'track_counts', '')
, (84, 'track_functions', '')
, (85, 'track_io_timing', '')
, (86, 'track_wal_io_timing', '')
) AS r (pnum, pname, pvalue)  -- (r)ecommended parameters
INNER JOIN pg_settings c  -- (c)urrrent settings
ON r.pname = c.name
ORDER BY r.pnum
;  -- local, host in pg_hba.conf, random_page_cost=2-3

show shared_buffers ;
show work_mem ;
show maintenance_work_mem ;
