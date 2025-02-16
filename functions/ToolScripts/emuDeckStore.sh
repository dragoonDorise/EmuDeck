#!/bin/bash

Store_installGame(){
    system=$1
    gameName=$2
    url=$3

    filename=$(basename "$url")
    name="${filename%.*}"

    wget -O "${romsPath}/${system}/${name}.zip" "${url}" && \
    wget -O "${storagePath}/retrolibrary/artwork/${system}/media/screenshot/${name}.jpg" "https://raw.githubusercontent.com/EmuDeck/emudeck-homebrew/main/downloaded_media/${system}/screenshots/homebrew/${name}.png" && \
    echo "true" || echo "false"
}

Store_uninstallGame(){
    system=$1
    gameName=$2
    url=$3

    filename=$(basename "$url")
    name="${filename%.*}"

    rm -rf "${romsPath}/${system}/${name}.zip" && \
    rm -rf  "${storagePath}/retrolibrary/artwork/${system}/media/screenshot/${name}.png" && echo "true" || echo "false"

}

Store_isGameInstalled(){
    system=$1
    gameName=$2
    url=$3

    filename=$(basename "$url")
    name="${filename%.*}"

    if [ -f "${romsPath}/${system}/${name}.zip" ]; then
        echo "true"
    else
        echo "false"
    fi

}