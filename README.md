# Ubuntu Post Install Script (UPIS)
Script for post-install operations after a clean Ubuntu-installation. This script is idem-potent, e.g. it is repeatable in the way it can be executed multiple times without doing harm.

## Preconditions
- clean installation of Ubuntu 24.04; other desktops/versions may work but are not tested
- architecture might be either x86 or arm; note that some packages are not (yet) available on arm
- installed language is Dutch
- script should be run by a 'normal' user, no root (password will be asked during execution)

## Usage
Download script ...and make it executable:

`wget https://raw.githubusercontent.com/markbaaijens/upis/master/upis.sh -O upis.sh && chmod +x upis.sh`  

Execute the script:

`./upis.sh` 
