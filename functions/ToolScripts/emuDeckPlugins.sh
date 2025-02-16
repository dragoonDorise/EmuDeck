#!/bin/bash

Plugins_install_cleanup() {
	local password=$1
  	#We restart Decky
	#systemctl daemon-reload
	#systemctl restart plugin_loader

	#Deleting temp password
	if [ "$password" = "EmuDecky!" ]; then
		echo "$password" | sudo -S -k passwd -d $(whoami) && echo "true"
	fi
}

Plugins_checkPassword(){
   local password=$1
   if [ "$password" = "EmuDecky!" ]; then ## AppImage install when no sudo
      #We create the password
      yes "$password" | passwd $(whoami) &>/dev/null || {
        read -r PASS <<< $(zenity --title="Decky Installer" --width=300 --height=100 --entry --hide-text --text="Enter your sudo/admin password so we can install Decky with the best plugins for emulation")
        if [[ $? -eq 1 ]] || [[ $? -eq 5 ]]; then
          exit 1
        fi
        if ( echo "$PASS" | sudo -S -k true ); then
          password=$PASS
        else
          zenity --title="Decky Installer" --width=150 --height=40 --info --text "Incorrect Password"
        fi
      }
   elif [ "$system" == "chimeraos" ]; then
    password="gamer"
   elif [ "$system" == "bazzite" ]; then
    password="bazzite"
   elif [ -z $password ]; then ## setup install when no password set

        #does it have a pass?
        if sudo -n true 2>/dev/null; then

            read -r PASS <<< $(zenity --title="Decky Installer" --width=300 --height=100 --entry --hide-text --text="Enter your sudo/admin password so we can install Decky with the best plugins for emulation")
            if [[ $? -eq 1 ]] || [[ $? -eq 5 ]]; then
                exit 1
            fi
            if ( echo "$PASS" | sudo -S -k true ); then
                password=$PASS
            else
                zenity --title="Decky Installer" --width=150 --height=40 --info --text "Incorrect Password"
                exit 1
            fi

        else
            #We create the password
            yes "$password" | passwd $(whoami) &>/dev/null || {
              read -r PASS <<< $(zenity --title="Decky Installer" --width=300 --height=100 --entry --hide-text --text="Enter your sudo/admin password so we can install Decky with the best plugins for emulation")
              if [[ $? -eq 1 ]] || [[ $? -eq 5 ]]; then
                exit 1
              fi
              if ( echo "$PASS" | sudo -S -k true ); then
                password=$PASS
              else
                zenity --title="Decky Installer" --width=150 --height=40 --info --text "Incorrect Password"
              fi
            }
        fi
   fi
   echo $password
}

Plugins_installPluginLoader(){
   setMSG  "Installing Decky Loader"

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
   mkdir -p "$HOME/homebrew/plugins/"

   # Capturar la contraseña corregida
   password=$(Plugins_checkPassword "$password")

   ptHash=$(curl https://beta.deckbrew.xyz/plugins | jq -r '.[] | select(.name=="PowerTools").versions[0].hash')
   local url="https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/$ptHash.zip"

   Plugins_installPluginLoader "$password"

   if [ -d "$HOME/homebrew" ]; then
      echo "$password" | sudo -S rm -rf "$HOME/homebrew/plugins/PowerTools"
      echo "$password" | sudo -S curl -L "$url" --output "$HOME/homebrew/PowerTools.zip.temp"  && mv "$HOME/homebrew/PowerTools.zip.temp" "$HOME/homebrew/PowerTools.zip"
      echo "$password" | sudo -S unzip "$HOME/homebrew/PowerTools.zip" -d "$HOME/homebrew/plugins/" && sudo rm "$HOME/homebrew/PowerTools.zip"
      Plugins_install_cleanup "$password"
   else
      rm -rf "$HOME/homebrew/plugins/PowerTools"
      echo "$password" | sudo -S curl -L "$url" --output "$HOME/homebrew/PowerTools.zip.temp" && mv "$HOME/homebrew/PowerTools.zip.temp" "$HOME/homebrew/PowerTools.zip"
      echo "$password" | sudo -S unzip "$HOME/homebrew/PowerTools.zip" -d "$HOME/homebrew/plugins/" && sudo rm "$HOME/homebrew/PowerTools.zip"
   fi
   Plugins_install_cleanup "$password"
}


Plugins_installPowerControl(){
   echo "Installing PowerControl"
   local password=$1
   local destinationFolder="$HOME/homebrew/plugins/PowerControl"
   local PowerControl_releaseURL="$(getLatestReleaseURLGH "mengmeet/PowerControl" ".tar.gz")"

   mkdir -p "$HOME/homebrew/plugins/"

   # Capturar la contraseña corregida
   password=$(Plugins_checkPassword "$password")

   Plugins_installPluginLoader "$password"

   if [ -d "$HOME/homebrew" ]; then
      echo "$password" | sudo -S rm -rf "$destinationFolder"
      echo "$password" | sudo -S curl -L "$PowerControl_releaseURL" -o "$HOME/homebrew/plugins/PowerControl.tar.gz"
      echo "$password" | sudo -S unzip "$HOME/homebrew/plugins/PowerControl.tar.gz" -d "$HOME/homebrew/plugins/" && echo "$password" | sudo -S rm "$HOME/homebrew/plugins/PowerControl.tar.gz"
      echo "$password" | sudo -S chown $USER:$USER -R "$HOME/homebrew/plugins/PowerControl"
      echo "$password" | sudo -S chmod 555 -R "$HOME/homebrew/plugins/PowerControl"
   else
      rm -rf "$destinationFolder"
      echo "$password" | sudo -S curl -L "$PowerControl_releaseURL" -o "$HOME/homebrew/plugins/PowerControl.tar.gz"
      echo "$password" | sudo -S unzip "$HOME/homebrew/plugins/PowerControl.tar.gz" -d "$HOME/homebrew/plugins/" && sudo rm "$HOME/homebrew/plugins/PowerControl.tar.gz"
      echo "$password" | sudo -S chown $USER:$USER -R "$HOME/homebrew/plugins/PowerControl"
   fi

   Plugins_install_cleanup "$password"
}


Plugins_installEmuDecky(){
   setMSG "Installing EmuDecky"
   local password=$1
   local destinationFolder="$HOME/homebrew/plugins/EmuDecky"
   local DeckyControls_releaseURL="$(getLatestReleaseURLGH "EmuDeck/EmuDecky" ".zip")"

   mkdir -p "$HOME/homebrew/plugins/"

   # CloudSync tools
    rsync -avzh "$emudeckBackend/tools/cloudSync/" "$toolsPath/cloudSync/"
    chmod +x "$toolsPath/cloudSync/cloud_sync_force_download.sh"
    chmod +x "$toolsPath/cloudSync/cloud_sync_force_upload.sh"

   # Capturar la contraseña corregida
   password=$(Plugins_checkPassword "$password")

   Plugins_installPluginLoader "$password"
   if [ -d "$HOME/homebrew" ]; then
      echo "$password" | sudo -S rm -rf "$destinationFolder"
      echo "$password" | sudo -S curl -L "$DeckyControls_releaseURL" -o "$HOME/homebrew/plugins/EmuDecky.zip"
      echo "$password" | sudo -S unzip "$HOME/homebrew/plugins/EmuDecky.zip" -d "$HOME/homebrew/plugins/" && echo "$password" | sudo -S rm "$HOME/homebrew/plugins/EmuDecky.zip"
      echo "$password" | sudo -S chown $USER:$USER -R "$HOME/homebrew/plugins/EmuDecky"
      echo "$password" | sudo -S chmod 555 -R "$HOME/homebrew/plugins/EmuDecky"
   else
      rm -rf "$destinationFolder"
      echo "$password" | sudo -S curl -L "$DeckyControls_releaseURL" -o "$HOME/homebrew/plugins/EmuDecky.zip"
      echo "$password" | sudo -S unzip "$HOME/homebrew/plugins/EmuDecky.zip" -d "$HOME/homebrew/plugins/" && sudo rm "$HOME/homebrew/plugins/EmuDecky.zip"
      echo "$password" | sudo -S chown $USER:$USER -R "$HOME/homebrew/plugins/EmuDecky"
   fi

   Plugins_install_cleanup "$password"

}


Plugins_installDeckyRomLibrary(){
   setMSG  "Installing Retro Library"
   local password=$1
   local destinationFolder="$HOME/homebrew/plugins/decky-rom-library"
   local DeckyControls_releaseURL="$(getLatestReleaseURLGH "EmuDeck/decky-rom-library" ".zip")"

   generateGameLists

   mkdir -p "$HOME/homebrew/plugins/"

   # Asegurarnos de que el password sea correcto antes de continuar
   password=$(Plugins_checkPassword "$password")

   Plugins_installPluginLoader "$password"

   if [ -d "$HOME/homebrew" ]; then
    echo "$password" | sudo -S rm -rf "$destinationFolder"
    echo "$password" | sudo -S curl -L "$DeckyControls_releaseURL" -o "$HOME/homebrew/plugins/decky-rom-library.zip"
    echo "$password" | sudo -S unzip "$HOME/homebrew/plugins/decky-rom-library.zip" -d "$HOME/homebrew/plugins/" && echo "$password" | sudo -S rm "$HOME/homebrew/plugins/decky-rom-library.zip"
    echo "$password" | sudo -S chown $USER:$USER -R "$HOME/homebrew/plugins/decky-rom-library"
    echo "$password" | sudo -S chmod 555 -R "$HOME/homebrew/plugins/decky-rom-library"
  else
     rm -rf "$destinationFolder"
     echo "$password" | sudo -S curl -L "$DeckyControls_releaseURL" -o "$HOME/homebrew/plugins/decky-rom-library.zip"
     echo "$password" | sudo -S unzip "$HOME/homebrew/plugins/decky-rom-library.zip" -d "$HOME/homebrew/plugins/" && sudo rm "$HOME/homebrew/plugins/decky-rom-library.zip"
     echo "$password" | sudo -S chown $USER:$USER -R "$HOME/homebrew/plugins/decky-rom-library"
   fi

   Plugins_install_cleanup "$password"

}


Plugins_installSteamDeckGyroDSU(){
   setMSG  "Installing GyroDSU"
   local SDGyro_releaseURL="https://github.com/kmicki/SteamDeckGyroDSU/raw/master/pkg/update.sh"
   curl -L $SDGyro_releaseURL --output /tmp/sdgyro.sh && chmod +x /tmp/sdgyro.sh && /tmp/sdgyro.sh && rm /tmp/sdgyro.sh
}



Plugins_install(){
  local password=$1
	Plugins_installEmuDecky $password
  Plugins_installDeckyRomLibrary $password
	Plugins_installSteamDeckGyroDSU
}


Plugins_installDeckyControls(){
  local password=$1
  Plugins_installEmuDecky $password
}