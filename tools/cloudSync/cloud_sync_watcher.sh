#!/bin/bash

echo "SERVICE - START"

source "$HOME/emudeck/settings.sh"
source "$HOME/.config/EmuDeck/backend/functions/helperFunctions.sh"
source "$HOME/.config/EmuDeck/backend/functions/ToolScripts/emuDeckCloudSync.sh"

touch "$savesPath/.watching"

# Declare an array to store current hashes
echo "SERVICE - declare"
declare -A current_hashes

# Function to calculate the hash of a directory
calculate_hash() { 
  dir="$1"
  hash=$(find "$dir" -maxdepth 1 -type f -exec sha256sum {} + | sha256sum | awk '{print $1}')
  echo "$hash"
}

# Extract the name of the folder immediately behind "saves"
get_parent_folder_name() {
  echo "SERVICE - get_parent_folder_name"
  dir="$1"
  parent_dir=$(dirname "$dir")
  folder_name=$(basename "$parent_dir")
  echo "$folder_name"
}

# Initialize current hashes
for dir in "$savesPath"/*/*; do
  if [ -d "$dir" ]; then    
    current_hashes["$dir"]=$(calculate_hash "$dir")
  fi
done

# Loop that runs every second
while [ 1 == 1 ]
do
  echo "SERVICE - LOOP"
  # Check for changes in hashes
  lastSavedDir=''
  for dir in "${!current_hashes[@]}"; do
    new_hash=$(calculate_hash "$dir")
    #echo "$dir - ${current_hashes[$dir]}"
    #echo "$dir - $new_hash"
    
    if [ "${current_hashes[$dir]}" != "$new_hash" ]; then
      # Show the name of the folder immediately behind "saves"
      
      if [ "$lastSavedDir" != "$dir" ]; then  
        emuName=$(get_parent_folder_name "$dir")
        #cloud_sync_update
        timestamp=$(date +%s)
        echo "SERVICE - $emuName CHANGES DETECTED"
        echo $timestamp > "$savesPath/$emuName/.pending_upload"
        echo "SERVICE - UPLOAD"
        cloud_sync_uploadEmu $emuName && rm -rf "$savesPath/$emuName/.pending_upload"
        echo "SERVICE - UPLOADED"   
        lastSavedDir=$dir      
      else    
        echo "SERVICE - IGNORED"   
        lastSavedDir=''
      fi
      current_hashes["$dir"]=$new_hash
    fi    
  done

  #Autostop service when everything has finished
  if [ ! -f "$savesPath/.watching" ]; then 
    echo "SERVICE - NO WATCHING"   
    if [ ! -f "$HOME/emudeck/cloud.lock" ]; then 
    echo "SERVICE - NO LOCK"     
      cloud_sync_stopService      
    fi
  fi
  
  sleep 1  # Wait for 1 second before the next iteration
done
echo "SERVICE - END"