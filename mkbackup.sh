#mkbackup - simple script for backuping by Shm...
#!/bin/bash


LVM_VOL="test"
LVM_GRP="hdd"

BACKUP_DRIVE_UUID="22fec9fd-ce1a-43d0-961c-124e834618a1"
BACKUP_MOUNT_POINT="/media/backup"

SNAP_SIZE="5Gb"
SNAP_NAME="${LVM_VOL}-backup_snap"
SNAP_MOUNT_POINT="${LVM_GRP}-${LVM_VOL}-backup_snap"

BACKUP_TARGET="shm"
BACKUP_EXCLUDE="shm/Temporary"

#
# Find backup volume by UUID and moint it
#
function mount_bkp_volume () {
        
    # make dir for backup device if not exist:
    if [ ! -d $BACKUP_MOUNT_POINT ] ; then
        echo "Directory $BACKUP_MOUNT_POINT does not exist. Creating."
        mkdir -p $BACKUP_MOUNT_POINT

        # cannot create directory:
        if [ $? == 1 ] ; then
            echo "Error: Cannot create $BACKUP_MOUNT_POINT. Abort"
            exit 1
        fi
    fi

    # get major,minore number for univocal device identification
    dev=$(findfs UUID=$BACKUP_DRIVE_UUID)


    # device not exist (or some other error):
    if [ $? == 1 ] ; then
        echo "Error: Backup device with UUID $BACKUP_DRIVE_UUID not found!"
        exit 1 
    fi
    
    # may device has been already mounted?
    # lets find out his mountpoint:
    mpoints=($(awk -v d="$dev" ' $1 == d {print $2}' /proc/mounts))

    # no mountpoint (device not mounted):
    if [ "$mpoints" = "" ] ; then
        echo "Backup device $dev not mounted"
        echo "Device $dev will be mounted to $BACKUP_MOUNT_POINT"
        mount UUID=$BACKUP_DRIVE_UUID $BACKUP_MOUNT_POINT
    else

        # search for all mountpoints
        for i in "${mpoints[@]}" ; do

            # if device already mounted in right place:
            if [ "$i" = "$BACKUP_MOUNT_POINT" ] ; then
                echo "Backup device $dev already mounted in $BACKUP_MOUNT_POINT"
                echo "Nothing to do there"
                return 0
            fi
        done

        # if device mounted if wrong place:
        echo "Backup device $dev mounted in $i"
        echo "Device will be binded to $BACKUP_MOUNT_POINT"
        mount -o bind $i $BACKUP_MOUNT_POINT
    fi
}

#
# 1 - lvm logical volume
# 2 - lvm logical group
#
function make_bkp_snapshot () {
    lvcreate -n "$1_backup" -s "$2/$1" -L $SNAP_SIZE
}

#
# 1 - lvm logical volume
# 2 - lvm logical group
#
function delete_bkp_snapshot () {
    lvremove -f "$2/$1_backup"
}

function usage () {
    echo "usage here"
}

echo $1

case $1 in
    (all)
        mount_bkp_volume 
        #make_bkp_snapshot $LVM_VOL $LVM_GRP
        #mount_snapshot $SNAP_NAME $LVM_GRP $SNAP_MOUNT_POINT

        #make_backup $SNAP_MOUNT_POINT $BACKUP_MOUNT_POINT $BACKUP_TARGET #BACKUP_EXCLUDE
        
        #delete_bkp_snapshot $LVM_VOL $LVM_GRP 
        #umount_bkp_volume ;;
        ;;

    (test)
        mount_bkp_volume ;;
    (*) 
        usage ;;
esac

#BKP_NAME=root_`date +%F`.tar.gz
#BKP_DIR='/home/backup'
#BKP_PROG=pigz
#
##cd $Backup_dir
#
#tar cvf $BKP_NAME -I $BKP_PROG \
#--exclude={/swapfile,/proc,/media,/tmp,/lost+found,/mnt,/sys,/home,$BKP_NAME}\
# /
