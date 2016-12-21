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
    setxkbmap us -option # claer xkb option

    xscreensaver-command -lock
    
    setxkbmap "us,ru" -variant "winkeys" -model pc105 -option "grp:alt_shift_toggle"
    # Magic! Magic everywhere! (Fix rus keybord in awesome).
    xkbcomp $DISPLAY - | egrep -v "group . = AltGr;" | xkbcomp - $DISPLAY
    ;;
esac
