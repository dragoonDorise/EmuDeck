#!/bin/bash

MSG="$emudeckLogs/msg.log"

generateGameLists() {


    mv "$storagePath/retrolibrary/assets/alekfull/carousel-icons"  "$storagePath/retrolibrary/assets/default/carousel-icons"

    generate_pythonEnv &> /dev/null

    local accountfolder=$(ls -td $HOME/.steam/steam/userdata/* | head -n 1)
    local dest_folder="$accountfolder/config/grid/retrolibrary/artwork/"
    echo "Starting to build database" > "$MSG"
    mkdir -p "$storagePath/retrolibrary/artwork"
    mkdir -p "$storagePath/retrolibrary/cache"
    mkdir -p "$accountfolder/config/grid/retrolibrary/"

    find "$storagePath/retrolibrary/artwork" -type f -size 0 -delete

    ln -sf "$storagePath/retrolibrary/artwork" "$accountfolder/config/grid/retrolibrary/artwork"
    ln -sf "$storagePath/retrolibrary/cache" "$accountfolder/config/grid/retrolibrary/cache"

    generateGameLists_downloadAchievements
    generateGameLists_downloadData
    generateGameLists_downloadAssets

    rsync -r --exclude='roms' --exclude='txt' "$emudeckBackend/roms/" "$storagePath/retrolibrary/artwork" --keep-dirlinks
    pegasus_setPaths && echo "Database built" > "$MSG" && python $emudeckBackend/tools/retro-library/generate_game_lists.py "$romsPath"
    generateGameLists_artwork &> /dev/null &
}

generateGameListsJson() {
    generate_pythonEnv &> /dev/null
    echo "Adding Games" > "$MSG"
    echo "Games Added" > "$MSG"
    cat $storagePath/retrolibrary/cache/roms_games.json
}

generateGameLists_artwork() {
    generate_pythonEnv &> /dev/null
    echo "Searching for missing artwork" > "$MSG"
    python $emudeckBackend/tools/retro-library/missing_artwork_platforms.py "$romsPath" "$storagePath/retrolibrary/artwork" && python $emudeckBackend/tools/retro-library/download_art_platforms.py "$storagePath/retrolibrary/artwork"

    $(python $emudeckBackend/tools/retro-library/missing_artwork_nohash.py "$romsPath" "$storagePath/retrolibrary/artwork" && python $emudeckBackend/tools/retro-library/download_art_nohash.py "$storagePath/retrolibrary/artwork") &
    echo "Artwork finished. Restart if you see this message" > "$MSG"
}

saveImage(){
    local url=$1
    local name=$2
    local system=$3
    local accountfolder=$(ls -td $HOME/.steam/steam/userdata/* | head -n 1)
    local dest_folder="$storagePath/retrolibrary/artwork/${system}/media/box2dfront/"
    local dest_path="$dest_folder/$name.jpg"
    wget -q -O "$dest_path" "$url"
}

function addGameListsArtwork() {
    local file="$1"
    local appID="$2"
    local platform="$3"
    local accountfolder=$(ls -td $HOME/.steam/steam/userdata/* | head -n 1)

    local vertical="$storagePath/retrolibrary/artwork/$platform/media/box2dfront/$file.jpg"
    local grid=$vertical
    local destination_vertical="$accountfolder/config/grid/${appID}p.png" #vertical
    local destination_hero="$accountfolder/config/grid/${appID}_hero.png" #BG
    local destination_grid="$accountfolder/config/grid/${appID}.png" #GRID
    rm -rf "$destination_vertical"
    rm -rf "$destination_hero"
    rm -rf "$destination_grid"

    #Use CP if custom grid instead of ln..
    ln -sf "$vertical" "$destination_vertical"
    ln -sf "$grid" "$destination_hero"
    ln -sf "$grid" "$destination_grid"
}

generateGameLists_getPercentage() {
    generate_pythonEnv &> /dev/null
    local accountfolder=$(ls -td $HOME/.steam/steam/userdata/* | head -n 1)
    local dest_folder="$storagePath/retrolibrary/artwork/"

    python $emudeckBackend/tools/retro-library/missing_artwork_nohash.py "$romsPath" "$dest_folder"

    local json_file="$storagePath/retrolibrary/cache/roms_games.json"
    local json_file_artwork="$storagePath/retrolibrary/cache/missing_artwork_no_hash.json"

    # Contar el número total de juegos en `roms_games.json`
    local games=$(jq '[.[].games[]] | length' "$json_file")
    local artwork_missing=$(jq '[.[] | .games | length] | length' "$json_file_artwork")
    if [[ -z "$games" || "$games" -eq 0 ]]; then
        return
    fi

    local parsed_games=$(( games - artwork_missing ))

    local percentage=$(( 100 * parsed_games / games ))

    echo "$parsed_games / $games ($percentage%)"
}


generateGameLists_retroAchievements(){
    generate_pythonEnv &> /dev/null
    local filename=$1
    local system=$2
    local localDataPath="$storagePath/retrolibrary/achievements/$system.json"
    local hash=$(md5sum $emulationPath/roms/$system/$filename | awk '{ print $1 }')
    python $emudeckBackend/tools/retro-library/retro_achievements.py "$cheevos_username" "$hash" "$localDataPath"
}

generateGameLists_downloadAchievements(){
    local folder="$storagePath/retrolibrary/achievements"
    if [ ! -d $folder ]; then
        echo "Downloading Retroachievements Data" > "$MSG"
        mkdir -p $folder
        ln -sf "$storagePath/retrolibrary/achievements" "$accountfolder/config/grid/retrolibrary/achievements"
        wget -q -O "$folder/achievements.zip" "https://artwork.emudeck.com/achievements/achievements.zip"
        cd "$folder" && unzip -o achievements.zip && rm achievements.zip
        echo "Retroachievements Data Downloaded" > "$MSG"
    fi
}

generateGameLists_downloadData(){
    local folder="$storagePath/retrolibrary/data"
    local accountfolder=$(ls -td $HOME/.steam/steam/userdata/* | head -n 1)
    ln -s "$folder" "$accountfolder/config/grid/retrolibrary/data"
    if [ ! -d $folder ]; then
        echo "Downloading Metada" > "$MSG"
        mkdir -p $folder
        ln -sf "$storagePath/retrolibrary/data" "$accountfolder/config/grid/retrolibrary/data"
        wget -q -O "$folder/data.zip" "https://artwork.emudeck.com/data/data.zip"
        cd $folder && unzip -o data.zip && rm data.zip
        echo "Metada Downloaded" > "$MSG"
    fi
}

generateGameLists_downloadAssets(){
    local accountfolder=$(ls -td $HOME/.steam/steam/userdata/* | head -n 1)
    local folder="$storagePath/retrolibrary/assets"
    local destFolder="$accountfolder/config/grid/retrolibrary/assets";

    local folderDefault="$storagePath/retrolibrary/assets/default"
    local folderBezels="$storagePath/retrolibrary/assets/bezels"
    local folderWii="$storagePath/retrolibrary/assets/wii"


    mkdir -p $folder
    ln -sf "$folder" "$destFolder"

    if [ ! -d $folderDefault ]; then
        echo "Downloading Assets" > "$MSG"
        wget -q -O "$folder/default.zip" "https://artwork.emudeck.com/assets/default.zip"
        cd $folder && unzip -o default.zip && rm default.zip
        echo "Assets Downloaded" > "$MSG"
    fi

    if [ ! -d $folderBezels ]; then
        echo "Downloading Bezels" > "$MSG"
        wget -q -O "$folder/bezels.zip" "https://artwork.emudeck.com/assets/bezels.zip"
        cd $folder && unzip -o bezels.zip && rm bezels.zip
        echo "Bezels Downloaded" > "$MSG"
    fi

    if [ ! -d $folderWii ]; then
        echo "Downloading Wii assets" > "$MSG"
        wget -q -O "$folder/wii.zip" "https://artwork.emudeck.com/assets/wii.zip"
        cd $folder && unzip -o wii.zip && rm wii.zip
        echo "Wii assets Downloaded" > "$MSG"
    fi

    wget -q -O "$folder/default/backgrounds/store.jpg" "https://artwork.emudeck.com/assets/default/backgrounds/store.jpg"
    wget -q -O "$folder/default/carousel-icons/store.jpg" "https://artwork.emudeck.com/assets/default/carousel-icons/store.jpg"
    wget -q -O "$folder/default/logo/store.png" "https://artwork.emudeck.com/assets/default/logo/store.png"

}