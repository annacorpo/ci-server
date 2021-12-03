#!/bin/bash

# CI Server REST API URL
REST=https://cloud.all-hw.com/ci
API_KEY=<access code obtained from All-HW web server>

# User task timeout
TIMEOUT=20
# Verbose output on REST API requests/responses: either "-v" or empty
VERBOSE=

P_2=$2
P_3=$3

if [[ "x$RATE" == "x" ]]; then
    RATE=<baud rate for the given type of board>
fi

if [[ "x$LOG" == "x" ]]; then
    LOG=0
fi

task_status() {
    LOG=$(mktemp /tmp/run.XXXX.log)
    curl -X GET $VERBOSE "$REST/usertask?id=$P_2" 2>/dev/null > $LOG
    
    STATUS=`cat $LOG | jq -c -r .status`

    echo Status: $STATUS
    if [[ "x$STATUS" == "xfinished" ]]; then
        echo Exit code: `cat $LOG | jq -c -r .code`
        echo UART output: 
        cat $LOG | jq -c -r .output
    fi
    rm $LOG
}

create_task() {
    curl -s -X POST -F firmware=@$P_2 -F input=@$P_3 $VERBOSE "$REST/usertask?version=V3&rate=$RATE&log=$LOG&timeout=$TIMEOUT&key=$API_KEY"
    echo
}

case "$1" in
    status)
        task_status
        ;;
    task)
        create_task
        ;;
esac

exit 0
