#makebackup - simple script for backuping by Shm...
#!/bin/bash

Name=`date +RootBkp-%d-%m-%y.tgz`

cd /home

tar cvpzf $Name --exclude={/swapfile,/proc,/media,/lost+found,/mnt,/sys,/home,$Name} / 
