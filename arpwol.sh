if (( $# != 1 )); then
    echo "Usage: arpwol.sh HOSTNAME"
    exit 1
fi

HOSTNAME=$1

# Check arp cache
arp $HOSTNAME > /dev/null
_check=$?

if [ ${_check} -eq 0 ]; then
    MAC=$(arp $HOSTNAME | tail -n 1 | awk -F" " '{print $3}')
    wol $MAC
else
    echo "There is no host \"$HOSTNAME\" in ARP cache" >&2
    exit ${_check}
fi
