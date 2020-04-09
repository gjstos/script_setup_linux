#!/bin/bash

echo "  _       _                            ____           _                   ";
echo " | |     (_)  _ __    _   _  __  __   / ___|    ___  | |_   _   _   _ __  ";
echo " | |     | | | '_ \  | | | | \ \/ /   \___ \   / _ \ | __| | | | | | '_ \ ";
echo " | |___  | | | | | | | |_| |  >  <     ___) | |  __/ | |_  | |_| | | |_) |";
echo " |_____| |_| |_| |_|  \__,_| /_/\_\   |____/   \___|  \__|  \__,_| | .__/ ";
echo "                                                                   |_|    ";
echo "";
echo "";

# =============================         Removing possible latches on apt         ============================= #

sudo rm /var/lib/dpkg/lock-frontend 
sudo rm /var/cache/apt/archives/lock

# =============================  Update apt repository and Upgrade all packages  ============================= #
 
sudo apt-get update
sudo apt-get -y upgrade

# =============================              Fixing missing packages             ============================= #

sudo apt-get install -y build-essential 
sudo apt-get install -y ubuntu-restricted-extras
sudo apt-get install -y apt-transport-https
sudo apt-get install -y unzip
sudo apt-get install -y curl
sudo apt-get install -y xz-utils
sudo apt-get install -y git

# =============================            Removing unwanted packages            ============================= #

sudo snap remove gnome-system-monitor gnome-calculator gnome-characters gnome-logs
sudo apt-get remove -y --purge --autoremove transmission*

# =============================                   Adding PPA's                   ============================= #
# Note that some of the PPA's below already exist in the apt-cache, but I'm putting it just to be sure.

## Graphics card drivers
sudo add-apt-repository -y ppa:graphics-drivers/ppa

## Typora
sudo sh -c 'wget -qO- https://typora.io/linux/public-key.asc | sudo apt-key add -'
sudo sh -c 'echo "deb https://typora.io/linux ./" > /etc/apt/sources.list.d/typora.list'

## QBitTorrent
sudo add-apt-repository -y ppa:qbittorrent-team/qbittorrent-stable

## Timeshift
sudo add-apt-repository -y ppa:teejee2008/timeshift

## LibreOffice
sudo add-apt-repository -y ppa:libreoffice/ppa

## Google Chrome
sudo sh -c 'wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - '
sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'

## Visual Studio Code
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

## OpenJDK
sudo add-apt-repository -y ppa:openjdk-r/ppa

## Dart Lang
sudo sh -c 'wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -'
sudo sh -c 'wget -qO- https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list'

## Android Studio
sudo add-apt-repository -y ppa:maarten-fonville/android-studio

# =============================              Installing new packages             ============================= #

sudo apt-get update
sudo apt-get -y upgrade

## Gnome Packages 
sudo apt install -y gnome-system-monitor gnome-calculator gnome-characters gnome-logs gnome-tweak-tool

## Typora
sudo apt-get install -y typora

## KVM
# Note: I am installing KVM because my machine has support emulation by hardware. 
# In case your computer does not have this support it is recommended to remove the lines regarding this package.
sudo apt-get install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils
sudo adduser `id -un` libvirt
sudo adduser `id -un` kvm

## QBitTorrent
sudo apt-get install -y qbittorrent

## Timeshift
sudo apt-get install -y timeshift

## LibreOffice
sudo apt install -y libreoffice

## Google Chrome
sudo apt-get install -y google-chrome-stable

## Visual Studio Code
sudo apt install -y code

## OpenJDK 8
# Currently [date of script creation] the Flutter breaks with versions higher than Java 8, 
# so I will install the version that works without issues
sudo apt-get install -y openjdk-8-jdk

## Dart Lang
sudo apt-get install -y dart

## Clang 9
# Dependency that the Flutter Desktop will need
# Note that I am using 9 version of the clang 
# In case there is a newer version in apt-cache just replace with the latest version in all
# the following commands
sudo apt-get install -y clang-9
sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-9 9
sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-9 9

# Android Studio
sudo apt-get install -y android-studio

## VLC
sudo snap install vlc

# =============================               Flutter & Dart Setup               ============================= #

mkdir $HOME/Development

## Note that I am using the "master" branch instead of the "stable" because I will be using
## the Flutter Web and Flutter Desktop. 
git clone -b master https://github.com/flutter/flutter.git $HOME/Development/flutter

## Adding to the file ". bashrc" the variables required for the Flutter / Dart
echo ''                                                       >> $HOME/.bashrc
echo '#====================================================#' >> $HOME/.bashrc
echo "#    Flutter && Dart Setup"                             >> $HOME/.bashrc
echo '#====================================================#' >> $HOME/.bashrc
echo 'export PATH="$PATH:/usr/lib/dart/bin"'                  >> $HOME/.bashrc
echo 'export PATH="$PATH:$HOME/.pub-cache/bin"'               >> $HOME/.bashrc
echo 'export PATH="$PATH:$HOME/Development/flutter/bin"'      >> $HOME/.bashrc

## Post configuration commands
source $HOME/.bashrc
## Slidy CLI
pub global activate slidy
## Flutter 
flutter doctor
flutter config --enable-linux-desktop
flutter config --enable-web
flutter config --enable-android-embedding-v2
## Don't need, but I'll put it to be sure 
flutter upgrade

# =============================                Typora Theme Setup                ============================= #

mkdir $HOME/Downloads/program_files

cd $HOME/Downloads/program_files

wget -c https://github.com/xypnox/xydark-typora/releases/download/v0.2/theme.zip

## Install the Xydark theme
unzip theme.zip
mv theme/* $HOME/.config/Typora/themes/

# =============================           Android Studio & Java Setup I          ============================= #

## Adding to the file ". bashrc" the variables required for the Android Studio / Java
echo ''                                                                   >> $HOME/.bashrc
echo '#====================================================#'             >> $HOME/.bashrc
echo "#    Android Studio && Java Setup"                                  >> $HOME/.bashrc
echo '#====================================================#'             >> $HOME/.bashrc
echo 'export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64'                 >> $HOME/.bashrc
echo 'export PATH=$PATH:$JAVA_HOME/bin'                                   >> $HOME/.bashrc
echo 'export ANDROID_HOME=$HOME/Android/Sdk'                              >> $HOME/.bashrc
echo 'export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools' >> $HOME/.bashrc


# =============================              Update Graphics Driver              ============================= #

sudo apt-get update
sudo ubuntu-drivers autoinstall -y
sudo apt dist-upgrade -y

# =============================          Android Studio & Java Setup II          ============================= #

