#!/bin/bash

array=( https://extensions.gnome.org/extension/545/hide-top-bar/
https://extensions.gnome.org/extension/5470/weather-oclock/ )

for i in "${array[@]}"
do
    EXTENSION_ID=$(curl -s $i | grep -oP 'data-uuid="\K[^"]+')
    echo $EXTENSION_ID
    VERSION_TAG=$(curl -Lfs "https://extensions.gnome.org/extension-query/?search=$EXTENSION_ID" | jq '.extensions[0] | .shell_version_map | map(.pk) | max')
    echo $VERSION_TAG

    DOWNLOAD_URL="https://extensions.gnome.org/extension-data/${EXTENSION_ID}.shell-extension.zip?version_tag=$VERSION_TAG"
    echo $DOWNLOAD_URL

    # DOWNLOAD_URL: does not work
    #   wget https://extensions.gnome.org/extension-data/hidetopbar@mathieu.bidon.ca.shell-extension.zip?version_tag=39984
    # download from the website: works (117 is the version chosen on the website):
    #   wget https://extensions.gnome.org/extension-data/hidetopbarmathieu.bidon.ca.v117.shell-extension.zip

    # - version-number differs
    # - version is formatted differently
    # - extention-id differs 
    #    hidetopbar@mathieu.bidon.ca 
    #    hidetopbarmathieu.bidon.ca (no 2-symbol)

    wget -O ${EXTENSION_ID}.zip "$DOWNLOAD_URL"
    gnome-extensions install --force ${EXTENSION_ID}.zip
    if ! gnome-extensions list | grep --quiet ${EXTENSION_ID}; then
        busctl --user call org.gnome.Shell.Extensions /org/gnome/Shell/Extensions org.gnome.Shell.Extensions InstallRemoteExtension s ${EXTENSION_ID}
    fi
    gnome-extensions enable ${EXTENSION_ID}
    rm ${EXTENSION_ID}.zip
done


