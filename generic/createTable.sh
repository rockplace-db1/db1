#
#  Rockplace, internal use only
#
#  20230502 Cheeyoung O  Created for PG, MySQL, and Oracle
#
TAB_NAME="table11"
NUM_ROWS="100"  # Minimum number of rows is 0
NUM_COLS="1000"  # Minimum number of columns is 2 and Max. is 1000
COL_DATA_TYPE="CHAR(2000)"
COL_DATA="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
 
COL_NAME_PREFIX="col"
 
#
# DROP TABLE statement to recreate the table
#
printf "DROP TABLE %s\n;\n" "$TAB_NAME"
 
#
# CREATE TABLE statement
#
printf "CREATE TABLE %s\n" "$TAB_NAME"
printf "( %s%04d %s\n" "$COL_NAME_PREFIX" "1" "$COL_DATA_TYPE"
for ((col_n = 2; col_n <= $NUM_COLS; col_n++))
do
  printf ", %s%04d %s\n" "$COL_NAME_PREFIX" "$col_n" "$COL_DATA_TYPE"
done
printf ") ;\n"
 
#
# INSERT statement
#
for ((row_n = 1; row_n <= $NUM_ROWS; row_n++))
{
  printf "INSERT INTO %s VALUES \n" "$TAB_NAME"
  printf "( \'%s\'\n" "$COL_DATA"
  for ((col_n = 2; col_n <= $NUM_COLS; col_n++))
  do
    printf ", \'%s\'\n" "$COL_DATA"
  done
  printf ") ;\n"
}
 
#
# COMMIT statement
#
printf "COMMIT ;\n"
