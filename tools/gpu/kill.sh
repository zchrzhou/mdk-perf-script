#!/bin/bash

if [ $EUID -ne 0 ]; then
    sudo killall metrics_monitor
else
    killall metrics_monitor
fi
