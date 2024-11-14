#!/bin/bash
generateGameLists() {
    local accountfolder=$(ls -td $HOME/.steam/steam/userdata/* | head -n 1)
    local dest_folder="$accountfolder/config/grid/emudeck/"
    mkdir -p $dest_folder
    pegasus_setPaths
    rsync -r --exclude='roms' --exclude='txt' "$EMUDECKGIT/roms/" "$dest_folder" --keep-dirlinks
    mkdir -p "$HOME/emudeck/cache/"
    python $HOME/.config/EmuDeck/backend/tools/retro-library/generate_game_lists.py "$romsPath"
}

generateGameListsJson() {
    python $HOME/.config/EmuDeck/backend/tools/retro-library/generate_game_lists.py "$romsPath"
    #cat $HOME/emudeck/cache/roms_games.json
    #generateGameLists_artwork $userid &> /dev/null &
    generateGameLists_artwork &> /dev/null &

}

generateGameLists_importESDE() {


    python $HOME/.config/EmuDeck/backend/tools/retro-library/import_media.py "$romsPath" "$dest_folder"
}

generateGameLists_artwork() {
    mkdir -p "$HOME/emudeck/cache/"
    local accountfolder=$(ls -td $HOME/.steam/steam/userdata/* | head -n 1)
    local dest_folder="$accountfolder/config/grid/emudeck/"
    python $HOME/.config/EmuDeck/backend/tools/retro-library/missing_artwork.py "$romsPath" "$dest_folder"
    python $HOME/.config/EmuDeck/backend/tools/retro-library/download_art.py "$dest_folder"

}

saveImage(){
    local url=$1
    local name=$2
    local system=$3
    local accountfolder=$(ls -td $HOME/.steam/steam/userdata/* | head -n 1)
    local dest_folder="$accountfolder/config/grid/emudeck/${system}"
    local dest_path="$dest_folder/$name.jpg"
    wget -q -O "$dest_path" "$url"
}

function addGameListsArtwork() {
    local file="$1"
    local appID="$2"
    local platform="$3"
    local accountfolder=$(ls -td $HOME/.steam/steam/userdata/* | head -n 1)

    local tempGrid =$(generateGameLists_extraArtwork $file $platform)

    local origin="$tempGrid"
    local destination="$accountfolder/config/grid/${appID}p.png"
    local destination_hero="$accountfolder/config/grid/${appID}_hero.png"
    local destination_home="$accountfolder/config/grid/${appID}.png"
    rm -rf "$destination"
    rm -rf "$destination_hero"
    rm -rf "$destination_home"
    cp "$origin" "$destination"
    cp "$origin" "$destination_hero"
    cp "$origin" "$destination_home"
}

generateGameLists_getPercentage() {

    local accountfolder=$(ls -td $HOME/.steam/steam/userdata/* | head -n 1)
    local dest_folder="$accountfolder/config/grid/emudeck/"

    python $HOME/.config/EmuDeck/backend/tools/retro-library/missing_artwork.py "$romsPath" "$dest_folder"


    local json_file="$HOME/emudeck/cache/roms_games.json"
    local json_file_artwork="$HOME/emudeck/cache/missing_artwork.json"

    # Contar el número total de juegos en `roms_games.json`
    local games=$(jq '[.[].games[]] | length' "$json_file")

    local artwork_missing=$(jq '. | length' "$json_file_artwork")

    if [[ -z "$games" || "$games" -eq 0 ]]; then
        return
    fi

    local parsed_games=$(( games - artwork_missing ))

    local percentage=$(( 100 * parsed_games / games ))

    # Mostrar el resultado
    echo "$parsed_games / $games ($percentage%)"
}

generateGameLists_extraArtwork() {
    local game=$1
    local platform=$2
    local accountfolder=$(ls -td $HOME/.steam/steam/userdata/* | head -n 1)
    local dest_folder="$accountfolder/config/grid/emudeck"

    wget -q -O "$HOME/emudeck/cache/response.json" "https://bot.emudeck.com/steamdb_extra.php?name=$game"

    game_name=$(jq -r '.name' "$HOME/emudeck/cache/response.json")
    game_img_url=$(jq -r '.img' "$HOME/emudeck/cache/response.json")
    filename=$(basename "$game_img_url")
    dest_path="$dest_folder/$platform/$game.temp.jpg"

    if [ "$game_img_url" != "null" ]; then
      wget -q -O "${dest_path}" "${game_img_url}"
    fi
    echo $dest_path
}