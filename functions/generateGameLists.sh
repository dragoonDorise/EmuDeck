#!/bin/bash
generateGameLists() {

    pegasus_setPaths

    python $HOME/.config/EmuDeck/backend/tools/generate_game_lists.py "$romsPath"
    generateGameLists_artwork &> /dev/null &
}

generateGameListsJson() {
    cat $HOME/emudeck/roms_games.json
    #generateGameLists_artwork &> /dev/null &
}

generateGameLists_artwork() {
   json=$(cat "$HOME/emudeck/roms_games.json")
   platforms=$(echo "$json" | jq -r '.[].id')

   accountfolder=$(ls -d $HOME/.steam/steam/userdata/* | head -n 1)
   dest_folder="$accountfolder/config/grid/"
   mkdir -p "$dest_folder"

   for platform in $platforms; do
       echo "Processing platform: $platform"
       games=$(echo "$json" | jq -r --arg platform "$platform" '.[] | select(.id == $platform) | .games[]?.name')

       declare -a download_array
       declare -a download_dest_paths

       for game in $games; do
           file_to_check="$dest_folder${game// /_}*"

           if ! ls $file_to_check 1> /dev/null 2>&1; then
               echo "$game"

               response=$(curl -s -G "https://bot.emudeck.com/steamdbimg.php?name=$game")
               game_name=$(echo "$response" | jq -r '.name')
               game_img_url=$(echo "$response" | jq -r '.img')
               filename=$(basename "$game_img_url")
               dest_path="$dest_folder$game.jpg"
               if [ ! -f "$dest_path" ]; then
                   download_array+=("$game_img_url")
                   download_dest_paths+=("$dest_path")
               fi
           fi
       done

       # Download images for the current platform
       for i in "${!download_array[@]}"; do
           {
               curl -s -o "${download_dest_paths[$i]}" "${download_array[$i]}"
           } &
       done
       wait

       echo "Completed downloads for platform: $platform"
   done
}

