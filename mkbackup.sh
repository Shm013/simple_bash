#mkbackup - simple script for backuping by Shm...
#!/bin/bash


LVM_VOL="test"
LVM_GRP="hdd"

BACKUP_DRIVE_UUID="22fec9fd-ce1a-43d0-961c-124e834618a1"
BACKUP_MOUNT_POINT="/media/backup"

SNAP_SIZE="5Gb"
SNAP_NAME="${LVM_VOL}-backup_snap"
SNAP_MOUNT_POINT="/media/${LVM_GRP}-${LVM_VOL}-backup_snap"

BACKUP_TARGET="shm"
BACKUP_EXCLUDE="shm/Temporary shm/Testing*"

#
# Find backup volume by UUID and moint it
#
function mount_bkp_volume () {
        
    # get major,minore number for univocal device identification
    dev=$(findfs UUID=$BACKUP_DRIVE_UUID)

    # device not exist (or some other error):
    if [ $? == 1 ] ; then
        echo "Error: Backup device with UUID $BACKUP_DRIVE_UUID not found!"
        exit 1
    fi

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

    # may device has been already mounted?
    # lets find out his mountpoint:
    mpoints=($(awk -v d="$dev" ' $1 == d {print $2}' /proc/mounts))

    # no mountpoint (device not mounted):
    if [ "$mpoints" = "" ] ; then
        echo "Backup device $dev not mounted"
        echo "Device $dev will be mounted at $BACKUP_MOUNT_POINT"
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

function umount_bkp_volume () {
   #TODO: add check with lsof 
    umount $BACKUP_MOUNT_POINT
}

function make_backup () {

    ex_file=$(mktemp /tmp/mkbackup.XXXXXXXXX)

    for x in $BACKUP_EXCLUDE; do
        echo $x >> $ex_file
    done

    src=${SNAP_MOUNT_POINT}/${BACKUP_TARGET} 
    dest=$BACKUP_MOUNT_POINT
    rsync -av --exclude-from $ex_file $src $dest

    rm $ex_file
}

function make_bkp_snapshot () {
    name=$1
    vol=$2
    group=$3

    lvcreate -n "${name}" -s "${group}/${vol}" -L $SNAP_SIZE
}

function mount_snapshot () {
    name=$1
    group=$2
    mountpoint=$3

    mkdir -p $mountpoint

    mount /dev/${group}/${name} ${mountpoint}
    # Error
    if [ $? == 1 ] ; then
        echo "Error: can't mount ${group}/${name} at ${mountpoint}"
        exit 1 
    fi
}

function umount_snapshot () {
    name=$1
    group=$2
    mountpoint=$3

    umount "${mountpoint}"
}

function delete_bkp_snapshot () {
    name=$1
    group=$2
    lvremove -f "${group}/${name}"
}

function usage () {
    echo "usage here"
}

case $1 in
    (start)


#        mount_bkp_volume
#
#        make_bkp_snapshot $SNAP_NAME $LVM_VOL $LVM_GRP
#        mount_snapshot $SNAP_NAME $LVM_GRP $SNAP_MOUNT_POINT
#
#        make_backup
#        
#        umount_snapshot $SNAP_NAME $LVM_GRP $SNAP_MOUNT_POINT
#        delete_bkp_snapshot $SNAP_NAME $LVM_GRP 
#
#        umount_bkp_volume ;;

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
