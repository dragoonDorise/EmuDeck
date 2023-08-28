#!/bin/bash
LOGFILE="$HOME/emudeck/cloudSync.log"
mv "${LOGFILE}" "$HOME/emudeck/cloudSync.last.log" #backup last log
{
source "$HOME/.config/EmuDeck/backend/functions/all.sh"

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
      echo "Change detected in $emuName"
      
      #cloud_sync_update
      cloud_sync_uploadEmu $emuName
      
      
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
} | tee "${LOGFILE}" 2>&1