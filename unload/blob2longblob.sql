--
-- Rockplace, internal use only
--
-- 09 June 2023 Set LineSize 32766 = vc_str + 2
-- 23 Apr 2023  Created, BLOB to LongBLOB
--
set pagesize 0
set LineSize 32766
set trimSpool on
set feedback off
set serveroutput on
spool table11_col02_101.sql
DECLARE
  n_col01 NUMBER ;
  
  blob01 BLOB ;  n_length NUMBER ; 
  n_offset NUMBER := 1 ;  n_amount NUMBER := 16382 ;  
  r_buf RAW(16382) ;  vc_str VARCHAR2(32764) ; 
BEGIN
  n_col01 := 101 ;
  SELECT col02 INTO blob01 FROM table11 WHERE col01 = n_col01 ;
  
  n_length := DBMS_LOB.getLength(blob01) ;
  DBMS_LOB.open(blob01, DBMS_LOB.LOB_READONLY) ;
  DBMS_output.enable(NULL) ;
  DBMS_output.put_line('set @v1 = '||n_col01||' ;') ; 
  DBMS_output.put_line('set @v2 = ''''') ;
  LOOP
    DBMS_LOB.read(blob01, n_amount, n_offset, r_buf) ;
    n_offset := n_offset + n_amount ;
    vc_str := RawToHex(r_buf) ;
    DBMS_output.put_line(''''||vc_str||'''') ;
    EXIT WHEN n_offset > n_length ;
  END LOOP ;
  DBMS_LOB.close(blob01) ;
  DBMS_output.put_line(';') ;  DBMS_output.put_line(' ') ;
  DBMS_output.put_line('UPDATE table31 SET col02 = UNHEX(@v2) WHERE col01 = @v1 ;') ; 
EXCEPTION
  WHEN OTHERS THEN 
    DBMS_LOB.close(blob01) ;
    DBMS_output.put_line(SQLErrM) ;
END ;
/
set feedback on
spool off
