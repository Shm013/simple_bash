#gentoo mounting & chrooting script

device='/dev/mapper/hdd-gentoo'
root_dir='/mnt/gentoo'

mnt_dir=`mount | grep $device | cut -d ' ' -f 3`

if [[ mnt_dir ]]; then
    if [[ $mnt_dir == "$root_dir" ]]; then
        echo "$device alredy mounted on $root_dir"
    else
        echo "$device alredy mounted on $mnt_dir"
        echo "unmout device is needed. quit..."
        return 2
    fi
else
    echo "mounting $device on $root_dir"
    mount $device $root_dir
fi
echo "mount /boot"
mount -o bind /boot $root_dir/boot
echo "mount /dev"
mount -o bind /dev $root_dir/dev
echo "mount sys"
mount -o bind /sys $root_dir/sys
echo "mount proc"
mount -t proc proc $root_dir/proc

echo "chroor now!"
chroot $root_dir /bin/bash
