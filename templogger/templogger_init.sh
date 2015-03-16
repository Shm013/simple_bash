#!/bin/bash

# . /etc/rc.d/init.d/functions

templogger="templogger"
lockfile="/var/lock/templogger"
logfile="/var/log/shm/templogger"
prog="templogger"
delay=5
RETVAL=0

start() {
        if [ -f $lockfile ]; then
            echo -n $"$prog is already running: "
            echo
        else
            echo -n $"Starting $prog: "
            $templogger $delay >> $logfile &
            RETVAL=$?
            [ $RETVAL = 0 ] && touch $lockfile
            return $RETVAL
        fi
    }
stop() {
        echo -n $"Stopping $prog: "
        killall $templogger
        RETVAL=$?
        echo
        [ $RETVAL = 0 ] && rm -f $lockfile
        return $RETVAL
    }
case "$1" in
        start)
        start
        ;;
        stop)
        stop
        ;;
        restart)
        stop
        start
        ;;
        *)

        echo "Usage: templogger {start|stop|restart}"
        exit 1
esac

exit $?
