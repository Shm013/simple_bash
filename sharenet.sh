# iptables rules for wifi ap
EXTIF1=wlan0
INTIF2=wlan1
# Delete all existing rules
iptables -F
iptables -t nat -F
iptables -t mangle -F
iptables -X

# Always accept loopback traffic
iptables -A INPUT -i lo -j ACCEPT

# Allow established connections, and those not coming from the outside
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -m state --state NEW -i $INTIF2 -j ACCEPT
iptables -A FORWARD -i $EXTIF1 -o $INTIF2 -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow outgoing connections from the LAN side
iptables -A FORWARD -i $INTIF2 -o $EXTIF1 -j ACCEPT

# Masquerade
iptables -t nat -A POSTROUTING -o $EXTIF1 -j MASQUERADE

# Don't forward from the outside to the inside
iptables -A FORWARD -i $EXTIF1 -o $EXTIF1 -j REJECT

echo 1 > /proc/sys/net/ipv4/ip_forward
#for f in /proc/sys/net/ipv4/conf/*/rp_filter ; do echo 0 > $f ; done
