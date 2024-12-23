#!/bin/bash

MSG="$HOME/.config/EmuDeck/msg.log"

generateGameLists_pythonEnv() {
    if [ ! -d "$HOME/.config/EmuDeck/python_virtual_env" ]; then
        python3 -m venv "$HOME/.config/EmuDeck/python_virtual_env"
        source "$HOME/.config/EmuDeck/python_virtual_env/bin/activate"
        pip install requests
    else
        source "$HOME/.config/EmuDeck/python_virtual_env/bin/activate"
    fi
}

generateGameLists() {

    generateGameLists_pythonEnv

    local accountfolder=$(ls -td $HOME/.steam/steam/userdata/* | head -n 1)
    local dest_folder="$accountfolder/config/grid/retrolibrary/artwork/"
    echo "Starting to build database" > "$MSG"
    mkdir -p "$storagePath/retrolibrary/artwork"
    mkdir -p "$storagePath/retrolibrary/cache"
    mkdir -p "$storagePath/retrolibrary/data"
    mkdir -p "$storagePath/retrolibrary/achievements"
    mkdir -p "$accountfolder/config/grid/retrolibrary/"

    ln -sf "$storagePath/retrolibrary/artwork" "$accountfolder/config/grid/retrolibrary/artwork"
    ln -sf "$storagePath/retrolibrary/cache" "$accountfolder/config/grid/retrolibrary/cache"
    ln -sf "$storagePath/retrolibrary/data" "$accountfolder/config/grid/retrolibrary/data"
    ln -sf "$storagePath/retrolibrary/achievements" "$accountfolder/config/grid/retrolibrary/achievements"

    generateGameLists_downloadAchievements
    generateGameLists_downloadData

    pegasus_setPaths
    rsync -r --exclude='roms' --exclude='txt' "$EMUDECKGIT/roms/" "$storagePath/retrolibrary/artwork" --keep-dirlinks
    mkdir -p "$storagePath/retrolibrary/cache/"
    echo "Database built" > "$MSG"
    python $HOME/.config/EmuDeck/backend/tools/retro-library/generate_game_lists.py "$romsPath"
}

generateGameListsJson() {
    generateGameLists_pythonEnv
    echo "Adding Games" > "$MSG"
    #python $HOME/.config/EmuDeck/backend/tools/retro-library/generate_game_lists.py "$romsPath"
    echo "Games Added" > "$MSG"
    cat $storagePath/retrolibrary/cache/roms_games.json
    #generateGameLists_artwork $userid &> /dev/null &
    generateGameLists_artwork &> /dev/null &

}

generateGameLists_importESDE() {
    python $HOME/.config/EmuDeck/backend/tools/retro-library/import_media.py "$romsPath" "$dest_folder"
}

generateGameLists_artwork() {
    echo "Searching for missing artwork" > "$MSG"
    python $HOME/.config/EmuDeck/backend/tools/retro-library/missing_artwork_platforms.py "$romsPath" "$storagePath/retrolibrary/artwork" && python $HOME/.config/EmuDeck/backend/tools/retro-library/download_art_platforms.py "$storagePath/retrolibrary/artwork"

    #$(python $HOME/.config/EmuDeck/backend/tools/retro-library/missing_artwork.py "$romsPath" "$dest_folder" && python $HOME/.config/EmuDeck/backend/tools/retro-library/download_art.py "$dest_folder") &
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

    #Uncomment to get custom grid
    #local tempGrid=$(generateGameLists_extraArtwork $file $platform)
    #local grid=$(echo "$tempGrid" | jq -r '.grid')

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

    local accountfolder=$(ls -td $HOME/.steam/steam/userdata/* | head -n 1)
    local dest_folder="$storagePath/retrolibrary/artwork/"

    #python $HOME/.config/EmuDeck/backend/tools/retro-library/missing_artwork.py "$romsPath" "$dest_folder"

    local json_file="$storagePath/retrolibrary/cache/roms_games.json"
    local json_file_artwork="$storagePath/retrolibrary/cache/missing_artwork.json"

    # Contar el número total de juegos en `roms_games.json`
    local games=$(jq '[.[].games[]] | length' "$json_file")
    local artwork_missing=$(jq '[.[] | select(.type == "box2dart")] | length' "$json_file_artwork")

    if [[ -z "$games" || "$games" -eq 0 ]]; then
        return
    fi

    local parsed_games=$(( games - artwork_missing ))

    local percentage=$(( 100 * parsed_games / games ))

    echo "$parsed_games / $games ($percentage%)"
}

generateGameLists_extraArtwork() {
    local game=$1
    local platform=$2
    local hash=$3
    local accountfolder=$(ls -td $HOME/.steam/steam/userdata/* | head -n 1)
    local dest_folder="$storagePath/retrolibrary/artwork"

    wget -q -O "$storagePath/retrolibrary/cache/response.json" "https://bot.emudeck.com/steamdb_extra.php?name=$game&hash=$hash"

    game_name=$(jq -r '.name' "$storagePath/retrolibrary/cache/response.json")
    game_img_url=$(jq -r '.grid' "$storagePath/retrolibrary/cache/response.json")
    dest_path="$dest_folder/$platform/$game.grid.temp"

    if [ "$game_img_url" != "null" ]; then
      wget -q -O "${dest_path}" "${game_img_url}"
    fi
    json=$(jq -n --arg grid "$dest_path" '{grid: $grid}')

    echo "$json"
}

generateGameLists_retroAchievements(){
    local hash=$1
    local system=$2
    local localDataPath="$storagePath/retrolibrary/achievements/$system.json"
    python $HOME/.config/EmuDeck/backend/tools/retro-library/retro_achievements.py "$cheevos_username" "$hash" "$localDataPath"
}

generateGameLists_downloadAchievements(){
    local folder="$storagePath/retrolibrary/achievements"
    if [ ! -d $folder ]; then
        echo "Downloading Retroachievements Data" > "$MSG"
        mkdir -p $folder
        wget -q -O "$folder/achievements.zip" "https://bot.emudeck.com/achievements/achievements.zip"
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
        wget -q -O "$folder/data.zip" "https://bot.emudeck.com/data/data.zip"
        cd $folder && unzip -o data.zip && rm data.zip
        echo "Metada Downloaded" > "$MSG"
    fi
}