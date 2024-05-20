#!/bin/bash
generateGameLists() {

    pegasus_setPaths

    python $HOME/test.py "$romsPath"

}

generateGameListsJson() {

    cat $HOME/emudeck/roms_games.json

}

generateGameLists_artwork() {

    ROMS_DIR="$romsPath"

    # Initialize an empty array in JSON format
    printf "["

    first_system=true
    declare -a download_array
    declare -a download_dest_paths
    declare -a valid_system_dirs

    # Collect directories that meet the file count criteria
    for system_dir in "$ROMS_DIR"/*; do
        if [[ -d "$system_dir" && -f "$system_dir/metadata.txt" ]]; then
            file_count=$(find "$system_dir" -type f | wc -l)
            if [[ "$file_count" -gt 2 ]]; then
                valid_system_dirs+=("$system_dir")
            fi
        fi
    done

    for system_dir in "${valid_system_dirs[@]}"; do
        if [[ "$system_dir" == *"/ps3" || "$system_dir" == *"/xbox360" || "$system_dir" == *"/model2" || "$system_dir" == *"/genesiswide" ]]; then
            continue
        fi

        collection=$(grep 'collection:' "$system_dir/metadata.txt" | cut -d ':' -f 2- | awk '{$1=$1};1')
        shortname=$(grep 'shortname:' "$system_dir/metadata.txt" | cut -d ':' -f 2- | awk '{$1=$1};1')
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

        # Process files and collect game data
        game_data=""
        while IFS= read -r -d '' file_path; do
            filename=$(basename "$file_path")
            extension="${filename##*.}"
            name="${filename%.*}"
            #echo "Processing file: $filename with extension: $extension"

            if [[ " ${extensions[@]} " =~ " ${extension} " ]]; then
                #echo "File $filename matches the extensions filter"
                if ! $first_game; then
                    game_data+=","
                else
                    first_game=false
                fi

                clean_name=$(echo "$name" | tr ' ' '_' | sed 's/[^a-zA-Z0-9_]//g')
                accountfolder=$(ls -d $HOME/.steam/steam/userdata/* | head -n 1)
                dest_folder="$accountfolder/config/grid/"
                mkdir -p "$dest_folder"
                file_to_check="$dest_folder$clean_name*"

                #We only download the info again if the img doesn't exists
                if ! ls $file_to_check 1> /dev/null 2>&1; then
                    response=$(curl -s -G "https://bot.emudeck.com/steamdbimg.php?name=$clean_name")
                    game_name=$(echo "$response" | jq -r '.name')
                    game_img_url=$(echo "$response" | jq -r '.img')
                    game_img=$(echo "$game_img_url" | sed 's|.*/||')
                    filename=$(basename "$game_img_url")
                    dest_path="$dest_folder$clean_name.jpg"
                    if [ ! -f "$dest_path" ]; then
                        #echo "Adding $game_img_url to download array"
                        download_array+=("$game_img_url")
                        download_dest_paths+=("$dest_path")
                    fi
                fi
                game_img="/customimages/$clean_name.jpg"

                if [ "$game_img_url" == "null" ]; then
                    game_name=$name
                fi

                game_data+=$(jq -n --arg name "$game_name" --arg filename "$file_path" --arg game_img "$game_img" \
                    '{"name": $name, "filename": $filename, "img": $game_img}')
            fi
        done < <(find "$system_dir" -type f -print0)

        printf "$game_data"
        # End games array and system object
        printf "] }"

    done

    # End of JSON array
    printf "]"

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
}

