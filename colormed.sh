#!/bin/bash

for x in {1..4}; do
    ffplay -f lavfi -i "sine=frequency=1500:duration=0.2" -autoexit -nodisp
    sleep $(( 2*60 ))
done

ffplay -f lavfi -i "sine=frequency=1000:duration=0.5" -autoexit -nodisp
