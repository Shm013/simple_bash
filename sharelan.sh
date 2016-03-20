#!/bin/bash

# sharelan.sh

eth0="enp4s0f1"
eth1="wlan0"

usage(){
    echo Usage:
    echo "$0 eth0 eth1 start"
    echo "$0 stop"
}

start(){
    ifconfig $eth0 up
    ifconfig $eth0 192.168.2.1
    echo "1" > /proc/sys/net/ipv4/ip_forward
    iptables -t nat -A POSTROUTING -o $eth1 -s 192.168.2.0/24 -j MASQUERADE
    echo "start sharing"
}

stop(){
    echo "stop sharing"
}

case $1 in
    start) start ;;
     stop) stop  ;;
        *) usage ;;
esac
