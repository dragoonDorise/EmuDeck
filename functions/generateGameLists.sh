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

    #Uncomment to get custom grid
    #local tempGrid=$(generateGameLists_extraArtwork $file $platform)
    #local grid=$(echo "$tempGrid" | jq -r '.grid')

    local vertical="$accountfolder/config/grid/emudeck/$platform/$file.jpg"
    local grid=$vertical
    local destination_vertical="$accountfolder/config/grid/${appID}p.png" #vertical
    local destination_hero="$accountfolder/config/grid/${appID}_hero.png" #BG
    local destination_grid="$accountfolder/config/grid/${appID}.png" #GRID
    rm -rf "$destination_vertical"
    rm -rf "$destination_hero"
    rm -rf "$destination_grid"

    #Use CP if custom grid instead of ln..
    ln -s "$vertical" "$destination_vertical"
    ln -s "$grid" "$destination_hero"
    ln -s "$grid" "$destination_grid"
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

    echo "$parsed_games / $games ($percentage%)"
}

generateGameLists_extraArtwork() {
    local game=$1
    local platform=$2
    local hash=$3
    local accountfolder=$(ls -td $HOME/.steam/steam/userdata/* | head -n 1)
    local dest_folder="$accountfolder/config/grid/emudeck"

    wget -q -O "$HOME/emudeck/cache/response.json" "https://bot.emudeck.com/steamdb_extra.php?name=$game&hash=$hash"

    game_name=$(jq -r '.name' "$HOME/emudeck/cache/response.json")
    game_img_url=$(jq -r '.grid' "$HOME/emudeck/cache/response.json")
    dest_path="$dest_folder/$platform/$game.grid.temp"

    if [ "$game_img_url" != "null" ]; then
      wget -q -O "${dest_path}" "${game_img_url}"
    fi
    json=$(jq -n --arg grid "$dest_path" '{grid: $grid}')

    echo "$json"
}