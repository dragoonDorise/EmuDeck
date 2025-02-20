#!/bin/bash
#variables
SRM_toolName="Steam ROM Manager"
SRM_toolType="$emuDeckEmuTypeAppImage"
SRM_toolPath="${toolsPath}/Steam-ROM-Manager.AppImage"
SRM_userData_directory="configs/steam-rom-manager/userData"
SRM_userData_configDir="$HOME/.config/steam-rom-manager/userData"
#cleanupOlderThings

SRM_install(){
  setMSG "Installing Steam ROM Manager"
  local showProgress="$1"

  if [ -f "$toolsPath" ]; then
    rm -rf "$toolsPath"
  fi

  mkdir -p "$toolsPath"

  if installToolAI "Steam-ROM-Manager" "$(getReleaseURLGH "SteamGridDB/steam-rom-manager" "AppImage")" "" "$showProgress"; then
    SRM_customDesktopShortcut
  else
    return 1
  fi
}

SRM_uninstall(){
  rm -rf "${toolsPath}/Steam ROM Manager.AppImage"
  rm -rf $HOME/.local/share/applications/SRM.desktop
  rm -rf "$HOME/.local/share/applications/Steam ROM Manager.desktop"
}

SRM_customDesktopShortcut(){
  mkdir -p "$toolsPath/launchers/srm"
  cp "$EMUDECKGIT/tools/launchers/srm/steamrommanager.sh" "$toolsPath/launchers/srm/steamrommanager.sh"
  rm -rf $HOME/.local/share/applications/SRM.desktop

  createDesktopShortcut   "$HOME/.local/share/applications/Steam ROM Manager.desktop" \
    "Steam-ROM-Manager AppImage" \
    "${toolsPath}/launchers/srm/steamrommanager.sh" \
    "false"
}

SRM_migration(){
  if [ -f "${toolsPath}/srm/Steam-ROM-Manager.AppImage" ]; then
    mv "${toolsPath}/srm/Steam-ROM-Manager.AppImage" "${toolsPath}/Steam ROM Manager.AppImage" &> /dev/null
    SRM_customDesktopShortcut
    SRM_flushToolLauncher
  fi

  if [ -f "${toolsPath}/Steam ROM Manager.AppImage" ]; then
    mv "${toolsPath}/Steam ROM Manager.AppImage" "${toolsPath}/Steam-ROM-Manager.AppImage" &> /dev/null
    SRM_customDesktopShortcut
    SRM_flushToolLauncher
  fi
}

SRM_init(){

  setMSG "Configuring Steam Rom Manager"
  mkdir -p "$HOME/.config/steam-rom-manager/userData/"
  rsync -avhp --mkpath "$EMUDECKGIT/configs/steam-rom-manager/userData/userConfigurations.json" "$HOME/.config/steam-rom-manager/userData/" --backup --suffix=.bak
  rsync -avhp --mkpath "$EMUDECKGIT/configs/steam-rom-manager/userData/userSettings.json" "$HOME/.config/steam-rom-manager/userData/" --backup --suffix=.bak
  SRM_setEmulationFolder
  SRM_setEnv
  SRM_addControllerTemplate
  SRM_addSteamInputProfiles
  SRM_flushToolLauncher
  addSteamInputCustomIcons
  SRM_flushOldSymlinks
  echo -e "true"

}

SRM_setEmulationFolder(){

  sed -i "s|/run/media/mmcblk0p1/Emulation/tools|${toolsPath}|g" "$HOME/.config/steam-rom-manager/userData/userConfigurations.json"
  sed -i "s|/run/media/mmcblk0p1/Emulation/storage|${storagePath}|g" "$HOME/.config/steam-rom-manager/userData/userConfigurations.json"
  sed -i "s|/home/deck|$HOME|g" "$HOME/.config/steam-rom-manager/userData/userConfigurations.json"

  sed -i "s|/home/deck|$HOME|g" "$HOME/.config/steam-rom-manager/userData/userSettings.json"
  sed -i "s|/run/media/mmcblk0p1/Emulation/roms|${romsPath}|g" "$HOME/.config/steam-rom-manager/userData/userSettings.json"
  sed -i "s|/run/media/mmcblk0p1/Emulation/tools|${toolsPath}|g" "$HOME/.config/steam-rom-manager/userData/userSettings.json"

}

SRM_setEnv(){

	setMSG 'Steam Rom Manager - Set enviroment'
  tmp=$(mktemp)
  jq -r --arg STEAMDIR "$HOME/.steam/steam" '.environmentVariables.steamDirectory = "\($STEAMDIR)"' \
  "$SRM_userData_configDir/userSettings.json" > "$tmp"\
   && mv "$tmp" "$SRM_userData_configDir/userSettings.json"

  tmp=$(mktemp)
  jq -r --arg ROMSDIR "$romsPath" '.environmentVariables.romsDirectory = "\($ROMSDIR)"' \
  "$SRM_userData_configDir/userSettings.json" > "$tmp" \
  && mv "$tmp" "$SRM_userData_configDir/userSettings.json"

  tmp=$(mktemp)
  jq -r --arg STEAMDIR "$HOME/.steam/steam" '.environmentVariables.steamDirectory = "\($STEAMDIR)"' \
  "$HOME/.config/steam-rom-manager/userData/userSettings.json" > "$tmp"\
  && mv "$tmp" "$HOME/.config/steam-rom-manager/userData/userSettings.json"

  tmp=$(mktemp)
  jq -r --arg ROMSDIR "$romsPath" '.environmentVariables.romsDirectory = "\($ROMSDIR)"' \
  "$HOME/.config/steam-rom-manager/userData/userSettings.json" > "$tmp" \
  && mv "$tmp" "$HOME/.config/steam-rom-manager/userData/userSettings.json"

}

SRM_addControllerTemplate(){

  mkdir -p "$HOME/.config/steam-rom-manager/userData/"
  rsync -avhp --mkpath "$EMUDECKGIT/configs/steam-rom-manager/userData/controllerTemplates.json" "$HOME/.config/steam-rom-manager/userData/" --backup --suffix=.bak

  if [ -d "${HOME}/.local/share/Steam" ]; then
    STEAMPATH="${HOME}/.local/share/Steam"
  elif [ -d "${HOME}/.steam/steam" ]; then
    STEAMPATH="${HOME}/.steam/steam"
  else
    echo "Steam install not found"
  fi

  sed -i "s|/home/deck/.local/share/Steam|${STEAMPATH}|g" "$HOME/.config/steam-rom-manager/userData/controllerTemplates.json"

}

SRM_addSteamInputProfiles(){
   setMSG 'Steam Rom Manager - Adding Steam input profiles'
   rm -rf "$HOME/.steam/steam/controller_base/templates/ares_controller_config.vdf"
   rm -rf "$HOME/.steam/steam/controller_base/templates/cemu_controller_config.vdf"
   rm -rf "$HOME/.steam/steam/controller_base/templates/citra_controller_config.vdf"
   rm -rf "$HOME/.steam/steam/controller_base/templates/duckstation_controller_config.vdf"
   rm -rf "$HOME/.steam/steam/controller_base/templates/emulationstation-de_controller_config.vdf"
   rm -rf "$HOME/.steam/steam/controller_base/templates/melonds_controller_config.vdf"
   rm -rf "$HOME/.steam/steam/controller_base/templates/mGBA_controller_config.vdf"
   rm -rf "$HOME/.steam/steam/controller_base/templates/pcsx2_controller_config.vdf"
   rm -rf "$HOME/.steam/steam/controller_base/templates/ppsspp_controller_config.vdf"
   rm -rf "$HOME/.steam/steam/controller_base/templates/rmg_controller_config.vdf"

   rsync -r --exclude='*/' "$EMUDECKGIT/configs/steam-input/" "$HOME/.steam/steam/controller_base/templates/"
   #Cleanup old controller schemes
}

SRM_resetConfig(){
  SRM_migration
  SRM_init
  echo "true"
}

SRM_IsInstalled(){

  if [ -f "$SRM_toolPath" ]; then
    echo "true"
  elif [ -e "${toolsPath}/Steam ROM Manager.AppImage" ]; then
    echo "true"
  elif [ -e "${toolsPath}/srm/Steam-ROM-Manager.AppImage" ]; then
    echo "true"
  else
      echo "false"
  fi

}

SRM_flushToolLauncher(){
  mkdir -p "$toolsPath/launchers/srm"
	cp "$EMUDECKGIT/tools/launchers/srm/steamrommanager.sh" "$toolsPath/launchers/srm/steamrommanager.sh"
  chmod +x "$toolsPath/launchers/srm/steamrommanager.sh"
}

SRM_flushOldSymlinks(){

  if [ -L "$romsPath/mame2003" ]; then
    rm -f "$romsPath/mame2003"
  fi

  if [ -L "$romsPath/mamecurrent" ]; then
    rm -f "$romsPath/mamecurrent"
  fi

}

SRM_deleteCache(){

  if [ -d "${HOME}/.local/share/Steam" ]; then
    STEAMPATH="${HOME}/.local/share/Steam"
  elif [ -d "${HOME}/.steam/steam" ]; then
    STEAMPATH="${HOME}/.steam/steam"
  else
    echo "Steam install not found"
  fi

		zenity --question \
    --text="If you are experiencing freezing or crashing with Steam ROM Manager, this will delete the cache and reset your non-Steam library. \
    \nThis will delete all of your non-Steam shortcuts. \
    \nDo note this includes any game launchers, browsers, fan games, any games or applications you have added as a non-Steam game. This will not delete the games or applications themselves. \
    \n \
    \nThis will also delete any curated art you may have selected or downloaded for both Steam and non-Steam games. \
    \n \
    \nDeleting the cache will remove any launch option modifications for Steam games. \
    \n \
    \nIf you do not delete the cache, Steam ROM Manager may continue to crash or freeze. However, your non-Steam shortcuts will remain intact. \
    \n \
    \nWould you like to delete the cache?" \
    --title="Delete Cache" \
		--width=400 \
		--height=300 \
    --ok-label="No" \
    --cancel-label="Yes"


		if [ $? = 1 ]; then
      find "$STEAMPATH/userdata" -mindepth 2 -maxdepth 2 -type d -name 'config' -exec rm -rf {} +
      echo "Cache deleted."
      zenity --info \
      --text="The cache has been deleted. All of your non-Steam shortcuts have been wiped. You may open Steam ROM Manager and re-add your ROMs to your library." \
      --title="Cache deleted" \
      --width=400 \
      --height=300
    else
      echo "User declined deleting cache."
    fi

}
