#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "You must be root to do this." 1>&2
   exit 100
fi

for module in vbox{drv,netadp,netflt,pci}; do
    modprobe $module
done
