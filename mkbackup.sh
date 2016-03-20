#makebackup - simple script for backuping by Shm...
#!/bin/bash

BKP_NAME=root_`date +%F`.tar.gz
BKP_DIR='/home/backup'
BKP_PROG=pigz

#cd $Backup_dir

tar cvf $BKP_NAME -I $BKP_PROG \
--exclude={/swapfile,/proc,/media,/tmp,/lost+found,/mnt,/sys,/home,$BKP_NAME}\
 /
