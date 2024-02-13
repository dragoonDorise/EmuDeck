#!/bin/bash
SRM_setEnv(){
	whoami=$(whoami)
	sed -i "s|WHOAMI|${whoami}|g" "$SRM_userData_configDir/userSettings.json"
	sed -i "s|/run/media/mmcblk0p1/Emulation|$emulationPath|g"  "$SRM_userData_configDir/userSettings.json"

}

SRM_resetLaunchers(){
  rsync -av --existing $HOME/.config/EmuDeck/backend/darwin/tools/launchers/ $toolsPath/launchers/
  for entry in $toolsPath/launchers/*.sh
  do
   chmod +x "$entry"
  done
}