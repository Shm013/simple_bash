#!/bin/bash

# sharenet_qemu.sh

qdev="wlan1"            # bridge device for qemu
netdev="wlan0"          # device with internet

qnetwork="10.0.3.0/8"   # qemu network

echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING -o $netdev -s $qnetwork -j MASQUERADE
iptables -I FORWARD 1 -i $qdev -j ACCEPT
iptables -I FORWARD 1 -o $qdev -m state --state RELATED,ESTABLISHED -j ACCEPT
echo "share internet from $netdev to $qdev in $qnetwork"
