#!/bin/bash

Plugins_install_cleanup() {
  local password=$1
  if [ $password = "Decky!" ]; then
   echo $password | sudo -S -k passwd -d $(whoami)
  fi
}

Plugins_checkPassword(){
   local password=$1      
   if [ $password = "Decky!" ]; then
     PASS=$password
     #We create the password
     yes $password | passwd deck   
   fi   
}

Plugins_installPluginLoader(){
   local password=$1
    
   local PluginLoader_releaseURL="https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/install_release.sh"
   mkdir -p "$HOME/homebrew"
   Plugins_checkPassword $password  && echo $password | sudo -S chown -R $USER:$USER "$HOME/homebrew"
   curl -L $PluginLoader_releaseURL | sh
   touch "$HOME/.steam/steam/.cef-enable-remote-debugging"
   echo $password |  sudo -S chown $USER:$USER ~/.steam/steam/.cef-enable-remote-debugging
   Plugins_install_cleanup $password
}

Plugins_installPowerTools(){
   local password=$1
   local ptHash
   Plugins_checkPassword $password
   ptHash=$(curl https://beta.deckbrew.xyz/plugins | jq -r '.[] | select(.name=="PowerTools").versions[0].hash')
   local url="https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/$ptHash.zip"
   echo $password |  sudo rm -rf "$HOME/homebrew/plugins/PowerTools"
   curl -l "$url" --output "$HOME/homebrew/PowerTools.zip.temp"  && mv "$HOME/homebrew/PowerTools.zip.temp" "$HOME/homebrew/PowerTools.zip" 
   echo $password |  sudo unzip "$HOME/homebrew/PowerTools.zip" -d "$HOME/homebrew/plugins/" && rm "$HOME/homebrew/PowerTools.zip"
   Plugins_install_cleanup $password
}

Plugins_installDeckyControls(){
   local password=$1
   local destinationFolder="$HOME/homebrew/plugins/emudeck-decky-controls"
   local DeckyControls_releaseURL="$(getLatestReleaseURLGH "EmuDeck/emudeck-decky-controls" ".zip")"
   Plugins_checkPassword $password
   echo $password |  sudo -S rm -rf $destinationFolder
   #echo $password |  sudo mkdir -p $destinationFolder
   echo $password |  sudo -S curl -L "$DeckyControls_releaseURL" -o "$HOME/homebrew/plugins/emudeck-decky-controls.zip"
   echo $password |  sudo -S unzip "$HOME/homebrew/plugins/emudeck-decky-controls.zip" -d "$HOME/homebrew/plugins/" && echo $password |  sudo -S rm "$HOME/homebrew/plugins/emudeck-decky-controls.zip"
   echo $password |  sudo -S chown $USER:$USER -R $HOME/homebrew/plugins/emudeck-decky-controls
   chmod 555 -R $HOME/homebrew/plugins/emudeck-decky-controls
   Plugins_install_cleanup $password
}

Plugins_installSteamDeckGyroDSU(){
   local password=$1
   Plugins_checkPassword $password
   echo $password | sudo -S pwd
   local SDGyro_releaseURL="https://github.com/kmicki/SteamDeckGyroDSU/raw/master/pkg/update.sh"   
   curl -L $SDGyro_releaseURL --output /tmp/sdgyro.sh && chmod +x /tmp/sdgyro.sh && /tmp/sdgyro.sh && rm /tmp/sdgyro.sh   
   Plugins_install_cleanup $password
}
