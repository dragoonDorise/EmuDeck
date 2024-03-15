#!/bin/bash
#variables
SRM_toolName="Steam ROM Manager"
SRM_toolType="$emuDeckEmuTypeAppImage"
SRM_toolPath="${toolsPath}/Steam ROM Manager.AppImage"
SRM_userData_directory="configs/steam-rom-manager/userData"
SRM_userData_configDir="$HOME/.config/steam-rom-manager/userData"
SRM_customVariablesURL="https://raw.githubusercontent.com/SteamGridDB/steam-rom-manager/master/files/customVariables.json"
#cleanupOlderThings

SRM_install(){
  setMSG "Installing Steam ROM Manager"
  local showProgress="$1"

  if installToolAI "$SRM_toolName" "$(getReleaseURLGH "SteamGridDB/steam-rom-manager" "AppImage")" "" "$showProgress"; then
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

	  SRM_init

	  Citra_resetConfig
	  PCSX2QT_resetConfig
	  DuckStation_resetConfig
  fi
}

SRM_init(){
  setMSG "Configuring Steam ROM Manager"
  local json_directory="$SRM_userData_configDir/parsers"
  local output_file="$SRM_userData_configDir/userConfigurations.json"

  mkdir -p "$SRM_userData_configDir/"

  SRM_createParsers
  SRM_addSteamInputProfiles
  SRM_setEnv
  echo -e "true"
}

SRM_ok_init(){

  setMSG "Configuring Steam Rom Manager"

  mkdir -p "$HOME/.config/steam-rom-manager/userData/"
  rsync -avhp --mkpath "$EMUDECKGIT/configs/steam-rom-manager/userData/userConfigurations.json" "$HOME/.config/steam-rom-manager/userData/" --backup --suffix=.bak
  rsync -avhp --mkpath "$EMUDECKGIT/configs/steam-rom-manager/userData/userSettings.json" "$HOME/.config/steam-rom-manager/userData/" --backup --suffix=.bak
  rsync -avhp --mkpath "$EMUDECKGIT/configs/steam-rom-manager/userData/controllerTemplates.json" "$HOME/.config/steam-rom-manager/userData/" --backup --suffix=.bak
  #cp "$EMUDECKGIT/configs/steam-rom-manager/userData/userConfigurations.json" "$HOME/.config/steam-rom-manager/userData/userConfigurations.json"
  #cp "$EMUDECKGIT/configs/steam-rom-manager/userData/userSettings.json" "$HOME/.config/steam-rom-manager/userData/userSettings.json"
  sleep 3
  tmp=$(mktemp)
  jq -r --arg STEAMDIR "$HOME/.steam/steam" '.environmentVariables.steamDirectory = "\($STEAMDIR)"' \
  "$HOME/.config/steam-rom-manager/userData/userSettings.json" > "$tmp"\
  && mv "$tmp" "$HOME/.config/steam-rom-manager/userData/userSettings.json"

  tmp=$(mktemp)
  jq -r --arg ROMSDIR "$romsPath" '.environmentVariables.romsDirectory = "\($ROMSDIR)"' \
  "$HOME/.config/steam-rom-manager/userData/userSettings.json" > "$tmp" \
  && mv "$tmp" "$HOME/.config/steam-rom-manager/userData/userSettings.json"

  #sed -i "s|/run/media/mmcblk0p1/Emulation/roms|${romsPath}|g" "$HOME/.config/steam-rom-manager/userData/userConfigurations.json"
  sed -i "s|/run/media/mmcblk0p1/Emulation/tools|${toolsPath}|g" "$HOME/.config/steam-rom-manager/userData/userConfigurations.json"
  sed -i "s|/run/media/mmcblk0p1/Emulation/storage|${storagePath}|g" "$HOME/.config/steam-rom-manager/userData/userConfigurations.json"
  sed -i "s|/home/deck|$HOME|g" "$HOME/.config/steam-rom-manager/userData/userConfigurations.json"

  sed -i "s|/home/deck|$HOME|g" "$HOME/.config/steam-rom-manager/userData/userSettings.json"
  sed -i "s|/run/media/mmcblk0p1/Emulation/roms|${romsPath}|g" "$HOME/.config/steam-rom-manager/userData/userSettings.json"
  sed -i "s|/run/media/mmcblk0p1/Emulation/tools|${toolsPath}|g" "$HOME/.config/steam-rom-manager/userData/userSettings.json"

  curl -L "$SRM_customVariablesURL" -o "$HOME/.config/steam-rom-manager/userData/customVariables.json"

  if [ -d "${HOME}/.local/share/Steam" ]; then
    STEAMPATH="${HOME}/.local/share/Steam"
  elif [ -d "${HOME}/.steam/steam" ]; then
    STEAMPATH="${HOME}/.steam/steam"
  else
    echo "Steam install not found"
  fi

  sed -i "s|/home/deck/.steam/steam|${STEAMPATH}|g" "$HOME/.config/steam-rom-manager/userData/controllerTemplates.json"

  SRM_flushToolLauncher
  SRM_addSteamInputProfiles
  addSteamInputCustomIcons
  
  echo -e "true"


}

SRM_createParsers(){
  setMSG 'Steam Rom Manager - Creating Parsers'
  local json_directory="$SRM_userData_configDir/parsers"
  local output_file="$SRM_userData_configDir/userConfigurations.json"
  local exclusionList=""
  #Multiemulator?
  if [ "$emuMULTI" != "both" ]; then

    if [ "$emuMULTI" = "ra" ]; then
      exclusionList=$exclusionList"ares/\n"
    else
	  exclusionList=$exclusionList"ares/\n"
		exclusionList=$exclusionList"mednafen_pcfx_libretro\n";
		exclusionList=$exclusionList"mednafen_vb_libretro\n";
		exclusionList=$exclusionList"sega_saturn-ra-kronos.json\n";
		exclusionList=$exclusionList"freeintv_libretro.json\n";
		exclusionList=$exclusionList"amiga_600-ra-puae.json\n";
		exclusionList=$exclusionList"amiga_1200-ra-puae.json\n";
		exclusionList=$exclusionList"amiga_cd-ra-puae.json\n";
		exclusionList=$exclusionList"amiga-ra-puae.json\n";
		exclusionList=$exclusionList"amstrad_cpc-ra-cap32.json\n";
		exclusionList=$exclusionList"arcade_naomi-ra-flycast.json\n";
		exclusionList=$exclusionList"arcade-ra-fbneo.json\n";
		exclusionList=$exclusionList"arcade-ra-mame_2003_plus.json\n";
		exclusionList=$exclusionList"arcade-ra-mame_2010.json\n";
		exclusionList=$exclusionList"arcade-ra-mame.json\n";
		exclusionList=$exclusionList"atari_2600-ra-stella.json\n";
		exclusionList=$exclusionList"atari_jaguar-ra-virtualjaguar.json\n";
		exclusionList=$exclusionList"atari_lynx-ra-mednafen.json\n";
		exclusionList=$exclusionList"bandai_wonderswan_color-ra-mednafen_swan.json\n";
		exclusionList=$exclusionList"bandai_wonderswan-ra-mednafen_swan.json\n";
		exclusionList=$exclusionList"commodore_16-ra-vice_xplus4.json\n";
		exclusionList=$exclusionList"commodore_64-ra-vice_x64.json\n";
		exclusionList=$exclusionList"commodore_vic_20-ra-vice_xvic.json\n";
		exclusionList=$exclusionList"doom-ra-prboom.json\n";
		exclusionList=$exclusionList"dos-ra-dosbox_pure.json\n";
		exclusionList=$exclusionList"nec_pc_98-ra-np2kai.json\n";
		exclusionList=$exclusionList"nec_pc_engine_turbografx_16_cd-ra-beetle_pce.json\n";
		exclusionList=$exclusionList"nec_pc_engine_turbografx_16-ra-beetle_pce.json\n";
		exclusionList=$exclusionList"nintendo_64-ra-mupen64plus_next.json\n";
		exclusionList=$exclusionList"nintendo_ds-melonds.json\n";
		exclusionList=$exclusionList"nintendo_ds-ra-melonds.json\n";
		exclusionList=$exclusionList"nintendo_gb-ra-gambatte.json\n";
		exclusionList=$exclusionList"nintendo_gb-ra-sameboy.json\n";
		exclusionList=$exclusionList"nintendo_gba-ra-mgba.json\n";
		exclusionList=$exclusionList"nintendo_gbc-ra-gambatte.json\n";
		exclusionList=$exclusionList"nintendo_gbc-ra-sameboy.json\n";
		exclusionList=$exclusionList"nintendo_nes-ra-mesen.json\n";
		exclusionList=$exclusionList"nintendo_sgb-ra-mesen-s.json\n";
		exclusionList=$exclusionList"nintendo_snes-ra-bsnes_hd.json\n";
		exclusionList=$exclusionList"nintendo_snes-ra-snes9x.json\n";
		exclusionList=$exclusionList"panasonic_3do-ra-opera.json\n";
		exclusionList=$exclusionList"philips_cd_i-ra-same_cdi.json\n";
		exclusionList=$exclusionList"pico_8-ra-retro8.json\n";
		exclusionList=$exclusionList"rpg_maker-ra-easyrpg.json\n";
		exclusionList=$exclusionList"sega_32X-ra-picodrive.json\n";
		exclusionList=$exclusionList"sega_CD_Mega_CD-ra-genesis_plus_gx.json\n";
		exclusionList=$exclusionList"sega_dreamcast-ra-flycast.json\n";
		exclusionList=$exclusionList"sega_game_gear-ra-genesis_plus_gx.json\n";
		exclusionList=$exclusionList"sega_genesis-ra-genesis_plus_gx_wide.json\n";
		exclusionList=$exclusionList"sega_genesis-ra-genesis_plus_gx.json\n";
		exclusionList=$exclusionList"sega_mastersystem-ra-genesis-plus-gx.json\n";
		exclusionList=$exclusionList"sega_saturn-ra-mednafen.json\n";
		exclusionList=$exclusionList"sega_saturn-ra-yabause.json\n";
		exclusionList=$exclusionList"sharp-x68000-ra-px68k.json\n";
		exclusionList=$exclusionList"sinclair_zx-spectrum-ra-fuse.json\n";
		exclusionList=$exclusionList"snk_neo_geo_pocket_color-ra-beetle_neopop.json\n";
		exclusionList=$exclusionList"snk_neo_geo_pocket-ra-beetle_neopop.json\n";
		exclusionList=$exclusionList"sony_psp-ra-ppsspp.json\n";
		exclusionList=$exclusionList"sony_psx-ra-beetle_psx_hw.json\n";
		exclusionList=$exclusionList"sony_psx-ra-swanstation.json\n";
		exclusionList=$exclusionList"tic-80-ra-tic80.json\n";
		exclusionList=$exclusionList"mattel_electronics_intellivision-ra-freeIntv.json\n";
		exclusionList=$exclusionList"nec_pc_fx-ra-beetle_pcfx.json\n";
		exclusionList=$exclusionList"nintendo_virtual_boy-ra-beetle_vb.json\n";
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
	  exclusionList=$exclusionList"nintendo_ds-ra-melondsds.json\n"

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

  if [ "$emuDreamcast" != "both" ]; then
	  if [ "$emuDreamcast" = "flycast" ]; then
		exclusionList=$exclusionList"sega_dreamcast-ra-flycast.json\n"
		exclusionList=$exclusionList"arcade_naomi-ra-flycast\n"
	  else
		exclusionList=$exclusionList"sega_dreamcast-flycast.json\n"
		exclusionList=$exclusionList"arcade_naomi-flycast.json\n"
		exclusionList=$exclusionList"arcade_atomiswave-flycast.json\n"
		exclusionList=$exclusionList"arcade_naomi2-flycast.json\n"
	  fi
	fi


  #Optional parsers
  exclusionList=$exclusionList"nintendo_gbc-ra-sameboy.json\n"
  exclusionList=$exclusionList"nintendo_gb-ra-sameboy.json\n"
  exclusionList=$exclusionList"sega_saturn-ra-yabause.json\n"
  exclusionList=$exclusionList"sony_psx-ra-swanstation.json\n"
  exclusionList=$exclusionList"nintendo_gbc-mgba.json\n"
  exclusionList=$exclusionList"nintendo_gb-mGBA.json\n"
  exclusionList=$exclusionList"nintendo_ds-ra-melonds-legacy.json\n"

  #Exclusion based on install status.



  if [ "$(BigPEmu_IsInstalled)" == "false" ]; then
		exclusionList=$exclusionList"atari_jaguar-bigpemu_proton.json\n"
	fi
  if [ "$(Primehack_IsInstalled)" == "false" ]; then
      exclusionList=$exclusionList"nintendo_primehack.json\n"
  fi
  if [ "$(RPCS3_IsInstalled)" == "false" ]; then
      exclusionList=$exclusionList"sony_ps3-rpcs3-extracted_iso_psn.json\n"
      exclusionList=$exclusionList"sony_ps3-rpcs3-pkg.json\n"
  fi
  if [ "$(Citra_IsInstalled)" == "false" ]; then
      exclusionList=$exclusionList"nintendo_3ds-citra.json\n"
  fi
  if [ "$(Dolphin_IsInstalled)" == "false" ]; then
      exclusionList=$exclusionList"nintendo_gc-dolphin.json\n"
      exclusionList=$exclusionList"nintendo_wii-dolphin.json\n"
  fi
  if [ "$(DuckStation_IsInstalled)" == "false" ]; then
      exclusionList=$exclusionList"sony_psx-duckstation.json\n"
  fi
  if [ "$(PPSSPP_IsInstalled)" == "false" ]; then
      exclusionList=$exclusionList"sony_psp-ppsspp.json\n"
  fi
  if [ "$(Xemu_IsInstalled)" == "false" ]; then
      exclusionList=$exclusionList"microsoft_xbox-xemu.json\n"
  fi
  if [ "$(Xenia_IsInstalled)" == "false" ]; then
     exclusionList=$exclusionList"microsoft_xbox_360-xenia-xbla.json\n"
     exclusionList=$exclusionList"microsoft_xbox_360-xenia.json\n"
  fi
  if [ "$(ScummVM_IsInstalled)" == "false" ]; then
      exclusionList=$exclusionList"scumm_scummvm.json\n"
  fi
  if [ "$(RMG_IsInstalled)" == "false" ]; then
      exclusionList=$exclusionList"nintendo_64-rmg.json\n"
  fi
  if [ "$(melonDS_IsInstalled)" == "false" ]; then
      exclusionList=$exclusionList"nintendo_ds-melonds.json\n"
  fi
  if [ "$(Vita3K_IsInstalled)" == "false" ]; then
      exclusionList=$exclusionList"sony_psvita-vita3k-pkg.json\n"
  fi
  if [ "$(mGBA_IsInstalled)" == "false" ]; then
    exclusionList=$exclusionList"nintendo_gb-mGBA.json\n"
    exclusionList=$exclusionList"nintendo_gba-mgba.json\n"
    exclusionList=$exclusionList"nintendo_gbc-mgba.json\n"
  fi
  if [ "$(MAME_IsInstalled)" == "false" ]; then
    exclusionList=$exclusionList"arcade-mame.json\n"
  fi
  if [ "$(Yuzu_IsInstalled)" == "false" ]; then
    exclusionList=$exclusionList"nintendo_switch-yuzu.json\n"
  fi
  if [ "$(Ryujinx_IsInstalled)" == "false" ]; then
    exclusionList=$exclusionList"nintendo_switch-ryujinx.json\n"
  fi
  if [ "$(PCSX2QT_IsInstalled)" == "false" ]; then
    exclusionList=$exclusionList"sony_ps2-pcsx2.json\n"
  fi

  if [ "$(Supermodel_IsInstalled)" == "false" ]; then
	  exclusionList=$exclusionList"sega_model_3-supermodel.json\n"
  fi

  if [ "$(Model2_IsInstalled)" == "false" ]; then
	exclusionList=$exclusionList"sega_model2-model2emulator.json\n"
  fi

  if [ "$(BigPEmu_IsInstalled)" == "false" ]; then
	exclusionList=$exclusionList"atari_jaguar-bigpemu_proton.json\n"
  fi

  echo -e $exclusionList > "$HOME/exclude.txt"

  rm -rf "$SRM_userData_configDir/parsers/emudeck/"

  rsync -avz --mkpath --exclude-from="$HOME/exclude.txt" "$EMUDECKGIT/$SRM_userData_directory/parsers/emudeck/" "$SRM_userData_configDir/parsers/emudeck/"
  mkdir -p "$SRM_userData_configDir/parsers/custom"
  echo "Place your custom parsers here. After placing your parsers, reset Steam ROM Manager in the EmuDeck application. The Citra and Yuzu parsers are two examples. If you no longer want to use them, you may delete the files here and reset Steam ROM Manager in the EmuDeck application to remove them from Steam ROM Manager." > "$SRM_userData_configDir/parsers/custom/readme.txt"
  #rsync -avz --mkpath "$EMUDECKGIT/$SRM_userData_directory/parsers/emudeck/nintendo_switch-yuzu.json" "$SRM_userData_configDir/parsers/custom"
  #rsync -avz --mkpath "$EMUDECKGIT/$SRM_userData_directory/parsers/emudeck/nintendo_3ds-citra.json" "$SRM_userData_configDir/parsers/custom"
  rsync -avhp --mkpath "$EMUDECKGIT/$SRM_userData_directory/userSettings.json" "$SRM_userData_configDir/" --backup --suffix=.bak

  cp "$SRM_userData_configDir/userConfigurations.json" "$SRM_userData_configDir/userConfigurations.bak"

  rm -rf "$HOME/exclude.txt"

  # jq -s '.' $(find "\"$json_directory"\" -name "*.json" | sort) > "$output_file"
  rm -rf "$HOME/temp_parser"
  ln -s "$json_directory" "$HOME/temp_parser"
  files=$(find "$HOME/temp_parser/emudeck" -name "*.json" | sort)
  customfiles=""
  if [ -d "$SRM_userData_configDir/parsers/custom/" ]; then
    customfiles=$(find "$SRM_userData_configDir/parsers/custom/" -name "*.json" | sort)
  fi
  jq -s '.' $files $customfiles > "$output_file"
  rm -rf "$HOME/temp_parser"

  sed -i "s|/run/media/mmcblk0p1/Emulation/tools|${toolsPath}|g" "$output_file"
  sed -i "s|/run/media/mmcblk0p1/Emulation/storage|${storagePath}|g" "$output_file"
  sed -i "s|/run/media/mmcblk0p1/Emulation/|${emulationPath}|g" "$output_file"
  sed -i "s|/home/deck|$HOME|g" "$output_file"

}

SRM_addSteamInputProfiles(){
   setMSG 'Steam Rom Manager - Adding Steam input profiles'
   cp "$EMUDECKGIT/$SRM_userData_directory/controllerTemplates.json" "$SRM_userData_configDir/controllerTemplates.json"
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

  sed -i "s|/home/deck|$HOME|g" "$SRM_userData_configDir/userSettings.json"
  sed -i "s|/run/media/mmcblk0p1/Emulation/roms|${romsPath}|g" "$SRM_userData_configDir/userSettings.json"
  sed -i "s|/run/media/mmcblk0p1/Emulation/tools|${toolsPath}|g" "$SRM_userData_configDir/userSettings.json"


}

SRM_resetConfig(){
  SRM_migration
  SRM_init
  #Reseting launchers
  SRM_resetLaunchers
  SRM_flushToolLauncher
  echo "true"
}

SRM_IsInstalled(){

  if [ -f "$SRM_toolPath" ]; then
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

SRM_flushToolLauncher(){
  mkdir -p "$toolsPath/launchers/srm"
	cp "$EMUDECKGIT/tools/launchers/srm/steamrommanager.sh" "$toolsPath/launchers/srm/steamrommanager.sh"
  chmod +x "$toolsPath/launchers/srm/steamrommanager.sh"
}