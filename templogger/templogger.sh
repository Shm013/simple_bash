#!/bin/bash
#Temperature logger. By Shm...

sensor="/sys/bus/platform/drivers/coretemp/coretemp.0/temp1_input"

delay=$1

while true; do
    echo "`date +%F_%H:%M` `cat $sensor`" 
    sleep $[$delay*60]
done


