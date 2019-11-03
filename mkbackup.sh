#mkbackup - simple script for backuping by Shm...
#!/bin/bash

XMLCONFIG="mkbackup.xml"

#
# Find backup volume by UUID and moint it
#
function mount_bkp_volume () {
    
    BACKUP_NAME=$1
    BACKUP_MOUNT_POINT="${2}/${BACKUP_NAME}"
    BACKUP_DRIVE_UUID=$3
        
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

    NAME=$1
    MNTDIR=$2

    _mountpoint="${2}/${1}"

    umount $_mountpoint
    rmdir $_mountpoint
}

function make_backup () {

    SRC=$1/$3
    DEST=$2

    TARGET=$3
    EXCLUDE=$4

    _ex_file=$(mktemp /tmp/mkbackup.XXXXXXXXX)

    for x in $EXCLUDE; do
        echo $x >> $_ex_file
    done

    rsync -av --exclude-from $_ex_file $SRC $DEST

    rm $_ex_file
}

function make_bkp_snapshot () {

    NAME="$1-snap"
    GROUP=$2
    VOL=$3
    SNAP_SIZE=$4

    lvcreate -n "${NAME}" -s "${GROUP}/${VOL}" -L $SNAP_SIZE
}

function mount_snapshot () {

    NAME="$1-snap"
    GROUP=$2
    MNTPOINT="$3/$NAME"

    mkdir -p $MNTPOINT

    mount /dev/${GROUP}/${NAME} ${MNTPOINT}
    # Error
    if [ $? == 1 ] ; then
        echo "Error: can't mount ${GROUP}/${NAME} at ${MNTPOINT}"
        exit 1 
    fi
}

function umount_snapshot () {

    NAME=$1
    GROUP=$2
    MNTDIR=$3

    _mountpoint="${MNTDIR}/${NAME}-snap"

    umount "${_mountpoint}"
    rmdir $_mountpoint
}

function delete_bkp_snapshot () {

    group=$1
    name=$2

    lvremove -f "${group}/${name}-snap"
}

function usage () {
    echo "usage here"
}

function getxml() {
    
    XPATH=$1
    XMLFILE=$2

    xmllint --xpath $XPATH $XMLFILE |\
    sed '/^\/ >/d' | sed 's/<[^>]*.//g'
}

#
# Checking for the presence of in XML by name
#
function check_entry() {
    
    TYPE=$1 # device, keeper, task, etc...
    NAME=$2 # name
    XMLFILE=$3 #xmlfile

    _xpath="//config/${TYPE}[@name=\"${NAME}\"]"

    xmllint --xpath $_xpath $XMLFILE > /dev/null
    _res=$?

    # No such device:
    if [ $_res == 10 ] ; then
        echo "No such ${TYPE} \"${NAME}\""
        exit 10
    fi

    # Unclassified error:
    if [ ! $_res == 0 ] ; then
        echo "Some error occurred during parsing ${XMLFILE} for ${TYPE} \"${NAME}\""
        exit 1
    fi

    echo "Testing: $TYPE \"$NAME\" found. Processing"
}

function main () {

    action=$1
    task=$2

    #TODO: add XMLCONFIG check & validaing

    case $1 in
        (start)
            echo "Starting task \"$task\""

            # Check task
            check_entry "task" $task $XMLCONFIG
            _task_xpath="//config/task[@name=\"${task}\"]"

            # Get params from task
            task_type=$(getxml "${_task_xpath}/type" $XMLCONFIG)
            task_target=$(getxml "${_task_xpath}/target" $XMLCONFIG)
            task_keeper=$(getxml "${_task_xpath}/keeper" $XMLCONFIG)
            task_device=$(getxml "${_task_xpath}/device" $XMLCONFIG)
            task_exclude=$(getxml "${_task_xpath}/exclude" $XMLCONFIG)

            # Check device
            check_entry "device" $task_device
            _device_xpath="//config/device[@name=\"${task_device}\"]"

            # Get params from device
            device_name=$task_device
            device_type=$(getxml "${_device_xpath}/type" $XMLCONFIG)
            device_mntdir=$(getxml "${_device_xpath}/mntdir" $XMLCONFIG)
            device_lvm_group=$(getxml "${_device_xpath}/lvm-group" $XMLCONFIG)
            device_lvm_name=$(getxml "${_device_xpath}/lvm-name" $XMLCONFIG)
            device_lvm_snap_size=$(getxml "${_device_xpath}/lvm-snap-size" $XMLCONFIG)

            # Check keeper
            check_entry "keeper" $task_keeper
            _keeper_xpath="//config/keeper[@name=\"${task_keeper}\"]"
            
            keeper_name=$task_keeper
            keeper_type=$(getxml "${_keeper_xpath}/type" $XMLCONFIG)
            keeper_dir=$(getxml "${_keeper_xpath}/dir" $XMLCONFIG)
            keeper_mntdir=$(getxml "${_keeper_xpath}/mntdir" $XMLCONFIG)
            keeper_UUID=$(getxml "${_keeper_xpath}/UUID" $XMLCONFIG)

            # Mount keeper
            case $keeper_type in
                (disk)
                    mount_bkp_volume $keeper_name $keeper_mntdir $keeper_UUID
                    dest="${keeper_mntdir}/${keeper_name}/${keeper_dir}"
                    mkdir -p $dest # Create directory for backup
                    ;;
                (*)
                    echo "Unknown keeper type. Abort."
                    exit 1
                    ;;
            esac

            # Device prepearing
            case $device_type in
                (lvm)
                    make_bkp_snapshot $device_name \
                        $device_lvm_group \
                        $device_lvm_name  \
                        $device_lvm_snap_size

                    mount_snapshot $device_name \
                        $device_lvm_group \
                        $device_mntdir

                    src="${device_mntdir}/${device_name}-snap"

                    ;;
                (*)
                    echo "Unknown device type. Abort."
                    # unmount here!
                    exit 1
                    ;;
            esac

            # Backup here:
            case $task_type in
                (rsync)
                    make_backup $src $dest $task_target $task_exclude
                    ;;
                (*)
                    echo "Unknown task type. Abort."
                    # unmount here!
                    exit 1
                    ;;
            esac

            # Device finalizing
            case $device_type in
                (lvm)
                    umount_snapshot $device_name \
                        $device_lvm_group \
                        $device_mntdir
                    delete_bkp_snapshot $device_lvm_group $device_name
                    ;;
            esac

            # Keeper finilazing
            case $keeper_type in
                (disk)
                    umount_bkp_volume $keeper_name $keeper_mntdir
                    ;;
            esac

            ;;
        (stop)
            ;;
        (pause)
            ;;
        (resume)
            ;;
        (show)
            ;;
        (list)
            ;;
        (*)
            usage ;;
    esac

}


# Start programm:

main $@

#BKP_NAME=root_`date +%F`.tar.gz
#BKP_DIR='/home/backup'
#BKP_PROG=pigz
#
##cd $Backup_dir
#
#tar cvf $BKP_NAME -I $BKP_PROG \
#--exclude={/swapfile,/proc,/media,/tmp,/lost+found,/mnt,/sys,/home,$BKP_NAME}\
# /
