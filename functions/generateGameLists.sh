#!/bin/bash

generateGameLists(){

    ROMS_DIR="$romsPath/snes"

    # Initialize an empty array in JSON format
    echo "["

    for system_dir in "$ROMS_DIR"*; do
        if [[ -d "$system_dir" && -f "$system_dir/metadata.txt" ]]; then

            file_count=$(find "$system_dir" -type f | wc -l)
            if [[ "$file_count" -le 2 ]]; then
                continue  # Skip this system_dir if there are 2 or fewer files
            fi

            collection=$(grep 'collection:' "$system_dir/metadata.txt" | cut -d ':' -f 2- | awk '{$1=$1};1')
            shortname=$(grep 'shortname:' "$system_dir/metadata.txt" | cut -d ':' -f 2- | awk '{$1=$1};1')
            launcher=$(grep 'launch:' "$system_dir/metadata.txt" | cut -d ':' -f 2- | awk '{$1=$1};1')
            extensions=$(grep 'extensions:' "$system_dir/metadata.txt" | cut -d ':' -f 2- | tr ',' ' ' | awk '{$1=$1};1')

            # Initialize an empty array in JSON format
            echo -n "  {"
            echo "\"title\": \"$collection\","
            echo "\"id\": \"$shortname\","
            echo "\"launcher\": \"$launcher\","
            echo "\"games\": ["

            # Use jq to create the JSON objects for each game and print them directly
            find "$system_dir" -type f | while read file_path; do
                filename=$(basename "$file_path")
                extension="${filename##*.}"
                name="${filename%.*}"
                if [[ "$extensions" =~ "$extension" ]]; then
                    jq -n --arg name "$name" --arg filename "$file_path" '{"name": $name, "filename": $filename}'
                    echo ","
                fi
            done

            # Close the games array and the system object
            echo "    },"

        fi
    done

    # Remove trailing comma from the last system object
    echo -n "]"
}