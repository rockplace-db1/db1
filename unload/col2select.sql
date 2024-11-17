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
  vc_table_name CONSTANT VARCHAR2(128) := 'ARTICLE_231107' ;
  vc_fields_terminated_by CONSTANT VARCHAR2(1) := ',' ;
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
  vc_col_expr VARCHAR2(4000) ; 

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
      WHEN 'NUMBER' THEN 
        vc_col_expr := 'TO_CHAR('||vc_col_name||')' ;
      WHEN 'DATE' THEN
        vc_col_expr := 'TO_CHAR('||vc_col_name||', '''||vc_date_format||''')' ;
      WHEN 'VARCHAR2' THEN
        vc_col_expr := 'RawToHex(utl_raw.cast_to_raw('||vc_col_name||'))' ;
      WHEN 'CHAR' THEN
        vc_col_expr := 'RawToHex(utl_raw.cast_to_raw('||vc_col_name||'))' ;
      WHEN 'RAW' THEN
        vc_col_expr := 'RawToHex('||vc_col_name||')' ;
      ELSE
        vc_col_expr := '''\N''' ; 
    END CASE ;
    IF REGEXP_COUNT(vc_typ_name, 'TIMESTAMP\([0-9]\) WITH TIME ZONE') > 0 
    THEN
      vc_col_expr := 'TO_CHAR('||vc_col_name||', '''||vc_timestamp_tz_format||''')' ;
    ELSIF REGEXP_COUNT(vc_typ_name, 'TIMESTAMP\([0-9]\)') > 0 
    THEN
      vc_col_expr := 'TO_CHAR('||vc_col_name||', '''||vc_timestamp_format||''')' ;
    END IF ;
    IF vc_nullable = 'Y' THEN
      vc_col_expr := 'NVL2('||vc_col_name||', '||vc_col_expr||', ''\N'')' ;
    END IF ;
    expr_list(vc_col_num) := vc_col_expr ;
  END LOOP ;
  CLOSE cursor01 ;
  DBMS_output.put_line('set serveroutput on') ;
  DBMS_output.put_line('set heading off') ;
  DBMS_output.put_line('set feedback off') ;
  DBMS_output.put_line('set linesize 8020') ;  -- 4,000 bytes x 2 + 20 bytes
  DBMS_output.put_line('set trimSpool on') ;
  DBMS_output.put_line('spool '||vc_owner_name||'_'||vc_table_name||'.csv') ;
  DBMS_output.put_line('DECLARE ') ;
  vc_col_num := expr_list.FIRST() ;
  WHILE vc_col_num IS NOT NULL LOOP
    DBMS_output.put_line('  v'||vc_col_num||' VARCHAR2(8000) ;') ;
    vc_col_num := expr_list.NEXT(vc_col_num) ;
  END LOOP ;
  DBMS_output.put_line('CURSOR cursor01 IS ') ;
  vc_col_num := expr_list.FIRST() ;
  DBMS_output.put_line('SELECT '||expr_list(vc_col_num)) ;
  LOOP
    vc_col_num := expr_list.NEXT(vc_col_num) ;
    EXIT WHEN vc_col_num IS NULL ;
    DBMS_output.put_line(', '||expr_list(vc_col_num)) ;
  END LOOP ;
  vc_col_num := expr_list.FIRST() ;
  DBMS_output.put_line('INTO v'||vc_col_num) ;
  LOOP
    vc_col_num := expr_list.NEXT(vc_col_num) ;
    EXIT WHEN vc_col_num IS NULL ;
    DBMS_output.put_line(', v'||vc_col_num) ;
  END LOOP ; 
  DBMS_output.put_line('FROM '||vc_owner_name||'.'||vc_table_name||' ; ') ;

  DBMS_output.put_line('BEGIN ') ;
  DBMS_output.put_line('OPEN cursor01 ; ') ;
  DBMS_output.put_line('LOOP ') ;
  DBMS_output.put_line('FETCH cursor01 ') ;
  vc_col_num := expr_list.FIRST() ;
  DBMS_output.put_line('INTO v'||vc_col_num) ;
  LOOP
    vc_col_num := expr_list.NEXT(vc_col_num) ;
    EXIT WHEN vc_col_num IS NULL ;
    DBMS_output.put_line(', v'||vc_col_num) ;
  END LOOP ;
  DBMS_output.put_line('; ') ;
  DBMS_output.put_line('EXIT WHEN cursor01%NOTFOUND ; ') ;
  vc_col_num := expr_list.FIRST() ;
  DBMS_output.put_line('DBMS_output.put(v'||vc_col_num||') ; ') ;
  LOOP
    vc_col_num := expr_list.NEXT(vc_col_num) ;
    EXIT WHEN vc_col_num IS NULL ;
    DBMS_output.put_line('DBMS_output.put('''||vc_fields_terminated_by||'''||v'||vc_col_num||') ; ') ;
  END LOOP ;
  DBMS_output.put_line('DBMS_output.new_line ; ') ;
  DBMS_output.put_line('END LOOP ; ') ;
  DBMS_output.put_line('CLOSE cursor01 ; ') ;
  DBMS_output.put_line('END ; ') ;
  DBMS_output.put_line('/ ') ;
  DBMS_output.put_line('spool off') ;
  DBMS_output.put_line('set serveroutput off') ;
  DBMS_output.put_line('set feedback on') ;
  DBMS_output.put_line('set heading on') ;
  DBMS_output.put_line('set linesize 80') ;
END ;
/
spool off
BEGIN
  DBMS_output.new_line ;
  DBMS_output.put_line('Review row2csv.sql modify it if needed.') ;
END ;
/
set serveroutput off
set feedback on
set heading on
set linesize 80
