#!/bin/bash

echo "SERVICE - START" > $HOME/emudeck/CloudSync.log
source "$HOME/emudeck/settings.sh"
source "$HOME/.config/EmuDeck/backend/functions/helperFunctions.sh"
source "$HOME/.config/EmuDeck/backend/functions/ToolScripts/emuDeckCloudSync.sh"

touch "$savesPath/.gaming"
touch "$savesPath/.watching"

#notify-send "Ready!" --icon="$HOME/.local/share/icons/emudeck/EmuDeck.png" --app-name "EmuDeck CloudSync" 

# Declare an array to store current hashes
echo "SERVICE - declare" >> $HOME/emudeck/CloudSync.log
declare -A current_hashes

# Function to calculate the hash of a directory
calculate_hash() { 
  dir="$1"
  hash=$(find "$dir" -maxdepth 1 -type f -exec sha256sum {} + | sha256sum | awk '{print $1}')
  echo "$hash"
}

# Extract the name of the folder immediately behind "saves"
get_parent_folder_name() {
  echo "SERVICE - get_parent_folder_name" >> $HOME/emudeck/CloudSync.log
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

  # Check for changes in hashes
  lastSavedDir=''
  
  for dir in "${!current_hashes[@]}"; do
  #echo -ne "." >> $HOME/emudeck/CloudSync.log
  
  if [ -h "$dir" ]; then
    realDir=$(readlink -f "$dir")
    new_hash=$(calculate_hash "$realDir")
  else
    new_hash=$(calculate_hash "$dir")
  fi
  
 
  # if [[ $dir == *"retroarch/states"* ]]; then
  #   echo "$dir - ${current_hashes[$dir]}" >> $HOME/emudeck/CloudSync.log
  #   echo "$dir - $new_hash" >> $HOME/emudeck/CloudSync.log
  # fi
  if [ "${current_hashes[$dir]}" != "$new_hash" ]; then
    # Show the name of the folder immediately behind "saves"
     echo "SERVICE - CHANGES DETECTED, LETS CHECK IF ITS A DUPLICATE" >> $HOME/emudeck/CloudSync.log
    if [ "$lastSavedDir" != "$dir" ]; then  
    emuName=$(get_parent_folder_name "$dir")
    #cloud_sync_update
    timestamp=$(date +%s)
    echo "SERVICE - $emuName CHANGES DETECTED" >> $HOME/emudeck/CloudSync.log
    echo $timestamp > "$savesPath/$emuName/.pending_upload"
    echo "SERVICE - UPLOAD" >> $HOME/emudeck/CloudSync.log
    #notify-send "Uploading from $emuName" --icon="$HOME/.local/share/icons/emudeck/EmuDeck.png" --app-name "EmuDeck CloudSync"    
    cloud_sync_uploadEmu $emuName
    rm -rf "$savesPath/$emuName/.pending_upload"
    echo "SERVICE - UPLOADED" >> $HOME/emudeck/CloudSync.log   
    lastSavedDir=$dir      
    else    
      echo "SERVICE - IGNORED" >> $HOME/emudeck/CloudSync.log   
      lastSavedDir=''
    fi
    current_hashes["$dir"]=$new_hash
  fi    
  done

  #Autostop service when everything has finished
  if [ ! -f "$savesPath/.gaming" ]; then
    echo "SERVICE - NO GAMING" >> $HOME/emudeck/CloudSync.log
    #notify-send "Uploading... don't turn off your device" --icon="$HOME/.local/share/icons/emudeck/EmuDeck.png" --app-name "EmuDeck CloudSync"
    if [ ! -f "$HOME/emudeck/cloud.lock" ]; then
      echo "SERVICE - STOP WATCHING" >> $HOME/emudeck/CloudSync.log  
      #notify-send "Uploading... don't turn off your device" --icon="$HOME/.local/share/icons/emudeck/EmuDeck.png" --app-name "EmuDeck CloudSync"
      #notify-send "Sync Completed! You can safely turn off your device" --icon="$HOME/.local/share/icons/emudeck/EmuDeck.png" --app-name "EmuDeck CloudSync"
      rm -rf "$savesPath/.watching"
      echo "SERVICE - NO LOCK - KILLING SERVICE" >> $HOME/emudeck/CloudSync.log     
      cloud_sync_stopService      
    fi
  fi
  
  sleep 1  # Wait for 1 second before the next iteration
done
echo "SERVICE - END" >> $HOME/emudeck/CloudSync.log