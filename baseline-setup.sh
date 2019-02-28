#!/bin/bash
#
# baseline setup script
#
# Here is a list of what will be installed:

# color distinction
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# check for root privileges
if [ $UID -ne 0 ]; then
    echo -e "${RED}This script must be run as root${NC}" 
    exit 1
fi

function yump(){
    yum install -y $@
}

# update yum
yum update -y

# enable additional yum repos
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm

# install yum utilities
yump yum-utils

# yum group installs
yum group install -y "Virtualization Host"

# install necessary packages
yump python36 git htop wget nginx device-mapper-persistent-data lvm2
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
ln -s /usr/bin/python3.6 /usr/bin/python3
python3 get-pip.py
ln -s /usr/local/bin/pip /bin/pip
yump autoreconf automake autoconf gtk3-devel
yump gcc kernel-source kernel-devel
wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm -P /tmp
yum localinstall -y google-chrome-stable_current_x86_64.rpm
rm -f /tmp/google-chrome-stable_current_x86_64.rpm

# install updated kernel
yum --enablerepo=elrepo-kernel install kernel-ml

# setup repo for docker
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yump docker-ce  docker-ce-cli containerd.io

# user configuration
useradd jlaberge
usermod -aG wheel jlaberge
usermod -aG docker jlaberge

# setup environment
yump guake zsh

git clone https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/custom/plugins/zsh-completions

hostnamectl set-hostname 'konoha.local'
hostnamectl set-hostname --pretty 'Konoha - Village Hidden in the Leaves'
git clone https://github.com/horst3180/arc-theme --depth 1 && cd arc-theme
./autogen.sh
make install

wget http://us.download.nvidia.com/XFree86/Linux-x86_64/410.93/NVIDIA-Linux-x86_64-410.93.run -P /tmp
/tmp/NVIDIA-Linux-x86_64-410.93.run


# setup environment for user
cd /home/jlaberge
wget https://raw.githubusercontent.com/rupa/z/master/z.sh
printf "\n\n#initialize Z (https://github.com/rupa/z) \n. ~/z.sh \n\n" >> .bashrc
chown -R jlaberge:jlaberge z.sh
chmod 600 z.sh

https://github.com/keepassxreboot/keepassxc/releases/download/2.3.4/KeePassXC-2.3.4-x86_64.AppImage
chmod +x KeePassXC-2.3.4-x86_64.AppImage
./KeePassXC-2.3.4-x86_64.AppImage

cp /usr/share/applications/guake.desktop /etc/xdg/autostart/
