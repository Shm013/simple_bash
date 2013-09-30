#makebackup - simple script for backuping by Shm...
#!/bin/bash

Name=`date +RootBkp-%d-%m-%y.tgz`

cd /home

tar cvpzf $Name --exclude=/swapfile  --exclude=/proc --exclude=/lost+found --exclude=/mnt --exclude=/sys --exclude=/home --exclude=$Name / 
