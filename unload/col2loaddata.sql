-- 
-- 04 Nov 24 Added TIMESTAMP([0-9]) (WITH TIME ZONE)
--           Updated NULL to \N
-- 01 Nov 24 Created
-- 
set serveroutput on
set heading off
set feedback off
set linesize 32767
set trimSpool on
spool row2csv.sql
DECLARE
  -- 
  -- Configuration
  -- 
  vc_owner_name CONSTANT VARCHAR2(128) := 'SYSTEM' ;
  vc_table_name CONSTANT VARCHAR2(128) := 'ARTICLE_231107' ;  --'EMPLOYEES' ;
  vc_file_name CONSTANT VARCHAR2(128) := vc_owner_name||'_'||vc_table_name||'.csv' ;
  vc_upload_dir CONSTANT VARCHAR2(255) := '/ProgramData/MySQL/MySQL Server 8.0/Uploads/' ;
  vc_lines_terminated_by CONSTANT VARCHAR2(4) := '\r\n' ;
  vc_fields_terminated_by CONSTANT VARCHAR2(1) := ',' ;
  vc_charset_name CONSTANT VARCHAR2(12) := 'utf8mb4' ;
  -- 
  -- Configuration: by data types
  -- 
  vc_date_format CONSTANT VARCHAR2(21) := 'YYYY-MM-DD HH24:MI:SS' ;  
  vc_timestamp_format CONSTANT VARCHAR2(25) := 'YYYY-MM-DD HH24:MI:SS.FF6' ;  
  vc_timestamp_tz_format CONSTANT VARCHAR2(25) := 'YYYY-MM-DD HH24:MI:SS.FF6' ;  

  n_count NUMBER := 0 ;
  i NUMBER := 0 ;
  n_col_id NUMBER ;
  vc_col_name VARCHAR2(128) ;  -- 128 = Max. Len. of an identifier from 11
  vc_typ_name VARCHAR2(106) ;
  vc_nullable VARCHAR2(1) ;
  vc_expr VARCHAR2(4000) ; 

  vc_col_num VARCHAR2(3) ;
  TYPE t_arr_str IS TABLE OF VARCHAR2(4000) INDEX BY VARCHAR2(3) ;  -- 4,000 bytes
  expr_list t_arr_str ;

  CURSOR cursor01 IS
    SELECT column_id, column_name, data_type, nullable
    INTO n_col_id, vc_col_name, vc_typ_name, vc_nullable
    FROM all_tab_columns 
    WHERE owner = vc_owner_name AND table_name = vc_table_name 
    ORDER BY column_id ASC ;
BEGIN
  SELECT COUNT(column_id) INTO n_count FROM all_tab_columns 
  WHERE owner = vc_owner_name AND table_name = vc_table_name 
  ;

  OPEN cursor01 ;
  i := 0 ;
  LOOP
    FETCH cursor01 INTO n_col_id, vc_col_name, vc_typ_name, vc_nullable ;
    EXIT WHEN cursor01%NOTFOUND ;
    i := i + 1 ;
    vc_col_num := TO_CHAR(i, 'FM000') ;
    CASE vc_typ_name 
      WHEN 'VARCHAR2' THEN
        vc_expr := vc_col_name||' = unhex(@v'||vc_col_num||')' ; 
      WHEN 'CHAR' THEN
        vc_expr := vc_col_name||' = unhex(@v'||vc_col_num||')' ; 
      WHEN 'RAW' THEN
        vc_expr := vc_col_name||' = unhex(@v'||vc_col_num||')' ; 
      ELSE
        vc_expr := vc_col_name||' = @v'||vc_col_num ; 
    END CASE ;
    expr_list(vc_col_num) := vc_expr ;
  END LOOP ;
  CLOSE cursor01 ;
  DBMS_output.put_line('LOAD DATA ') ;
  DBMS_output.put_line('INFILE '''||vc_upload_dir||vc_file_name||''' ') ;
  DBMS_output.put_line('INTO TABLE '||vc_table_name) ;
  DBMS_output.put_line('CHARACTER SET '||vc_charset_name) ;
  DBMS_output.put_line('FIELDS TERMINATED BY '''||vc_fields_terminated_by||'''') ;
  DBMS_output.put_line('LINES TERMINATED BY '''||vc_lines_terminated_by||'''') ;
  vc_col_num := expr_list.FIRST() ;
  DBMS_output.put_line('( @v'||vc_col_num) ;
  LOOP
    vc_col_num := expr_list.NEXT(vc_col_num) ;
    EXIT WHEN vc_col_num IS NULL ;
    DBMS_output.put_line(', @v'||vc_col_num) ;
  END LOOP ; 
  DBMS_output.put_line(') ') ;
  vc_col_num := expr_list.FIRST() ;
  DBMS_output.put_line('SET '||expr_list(vc_col_num)) ;
  LOOP
    vc_col_num := expr_list.NEXT(vc_col_num) ;
    EXIT WHEN vc_col_num IS NULL ;
    DBMS_output.put_line(', '||expr_list(vc_col_num)) ;
  END LOOP ;
  DBMS_output.put_line('; ') ;
END ;
/
spool off
set serveroutput off
set feedback on
set heading on
set linesize 80
