#!/bin/sh
#
#  Post-install script for Ubuntu
#
#  Copyright (C) 2024 Mark Baaijens <mark.baaijens@gmail.com>
#
#  This is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

# Script must NOT be executed as root b/c otherwise some user settings end up in the root domain
if [ -n "$(whoami | grep root)" ]
then
  echo "Running as root. Exiting"
  exit 1    
fi

# Check for supported desktop(s)
desktop=$(echo $DESKTOP_SESSION | tr '[:upper:]' '[:lower:]')
if [ "$desktop" != "ubuntu" ]
then
  echo "No supported desktop found. Exiting"
  exit 1      
fi

#
# User dialog
#
echo "Choose what to install:"
read -r -p "Telegram? [y/N] " install_telegram
read -r -p "Visual Studio Code? [y/N] " install_code
read -r -p "Audio-suite (PuddleTag, SoundJuicer, Audacity, QuodLibet, SoundVisualiser, Flacon and Spek)? [y/N] " install_audio
read -r -p "Graphic-suite (GIMP, Pinta, Inkscape)? [y/N] " install_graphic
read -r -p "SyncThing? [y/N] " install_sync
read -r -p "Zim desktop-wiki? [y/N] " install_zim
read -r -p "Raspberry Pi-imager? [y/N] " install_rpimager
read -r -p "Chromium-browser? [y/N] " install_chromium
read -r -p "Complete language support (this may take a while)? [y/N] " install_language
read -r -p "Upgrade packages (this may take a while)? [y/N] " install_upgrade

#
# System settings
#

# De-activate error-system
sudo sed -i 's/enabled=1/enabled=0/g' /etc/default/apport

# Commented out b/c zram-config is not working correctly on arm64
# Use zram = compressed memory (advantage when in low memory)
#sudo apt-get install zram-config -y
#sudo systemctl enable zram-config
#sudo systemctl start zram-config

# Increase swappiness to make better use of zram
#sudo sed -i '/vm.swappiness=/d' /etc/sysctl.conf  # Remove the line first if present
#sudo /bin/sh -c 'echo "vm.swappiness=150" >> /etc/sysctl.conf'

#
# Personal settings
#

# Provide template for text-file through context-menu Nautilus
if [ -d ~/Sjablonen ]; then
    touch ~/Sjablonen/Tekst-document.txt
else
    echo "Folder ~/Sjablonen is not present, installation language is not Dutch?"    
fi

# Interface
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface show-battery-percentage true
gsettings set org.gnome.desktop.interface monospace-font-name 'Ubuntu Mono 11'

# Date
gsettings set org.gnome.desktop.interface clock-show-weekday true
gsettings set org.gnome.desktop.calendar show-weekdate true

# Dock
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize-or-previews'
gsettings set org.gnome.shell.extensions.dash-to-dock autohide-in-fullscreen true
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts false
gsettings set org.gnome.shell.extensions.dash-to-dock show-trash true

# Favourites, only replace when these are set to default from a clean install
if [ "$(gsettings get org.gnome.shell favorite-apps)" = "['ubuntu-desktop-installer_ubuntu-desktop-installer.desktop', 'ubiquity.desktop', 'firefox_firefox.desktop', 'thunderbird.desktop', 'org.gnome.Nautilus.desktop', 'rhythmbox.desktop', 'libreoffice-writer.desktop', 'snap-store_snap-store.desktop', 'yelp.desktop']" ]; then
    gsettings set org.gnome.shell favorite-apps "['firefox_firefox.desktop', 'org.gnome.Nautilus.desktop']"
fi

# Workspaces
gsettings set org.gnome.mutter dynamic-workspaces false
gsettings set org.gnome.desktop.wm.preferences num-workspaces 1

# Nightmode
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 3282

# Mouse and Touchpad 
gsettings set org.gnome.desktop.peripherals.touchpad speed 0.3 # Accelerate a bit

# Nautilus
gsettings set org.gnome.nautilus.preferences open-folder-on-dnd-hover true
gsettings set org.gnome.nautilus.preferences recursive-search 'never'
gsettings set org.gnome.nautilus.preferences show-delete-permanently true
gsettings set org.gnome.nautilus.preferences show-directory-item-counts 'always'
gsettings set org.gnome.nautilus.preferences show-image-thumbnails 'always'

#
# Packages 
#

# Update first otherwise subsequent installs will not work on a fresh system
# Notice the single 'q' (and not 'qq') to procvide some feedback
sudo apt-get update -y  

# Several basic packages
sudo apt-get install dconf-editor htop tree bwm-ng nmap -y
sudo apt-get install gnome-shell-extension-manager -y

# Replace rhythmbox with Lollypop as the default music-player
sudo apt remove rhythmbox -y
sudo apt install lollypop -y 

if [ "$install_audio" = "y" ] || [ "$install_audio" = "Y" ]; then
    sudo apt-get install puddletag -y
    sudo apt-get install sound-juicer -y
    # TODO: removable media => link audio-cd to sound-juicer
    sudo apt-get install audacity -y
    sudo apt-get install quodlibet -y
    sudo apt-get install sonic-visualiser -y

    # Snap from flacon-tabetai does not start
    sudo add-apt-repository ppa:flacon -y
    sudo apt install flacon -y

    sudo snap install spek
fi

if [ "$install_graphic" = "y" ] || [ "$install_graphic" = "Y" ]; then
    sudo snap install pinta
    sudo snap install gimp
    sudo snap install inkscape
fi

if [ "$install_telegram" = "y" ] || [ "$install_telegram" = "Y" ]; then
    sudo snap install telegram-desktop
fi

if [ "$install_code" = "y" ] || [ "$install_code" = "Y" ]; then
    if [ "$(uname -a | grep x86_64)" ]; then
        sudo snap install --classic code
    fi
fi

if [ "$install_sync" = "y" ] || [ "$install_sync" = "Y" ]; then
    sudo apt install curl apt-transport-https
    sudo mkdir -p /etc/apt/keyrings
    sudo curl -L -o /etc/apt/keyrings/syncthing-archive-keyring.gpg https://syncthing.net/release-key.gpg
    echo "deb https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list
    sudo apt update
    sudo apt install syncthing
fi

if [ "$install_chromium" = "y" ] || [ "$install_chromium" = "Y" ]; then
    # Use chromium instead of chrome b/c chromium is available on arm, and chrome is not
    sudo apt-get install chromium-browser
fi

if [ "$install_zim" = "y" ] || [ "$install_chromium" = "Y" ]; then
    sudo apt-get install zim -y
fi

if [ "$install_rpimager" = "y" ] || [ "$install_chromium" = "Y" ]; then
     sudo apt install rpi-imager -y
fi

#
# Finishing up
#
if [ "$install_language" = "y" ] || [ "$install_language" = "Y" ]; then
    sudo apt-get install $(check-language-support -l nl) -y
    sudo apt-get install $(check-language-support -l uk) -y
fi

if [ "$install_upgrade" = "y" ] || [ "$install_upgrade" = "Y" ]; then
    sudo apt-get upgrade -y
    sudo snap refresh
fi

sudo apt-get autoremove -y
sudo apt-get autoclean -y
