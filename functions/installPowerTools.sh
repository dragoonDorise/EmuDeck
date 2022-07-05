#!/bin/bash
installPowerTools(){		
#should use sudo password piped into cache earlier.
releaseURL='https://github.com/SteamDeckHomebrew/PluginLoader/raw/legacy/dist/install_release.sh'
mkdir -p $HOME/homebrew
sudo chown -R deck:deck $HOME/homebrew
curl -L "$releaseURL" | sh	
sudo rm -rf ~/homebrew/plugins/PowerTools
sudo git clone https://github.com/NGnius/PowerTools.git ~/homebrew/plugins/PowerTools 
sleep 1
cd ~/homebrew/plugins/PowerTools
sudo git checkout tags/v0.6.0
text="$(printf "To finish the installation of Plugin Loader and PowerTools you will need to go into the Steam UI Settings\n\nUnder System -> System Settings toggle Enable Developer Mode\n\nScroll the sidebar all the way down and click on Developer\n\nUnder Miscellaneous, enable CEF Remote Debugging\n\nIn order to improve performance on Yuzu or Dolphin try configuring Powertools to activate only 4 CPU Cores\n\nYou can Access Powertools by presing the ... button and selecting the new Plugins Menu\n\n
\n\nIMPORTANT - The Powertools menu is touch ONLY.\n\n")"
zenity --info \
   --title="EmuDeck" \
   --width=450 \
   --text="${text}" 2>/dev/null		
}
