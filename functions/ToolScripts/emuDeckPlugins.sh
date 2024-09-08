#!/bin/bash

Plugins_install_cleanup() {
	local password=$1
  	#We restart Decky
	#systemctl daemon-reload
	#systemctl restart plugin_loader

	#Deleting temp password
	if [ "$password" = "Decky!" ]; then
		echo "$password" | sudo -S -k passwd -d $(whoami) && echo "true"
	fi
}

Plugins_checkPassword(){
   local password=$1
   if [ "$password" = "Decky!" ]; then
     #We create the password
     yes "$password" | passwd $(whoami) &>/dev/null
   elif [ "$system" == "chimeraos" ]; then
   	password="gamer"
   else
      if ( echo "$password" | sudo -S -k true ); then
        echo "true"
      else
          read -r PASS <<< $(zenity --title="Decky Installer" --width=300 --height=100 --entry --hide-text --text="Enter your sudo/admin password so we can install Decky with the best plugins for emulation")
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
   echo $password
}

Plugins_installPluginLoader(){
	echo "Installing Decky"
   local password=$1
   local PluginLoader_releaseURL="https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/install_release.sh"
   #if [ ! -f $HOME/.steam/steam/.cef-enable-remote-debugging ]; then
		mkdir -p "$HOME/homebrew"
		Plugins_checkPassword $password  && echo $password | sudo -S chown -R $USER:$USER "$HOME/homebrew"
		curl -L $PluginLoader_releaseURL | sh
		touch "$HOME/.steam/steam/.cef-enable-remote-debugging"
		echo $password | sudo -S chown $USER:$USER ~/.steam/steam/.cef-enable-remote-debugging
		Plugins_install_cleanup $password
	#fi
}

Plugins_installPowerTools(){
	echo "Installing PowerTools"
   local password=$1
   local ptHash
   Plugins_checkPassword $password
   ptHash=$(curl https://beta.deckbrew.xyz/plugins | jq -r '.[] | select(.name=="PowerTools").versions[0].hash')
   local url="https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/$ptHash.zip"

   if [ -d "$HOME/homebrew" ]; then
   	echo $password |  sudo -S rm -rf "$HOME/homebrew/plugins/PowerTools"
   	echo $password | sudo -S curl -l "$url" --output "$HOME/homebrew/PowerTools.zip.temp"  && mv "$HOME/homebrew/PowerTools.zip.temp" "$HOME/homebrew/PowerTools.zip"
   	echo $password |  sudo -S unzip "$HOME/homebrew/PowerTools.zip" -d "$HOME/homebrew/plugins/" && sudo rm "$HOME/homebrew/PowerTools.zip"
   	Plugins_install_cleanup $password
   else
      Plugins_installPluginLoader $password
	  rm -rf "$HOME/homebrew/plugins/PowerTools"
	  echo $password |  sudo -S curl -l "$url" --output "$HOME/homebrew/PowerTools.zip.temp" && mv "$HOME/homebrew/PowerTools.zip.temp" "$HOME/homebrew/PowerTools.zip"
	  echo $password |  sudo -S unzip "$HOME/homebrew/PowerTools.zip" -d "$HOME/homebrew/plugins/" && sudo rm "$HOME/homebrew/PowerTools.zip"
   fi
}

Plugins_installPowerControl(){
	echo "Installing PowerControl"
   local password=$1
   local destinationFolder="$HOME/homebrew/plugins/PowerControl"
   local PowerControl_releaseURL="$(getLatestReleaseURLGH "mengmeet/PowerControl" ".tar.gz")"
   if [ -d "$HOME/homebrew" ]; then
   	Plugins_checkPassword $password
   	echo $password |  sudo -S rm -rf $destinationFolder
   	echo $password |  sudo -S curl -L "$PowerControl_releaseURL" -o "$HOME/homebrew/plugins/PowerControl.tar.gz"
   	echo $password |  sudo -S unzip "$HOME/homebrew/plugins/PowerControl.tar.gz" -d "$HOME/homebrew/plugins/" && echo $password |  sudo -S rm "$HOME/homebrew/plugins/PowerControl.tar.gz"
   	echo $password |  sudo -S chown $USER:$USER -R $HOME/homebrew/plugins/PowerControl
   	echo $password | sudo -S chmod 555 -R $HOME/homebrew/plugins/PowerControl
   	Plugins_install_cleanup $password
   else
      Plugins_installPluginLoader $password
	  rm -rf $destinationFolder
	  echo $password |  sudo -S curl -L "$PowerControl_releaseURL" -o "$HOME/homebrew/plugins/PowerControl.tar.gz"
	  echo $password |  sudo -S unzip "$HOME/homebrew/plugins/PowerControl.tar.gz" -d "$HOME/homebrew/plugins/" && sudo rm "$HOME/homebrew/plugins/PowerControl.tar.gz"
	  echo $password | sudo -S chown $USER:$USER -R $HOME/homebrew/plugins/PowerControl
   fi

}

Plugins_installDeckyControls(){
  local password=$1
  Plugins_installEmuDecky $password
}
Plugins_installEmuDecky(){
   echo "Installing EmuDecky"
   local password=$1
   local destinationFolder="$HOME/homebrew/plugins/EmuDecky"
   local DeckyControls_releaseURL="$(getLatestReleaseURLGH "EmuDeck/EmuDecky" ".zip")"
   if [ -d "$HOME/homebrew" ]; then
		Plugins_checkPassword $password
		echo $password |  sudo -S rm -rf $destinationFolder
		echo $password |  sudo -S curl -L "$DeckyControls_releaseURL" -o "$HOME/homebrew/plugins/EmuDecky.zip"
		echo $password |  sudo -S unzip "$HOME/homebrew/plugins/EmuDecky.zip" -d "$HOME/homebrew/plugins/" && echo $password |  sudo -S rm "$HOME/homebrew/plugins/EmuDecky.zip"
		echo $password |  sudo -S chown $USER:$USER -R $HOME/homebrew/plugins/EmuDecky
		echo $password | sudo -S chmod 555 -R $HOME/homebrew/plugins/EmuDecky
		Plugins_install_cleanup $password
	else
         Plugins_installPluginLoader $password
		 rm -rf $destinationFolder
		 echo $password |  sudo -S curl -L "$DeckyControls_releaseURL" -o "$HOME/homebrew/plugins/EmuDecky.zip"
		 echo $password |  sudo -S unzip "$HOME/homebrew/plugins/EmuDecky.zip" -d "$HOME/homebrew/plugins/" && sudo rm "$HOME/homebrew/plugins/EmuDecky.zip"
		 echo $password | sudo -S chown $USER:$USER -R $HOME/homebrew/plugins/EmuDecky
   fi
   #CloudSync tools
   rsync -avzh "$EMUDECKGIT/tools/cloudSync/" "$toolsPath/cloudSync/"
   chmod +x "$toolsPath/cloudSync/cloud_sync_force_download.sh"
   chmod +x "$toolsPath/cloudSync/cloud_sync_force_upload.sh"

}

Plugins_installDeckyRomLibrary(){
   echo "Installing Decky Rom Library"
   local password=$1
   local destinationFolder="$HOME/homebrew/plugins/decky-rom-library"
   local DeckyControls_releaseURL="$(getLatestReleaseURLGH "EmuDeck/decky-rom-library" ".zip")"
   if [ -d "$HOME/homebrew" ]; then
    Plugins_checkPassword $password
    echo $password |  sudo -S rm -rf $destinationFolder
    echo $password |  sudo -S curl -L "$DeckyControls_releaseURL" -o "$HOME/homebrew/plugins/decky-rom-library.zip"
    echo $password |  sudo -S unzip "$HOME/homebrew/plugins/decky-rom-library.zip" -d "$HOME/homebrew/plugins/" && echo $password |  sudo -S rm "$HOME/homebrew/plugins/decky-rom-library.zip"
    echo $password |  sudo -S chown $USER:$USER -R $HOME/homebrew/plugins/decky-rom-library
    echo $password | sudo -S chmod 555 -R $HOME/homebrew/plugins/decky-rom-library
    Plugins_install_cleanup $password
  else
     Plugins_installPluginLoader $password
     rm -rf $destinationFolder
     echo $password |  sudo -S curl -L "$DeckyControls_releaseURL" -o "$HOME/homebrew/plugins/decky-rom-library.zip"
     echo $password | sudo -S unzip "$HOME/homebrew/plugins/decky-rom-library.zip" -d "$HOME/homebrew/plugins/" && sudo rm "$HOME/homebrew/plugins/decky-rom-library.zip"
     echo $password | sudo -S chown $USER:$USER -R $HOME/homebrew/plugins/decky-rom-library
   fi

}

Plugins_installSteamDeckGyroDSU(){
	echo "Installing GyroDSU"
   local SDGyro_releaseURL="https://github.com/kmicki/SteamDeckGyroDSU/raw/master/pkg/update.sh"
   curl -L $SDGyro_releaseURL --output /tmp/sdgyro.sh && chmod +x /tmp/sdgyro.sh && /tmp/sdgyro.sh && rm /tmp/sdgyro.sh
}



Plugins_install(){
  local password=$1
	Plugins_installEmuDecky $password
  Plugins_installDeckyRomLibrary $password
	Plugins_installSteamDeckGyroDSU
}