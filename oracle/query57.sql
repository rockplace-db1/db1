--
--  Rockplace, internal use only
--
set PageSize 40
set LineSize 80

alter session set NLS_DATE_FORMAT = 'YYYY-MM-DD HH24:MI:SS'
/

variable vc_obj_type varchar2(19) ;
variable vc_obj_name varchar2(30) ;
variable vc_own_name varchar2(30) ;

begin
 :vc_obj_type := 'TABLE' ;
 :vc_obj_name := 'TABLE11' ;
 :vc_own_name := 'USER11' ;
end ;
/
show error

spool query57.out 

SELECT sysdate
FROM dual
/

SELECT dbid , name , db_unique_name
, database_role , created , platform_name
FROM v$database
/
SELECT startup_time , instance_number , instance_name
, instance_role , version , parallel , thread#
, host_name
FROM v$instance
/

print :vc_obj_type :vc_obj_name :vc_own_name

set PageSize 0
set Long 32767

SELECT dbms_metadata.get_ddl(:vc_obj_type, :vc_obj_name, :vc_own_name)
FROM dual
/

set PageSize 40
set LineSize 80
spool off
