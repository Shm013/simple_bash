#!/bin/bash

_tmp=$1

length=${_tmp:=25}

echo "${RANDOM}$(date +%N)" | sha256sum | base64 | head -c$length
echo
