#!/bin/bash

Store_installGame(){
    system=$1
    gameName=$2
    url=$3

    gameUrl="${url//[ ]/%20}"

    curl "${gameUrl}" -o "${romsPath}/${system}/${gameName}.zip" && \
    curl "https://raw.githubusercontent.com/EmuDeck/emudeck-homebrew/main/downloaded_media/${system}/screenshots/homebrew/${gameNameUrl}.png" -o "${storagePath}/retrolibrary/artwork/${system}/media/screenshot/${gameName}.png" && echo "true" || echo "false"


}

Store_uninstallGame(){
    system=$1
    gameName=$2

    rm -rf "${romsPath}/${system}/${gameName}.zip" && \
    rm -rf  "${storagePath}/retrolibrary/artwork/${system}/media/screenshot/${gameName}.png" && echo "true" || echo "false"

}

Store_isGameInstalled(){
    system=$1
    gameName=$2

    if [ -f "${romsPath}/${system}/${gameName}.zip" ]; then
        echo "true"
    else
        echo "false"
    fi

}