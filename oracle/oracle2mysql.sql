set LineSize 110
column instance_number format 999
column parameter format a24
column value format a36
alter session set NLS_TIMESTAMP_TZ_FORMAT = 'YYYY-MM-DD HH24:MI:SS.FF TZH:TZM' 
/
SELECT systimestamp FROM DUAL
/
SELECT instance_name, instance_number
, version_full, startup_time, host_name
FROM v$instance
/
SELECT name, dbid, created, platform_name
FROM v$database 
/
SELECT parameter, value
FROM v$nls_parameters
WHERE parameter IN ('NLS_CHARACTERSET', 'NLS_NCHAR_CHARACTERSET')
/
set LineSize 80
-- 
-- Max. Length of an identifier is 30 chars.
-- 
--variable vc_schema_name VARCHAR2(30) ;
--BEGIN
--  :vc_schema_name := 'SYS' ;
--END ;
--/
--show error
--print :vc_schema_name
set PageSize 40
set LineSize 120
column schema_name format a30
column seg_name format a20
column n_segs format 999,999,999
column total_unit format a13
column total_byte format 999,999,999,999,999
prompt 
prompt  * Data objects(segments) by type and size
prompt 
WITH v AS
( SELECT s.owner AS schema_name
  , s.segment_name AS seg_name
  , s.segment_type AS seg_type
  , s.bytes
  FROM dba_segments s
  WHERE s.segment_type IN
  ( 'TABLE', 'TABLE PARTITION', 'TABLE SUBPARTITION'
  , 'INDEX', 'LOBSEGMENT'  --, 'LOBINDEX'
  , 'LOB PARTITION', 'LOB SUBPARTITION'
  )
  AND s.owner NOT IN 
  ( 'SYS', 'SYSTEM', 'SYSBACKUP', 'SYSDG', 'SYSKM', 'SYSRAC'
  , 'APPQOSSYS', 'AUDSYS', 'CTXSYS', 'EXFSYS', 'GGSYS', 'LBACSYS'
  , 'OJVMSYS', 'OLAPSYS', 'OWBSYS', 'WMSYS'
  , 'DBSFWUSER', 'DIP', 'ORACLE_OCM', 'OUTLN', 'PERFSTAT'
  , 'REMOTE_SCHEDULER_AGENT', 'SYS$UMF', 'XS$NULL', 'DGPDB_INT'
  , 'APEX_050100', 'APEX_PUBLIC_USER', 'FLOW_FILES'
  , 'DVSYS', 'DVF' , 'SYSMAN', 'DBSNMP'
  , 'GSMADMIN_INTERNAL', 'GSMCATUSER', 'GSMUSER', 'GSMROOTUSER'
  , 'DMA_COLLECTOR', 'C##DMA_COLLECTOR'
  , 'ORDIM', 'SI_INFORMTN_SCHEMA'
  , 'ORDSYS', 'ORDDATA', 'ORDPLUGINS', 'ORDDATA'
  , 'MDSYS', 'MDDATA', 'SPATIAL_CSW_ADMIN_USR'
  , 'XDB', 'ANONYMOUS'
--  , 'HR' , 'PM', 'OE', 'SH',  'CO'
  )
)
-- 
-- The sizes of data objects by object types
-- 
SELECT v.schema_name
, v.seg_type
, COUNT(*) AS num_segs
, CASE
  WHEN SUM(v.bytes) >= 1099511627776
  THEN TO_CHAR(SUM(v.bytes) / 1099511627776.0, '9,999.999')||' TB'
  WHEN SUM(v.bytes) >= 1073741824
  THEN TO_CHAR(SUM(v.bytes) / 1073741824.0, '9,999.999')||' GB'
  WHEN SUM(bytes) >= 1048576
  THEN TO_CHAR(SUM(v.bytes) / 1048576.0, '9,999.999')||' MB'
  WHEN SUM(bytes) >= 1024
  THEN TO_CHAR(SUM(v.bytes) / 1024.0, '9,999.999')||' KB'
  ELSE TO_CHAR(SUM(v.bytes))||' byte(s)' END AS total_unit
, SUM(v.bytes) AS total_byte
FROM v 
GROUP BY v.schema_name, v.seg_type
ORDER BY v.schema_name, total_byte DESC
;
set PageSize 40
-- 
-- Max. Length of an identifier is 30 chars.
-- 
--variable vc_supported VARCHAR2(1) ;
--variable vc_schema_name VARCHAR2(30) ;
--BEGIN
--  :vc_supported := 'Y' ;
--  :vc_schema_name := 'SYS' ;
--END ;
--/
--show error
--print :vc_schema_name

set PageSize 40
set LineSize 220
prompt 
prompt * Number of columns by data type
prompt 
column schema_name format a30
column col_name format a30
column dat_type format a30
column num_cols format 999,999,999
WITH c AS
( SELECT a.owner AS schema_name
  , a.column_name AS col_name
  , a.data_type AS dat_type
  , 'Y' AS b_supported
  FROM dba_tab_columns a
  WHERE a.data_type IN
  ( 'NUMBER', 'RAW', 'LONG RAW', 'BLOB'
  , 'CHAR', 'VARCHAR2', 'LONG', 'CLOB'
  , 'NCHAR', 'NVARCHAR2', 'NCLOB'
  , 'DATE', 'TIMESTAMP(0)', 'TIMESTAMP(1)', 'TIMESTAMP(2)'
  , 'TIMESTAMP(3)', 'TIMESTAMP(4)', 'TIMESTAMP(5)', 'TIMESTAMP(6)'
  , 'TIMESTAMP(0) WITH TIME ZONE', 'TIMESTAMP(1) WITH TIME ZONE'
  , 'TIMESTAMP(2) WITH TIME ZONE', 'TIMESTAMP(3) WITH TIME ZONE'
  , 'TIMESTAMP(4) WITH TIME ZONE', 'TIMESTAMP(5) WITH TIME ZONE'
  , 'TIMESTAMP(6) WITH TIME ZONE'
  )
  UNION ALL
  SELECT b.owner AS schema_name
  , b.column_name AS col_name
  , b.data_type AS dat_type
  , 'N' AS b_supported
  FROM dba_tab_columns b
  WHERE b.data_type IN
  ( 'ROWID', 'UROWID'
  , 'TIMESTAMP(7)', 'TIMESTAMP(8)', 'TIMESTAMP(9)'
  , 'TIMESTAMP(7) WITH TIME ZONE', 'TIMESTAMP(8) WITH TIME ZONE'
  , 'TIMESTAMP(9) WITH TIME ZONE'
  )
)
, d AS
( SELECT c.b_supported
  , c.dat_type
  , COUNT(*) AS num_cols
  FROM c
  WHERE c.schema_name NOT IN
  ( 'SYS', 'SYSTEM', 'SYSBACKUP', 'SYSDG', 'SYSKM', 'SYSRAC'
  , 'APPQOSSYS', 'AUDSYS', 'CTXSYS', 'EXFSYS', 'GGSYS', 'LBACSYS'
  , 'OJVMSYS', 'OLAPSYS', 'OWBSYS', 'WMSYS'
  , 'DBSFWUSER', 'DIP', 'ORACLE_OCM', 'OUTLN', 'PERFSTAT'
  , 'REMOTE_SCHEDULER_AGENT', 'SYS$UMF', 'XS$NULL', 'DGPDB_INT'
  , 'APEX_050100', 'APEX_PUBLIC_USER', 'FLOW_FILES'
  , 'DVSYS', 'DVF' , 'SYSMAN', 'DBSNMP'
  , 'GSMADMIN_INTERNAL', 'GSMCATUSER', 'GSMUSER', 'GSMROOTUSER'
  , 'DMA_COLLECTOR', 'C##DMA_COLLECTOR'
  , 'ORDIM', 'SI_INFORMTN_SCHEMA'
  , 'ORDSYS', 'ORDDATA', 'ORDPLUGINS', 'ORDDATA'
  , 'MDSYS', 'MDDATA', 'SPATIAL_CSW_ADMIN_USR'
  , 'XDB', 'ANONYMOUS'
--  , 'HR' , 'PM', 'OE', 'SH',  'CO'
  )
  GROUP BY c.b_supported, c.dat_type
  ORDER BY c.b_supported, c.dat_type 
)
-- 
-- The number of columns by col. data types
-- 
SELECT d.dat_type
, d.num_cols
FROM d
ORDER BY d.b_supported DESC
, d.num_cols DESC
;
set PageSize 40
set LineSize 80
-- 
-- Max. Length of an identifier is 30 chars.
-- 
set PageSize 40
set LineSize 90
prompt 
prompt * Views
prompt 
column schema_name format a30
column view_name format a30
column num_views format 999,999
column chars_total format 999,999,999
WITH v AS
( SELECT v.owner AS schema_name
  , v.view_name AS view_name
  , v.text_length AS n_chars
  FROM dba_views v 
  WHERE v.owner NOT IN
  ( 'SYS', 'SYSTEM', 'SYSBACKUP', 'SYSDG', 'SYSKM', 'SYSRAC'
  , 'APPQOSSYS', 'AUDSYS', 'CTXSYS', 'EXFSYS', 'GGSYS', 'LBACSYS'
  , 'OJVMSYS', 'OLAPSYS', 'OWBSYS', 'WMSYS'
  , 'DBSFWUSER', 'DIP', 'ORACLE_OCM', 'OUTLN', 'PERFSTAT'
  , 'REMOTE_SCHEDULER_AGENT', 'SYS$UMF', 'XS$NULL', 'DGPDB_INT'
  , 'APEX_050100', 'APEX_PUBLIC_USER', 'FLOW_FILES'
  , 'DVSYS', 'DVF' , 'SYSMAN', 'DBSNMP'
  , 'GSMADMIN_INTERNAL', 'GSMCATUSER', 'GSMUSER', 'GSMROOTUSER'
  , 'DMA_COLLECTOR', 'C##DMA_COLLECTOR'
  , 'ORDIM', 'SI_INFORMTN_SCHEMA'
  , 'ORDSYS', 'ORDDATA', 'ORDPLUGINS', 'ORDDATA'
  , 'MDSYS', 'MDDATA', 'SPATIAL_CSW_ADMIN_USR'
  , 'XDB', 'ANONYMOUS'
--  , 'HR' , 'PM', 'OE', 'SH',  'CO'
  )
)
-- 
-- 
SELECT v.schema_name
, 'VIEW' AS obj_type
, COUNT(v.view_name) AS num_views
, SUM(v.n_chars) AS chars_total
FROM v
GROUP BY v.schema_name 
ORDER BY chars_total DESC
;
set PageSize 40
-- 
-- Max. Length of an identifier is 30 chars.
-- 
set PageSize 40
set LineSize 90
prompt 
prompt * Stored procedures
prompt 
column schema_name format a30
column obj_type format a30
column num_objs format 999,999,999
column lines_total format 999,999,999
WITH s AS
( SELECT s.owner AS schema_name
  , s.type AS obj_type
  , s.name AS obj_name
  , MAX(s.line) AS n_4k_lines
  FROM dba_source s
  WHERE owner NOT IN
  ( 'SYS', 'SYSTEM', 'SYSBACKUP', 'SYSDG', 'SYSKM', 'SYSRAC'
  , 'APPQOSSYS', 'AUDSYS', 'CTXSYS', 'EXFSYS', 'GGSYS', 'LBACSYS'
  , 'OJVMSYS', 'OLAPSYS', 'OWBSYS', 'WMSYS'
  , 'DBSFWUSER', 'DIP', 'ORACLE_OCM', 'OUTLN', 'PERFSTAT'
  , 'REMOTE_SCHEDULER_AGENT', 'SYS$UMF', 'XS$NULL', 'DGPDB_INT'
  , 'APEX_050100', 'APEX_PUBLIC_USER', 'FLOW_FILES'
  , 'DVSYS', 'DVF' , 'SYSMAN', 'DBSNMP'
  , 'GSMADMIN_INTERNAL', 'GSMCATUSER', 'GSMUSER', 'GSMROOTUSER'
  , 'DMA_COLLECTOR', 'C##DMA_COLLECTOR'
  , 'ORDIM', 'SI_INFORMTN_SCHEMA'
  , 'ORDSYS', 'ORDDATA', 'ORDPLUGINS', 'ORDDATA'
  , 'MDSYS', 'MDDATA', 'SPATIAL_CSW_ADMIN_USR'
  , 'XDB', 'ANONYMOUS'
--  , 'HR' , 'PM', 'OE', 'SH',  'CO'
  )
  GROUP BY s.owner
  , s.type
  , s.name
)
-- 
-- 
SELECT s.schema_name
, s.obj_type
, COUNT(s.obj_name) AS num_objs
, SUM(s.n_4k_lines) AS lines_total
FROM s
GROUP BY s.schema_name, s.obj_type
ORDER BY s.schema_name, lines_total DESC
;
set PageSize 40
-- 
-- Max. Length of an identifier is 30 chars.
-- 
--variable vc_supported VARCHAR2(1) ;
--variable vc_schema_name VARCHAR2(30) ;
--BEGIN
--  :vc_supported := 'N' ;
--  :vc_schema_name := 'SYS' ;
--END ;
--/
--show error
--print :vc_schema_name

set PageSize 40
set LineSize 100
prompt 
prompt * Database Objects
prompt 
column schema_name format a30
column obj_name format a30
WITH c AS
( SELECT a.owner AS schema_name
  , a.object_name AS obj_name
  , a.object_type AS obj_type
  , 'Y' AS b_supported
  FROM dba_objects a
  WHERE a.object_type IN
  ( 'TABLE', 'TABLE PARTITION', 'TABLE SUBPARTITION'
  , 'INDEX', 'LOB', 'LOB PARTITION'
  )
  UNION ALL
  SELECT b.owner AS schema_name
  , b.object_name AS obj_name
  , b.object_type AS obj_type
  , 'N' AS b_supported
  FROM dba_objects b
  WHERE b.object_type IN
  ( 'INDEX SUBPARTITION', 'SEQUENCE', 'VIEW', 'SYNONYM'
  , 'TRIGGER', 'PROCEDURE', 'FUNCTION', 'PACKAGE', 'PACKAGE BODY'
  , 'TYPE', 'TYPE BODY', 'DATABASE LINK'
  -- Scheduler jobs
  , 'PROGRAM', 'JOB', 'JOB CLASS', 'SCHEDULE', 'SCHEDULER GROUP'
  )
)
, d AS
( SELECT c.schema_name
  , c.obj_type
  , c.b_supported
  , COUNT(*) AS num_objs
  FROM c
  WHERE schema_name NOT IN 
  ( 'SYS', 'SYSTEM', 'SYSBACKUP', 'SYSDG', 'SYSKM', 'SYSRAC'
  , 'APPQOSSYS', 'AUDSYS', 'CTXSYS', 'EXFSYS', 'GGSYS', 'LBACSYS'
  , 'OJVMSYS', 'OLAPSYS', 'OWBSYS', 'WMSYS'
  , 'DBSFWUSER', 'DIP', 'ORACLE_OCM', 'OUTLN', 'PERFSTAT'
  , 'REMOTE_SCHEDULER_AGENT', 'SYS$UMF', 'XS$NULL', 'DGPDB_INT'
  , 'APEX_050100', 'APEX_PUBLIC_USER', 'FLOW_FILES'
  , 'DVSYS', 'DVF' , 'SYSMAN', 'DBSNMP'
  , 'GSMADMIN_INTERNAL', 'GSMCATUSER', 'GSMUSER', 'GSMROOTUSER'
  , 'DMA_COLLECTOR', 'C##DMA_COLLECTOR'
  , 'ORDIM', 'SI_INFORMTN_SCHEMA'
  , 'ORDSYS', 'ORDDATA', 'ORDPLUGINS', 'ORDDATA'
  , 'MDSYS', 'MDDATA', 'SPATIAL_CSW_ADMIN_USR'
  , 'XDB', 'ANONYMOUS'
--  , 'HR' , 'PM', 'OE', 'SH',  'CO'
  )
  GROUP BY c.schema_name, c.obj_type, c.b_supported
)
-- 
-- The number of objects by types
-- 
SELECT d.schema_name
, d.obj_type
, d.num_objs
FROM d
ORDER BY d.b_supported DESC, d.num_objs DESC
;
set PageSize 40
