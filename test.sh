#!/bin/bash

SCRIPT_ROOT=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

perl $SCRIPT_ROOT/main.pl --start 4 --end 6 --loop -1 --with-gpu --with-cpu-mem --with-par
