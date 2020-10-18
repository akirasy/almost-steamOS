#!/usr/bin/env bash

# Define color codes
endcolor="\033[0m"
cyan="\033[0;36m"
bgreen="\033[1;32m"
bcyan="\033[1;36m"

function check_sudo {  # change this to case switch
    case $EUID in
        0) clear; echo -e "\n${bcyan}Sudo priviledge: Granted${endcolor}\n" ;;
        *) echo -e "\n${bcyan}Installer must be run as sudo.${endcolor}\n" 
           echo "Exiting now.\n"; exit ;;
    esac
}

function show_intro {
    echo -e "${bcyan}Make sure all the pre-requisites are met.${endcolor}"
    echo "You should have done this prior to running this script."
    echo "    1. Make sure debian usb stick or debian iso is available."
    echo "    2. Install minimal Debian server to your PC."
    echo "    3. Install graphic card driver. (Installation of graphic card is not fully supported)"
    echo "Continue running script? (Y/N)"
    echo -en "${bgreen}Answer: ${endcolor}"; read reply; case $reply in
        Y|y|Yes|yes ) echo "Okay..." ;;
        *           ) exit ;;
    esac
}

function add_arch {
    echo -e "\n\n${bcyan}Adding 32bit support to apt repository.${endcolor}"
    dpkg --add-architecture i386
    apt update
}

function check_internet {
    while [ True ]; do
        internet_true=$( wget --quiet --spider https://www.debian.org; echo $? )
        case $internet_true in
            0)  echo -e "\n\n${bcyan}Internet connection established!${endcolor}"
                read -p "Press ENTER to continue..."
                break ;;
            *)  echo -e "\n\n${bcyan}You are not connected to the internet.${endcolor}"
                read -p "Press ENTER to configure network..."
                nmtui; sleep 1 ;;
        esac
    done
}

function mount_local_apt {
    mkdir -p /mnt/local-apt
    mkdir -p /etc/apt/sources.list.d/
    cp $PWD/config/apt/local-repo.list /etc/apt/sources.list.d/local-repo.list
    echo -e "${bcyan}Installation requires '*.iso' file or 'debian usb drive' to use as apt-repo.${endcolor}"
    echo "Which one do you have?"
    echo "    1) Debian usb stick"
    echo "    2) Debian iso file"
    echo "    *) I don't have any of the above"
    echo -en "${bgreen}Answer: ${endcolor}"; read reply; case $reply in
        1)  lsblk
            echo -e "${bcyan}Write out your usb mount point. (eg /dev/sdb1)${endcolor}"
            read -e -p "Mount point: " apt_source
            mount $apt_source /mnt/local-apt ;;
        2)  echo -e "${bcyan}Where is the iso file? (provide absolute path please)${endcolor}"
            read -e -p "Absolute filepath: " apt_source
            mount -o loop $apt_source /mnt/local-apt ;;
        *)  echo "Get all pre-requisites ready. Then rerun this script."
            exit ;;
    esac
}

function install_offline {
    echo -e "\n\n${bcyan}Installing packages from local repository.${endcolor}"
    echo "This may take a while..."
    read -p "Press ENTER to continue..."
    mv /etc/apt/sources.list /etc/apt/sources.list.orig
    echo "#" > /etc/apt/sources.list
    apt -y update; apt -y install network-manager \
                   xorg openbox lightdm \
                   pulseaudio pavucontrol \
                   lxterminal wget
}

function install_online {
    echo -e "\n\n${bcyan}Installing packages from the internet.${endcolor}"
    echo "This may take a while..."
    read -p "Press ENTER to continue..."
    cp $PWD/config/apt/sources.list /etc/apt/sources.list
    apt -y update; apt -y install tint2 feh \
                   firmware-misc-nonfree \
                   firmware-realtek
}

function install_graphic {
    echo -e "\n\n${bcyan}Trying to install graphic card driver.${endcolor}"
    vga_type=$( lspci | grep VGA | awk '{print $5}' )
    case $vga_type in
        NVIDIA) echo "Installing NVIDIA drivers."
                apt -y install nvidia-driver \
                               nvidia-driver-libs-i386 ;;
             *) echo "VGA type not supported." ;;
    esac
}

function copy_config {
    echo -e "\n\n${bcyan}Apply settings for almost-steamOS.${endcolor}"
    user_name=$( who | awk '{print $1}' )
    #  ------ apt ------
    echo -e "${bcyan}Configure setting:${endcolor} apt"
    cp $PWD/config/apt/sources.list /etc/apt/sources.list
    chmod 644 /etc/apt/sources.list
    # ------ lightdm ------ 
    echo -e "${bcyan}Configure setting:${endcolor} lightdm"
    sed "s/steam/$user_name/g" -i $PWD/config/lightdm/lightdm.conf
    cp $PWD/config/lightdm/lightdm.conf /etc/lightdm/lightdm.conf
    chmod 644 /etc/lightdm/lightdm.conf
    # ------ openbox ------ 
    echo -e "${bcyan}Configure setting:${endcolor} openbox"
    mkdir -p /home/$user_name/.config/openbox
    cp $PWD/config/openbox/* /home/$user_name/.config/openbox/
    chown $user_name:$user_name /home/$user_name/.config/openbox
    chown $user_name:$user_name /home/$user_name/.config/openbox/autostart
    chown $user_name:$user_name /home/$user_name/.config/openbox/environment
    chown $user_name:$user_name /home/$user_name/.config/openbox/menu.xml
    chown $user_name:$user_name /home/$user_name/.config/openbox/rc.xml
    chmod 755 $user_name:$user_name /home/$user_name/.config/openbox/autostart
    chmod 755 $user_name:$user_name /home/$user_name/.config/openbox/environment
    chmod 644 $user_name:$user_name /home/$user_name/.config/openbox/menu.xml
    chmod 644 $user_name:$user_name /home/$user_name/.config/openbox/rc.xml
    # ------ tint2 ------ 
    echo -e "${bcyan}Configure setting:${endcolor} tint2"
    mkdir -p /home/$user_name/.config/tint2
    sed "s/steam/$user_name/g" -i $PWD/config/tint2/combined.tint2rc
    cp $PWD/config/tint2/* /home/$user_name/.config/tint2
    cp $PWD/img/power-button.svg /home/$user_name/.config/tint2
    chown $user_name:$user_name /home/$user_name/.config/tint2
    chown $user_name:$user_name /home/$user_name/.config/tint2/combined.tint2rc
    chown $user_name:$user_name /home/$user_name/.config/tint2/power-button.svg
    chown $user_name:$user_name /home/$user_name/.config/tint2/autostart
    chmod 644 /home/$user_name/.config/tint2/combined.tint2rc
    chmod 644 /home/$user_name/.config/tint2/power-button.svg
    chmod 755 /home/$user_name/.config/tint2/autostart
    # ------ feh ------ 
    echo -e "${bcyan}Configure setting:${endcolor} feh"
    sed "s/steam/$user_name/g" -i $PWD/config/feh/fehbg
    mkdir -p /home/$user_name/.config/feh
    cp $PWD/config/feh/autostart /home/$user_name/.config/feh/autostart
    cp $PWD/img/wallpaper.png /home/$user_name/.config/feh/wallpaper.png
    chown $user_name:$user_name /home/$user_name/.config/feh
    chown $user_name:$user_name /home/$user_name/.config/feh/autostart
    chown $user_name:$user_name /home/$user_name/.config/feh/wallpaper.png
    chmod 755 /home/$user_name/.config/feh/autostart
    chmod 644 /home/$user_name/.config/feh/wallpaper.png
}

function web_browser {
    echo -e "\n\n${bcyan}Which web browser do you prefer?${endcolor}"
    echo "    1) Google Chrome"
    echo "    2) Chromium"
    echo "    3) Falkon"
    echo "    4) Firefox ESR"
    echo "    *) I'll install it manually."
    echo -en "${bgreen}Answer: ${endcolor}"; read reply; case $reply in
        1) wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
           apt -y install ./google-chrome-stable_current_amd64.deb
           rm google-chrome-stable_current_amd64.deb ;;
        2) apt -y install chromium ;;
        3) apt -y install falkon ;;
        4) apt -y install firefox-esr ;;
        *) echo "It's totally fine for not having web browser. (^_^)";;
    esac
}

function cleanup {
    echo -e "\n\n${bcyan}Cleaning up installation process...${endcolor}"
    echo -e "${cyan}Disable local iso repository.${endcolor}"
    sed 's/^/#/' -i /etc/apt/sources.list.d/local-iso.list
    echo -e "${cyan}Update, upgrade and clean apt caches.${endcolor}"
    apt update; apt -y upgrade; apt -y autoremove; apt clean

    echo -e "${bcyan}Installation completed...${endcolor}"
    echo "What do you want to do next?"
    echo "    1) Reboot the system and enjoy almost-steamOS"
    echo "    *) Exit script and go back to terminal"
    echo -en "${bgreen}Answer: ${endcolor}"; read reply; case $reply in
        1) echo "System will reboot in 3 seconds."
           sleep 3
           shutdown -r now ;;
        *) echo "Exiting installation script."
           echo "Hint: enter 'sudo shutdown now' to reboot." ;;
    esac
}

function main {
    check_sudo
    show_intro
    mount_local_apt
    install_offline
    check_internet
    install_online
    add_arch
    install_graphic
    apt -y install steam
    web_browser
    copy_config
    cleanup
}

main
