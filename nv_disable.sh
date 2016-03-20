#!/bin/bash
# power off nvidia card

rmmod nvidia_modeset
rmmod nvidia

tee /proc/acpi/bbswitch <<<OFF
