#!/bin/bash
trap 'exit 130' INT
shopt -s xpg_echo

DISTRO=$( (lsb_release -ds || cat /etc/*release || uname -om) 2>/dev/null | head -n1 | cut -f1 -d " ")

# check if is arch uname -r | sed 's/.*-*-//'
TERMS=(gnome-terminal konsole terminator xterm xfce4-terminal lxterminal rxvt)
for t in ${TERMS[*]}; do
    if [ $(command -v $t) ]; then
        detected_term=$t
        break
    fi
done

if [ "$USER" = "root" ]; then
    THIS_USER=$SUDO_USER
    THIS_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)
else
    THIS_USER=$USER
    THIS_HOME=$HOME
fi

echo "  _       _                            ____           _                   "
echo " | |     (_)  _ __    _   _  __  __   / ___|    ___  | |_   _   _   _ __  "
echo " | |     | | | '_ \  | | | | \ \/ /   \___ \   / _ \ | __| | | | | | '_ \ "
echo " | |___  | | | | | | | |_| |  >  <     ___) | |  __/ | |_  | |_| | | |_) |"
echo " |_____| |_| |_| |_|  \__,_| /_/\_\   |____/   \___|  \__|  \__,_| | .__/ "
echo "                                                                   |_|    "
echo ""
echo ""
echo " - Some windows can be opened, so wait and don't close them because"
echo "   the script will eventually close all of them"
echo " - Distro: $DISTRO"
echo " - Home: "$THIS_HOME""
echo " - User: "$THIS_USER"\n"
sleep 3

# =============================         Removing possible latches on apt         ============================= #

sudo rm /var/lib/dpkg/lock-frontend /var/cache/apt/archives/lock

# =============================  Update apt repository and Upgrade all packages  ============================= #

sudo apt update
sudo apt -y upgrade

# =============================              Fixing missing packages             ============================= #

echo "\n\e[96mInstalling:"
echo "\e[96m  - build-essential"
echo "\e[96m  - apt-transport-https"
echo "\e[96m  - unzip"
echo "\e[96m  - curl"
echo "\e[96m  - xz-utils"
echo "\e[96m  - git"
echo "\e[96m  - ffmpeg"
echo "\e[96m  - gnupg1"
echo "\e[96m  - libncurses5-dev"
echo "\e[96m  - make"
echo "\e[96m  - dirmngr\e[0m\n"
sudo apt install -y -m build-essential apt-transport-https unzip curl xz-utils git ffmpeg gnupg1 dirmngr libncurses5-dev make

if [ "$DISTRO" = "Ubuntu" ]; then
    echo "\n\e[96mInstalling:"
    echo "\e[96m  - ubuntu-restricted-extas\e[0m\n"
    sudo apt install -y ubuntu-restricted-extras
else
    echo "\n\e[96mInstalling:"
    echo "\e[96m  - mint-meta-codecs\e[0m\n"
    sudo apt install mint-meta-codecs
fi

# =============================            Removing unwanted packages            ============================= #

if [ "$DISTRO" = "Ubuntu" ]; then
    echo "\n\e[95mRemoving snaps:"
    echo "\e[95m  - gnome-system-monitor"
    echo "\e[95m  - gnome-calculator"
    echo "\e[95m  - gnome-characters"
    echo "\e[95m  - gnome-logs\e[0m\n"
    sudo snap remove gnome-system-monitor gnome-calculator gnome-characters gnome-logs
fi

echo "\n\e[95mRemoving:"
echo "\e[95m  - transmission"
echo "\e[95m  - remmina"
echo "\e[95m  - thunderbird\e[0m\n"
sudo apt-get remove -y --purge --autoremove transmission* remmina* thunderbird*

# =============================                   Adding PPA's                   ============================= #

## qBitTorrent
echo "\n\e[34mSearching in apt by:"
echo "\e[34m  - qbittorrent\e[0m\n"
if ! sudo apt search -n qbittorrent; then
    echo "\n\e[93mqBittorrent not found!"
    echo "\n\e[96mInstalling qBittorrent repository...\e[0m\n"
    sudo add-apt-repository -y ppa:qbittorrent-team/qbittorrent-stable
fi

## Timeshift
echo "\n\e[34mSearching in apt by:"
echo "\e[34m  - timeshift\e[0m\n"
if ! sudo apt search -n timeshift; then
    echo "\n\e[93mTimeshift not found!"
    echo "\n\e[96mInstalling Timeshift repository...\e[0m\n"
    sudo add-apt-repository -y ppa:teejee2008/timeshift
fi

## Stacer
echo "\n\e[34mSearching in apt by:"
echo "\e[34m  - stacer\e[0m\n"
if ! sudo apt search -n stacer; then
    echo "\n\e[93mStacer not found!"
    echo "\n\e[96mInstalling Stacer repository...\e[0m\n"
    sudo add-apt-repository -y ppa:oguzhaninan/stacer
fi

## OpenJDK
echo "\n\e[34mSearching in apt by:"
echo "\e[34m  - openjdk-8\e[0m\n"
if ! sudo apt search -n openjdk-8-jdk; then
    echo "\n\e[93mOpenJDK 8 not found!"
    echo "\n\e[96mInstalling OpenJDK repository...\e[0m\n"
    sudo add-apt-repository -y ppa:openjdk-r/ppa
fi

## Graphics card drivers
echo "\n\e[96mInstalling repository:"
echo "\e[96m  - graphics-drivers\e[0m\n"
sudo add-apt-repository -y ppa:graphics-drivers/ppa

## Typora
echo "\n\e[96mInstalling repository:"
echo "\e[96m  - typora\e[0m\n"
sudo sh -c 'wget -qO- https://typora.io/linux/public-key.asc | sudo apt-key add -'
sudo sh -c 'echo "deb https://typora.io/linux ./" > /etc/apt/sources.list.d/typora.list'

## LibreOffice
echo "\n\e[96mInstalling repository:"
echo "\e[96m  - libreoffice\e[0m\n"
sudo add-apt-repository -y ppa:libreoffice/ppa

if ! apt-key list | grep google; then
    echo "\n\e[96mInstalling apt-key:"
    echo "\e[96m  - google\e[0m\n"
    sudo sh -c 'wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - '
fi

## Google Chrome
echo "\n\e[96mSearching for the Chrome...\e[0m\n"
if ! cat /etc/apt/sources.list.d/google.list | grep chrome && [ ! -f /etc/apt/sources.list.d/google-chrome.list ]; then
    echo "\n\e[93mChrome not found!"
    echo "\n\e[96mInstalling source.list:"
    echo "\e[96m  - google-chrome\e[0m\n"
    sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
else
    echo "\n\e[92mChrome found!"
fi

## Dart Lang
echo "\n\e[96mInstalling source.list:"
echo "\e[96m  - dart\e[0m\n"
sudo sh -c 'wget -qO- https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list'

## Visual Studio Code
echo "\n\e[96mInstalling gpg key:"
echo "\e[96m  - microsoft\e[0m\n"
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >"$THIS_HOME"/.gnupg/microsoft.gpg
chmod 777 "$THIS_HOME"/.gnupg/microsoft.gpg
sudo install -o root -g root -m 644 "$THIS_HOME"/.gnupg/microsoft.gpg /etc/apt/trusted.gpg.d/
echo "\n\e[96mInstalling source.list:"
echo "\e[96m  - vscode\e[0m\n"
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

# =============================              Installing new packages             ============================= #

sudo apt update
sudo apt -y upgrade

## Gnome Packages
if [ "$DISTRO" = "Ubuntu" ]; then
    echo "\n\e[96mInstalling apt's:"
    echo "\e[96m  - gnome-system-monitor"
    echo "\e[96m  - gnome-calculator"
    echo "\e[96m  - gnome-characters"
    echo "\e[96m  - gnome-logs"
    echo "\e[96m  - gnome-tweak-tool\e[0m\n"
    sudo apt install -y gnome-system-monitor gnome-calculator gnome-characters gnome-logs gnome-tweak-tool
fi

echo "\n\e[96mInstalling apt's:"
echo "\e[96m  - snapd"
echo "\e[96m  - typora"
echo "\e[96m  - qbittorrent"
echo "\e[96m  - timeshift"
echo "\e[96m  - gparted"
echo "\e[96m  - fonts-firacode"
echo "\e[96m  - libreoffice-base"
echo "\e[96m  - google-chrome-stable"
echo "\e[96m  - code"
echo "\e[96m  - clang-9"
echo "\e[96m  - adb"
echo "\e[96m  - virtualbox"
echo "\e[96m  - dart"
echo "\e[96m  - qemu-kvm"
echo "\e[96m  - qemu-kvm"
echo "\e[96m  - libvirt-daemon-system"
echo "\e[96m  - libvirt-clients"
echo "\e[96m  - bridge-utils"
echo "\e[96m  - openjdk-8-jdk\e[0m\n"
sudo apt install -y pv tree snapd typora qbittorrent stacer timeshift gparted fonts-firacode libreoffice-base google-chrome-stable code clang-9 adb virtualbox dart qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils

## KVM
echo "\n\e[96mAddig \e[1;6m"$THIS_USER"\e[0m \e[96mto grouops libvirt and kvm\e...\e[0m\n"
sudo adduser "$THIS_USER" libvirt
sudo adduser "$THIS_USER" kvm

## Clang 9
echo "\n\e[96mUpdating {clang-9, clang++-9} to {clang, clang++}...\e[0m\n"
sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-9 9
sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-9 9

echo "\n\e[96mInstalling snap's:"
echo "\e[96m  - android-studio"
echo "\e[96m  - vlc"
echo "\e[96m  - scrcpy\e[0m\n"
sudo snap install android-studio --classic
sudo snap install vlc scrcpy

# =============================               Flutter & Dart Setup               ============================= #

sudo -u "$THIS_USER" mkdir "$THIS_HOME"/Development

echo "\n\e[96mCloning flutter in the ~/Development/flutter folder...\e[0m\n"
sudo -u "$THIS_USER" git clone -b master https://github.com/flutter/flutter.git "$THIS_HOME"/Development/flutter

## Adding to the file ".bashrc" the variables required for the Flutter / Dart
echo "" >>"$THIS_HOME"/.bashrc
echo "#====================================================#" >>"$THIS_HOME"/.bashrc
echo "#    Flutter && Dart Setup" >>"$THIS_HOME"/.bashrc
echo "#====================================================#" >>"$THIS_HOME"/.bashrc
echo "export PATH="'$PATH'":/usr/lib/dart/bin" >>"$THIS_HOME"/.bashrc
echo "export PATH="'$PATH'":"'$HOME'"/.pub-cache/bin" >>"$THIS_HOME"/.bashrc
echo "export PATH="'$PATH'":"'$HOME'"/Development/flutter/bin" >>"$THIS_HOME"/.bashrc

## Post configuration commands
echo "\n\e[96mPost configuration commands for flutter and dart {slidy}...\e[0m\n"
sudo -u "$THIS_USER" gnome-terminal --disable-factory -q -- bash -ic "echo -e '\n\e[96mInstalling Slidy on Dart...\n\e[0m' ; pub global activate slidy ; echo -e $'\n\e[96mFlutter\'s initial commands...\n\e[0m' ; flutter upgrade ; flutter doctor ; echo -e '\n\e[96mActivating Flutter desktop-embedding, web and android-embedding-v2...\n\e[0m' ; flutter config --enable-linux-desktop --enable-web --enable-android-embedding-v2 ; sleep 5"

# =============================                Typora Theme Setup                ============================= #

sudo -u "$THIS_USER" mkdir /tmp/program_files
cd /tmp/program_files
echo "\n\e[96mDownloading theme XYDark for Typora...\e[0m\n"
sudo -u "$THIS_USER" wget -c https://github.com/xypnox/xydark-typora/releases/download/v0.2/theme.zip
chmod 777 theme.zip

## Install the Xydark theme
echo "\n\e[96mInstalling theme XYDark for Typora...\e[0m\n"
sudo -u "$THIS_USER" unzip theme.zip
sudo -u "$THIS_USER" typora &
sleep 7
killall -I TYPORA
sudo -u "$THIS_USER" cp -r theme/* "$THIS_HOME"/.config/Typora/themes/

# =============================                  progress Setup                  ============================= #

echo "\n\e[96mCloning and Installing progress...\e[0m\n"
sudo -u "$THIS_USER" git clone https://github.com/Xfennec/progress.git
cd progress
make
make install

# =============================           Android Studio & Java Setup            ============================= #

## Adding to the file ".bashrc" the variables required for the Android Studio / Java
echo "" >>"$THIS_HOME"/.bashrc
echo "#====================================================#" >>"$THIS_HOME"/.bashrc
echo "#    Android Studio && Java Setup" >>"$THIS_HOME"/.bashrc
echo "#====================================================#" >>"$THIS_HOME"/.bashrc
echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >>"$THIS_HOME"/.bashrc
echo "export PATH="'$PATH'":"'$JAVA_HOME'"/bin" >>"$THIS_HOME"/.bashrc
echo "export ANDROID_HOME="'$HOME'"/Android/Sdk" >>"$THIS_HOME"/.bashrc
echo "export PATH="'$PATH'":"'$ANDROID_HOME'"/tools:"'$ANDROID_HOME'"/platform-tools" >>"$THIS_HOME"/.bashrc

# =============================                GitKraken Install                 ============================= #
echo "\n\e[96mDownloading Gitkraken...\e[0m\n"
wget -cnd https://release.gitkraken.com/linux/gitkraken-amd64.deb

echo "\n\e[96mInstalling Gitkraken...\e[0m\n"
sudo dpkg -i ./gitkraken-amd64.deb

# =============================                   Final Touchs                   ============================= #

CHROME_PPA=/etc/apt/sources.list.d/google-chrome.list
if [ -f "$CHROME_PPA" ]; then
    sudo rm /etc/apt/sources.list.d/google.list
fi
sudo apt update
sudo apt --fix-broken install -y
sudo ubuntu-drivers autoinstall
sudo apt full-upgrade -y

# =============================                  Finally Ending                  ============================= #

echo "\n"
echo "\e[31m██╗    ██╗ █████╗ ██████╗ ███╗   ██╗██╗███╗   ██╗ ██████╗ "
echo "\e[31m██║    ██║██╔══██╗██╔══██╗████╗  ██║██║████╗  ██║██╔════╝ "
echo "\e[31m██║ █╗ ██║███████║██████╔╝██╔██╗ ██║██║██╔██╗ ██║██║  ███╗"
echo "\e[31m██║███╗██║██╔══██║██╔══██╗██║╚██╗██║██║██║╚██╗██║██║   ██║"
echo "\e[31m╚███╔███╔╝██║  ██║██║  ██║██║ ╚████║██║██║ ╚████║╚██████╔╝"
echo "\e[31m ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝╚═╝  ╚═══╝ ╚═════╝ "
echo "\e[0m\n"

echo "  - You need to start Android Studio to finish the Flutter setup."
echo "  - Be sure to install the Android SDK in the path /home/your_user/Android/Sdk"
echo "    otherwise you will need to change the path of the ANDROID_HOME in the "
echo "    /home/your_user/.bashrc file to what you defined in the Android SDK installation."
echo ""
