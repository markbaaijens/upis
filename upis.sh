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
  echo "No supported desktop found."
  exit 1      
fi

#
# User dialog
#
echo "Options:"

read -r -p "- Replace menu? [y/N] " install_menu
install_menu=$(echo $install_menu | tr '[:upper:]' '[:lower:]')

read -r -p "- Install: Telegram? [y/N] " install_telegram
install_telegram=$(echo $install_telegram | tr '[:upper:]' '[:lower:]')

read -r -p "- Install: Visual Studio Code? [y/N] " install_code
install_code=$(echo $install_code | tr '[:upper:]' '[:lower:]')

read -r -p "- Install: Audio-suite (PuddleTag, SoundJuicer, Audacity, QuodLibet, SoundVisualiser, Flacon and Spek)? [y/N] " install_audio
install_audio=$(echo $install_audio | tr '[:upper:]' '[:lower:]')

read -r -p "- Install: Graphic-suite (GIMP, Pinta, Inkscape)? [y/N] " install_graphic
install_graphic=$(echo $install_graphic | tr '[:upper:]' '[:lower:]')

read -r -p "- Install: SyncThing? [y/N] " install_sync
install_sync=$(echo $install_sync | tr '[:upper:]' '[:lower:]')

read -r -p "- Install: Zim desktop-wiki? [y/N] " install_zim
install_zim=$(echo $install_zim | tr '[:upper:]' '[:lower:]')

read -r -p "- Install: Raspberry Pi-imager? [y/N] " install_rpimager
install_rpimager=$(echo $install_rpimager | tr '[:upper:]' '[:lower:]')

read -r -p "- Install: Chromium-browser? [y/N] " install_chromium
install_chromium=$(echo $install_chromium | tr '[:upper:]' '[:lower:]')

echo "---"
echo "Selected:"
if [ "$install_menu" = "y" ]; then echo "- Replace menu"; fi
if [ "$install_code" = "y" ]; then echo "- Install: Visual Studio Code"; fi
if [ "$install_audio" = "y" ]; then echo "- Install: Audio-suite"; fi
if [ "$install_graphic" = "y" ]; then echo "- Install: Graphics-suite"; fi
if [ "$install_sync" = "y" ]; then echo "- Install: SyncThing"; fi
if [ "$install_zim" = "y" ]; then echo "- Install: Zim Desktop Wiki"; fi
if [ "$install_rpimager" = "y" ]; then echo "- Install: Raspberry Pi Imager"; fi
if [ "$install_chromium" = "y" ]; then echo "- Install: Chromium Browser"; fi

read -r -p "Proceed (you will be asked for your password when procedding)? [y/N] " proceed
proceed=$(echo $proceed | tr '[:upper:]' '[:lower:]')
if [ "$proceed" != "y" ]; then
    exit
fi

echo "Processing..."

#
# System settings
#

# De-activate error-system
sudo sed -i 's/enabled=1/enabled=0/g' /etc/default/apport

# Commented out b/c zram-config is not working correctly on arm64
# Use zram = compressed memory (advantage when in low memory)
#sudo apt install zram-config -y
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
    warning_folder=1
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

# Workspaces
#gsettings set org.gnome.mutter dynamic-workspaces false
#gsettings set org.gnome.desktop.wm.preferences num-workspaces 1

# Nightmode
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 3282

# Mouse and Touchpad 
#gsettings set org.gnome.desktop.peripherals.touchpad speed 0.3 # Accelerate a bit

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
sudo apt update -y  

# Several basic packages
sudo apt install dconf-editor htop tree bwm-ng nmap -y

# Note. Package gnome-shell-extensions does slightly the same (showing gnome-extensions), 
# though you cannot new extensions through browsing
sudo apt install gnome-shell-extension-manager -y

# Replace Video's (Totem) by Celluloid
sudo apt purge totem totem-plugins -y
sudo apt install celluloid -y

# Remove rhythmbox; music is better played with celluloid
sudo apt remove rhythmbox -y

if [ "$install_audio" = "y" ]; then
    sudo apt install puddletag -y
    sudo apt install sound-juicer -y
    sudo apt install audacity -y
    sudo apt install quodlibet -y
    sudo apt install sonic-visualiser -y

    # Snap from flacon-tabetai does not start
    sudo add-apt-repository ppa:flacon -y
    sudo apt install flacon -y

    sudo snap install spek
fi

if [ "$install_graphic" = "y" ]; then
    sudo snap install pinta
    sudo snap install gimp
    sudo snap install inkscape
fi

if [ "$install_telegram" = "y" ]; then
    sudo snap install telegram-desktop
fi

if [ "$install_code" = "y" ]; then
    if [ "$(uname -a | grep x86_64)" ]; then
        sudo snap install --classic code
    fi
fi

if [ "$install_sync" = "y" ]; then
    sudo apt install curl apt-transport-https
    sudo mkdir -p /etc/apt/keyrings
    sudo curl -L -o /etc/apt/keyrings/syncthing-archive-keyring.gpg https://syncthing.net/release-key.gpg
    echo "deb https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list
    sudo apt update
    sudo apt install syncthing
fi

if [ "$install_chromium" = "y" ]; then
    # Use chromium instead of chrome b/c chromium is available on arm, and chrome is not
    sudo snap install chromium-browser
fi

if [ "$install_zim" = "y" ]; then
    sudo apt install zim -y
fi

if [ "$install_rpimager" = "y" ]; then
     sudo apt install rpi-imager -y
fi

if [ "$install_menu" = "y" ]; then
    gsettings set org.gnome.shell favorite-apps "['firefox_firefox.desktop', 'org.gnome.Nautilus.desktop']"
fi

#
# Finishing up
#

sudo apt install $(check-language-support -l nl) -y
sudo apt install $(check-language-support -l uk) -y
sudo apt dist-upgrade -y
sudo snap refresh

sudo apt autoremove -y
sudo apt autoclean -y

#
# Report
#
echo "---"
echo "Standard:"
echo "- Modified settngs for: Interface, Date, Dock, Nightmode, Nautilus"
echo "- Upgraded all packages"
echo "- Installed: dconf-editor htop tree bwm-ng nmap"
echo "- Installed: gnome-shell-extension-manager"
echo "- Replaced Video's (Totem) by Celluloid"
echo "- Removed Rhythmbox (music is better played with Celluloid)"

echo "Optional:"
if [ "$install_menu" = "y" ]; then echo "- Menu replaced"; fi
if [ "$install_code" = "y" ]; then echo "- Installed: Visual Studio Code"; fi
if [ "$install_audio" = "y" ]; then echo "- Installed: Audio-suite"; fi
if [ "$install_graphic" = "y" ]; then echo "- Installed: Graphics-suite"; fi
if [ "$install_sync" = "y" ]; then echo "- Installed: SyncThing"; fi
if [ "$install_zim" = "y" ]; then echo "- Installed: Zim Desktop Wiki"; fi
if [ "$install_rpimager" = "y" ]; then echo "- Installed: Raspberry Pi Imager"; fi
if [ "$install_chromium" = "y" ]; then echo "- Installed: Chromium Browser"; fi

if [ $warning_folder ]; then echo "Warning: Folder ~/Sjablonen is not present, installation language is not Dutch?"; fi

