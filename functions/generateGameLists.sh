#!/bin/bash
generateGameLists() {
    ROMS_DIR="$romsPath"

    # Initialize an empty array in JSON format
    printf "["

    first_system=true

    for system_dir in "$ROMS_DIR"/*; do
        if [[ -d "$system_dir" && -f "$system_dir/metadata.txt" ]]; then

            if [[ "$system_dir" == *"/ps3" ]]; then
                continue
            fi
            if [[ "$system_dir" == *"/xbox360" ]]; then
                continue
            fi
            if [[ "$system_dir" == *"/model2" ]]; then
                continue
            fi
            if [[ "$system_dir" == *"/genesiswide" ]]; then
                continue
            fi

            file_count=$(find "$system_dir" -type f | wc -l)
            if [[ "$file_count" -le 2 ]]; then
                continue  # Skip this system_dir if there are 2 or fewer files
            fi

            collection=$(grep 'collection:' "$system_dir/metadata.txt" | cut -d ':' -f 2- | awk '{$1=$1};1')
            shortname=$(grep 'shortname:' "$system_dir/metadata.txt" | cut -d ':' -f 2- | awk '{$1=$1};1')
#            launcher=$(grep 'launch:' "$system_dir/metadata.txt" | cut -d ':' -f 2- | awk '{$1=$1};1')
            launcher=$(grep 'launch:' "$system_dir/metadata.txt" | cut -d ':' -f 2- | awk '{$1=$1};1' | sed 's/"/\\"/g')
            extensions=$(grep 'extensions:' "$system_dir/metadata.txt" | cut -d ':' -f 2- | tr ',' ' ' | awk '{$1=$1};1')

            if $first_system; then
                first_system=false
            else
                printf ","
            fi

            # Start system object
            printf '{ "title": "%s", "id": "%s", "launcher": "%s", "games": [' "$collection" "$shortname" "$launcher"

            # Use jq to create the JSON objects for each game and print them directly
            first_game=true
            api_key="f80f92019254471cca9d62ff91c21eee"

            find "$system_dir" -type f | while read -r file_path; do
                filename=$(basename "$file_path")
                extension="${filename##*.}"
                name="${filename%.*}"
                if [[ "$extensions" =~ "$extension" ]]; then
                    if $first_game; then
                        first_game=false
                    else
                        printf ","
                    fi

                    clean_name=$(echo "$name" | tr ' ' '_' | sed 's/[^a-zA-Z0-9_]//g')

                    response=$(curl -s -G "https://bot.emudeck.com/steamdbimg.php?name=$clean_name")

                    game_name=$(echo "$response" | jq -r '.name')
                    game_img_url=$(echo "$response" | jq -r '.img')
                    game_img=$(echo "$game_img_url" | sed 's|.*/||')


                    if [ "$game_img_url" == "null" ]; then
                        game_name=$name
                        game_img='';
                    else
                        accountfolder=$(ls -d $HOME/.steam/steam/userdata/*/ | head -n 1)
                        dest_folder="$accountfolder/config/grid/"
                        mkdir -p "$dest_folder"
                        filename=$(basename "$game_img_url")
                        dest_path="$dest_folder/$filename"
                        if [ ! -f $dest_path ]; then
                            curl -o "$dest_path" "$game_img_url"
                        fi
                        game_img="/customimages/$game_img"
                    fi

                    jq -n --arg name "$game_name" --arg filename "$file_path" --arg game_img "$game_img" \
                        '{"name": $name, "filename": $filename, "img": $game_img}'
                fi
            done
            # End games array and system object
            printf "] }"

        fi
    done

    # End of JSON array
    printf "]"
}
