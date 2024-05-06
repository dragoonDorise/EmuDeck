#!/bin/bash

generateGameLists(){

    ROMS_DIR="$HOME/Emulation/roms"

    JSON_OUTPUT="$HOME/Emulation/roms_games.json"
    echo "[" > "$JSON_OUTPUT"

    for system_dir in "$ROMS_DIR"/*; do
        if [[ -d "$system_dir" && -f "$system_dir/metadata.txt" ]]; then

            collection=$(grep 'collection:' "$system_dir/metadata.txt" | cut -d ':' -f 2- | awk '{$1=$1};1')
            shortname=$(grep 'shortname:' "$system_dir/metadata.txt" | cut -d ':' -f 2- | awk '{$1=$1};1')
            extensions=$(grep 'extensions:' "$system_dir/metadata.txt" | cut -d ':' -f 2- | tr ',' '\n' | awk '{$1=$1};1' | tr '\n' '|')
            launcher=$(grep 'launch:' "$system_dir/metadata.txt" | cut -d ':' -f 2- | awk '{$1=$1};1')
            extensions="${extensions%|}" # Eliminar el último '|'


            tmp_file="$(mktemp)"


            find "$system_dir" -type f | while read file_path; do
                filename=$(basename "$file_path")
                extension="${filename##*.}"

                if [[ $extensions =~ (^|[|])${extension,,}([|]|$) ]]; then

                    name="${filename%.*}"
                    echo "{\"name\": \"$name\", \"filename\": \"$file_path\"}," >> "$tmp_file"
                fi
            done


            sort "$tmp_file" | sed '$ s/,$//' > "${tmp_file}_sorted"
            mv "${tmp_file}_sorted" "$tmp_file"


            if [[ -s "$tmp_file" ]]; then
                echo "  {" >> "$JSON_OUTPUT"
                echo "    \"title\": \"$collection\"," >> "$JSON_OUTPUT"
                echo "    \"id\": \"$shortname\"," >> "$JSON_OUTPUT"
                echo "    \"launcher\": \"$launcher\"," >> "$JSON_OUTPUT"
                echo "    \"games\": [" >> "$JSON_OUTPUT"
                cat "$tmp_file" >> "$JSON_OUTPUT"
                echo "    ]" >> "$JSON_OUTPUT"
                echo "  }," >> "$JSON_OUTPUT"
            fi


            rm "$tmp_file"
        fi
    done


    echo "]" >> "$JSON_OUTPUT"
    sed -i '$ s/,$//' "$JSON_OUTPUT"

    cat $JSON_OUTPUT

}
