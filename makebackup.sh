#makebackup - simple script for backuping by Shm...
#!/bin/bash

Name=`date +RootBkp-%d-%m-%y.tgz`
Backup_dir='/home/backup'

cd $Backup_dir

tar cvpzf $Name --exclude={/swapfile,/proc,/media,/lost+found,/mnt,/sys,/home,$Name} / 
