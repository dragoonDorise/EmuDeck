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
                    clean_name=$(clean_name "$name")
                    # Llamada a la API de SteamGridDB para obtener el ID del juego basado en el nombre
                    response=$(curl -s -G "https://bot.emudeck.com/steamdbimg.php?name=$clean_name")


                    # Extraer el ID del juego de la respuesta JSON
                    game_name=$(echo "$response" | jq -r '.name')
                    game_img=$(echo "$response" | jq -r '.img')

                    # Si no se encontró un ID, continuar sin agregarlo al JSON
                    if [ "$game_img" == "null" ]; then
                        game_name=$name
                        game_img='';
                    fi

                    # Generar el JSON con el ID del juego
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
