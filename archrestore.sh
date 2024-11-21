#!/bin/bash
echo "where there is a will, there is a bread. Always remember to share"
# An easy program that will easily reinstall all the programs you used to have. Based on the former applist.txt in docu. I chose this over copy and pasting the whole system because it should be better for new system compatibility, disk lifespan, and efficiency. It also gives me freedom of choice, in case the system drive breaks but the other drive is fine and viceversa. I only need to restore what was lost, instead of everything.
# Make sure to have veracrypt and gparted installed, and make the encryoted partitions before running.
# Below are also some tips for operations you might want to do after install.

# The following should be run once you restore grub and mkinitcpio.conf. It's necessary for vms and other programs.
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo mkinitcpio -p linux

echo paru is important
sudo pacman -S git
sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru
cd paru
makepkg -si
cd ..
sudo rm -r paru/

# Cleaning trash
sudo pacman -Rcns ristretto xfce4-clipman-plugin vim parole xfce4-dict xfce4-weather-plugin

echo management and priority
sudo pacman -S mesa-utils onevpl-intel-gpu gparted veracrypt git snap-pac snap-sync grub-btrfs exfatprogs ntfs-3g reflectors dosfstools snapper archlinux-keyring pyenv
paru -S btrfs-assistant cef-minimal-obs-bin obs-studio-tytan652 autotrash
echo dependencies, good, and compatibility
sudo pacman -S autorandr qt5ct ttf-dejavu ttf-liberation noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra webp-pixbuf-loader poppler-glib ffmpegthumbnailer freetype2 libgsf evince atril gnome-epub-thumbnailer f3d lib32-pipewire lib32-pipewire-jack kvantum dotnet-sdk-6.0 catfish udftools php xorg-server mutagen
paru -S raw-thumbnailer mcomix cover-thumbnailer pipewire-alsa flat-remix-gtk microconda ttf-ms-win10-auto atomicparsley
#sudo pacman -S dotnet-runtime
#dotnet-sdk-6.0 will not be necessary if vrchat sdk linux doesn't work. See https://github.com/vrchat-community/creator-companion/issues/408#issuecomment-2371877473
echo wine
sudo pacman -S wine-gecko wine-mono lib32-gst-plugins-base lib32-gst-plugins-good libsidplayfp lib32-mesa vulkan-intel lib32-vulkan-intel vulkan-icd-loader lib32-vulkan-icd-loader lib32-opencl-icd-loader lib32-libxslt cups samba dosbox
paru -S lib32-gst-plugins-bad lib32-gst-plugins-ugly
echo programs
# install noise repellent. it has to be done this way instead of using pacman until the pull request is pushed
git clone --single-branch --branch restore-state https://github.com/orivej/noise-repellent.git
cd noise-repellent
meson build --buildtype=release --prefix=/usr --libdir=lib
meson compile -C build -v
sudo meson install -C build
cd ..
sudo rm -r noise-repellent/
sudo pacman -S mpv audacious libreoffice-fresh jalv lsp-plugins-lv2 libvirt virt-viewer virt-manager qemu-desktop dnsmasq iptables-nft geany winetricks okular keepassxc steam gimp speedcrunch wine-staging yt-dlp yt-dlp-drop-in steamcmd ppsspp bottles mediainfo-gui pqiv qbittorrent
paru -S tenacity-git peazip qdirstat optimus-manager raider-file-shredder portmaster-stub-bin ventoy xnviewmp rpi-imager pcsx2-git waydroid soundux-git xclicker autokey
# optionals
# also see paruoptionals.sh. Only currently installed or most useful optionals are here.
# sudo pacman -S rpi-imager-bin
# paru -S solarwallet electron-cash nault-bin sparrow-wallet sia-ui hdsentinel_gui seatools fontpreview
#paru -S fluent-reader-bin ledfx-git
#https://aur.archlinux.org/packages?O=0&SeB=nd&K=rpi-imager&outdated=&SB=p&SO=d&PP=50&submit=Go
echo VRChat vpm
dotnet tool install --global vrchat.vpm.cli
dotnet tool update --global vrchat.vpm.cli
echo Final touches
sudo pacman -S steam-native-runtime
sudo pacman -Rcn steam-native-runtime
paru -S c++utilities
paru -S qtutilities
paru -S qtforkawesome
paru -S syncthingtray
paru -S informant
sudo usermod -a -G informant $USER
sudo usermod -a -G libvirt $USER
sudo usermod -a -G vboxusers $USER
sudo usermod -a -G yesgang $USER
informant read
reboot

# odd ones
#cd ~/opt
#sudo pacman -S lynx
#lynx "https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=en-US"
#sudo tar xf firefox*.tar.bz2 -C ~/opt/
#sudo ln -sf ~/opt/firefox/firefox /usr/bin/firefox
#sudo wget https://raw.githubusercontent.com/mozilla/sumo-kb/main/install-firefox-linux/firefox.desktop -P /usr/local/share/applications

# Tor Browser
#lynx https://www.torproject.org/download/
#sudo tar xf tor-browser-linux*.tar.xz -C ~/opt/Mep
#~/opt/Mep/start-tor-browser.desktop --register-app

# Mega
#sudo pacman -U /package.pkg.tar.zst
# Installing team missing libraries. Without the aur package.
# cd ~/.steam/root/ubuntu12_32
# file * | grep ELF | cut -d: -f1 | LD_LIBRARY_PATH=. xargs ldd | grep 'not found' | sort | uniq
# while steam is running (this might be useless)
# for i in $(pgrep steam); do sed '/\.local/!d;s/.*  //g' /proc/$i/maps; done | sort | uniq


# AI (no quick install tips like above because these keep evolving)
# sudo pacman -S microconda
#follow(always manual, cus debug. Mainly for oobabooga):
#https://docs.sillytavern.app/installation/linuxmacos/
#https://docs.sillytavern.app/extras/installation/
#https://github.com/oobabooga/text-generation-webui (look at linked docs, especially gptq-for-llama if it's still needed)

# portmaster lan: ??? 
#note: obs will install ffmpeg and vlc. OBS should go first to avoid dependency conflicts that are irreversible

#Intel drivers # might not be necessary. xf86-video-intel? let the installer decide
#sudo pacman -S mesa lib32-mesa vulkan-intel lib32-vulkan-intel intel-media-driver
#Nvidia drivers
#sudo pacman -S libva-mesa-driver mesa-vdpau # opensource
#paru -S nouveau-fw # for opensource
#sudo pacman -S nvidia nvidia-utils lib32-nvidia-utils

## Snapper creation instruction if needed. Hopefully not needed
#snapper with default btrfs layout because people suck shit at explaining shit online and shit and so many websites dont tell you shit
#sudo nano /etc/conf.d/snapper add snapper after "SNAPPER_CONFIGS="
#create a config for home or any folder
#sudo cp /etc/snapper/configs/home /etc/snapper/configs/root
#edit root to match

# Resize partition instructions.
# Create V partition
# go on archiso
# mount /dev/nvme0n1p2 /mnt (do not unmount)
# parted /dev/nvme0n1 resizepart 2 200GB
# btrfs filesystem resize max /mnt
# reboot

# QT Colors
# ayu Mirage and kvAdaptaDark

#virtio???
