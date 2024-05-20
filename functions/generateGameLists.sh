#!/bin/bash
generateGameLists() {

    pegasus_setPaths
    echo $HOME/emudeck/.scraping
    python $HOME/.config/EmuDeck/backend/tools/generate_game_lists.py && rm -rf $HOME/emudeck/.scraping "$romsPath" & generateGameLists_artwork

}

generateGameListsJson() {
    cat $HOME/emudeck/roms_games.json & generateGameLists_artwork "-r"
}

generateGameLists_artwork() {
    local direction=$1
    local json=$(cat $HOME/emudeck/roms_games.json)
    local accountfolder=$(ls -d $HOME/.steam/steam/userdata/* | head -n 1)
    local dest_folder="$accountfolder/config/grid/"
    mapfile -t games_array < <(echo "$json" | jq -r '.[] | .games[]? | .name' | sed -e 's/ (.*)//g' -e 's/ /_/g')

    mapfile -t sorted_games_array < <(printf "%s\n" "${games_array[@]}" | sort $direction)

    mkdir -p "$dest_folder"

    # Imprime los nombres limpios almacenados en el array
    for game in "${sorted_games_array[@]}"; do

        declare -a download_array
        declare -a download_dest_paths
        declare -a valid_system_dirs


        file_to_check="$dest_folder$game*"

        if ! ls $file_to_check 1> /dev/null 2>&1; then
          echo $game

          response=$(curl -s -G "https://bot.emudeck.com/steamdbimg.php?name=$game")
          game_name=$(echo "$response" | jq -r '.name')
          game_img_url=$(echo "$response" | jq -r '.img')
          game_img=$(echo "$game_img_url" | sed 's|.*/||')
          filename=$(basename "$game_img_url")
          dest_path="$dest_folder$game.jpg"
          if [ ! -f "$dest_path" ]; then
              #echo "Adding $game_img_url to download array"
              download_array+=("$game_img_url")
              download_dest_paths+=("$dest_path")
          fi

        fi

        # Ensure the download array is not empty
        #echo "Download array length: ${#download_array[@]}"
        if [ ${#download_array[@]} -eq 0 ]; then
            #echo "No images to download."
            return
        fi

        # Download images in parallel
        #echo "Starting downloads..."
        for i in "${!download_array[@]}"; do
            {
                #echo "Downloading ${download_array[$i]} to ${download_dest_paths[$i]}"
                curl -o "${download_dest_paths[$i]}" "${download_array[$i]}"
            } &
        done
        wait
        #echo "Downloads completed."

    done
}

