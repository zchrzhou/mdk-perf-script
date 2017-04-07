#!/bin/bash

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

if [ $# != 2 ] ; then
    echo "Use: `basename $0` <Interval> <sample_>."
    exit 1
fi

INTERVAL=$1

# tanscode => sample_multi
# all => sample_
SAMPLE=$2   

LOGFILE=$SCRIPT_DIR/cpu_mem.txt
rm -f $LOGFILE

while sleep $INTERVAL 
do
    #collect cpu and mem usage
    top -d 1 -bn 1 | grep $SAMPLE | grep -v grep | awk '{print $9"\t"$10}' | grep -v 0.0 >> $LOGFILE
done
