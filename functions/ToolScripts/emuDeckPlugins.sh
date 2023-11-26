#!/bin/bash



Plugins_install_cleanup() {
	local password=$1
  	#We restart Decky
	#systemctl daemon-reload
	#systemctl restart plugin_loader

	if [ "$password" = "Decky!" ] || [ "$password" = "gamer" ]; then
		echo "$password" | sudo -S -k passwd -d $(whoami)
	fi
}

Plugins_checkPassword(){
   local password=$1
   if [ "$password" = "Decky!" ] || [ "$password" = "gamer" ]; then
     #We create the password
     yes "$password" | passwd $(whoami)
   else
      if ( echo "$PASS" | sudo -S -k true ); then
        echo "true"
      else
          PASS=$(zenity --title="Decky Installer" --width=300 --height=100 --entry --hide-text --text="Enter your sudo/admin password so we can install Decky with the best plugins for emulation")
          if [[ $? -eq 1 ]] || [[ $? -eq 5 ]]; then
              exit 1
          fi
          if ( echo "$PASS" | sudo -S -k true ); then
              password=$PASS
          else
              zenity --title="Decky Installer" --width=150 --height=40 --info --text "Incorrect Password"
          fi
        fi
   fi
   return $password
}

Plugins_installPluginLoader(){
   local password=$1
   local PluginLoader_releaseURL="https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/install_release.sh"
   if [ ! -f $HOME/.steam/steam/.cef-enable-remote-debugging ]; then
		mkdir -p "$HOME/homebrew"
		Plugins_checkPassword $password  && echo $password | sudo -S chown -R $USER:$USER "$HOME/homebrew"
		curl -L $PluginLoader_releaseURL | sh
		touch "$HOME/.steam/steam/.cef-enable-remote-debugging"
		echo $password |  sudo -S chown $USER:$USER ~/.steam/steam/.cef-enable-remote-debugging
		Plugins_install_cleanup $password
	fi
}

Plugins_installPowerTools(){
   local password=$1
   local ptHash
   Plugins_checkPassword $password
   local url="https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/$ptHash.zip"

   ptHash=$(curl https://beta.deckbrew.xyz/plugins | jq -r '.[] | select(.name=="PowerTools").versions[0].hash')
   if [ -d "$HOME/homebrew/plugins/" ]; then
   	echo $password |  sudo -S rm -rf "$HOME/homebrew/plugins/PowerTools"
   	curl -l "$url" --output "$HOME/homebrew/PowerTools.zip.temp"  && mv "$HOME/homebrew/PowerTools.zip.temp" "$HOME/homebrew/PowerTools.zip"
   	echo $password |  sudo -S unzip "$HOME/homebrew/PowerTools.zip" -d "$HOME/homebrew/plugins/" && rm "$HOME/homebrew/PowerTools.zip"
   	Plugins_install_cleanup $password
   else
	  rm -rf "$HOME/homebrew/plugins/PowerTools"
	  curl -l "$url" --output "$HOME/homebrew/PowerTools.zip.temp" && mv "$HOME/homebrew/PowerTools.zip.temp" "$HOME/homebrew/PowerTools.zip"
	  unzip "$HOME/homebrew/PowerTools.zip" -d "$HOME/homebrew/plugins/" && rm "$HOME/homebrew/PowerTools.zip"
   fi
}

Plugins_installPowerControl(){
   local password=$1
   local destinationFolder="$HOME/homebrew/plugins/EmuDecky"
   local PowerControl_releaseURL="$(getLatestReleaseURLGH "mengmeet/PowerControl" ".tar.gz")"
   if [ -d "$HOME/homebrew/plugins/" ]; then
   	Plugins_checkPassword $password
   	echo $password |  sudo -S rm -rf $destinationFolder
   	echo $password |  sudo -S curl -L "$PowerControl_releaseURL" -o "$HOME/homebrew/plugins/PowerControl.tar.gz"
   	echo $password |  sudo -S unzip "$HOME/homebrew/plugins/PowerControl.tar.gz" -d "$HOME/homebrew/plugins/" && echo $password |  sudo -S rm "$HOME/homebrew/plugins/PowerControl.tar.gz"
   	echo $password |  sudo -S chown $USER:$USER -R $HOME/homebrew/plugins/PowerControl
   	chmod 555 -R $HOME/homebrew/plugins/PowerControl
   	Plugins_install_cleanup $password
   else
	  rm -rf $destinationFolder
	  curl -L "$PowerControl_releaseURL" -o "$HOME/homebrew/plugins/PowerControl.tar.gz"
	  unzip "$HOME/homebrew/plugins/PowerControl.tar.gz" -d "$HOME/homebrew/plugins/" && rm "$HOME/homebrew/plugins/PowerControl.tar.gz"
	  chown $USER:$USER -R $HOME/homebrew/plugins/PowerControl
   fi

}

Plugins_installDeckyControls(){
  local password=$1
  Plugins_installEmuDecky $password
}
Plugins_installEmuDecky(){
   local password=$1
   local destinationFolder="$HOME/homebrew/plugins/EmuDecky"
   local DeckyControls_releaseURL="$(getLatestReleaseURLGH "EmuDeck/EmuDecky" ".zip")"
   if [ -d "$HOME/homebrew/plugins/" ]; then
		Plugins_checkPassword $password
		echo $password |  sudo -S rm -rf $destinationFolder
		echo $password |  sudo -S curl -L "$DeckyControls_releaseURL" -o "$HOME/homebrew/plugins/EmuDecky.zip"
		echo $password |  sudo -S unzip "$HOME/homebrew/plugins/EmuDecky.zip" -d "$HOME/homebrew/plugins/" && echo $password |  sudo -S rm "$HOME/homebrew/plugins/EmuDecky.zip"
		echo $password |  sudo -S chown $USER:$USER -R $HOME/homebrew/plugins/EmuDecky
		chmod 555 -R $HOME/homebrew/plugins/EmuDecky
		Plugins_install_cleanup $password
	else
		 rm -rf $destinationFolder
		 curl -L "$DeckyControls_releaseURL" -o "$HOME/homebrew/plugins/EmuDecky.zip"
		 unzip "$HOME/homebrew/plugins/EmuDecky.zip" -d "$HOME/homebrew/plugins/" && rm "$HOME/homebrew/plugins/EmuDecky.zip"
		 chown $USER:$USER -R $HOME/homebrew/plugins/EmuDecky
   fi

}

Plugins_installSteamDeckGyroDSU(){
   local password=$1
   Plugins_checkPassword $password
   echo $password | sudo -S pwd
   local SDGyro_releaseURL="https://github.com/kmicki/SteamDeckGyroDSU/raw/master/pkg/update.sh"
   curl -L $SDGyro_releaseURL --output /tmp/sdgyro.sh && chmod +x /tmp/sdgyro.sh && /tmp/sdgyro.sh && rm /tmp/sdgyro.sh
   Plugins_install_cleanup $password
}



Plugins_install(){
	Plugins_installEmuDecky
	Plugins_installSteamDeckGyroDSU
	Plugins_installPluginLoader
}