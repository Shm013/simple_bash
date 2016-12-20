#!/bin/bash -xe

tftproot="$1"
image="$2"
tmp="./tmp"

test -z "$tftproot" -o -z "$image" && echo "Usage: $0 <tftproot> <gentoo-iso>" >&2 && exit 1
test -e "$tmp" && echo "Temporary path '$tmp' already exists." >&2 && exit 1

iso="$tmp/iso"
initrd="$tmp/initrd.dir"

# prepare directories
mkdir -p "$tmp" "$iso" "$initrd/mnt/cdrom"

# extract files from ISO image
mount -o ro,loop "$image" "$iso"
cp "$iso"/{image.squashfs,isolinux/gentoo,isolinux/gentoo.igz} "$tmp"
umount "$iso"

# rename kernel
mv "$tmp/gentoo" "$tmp/kernel"

# patch initramfs and add squashfs to it
xz -dc "$tmp/gentoo.igz" | ( cd "$initrd" && cpio -idv )
patch -d "$initrd" -p0 <<'EOF'
--- init.orig	2016-01-02 00:00:00.000000000 +0100
+++ init	2016-01-02 00:00:00.000000000 +0100
@@ -455,9 +455,9 @@
 		CHROOT=${NEW_ROOT}
 	fi
 
-	if [ /dev/nfs != "$REAL_ROOT" ] && [ sgimips != "$LOOPTYPE" ] && [ 1 != "$aufs" ]; then
-		bootstrapCD
-	fi
+#	if [ /dev/nfs != "$REAL_ROOT" ] && [ sgimips != "$LOOPTYPE" ] && [ 1 != "$aufs" ]; then
+#		bootstrapCD
+#	fi
 
 	if [ "${REAL_ROOT}" = '' ]
 	then
@@ -591,7 +591,7 @@
 		else
 			bad_msg "Block device ${REAL_ROOT} is not a valid root device..."
 			REAL_ROOT=""
-			got_good_root=0
+			got_good_root=1
 		fi
 	done
 
@@ -670,7 +670,7 @@
 	[ -z "${LOOP}" ] && find_loop
 	[ -z "${LOOPTYPE}" ] && find_looptype
 
-	cache_cd_contents
+	#cache_cd_contents
 
 	# If encrypted, find key and mount, otherwise mount as usual
 	if [ -n "${CRYPT_ROOT}" ]
EOF
cp "$tmp/image.squashfs" "$initrd/mnt/cdrom"
( cd "$initrd" && find . -print | cpio -o -H newc | gzip -9 -c - ) > "$tmp/initrd"

# prepare boot data
grub-mknetdir -v --net-directory="$tftproot"
cat > "$tftproot/boot/grub/grub.cfg" <<'EOF'
menuentry "Gentoo Live" {
    linux /boot/kernel root=/dev/ram0 init=/linuxrc loop=/image.squashfs looptype=squashfs cdroot=1 real_root=/
    initrd /boot/initrd
}
EOF
cp "$tmp"/{kernel,initrd} "$tftproot/boot"

# cleanup
rm -rf "$tmp"
