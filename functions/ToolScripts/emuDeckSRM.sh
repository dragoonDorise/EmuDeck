#!/bin/bash
#variables
SRM_toolName="Steam Rom Manager"
SRM_toolType="AppImage"
SRM_toolPath="${toolsPath}/Steam-ROM-Manager.AppImage"
SRM_userData_directory="configs/steam-rom-manager/userData"
SRM_userData_configDir="$HOME/.config/steam-rom-manager/userData"
#cleanupOlderThings

SRM_install(){		
  setMSG "Installing Steam Rom Manager"
  local showProgress="$1"
  
  if installToolAI "$SRM_toolName" "$(getReleaseURLGH "SteamGridDB/steam-rom-manager" "AppImage")" "" "$showProgress"; then
    :
  else
    return 1
  fi
  
} 


SRM_uninstall(){
  rm -rf "${toolsPath}/Steam-ROM-Manager.AppImage"
  rm -rf $HOME/.local/share/applications/SRM.desktop
}

SRM_createDesktopShortcut(){
  local SRM_Shortcutlocation=$1

  mkdir -p "$HOME/.local/share/applications/"
  
  mkdir -p "$HOME/.local/share/icons/emudeck/"
  cp -v "$EMUDECKGIT/icons/srm.png" "$HOME/.local/share/icons/emudeck/"

  if [[ "$SRM_Shortcutlocation" == "" ]]; then

	SRM_Shortcutlocation="$HOME/.local/share/applications/SRM.desktop"
  
  fi

  echo "#!/usr/bin/env xdg-open
  [Desktop Entry]
  Name=Steam Rom Manager AppImage
  Exec=zenity --question --width 450 --title \"Close Steam/Steam Input?\" --text \"Exit Steam to launch Steam Rom Manager? Desktop controls will temporarily revert to touch/trackpad/L2/R2 until you open Steam again.\" && (kill -15 \$(pidof steam) & $SRM_toolPath)
  Icon=$HOME/.local/share/icons/emudeck/srm.png
  Terminal=false
  Type=Application
  Categories=Game;
  StartupNotify=false" > "$SRM_Shortcutlocation"
  chmod +x "$SRM_Shortcutlocation"
}

SRM_init(){			
  setMSG "Configuring Steam Rom Manager"	
  local json_directory="$SRM_userData_configDir/parsers"
  local output_file="$SRM_userData_configDir/userConfigurations.json"
  #local files=$1


  

  mkdir -p "$SRM_userData_configDir/"	

  #Multiemulator?
  exclusionList=""
  #Multiemulator?
  if [ "$emuMULTI" != "both" ]; then
	if [ "$emuMULTI" = "ra" ]; then
	  exclusionList=$exclusionList"ares/\n"
	else
	  exclusionList=$exclusionList"atari_2600-ra-stella.json\n";
	  exclusionList=$exclusionList"bandai_wonderswan_color-ra-mednafen_swan.json\n";
	  exclusionList=$exclusionList"bandai_wonderswan-ra-mednafen_swan.json\n";
	  exclusionList=$exclusionList"nec_pc_engine_turbografx_16_cd-ra-beetle_pce.json\n";
	  exclusionList=$exclusionList"nec_pc_engine_turbografx_16-ra-beetle_pce.json\n";
	  exclusionList=$exclusionList"nintendo_64-ra-mupen64plus_next.json\n";
	  exclusionList=$exclusionList"nintendo_gb-ra-gambatte.json\n";
	  exclusionList=$exclusionList"nintendo_gb-ra-sameboy.json\n";
	  exclusionList=$exclusionList"nintendo_gba-ra-mgba.json\n";
	  exclusionList=$exclusionList"nintendo_gbc-ra-gambatte.json\n";
	  exclusionList=$exclusionList"nintendo_gbc-ra-sameboy.json\n";
	  exclusionList=$exclusionList"nintendo_nes-ra-mesen.json\n";
	  exclusionList=$exclusionList"nintendo_snes-ra-bsnes_hd.json\n";
	  exclusionList=$exclusionList"nintendo_snes-ra-snes9x.json\n";
	  exclusionList=$exclusionList"sega_32X-ra-picodrive.json\n";
	  exclusionList=$exclusionList"sega_CD_Mega_CD-ra-genesis_plus_gx.json\n";
	  exclusionList=$exclusionList"sega_dreamcast-ra-flycast.json\n";
	  exclusionList=$exclusionList"sega_game_gear-ra-genesis_plus_gx.json\n";
	  exclusionList=$exclusionList"sega_genesis-ra-genesis_plus_gx_wide.json\n";
	  exclusionList=$exclusionList"sega_genesis-ra-genesis_plus_gx.json\n";
	  exclusionList=$exclusionList"sega_mastersystem-ra-genesis-plus-gx.json\n";
	  exclusionList=$exclusionList"sinclair_zx-spectrum-ra-fuse.json\n";
	  exclusionList=$exclusionList"snk_neo_geo_pocket_color-ra-beetle_neopop.json\n";
	  exclusionList=$exclusionList"snk_neo_geo_pocket-ra-beetle_neopop.json\n";		 
	fi
  fi
  #N64?
  if [ "$emuN64" != "both" ]; then
	if [ "$emuN64" = "rgm" ]; then
	  exclusionList=$exclusionList"nintendo_64-ra-mupen64plus_next.json\n"
	  exclusionList=$exclusionList"nintendo_64-ares.json\n"
	  exclusionList=$exclusionList"nintendo_64dd-ares.json\n"
	else
	  exclusionList=$exclusionList"nintendo_64-rmg.json\n"
	fi
  fi
  #PSX?
  if [ "$emuPSX" != "both" ]; then
	if [ "$emuPSX" = "duckstation" ]; then
	  exclusionList=$exclusionList"sony_psx-ra-beetle_psx_hw.json\n"
	  exclusionList=$exclusionList"sony_psx-ra-swanstation.json\n"
	  exclusionList=$exclusionList"nintendo_64dd-ares.json\n"
	else
	  exclusionList=$exclusionList"sony_psx-duckstation.json\n"	
	fi
  fi
  #gba?
  if [ "$emuGBA" != "both" ]; then
	if [ "$emuGBA" = "mgba" ]; then
	  exclusionList=$exclusionList"nintendo_gameboy-advance-ares.json\n"
	  exclusionList=$exclusionList"nintendo_gba-ra-mgba.json\n"
	else		
	  exclusionList=$exclusionList"nintendo_gba-mgba.json\n"
	fi
  fi
  #psp
  if [ "$emuPSP" != "both" ]; then
	if [ "$emuPSP" = "ppsspp" ]; then
	  exclusionList=$exclusionList"sony_psp-ra-ppsspp.json\n"
	else
	  exclusionList=$exclusionList"sony_psp-ppsspp.json\n"		
	fi
  fi
  #melonDS
  if [ "$emuNDS" != "both" ]; then
	if [ "$emuNDS" = "melonds" ]; then
	  exclusionList=$exclusionList"nintendo_ds-ra-melonds.json\n"
	else
	  exclusionList=$exclusionList"nintendo_ds-melonds.json\n"
	fi
  fi
  #mame
  if [ "$emuMAME" != "both" ]; then
	if [ "$emuMAME" = "mame" ]; then	
	  exclusionList=$exclusionList"arcade-ra-mame_2010.json\n"
	  exclusionList=$exclusionList"arcade-ra-mame.json\n"
	  exclusionList=$exclusionList"arcade-ra-mame_2003_plus.json\n"
	else
	  exclusionList=$exclusionList"arcade-mame.json\n"
	  exclusionList=$exclusionList"tiger_electronics_gamecom-mame.json\n"
	  exclusionList=$exclusionList"vtech_vsmile-mame.json\n"
	  exclusionList=$exclusionList"snk_neo_geo_cd-mame.json\n"
	  exclusionList=$exclusionList"philips_cd_i-mame.json\n"		
	fi
  fi
  #Optional parsers
  exclusionList=$exclusionList"nintendo_gbc-ra-sameboy.json\n"
  exclusionList=$exclusionList"nintendo_gb-ra-sameboy.json\n"
  exclusionList=$exclusionList"sega_saturn-ra-yabause.json\n"
  exclusionList=$exclusionList"sony_psx-ra-swanstation.json\n"
  exclusionList=$exclusionList"nintendo_gbc-mgba.json\n"
  exclusionList=$exclusionList"nintendo_gb-mGBA.json\n"
  
  echo -e $exclusionList > "$HOME/exclude.txt"
  
  rm -rf "$SRM_userData_configDir/parsers/emudeck/"
	
  rsync -avz --mkpath --exclude-from="$HOME/exclude.txt" "$EMUDECKGIT/$SRM_userData_directory/parsers/emudeck/" "$SRM_userData_configDir/parsers/emudeck/"
  echo "Put your custom parsers here" "$SRM_userData_configDir/parsers/custom/readme.txt"
  rsync -avhp --mkpath "$EMUDECKGIT/$SRM_userData_directory/userSettings.json" "$SRM_userData_configDir/" --backup --suffix=.bak
  
  cp "$SRM_userData_configDir/userConfigurations.json" "$SRM_userData_configDir/userConfigurations.bak"
  
  rm -rf "$HOME/exclude.txt"
  
  # jq -s '.' $(find "\"$json_directory"\" -name "*.json" | sort) > "$output_file"
  rm -rf "$HOME/temp_parser"
  ln -s "$json_directory" "$HOME/temp_parser"
  files=$(find "$HOME/temp_parser/emudeck" -name "*.json" | sort)
  jq -s '.' $files > "$output_file"
  rm -rf "$HOME/temp_parser"
  
  sleep 1
  
  SRM_setEnv

  sed -i "s|/run/media/mmcblk0p1/Emulation/tools|${toolsPath}|g" "$SRM_userData_configDir/userConfigurations.json"
  sed -i "s|/run/media/mmcblk0p1/Emulation/storage|${storagePath}|g" "$SRM_userData_configDir/userConfigurations.json"
  sed -i "s|/home/deck|$HOME|g" "$SRM_userData_configDir/userConfigurations.json"
  
  sed -i "s|/home/deck|$HOME|g" "$SRM_userData_configDir/userSettings.json"
  sed -i "s|/run/media/mmcblk0p1/Emulation/roms|${romsPath}|g" "$SRM_userData_configDir/userSettings.json"
  sed -i "s|/run/media/mmcblk0p1/Emulation/tools|${toolsPath}|g" "$SRM_userData_configDir/userSettings.json"
  
  
  echo -e "true"
}

SRM_setEnv(){
  tmp=$(mktemp)
  jq -r --arg STEAMDIR "$HOME/.steam/steam" '.environmentVariables.steamDirectory = "\($STEAMDIR)"' \
  "$SRM_userData_configDir/userSettings.json" > "$tmp"\
   && mv "$tmp" "$SRM_userData_configDir/userSettings.json"
  
  tmp=$(mktemp)
  jq -r --arg ROMSDIR "$romsPath" '.environmentVariables.romsDirectory = "\($ROMSDIR)"' \
  "$SRM_userData_configDir/userSettings.json" > "$tmp" \
  && mv "$tmp" "$SRM_userData_configDir/userSettings.json"  
}

SRM_resetConfig(){
  SRM_init
  #Reseting launchers
  SRM_resetLaunchers
  echo "true"
}

SRM_IsInstalled(){
  if [ -e "$SRM_toolPath" ]; then
	echo "true"
  else
	echo "false"
  fi
}
SRM_resetLaunchers(){
  rsync -av --existing $HOME/.config/EmuDeck/backend/tools/launchers/ $toolsPath/launchers/	
  for entry in $toolsPath/launchers/*.sh
  do
	 chmod +x "$entry"
  done
}