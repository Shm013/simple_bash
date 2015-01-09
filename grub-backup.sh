datev=$(date +%Y_%m_%d)
mkdir -p ~/grub.bak/$datev
cd ~/.grub.bak/$datev
mkdir -p boot/grub etc/default
cp /boot/grub/grub.cfg boot/grub
cp -Rp /etc/grub.d etc
cp /etc/default/grub etc/default
