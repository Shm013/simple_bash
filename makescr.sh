#makescr - simple scripn for takin screenshot. By Shm...
#!/bin/bash

#######################################################
#Screenshot directory:
DIR=~/Pictures/shots/

#File name:
SUF=`date +-%Y-%m-%d_%H-%M`
WIN=Win$SUF.png
SCR=Shot$SUF.png
#######################################################

#Dir check:
dirCheck(){
    if [ ! -d $DIR ] ; then
        DIR=~/
    fi
    cd $DIR
}

takeShot(){
    Target=$1    # WIN | SCR
    Options=$2   # Any options
    dirCheck
    number=1
    prefix="${Target%%.*}"
    sufix=".${Target##*.}"
    while [ -f $Target ] ; do
        Target="$prefix($number)$sufix"
    ((++number))
    done
    scrot $Target $Options
}

usage() {
    echo "makescr - simple script for take screenshot. Requires scrot.
Usage : makescr.sh [OPTION]
  -h        display this help and exit
  -s        shot interactively choose window (with border)
  -u        shot focused window (without border)
  -a        shot all screen
By Shm...
"
}

case $1 in
    -h) usage                  ;; #show usage
    -u) takeShot $WIN "-u"     ;; #focused window
    -s) takeShot $WIN "-s -b"  ;; #interactively choose window
    -a) takeShot $SCR          ;; #all screen
     *) takeShot $SCR          ;; #all screen
esac
