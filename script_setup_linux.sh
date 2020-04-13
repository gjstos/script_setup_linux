#!/bin/bash

echo "  _       _                            ____           _                   ";
echo " | |     (_)  _ __    _   _  __  __   / ___|    ___  | |_   _   _   _ __  ";
echo " | |     | | | '_ \  | | | | \ \/ /   \___ \   / _ \ | __| | | | | | '_ \ ";
echo " | |___  | | | | | | | |_| |  >  <     ___) | |  __/ | |_  | |_| | | |_) |";
echo " |_____| |_| |_| |_|  \__,_| /_/\_\   |____/   \___|  \__|  \__,_| | .__/ ";
echo "                                                                   |_|    ";
echo "";
echo "";

DISTRO=$(grep -Eo "(Ubuntu|Mint)" /etc/issue)

# =============================         Removing possible latches on apt         ============================= #

sudo rm /var/lib/dpkg/lock-frontend 
sudo rm /var/cache/apt/archives/lock

# =============================  Update apt repository and Upgrade all packages  ============================= #
 
sudo apt update
sudo apt -y upgrade

# =============================              Fixing missing packages             ============================= #

sudo apt install -y build-essential 
if [ "$DISTO" = "Ubuntu" ] ; then
    sudo apt install -y ubuntu-restricted-extras
else 
    sudo apt install mint-meta-codecs
fi
sudo apt install -y apt-transport-https
sudo apt install -y unzip
sudo apt install -y curl
sudo apt install -y xz-utils
sudo apt install -y git
sudo apt install -y ffmpeg

# =============================            Removing unwanted packages            ============================= #

if [ "$DISTRO" = "Ubuntu" ] ; then
    sudo snap remove gnome-system-monitor gnome-calculator gnome-characters gnome-logs
fi

sudo apt remove -y --purge --autoremove transmission*

# =============================                   Adding PPA's                   ============================= #

## Graphics card drivers
sudo add-apt-repository -y ppa:graphics-drivers/ppa

## Typora
sudo sh -c 'wget -qO- https://typora.io/linux/public-key.asc | sudo apt-key add -'
sudo sh -c 'echo "deb https://typora.io/linux ./" > /etc/apt/sources.list.d/typora.list'

## QBitTorrent
if ! sudo apt search -n qbittorrent ; then
    sudo add-apt-repository -y ppa:qbittorrent-team/qbittorrent-stable
fi

## Timeshift
if ! sudo apt search -n timeshift ; then
    sudo add-apt-repository -y ppa:teejee2008/timeshift
fi

## LibreOffice
sudo add-apt-repository -y ppa:libreoffice/ppa

## Stacer
sudo add-apt-repository -y ppa:oguzhaninan/stacer -y

## Google Chrome
sudo sh -c 'wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - '
sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'

## Visual Studio Code
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

## OpenJDK
if ! sudo apt search -n openjdk-8-jdk ; then
    sudo add-apt-repository -y ppa:openjdk-r/ppa
fi

## Dart Lang
sudo sh -c 'wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -'
sudo sh -c 'wget -qO- https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list'


# =============================              Installing new packages             ============================= #

sudo apt update
sudo apt -y upgrade

## Gnome Packages 
if [ "$DISTRO" = "Ubuntu" ] ; then
    sudo apt install -y gnome-system-monitor gnome-calculator gnome-characters gnome-logs # gnome-tweak-tool
fi

## Snap
if [ "$DISTRO" = "Mint" ] ; then
    sudo apt install -y snapd
fi

## Typora
sudo apt install -y typora

## KVM
# Note: I am installing KVM because my machine has support emulation by hardware. 
# In case your computer does not have this support it is recommended to remove the lines regarding this package.
sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils
sudo adduser "$(id -un)" libvirt
sudo adduser "$(id -un)" kvm

## QBitTorrent
sudo apt install -y qbittorrent

## Stacer
sudo apt install -y stacer

## Timeshift
sudo apt install -y timeshift

## Gparted
sudo apt install -y gparted

## Fira Code
sudo apt install -y fonts-firacode

## LibreOffice
sudo apt install -y libreoffice

## Google Chrome
sudo apt install -y google-chrome-stable

## Visual Studio Code
sudo apt install -y code

## OpenJDK 8
# Currently [date of script creation] the Flutter breaks with versions higher than Java 8, 
# so I will install the version that works without issues
sudo apt install -y openjdk-8-jdk

## Dart Lang
sudo apt install -y dart

## VirtualBox
sudo apt install -y virtualbox

## Clang 9
# Dependency that the Flutter Desktop will need
# Note that I am using 9 version of the clang 
# In case there is a newer version in apt repo just replace with the latest version in all
# the following commands
sudo apt install -y clang-9
sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-9 9
sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-9 9

# Android Studio
sudo snap install android-studio --classic

## OBS Studio
sudo snap install obs-studio

## VLC
sudo snap install vlc

# =============================               Flutter & Dart Setup               ============================= #

mkdir ~/Development

## Note that I am using the "master" branch instead of the "stable" because I will be using
## the Flutter Web and Flutter Desktop. 
git clone -b master https://github.com/flutter/flutter.git ~/Development/flutter

## Adding to the file ". bashrc" the variables required for the Flutter / Dart
echo ""                                                       >> ~/.bashrc
echo "#====================================================#" >> ~/.bashrc
echo "#    Flutter && Dart Setup"                             >> ~/.bashrc
echo "#====================================================#" >> ~/.bashrc
echo "export PATH=$PATH:/usr/lib/dart/bin"                    >> ~/.bashrc
echo "export PATH=$PATH:$HOME/.pub-cache/bin"                 >> ~/.bashrc
echo "export PATH=$PATH:$HOME/Development/flutter/bin"        >> ~/.bashrc

## Post configuration commands
declare -r bashrc="$HOME"/.bashrc
source "$bashrc"
## Slidy CLI
pub global activate slidy
## Flutter 
flutter doctor
flutter config --enable-linux-desktop --enable-web --enable-android-embedding-v2

# =============================                Typora Theme Setup                ============================= #

mkdir ~/Downloads/program_files

cd ~/Downloads/program_files

wget -c https://github.com/xypnox/xydark-typora/releases/download/v0.2/theme.zip

## Install the Xydark theme
unzip theme.zip
mv theme/* ~/.config/Typora/themes/

# =============================           Android Studio & Java Setup            ============================= #

## Adding to the file ". bashrc" the variables required for the Android Studio / Java
echo ""                                                                   >> ~/.bashrc
echo "#====================================================#"             >> ~/.bashrc
echo "#    Android Studio && Java Setup"                                  >> ~/.bashrc
echo "#====================================================#"             >> ~/.bashrc
echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64"                 >> ~/.bashrc
echo "export PATH=$PATH:$JAVA_HOME/bin"                                   >> ~/.bashrc
echo "export ANDROID_HOME=$HOME/Android/Sdk"                              >> ~/.bashrc
echo "export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools" >> ~/.bashrc


# =============================                GitKraken Install                 ============================= #
cd ~/Downloads

wget -c https://release.gitkraken.com/linux/gitkraken-amd64.deb

sudo dpkg -i ./*.deb

# =============================              Update Graphics Driver              ============================= #

sudo apt update
sudo ubuntu-drivers autoinstall -y
sudo apt full-upgrade -y

# =============================                  Finally Ending                  ============================= #


echo "                                                          ";
echo "                                                          ";
echo "██╗    ██╗ █████╗ ██████╗ ███╗   ██╗██╗███╗   ██╗ ██████╗ ";
echo "██║    ██║██╔══██╗██╔══██╗████╗  ██║██║████╗  ██║██╔════╝ ";
echo "██║ █╗ ██║███████║██████╔╝██╔██╗ ██║██║██╔██╗ ██║██║  ███╗";
echo "██║███╗██║██╔══██║██╔══██╗██║╚██╗██║██║██║╚██╗██║██║   ██║";
echo "╚███╔███╔╝██║  ██║██║  ██║██║ ╚████║██║██║ ╚████║╚██████╔╝";
echo " ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝╚═╝  ╚═══╝ ╚═════╝ ";
echo "                                                          ";
echo "                                                          ";

echo "You need to start Android Studio to finish the Flutter setup."
echo ""
echo "Be sure to install the Android SDK in the path /home/your_user/Android/Sdk"
echo ""
echo "Otherwise you will need to change the path of the ANDROID_HOME in the /home/your_user/.bashrc file to what you defined in the Android SDK installation."
echo ""
echo ""