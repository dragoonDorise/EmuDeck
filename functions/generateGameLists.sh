#!/bin/bash
generateGameLists() {
    pegasus_setPaths
    mkdir -p "$HOME/emudeck/cache/"
    python $HOME/.config/EmuDeck/backend/tools/generate_game_lists.py "$romsPath"
}

generateGameListsJson() {
    #local userid=$1
#
#     if [ ! -f "$HOME/emudeck/games.json" ]; then
#         download_attempt=$(wget --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36" "https://steamgriddb.com/api/games" -O "$HOME/emudeck/games.json")
#     fi
    python $HOME/.config/EmuDeck/backend/tools/generate_game_lists.py "$romsPath"
    cat $HOME/emudeck/cache/roms_games.json
    #generateGameLists_artwork $userid &> /dev/null &
    if [ -f "$HOME/emudeck/cache/.romlibrary_first" ]; then
        generateGameLists_artwork 0 &> /dev/null &
    else
        generateGameLists_artwork 1 &> /dev/null &
        sleep 5
        generateGameLists_artwork 2 &> /dev/null &
        sleep 5
        generateGameLists_artwork 3 &> /dev/null &
        sleep 5
        generateGameLists_artwork 4 &> /dev/null &
        sleep 5
        generateGameLists_artwork 5 &> /dev/null &
        sleep 5
        touch "$HOME/emudeck/cache/.romlibrary_first"
    fi

}

generateGameLists_artwork() {
    mkdir -p "$HOME/emudeck/cache/"
    local number_log=$1
    local current_time=$(date +"%H_%M_%S")
    local logfilename="$HOME/emudeck/logs/library_${number_log}.log"
    local json_file="$HOME/emudeck/cache/roms_games.json"
    local json=$(cat "$json_file")

    if [ $number_log = 1 ]; then
        local platforms=$(echo "$json" | jq -r '.[].id')
    else
        local platforms=$(echo "$json" | jq -r '.[].id' | shuf)
    fi
    local accountfolder=$(ls -td $HOME/.steam/steam/userdata/* | head -n 1)
    local dest_folder="$accountfolder/config/grid/emudeck/"

    echo "" > "$logfilename"
    mkdir -p "$dest_folder"

    declare -A processed_games

    for platform in $platforms; do
        echo "Processing platform: $platform" >> "$logfilename"
        if [ $number_log = 1 ]; then
            games=$(echo "$json" | jq -r --arg platform "$platform" '.[] | select(.id == $platform) | .games[]?.name')
        else
            games=$(echo "$json" | jq -r --arg platform "$platform" '.[] | select(.id == $platform) | .games[]?.name' | shuf)
        fi
        declare -a download_array
        declare -a download_dest_paths

        for game in $games; do
            file_to_check="$dest_folder${game// /_}.jpg"

            if ! ls $file_to_check 1> /dev/null 2>&1 && [ -z "${processed_games[$game]}" ]; then
                echo "GAME:" "$game" >> "$logfilename"

                fuzzygame=$(python $HOME/.config/EmuDeck/backend/tools/fuzzy_search_rom.py "$game")
                fuzzygame="${fuzzygame// /_}"
                fuzzygame="${fuzzygame//:/}"
                fuzzygame="${fuzzygame//./}"
                fuzzygame="${fuzzygame//&/}"
                fuzzygame="${fuzzygame//!/}"
                echo "FUZZY:" "$fuzzygame" >> "$logfilename"
                #response=$(curl -s -G "https://bot.emudeck.com/steamdbimg.php?name=$fuzzygame")
                #game_name=$(echo "$response" | jq -r '.name')
                #game_img_url=$(echo "$response" | jq -r '.img')

                wget -q -O "$HOME/emudeck/cache/response.json" "https://bot.emudeck.com/steamdbimg.php?name=$fuzzygame"
                game_name=$(jq -r '.name' "$HOME/emudeck/cache/response.json")
                game_img_url=$(jq -r '.img' "$HOME/emudeck/cache/response.json")

                filename=$(basename "$game_img_url")
                dest_path="$dest_folder$game.jpg"

                if [ ! -f "$dest_path" ] && [ "$game_img_url" != "null" ]; then
                    echo "Added to the list: $game_img_url" >> "$logfilename"
                    download_array+=("$game_img_url")
                    download_dest_paths+=("$dest_path")
                    processed_games[$game]=1
                else
                    #response=$(curl -s -G "https://bot.emudeck.com/steamdbimg.php?name=$game")
                    #game_name=$(echo "$response" | jq -r '.name')
                    #game_img_url=$(echo "$response" | jq -r '.img')
                    wget -q -O "$HOME/emudeck/cache/response.json" "https://bot.emudeck.com/steamdbimg.php?name=$game"

                    game_name=$(jq -r '.name' "$HOME/emudeck/cache/response.json")
                    game_img_url=$(jq -r '.img' "$HOME/emudeck/cache/response.json")
                    filename=$(basename "$game_img_url")
                    dest_path="$dest_folder$game.jpg"

                    if [ "$game_img_url" = "null" ]; then
                       echo -e " - No picture" >> "$logfilename"
                    else
                        echo "Added to the list (NO FUZZY): $game_img_url" >> "$logfilename"
                        download_array+=("$game_img_url")
                        download_dest_paths+=("$dest_path")
                        processed_games[$game]=1
                    fi
                fi
            fi

            # Download in batches of 10
            if [ ${#download_array[@]} -ge 10 ]; then
                echo ""
                echo "Start batch" >> "$logfilename"
                for i in "${!download_array[@]}"; do
                    {
                        #curl -s -o "${download_dest_paths[$i]}" "${download_array[$i]}" >> "$logfilename"
                        wget -q -O "${download_dest_paths[$i]}" "${download_array[$i]}" >> "$logfilename"

                    } &
                done
                wait
                # Clear the arrays for the next batch
                download_array=()
                download_dest_paths=()
                echo "Completed batch" >> "$logfilename"
                echo ""
            fi
        done

        # Download images for the current platform
        if [ ${#download_array[@]} -ne 0 ]; then
            for i in "${!download_array[@]}"; do
                {
                    #curl -s -o "${download_dest_paths[$i]}" "${download_array[$i]}" >> "$logfilename"
                    wget -q -O "${download_dest_paths[$i]}" "${download_array[$i]}" >> "$logfilename"
                } &
            done
        fi
        wait

        echo "Completed search for platform: $platform" >> "$logfilename"
    done

    # Save the updated JSON back to the file
    #echo "$json" > "$json_file"
}

saveImage(){
    local url=$1
    local name=$2
    local accountfolder=$(ls -td $HOME/.steam/steam/userdata/* | head -n 1)
    local dest_folder="$accountfolder/config/grid/emudeck"
    local dest_path="$dest_folder/$name.jpg"
    wget -q -O "$dest_path" "$url"
}