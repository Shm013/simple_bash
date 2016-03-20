#!/bin/bash


MOUNT_DIR="/media/YandexDisk/karlos013@yandex.ru"

LOCAL_SYNC_DIR="/home/shm/YandexDisk/karlos013@yandex.ru"
REMOTE_SYNC_DIR="$MOUNT_DIR/sync"


function pull { # get all data from yadisk;
    notify-send "Yasync" "Pull: sync start"
    rsync -qral "$REMOTE_SYNC_DIR/" "$LOCAL_SYNC_DIR/"
    notify-send "Yasync" "Pull: sync done"
}

function push { # put all data to yadisk;
    notify-send "Yasync" "Push: sync start"
    rsync -vap --delete-after "$LOCAL_SYNC_DIR/" "$REMOTE_SYNC_DIR/"
    notify-send "Yasync" "Push: sync done"
}

usage() {
    echo "Usage: $0 <actoin>

actions:
        push - push files to yandex disk, then remove extraneous;
        pull - pull files from yandex disk.
"
}

function yaumount {
    if grep -qs "$MOUNT_DIR" /proc/mounts; then # if mountded;
        echo "$MOUNT_DIR mounted."
        umount $MOUNT_DIR
    fi
}

function yamount { # mount davfs if it needed;
    if grep -qs "$MOUNT_DIR" /proc/mounts; then # if mountded;
        echo "$MOUNT_DIR mounted."
    else                                        # else;
        echo "$MOUNT_DIR not mounted."
        mount "$MOUNT_DIR"
        if [ $? -eq 0 ]; then
            echo "Mount success!"
        else
            echo "Something went wrong with the mount..."
            exit 1
        fi
    fi
}

case $1 in
    push) yamount; push ;;
    pull) yamount; pull ;;
     *) usage  
esac
