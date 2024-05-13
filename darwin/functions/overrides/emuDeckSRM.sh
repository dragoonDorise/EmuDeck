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

SRM_init(){
  setMSG "Configuring Steam ROM Manager"
  local json_directory="$SRM_userData_configDir/parsers"
  local output_file="$SRM_userData_configDir/userConfigurations.json"

  mkdir -p "$SRM_userData_configDir/"

  SRM_createParsers

  SRM_setEnv
  echo -e "true"
}

SRM_createParsers(){
  setMSG 'Steam Rom Manager - Creating Parsers'
  local json_directory="$SRM_userData_configDir/parsers"
  local output_file="$SRM_userData_configDir/userConfigurations.json"
  local exclusionList=""
  #Multiemulator?
  if [ "$emuMULTI" != "both" ]; then

    if [ "$emuMULTI" = "undefined" ]; then
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
    elif [ "$emuMULTI" = "ra" ]; then
      exclusionList=$exclusionList"ares/\n"
    else
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



  if [ "$doInstallBigPEmu" == "false" ] || [ "$(BigPEmu_IsInstalled)" == "false" ]; then
    exclusionList=$exclusionList"atari_jaguar-bigpemu_proton.json\n"
  fi
  if [ "$doInstallPrimeHack" == "false" ] || [ "$(Primehack_IsInstalled)" == "false" ]; then
      exclusionList=$exclusionList"nintendo_primehack.json\n"
  fi
  if [ "$doInstallRPCS3" == "false" ] || [ "$(RPCS3_IsInstalled)" == "false" ]; then
      exclusionList=$exclusionList"sony_ps3-rpcs3-extracted_iso_psn.json\n"
      exclusionList=$exclusionList"sony_ps3-rpcs3-pkg.json\n"
  fi
  if [ "$(Citra_IsInstalled)" == "false" ]; then
      exclusionList=$exclusionList"nintendo_3ds-citra.json\n"
  fi
  if [ "$doInstallDolphin" == "false" ] || [ "$(Dolphin_IsInstalled)" == "false" ]; then
      exclusionList=$exclusionList"nintendo_gc-dolphin.json\n"
      exclusionList=$exclusionList"nintendo_wii-dolphin.json\n"
  fi
  if [ "$doInstallDuck" == "false" ] || [ "$(DuckStation_IsInstalled)" == "false" ]; then
      exclusionList=$exclusionList"sony_psx-duckstation.json\n"
  fi
  if [ "$doInstallPPSSPP" == "false" ] || [ "$(PPSSPP_IsInstalled)" == "false" ]; then
      exclusionList=$exclusionList"sony_psp-ppsspp.json\n"
  fi
  if [ "$doInstallXemu" == "false" ] || [ "$(Xemu_IsInstalled)" == "false" ]; then
      exclusionList=$exclusionList"microsoft_xbox-xemu.json\n"
  fi
  if [ "$doInstallXenia" == "false" ] || [ "$(Xenia_IsInstalled)" == "false" ]; then
     exclusionList=$exclusionList"microsoft_xbox_360-xenia-xbla.json\n"
     exclusionList=$exclusionList"microsoft_xbox_360-xenia.json\n"
  fi
  if [ "$doInstallScummVM" == "false" ] || [ "$(ScummVM_IsInstalled)" == "false" ]; then
      exclusionList=$exclusionList"scumm_scummvm.json\n"
  fi
  if [ "$doInstallRMG" == "false" ] || [ "$(RMG_IsInstalled)" == "false" ]; then
      exclusionList=$exclusionList"nintendo_64-rmg.json\n"
  fi
  if [ "$doInstallmelonDS" == "false" ] || [ "$(melonDS_IsInstalled)" == "false" ]; then
      exclusionList=$exclusionList"nintendo_ds-melonds.json\n"
  fi
  if [ "$doInstallVita3K" == "false" ] || [ "$(Vita3K_IsInstalled)" == "false" ]; then
      exclusionList=$exclusionList"sony_psvita-vita3k-pkg.json\n"
  fi
  if [ "$doInstallMGBA" == "false" ] || [ "$(mGBA_IsInstalled)" == "false" ]; then
    exclusionList=$exclusionList"nintendo_gb-mGBA.json\n"
    exclusionList=$exclusionList"nintendo_gba-mgba.json\n"
    exclusionList=$exclusionList"nintendo_gbc-mgba.json\n"
  fi
  if [ "$doInstallMAME" == "false" ] || [ "$(MAME_IsInstalled)" == "false" ]; then
    exclusionList=$exclusionList"arcade-mame.json\n"
  fi
  if [ "$(Yuzu_IsInstalled)" == "false" ]; then
    exclusionList=$exclusionList"nintendo_switch-yuzu.json\n"
  fi
  if [ "$doInstallRyujinx" == "false" ] || [ "$(Ryujinx_IsInstalled)" == "false" ]; then
    exclusionList=$exclusionList"nintendo_switch-ryujinx.json\n"
  fi
  if [ "$doInstallPCSX2QT" == "false" ] || [ "$(PCSX2QT_IsInstalled)" == "false" ]; then
    exclusionList=$exclusionList"sony_ps2-pcsx2.json\n"
  fi

  if [ "$doInstallSupermodel" == "false" ] || [ "$(Supermodel_IsInstalled)" == "false" ]; then
    exclusionList=$exclusionList"sega_model_3-supermodel.json\n"
  fi

  if [ "$doInstallModel2" == "false" ] || [ "$(Model2_IsInstalled)" == "false" ]; then
    exclusionList=$exclusionList"sega_model2-model2emulator.json\n"
  fi

  if [ "$doInstallBigPEmu" == "false" ] || [ "$(BigPEmu_IsInstalled)" == "false" ]; then
    exclusionList=$exclusionList"atari_jaguar-bigpemu_proton.json\n"
  fi

  echo -e $exclusionList > "$HOME/exclude.txt"

  rm -rf "$SRM_userData_configDir/parsers/emudeck/"

  rsync -avz --mkpath --exclude-from="$HOME/exclude.txt" "$EMUDECKGIT/$SRM_userData_directory/parsers/emudeck/" "$SRM_userData_configDir/parsers/emudeck/"
  mkdir -p "$SRM_userData_configDir/parsers/custom"
  echo "Place your custom parsers here. After placing your parsers, reset Steam ROM Manager in the EmuDeck application. The Citra and Yuzu parsers are two examples. If you no longer want to use them, you may delete the files here and reset Steam ROM Manager in the EmuDeck application to remove them from Steam ROM Manager." > "$SRM_userData_configDir/parsers/custom/readme.txt"
  rsync -avz --mkpath "$EMUDECKGIT/$SRM_userData_directory/parsers/emudeck/nintendo_switch-yuzu.json" "$SRM_userData_configDir/parsers/custom"
  rsync -avz --mkpath "$EMUDECKGIT/$SRM_userData_directory/parsers/emudeck/nintendo_3ds-citra.json" "$SRM_userData_configDir/parsers/custom"
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
  sed -i "s|/home/deck|$HOME|g" "$output_file"

}