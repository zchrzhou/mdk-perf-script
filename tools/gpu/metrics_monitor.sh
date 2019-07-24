#!/bin/bash

# get script path
script_path() 
{
    SOURCE=${BASH_SOURCE[0]}
    DIR=$( dirname "$SOURCE" )
    while [ -h "$SOURCE" ]
    do
        SOURCE=$(readlink "$SOURCE")
        [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
        DIR=$( cd -P "$( dirname "$SOURCE"  )" && pwd )
    done
    DIR=$( cd -P "$( dirname "$SOURCE" )" && pwd )
    echo $DIR
}

RUN_ROOT=$(script_path)
LOG_FILE=$RUN_ROOT/gpu.log


if [ $EUID -ne 0 ]; then
    sudo $RUN_ROOT/metrics_monitor > $LOG_FILE
else
    $RUN_ROOT/metrics_monitor > $LOG_FILE
fi
