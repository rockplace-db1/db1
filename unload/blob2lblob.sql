--
-- Rockplace, internal use only
--
-- 08 June 2023 Created, BLOB to (MEDIUM|LONG)BLOB
--
set pagesize 0
set LineSize 16383
set feedback off
set serveroutput on
spool table11_col02_79.sql
DECLARE
  n_col01 NUMBER ;
  
  blob01 BLOB ;  n_length NUMBER ; 
  n_offset NUMBER := 1 ;  n_amount NUMBER := 80 ;  
  r_buf RAW(80) ;  vc_str VARCHAR2(160) ; 
BEGIN
  n_col01 := 79 ;
  SELECT col02 INTO blob01 FROM table11 WHERE col01 = n_col01 ;
  
  n_length := DBMS_LOB.getLength(blob01) ;
  DBMS_LOB.open(blob01, DBMS_LOB.LOB_READONLY) ;
  DBMS_output.enable(NULL) ;
  DBMS_output.put_line('UPDATE table31 SET col02 = X''''') ;
  LOOP
    DBMS_LOB.read(blob01, n_amount, n_offset, r_buf) ;
    n_offset := n_offset + n_amount ;
    vc_str := RawToHex(r_buf) ;
    DBMS_output.put_line('+X'''||vc_str||'''') ;
    EXIT WHEN n_offset > n_length ;
  END LOOP ;
  DBMS_LOB.close(blob01) ;
  DBMS_output.put_line('WHERE col01 = '||n_col01||' ;') ;
EXCEPTION
  WHEN OTHERS THEN 
    DBMS_LOB.close(blob01) ;
    DBMS_output.put_line(SQLErrM) ;
END ;
/
set feedback on
spool off