#!/bin/sh

ACTION=$1

case $ACTION in
shutdown)
    dbus-send --system --print-reply \
    --dest="org.freedesktop.ConsoleKit" \
    /org/freedesktop/ConsoleKit/Manager \
    org.freedesktop.ConsoleKit.Manager.Stop
    ;;
reboot)
    dbus-send --system --print-reply \
    --dest="org.freedesktop.ConsoleKit" \
    /org/freedesktop/ConsoleKit/Manager \
    org.freedesktop.ConsoleKit.Manager.Restart
    ;;
suspend)
    dbus-send --system --print-reply \
    --dest="org.freedesktop.UPower"  \
    /org/freedesktop/UPower \
    org.freedesktop.UPower.Suspend
    ;;
lock)
    xscreensaver-command -lock
    ;;
esac
