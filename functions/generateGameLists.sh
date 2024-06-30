#!/bin/bash
generateGameLists() {
    pegasus_setPaths
    mkdir -p "$HOME/emudeck/cache/"
    python $HOME/.config/EmuDeck/backend/tools/generate_game_lists.py "$romsPath"
}

generateGameListsJson() {
    #local userid=$1
    python $HOME/.config/EmuDeck/backend/tools/generate_game_lists.py "$romsPath"
    cat $HOME/emudeck/cache/roms_games.json
    #generateGameLists_artwork $userid &> /dev/null &
    if [ -f "$HOME/emudeck/cache/.romlibrary_first" ]; then
        generateGameLists_artwork  &> /dev/null &
    else
        generateGameLists_artwork  &> /dev/null &
        generateGameLists_artwork  &> /dev/null &
        generateGameLists_artwork  &> /dev/null &
        generateGameLists_artwork  &> /dev/null &
        generateGameLists_artwork  &> /dev/null &
        touch "$HOME/emudeck/cache/.romlibrary_first"
    fi

}

generateGameLists_artwork() {
    mkdir -p "$HOME/emudeck/cache/"
    echo "" > "$HOME/emudeck/logs/romlibrary.log"
    local json_file="$HOME/emudeck/cache/roms_games.json"
    local json=$(cat "$json_file")
    local platforms=$(echo "$json" | jq -r '.[].id' | shuf)

    accountfolder=$(ls -td $HOME/.steam/steam/userdata/* | head -n 1)

    dest_folder="$accountfolder/config/grid/emudeck/"
    mkdir -p "$dest_folder"

    declare -A processed_games

    for platform in $platforms; do
        echo "Processing platform: $platform" >> "$HOME/emudeck/logs/romlibrary.log"
        games=$(echo "$json" | jq -r --arg platform "$platform" '.[] | select(.id == $platform) | .games[]?.name' | shuf)

        declare -a download_array
        declare -a download_dest_paths

        for game in $games; do
            file_to_check="$dest_folder${game// /_}*"

            if ! ls $file_to_check 1> /dev/null 2>&1 && [ -z "${processed_games[$game]}" ]; then
                echo "GAME:" "$game" >> "$HOME/emudeck/logs/romlibrary.log"

                fuzzygame=$(python $HOME/.config/EmuDeck/backend/tools/fuzzy_search_rom.py "$game")
                fuzzygame="${fuzzygame// /_}"
                echo "FUZZY:" "$fuzzygame" >> "$HOME/emudeck/logs/romlibrary.log"
                response=$(curl -s -G "https://bot.emudeck.com/steamdbimg.php?name=$fuzzygame")
                game_name=$(echo "$response" | jq -r '.name')
                game_img_url=$(echo "$response" | jq -r '.img')
                filename=$(basename "$game_img_url")
                dest_path="$dest_folder$game.jpg"

                if [ ! -f "$dest_path" ] && [ "$game_img_url" != "null" ]; then
                    echo "Added to the list: $game_img_url" - $dest_path
                    download_array+=("$game_img_url")
                    download_dest_paths+=("$dest_path")
                    processed_games[$game]=1

                    # Update the JSON with the image URL
                    #json=$(echo "$json" | jq --arg platform "$platform" --arg game "$game" --arg img_url "$game_img_url" ' (.[].games[] | select(.name == $game) | .img) |= $img_url ')
                else
                    response=$(curl -s -G "https://bot.emudeck.com/steamdbimg.php?name=$game")
                    game_name=$(echo "$response" | jq -r '.name')
                    game_img_url=$(echo "$response" | jq -r '.img')
                    filename=$(basename "$game_img_url")
                    dest_path="$dest_folder$game.jpg"

                    if [ "$game_img_url" = "null" ]; then
                       echo -e " - No picture" >> "$HOME/emudeck/logs/romlibrary.log"
                    else
                        echo "Added to the list: $game_img_url" - $dest_path
                        download_array+=("$game_img_url")
                        download_dest_paths+=("$dest_path")
                        processed_games[$game]=1
                    fi
                fi
            fi

            # Download in batches of 10
            if [ ${#download_array[@]} -ge 10 ]; then
                echo ""
                echo "Start batch" >> "$HOME/emudeck/logs/romlibrary.log"
                for i in "${!download_array[@]}"; do
                    {
                        curl -s -o "${download_dest_paths[$i]}" "${download_array[$i]}" >> "$HOME/emudeck/logs/romlibrary.log"
                    } &
                done
                wait
                # Clear the arrays for the next batch
                download_array=()
                download_dest_paths=()
                echo "Completed batch" >> "$HOME/emudeck/logs/romlibrary.log"
                echo ""
            fi
        done

        # Download images for the current platform
        if [ ${#download_array[@]} -ne 0 ]; then
            for i in "${!download_array[@]}"; do
                {
                    curl -s -o "${download_dest_paths[$i]}" "${download_array[$i]}" >> "$HOME/emudeck/logs/romlibrary.log"
                } &
            done
        fi
        wait

        echo "Completed search for platform: $platform" >> "$HOME/emudeck/logs/romlibrary.log"
    done

    # Save the updated JSON back to the file
    #echo "$json" > "$json_file"
}
