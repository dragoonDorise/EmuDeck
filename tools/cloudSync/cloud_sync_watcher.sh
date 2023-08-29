#!/bin/bash

echo "SERVICE - START" >> $HOME/log.log

source "$HOME/.config/EmuDeck/backend/functions/all.sh"

touch "$savesPath/.watching"

# Declare an array to store current hashes
declare -A current_hashes

# Function to calculate the hash of a directory
calculate_hash() {
  dir="$1"
  hash=$(find "$dir" -maxdepth 1 -type f -exec sha256sum {} + | sha256sum | awk '{print $1}')
  echo "$hash"
}

# Extract the name of the folder immediately behind "saves"
get_parent_folder_name() {
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
while true; do
  # Check for changes in hashes
  for dir in "${!current_hashes[@]}"; do
    new_hash=$(calculate_hash "$dir")
    if [ "${current_hashes[$dir]}" != "$new_hash" ]; then
      # Show the name of the folder immediately behind "saves"
      emuName=$(get_parent_folder_name "$dir")
      #cloud_sync_update
      timestamp=$(date +%s)
      echo "SERVICE - CHANGES DETECTED" >> $HOME/log.log
      echo $timestamp > "$savesPath/$emuName/.pending_upload"
      echo "SERVICE - UPLOAD?" >> $HOME/log.log
      cloud_sync_uploadEmu $emuName && rm -rf "$savesPath/$emuName/.pending_upload"
      echo "SERVICE - UPLOADED" >> $HOME/log.log
      current_hashes["$dir"]=$new_hash
    fi
  done
  
  #Autostop service when everything has finished
  if [ ! -f "$savesPath/.watching" ]; then    
    if [ ! -f "$HOME/emudeck/cloud.lock" ]; then      
      cloud_sync_stopService      
    fi
  fi
  
  sleep 1  # Wait for 1 second before the next iteration
done