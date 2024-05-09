#!/bin/bash

generateGameLists() {
    ROMS_DIR="$romsPath/snes"

    # Initialize an empty array in JSON format
    printf "["

    first_system=true

    for system_dir in "$ROMS_DIR"*; do
        if [[ -d "$system_dir" && -f "$system_dir/metadata.txt" ]]; then

            # Ignore directories named "ps3"
            if [[ "$system_dir" == *"/ps3" ]]; then
                continue
            fi

            file_count=$(find "$system_dir" -type f | wc -l)
            if [[ "$file_count" -le 2 ]]; then
                continue  # Skip this system_dir if there are 2 or fewer files
            fi

            collection=$(grep 'collection:' "$system_dir/metadata.txt" | cut -d ':' -f 2- | awk '{$1=$1};1')
            shortname=$(grep 'shortname:' "$system_dir/metadata.txt" | cut -d ':' -f 2- | awk '{$1=$1};1')
            launcher=$(grep 'launch:' "$system_dir/metadata.txt" | cut -d ':' -f 2- | awk '{$1=$1};1')
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
                    jq -n --arg name "$name" --arg filename "$file_path" '{"name": $name, "filename": $filename}'
                fi
            done

            # End games array and system object
            printf "] }"

        fi
    done

    # End of JSON array
    printf "]"
}
