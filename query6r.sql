--
-- 14 Sep 2023 Created, pg_stat_wal_receiver
--
SELECT current_timestamp, current_database(), pg_backend_pid() 
;

SELECT pid, status, slot_name
, receive_start_lsn, receive_start_tli
FROM pg_stat_wal_receiver 
;

SELECT pid, flushed_lsn, written_lsn, received_tli
FROM pg_stat_wal_receiver
;

SELECT pid, last_msg_send_time, last_msg_receipt_time
FROM pg_stat_wal_receiver
;

SELECT pid, latest_end_lsn, latest_end_time
, sender_host, sender_port
FROM pg_stat_wal_receiver
;

SELECT pid, conninfo
FROM pg_stat_wal_receiver
;
show primary_conninfo ;
