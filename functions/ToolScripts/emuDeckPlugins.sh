#!/bin/bash

Plugins_installPluginLoader(){
   local PluginLoader_releaseURL="https://github.com/SteamDeckHomebrew/PluginLoader/raw/main/dist/install_release.sh"
   mkdir -p $HOME/homebrew
   sudo chown -R deck:deck $HOME/homebrew
   curl -L $PluginLoader_releaseURL | sh
   touch /home/deck/.steam/steam/.cef-enable-remote-debugging
}

Plugins_installPowerTools(){	
   sudo rm -rf ~/homebrew/plugins/PowerTools
   sudo git clone https://github.com/NGnius/PowerTools.git ~/homebrew/plugins/PowerTools 
   cd ~/homebrew/plugins/PowerTools
   sudo git checkout tags/v0.7.0
}

Plugins_installSteamDeckGyroDSU(){
   InstallGyro=$(bash <(curl -sL https://github.com/kmicki/SteamDeckGyroDSU/raw/master/pkg/update.sh))
	echo $(printf "$InstallGyro" )
}
