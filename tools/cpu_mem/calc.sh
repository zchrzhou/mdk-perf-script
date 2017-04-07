#!/bin/bash

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

if [ $# != 1 ] ; then
    echo "Use: `basename $0` <channel-number>."
    exit 1
fi

INPUT_NUM=$1
LOGFILE=$SCRIPT_DIR/cpu_mem.txt

CPU_CORE_NUM=`cat /proc/cpuinfo | grep -c processor`
eval $(awk '{a+=$1;b+=$2} END {printf("avgcpu=%.1f\navgmem=%.1f", (a/(NR*'"$CPU_CORE_NUM"'))*'"$INPUT_NUM"',(b/NR));}' $LOGFILE)

# all chinnal CPU and echo channel MEM
echo "$avgcpu"
echo "$avgmem"
