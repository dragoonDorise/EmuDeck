#!/bin/bash

echo "SERVICE - START" > $HOME/emudeck/logs/CloudWatcher.log
source "$HOME/emudeck/settings.sh"
source "$HOME/.config/EmuDeck/backend/functions/helperFunctions.sh"
source "$HOME/.config/EmuDeck/backend/functions/ToolScripts/emuDeckCloudSync.sh"

touch "$savesPath/.gaming"
touch "$savesPath/.watching"

#notify-send "Ready!" --icon="$HOME/.local/share/icons/emudeck/EmuDeck.png" --app-name "EmuDeck CloudSync"

# Declare an array to store current hashes
echo "SERVICE - declare" >> $HOME/emudeck/logs/CloudWatcher.log
declare -A current_hashes

# Function to calculate the hash of a directory
calculate_hash() {
  dir="$1"
  hash=$(find "$dir" -type f -exec sha256sum {} + | sha256sum | awk '{print $1}')
  echo "$hash"
}

# Extract the name of the folder immediately behind "saves"
get_parent_folder_name() {
  dir="$1"
  parent_dir=$(dirname "$dir")
  folder_name=$(basename "$parent_dir")
  echo "$folder_name"
}

get_emulator() {
  local currentEmu=$(cat "$savesPath/.emuName")
  echo $currentEmu
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
  #echo -ne "." >> $HOME/emudeck/logs/CloudWatcher.log

  if [ -h "$dir" ]; then
    realDir=$(readlink -f "$dir")
    new_hash=$(calculate_hash "$realDir")
  else
    new_hash=$(calculate_hash "$dir")
  fi


  # if [[ $dir == *"citra/saves"* ]]; then
  #   echo "$dir - ${current_hashes[$dir]}" >> $HOME/emudeck/logs/CloudWatcher.log
  #   echo "$dir - $new_hash" >> $HOME/emudeck/logs/CloudWatcher.log
  # fi

  currentEmu=$(get_emulator)
  if [ $currentEmu == 'all' ]; then
    currentEmu=$dir
  fi

  # echo $currentEmu >> $HOME/emudeck/logs/CloudWatcher.log
  # echo $dir >> $HOME/emudeck/logs/CloudWatcher.log

  if [ "${current_hashes[$dir]}" != "$new_hash" ] && [[ $dir == *"$currentEmu"* ]]; then
    # Show the name of the folder immediately behind "saves"
     echo "SERVICE - CHANGES DETECTED on $dir, LETS CHECK IF ITS A DUPLICATE" >> $HOME/emudeck/logs/CloudWatcher.log
     timestamp=$(date +%s)

     if [ $((timestamp - lastSavedTime)) == 0 ]; then
      echo "SERVICE - IGNORED, same timestamp" >> $HOME/emudeck/logs/CloudWatcher.log
     fi
     echo $((timestamp - lastSavedTime)) >> $HOME/emudeck/logs/CloudWatcher.log

    if [ $((timestamp - lastSavedTime)) -ge 1 ]; then
      emuName=$(get_parent_folder_name "$dir")
      #cloud_sync_update

      echo "SERVICE - $emuName CHANGES CONFIRMED" >> $HOME/emudeck/logs/CloudWatcher.log
      echo $timestamp > "$savesPath/$emuName/.pending_upload"
      echo "SERVICE - UPLOADING" >> $HOME/emudeck/logs/CloudWatcher.log
      #notify-send "Uploading from $emuName" --icon="$HOME/.local/share/icons/emudeck/EmuDeck.png" --app-name "EmuDeck CloudSync"
      cloud_sync_uploadEmu $emuName
      rm -rf "$savesPath/$emuName/.pending_upload"
      echo "SERVICE - UPLOADED!" >> $HOME/emudeck/logs/CloudWatcher.log
      lastSavedTime=$(date +%s)
    else
      lastSavedTime=''
    fi
    current_hashes["$dir"]=$new_hash
  fi
  done

  #Autostop service when everything has finished
  if [ ! -f "$savesPath/.gaming" ]; then
    echo "SERVICE - NO GAMING" >> $HOME/emudeck/logs/CloudWatcher.log
    #notify-send "Uploading... don't turn off your device" --icon="$HOME/.local/share/icons/emudeck/EmuDeck.png" --app-name "EmuDeck CloudSync"
    if [ ! -f "$HOME/emudeck/cloud.lock" ]; then
      echo "SERVICE - STOP WATCHING" >> $HOME/emudeck/logs/CloudWatcher.log
      #notify-send "Uploading... don't turn off your device" --icon="$HOME/.local/share/icons/emudeck/EmuDeck.png" --app-name "EmuDeck CloudSync"
      #notify-send "Sync Completed! You can safely turn off your device" --icon="$HOME/.local/share/icons/emudeck/EmuDeck.png" --app-name "EmuDeck CloudSync"
      rm -rf "$savesPath/.watching"
      rm -rf "$savesPath/.emuName"
      echo "SERVICE - NO LOCK - KILLING SERVICE" >> $HOME/emudeck/logs/CloudWatcher.log

      cloud_sync_stopService
    fi
  fi

  sleep 1  # Wait for 1 second before the next iteration
done
echo "SERVICE - END" >> $HOME/emudeck/logs/CloudWatcher.log
