#!/bin/bash

Plugins_installPluginLoader(){
   local PluginLoader_releaseURL="https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/install_release.sh"
   mkdir -p "$HOME/homebrew"
   sudo chown -R $USER:$USER "$HOME/homebrew"
   curl -L $PluginLoader_releaseURL | sh
   touch "$HOME/.steam/steam/.cef-enable-remote-debugging"
   sudo chown $USER:$USER ~/.steam/steam/.cef-enable-remote-debugging
   #sudo systemctl disable --now steam-web-debug-portforward.service
}

Plugins_installPowerTools(){
   local ptHash
   ptHash=$(curl https://beta.deckbrew.xyz/plugins | jq -r '.[] | select(.name=="PowerTools").versions[0].hash')
   local url="https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/$ptHash.zip"
   sudo rm -rf "$HOME/homebrew/plugins/PowerTools"
   curl -l "$url" --output "$HOME/homebrew/PowerTools.zip.temp"  && mv "$HOME/homebrew/PowerTools.zip.temp" "$HOME/homebrew/PowerTools.zip" 
   sudo unzip "$HOME/homebrew/PowerTools.zip" -d "$HOME/homebrew/plugins/" && rm "$HOME/homebrew/PowerTools.zip"
}

Plugins_installDeckyControls(){
   local destinationFolder="$HOME/homebrew/plugins/emudeck-decky-controls"
   local DeckyControls_releaseURL="$(getLatestReleaseURLGH "EmuDeck/emudeck-decky-controls" ".zip")"
   sudo rm -rf $destinationFolder
   #sudo mkdir -p $destinationFolder
   sudo curl -L "$DeckyControls_releaseURL" -o "$HOME/homebrew/plugins/emudeck-decky-controls.zip"
   sudo unzip "$HOME/homebrew/plugins/emudeck-decky-controls.zip" -d "$HOME/homebrew/plugins/" && sudo rm "$HOME/homebrew/plugins/emudeck-decky-controls.zip"
   sudo chown $USER:$USER -R $HOME/homebrew/plugins/emudeck-decky-controls
   chmod 555 -R $HOME/homebrew/plugins/emudeck-decky-controls
}

Plugins_installSteamDeckGyroDSU(){
   local SDGyro_releaseURL="https://github.com/kmicki/SteamDeckGyroDSU/raw/master/pkg/update.sh"
   curl -L $SDGyro_releaseURL --output /tmp/sdgyro.sh && chmod +x /tmp/sdgyro.sh && /tmp/sdgyro.sh && rm /tmp/sdgyro.sh
}
