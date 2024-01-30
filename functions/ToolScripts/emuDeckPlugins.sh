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
   # The emudeck-decky-controls plugin is superseded by EmuDecky.
   # Remove old emudeck-decky-controls installations to prevent
   # duplicate plugins with different names.
   sudo rm -rf "$HOME/homebrew/plugins/emudeck-decky-controls"

   local DeckyControls_releaseURL="$(getLatestReleaseURLGH "EmuDeck/EmuDecky" ".zip")"
   local destinationArchive="$HOME/homebrew/plugins/EmuDecky.zip"
   sudo curl -L "$DeckyControls_releaseURL" -o "$destinationArchive"
   local destinationFolder="$HOME/homebrew/plugins/$(zipinfo -1 $destinationArchive | head -1)"
   sudo rm -rf $destinationFolder
   sudo unzip "$destinationArchive" -d "$HOME/homebrew/plugins/" && sudo rm "$destinationArchive"
   sudo chown $USER:$USER -R "$destinationFolder"
   chmod 555 "$destinationFolder"
}

Plugins_installSteamDeckGyroDSU(){
   local SDGyro_releaseURL="https://github.com/kmicki/SteamDeckGyroDSU/raw/master/pkg/update.sh"
   curl -L $SDGyro_releaseURL --output /tmp/sdgyro.sh && chmod +x /tmp/sdgyro.sh && /tmp/sdgyro.sh && rm /tmp/sdgyro.sh
}
