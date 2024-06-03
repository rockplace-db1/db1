# 
# 01 June 24 Created at 22:28, arithmatic expansion
# 
#ERR_LOG_FILES=POSFMES_202*.log
#ERR_LOG_FILES=../231208/*.log
ERR_LOG_FILES="../231204/edb-2023-*.log"

AWK_CMD=/bin/awk
EXPR_CMD=/bin/expr
HEAD_CMD=/bin/head
GREP_CMD=/bin/grep
PRINTF_CMD=/bin/printf
SORT_CMD=/bin/sort
TAIL_CMD=/bin/tail
WC_CMD=/bin/wc

# 
# subroutines
#
searchLogForLockwaits()
{
  # Length must be greater than 0
  EVENT_LOCKWAIT_ELAPSED="still waiting for"
  N_LINES_AFTER=2
  N_MSGS=1

  $PRINTF_CMD "\nTrying to search Lock wait message(s) ...\n"

  # double quote 
  N_COUNT=`$GREP_CMD -h "$EVENT_LOCKWAIT_ELAPSED" $ERR_LOG_FILES | $WC_CMD -l`
  RET_CODE=$?
  if [ $N_COUNT -eq 0 ] ;
  then
    $PRINTF_CMD "No message was found: Lock wait\n"
    return 0
  fi
  $PRINTF_CMD "%s message(s) found: Lock wait\n" "$N_COUNT"
  F_MSEC=`$GREP_CMD -h "$EVENT_LOCKWAIT_ELAPSED" $ERR_LOG_FILES | $GREP_CMD -oP "after \K.+" | $AWK_CMD '{ printf "%s\n",$1 }' | $SORT_CMD -nr | $HEAD_CMD -n $N_MSGS`
  RET_CODE=$?
  $PRINTF_CMD "The longest wait time was %s milliseconds as follows:\n" "$F_MSEC"
  $GREP_CMD -h -A "$N_LINES_AFTER" "$F_MSEC" $ERR_LOG_FILES 
  RET_CODE=$?
}

searchLogForExectime()
{
  # Length must be greater than 0
  EVENT_SQLEXEC_TIMETAKEN="duration:"
  N_LINES_AFTER=1
  N_MSGS=1

  $PRINTF_CMD "\nTrying to search SQL execution time(duration) ...\n"

  # double quote 
  N_COUNT=`$GREP_CMD -h "$EVENT_SQLEXEC_TIMETAKEN" $ERR_LOG_FILES | $WC_CMD -l`
  RET_CODE=$?
  if [ $N_COUNT -eq 0 ] ;
  then
    $PRINTF_CMD "No message was found: SQL execution time(duration)\n"
    return 0
  fi
  $PRINTF_CMD "%s message(s) found: SQL exec time(duration)\n" "$N_COUNT"
  F_MSEC=`$GREP_CMD -h "$EVENT_SQLEXEC_TIMETAKEN" $ERR_LOG_FILES | $GREP_CMD -oP "LOG:  \K.+" | $AWK_CMD '{ printf "%s\n",$2 }' | $SORT_CMD -nr | $HEAD_CMD -n $N_MSGS`
  RET_CODE=$?
  $PRINTF_CMD "The longest exec time was %s milliseconds as follows:\n" "$F_MSEC"
  $GREP_CMD -h -A "$N_LINES_AFTER" "$F_MSEC" $ERR_LOG_FILES 
  RET_CODE=$?
}

searchLogForTempfile()
{
  # Length must be greater than 0
  EVENT_TEMPFILE_DELETED="temporary file:"
  N_LINES_AFTER=1
  N_MSGS=1

  # arithmatic expansion suggested by Gemini
  N_LINES_OUTPUT=$(($N_MSGS * ($N_LINES_AFTER + 1)))
  #$PRINTF_CMD "DEBUG: %s\n" "$N_LINES_OUTPUT"

  $PRINTF_CMD "\nTrying to search message(s) of Temporary file(s) ...\n"

  # double quote 
  N_COUNT=`$GREP_CMD -h "$EVENT_TEMPFILE_DELETED" $ERR_LOG_FILES | $WC_CMD -l`
  RET_CODE=$?
  if [ $N_COUNT -eq 0 ] ;
  then
    $PRINTF_CMD "No message was found: Temporary file\n"
    return 0
  fi
  $PRINTF_CMD "%s message(s) found: Temp. file\n" "$N_COUNT"
  F_MSEC=`$GREP_CMD -h "$EVENT_TEMPFILE_DELETED" $ERR_LOG_FILES | $GREP_CMD -oP "LOG:  \K.+" | $AWK_CMD '{ printf "%s\n",$6 }' | $SORT_CMD -nr | $HEAD_CMD -n $N_MSGS`
  RET_CODE=$?
  $PRINTF_CMD "The largest temp. file was %s bytes:\n" "$F_MSEC"
  $GREP_CMD -h -A "$N_LINES_AFTER" "$F_MSEC" $ERR_LOG_FILES | $TAIL_CMD -n $N_LINES_OUTPUT
  RET_CODE=$?
}

countMsgBySev()
{
  ERR_LEVELS="PANIC FATAL WARNING ERROR"

  $PRINTF_CMD "\nNumber of Messages by Msg Severities\n" 
  for ERR_LEVEL in $ERR_LEVELS ;
  do
    N_COUNT=`$GREP_CMD -h "$ERR_LEVEL:" $ERR_LOG_FILES | $WC_CMD -l`
    RET_CODE=$?
    $PRINTF_CMD "%s  %s\n" "$ERR_LEVEL" "$N_COUNT"
  done ;
}

printBanner()
{
  $PRINTF_CMD "Rockplace, inc. \n\n\
Created for POSCO \n\
Created to be used with EDB Postgres Advanced Server (EPAS) v10 or above\n\
and Red hat Enterprise Linux (RHEL) 7 or above\n\n"
}

searchErrForDeadlockPG()
{
  # Length must be greater than 0
  EVENT_DEADLOCK_DETECTED="ERROR:  deadlock detected"
  N_LINES_AFTER=6
  N_MSGS=1

  # arithmatic expansion suggested by Gemini
  N_LINES_OUTPUT=$(($N_MSGS * ($N_LINES_AFTER + 1)))
  #$PRINTF_CMD "DEBUG: %s\n" "$N_LINES_OUTPUT"

  $PRINTF_CMD "\nTring to search Deadlock detection message(s)...\n"

  # double quote 
  N_COUNT=`$GREP_CMD -h "$EVENT_DEADLOCK_DETECTED" $ERR_LOG_FILES | $WC_CMD -l`
  if [ $N_COUNT -eq 0 ] ;
  then
    $PRINTF_CMD "No message was found: Deadlock detection\n"
    return 0
  elif [ $N_COUNT -eq 1 ] ;
  then
    $PRINTF_CMD "1 message found (Deadlock detection):\n"
    $GREP_CMD -h -A "$N_LINES_AFTER" "$EVENT_DEADLOCK_DETECTED" $ERR_LOG_FILES | $HEAD_CMD -n $N_LINES_OUTPUT
    RET_CODE=$?
    return $RET_CODE
  fi
  $PRINTF_CMD "%s messages found: Deadlock detection\n" "$N_COUNT"
  $PRINTF_CMD "The 1st and the Last deadlock detection was:\n" 
  $GREP_CMD -h -A "$N_LINES_AFTER" "$EVENT_DEADLOCK_DETECTED" $ERR_LOG_FILES | $HEAD_CMD -n $N_LINES_OUTPUT
  RET_CODE=$?
  $GREP_CMD -h -A "$N_LINES_AFTER" "$EVENT_DEADLOCK_DETECTED" $ERR_LOG_FILES | $TAIL_CMD -n $N_LINES_OUTPUT
  RET_CODE=$?
}

# 
# main
# 
printBanner
$PRINTF_CMD "\nTrying to search LOG: in %s ...\n" "$ERR_LOG_FILES"
searchLogForLockwaits
searchLogForExectime
searchLogForTempfile
countMsgBySev
$PRINTF_CMD "\nTrying to search ERROR: in %s ...\n" "$ERR_LOG_FILES"
searchErrForDeadlockPG
#searchErrForDeadlockEPAS
