# Ubuntu post-install Script (UPIS)
Script for post-install operations after a clean Ubuntu-installation. This script is repeatable e.g. it can be executed multiple times.

## Preconditions:
- clean installation of Ubuntu 24.04; other desktops/versions may work but this is not tested
- installed language is Dutch
- script should be run by a 'normal' user (password will be asked during execution)
- script should NOT be run as root 

## Usage
wget https://raw.githubusercontent.com/markbaaijens/upis/master/ubuntu-postinstall
chmod +x ubuntu-postinstall
./ubuntu-postinstall
