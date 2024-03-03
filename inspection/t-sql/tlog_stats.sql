DECLARE @v1 int ;
SET @v1 = 5 ;
SELECT database_id, recovery_model
, CURRENT_TIMESTAMP, log_end_lsn, log_min_lsn
, log_recovery_lsn, recovery_vlf_count, log_recovery_size_mb
, log_checkpoint_lsn, log_since_last_checkpoint_mb
, log_backup_time, log_backup_lsn, log_since_last_log_backup_mb
, current_vlf_sequence_number, current_vlf_size_mb
, active_vlf_count, active_log_size_mb
, total_vlf_count, total_log_size_mb
FROM sys.dm_db_log_stats(@v1)
