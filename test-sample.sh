#!/bin/bash


SCRIPT_ROOT=`pwd`

if [ "$OS" = "Windows_NT" ]; then
    # On Windows
    PERF_ROOT="$SCRIPT_ROOT/../perf-script"
    SAMPLE_BIN="C:/mediasdk-samples/Intel-Media-Samples-6.0.0.49/_bin/x64"
else
    # On Linux
    PERF_ROOT="/VCA/perf-script"
    SAMPLE_BIN="$PERF_ROOT/binary/linux"
fi

## Test Item
$PERF_ROOT/main.pl --sample-dir=$SAMPLE_BIN --test A01
