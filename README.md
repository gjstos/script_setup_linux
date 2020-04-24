# My Setup Script :floppy_disk:

This repository contains a Linux configuration script [only for Ubuntu-based distributions and Linux Mint] that I did to facilitate the installation of a new Linux distribution.

## :pushpin: ​Softwares

- Android Studio
- Dart
- Flutter [enabled WEB and Desktop]
- ~~Gnome Tweak Tool~~ 
- Google Chrome
- KVM
- LibreOffice
- OpenJDK 8 JDK
- qBittorrent
- Timeshift
- Typora
- VLC
- Visual Studio Code
- OBS Studio
- VirtualBox
- Gparted
- Fira Code (font)
- Stacer
- scrcpy
- adb

## :hammer: ​Installation of the Script

1. Open in Terminal the folder where is saved the ***script_setup_linux.sh*** file

2. Type the following command and enter your password when prompted:

   ```bash
   sudo chmod +x script_setup_linux.sh
   ```

3. Now type the following command and enter your password when prompted:

   ```bash
   ./script_setup_linux.sh
   ```

4. Case appears the error below:

   ```bash
   bash: ./script_setup_linux.sh: /bin/bash^M: bad interpreter: No such file or directory
   ```

   Just type the command below and remake the step 3:

   ```bash
   sed -i -e 's/\r$//' script_setup_linux.sh
   ```

5. Now it's just grab a coffee :coffee: and hope to finalize the installation of the programs

### :warning: Attention :warning:

- There will be the need for interaction with the terminal when the script is installing  the Graphical Drivers.
- After the finalization of the script starts Android Studio and follow the steps until you appear the initial screen of the Software.
- Be sure to put as path to save the Android Studio SDK in ```/home/your_user/Android/Sdk```. Otherwise, you will need to change to the selected path in the ```~/.bashrc``` file in the ANDROID_HOME variable.
- Run the ```flutter doctor -v``` command to see if it's all right. In case it appears any error, Uncle [Google](https://www.google.com "Google's Homepage") can help you :blush:.
