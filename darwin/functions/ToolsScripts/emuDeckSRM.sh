#!/bin/bash
SRM_setEnv(){
	whoami=$(whoami)
	sed -i "s|WHOAMI|${whoami}|g" "$SRM_userData_configDir/userSettings.json"
	sed -i "s|/run/media/mmcblk0p1/Emulation|$emulationPath|g"  "$SRM_userData_configDir/userSettings.json"

}

SRM_install(){
  darwin_installEmuDMG "Steam-ROM-Manager" "$(getReleaseURLGH "SteamGridDB/steam-rom-manager" "dmg")"
}

SRM_IsInstalled(){
  [ -e '/Applications/Steam ROM Manager.app' ] && echo "true" || echo "false"
}

SRM_uninstall(){
  rm -rf '/Applications/Steam ROM Manager.app'
  rm -rf "$HOME/Applications/EmuDeck/Steam ROM Manager.app"
}