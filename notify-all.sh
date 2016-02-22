title="$1"
body="$2"
shift 2
opts="$*"

# backup env.
old_user=$USER
old_display=$DISPLAY
old_dbus=$DBUS_SESSION_BUS_ADDRESS

for pid in $(pgrep 'awesome'); do
    eval $(grep -z ^USER /proc/$pid/environ)
    eval export $(grep -z ^DISPLAY /proc/$pid/environ)
    eval export $(grep -z ^DBUS_SESSION_BUS_ADDRESS /proc/$pid/environ)
    su $USER -c "notify-send $opts \"$title\" \"$body\""
done

# restore env.

export USER=$old_user
export DISPLAY=$old_display
export DBUS_SESSION_BUS_ADDRESS=$old_dbus
