#!/bin/bash

Store_installGame(){
    system=$1
    name=$2
    url=$3

    name_cleaned=$(echo "$name" | sed -E 's/\(.*?\)//g' | sed -E 's/\[.*?\]//g')
    name_cleaned=$(echo "$name_cleaned" | tr ' ' '_' | tr '-' '_')
    name_cleaned=$(echo "$name_cleaned" | sed -E 's/_+/_/g')
    name_cleaned=$(echo "$name_cleaned" | tr -d '+&!'\''.' | sed 's/_decrypted//g' | sed 's/decrypted//g' | sed 's/.ps3//g')
    name_cleaned=$(echo "$name_cleaned" | tr '[:upper:]' '[:lower:]')

    wget -O "${romsPath}/${system}/${name}.zip" "${url}" && \
    wget -O "${storagePath}/retrolibrary/artwork/${system}/media/screenshot/${name_cleaned}.jpg" "https://f005.backblazeb2.com/file/emudeck-store/artwork/${system}/media/screenshot/${name}.png" && \
    wget -O "${storagePath}/retrolibrary/artwork/${system}/media/box2dfront/${name_cleaned}.jpg" "https://f005.backblazeb2.com/file/emudeck-store/artwork/${system}/media/box2dfront/${name}.png" && \
    echo "true" || echo "false"
}

Store_uninstallGame(){
    system=$1
    name=$2
    url=$3

    name_cleaned=$(echo "$name" | sed -E 's/\(.*?\)//g' | sed -E 's/\[.*?\]//g')
    name_cleaned=$(echo "$name_cleaned" | tr ' ' '_' | tr '-' '_')
    name_cleaned=$(echo "$name_cleaned" | sed -E 's/_+/_/g')
    name_cleaned=$(echo "$name_cleaned" | tr -d '+&!'\''.' | sed 's/_decrypted//g' | sed 's/decrypted//g' | sed 's/.ps3//g')
    name_cleaned=$(echo "$name_cleaned" | tr '[:upper:]' '[:lower:]')


    rm -rf "${romsPath}/${system}/${name}.zip" && \
    rm -rf  "${storagePath}/retrolibrary/artwork/${system}/media/screenshot/${name_cleaned}.jpg" && \
    "${storagePath}/retrolibrary/artwork/${system}/media/box2dfront/${name_cleaned}.jpg" && echo "true" || echo "false"

}

Store_isGameInstalled(){
    system=$1
    name=$2
    url=$3

    if [ -f "${romsPath}/${system}/${name}.zip" ]; then
        echo "true"
    else
        echo "false"
    fi

}