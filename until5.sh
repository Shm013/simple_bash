#!/bin/bash

counter=0 
ret=1

while [[ $counter -lt 5 ]] && [[ $ret -ne 0 ]]
do
  echo Counter: $counter
  read ret
  ((counter++))
done
