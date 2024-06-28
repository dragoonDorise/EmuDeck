#!/bin/bash
#variables
RetroArch_emuName="RetroArch"
RetroArch_emuType="$emuDeckEmuTypeFlatpak"
RetroArch_emuPath="org.libretro.RetroArch"
RetroArch_releaseURL=""
RetroArch_path="$HOME/.var/app/org.libretro.RetroArch/config/retroarch"
RetroArch_configFile="$HOME/.var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg"
RetroArch_coreConfigFolders="$HOME/.var/app/org.libretro.RetroArch/config/retroarch/config"
RetroArch_cores="$HOME/.var/app/org.libretro.RetroArch/config/retroarch/cores"
RetroArch_remapsDir="$HOME/.var/app/org.libretro.RetroArch/config/retroarch/config/remaps"
RetroArch_overlaysPath="~/.var/app/org.libretro.RetroArch/config/retroarch/overlays"
RetroArch_videoPath="/app/lib/retroarch/filters/video"

RetroArch_coresURL="https://buildbot.libretro.com/nightly/linux/x86_64/latest/"
RetroArch_coresExtension="so.zip"
RetroArch_assetsURL="https://buildbot.libretro.com/assets/frontend/assets.zip"
RetroArch_shaderscgURL="https://buildbot.libretro.com/assets/frontend/shaders_cg.zip"
RetroArch_shadersglslURL="https://buildbot.libretro.com/assets/frontend/shaders_glsl.zip"
RetroArch_shadersslangURL="https://buildbot.libretro.com/assets/frontend/shaders_slang.zip"
RetroArch_infoURL="https://buildbot.libretro.com/assets/frontend/info.zip"
RetroArch_ppssppURL="https://buildbot.libretro.com/assets/system/PPSSPP.zip"
RetroArch_autoconfigURL="https://buildbot.libretro.com/assets/frontend/autoconfig.zip"
RetroArch_overlaysURL="https://buildbot.libretro.com/assets/frontend/overlays.zip"
RetroArch_cheatsURL="https://buildbot.libretro.com/assets/frontend/cheats.zip"

#cleanupOlderThings
RetroArch_cleanup(){
	echo "NYI"
}

RetroArch_backupConfigs(){
	cp -vp "$RetroArch_configFile" "$RetroArch_configFile.bak"
	find "$RetroArch_coreConfigFolders" -type f -name "*.cfg" -o -type f -name "*.opt" -o -type f -name "*.slangp" -o -type f -name "*.glslp"| while read -r backupfile
	do
		cp -vp "$backupfile" "$backupfile.bak"
	done
}

#Install
RetroArch_install(){
	setMSG "Installing $RetroArch_emuName" 
	installEmuFP "${RetroArch_emuName}" "${RetroArch_emuPath}" "emulator" ""
	RetroArch_installCores
}


#Fix for autoupdate
Retroarch_install(){
	RetroArch_install
}

#ApplyInitialSettings
RetroArch_init(){

	#netPlay
	setSetting netplayCMD "' '"

	setMSG "RetroArch - HD Texture Packs"

	setMSG "RetroArch - FullScreen"
	RetroArch_setConfigOverride 'video_fullscreen' "true" "$RetroArch_configFile"
	RetroArch_setConfigOverride 'video_windowed_fullscreen' "true" "$RetroArch_configFile"

	#NES
	unlink "$emulationPath"/hdpacks/Mesen 2>/dev/null #refresh link if moved
	ln -s "$biosPath"/HdPacks/ "$emulationPath"/hdpacks/nes
	echo "Put your Mesen HD Packs here. Remember to put the pack inside a folder here with the exact name of the rom" > "$emulationPath"/hdpacks/nes/readme.txt

	RetroArch_backupConfigs
	configEmuFP "${RetroArch_emuName}" "${RetroArch_emuPath}" "true"
	updateEmuFP "${RetroArch_emuName}" "${RetroArch_emuPath}" "emulator"
	RetroArch_setEmulationFolder
	RetroArch_setupSaves
	RetroArch_setupStorage
	#RetroArch_installCores
	RetroArch_setUpCoreOptAll
	RetroArch_setConfigAll
	RetroArch_setupConfigurations
	RetroArch_setCustomizations
	RetroArch_autoSave
	RetroArch_setRetroAchievements
	RetroArch_melonDSDSMigration
	RetroArch_buildbotDownloader
	#SRM_createParsers
	RetroArch_flushEmulatorLauncher
	mkdir -p "$biosPath/mame/bios"
	mkdir -p "$biosPath/dc"
	mkdir -p "$biosPath/neocd"

	echo  "Put your MAME bios here" > "$biosPath/mame/bios/readme.txt"
	echo  "Put your Dreamcast bios here" > "$biosPath/dc/readme.txt"
	echo  "Put your Neo Geo CD bios here" > "$biosPath/neocd/readme.txt"
	echo  "# Where to put your bios?" > "$biosPath/readme.txt"
	echo  "First of all, don't create any new subdirectory. ***" >> "$biosPath/readme.txt"
	echo  "# System -> folder" > "$biosPath/readme.txt"
	echo  "Playstation 1 / Duckstation -> bios/" >> "$biosPath/readme.txt"
	echo  "Playstation 2 / PCSX2 -> bios/" >> "$biosPath/readme.txt"
	echo  "Nintendo DS / melonDS -> bios/" >> "$biosPath/readme.txt"
	echo  "Playstation 3 / RPCS3 -> Download it from https://www.playstation.com/en-us/support/hardware/ps3/system-software/" >> "$biosPath/readme.txt"
	echo  "Dreamcast / RetroArch -> bios/dc" >> "$biosPath/readme.txt"
	echo  "Switch / Yuzu -> bios/yuzu/firmware and bios/yuzu/keys" >> "$biosPath/readme.txt"
	echo  "Those are the only mandatory bios, the rest are optional" >> "$biosPath/readme.txt"

}



RetroArch_setCustomizations(){
	# User customizations
	RetroArch_setShadersCRT
	RetroArch_setShaders3DCRT
	RetroArch_setShadersMAT
	RetroArch_setBezels

	#
	#New Aspect Ratios
	#

	#Sega Games
		#Master System
		#Genesis
		#Sega CD
		#Sega 32X

	case $arSega in
	  "32")
		RetroArch_mastersystem_ar32
		RetroArch_genesis_ar32
		RetroArch_segacd_ar32
		  RetroArch_sega32x_ar32
		;;
	  *)
		RetroArch_mastersystem_ar43
		RetroArch_genesis_ar43
		  RetroArch_segacd_ar43
		  RetroArch_sega32x_ar43
		  if [ "$RABezels" == "true" ] && [ "$doSetupRA" == "true" ]; then
			  RetroArch_mastersystem_bezelOn
			  RetroArch_genesis_bezelOn
			  RetroArch_segacd_bezelOn
			  RetroArch_sega32x_bezelOn
		fi
	  ;;
	esac

	#Snes and NES
	case $arSnes in
	  "87")
		RetroArch_snes_ar87
		RetroArch_nes_ar87
	  ;;
	  "32")
			RetroArch_snes_ar32
		  RetroArch_nes_ar32
		;;
	  *)
		RetroArch_snes_ar43
		RetroArch_nes_ar43
		if [ "$RABezels" == "true" ] && [ "$doSetupRA" == "true" ]; then
			RetroArch_snes_bezelOn
		fi
	  ;;
	esac
	# Classic 3D Games
		#Dreamcast
		#PSX
		#Nintendo 64
		#Saturn
		#Xbox
	if [ "$arClassic3D" == 169 ]; then
			RetroArch_Beetle_PSX_HW_wideScreenOn
			RetroArch_Flycast_wideScreenOn
			RetroArch_dreamcast_bezelOff
			RetroArch_psx_bezelOff
			RetroArch_n64_wideScreenOn
			RetroArch_SwanStation_wideScreenOn
	else
			RetroArch_Flycast_wideScreenOff
			RetroArch_n64_wideScreenOff
			RetroArch_Beetle_PSX_HW_wideScreenOff
			RetroArch_SwanStation_wideScreenOff
		#"Bezels on"
		if [ "$RABezels" == "true" ]; then
			RetroArch_dreamcast_bezelOn
			RetroArch_n64_bezelOn
			RetroArch_psx_bezelOn
		fi
	fi
}

RetroArch_setRetroAchievements(){
	#RetroAchievments
	RetroArch_retroAchievementsSetLogin
	if [ "$achievementsHardcore" == "true" ]; then
		RetroArch_retroAchievementsHardCoreOn
	else
		RetroArch_retroAchievementsHardCoreOff
	fi
}



#update
RetroArch_update(){
	setMSG "Updating $RetroArch_emuName settings."
	RetroArch_backupConfigs
	configEmuFP "${RetroArch_emuName}" "${RetroArch_emuPath}"
	updateEmuFP "${RetroArch_emuName}" "${RetroArch_emuPath}" "emulator" ""
	RetroArch_setEmulationFolder
	RetroArch_setupSaves
	RetroArch_setupStorage
	 RetroArch_setupConfigurations
	RetroArch_installCores
	RetroArch_setUpCoreOptAll
	RetroArch_setConfigAll
	RetroArch_melonDSDSMigration
	RetroArch_buildbotDownloader
	RetroArch_flushEmulatorLauncher
}


#ConfigurePaths
RetroArch_setEmulationFolder(){
	setMSG "Setting $RetroArch_emuName Emulation Folder"

	RetroArch_setConfigOverride 'system_directory' "\"${biosPath}\"" "$RetroArch_configFile"
	RetroArch_setConfigOverride 'rgui_browser_directory' "\"${romsPath}\"" "$RetroArch_configFile"
	RetroArch_setConfigOverride 'cheat_database_path' "\"${storagePath}/retroarch/cheats\"" "$RetroArch_configFile"
}

#SetupSaves
RetroArch_setupSaves(){

	linkToSaveFolder retroarch states "$RetroArch_path/states"
	linkToSaveFolder retroarch saves "$RetroArch_path/saves"

	RetroArch_setConfigOverride 'savestate_directory'  "\"$savesPath/retroarch/states\"" "$RetroArch_configFile"
	RetroArch_setConfigOverride 'savefile_directory'  "\"$savesPath/retroarch/saves\"" "$RetroArch_configFile"

}


#SetupStorage
RetroArch_setupStorage(){
	RetroArch_Mupen64Plus_Next_setUpHdPacks
	rsync -a --ignore-existing '/var/lib/flatpak/app/org.libretro.RetroArch/current/active/files/share/libretro/database/cht/' "$storagePath/retroarch/cheats"
}

#SetupConfigurations
RetroArch_setupConfigurations(){

	# Set input driver to SDL. X input driver does not seem to work ootb on some non-SteamOS distributions including ChimeraOS.
	input_driver='input_driver = '
	input_driverSetting="${input_driver}"\""sdl"\"
	changeLine "$input_driver" "$input_driverSetting" "$RetroArch_configFile"

	# Set microphone driver to SDL. Potentially fixes RetroArch hanging when closing content.
	microphone_driver='microphone_driver = '
	microphone_driverSetting="${microphone_driver}"\""sdl"\"
	changeLine "$microphone_driver" "$microphone_driverSetting" "$RetroArch_configFile"

}

RetroArch_buildbotDownloader(){

	local shadersDir="$HOME/.var/app/org.libretro.RetroArch/config/retroarch/shaders"
	local shaderscgDir="$HOME/.var/app/org.libretro.RetroArch/config/retroarch/shaders/shaders_cg"
	local shadersglslDir="$HOME/.var/app/org.libretro.RetroArch/config/retroarch/shaders/shaders_glsl"
	local shadersslangDir="$HOME/.var/app/org.libretro.RetroArch/config/retroarch/shaders/shaders_slang"
	local assetsDir="$HOME/.var/app/org.libretro.RetroArch/config/retroarch/assets"
	local autoconfigDir="$HOME/.var/app/org.libretro.RetroArch/config/retroarch/autoconfig"
	local overlaysDir="$HOME/.var/app/org.libretro.RetroArch/config/retroarch/overlays"
	local infoDir="$HOME/.var/app/org.libretro.RetroArch/config/retroarch/info"
	local ppssppDir="$biosPath/PPSSPP"
	local cheatsDir="$storagePath/retroarch/cheats"

	# Make folders
	mkdir -p $shadersDir
	mkdir -p $shaderscgDir
	mkdir -p $shadersglslDir
	mkdir -p $shadersslangDir
	mkdir -p $assetsDir
	mkdir -p $autoconfigDir
	mkdir -p $overlaysDir
	mkdir -p $infoDir
	mkdir -p $ppssppDir
	mkdir -p $cheatsDir

	# Common Shaders
	if [[ ! "$( ls -A $shaderscgDir)" ]] ; then
		{ curl -L "$RetroArch_shaderscgURL" -o "$shaderscgDir/shaders_cg.zip" && nice -n 5 unzip -q -o "$shaderscgDir/shaders_cg.zip" -d "$shaderscgDir" && rm "$shaderscgDir/shaders_cg.zip"; } &> /dev/null
	fi

	# GLSL Shaders
	if [[ ! "$( ls -A "$shadersglslDir")" ]] ; then
		{ curl -L "$RetroArch_shadersglslURL" -o "$shadersglslDir/shaders_glsl.zip" && nice -n 5 unzip -q -o "$shadersglslDir/shaders_glsl.zip" -d "$shadersglslDir" && rm "$shadersglslDir/shaders_glsl.zip"; } &> /dev/null

	fi

	# Slang Shaders
	if [[ ! "$( ls -A "$shadersslangDir")" ]] ; then
		{ curl -L "$RetroArch_shadersslangURL" -o "$shadersslangDir/shaders_glsl.zip" && nice -n 5 unzip -q -o "$shadersslangDir/shaders_glsl.zip" -d "$shadersslangDir" && rm "$shadersslangDir/shaders_glsl.zip"; } &> /dev/null

	fi

	# Assets
	if  [[ ! "$( ls -A "$assetsDir")" ]] ; then
		{ curl -L "$RetroArch_assetsURL" -o "$assetsDir/assets.zip" && nice -n 5 unzip -q -o "$assetsDir/assets.zip" -d "$assetsDir" && rm "$assetsDir/assets.zip"; } &> /dev/null

	fi

	# Overlays
	if [[ ! "$( ls -A "$overlaysDir/borders")" ]] ; then
		{ curl -L "$RetroArch_overlaysURL" -o "$overlaysDir/overlays.zip" && nice -n 5 unzip -q -o "$overlaysDir/overlays.zip" -d "$overlaysDir" && rm "$overlaysDir/overlays.zip"; } &> /dev/null

	fi

	# Autoconfig - for controllers (primarily helps non-Steam Deck setups)
	if [[ ! "$( ls -A "$autoconfigDir")" ]] ; then
		{ curl -L "$RetroArch_autoconfigURL" -o "$autoconfigDir/autoconfig.zip" && nice -n 5 unzip -q -o "$autoconfigDir/autoconfig.zip" -d "$autoconfigDir" && rm "$autoconfigDir/autoconfig.zip"; } &> /dev/null

	fi

	# Info
	if [[ ! "$( ls -A "$infoDir")" ]] ; then
		{ curl -L "$RetroArch_infoURL" -o "$infoDir/info.zip" && nice -n 5 unzip -q -o "$infoDir/info.zip" -d "$infoDir" && rm "$infoDir/info.zip"; } &> /dev/null

	fi

	# Cheats
	if [[ ! "$( ls -A "$cheatsDir")" ]] ; then
		{ curl -L "$RetroArch_cheatsURL" -o "$cheatsDir/cheats.zip" && nice -n 5 unzip -q -o "$cheatsDir/cheats.zip" -d "$cheatsDir" && rm "$cheatsDir/cheats.zip"; } &> /dev/null

	fi


	# PPSSPP
	if  [[ ! "$( ls -A "$ppssppDir")" ]] ; then
		{ curl -L "$RetroArch_ppssppURL" -o "$biosPath/PPSSPP.zip" && nice -n 5 unzip -q -o "$biosPath/PPSSPP.zip" -d "$biosPath" && rm "$biosPath/PPSSPP.zip"; } &> /dev/null

	fi


}

#WipeSettings
RetroArch_wipe(){
   rm -rf "$HOME/.var/app/$RetroArch_emuPath"
   # prob not cause roms are here
}


#Uninstall
RetroArch_uninstall(){
	uninstallEmuFP "${RetroArch_emuName}" "${RetroArch_emuPath}" "emulator" ""
}

#setABXYstyle
RetroArch_setABXYstyle(){
	mv "$RetroArch_remapsDir/mGBA/mGBA.rmp.disabled" "$RetroArch_remapsDir/mGBA/mGBA.rmp"
	mv "$RetroArch_remapsDir/Gambatte/Gambatte.rmp.disabled" "$RetroArch_remapsDir/Gambatte/Gambatte.rmp"
	mv "$RetroArch_remapsDir/bsnes-hd beta/bsnes-hd beta.rmp.disabled" "$RetroArch_remapsDir/bsnes-hd beta/bsnes-hd beta.rmp"
	mv "$RetroArch_remapsDir/melonDS DS/melonDS DS.rmp.disabled" "$RetroArch_remapsDir/melonDS DS/melonDS DS.rmp"
	mv "$RetroArch_remapsDir/Mupen64Plus-Next/Mupen64Plus-Next.rmp.disabled" "$RetroArch_remapsDir/Mupen64Plus-Next/Mupen64Plus-Next.rmp"
	mv "$RetroArch_remapsDir/SameBoy/SameBoy.rmp.disabled" "$RetroArch_remapsDir/SameBoy/SameBoy.rmp"
	mv "$RetroArch_remapsDir/Snes9x/Snes9x.rmp.disabled" "$RetroArch_remapsDir/Snes9x/Snes9x.rmp"
	mv "$RetroArch_remapsDir/Mesen/Mesen.rmp.disabled" "$RetroArch_remapsDir/Mesen/Mesen.rmp"
	mv "$RetroArch_remapsDir/Nestopia/Nestopia.rmp.disabled" "$RetroArch_remapsDir/Nestopia/Nestopia.rmp"
	mv "$RetroArch_remapsDir/Beetle VB/Beetle VB.rmp.disabled" "$RetroArch_remapsDir/Beetle VB/Beetle VB.rmp"

}
RetroArch_setBAYXstyle(){
	mv "$RetroArch_remapsDir/mGBA/mGBA.rmp" "$RetroArch_remapsDir/mGBA/mGBA.rmp.disabled"
	mv "$RetroArch_remapsDir/Gambatte/Gambatte.rmp" "$RetroArch_remapsDir/Gambatte/Gambatte.rmp.disabled"
	mv "$RetroArch_remapsDir/bsnes-hd beta/bsnes-hd beta.rmp" "$RetroArch_remapsDir/bsnes-hd beta/bsnes-hd beta.rmp.disabled"
	mv "$RetroArch_remapsDir/melonDS DS/melonDS DS.rmp" "$RetroArch_remapsDir/melonDS DS/melonDS DS.rmp.disabled"
	mv "$RetroArch_remapsDir/Mupen64Plus-Next/Mupen64Plus-Next.rmp" "$RetroArch_remapsDir/Mupen64Plus-Next/Mupen64Plus-Next.rmp.disabled"
	mv "$RetroArch_remapsDir/SameBoy/SameBoy.rmp" "$RetroArch_remapsDir/SameBoy/SameBoy.rmp.disabled"
	mv "$RetroArch_remapsDir/Snes9x/Snes9x.rmp" "$RetroArch_remapsDir/Snes9x/Snes9x.rmp.disabled"
	mv "$RetroArch_remapsDir/Mesen/Mesen.rmp" "$RetroArch_remapsDir/Mesen/Mesen.rmp.disabled"
	mv "$RetroArch_remapsDir/Beetle VB/Beetle VB.rmp" mv "$RetroArch_remapsDir/Beetle VB/Beetle VB.rmp.disabled"
}

#Migrate
RetroArch_migrate(){
	echo "NYI"
}

#WideScreenOn
RetroArch_wideScreenOn(){
echo "NYI"
}

#WideScreenOff
RetroArch_wideScreenOff(){
echo "NYI"
}

RetroArch_setOverride(){
	local fileName=$1
	local coreName=$2
	local option=$3
	local value=$4
	local settingLine="$option = $value"
	local fullPath="$RetroArch_coreConfigFolders/$coreName"
	local configFile="$fullPath/$fileName"

	if [[ $value == 'ED_RM_LINE' ]]; then
		echo "Deleting $option from $configFile"
		sed -i '/^'"$option"'/d' "$configFile"
	else
		updateOrAppendConfigLine "$configFile" "$option =" "$settingLine"
	fi
}

RetroArch_setConfigOverride(){
	local option=$1
	local value=$2
	local configFile=$3
	local settingLine="$option = $value"

	if [[ $value == 'ED_RM_LINE' ]]; then
		echo "Deleting $option from $configFile"
		sed -i '/^'"$option"'/d' "$configFile"
	else
		updateOrAppendConfigLine "$configFile" "$option =" "$settingLine"
	fi
}

RetroArch_vice_xvic_setConfig(){
	RetroArch_setOverride 'xvic.cfg' 'VICE xvic'  'video_driver' '"glcore"'
}
RetroArch_vice_xscpu64_setConfig(){
	RetroArch_setOverride 'xscpu64.cfg' 'VICE xscpu64'  'video_driver' '"glcore"'
}
RetroArch_vice_x64sc_setConfig(){
	RetroArch_setOverride 'x64sc.cfg' 'VICE x64sc'  'video_driver' '"glcore"'
}
RetroArch_vice_x64_setConfig(){
	RetroArch_setOverride 'x64.cfg' 'VICE x64'  'video_driver' '"glcore"'
}

RetroArch_wswanc_setConfig(){
	RetroArch_setOverride 'wonderswancolor.cfg' 'Beetle Cygne'  'input_player1_analog_dpad_mode' '"1"'
	RetroArch_setOverride 'wonderswancolor.cfg' 'Beetle WonderSwan'  'input_player1_analog_dpad_mode' '"1"'
}
RetroArch_wswanc_bezelOn(){
	RetroArch_setOverride 'wonderswancolor.cfg' 'Beetle Cygne'  'input_overlay_enable' '"false"'
	RetroArch_setOverride 'wonderswancolor.cfg' 'Beetle WonderSwan'  'input_overlay_enable' '"false"'
}
RetroArch_wswanc_bezelOff(){
	RetroArch_setOverride 'wonderswancolor.cfg' 'Beetle Cygne'  'input_overlay_enable' '"false"'
	RetroArch_setOverride 'wonderswancolor.cfg' 'Beetle WonderSwan'  'input_overlay_enable' '"false"'
}
RetroArch_wswanc_MATshaderOn(){
	RetroArch_setOverride 'wonderswancolor.cfg' 'Beetle Cygne'  'video_shader_enable' 'true'
	RetroArch_setOverride 'wonderswancolor.cfg' 'Beetle Cygne'	'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'wonderswancolor.cfg' 'Beetle Cygne'	'video_smooth' '"false"'

	RetroArch_setOverride 'wonderswancolor.cfg' 'Beetle WonderSwan'  'video_shader_enable' 'true'
	RetroArch_setOverride 'wonderswancolor.cfg' 'Beetle WonderSwan'	 'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'wonderswancolor.cfg' 'Beetle WonderSwan'	 'video_smooth' '"false"'
}

RetroArch_wswanc_MATshaderOff(){
	RetroArch_setOverride 'wonderswancolor.cfg' 'Beetle Cygne'  'video_shader_enable' 'false'
	RetroArch_setOverride 'wonderswancolor.cfg' 'Beetle Cygne'	'video_filter' "\"$RetroArch_videoPath/Normal4x.filt\""
	RetroArch_setOverride 'wonderswancolor.cfg' 'Beetle Cygne'	'video_smooth' '"true"'

	RetroArch_setOverride 'wonderswancolor.cfg' 'Beetle WonderSwan'  'video_shader_enable' 'false'
	RetroArch_setOverride 'wonderswancolor.cfg' 'Beetle WonderSwan'	 'video_filter' "\"$RetroArch_videoPath/Normal4x.filt\""
	RetroArch_setOverride 'wonderswancolor.cfg' 'Beetle WonderSwan'	 'video_smooth' '"true"'
}

RetroArch_wswan_setConfig(){
	RetroArch_setOverride 'wonderswan.cfg' 'Beetle Cygne'  'input_player1_analog_dpad_mode' '"1"'
	RetroArch_setOverride 'wonderswan.cfg' 'Beetle WonderSwan'  'input_player1_analog_dpad_mode' '"1"'
}
RetroArch_wswan_bezelOn(){
	RetroArch_setOverride 'wonderswan.cfg' 'Beetle Cygne'  'input_overlay_enable' '"false"'
	RetroArch_setOverride 'wonderswan.cfg' 'Beetle WonderSwan'  'input_overlay_enable' '"false"'
}

RetroArch_wswan_bezelOff(){
	RetroArch_setOverride 'wonderswan.cfg' 'Beetle Cygne'  'input_overlay_enable' '"false"'
	RetroArch_setOverride 'wonderswan.cfg' 'Beetle WonderSwan'  'input_overlay_enable' '"false"'
}

RetroArch_wswan_MATshaderOn(){
	RetroArch_setOverride 'wonderswan.cfg' 'Beetle Cygne'  'video_shader_enable' 'true'
	RetroArch_setOverride 'wonderswan.cfg' 'Beetle Cygne'	'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'wonderswan.cfg' 'Beetle Cygne'	'video_smooth' '"false"'

	RetroArch_setOverride 'wonderswan.cfg' 'Beetle WonderSwan'  'video_shader_enable' 'true'
	RetroArch_setOverride 'wonderswan.cfg' 'Beetle WonderSwan'	 'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'wonderswan.cfg' 'Beetle WonderSwan'	 'video_smooth' '"false"'
}

RetroArch_wswan_MATshaderOff(){
	RetroArch_setOverride 'wonderswan.cfg' 'Beetle Cygne'  'video_shader_enable' 'false'
	RetroArch_setOverride 'wonderswan.cfg' 'Beetle Cygne'	'video_filter' "\"$RetroArch_videoPath/Normal4x.filt\""
	RetroArch_setOverride 'wonderswan.cfg' 'Beetle Cygne'	'video_smooth' '"true"'

	RetroArch_setOverride 'wonderswan.cfg' 'Beetle WonderSwan'  'video_shader_enable' 'false'
	RetroArch_setOverride 'wonderswan.cfg' 'Beetle WonderSwan'	 'video_filter' "\"$RetroArch_videoPath/Normal4x.filt\""
	RetroArch_setOverride 'wonderswan.cfg' 'Beetle WonderSwan'	 'video_smooth' '"true"'
}

RetroArch_dolphin_emu_setConfig(){
	RetroArch_setOverride 'dolphin_emu.cfg' 'dolphin_emu'  'video_driver' '"gl"'
	RetroArch_setOverride 'dolphin_emu.cfg' 'dolphin_emu'  'video_driver' '"gl"'
}

RetroArch_PPSSPP_setConfig(){
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_auto_frameskip' '"disabled"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_block_transfer_gpu' '"enabled"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_button_preference' '"Cross"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_cheats' '"disabled"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_cpu_core' '"JIT"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_disable_slow_framebuffer_effects' '"disabled"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_fast_memory' '"enabled"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_force_lag_sync' '"disabled"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_frameskip' '"Off"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_frameskiptype' '"Number'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_gpu_hardware_transform' '"enabled"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_ignore_bad_memory_access' '"enabled"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_inflight_frames' '"Up'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_internal_resolution' '"1440x816"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_io_timing_method' '"Fast"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_language' '"Automatic"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_lazy_texture_caching' '"disabled"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_locked_cpu_speed' '"off"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_lower_resolution_for_effects' '"Off"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_rendering_mode' '"Buffered"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_retain_changed_textures' '"disabled"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_software_skinning' '"enabled"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_spline_quality' '"Low"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_texture_anisotropic_filtering' '"off"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_texture_deposterize' '"disabled"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_texture_filtering' '"Auto"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_texture_replacement' '"enabled"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_texture_scaling_level' '"Off"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_texture_scaling_type' '"xbrz"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_texture_shader' '"Off"'
	RetroArch_setOverride 'psp.cfg' 'PPSSPP'  'ppsspp_vertex_cache' '"disabled"'
}

RetroArch_pcengine_setConfig(){
	RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE Fast'  'input_player1_analog_dpad_mode' '"1"'
	RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE'  'input_player1_analog_dpad_mode' '"1"'
	RetroArch_setOverride 'tg16.cfg' 'Beetle PCE Fast'  'input_player1_analog_dpad_mode' '"1"'
	RetroArch_setOverride 'tg16.cfg' 'Beetle PCE'  'input_player1_analog_dpad_mode' '"1"'
}
RetroArch_pcengine_bezelOn(){
	RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE Fast'  'aspect_ratio_index' '"21"'
	RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE Fast'  'custom_viewport_height' '"1200"'
	RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE Fast'  'custom_viewport_x' '"0"'
	RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE Fast'  'input_overlay' "\"$RetroArch_overlaysPath/pegasus/pcengine.cfg\""
	RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE Fast'  'input_overlay_aspect_adjust_landscape' '"-0.150000"'
	RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE Fast'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE Fast'  'input_overlay_scale_landscape' '"1.075000"'

	RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE'  'aspect_ratio_index' '"21"'
	RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE'  'custom_viewport_height' '"1200"'
	RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE'  'custom_viewport_x' '"0"'
	RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE'  'input_overlay' "\"$RetroArch_overlaysPath/pegasus/pcengine.cfg\""
	RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE'  'input_overlay_aspect_adjust_landscape' '"-0.150000"'
	RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE'  'input_overlay_scale_landscape' '"1.075000"'

	RetroArch_setOverride 'tg16.cfg' 'Beetle PCE Fast'  'aspect_ratio_index' '"21"'
	RetroArch_setOverride 'tg16.cfg' 'Beetle PCE Fast'  'custom_viewport_height' '"1200"'
	RetroArch_setOverride 'tg16.cfg' 'Beetle PCE Fast'  'custom_viewport_x' '"0"'
	RetroArch_setOverride 'tg16.cfg' 'Beetle PCE Fast'  'input_overlay' "\"$RetroArch_overlaysPath/pegasus/pcengine.cfg\""
	RetroArch_setOverride 'tg16.cfg' 'Beetle PCE Fast'  'input_overlay_aspect_adjust_landscape' '"-0.150000"'
	RetroArch_setOverride 'tg16.cfg' 'Beetle PCE Fast'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'tg16.cfg' 'Beetle PCE Fast'  'input_overlay_scale_landscape' '"1.075000"'

	RetroArch_setOverride 'tg16.cfg' 'Beetle PCE'  'aspect_ratio_index' '"21"'
	RetroArch_setOverride 'tg16.cfg' 'Beetle PCE'  'custom_viewport_height' '"1200"'
	RetroArch_setOverride 'tg16.cfg' 'Beetle PCE'  'custom_viewport_x' '"0"'
	RetroArch_setOverride 'tg16.cfg' 'Beetle PCE'  'input_overlay' "\"$RetroArch_overlaysPath/pegasus/pcengine.cfg\""
	RetroArch_setOverride 'tg16.cfg' 'Beetle PCE'  'input_overlay_aspect_adjust_landscape' '"-0.150000"'
	RetroArch_setOverride 'tg16.cfg' 'Beetle PCE'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'tg16.cfg' 'Beetle PCE'  'input_overlay_scale_landscape' '"1.075000"'

}

RetroArch_pcengine_bezelOff(){
	RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE Fast'  'input_overlay_enable' '"false"'
	RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE'  'input_overlay_enable' '"false"'
	RetroArch_setOverride 'tg16.cfg' 'Beetle PCE Fast'  'input_overlay_enable' '"false"'
	RetroArch_setOverride 'tg16.cfg' 'Beetle PCE'  'input_overlay_enable' '"false"'
}

RetroArch_pcengine_CRTshaderOn(){
	RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE Fast'  'video_shader_enable' '"true"'
	RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE Fast'	'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE Fast'	'video_smooth' '"false"'

	RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE'  'video_shader_enable' '"true"'
	RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE'	'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE'	'video_smooth' '"false"'

	RetroArch_setOverride 'tg16.cfg' 'Beetle PCE Fast'  'video_shader_enable' '"true"'
	RetroArch_setOverride 'tg16.cfg' 'Beetle PCE Fast'	'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'tg16.cfg' 'Beetle PCE Fast'	'video_smooth' '"false"'

	RetroArch_setOverride 'tg16.cfg' 'Beetle PCE'  'video_shader_enable' '"true"'
	RetroArch_setOverride 'tg16.cfg' 'Beetle PCE'	'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'tg16.cfg' 'Beetle PCE'	'video_smooth' '"false"'
}

RetroArch_pcengine_CRTshaderOff(){
	RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE Fast'  'video_shader_enable' '"false"'
	RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE Fast'	'video_filter' "\"$RetroArch_videoPath/Normal4x.filt\""
	RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE Fast'	'video_smooth' '"true"'

	RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE'  'video_shader_enable' '"false"'
	RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE'	'video_filter' "\"$RetroArch_videoPath/Normal4x.filt\""
	RetroArch_setOverride 'pcengine.cfg' 'Beetle PCE'	'video_smooth' '"true"'

	RetroArch_setOverride 'tg16.cfg' 'Beetle PCE Fast'  'video_shader_enable' '"false"'
	RetroArch_setOverride 'tg16.cfg' 'Beetle PCE Fast'	'video_filter' "\"$RetroArch_videoPath/Normal4x.filt\""
	RetroArch_setOverride 'tg16.cfg' 'Beetle PCE Fast'	'video_smooth' '"true"'

	RetroArch_setOverride 'tg16.cfg' 'Beetle PCE'  'video_shader_enable' '"false"'
	RetroArch_setOverride 'tg16.cfg' 'Beetle PCE'	'video_filter' "\"$RetroArch_videoPath/Normal4x.filt\""
	RetroArch_setOverride 'tg16.cfg' 'Beetle PCE'	'video_smooth' '"true"'
}

RetroArch_amiga1200_CRTshaderOff(){
	RetroArch_setOverride 'amiga1200.cfg' 'PUAE'  'video_shader_enable' '"false"'
	RetroArch_setOverride 'amiga1200.cfg' 'PUAE'  'video_filter' "\"$RetroArch_videoPath/Normal4x.filt\""
	RetroArch_setOverride 'amiga1200.cfg' 'PUAE'  'video_smooth' '"true"'
}

RetroArch_amiga1200_CRTshaderOn(){
	RetroArch_setOverride 'amiga1200.cfg' 'PUAE'  'video_shader_enable' '"true"'
	RetroArch_setOverride 'amiga1200.cfg' 'PUAE'  'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'amiga1200.cfg' 'PUAE'  'video_smooth' '"false"'
}

RetroArch_amiga1200_setUpCoreOpt(){
	RetroArch_setOverride 'amiga1200.opt' 'PUAE'  'puae_model' '"A1200"'
}

RetroArch_nes_setConfig(){
	RetroArch_setOverride 'nes.cfg' 'Mesen'  'input_player1_analog_dpad_mode' '"1"'
	RetroArch_setOverride 'nes.cfg' 'Nestopia'  'input_player1_analog_dpad_mode' '"1"'
}

RetroArch_nes_bezelOn(){
	RetroArch_setOverride 'nes.cfg' 'Mesen'  'input_overlay' "\"$RetroArch_overlaysPath/pegasus/nes.cfg\""
	RetroArch_setOverride 'nes.cfg' 'Mesen'  'input_overlay_auto_scale' '"false"'
	RetroArch_setOverride 'nes.cfg' 'Mesen'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'nes.cfg' 'Mesen'  'input_overlay_opacity' '"0.700000"'
	RetroArch_setOverride 'nes.cfg' 'Mesen'  'input_overlay_scale_landscape' '"1.070000"'
	RetroArch_setOverride 'nes.cfg' 'Mesen'  'input_overlay_aspect_adjust_landscape' '"0.100000"'
	RetroArch_setOverride 'nes.cfg' 'Mesen'  'video_scale_integer' '"false"'
	RetroArch_setOverride 'nes.cfg' 'Mesen'  'aspect_ratio_index' '"0"'



	RetroArch_setOverride 'nes.cfg' 'Nestopia'  'input_overlay' "\"$RetroArch_overlaysPath/pegasus/nes.cfg\""
	RetroArch_setOverride 'nes.cfg' 'Nestopia'  'input_overlay_auto_scale' '"false"'
	RetroArch_setOverride 'nes.cfg' 'Nestopia'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'nes.cfg' 'Nestopia'  'input_overlay_opacity' '"0.700000"'
	RetroArch_setOverride 'nes.cfg' 'Nestopia'  'input_overlay_scale_landscape' '"1.070000"'
	RetroArch_setOverride 'nes.cfg' 'Nestopia'  'input_overlay_aspect_adjust_landscape' '"0.100000"'
	RetroArch_setOverride 'nes.cfg' 'Nestopia'  'video_scale_integer' '"false"'
	RetroArch_setOverride 'nes.cfg' 'Nestopia'  'aspect_ratio_index' '"0"'

	case $arSnes in
	  "87")
		RetroArch_nes_ar87
	  ;;
	  "32")
		  RetroArch_nes_ar32
		;;
	  *)
		RetroArch_nes_ar43
	  ;;
	esac


}

RetroArch_nes_bezelOff(){
	RetroArch_setOverride 'nes.cfg' 'Nestopia'  'input_overlay_enable' '"false"'
	RetroArch_setOverride 'nes.cfg' 'Mesen'  'input_overlay_enable' '"false"'
}

RetroArch_nes_CRTshaderOn(){
	RetroArch_setOverride 'nes.cfg' 'Mesen'  'video_shader_enable' '"true"'
	RetroArch_setOverride 'nes.cfg' 'Mesen'	'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'nes.cfg' 'Mesen'	'video_smooth' '"false"'

	RetroArch_setOverride 'nes.cfg' 'Nestopia'  'video_shader_enable' '"true"'
	RetroArch_setOverride 'nes.cfg' 'Nestopia'	'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'nes.cfg' 'Nestopia'	'video_smooth' '"false"'
}

RetroArch_nes_CRTshaderOff(){
	RetroArch_setOverride 'nes.cfg' 'Mesen'  'video_shader_enable' '"false"'
	RetroArch_setOverride 'nes.cfg' 'Mesen'	'video_filter' "\"$RetroArch_videoPath/Normal4x.filt\""
	RetroArch_setOverride 'nes.cfg' 'Mesen'	'video_smooth' '"true"'

	RetroArch_setOverride 'nes.cfg' 'Nestopia'  'video_shader_enable' '"false"'
	RetroArch_setOverride 'nes.cfg' 'Nestopia'	'video_filter' "\"$RetroArch_videoPath/Normal4x.filt\""
	RetroArch_setOverride 'nes.cfg' 'Nestopia'	'video_smooth' '"true"'
}

RetroArch_nes_ar43(){
	#RetroArch_nes_bezelOn
	RetroArch_setOverride 'nes.cfg' 'Nestopia'  'aspect_ratio_index' '"0"'
	RetroArch_setOverride 'nes.cfg' 'Mesen'  'aspect_ratio_index' '"0"'
}

RetroArch_nes_ar87(){
	RetroArch_setOverride 'nes.cfg' 'Nestopia'  'input_overlay_scale_landscape' '"1.380000"'
	RetroArch_setOverride 'nes.cfg' 'Nestopia'  'input_overlay_aspect_adjust_landscape' '"-0.170000"'
	RetroArch_setOverride 'nes.cfg' 'Nestopia'  'aspect_ratio_index' '"15"'
	RetroArch_setOverride 'nes.cfg' 'Mesen'  'input_overlay_scale_landscape' '"1.380000"'
	RetroArch_setOverride 'nes.cfg' 'Mesen'  'input_overlay_aspect_adjust_landscape' '"-0.170000"'
	RetroArch_setOverride 'nes.cfg' 'Mesen'  'aspect_ratio_index' '"15"'
}

RetroArch_nes_ar32(){
	RetroArch_setOverride 'nes.cfg' 'Nestopia'  'aspect_ratio_index' '"7"'
	RetroArch_setOverride 'nes.cfg' 'Mesen'  'aspect_ratio_index' '"7"'
	RetroArch_nes_bezelOff
}

RetroArch_Mupen64Plus_Next_setConfig(){
	RetroArch_setOverride 'n64.cfg' 'Mupen64Plus-Next'  'aspect_ratio_index' '"0"'
	RetroArch_setOverride 'n64.cfg' 'Mupen64Plus-Next'  'video_crop_overscan' '"false"'
	RetroArch_setOverride 'n64.cfg' 'Mupen64Plus-Next'  'video_smooth' 'ED_RM_LINE'
	RetroArch_setOverride 'n64.cfg' 'Mupen64Plus-Next'  'video_shader_enable' '"false"'
	RetroArch_setOverride 'n64.cfg' 'Mupen64Plus-Next'  'input_overlay_auto_scale'  '"false"'
}




 RetroArch_n64_3DCRTshaderOn(){
	 RetroArch_setOverride 'n64.cfg' 'Mupen64Plus-Next'  'video_shader_enable' '"true"'
	RetroArch_setOverride 'n64.cfg' 'Mupen64Plus-Next'  'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'n64.cfg' 'Mupen64Plus-Next'  'video_smooth' 'ED_RM_LINE'
 }

RetroArch_n64_3DCRTshaderOff(){
	RetroArch_setOverride 'n64.cfg' 'Mupen64Plus-Next'  'video_shader_enable' '"false"'
	RetroArch_setOverride 'n64.cfg' 'Mupen64Plus-Next'  'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'n64.cfg' 'Mupen64Plus-Next'  'video_smooth' 'ED_RM_LINE'
}

RetroArch_n64_setConfig(){
	RetroArch_n64_3DCRTshaderOff
}

RetroArch_lynx_setConfig(){
	RetroArch_setOverride 'lynx.cfg' 'Beetle Lynx'  'input_player1_analog_dpad_mode' '"1"'
	RetroArch_setOverride 'atarilynx.cfg' 'Handy'  'input_player1_analog_dpad_mode' '"1"'
}

RetroArch_lynx_bezelOn(){
	RetroArch_setOverride 'lynx.cfg' 'Beetle Lynx'  'aspect_ratio_index' '"21"'
	RetroArch_setOverride 'lynx.cfg' 'Beetle Lynx'  'input_overlay' "\"$RetroArch_overlaysPath/pegasus/lynx.cfg\""
	RetroArch_setOverride 'lynx.cfg' 'Beetle Lynx'  'input_overlay_auto_scale' '"false"'
	RetroArch_setOverride 'lynx.cfg' 'Beetle Lynx'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'lynx.cfg' 'Beetle Lynx'  'input_overlay_opacity' '"0.700000"'
	RetroArch_setOverride 'lynx.cfg' 'Beetle Lynx'  'input_overlay_scale_landscape' '"1.170000"'
	RetroArch_setOverride 'lynx.cfg' 'Beetle Lynx'  'video_scale_integer' '"false"'

	RetroArch_setOverride 'atarilynx.cfg' 'Handy'  'aspect_ratio_index' '"21"'
	RetroArch_setOverride 'atarilynx.cfg' 'Handy'  'input_overlay' "\"$RetroArch_overlaysPath/pegasus/lynx.cfg\""
	RetroArch_setOverride 'atarilynx.cfg' 'Handy'  'input_overlay_auto_scale' '"false"'
	RetroArch_setOverride 'atarilynx.cfg' 'Handy'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'atarilynx.cfg' 'Handy'  'input_overlay_opacity' '"0.700000"'
	RetroArch_setOverride 'atarilynx.cfg' 'Handy'  'input_overlay_scale_landscape' '"1.170000"'
	RetroArch_setOverride 'atarilynx.cfg' 'Handy'  'video_scale_integer' '"false"'
}

RetroArch_lynx_bezelOff(){
	RetroArch_setOverride 'lynx.cfg' 'Beetle Lynx'  'input_overlay_enable' '"false"'
	RetroArch_setOverride 'atarilynx.cfg' 'Handy'  'input_overlay_enable' '"false"'
}

RetroArch_lynx_MATshaderOn(){
	RetroArch_setOverride 'lynx.cfg' 'Beetle Lynx'  'video_shader_enable' 'true'
	RetroArch_setOverride 'lynx.cfg' 'Beetle Lynx'	'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'lynx.cfg' 'Beetle Lynx'	'video_smooth' '"false"'

	RetroArch_setOverride 'atarilynx.cfg' 'Handy'  'video_shader_enable' 'true'
	RetroArch_setOverride 'atarilynx.cfg' 'Handy'	'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'atarilynx.cfg' 'Handy'	'video_smooth' '"false"'
}

RetroArch_lynx_MATshaderOff(){
	RetroArch_setOverride 'lynx.cfg' 'Beetle Lynx'  'video_shader_enable' 'false'
	RetroArch_setOverride 'lynx.cfg' 'Beetle Lynx'	'video_filter' "\"$RetroArch_videoPath/Normal4x.filt\""
	RetroArch_setOverride 'lynx.cfg' 'Beetle Lynx'	'video_smooth' '"true"'

	RetroArch_setOverride 'atarilynx.cfg' 'Handy'  'video_shader_enable' 'false'
	RetroArch_setOverride 'atarilynx.cfg' 'Handy'	'video_filter' "\"$RetroArch_videoPath/Normal4x.filt\""
	RetroArch_setOverride 'atarilynx.cfg' 'Handy'	'video_smooth' '"true"'
}


RetroArch_SameBoy_gb_setConfig(){
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'input_player1_analog_dpad_mode' '"1"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_dark_filter_level' '"0"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_bootloader' '"enabled"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_colorization' '"internal"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_hwmode' '"Auto"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_internal_palette' '"GB'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_mode' '"Not'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_port' '"56400"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_server_ip_1' '"0"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_server_ip_10' '"0"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_server_ip_11' '"0"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_server_ip_12' '"0"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_server_ip_2' '"0"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_server_ip_3' '"0"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_server_ip_4' '"0"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_server_ip_5' '"0"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_server_ip_6' '"0"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_server_ip_7' '"0"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_server_ip_8' '"0"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_link_network_server_ip_9' '"0"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_palette_twb64_1' '"TWB64'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_gb_palette_twb64_2' '"TWB64'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_mix_frames' '"disabled"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_rumble_level' '"10"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_show_gb_link_settings' '"disabled"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_turbo_period' '"4"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'gambatte_up_down_allowed' '"disabled"'
}

RetroArch_ngp_setConfig(){
	RetroArch_setOverride 'ngp.cfg' 'Beetle NeoPop'  'input_player1_analog_dpad_mode' '"1"'
}

RetroArch_ngp_bezelOn(){
	RetroArch_setOverride 'ngp.cfg' 'Beetle NeoPop'  'aspect_ratio_index' '"21"'
	RetroArch_setOverride 'ngp.cfg' 'Beetle NeoPop'  'input_overlay' "\"$RetroArch_overlaysPath/pegasus/ngpc.cfg\""
	RetroArch_setOverride 'ngp.cfg' 'Beetle NeoPop'  'input_overlay_aspect_adjust_landscape' '"-0.310000"'
	RetroArch_setOverride 'ngp.cfg' 'Beetle NeoPop'  'input_overlay_auto_scale' '"false"'
	RetroArch_setOverride 'ngp.cfg' 'Beetle NeoPop'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'ngp.cfg' 'Beetle NeoPop'  'input_overlay_hide_in_menu' '"false"'
	RetroArch_setOverride 'ngp.cfg' 'Beetle NeoPop'  'input_overlay_scale_landscape' '"1.625000"'
	RetroArch_setOverride 'ngp.cfg' 'Beetle NeoPop'  'input_overlay_x_separation_portrait' '"-0.010000"'
	RetroArch_setOverride 'ngp.cfg' 'Beetle NeoPop'  'input_overlay_y_offset_landscape' '"-0.135000"'
}

RetroArch_ngp_bezelOff(){
	RetroArch_setOverride 'ngp.cfg' 'Beetle NeoPop'  'input_overlay_enable' '"false"'
}

RetroArch_ngp_MATshaderOn(){
	RetroArch_setOverride 'ngp.cfg' 'Beetle NeoPop'  'video_shader_enable' 'true'
	RetroArch_setOverride 'ngp.cfg' 'Beetle NeoPop'	 'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'ngp.cfg' 'Beetle NeoPop'	 'video_smooth' '"false"'
}

RetroArch_ngp_MATshaderOff(){
	RetroArch_setOverride 'ngp.cfg' 'Beetle NeoPop'  'video_shader_enable' 'false'
	RetroArch_setOverride 'ngp.cfg' 'Beetle NeoPop'	 'video_filter' "\"$RetroArch_videoPath/Normal4x.filt\""
	RetroArch_setOverride 'ngp.cfg' 'Beetle NeoPop'	 'video_smooth' '"true"'
}

RetroArch_ngpc_setConfig(){
	RetroArch_setOverride 'ngpc.cfg' 'Beetle NeoPop'  'input_player1_analog_dpad_mode' '"1"'
}

RetroArch_ngpc_bezelOn(){
	RetroArch_setOverride 'ngpc.cfg' 'Beetle NeoPop'  'aspect_ratio_index' '"21"'
	RetroArch_setOverride 'ngpc.cfg' 'Beetle NeoPop'  'input_overlay' "\"$RetroArch_overlaysPath/pegasus/ngpc.cfg\""
	RetroArch_setOverride 'ngpc.cfg' 'Beetle NeoPop'  'input_overlay_aspect_adjust_landscape' '"-0.170000"'
	RetroArch_setOverride 'ngpc.cfg' 'Beetle NeoPop'  'input_overlay_auto_scale' '"false"'
	RetroArch_setOverride 'ngpc.cfg' 'Beetle NeoPop'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'ngpc.cfg' 'Beetle NeoPop'  'input_overlay_scale_landscape' '"1.615000"'
	RetroArch_setOverride 'ngpc.cfg' 'Beetle NeoPop'  'input_overlay_x_separation_portrait' '"-0.010000"'
	RetroArch_setOverride 'ngpc.cfg' 'Beetle NeoPop'  'input_overlay_y_offset_landscape' '"-0.135000"'
}

RetroArch_ngpc_bezelOff(){
	RetroArch_setOverride 'ngpc.cfg' 'Beetle NeoPop'  'input_overlay_enable' '"false"'
}

RetroArch_ngpc_MATshaderOn(){
	RetroArch_setOverride 'ngpc.cfg' 'Beetle NeoPop'  'video_shader_enable' 'true'
	RetroArch_setOverride 'ngpc.cfg' 'Beetle NeoPop'  'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'ngpc.cfg' 'Beetle NeoPop'  'video_smooth' '"false"'
}

RetroArch_ngpc_MATshaderOff(){
	RetroArch_setOverride 'ngpc.cfg' 'Beetle NeoPop'  'video_shader_enable' 'false'
	RetroArch_setOverride 'ngpc.cfg' 'Beetle NeoPop'  'video_filter' "\"$RetroArch_videoPath/Normal4x.filt\""
	RetroArch_setOverride 'ngpc.cfg' 'Beetle NeoPop'  'video_smooth' '"true"'
}

RetroArch_atari2600_setConfig(){
	RetroArch_setOverride 'atari2600.cfg' 'Stella'  'input_player1_analog_dpad_mode' '"1"'
}

RetroArch_atari2600_bezelOn(){
	RetroArch_setOverride 'atari2600.cfg' 'Stella'  'input_overlay' "\"$RetroArch_overlaysPath/pegasus/atari2600.cfg\""
	RetroArch_setOverride 'atari2600.cfg' 'Stella'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'atari2600.cfg' 'Stella'  'input_overlay_aspect_adjust_landscape' '"0.095000"'
	RetroArch_setOverride 'atari2600.cfg' 'Stella'  'input_overlay_scale_landscape' '"1.070000"'
	RetroArch_setOverride 'atari2600.cfg' 'Stella'  'aspect_ratio_index' '"0"'
}

RetroArch_atari2600_bezelOff(){
	RetroArch_setOverride 'atari2600.cfg' 'Stella' 'input_overlay_enable' '"false"'
}

RetroArch_atari2600_CRTshaderOn(){
	RetroArch_setOverride 'atari2600.cfg' 'Stella' 'video_shader_enable' 'true'
	RetroArch_setOverride 'atari2600.cfg' 'Stella'	'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'atari2600.cfg' 'Stella'	'video_smooth' '"false"'
}

RetroArch_atari2600_CRTshaderOff(){
	RetroArch_setOverride 'atari2600.cfg' 'Stella' 'video_shader_enable' '"false"'
	RetroArch_setOverride 'atari2600.cfg' 'Stella'	'video_filter' "\"$RetroArch_videoPath/Normal4x.filt\""
	RetroArch_setOverride 'atari2600.cfg' 'Stella'	'video_smooth' '"true"'
}

RetroArch_mame_setConfig(){
	RetroArch_setOverride 'mame.cfg' 'MAME 2003-Plus'  'input_player1_analog_dpad_mode' '"1"'
	RetroArch_setOverride 'mame.cfg' 'MAME'  'input_player1_analog_dpad_mode' '"1"'
	RetroArch_setOverride 'mame.cfg' 'MAME'  'cheevos_enable = "false"'
}

RetroArch_mame_bezelOn(){
	RetroArch_setOverride 'mame.cfg' 'MAME 2003-Plus'  'input_overlay_enable' '"false"'
	RetroArch_setOverride 'mame.cfg' 'MAME'  'input_overlay_enable' '"false"'
}

RetroArch_mame_bezelOff(){
	RetroArch_setOverride 'mame.cfg' 'MAME 2003-Plus'  'input_overlay_enable' '"false"'
	RetroArch_setOverride 'mame.cfg' 'MAME'  'input_overlay_enable' '"false"'
}

RetroArch_mame_CRTshaderOn(){
	RetroArch_setOverride 'mame.cfg' 'MAME 2003-Plus'  'video_shader_enable' 'true'
	RetroArch_setOverride 'mame.cfg' 'MAME 2003-Plus'   'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'mame.cfg' 'MAME 2003-Plus'	'video_smooth' '"false"'

	RetroArch_setOverride 'mame.cfg' 'MAME' 'video_shader_enable' 'true'
	RetroArch_setOverride 'mame.cfg' 'MAME'	'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'mame.cfg' 'MAME'	'video_smooth' '"false"'
}

RetroArch_mame_CRTshaderOff(){
	RetroArch_setOverride 'mame.cfg' 'MAME 2003-Plus'  'video_shader_enable' 'false'
	RetroArch_setOverride 'mame.cfg' 'MAME 2003-Plus'	'video_filter' "\"$RetroArch_videoPath/Normal4x.filt\""
	RetroArch_setOverride 'mame.cfg' 'MAME 2003-Plus'	'video_smooth' '"true"'

	RetroArch_setOverride 'mame.cfg' 'MAME'  'video_shader_enable' 'false'
	RetroArch_setOverride 'mame.cfg' 'MAME'	'video_filter' "\"$RetroArch_videoPath/Normal4x.filt\""
	RetroArch_setOverride 'mame.cfg' 'MAME'	'video_smooth' '"true"'
}

RetroArch_neogeo_bezelOn(){
	RetroArch_setOverride 'neogeo.cfg' 'FinalBurn Neo'  'input_overlay' "$RetroArch_overlaysPath/pegasus/neogeo.cfg"
	RetroArch_setOverride 'neogeo.cfg' 'FinalBurn Neo'  'input_overlay_auto_scale' '"false"'
	RetroArch_setOverride 'neogeo.cfg' 'FinalBurn Neo'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'neogeo.cfg' 'FinalBurn Neo'  'input_overlay_hide_in_menu' '"false"'
	RetroArch_setOverride 'neogeo.cfg' 'FinalBurn Neo'  'input_overlay_scale_landscape' '"1.170000'
}

RetroArch_neogeo_bezelOff(){
	RetroArch_setOverride 'neogeo.cfg' 'FinalBurn Neo'  'input_overlay_enable' '"false"'
}

RetroArch_neogeo_CRTshaderOn(){
	RetroArch_setOverride 'neogeo.cfg' 'FinalBurn Neo' 'video_shader_enable' 'true'
	RetroArch_setOverride 'neogeo.cfg' 'FinalBurn Neo'	'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'neogeo.cfg' 'FinalBurn Neo'	'video_smooth' '"false"'
}

RetroArch_neogeo_CRTshaderOff(){
	RetroArch_setOverride 'neogeo.cfg' 'FinalBurn Neo' 'video_shader_enable' '"false"'
	RetroArch_setOverride 'neogeo.cfg' 'FinalBurn Neo'	'video_filter' "\"$RetroArch_videoPath/Normal4x.filt\""
	RetroArch_setOverride 'neogeo.cfg' 'FinalBurn Neo'	'video_smooth' '"true"'
}

RetroArch_fbneo_bezelOn(){
	RetroArch_setOverride 'fbneo.cfg' 'FinalBurn Neo'  'input_overlay' "$RetroArch_overlaysPath/pegasus/neogeo.cfg"
	RetroArch_setOverride 'fbneo.cfg' 'FinalBurn Neo'  'input_overlay_auto_scale' '"false"'
	RetroArch_setOverride 'fbneo.cfg' 'FinalBurn Neo'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'fbneo.cfg' 'FinalBurn Neo'  'input_overlay_hide_in_menu' '"false"'
	RetroArch_setOverride 'fbneo.cfg' 'FinalBurn Neo'  'input_overlay_scale_landscape' '"1.170000'
}

RetroArch_fbneo_bezelOff(){
	RetroArch_setOverride 'fbneo.cfg' 'FinalBurn Neo'  'input_overlay_enable' '"false"'
}

RetroArch_fbneo_CRTshaderOn(){
	RetroArch_setOverride 'fbneo.cfg' 'FinalBurn Neo' 'video_shader_enable' 'true'
	RetroArch_setOverride 'fbneo.cfg' 'FinalBurn Neo'	'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'fbneo.cfg' 'FinalBurn Neo'	'video_smooth' '"false"'
}

RetroArch_fbneo_CRTshaderOff(){
	RetroArch_setOverride 'fbneo.cfg' 'FinalBurn Neo' 'video_shader_enable' '"false"'
	RetroArch_setOverride 'fbneo.cfg' 'FinalBurn Neo'	'video_filter' "\"$RetroArch_videoPath/Normal4x.filt\""
	RetroArch_setOverride 'fbneo.cfg' 'FinalBurn Neo'	'video_smooth' '"true"'
}


RetroArch_segacd_setConfig(){
	RetroArch_setOverride 'megacd.cfg' 'Genesis Plus GX'  'input_player1_analog_dpad_mode' '"1"'
	RetroArch_setOverride 'segacd.cfg' 'Genesis Plus GX'  'input_player1_analog_dpad_mode' '"1"'
}

RetroArch_segacd_bezelOn(){
	RetroArch_setOverride 'megacd.cfg' 'Genesis Plus GX'  'input_overlay' "\"$RetroArch_overlaysPath/pegasus/segacd.cfg\""
	RetroArch_setOverride 'megacd.cfg' 'Genesis Plus GX'  'input_overlay_auto_scale' '"false"'
	RetroArch_setOverride 'megacd.cfg' 'Genesis Plus GX'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'megacd.cfg' 'Genesis Plus GX'  'input_overlay_hide_in_menu' '"false"'
	RetroArch_setOverride 'megacd.cfg' 'Genesis Plus GX'  'input_overlay_scale_landscape' '"1.170000'
	RetroArch_setOverride 'megacd.cfg' 'Genesis Plus GX'  'aspect_ratio_index' '"0"'

	RetroArch_setOverride 'segacd.cfg' 'Genesis Plus GX'  'input_overlay' "\"$RetroArch_overlaysPath/pegasus/segacd.cfg\""
	RetroArch_setOverride 'segacd.cfg' 'Genesis Plus GX'  'input_overlay_auto_scale' '"false"'
	RetroArch_setOverride 'segacd.cfg' 'Genesis Plus GX'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'segacd.cfg' 'Genesis Plus GX'  'input_overlay_hide_in_menu' '"false"'
	RetroArch_setOverride 'segacd.cfg' 'Genesis Plus GX'  'input_overlay_scale_landscape' '"1.170000'
	RetroArch_setOverride 'segacd.cfg' 'Genesis Plus GX'  'aspect_ratio_index' '"0"'
}
RetroArch_segacd_bezelOff(){
	RetroArch_setOverride 'megacd.cfg' 'Genesis Plus GX'  'input_overlay_enable' '"false"'
	RetroArch_setOverride 'segacd.cfg' 'Genesis Plus GX'  'input_overlay_enable' '"false"'
}

RetroArch_segacd_CRTshaderOn(){
	RetroArch_setOverride 'segacd.cfg' 'Genesis Plus GX'  'video_shader_enable' '"true"'
	RetroArch_setOverride 'megacd.cfg' 'Genesis Plus GX'  'video_shader_enable' '"true"'
}

RetroArch_segacd_CRTshaderOff(){
	RetroArch_setOverride 'segacd.cfg' 'Genesis Plus GX'  'video_shader_enable' '"false"'
	RetroArch_setOverride 'megacd.cfg' 'Genesis Plus GX'  'video_shader_enable' '"false"'
}


RetroArch_segacd_ar32(){
	RetroArch_setOverride 'segacd.cfg' 'Genesis Plus GX'  'aspect_ratio_index' '"7"'
	RetroArch_setOverride 'megacd.cfg' 'Genesis Plus GX'  'aspect_ratio_index' '"7"'
	RetroArch_segacd_bezelOff
}
RetroArch_segacd_ar43(){
	RetroArch_setOverride 'segacd.cfg' 'Genesis Plus GX'  'aspect_ratio_index' '"21"'
	RetroArch_setOverride 'megacd.cfg' 'Genesis Plus GX'  'aspect_ratio_index' '"21"'
}

RetroArch_genesis_setConfig(){
	RetroArch_setOverride 'genesis.cfg' 'Genesis Plus GX'  'input_player1_analog_dpad_mode' '"1"'
	RetroArch_setOverride 'megadrive.cfg' 'Genesis Plus GX'  'input_player1_analog_dpad_mode' '"1"'
}

RetroArch_genesis_bezelOn(){
	RetroArch_setOverride 'genesis.cfg' 'Genesis Plus GX'  'input_overlay' "\"$RetroArch_overlaysPath/pegasus/genesis.cfg\""
	RetroArch_setOverride 'genesis.cfg' 'Genesis Plus GX'  'input_overlay_auto_scale' '"false"'
	RetroArch_setOverride 'genesis.cfg' 'Genesis Plus GX'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'genesis.cfg' 'Genesis Plus GX'  'input_overlay_scale_landscape' '"1.170000"'
	RetroArch_setOverride 'genesis.cfg' 'Genesis Plus GX'  'aspect_ratio_index' '"0"'

	RetroArch_setOverride 'megadrive.cfg' 'Genesis Plus GX'  'input_overlay' "\"$RetroArch_overlaysPath/pegasus/genesis.cfg\""
	RetroArch_setOverride 'megadrive.cfg' 'Genesis Plus GX'  'input_overlay_auto_scale' '"false"'
	RetroArch_setOverride 'megadrive.cfg' 'Genesis Plus GX'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'megadrive.cfg' 'Genesis Plus GX'  'input_overlay_scale_landscape' '"1.170000"'
	RetroArch_setOverride 'megadrive.cfg' 'Genesis Plus GX'  'aspect_ratio_index' '"0"'

}

RetroArch_genesis_bezelOff(){
	RetroArch_setOverride 'megadrive.cfg' 'Genesis Plus GX'  'input_overlay_enable' '"false"'
	RetroArch_setOverride 'genesis.cfg' 'Genesis Plus GX'  'input_overlay_enable' '"false"'
}

RetroArch_genesis_ar32(){
	RetroArch_setOverride 'genesis.cfg' 'Genesis Plus GX'  'aspect_ratio_index' '"7"'
	RetroArch_setOverride 'megadrive.cfg' 'Genesis Plus GX'  'aspect_ratio_index' '"7"'
	RetroArch_genesis_bezelOff
}

RetroArch_genesis_ar43(){
	RetroArch_setOverride 'genesis.cfg' 'Genesis Plus GX'  'aspect_ratio_index' '"21"'
	RetroArch_setOverride 'megadrive.cfg' 'Genesis Plus GX'  'aspect_ratio_index' '"21"'
}

RetroArch_genesis_CRTshaderOn(){
	RetroArch_setOverride 'genesis.cfg' 'Genesis Plus GX'  'video_shader_enable' '"true"'
	RetroArch_setOverride 'genesis.cfg' 'Genesis Plus GX'	'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'genesis.cfg' 'Genesis Plus GX'	'video_smooth' '"false"'

	RetroArch_setOverride 'megadrive.cfg' 'Genesis Plus GX'  'video_shader_enable' '"true"'
	RetroArch_setOverride 'megadrive.cfg' 'Genesis Plus GX'	'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'megadrive.cfg' 'Genesis Plus GX'	'video_smooth' '"false"'
}

RetroArch_genesis_CRTshaderOff(){
	RetroArch_setOverride 'genesis.cfg' 'Genesis Plus GX'  'video_shader_enable' '"false"'
	RetroArch_setOverride 'genesis.cfg' 'Genesis Plus GX'	'video_filter' "\"$RetroArch_videoPath/Normal4x.filt\""
	RetroArch_setOverride 'genesis.cfg' 'Genesis Plus GX'	'video_smooth' '"true"'

	RetroArch_setOverride 'megadrive.cfg' 'Genesis Plus GX'  'video_shader_enable' '"false"'
	RetroArch_setOverride 'megadrive.cfg' 'Genesis Plus GX'	'video_filter' "\"$RetroArch_videoPath/Normal4x.filt\""
	RetroArch_setOverride 'megadrive.cfg' 'Genesis Plus GX'	'video_smooth' '"true"'
}

RetroArch_gamegear_setConfig(){
	RetroArch_setOverride 'gamegear.cfg' 'Genesis Plus GX'  'input_player1_analog_dpad_mode' '"1"'
	RetroArch_setOverride 'gamegear.cfg' 'Gearsystem'  'input_player1_analog_dpad_mode' '"1"'
}

RetroArch_gamegear_bezelOn(){
	RetroArch_setOverride 'gamegear.cfg' 'Genesis Plus GX'  'aspect_ratio_index' '"21"'
	RetroArch_setOverride 'gamegear.cfg' 'Genesis Plus GX'  'input_overlay' "\"$RetroArch_overlaysPath/pegasus/gg.cfg\""
	RetroArch_setOverride 'gamegear.cfg' 'Genesis Plus GX'  'input_overlay_aspect_adjust_landscape' '"-0.115000"'
	RetroArch_setOverride 'gamegear.cfg' 'Genesis Plus GX'  'input_overlay_auto_scale' '"false"'
	RetroArch_setOverride 'gamegear.cfg' 'Genesis Plus GX'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'gamegear.cfg' 'Genesis Plus GX'  'input_overlay_scale_landscape' '"1.545000"'

	RetroArch_setOverride 'gamegear.cfg' 'Gearsystem'  'aspect_ratio_index' '"21"'
	RetroArch_setOverride 'gamegear.cfg' 'Gearsystem'  'input_overlay' "\"$RetroArch_overlaysPath/pegasus/gg.cfg\""
	RetroArch_setOverride 'gamegear.cfg' 'Gearsystem'  'input_overlay_aspect_adjust_landscape' '"-0.115000"'
	RetroArch_setOverride 'gamegear.cfg' 'Gearsystem'  'input_overlay_auto_scale' '"false"'
	RetroArch_setOverride 'gamegear.cfg' 'Gearsystem'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'gamegear.cfg' 'Gearsystem'  'input_overlay_scale_landscape' '"1.545000"'
}

RetroArch_gamegear_bezelOff(){
	RetroArch_setOverride 'gamegear.cfg' 'Genesis Plus GX'  'input_overlay_enable' '"false"'

	RetroArch_setOverride 'gamegear.cfg' 'Gearsystem'  'input_overlay_enable' '"false"'
}

RetroArch_gamegear_MATshaderOn(){
	RetroArch_setOverride 'gamegear.cfg' 'Genesis Plus GX'  'video_shader_enable' '"true"'
	RetroArch_setOverride 'gamegear.cfg' 'Genesis Plus GX'	'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'gamegear.cfg' 'Genesis Plus GX'	'video_smooth' '"false"'

	RetroArch_setOverride 'gamegear.cfg' 'Gearsystem'  'video_shader_enable' '"true"'
	RetroArch_setOverride 'gamegear.cfg' 'Gearsystem'	'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'gamegear.cfg' 'Gearsystem'	'video_smooth' '"false"'
}

RetroArch_gamegear_MATshaderOff(){
	RetroArch_setOverride 'gamegear.cfg' 'Genesis Plus GX'  'video_shader_enable' '"false"'
	RetroArch_setOverride 'gamegear.cfg' 'Genesis Plus GX'	'video_filter' "\"$RetroArch_videoPath/Normal4x.filt\""
	RetroArch_setOverride 'gamegear.cfg' 'Genesis Plus GX'	'video_smooth' '"true"'

	RetroArch_setOverride 'gamegear.cfg' 'Gearsystem'  'video_shader_enable' '"false"'
	RetroArch_setOverride 'gamegear.cfg' 'Gearsystem'	'video_filter' "\"$RetroArch_videoPath/Normal4x.filt\""
	RetroArch_setOverride 'gamegear.cfg' 'Gearsystem'	'video_smooth' '"true"'
}

RetroArch_mastersystem_setConfig(){
	RetroArch_setOverride 'mastersystem.cfg' 'Genesis Plus GX'  'input_player1_analog_dpad_mode' '"1"'
}

RetroArch_mastersystem_bezelOn(){
	RetroArch_setOverride 'mastersystem.cfg' 'Genesis Plus GX'  'aspect_ratio_index' '"21"'
	RetroArch_setOverride 'mastersystem.cfg' 'Genesis Plus GX'  'input_overlay' "\"$RetroArch_overlaysPath/pegasus/mastersystem.cfg\""
	RetroArch_setOverride 'mastersystem.cfg' 'Genesis Plus GX'  'input_overlay_auto_scale' '"false"'
	RetroArch_setOverride 'mastersystem.cfg' 'Genesis Plus GX'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'mastersystem.cfg' 'Genesis Plus GX'  'input_overlay_scale_landscape' '"1.170000"'
}

RetroArch_mastersystem_bezelOff(){
	RetroArch_setOverride 'mastersystem.cfg' 'Genesis Plus GX'  'input_overlay_enable' '"false"'
}

RetroArch_mastersystem_ar32(){
	RetroArch_setOverride 'mastersystem.cfg' 'Genesis Plus GX'  'aspect_ratio_index' '"7"'
	RetroArch_mastersystem_bezelOff
}

RetroArch_mastersystem_CRTshaderOn(){
	RetroArch_setOverride 'mastersystem.cfg' 'Genesis Plus GX'  'video_shader_enable' '"true"'
	RetroArch_setOverride 'mastersystem.cfg' 'Genesis Plus GX'	'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'mastersystem.cfg' 'Genesis Plus GX'	'video_smooth' '"false"'
}

RetroArch_mastersystem_CRTshaderOff(){
	RetroArch_setOverride 'mastersystem.cfg' 'Genesis Plus GX'  'video_shader_enable' '"false"'
	RetroArch_setOverride 'mastersystem.cfg' 'Genesis Plus GX'	'video_filter' "\"$RetroArch_videoPath/Normal4x.filt\""
	RetroArch_setOverride 'mastersystem.cfg' 'Genesis Plus GX'	'video_smooth' '"true"'
}

RetroArch_mastersystem_ar43(){
	RetroArch_setOverride 'mastersystem.cfg' 'Genesis Plus GX'  'aspect_ratio_index' '"21"'
}
RetroArch_sega32x_setConfig(){
	RetroArch_setOverride 'sega32x.cfg' 'PicoDrive'  'input_player1_analog_dpad_mode' '"1"'
	RetroArch_setOverride 'sega32xna.cfg' 'PicoDrive'  'input_player1_analog_dpad_mode' '"1"'
}
RetroArch_sega32x_bezelOn(){
	RetroArch_setOverride 'sega32x.cfg' 'PicoDrive'  'input_overlay' "\"$RetroArch_overlaysPath/pegasus/sega32x.cfg\""
	RetroArch_setOverride 'sega32x.cfg' 'PicoDrive'  'input_overlay_auto_scale' '"false"'
	RetroArch_setOverride 'sega32x.cfg' 'PicoDrive'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'sega32x.cfg' 'PicoDrive'  'input_overlay_hide_in_menu' '"false"'
	RetroArch_setOverride 'sega32x.cfg' 'PicoDrive'  'input_overlay_scale_landscape' '"1.070000"'
	RetroArch_setOverride 'sega32x.cfg' 'PicoDrive'  'input_overlay_aspect_adjust_landscape' '"0.095000"'
	RetroArch_setOverride 'sega32x.cfg' 'PicoDrive'  'aspect_ratio_index' '"0"'

	RetroArch_setOverride 'sega32xna.cfg' 'PicoDrive'  'input_overlay' "\"$RetroArch_overlaysPath/pegasus/sega32x.cfg\""
	RetroArch_setOverride 'sega32xna.cfg' 'PicoDrive'  'input_overlay_auto_scale' '"false"'
	RetroArch_setOverride 'sega32xna.cfg' 'PicoDrive'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'sega32xna.cfg' 'PicoDrive'  'input_overlay_hide_in_menu' '"false"'
	RetroArch_setOverride 'sega32xna.cfg' 'PicoDrive'  'input_overlay_scale_landscape' '"1.070000"'
	RetroArch_setOverride 'sega32xna.cfg' 'PicoDrive'  'input_overlay_aspect_adjust_landscape' '"0.095000"'
	RetroArch_setOverride 'sega32xna.cfg' 'PicoDrive'  'aspect_ratio_index' '"0"'
}

RetroArch_sega32x_bezelOff(){
	RetroArch_setOverride 'sega32x.cfg' 'PicoDrive'  'input_overlay_enable' '"false"'
	RetroArch_setOverride 'sega32xna.cfg' 'PicoDrive'  'input_overlay_enable' '"false"'
}

RetroArch_sega32x_CRTshaderOn(){
	RetroArch_setOverride 'sega32x.cfg' 'PicoDrive'  'video_shader_enable' '"true"'
	RetroArch_setOverride 'sega32x.cfg' 'PicoDrive'	 'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'sega32x.cfg' 'PicoDrive'	 'video_smooth' '"false"'
	RetroArch_setOverride 'sega32xna.cfg' 'PicoDrive'  'video_shader_enable' '"true"'
	RetroArch_setOverride 'sega32xna.cfg' 'PicoDrive'	 'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'sega32xna.cfg' 'PicoDrive'	 'video_smooth' '"false"'
}

RetroArch_sega32x_CRTshaderOff(){
	RetroArch_setOverride 'sega32x.cfg' 'PicoDrive'  'video_shader_enable' '"false"'
	RetroArch_setOverride 'sega32x.cfg' 'PicoDrive'	 'video_filter' "\"$RetroArch_videoPath/Normal4x.filt\""
	RetroArch_setOverride 'sega32x.cfg' 'PicoDrive'	 'video_smooth' '"true"'
	RetroArch_setOverride 'sega32xna.cfg' 'PicoDrive'  'video_shader_enable' '"false"'
	RetroArch_setOverride 'sega32xna.cfg' 'PicoDrive'	 'video_filter' "\"$RetroArch_videoPath/Normal4x.filt\""
	RetroArch_setOverride 'sega32xna.cfg' 'PicoDrive'	 'video_smooth' '"true"'
}

RetroArch_sega32x_ar32(){
	RetroArch_setOverride 'sega32x.cfg' 'PicoDrive'  'aspect_ratio_index' '"7"'
	RetroArch_setOverride 'sega32xna.cfg' 'PicoDrive'  'aspect_ratio_index' '"7"'
	RetroArch_sega32x_bezelOff
}

RetroArch_sega32x_ar43(){
	RetroArch_setOverride 'sega32x.cfg' 'PicoDrive'  'aspect_ratio_index' '"21"'
	RetroArch_setOverride 'sega32xna.cfg' 'PicoDrive'  'aspect_ratio_index' '"21"'
	RetroArch_sega32x_bezelOff
}

#RetroArch_gba_bezelOn(){
#	#missing stuff?
#	RetroArch_setOverride 'gba.cfg' 'mGBA'  'aspect_ratio_index' '"21"'
#}
RetroArch_gba_setConfig(){
	RetroArch_setOverride 'gba.cfg' 'mGBA'  'input_player1_analog_dpad_mode' '"1"'
}
RetroArch_gba_MATshaderOn(){
	RetroArch_setOverride 'gba.cfg' 'mGBA'  'video_shader_enable' '"true"'
	RetroArch_setOverride 'gba.cfg' 'mGBA'	 'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'gba.cfg' 'mGBA'	 'video_smooth' '"false"'
}

RetroArch_gba_MATshaderOff(){
	RetroArch_setOverride 'gba.cfg' 'mGBA'  'video_shader_enable' '"false"'
	RetroArch_setOverride 'gba.cfg' 'mGBA'	 'video_filter' "\"$RetroArch_videoPath/Normal4x.filt\""
	RetroArch_setOverride 'gba.cfg' 'mGBA'	 'video_smooth' '"true"'
}

RetroArch_gb_bezelOn(){
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'aspect_ratio_index' '"21"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'input_overlay' "\"$RetroArch_overlaysPath/pegasus/gb.cfg\""
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'input_overlay_auto_scale' '"false"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'input_overlay_scale_landscape' '"1.860000"'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'input_overlay_y_offset_landscape' '"-0.150000"'

	RetroArch_setOverride 'gb.cfg' 'Gambatte'  'aspect_ratio_index' '"21"'
	RetroArch_setOverride 'gb.cfg' 'Gambatte'  'input_overlay' "\"$RetroArch_overlaysPath/pegasus/gb.cfg\""
	RetroArch_setOverride 'gb.cfg' 'Gambatte'  'input_overlay_auto_scale' '"false"'
	RetroArch_setOverride 'gb.cfg' 'Gambatte'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'gb.cfg' 'Gambatte'  'input_overlay_scale_landscape' '"1.860000"'
	RetroArch_setOverride 'gb.cfg' 'Gambatte'  'input_overlay_y_offset_landscape' '"-0.150000"'
}

RetroArch_gb_setConfig(){
	RetroArch_setOverride 'gb.cfg' 'Gambatte'  'input_player1_analog_dpad_mode' '"1"'
}

RetroArch_gb_bezelOff(){
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'input_overlay_enable' '"false"'


	RetroArch_setOverride 'gb.cfg' 'Gambatte'  'input_overlay_enable' '"false"'
}

RetroArch_gb_MATshaderOn(){
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'video_shader_enable' 'true'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'	 'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'	 'video_smooth' '"false"'

	RetroArch_setOverride 'gb.cfg' 'Gambatte'  'video_shader_enable' '"true"'
	RetroArch_setOverride 'gb.cfg' 'Gambatte'	 'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'gb.cfg' 'Gambatte'	 'video_smooth' '"false"'
}

RetroArch_gb_MATshaderOff(){
	RetroArch_setOverride 'gb.cfg' 'SameBoy'  'video_shader_enable' 'false'
	RetroArch_setOverride 'gb.cfg' 'SameBoy'	 'video_filter' "\"$RetroArch_videoPath/Normal4x.filt\""
	RetroArch_setOverride 'gb.cfg' 'SameBoy'	 'video_smooth' '"true"'

	RetroArch_setOverride 'gb.cfg' 'Gambatte'  'video_shader_enable' '"false"'
	RetroArch_setOverride 'gb.cfg' 'Gambatte'	 'video_filter' "\"$RetroArch_videoPath/Normal4x.filt\""
	RetroArch_setOverride 'gb.cfg' 'Gambatte'	 'video_smooth' '"true"'
}

RetroArch_SameBoy_gbc_setConfig(){
	RetroArch_setOverride 'gbc.cfg' 'SameBoy'  'input_player1_analog_dpad_mode' '"1"'
	RetroArch_setOverride 'gbc.cfg' 'SameBoy'  'gambatte_gbc_color_correction' '"GBC'
	RetroArch_setOverride 'gbc.cfg' 'SameBoy'  'gambatte_gbc_color_correction_mode' '"accurate"'
	RetroArch_setOverride 'gbc.cfg' 'SameBoy'  'gambatte_gbc_frontlight_position' '"central"'
}


RetroArch_gbc_setConfig(){
	RetroArch_setOverride 'gbc.cfg' 'Gambatte'  'input_player1_analog_dpad_mode' '"1"'
}

RetroArch_gbc_bezelOn(){
	RetroArch_setOverride 'gbc.cfg' 'SameBoy'  'aspect_ratio_index' '"21"'
	RetroArch_setOverride 'gbc.cfg' 'SameBoy'  'input_overlay' "\"$RetroArch_overlaysPath/pegasus/gbc.cfg\""
	RetroArch_setOverride 'gbc.cfg' 'SameBoy'  'input_overlay_auto_scale' '"false"'
	RetroArch_setOverride 'gbc.cfg' 'SameBoy'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'gbc.cfg' 'SameBoy'  'input_overlay_scale_landscape' '"1.870000"'
	RetroArch_setOverride 'gbc.cfg' 'SameBoy'  'input_overlay_y_offset_landscape' '"-0.220000"'

	RetroArch_setOverride 'gbc.cfg' 'Gambatte'  'aspect_ratio_index' '"21"'
	RetroArch_setOverride 'gbc.cfg' 'Gambatte'  'input_overlay' "\"$RetroArch_overlaysPath/pegasus/gbc.cfg\""
	RetroArch_setOverride 'gbc.cfg' 'Gambatte'  'input_overlay_auto_scale' '"false"'
	RetroArch_setOverride 'gbc.cfg' 'Gambatte'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'gbc.cfg' 'Gambatte'  'input_overlay_scale_landscape' '"1.870000"'
	RetroArch_setOverride 'gbc.cfg' 'Gambatte'  'input_overlay_y_offset_landscape' '"-0.220000"'
}

RetroArch_gbc_bezelOff(){
	RetroArch_setOverride 'gbc.cfg' 'SameBoy'  'input_overlay_enable' '"false"'


	RetroArch_setOverride 'gbc.cfg' 'Gambatte'  'input_overlay_enable' '"false"'
}

RetroArch_gbc_MATshaderOn(){
	RetroArch_setOverride 'gbc.cfg' 'SameBoy'  'video_shader_enable' 'true'
	RetroArch_setOverride 'gbc.cfg' 'SameBoy'	 'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'gbc.cfg' 'SameBoy'	 'video_smooth' '"false"'

	RetroArch_setOverride 'gbc.cfg' 'Gambatte'  'video_shader_enable' 'true'
	RetroArch_setOverride 'gbc.cfg' 'Gambatte'	 'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'gbc.cfg' 'Gambatte'	 'video_smooth' '"false"'
}

RetroArch_gbc_MATshaderOff(){
	RetroArch_setOverride 'gbc.cfg' 'SameBoy'  'video_shader_enable' 'false'
	RetroArch_setOverride 'gbc.cfg' 'SameBoy'	 'video_filter' "\"$RetroArch_videoPath/Normal4x.filt\""
	RetroArch_setOverride 'gbc.cfg' 'SameBoy'	 'video_smooth' '"true"'

	RetroArch_setOverride 'gbc.cfg' 'Gambatte'  'video_shader_enable' 'false'
	RetroArch_setOverride 'gbc.cfg' 'Gambatte'	 'video_filter' "\"$RetroArch_videoPath/Normal4x.filt\""
	RetroArch_setOverride 'gbc.cfg' 'Gambatte'	 'video_smooth' '"true"'
}

RetroArch_n64_wideScreenOn(){
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-aspect' '"16:9 adjusted"'
	RetroArch_setOverride 'n64.cfg' 'Mupen64Plus-Next'  'aspect_ratio_index' '"1"'
	RetroArch_n64_bezelOff
	RetroArch_n64_3DCRTshaderOff
}

RetroArch_n64_wideScreenOff(){
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-aspect' '"4:3"'
	RetroArch_setOverride 'n64.cfg' 'Mupen64Plus-Next'  'aspect_ratio_index' '"0"'
	#RetroArch_n64_bezelOn
}

RetroArch_n64_bezelOn(){
	RetroArch_setOverride 'n64.cfg' 'Mupen64Plus-Next'  'aspect_ratio_index' '"0"'
	RetroArch_setOverride 'n64.cfg' 'Mupen64Plus-Next'  'input_overlay' "\"$RetroArch_overlaysPath/pegasus/N64.cfg\""
	RetroArch_setOverride 'n64.cfg' 'Mupen64Plus-Next'  'input_overlay_aspect_adjust_landscape' '"0.085000"'
	RetroArch_setOverride 'n64.cfg' 'Mupen64Plus-Next'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'n64.cfg' 'Mupen64Plus-Next'  'input_overlay_scale_landscape' '"1.065000"'
}

RetroArch_n64_bezelOff(){
	RetroArch_setOverride 'n64.cfg' 'Mupen64Plus-Next'  'input_overlay_enable' '"false"'
}

RetroArch_atari800_setConfig(){
	RetroArch_setOverride 'atari800.cfg' 'Stella'  'input_player1_analog_dpad_mode' '"1"'
}

RetroArch_atari800_bezelOn(){
	RetroArch_setOverride 'atari800.cfg' 'Stella'  'aspect_ratio_index' '"0"'
	RetroArch_setOverride 'atari800.cfg' 'Stella'  'input_overlay' "\"$RetroArch_overlaysPath/pegasus/atari800.cfg\""
	RetroArch_setOverride 'atari800.cfg' 'Stella'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'atari800.cfg' 'Stella'  'input_overlay_hide_in_menu' '"true"'
	RetroArch_setOverride 'atari800.cfg' 'Stella'  'input_overlay_scale_landscape' '"1.175000"'
	RetroArch_setOverride 'atari800.cfg' 'Stella'  'input_overlay_aspect_adjust_landscape' '"0.000000"'
}

RetroArch_atari800_bezelOff(){
	RetroArch_setOverride 'atari800.cfg' 'Stella'  'input_overlay_enable' '"false"'
}

RetroArch_atari5200_setConfig(){
	RetroArch_setOverride 'atari5200.cfg' 'Stella'  'input_player1_analog_dpad_mode' '"1"'
}

RetroArch_atari5200_bezelOn(){
	RetroArch_setOverride 'atari5200.cfg' 'Stella'  'aspect_ratio_index' '"0"'
	RetroArch_setOverride 'atari5200.cfg' 'Stella'  'input_overlay' "\"$RetroArch_overlaysPath/pegasus/atari5200.cfg\""
	RetroArch_setOverride 'atari5200.cfg' 'Stella'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'atari5200.cfg' 'Stella'  'input_overlay_hide_in_menu' '"true"'
	RetroArch_setOverride 'atari5200.cfg' 'Stella'  'input_overlay_scale_landscape' '"1.175000"'
	RetroArch_setOverride 'atari5200.cfg' 'Stella'  'input_overlay_aspect_adjust_landscape' '"0.000000"'
}

RetroArch_atari5200_bezelOff(){
	RetroArch_setOverride 'atari5200.cfg' 'Stella'  'input_overlay_enable' '"false"'
}

RetroArch_dreamcast_bezelOn(){
	RetroArch_setOverride 'dreamcast.cfg' 'Flycast'  'aspect_ratio_index' '"0"'
	RetroArch_setOverride 'dreamcast.cfg' 'Flycast'  'input_overlay' "\"$RetroArch_overlaysPath/pegasus/Dreamcast.cfg\""
	RetroArch_setOverride 'dreamcast.cfg' 'Flycast'  'input_overlay_aspect_adjust_landscape' '"0.110000"'
	RetroArch_setOverride 'dreamcast.cfg' 'Flycast'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'dreamcast.cfg' 'Flycast'  'input_overlay_scale_landscape' '"1.054998"'
}

RetroArch_dreamcast_bezelOff(){
	RetroArch_setOverride 'dreamcast.cfg' 'Flycast'  'input_overlay_enable' '"false"'
}

#temporary
RetroArch_Flycast_bezelOff(){
	RetroArch_dreamcast_bezelOff
}

RetroArch_Flycast_bezelOn(){
	RetroArch_dreamcast_bezelOn
}

RetroArch_Beetle_PSX_HW_bezelOff(){
	RetroArch_psx_bezelOff
}

RetroArch_Beetle_PSX_HW_bezelOn(){
	RetroArch_psx_bezelOn
}

 RetroArch_dreamcast_3DCRTshaderOn(){
	 RetroArch_setOverride 'dreamcast.cfg' 'Flycast' 'video_shader_enable' '"true"'
	RetroArch_setOverride 'dreamcast.cfg' 'Flycast'	'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'dreamcast.cfg' 'Flycast'	'video_smooth' 'ED_RM_LINE'
 }

RetroArch_dreamcast_setConfig(){
	RetroArch_dreamcast_3DCRTshaderOff
}

RetroArch_dreamcast_3DCRTshaderOff(){
	RetroArch_setOverride 'dreamcast.cfg' 'Flycast' 'video_shader_enable' '"false"'
	RetroArch_setOverride 'dreamcast.cfg' 'Flycast'	'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'dreamcast.cfg' 'Flycast'	'video_smooth' 'ED_RM_LINE'
}

RetroArch_saturn_setConfig(){
	mkdir -p "$biosPath/kronos"
	RetroArch_setOverride 'saturn.cfg' 'Yabause'  'input_player1_analog_dpad_mode' '"1"'
	RetroArch_setOverride 'saturn.cfg' 'YabaSanshiro'  'input_player1_analog_dpad_mode' '"1"'
	RetroArch_setOverride 'saturn.cfg' 'Kronos'  'input_player1_analog_dpad_mode' '"1"'
	RetroArch_setOverride 'saturn.cfg' 'Beetle Saturn'  'input_player1_analog_dpad_mode' '"1"'
	RetroArch_saturn_3DCRTshaderOff
}

RetroArch_saturn_bezelOn(){
	RetroArch_setOverride 'saturn.cfg' 'Yabause'  'aspect_ratio_index' '"0"'
	RetroArch_setOverride 'saturn.cfg' 'Yabause'  'input_overlay' "\"$RetroArch_overlaysPath/pegasus/saturn.cfg\""
	RetroArch_setOverride 'saturn.cfg' 'Yabause'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'saturn.cfg' 'Yabause'  'input_overlay_scale_landscape' '"1.070000"'
	RetroArch_setOverride 'saturn.cfg' 'Yabause'  'input_overlay_aspect_adjust_landscape' '"0.095000"'

	RetroArch_setOverride 'saturn.cfg' 'YabaSanshiro'  'aspect_ratio_index' '"0"'
	RetroArch_setOverride 'saturn.cfg' 'YabaSanshiro'  'input_overlay' "\"$RetroArch_overlaysPath/pegasus/saturn.cfg\""
	RetroArch_setOverride 'saturn.cfg' 'YabaSanshiro'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'saturn.cfg' 'YabaSanshiro'  'input_overlay_scale_landscape' '"1.070000"'
	RetroArch_setOverride 'saturn.cfg' 'YabaSanshiro'  'input_overlay_aspect_adjust_landscape' '"0.095000"'


	RetroArch_setOverride 'saturn.cfg' 'Kronos'  'aspect_ratio_index' '"0"'
	RetroArch_setOverride 'saturn.cfg' 'Kronos'  'input_overlay' "\"$RetroArch_overlaysPath/pegasus/saturn.cfg\""
	RetroArch_setOverride 'saturn.cfg' 'Kronos'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'saturn.cfg' 'Kronos'  'input_overlay_scale_landscape' '"1.070000"'
	RetroArch_setOverride 'saturn.cfg' 'Kronos'  'input_overlay_aspect_adjust_landscape' '"0.095000"'

	RetroArch_setOverride 'saturn.cfg' 'Beetle Saturn'  'aspect_ratio_index' '"0"'
	RetroArch_setOverride 'saturn.cfg' 'Beetle Saturn'  'input_overlay' "\"$RetroArch_overlaysPath/pegasus/saturn.cfg\""
	RetroArch_setOverride 'saturn.cfg' 'Beetle Saturn'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'saturn.cfg' 'Beetle Saturn'  'input_overlay_scale_landscape' '"1.070000"'
	RetroArch_setOverride 'saturn.cfg' 'Beetle Saturn'  'input_overlay_aspect_adjust_landscape' '"0.095000"'
}

RetroArch_saturn_bezelOff(){
	RetroArch_setOverride 'saturn.cfg' 'Yabause'  'input_overlay_enable' '"false"'
	RetroArch_setOverride 'saturn.cfg' 'YabaSanshiro'  'input_overlay_enable' '"false"'
	RetroArch_setOverride 'saturn.cfg' 'Kronos'  'input_overlay_enable' '"false"'
	RetroArch_setOverride 'saturn.cfg' 'Beetle Saturn'  'input_overlay_enable' '"false"'
}

 RetroArch_saturn_3DCRTshaderOn(){
	 RetroArch_setOverride 'saturn.cfg' 'Yabause'  'video_shader_enable' '"true"'
	RetroArch_setOverride 'saturn.cfg' 'Yabause'	'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'saturn.cfg' 'Yabause'	'video_smooth' 'ED_RM_LINE'

	 RetroArch_setOverride 'saturn.cfg' 'YabaSanshiro'  'video_shader_enable' '"true"'
	RetroArch_setOverride 'saturn.cfg' 'YabaSanshiro'	'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'saturn.cfg' 'YabaSanshiro'	'video_smooth' 'ED_RM_LINE'

	RetroArch_setOverride 'saturn.cfg' 'Kronos'  'video_shader_enable' '"true"'
	RetroArch_setOverride 'saturn.cfg' 'Kronos'	'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'saturn.cfg' 'Kronos'	'video_smooth' 'ED_RM_LINE'

	 RetroArch_setOverride 'saturn.cfg' 'Beetle Saturn'  'video_shader_enable' '"true"'
	RetroArch_setOverride 'saturn.cfg' 'Beetle Saturn'	'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'saturn.cfg' 'Beetle Saturn'	'video_smooth' 'ED_RM_LINE'
 }

RetroArch_saturn_3DCRTshaderOff(){
	RetroArch_setOverride 'saturn.cfg' 'Yabause'  'video_shader_enable' '"false"'
	RetroArch_setOverride 'saturn.cfg' 'YabaSanshiro'  'video_shader_enable' '"false"'
	RetroArch_setOverride 'saturn.cfg' 'Kronos'  'video_shader_enable' '"false"'
	RetroArch_setOverride 'saturn.cfg' 'Beetle Saturn'  'video_shader_enable' '"false"'

	RetroArch_setOverride 'saturn.cfg' 'Yabause'	'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'saturn.cfg' 'Yabause'	'video_smooth' 'ED_RM_LINE'

	RetroArch_setOverride 'saturn.cfg' 'YabaSanshiro'	'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'saturn.cfg' 'YabaSanshiro'	'video_smooth' 'ED_RM_LINE'

	RetroArch_setOverride 'saturn.cfg' 'Kronos'	'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'saturn.cfg' 'Kronos'	'video_smooth' 'ED_RM_LINE'

	RetroArch_setOverride 'saturn.cfg' 'Beetle Saturn'	'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'saturn.cfg' 'Beetle Saturn'	'video_smooth' 'ED_RM_LINE'
}

RetroArch_snes_setConfig(){
	RetroArch_setOverride 'snes.cfg' 'Snes9x'  'input_player1_analog_dpad_mode' '"1"'
	RetroArch_setOverride 'snesna.cfg' 'Snes9x'  'input_player1_analog_dpad_mode' '"1"'
}

RetroArch_snes_bezelOn(){
	RetroArch_setOverride 'snes.cfg' 'Snes9x'  'input_overlay' "\"$RetroArch_overlaysPath/pegasus/snes.cfg\""
	RetroArch_setOverride 'snes.cfg' 'Snes9x'  'input_overlay_auto_scale' '"false"'
	RetroArch_setOverride 'snes.cfg' 'Snes9x'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'snes.cfg' 'Snes9x'  'input_overlay_opacity' '"0.700000"'
	RetroArch_setOverride 'snes.cfg' 'Snes9x'  'video_scale_integer' '"false"'
	RetroArch_setOverride 'snesna.cfg' 'Snes9x'  'input_overlay' "\"$RetroArch_overlaysPath/pegasus/snes.cfg\""
	RetroArch_setOverride 'snesna.cfg' 'Snes9x'  'input_overlay_auto_scale' '"false"'
	RetroArch_setOverride 'snesna.cfg' 'Snes9x'  'input_overlay_enable' '"true"'
	RetroArch_setOverride 'snesna.cfg' 'Snes9x'  'input_overlay_opacity' '"0.700000"'
	RetroArch_setOverride 'snesna.cfg' 'Snes9x'  'video_scale_integer' '"false"'

	case $arSnes in
	  "87")
		RetroArch_snes_ar87
	  ;;
	  "32")
			RetroArch_snes_ar32
		;;
	  *)
		RetroArch_snes_ar43
	  ;;
	esac
}

RetroArch_snes_bezelOff(){
	RetroArch_setOverride 'snes.cfg' 'Snes9x'  'input_overlay_enable' '"false"'
	RetroArch_setOverride 'snesna.cfg' 'Snes9x'  'input_overlay_enable' '"false"'
}

RetroArch_snes_CRTshaderOn(){
	RetroArch_setOverride 'snes.cfg' 'Snes9x'  'video_shader_enable' '"true"'
	RetroArch_setOverride 'snes.cfg' 'Snes9x'	'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'snes.cfg' 'Snes9x'	'video_smooth' '"false"'
	RetroArch_setOverride 'snesna.cfg' 'Snes9x'  'video_shader_enable' '"true"'
	RetroArch_setOverride 'snesna.cfg' 'Snes9x'	'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'snesna.cfg' 'Snes9x'	'video_smooth' '"false"'
}

RetroArch_snes_CRTshaderOff(){
	RetroArch_setOverride 'snes.cfg' 'Snes9x'  'video_shader_enable' '"false"'
	RetroArch_setOverride 'snes.cfg' 'Snes9x'	'video_filter' "\"$RetroArch_videoPath/Normal4x.filt\""
	RetroArch_setOverride 'snes.cfg' 'Snes9x'	'video_smooth' '"true"'
	RetroArch_setOverride 'snesna.cfg' 'Snes9x'  'video_shader_enable' '"false"'
	RetroArch_setOverride 'snesna.cfg' 'Snes9x'	'video_filter' "\"$RetroArch_videoPath/Normal4x.filt\""
	RetroArch_setOverride 'snesna.cfg' 'Snes9x'	'video_smooth' '"true"'
}

RetroArch_snes_ar43(){
	RetroArch_setOverride 'snes.cfg' 'Snes9x'  'aspect_ratio_index' '"0"'
	RetroArch_setOverride 'snes.cfg' 'Snes9x'  'input_overlay_scale_landscape' '"1.170000"'
	RetroArch_setOverride 'snes.cfg' 'Snes9x'  'input_overlay_aspect_adjust_landscape' '"0"'
	RetroArch_setOverride 'snes.cfg' 'Snes9x'  'input_overlay' "\"$RetroArch_overlaysPath/pegasus/snes.cfg\""
	RetroArch_setOverride 'snesna.cfg' 'Snes9x'  'aspect_ratio_index' '"0"'
	RetroArch_setOverride 'snesna.cfg' 'Snes9x'  'input_overlay_scale_landscape' '"1.170000"'
	RetroArch_setOverride 'snesna.cfg' 'Snes9x'  'input_overlay_aspect_adjust_landscape' '"0"'
	RetroArch_setOverride 'snesna.cfg' 'Snes9x'  'input_overlay' "\"$RetroArch_overlaysPath/pegasus/snes.cfg\""
}

RetroArch_snes_ar87(){
	RetroArch_setOverride 'snes.cfg' 'Snes9x'  'input_overlay' "\"$RetroArch_overlaysPath/pegasus/snes87.cfg\""
	RetroArch_setOverride 'snes.cfg' 'Snes9x'  'input_overlay_scale_landscape' '"1.380000"'
	RetroArch_setOverride 'snes.cfg' 'Snes9x'  'input_overlay_aspect_adjust_landscape' '"-0.170000"'
	RetroArch_setOverride 'snes.cfg' 'Snes9x'  'aspect_ratio_index' '"15"'
	RetroArch_setOverride 'snesna.cfg' 'Snes9x'  'input_overlay' "\"$RetroArch_overlaysPath/pegasus/snes87.cfg\""
	RetroArch_setOverride 'snesna.cfg' 'Snes9x'  'input_overlay_scale_landscape' '"1.380000"'
	RetroArch_setOverride 'snesna.cfg' 'Snes9x'  'input_overlay_aspect_adjust_landscape' '"-0.170000"'
	RetroArch_setOverride 'snesna.cfg' 'Snes9x'  'aspect_ratio_index' '"15"'
}

RetroArch_snes_ar32(){
	RetroArch_setOverride 'snes.cfg' 'Snes9x'  'aspect_ratio_index' '"7"'
	RetroArch_setOverride 'snesna.cfg' 'Snes9x'  'aspect_ratio_index' '"7"'
	RetroArch_snes_bezelOff
}


# RetroArch_bsnes_hd_beta_bezelOn(){
# 	RetroArch_setOverride 'sneshd.cfg' 'bsnes-hd beta'  'video_scale_integer' '"false"'
# }

RetroArch_melonDS_setUpCoreOpt(){
	RetroArch_setOverride 'melonDS.opt' 'melonDS'  'melonds_audio_bitrate' '"Automatic"'
	RetroArch_setOverride 'melonDS.opt' 'melonDS'  'melonds_audio_interpolation' '"None"'
	RetroArch_setOverride 'melonDS.opt' 'melonDS'  'melonds_boot_directly' '"enabled"'
	RetroArch_setOverride 'melonDS.opt' 'melonDS'  'melonds_console_mode' '"DS"'
	RetroArch_setOverride 'melonDS.opt' 'melonDS'  'melonds_dsi_sdcard' '"disabled"'
	RetroArch_setOverride 'melonDS.opt' 'melonDS'  'melonds_hybrid_ratio' '"2"'
	RetroArch_setOverride 'melonDS.opt' 'melonDS'  'melonds_hybrid_small_screen' '"Duplicate"'
	RetroArch_setOverride 'melonDS.opt' 'melonDS'  'melonds_jit_block_size' '"32"'
	RetroArch_setOverride 'melonDS.opt' 'melonDS'  'melonds_jit_branch_optimisations' '"enabled"'
	RetroArch_setOverride 'melonDS.opt' 'melonDS'  'melonds_jit_enable' '"enabled"'
	RetroArch_setOverride 'melonDS.opt' 'melonDS'  'melonds_jit_fast_memory' '"enabled"'
	RetroArch_setOverride 'melonDS.opt' 'melonDS'  'melonds_jit_literal_optimisations' '"enabled"'
	RetroArch_setOverride 'melonDS.opt' 'melonDS'  'melonds_opengl_better_polygons' '"enabled"'
	RetroArch_setOverride 'melonDS.opt' 'melonDS'  'melonds_opengl_filtering' '"nearest"'
	RetroArch_setOverride 'melonDS.opt' 'melonDS'  'melonds_opengl_renderer' '"enabled"'
	RetroArch_setOverride 'melonDS.opt' 'melonDS'  'melonds_opengl_resolution' '"5x native (1280x960)"'
	RetroArch_setOverride 'melonDS.opt' 'melonDS'  'melonds_randomize_mac_address' '"disabled"'
	RetroArch_setOverride 'melonDS.opt' 'melonDS'  'melonds_screen_gap' '"0"'
	RetroArch_setOverride 'melonDS.opt' 'melonDS'  'melonds_screen_layout' '"Hybrid Bottom"'
	RetroArch_setOverride 'melonDS.opt' 'melonDS'  'melonds_swapscreen_mode' '"Toggle"'
	RetroArch_setOverride 'melonDS.opt' 'melonDS'  'melonds_threaded_renderer' '"disabled"'
	RetroArch_setOverride 'melonDS.opt' 'melonDS'  'melonds_touch_mode' '"Touch"'
}

RetroArch_melonDS_setConfig(){
	RetroArch_setOverride 'nds.cfg' 'melonDS'  'rewind_enable' '"false"'
}

RetroArch_melonDSDS_setUpCoreOpt(){
	RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_audio_bitdepth' '"auto"'
	RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_audio_interpolation' '"disabled"'
	RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_boot_mode' '"disabled"'
	RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS' 'melonds_console_mode' '"ds"'
	RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_dsi_sdcard' '"enabled"'
	RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_hybrid_ratio' '"2"'
	RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_hybrid_small_screen' '"both"'
	RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_jit_block_size' '"32"'
	RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_jit_branch_optimisations' '"enabled"'
	RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_jit_enable' '"enabled"'
	RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_jit_fast_memory' '"enabled"'
	RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_jit_literal_optimisations' '"enabled"'
	RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_opengl_better_polygons' '"enabled"'
	RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_opengl_filtering' '"nearest"'
	RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_render_mode' '"software"'
	RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_opengl_resolution' '"5"'
	RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_show_mic_state' '"disabled"'
#	Unsupported in melonDSDS at this time.
#	RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_randomize_mac_address' '"disabled"'
	RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_screen_gap' '"0"'
#	No equivalent in melonDSDS at this time.
#	RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_screen_layout' '"Hybrid Bottom"'
#	No equivalent in melonDSDS at this time.
#	RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_swapscreen_mode' '"Toggle"'
	RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_threaded_renderer' '"enabled"'
	RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_touch_mode' '"auto"'
	# Screen layouts
	RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_show_current_layout' '"disabled"'
	RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_number_of_screen_layouts ' '"8"'
	RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_screen_layout1' '"hybrid-top"'
	RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_screen_layout2' '"hybrid-bottom"'
	RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_screen_layout3' '"top"'
	RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_screen_layout4' '"bottom"'
	RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_screen_layout5' '"top-bottom"'
	RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_screen_layout6' '"left-right"'
	RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_screen_layout7' '"bottom-top"'
	RetroArch_setOverride 'melonDS DS.opt' 'melonDS DS'  'melonds_screen_layout8' '"right-left"'

}

RetroArch_melonDSDS_setConfig(){
	RetroArch_setOverride 'melonDS DS.cfg' 'melonDS DS'  'rewind_enable' '"true"'
	RetroArch_setOverride 'melonDS DS.cfg' 'melonDS DS'  'rewind_granularity' '"6"'
}

RetroArch_Mupen64Plus_Next_setUpCoreOpt(){
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-169screensize' '"1920x1080"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-43screensize' '"1280x960"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-alt-map' '"False"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-angrylion-multithread' '"all threads"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-angrylion-overscan' '"disabled"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-angrylion-sync' '"Low"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-angrylion-vioverlay' '"Filtered"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-aspect' '"4:3"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-astick-deadzone' '"15"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-astick-sensitivity' '"100"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-BackgroundMode' '"OnePiece"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-BilinearMode' '"standard"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-CorrectTexrectCoords' '"Auto"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-CountPerOp' '"0"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-CountPerOpDenomPot' '"0"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-cpucore' '"dynamic_recompiler"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-d-cbutton' '"C3"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-DitheringPattern' '"False"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-DitheringQuantization' '"False"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-EnableCopyAuxToRDRAM' '"False"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-EnableCopyColorToRDRAM' '"Async"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-EnableCopyDepthToRDRAM' '"Software"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-EnableEnhancedHighResStorage' '"True"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-EnableEnhancedTextureStorage' '"True"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-EnableFBEmulation' '"True"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-EnableFragmentDepthWrite' '"True"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-EnableHiResAltCRC' '"False"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-EnableHWLighting' '"False"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-EnableInaccurateTextureCoordinates' '"False"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-EnableLegacyBlending' '"False"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-EnableLODEmulation' '"True"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-EnableN64DepthCompare' '"False"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-EnableNativeResFactor' '"4"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-EnableNativeResTexrects' '"Optimized"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-EnableOverscan' '"Enabled"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-EnableShadersStorage' '"True"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-EnableTexCoordBounds' '"True"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-EnableTextureCache' '"True"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-ForceDisableExtraMem' '"False"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-FrameDuping' '"False"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-Framerate' '"Fullspeed"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-FXAA' '"0"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-GLideN64IniBehaviour' '"late"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-HybridFilter' '"False"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-IgnoreTLBExceptions' '"False"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-l-cbutton' '"C2"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-MaxHiResTxVramLimit' '"0"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-MaxTxCacheSize' '"8000"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-MultiSampling' '"0"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-OverscanBottom' '"0"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-OverscanLeft' '"0"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-OverscanRight' '"0"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-OverscanTop' '"0"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-pak1' '"memory"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-pak2' '"none"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-pak3' '"none"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-pak4' '"none"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-parallel-rdp-deinterlace-method' '"Bob"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-parallel-rdp-dither-filter' '"True"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-parallel-rdp-divot-filter' '"True"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-parallel-rdp-downscaling' '"disable"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-parallel-rdp-gamma-dither' '"True"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-parallel-rdp-native-tex-rect' '"True"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-parallel-rdp-native-texture-lod' '"False"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-parallel-rdp-overscan' '"0"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-parallel-rdp-super-sampled-read-back' '"False"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-parallel-rdp-super-sampled-read-back-dither' '"False"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-parallel-rdp-synchronous' '"True"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-parallel-rdp-upscaling' '"1x"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-parallel-rdp-vi-aa' '"True"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-parallel-rdp-vi-bilinear' '"True"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-r-cbutton' '"C1"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-rdp-plugin' '"gliden64"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-RDRAMImageDitheringMode' '"False"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-rsp-plugin' '"hle"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-ThreadedRenderer' '"True"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-txEnhancementMode' '"As Is"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-txFilterIgnoreBG' '"True"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-txFilterMode' '"None"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-txHiresEnable' '"True"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-txHiresFullAlphaChannel' '"False"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-u-cbutton' '"C4"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-virefresh' '"Auto"'

	# hd pack settings
	# Commenting these out. These seem to be causing a lot of graphical issues. 
	#RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-txHiresEnable' '"True"'
	#RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-txHiresFullAlphaChannel' '"True"'
	#RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-txCacheCompression' '"True"'
	#RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-EnableEnhancedHighResStorage' '"True"'
	#RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-EnableEnhancedTextureStorage' '"False"' # lazy loading
	
	# revert hd pack settings
	# These seem to be causing a lot of graphical issues. 
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-txHiresEnable' '"False"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-txHiresFullAlphaChannel' '"False"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-txCacheCompression' '"False"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-EnableEnhancedHighResStorage' '"False"'
	RetroArch_setOverride 'Mupen64Plus-Next.opt' 'Mupen64Plus-Next'  'mupen64plus-EnableEnhancedTextureStorage' '"False"' # lazy loading

}

#  setupHdPacks()
RetroArch_Mupen64Plus_Next_setUpHdPacks(){
  	local texturePackPath="$HOME/.var/app/org.libretro.RetroArch/config/retroarch/system/Mupen64plus/hires_texture"
	local textureCachePath="$HOME/.var/app/org.libretro.RetroArch/config/retroarch/system/Mupen64plus/cache"

	# Something in the install is causng infinite symlinks, commenting these lines out for now and deleting folders. Needs more thorough testing. 
	rm -rf "$emulationPath/hdpacks/retroarch/Mupen64plus"
	rm -rf "$biosPath/Mupen64plus/cache/"

	#mkdir -p "$texturePackPath"
	#mkdir -p "$textureCachePath"
	#mkdir -p "$emulationPath/hdpacks/retroarch/Mupen64plus"
	#ln -s "$emulationPath/hdpacks/retroarch/Mupen64plus/hires_texture" "$texturePackPath"
	#ln -s "$emulationPath/hdpacks/retroarch/Mupen64plus/cache" "$textureCachePath"
	#N64
	#unlink "$emulationPath"/hdpacks/Mupen64plus_next 2>/dev/null #refresh link if moved
	#mkdir "$biosPath"/Mupen64plus
	#ln -s "$biosPath"/Mupen64plus/cache/ "$emulationPath"/hdpacks/n64
	#echo "Put your Nintendo64 HD Packs here in HTS format. You can download them from https://emulationking.com/nintendo64/" > "$emulationPath"/hdpacks/n64/readme.txt

}

RetroArch_Beetle_PSX_HW_setUpCoreOpt(){
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_adaptive_smoothing' '"disabled"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_analog_calibration' '"disabled"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_analog_toggle' '"disabled"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_aspect_ratio' '"corrected"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_cd_access_method' '"sync"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_cd_fastload' '"2x(native)"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_core_timing_fps' '"force_progressive"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_cpu_dynarec' '"disabled"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_cpu_freq_scale' '"100%(native)"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_crop_overscan' '"smart"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_crosshair_color_p1' '"red"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_crosshair_color_p2' '"blue"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_depth' '"16bpp(native)"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_display_internal_fps' '"disabled"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_display_vram' '"disabled"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_dither_mode' '"1x(native)"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_dump_textures' '"disabled"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_dynarec_eventcycles' '"128"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_dynarec_invalidate' '"full"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_enable_memcard1' '"enabled"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_enable_multitap_port1' '"disabled"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_enable_multitap_port2' '"disabled"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_filter' '"nearest"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_filter_exclude_2d_polygon' '"disabled"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_filter_exclude_sprite' '"disabled"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_frame_duping' '"disabled"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_gpu_overclock' '"1x(native)"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_gte_overclock' '"disabled"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_gun_cursor' '"cross"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_gun_input_mode' '"lightgun"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_image_crop' '"disabled"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_image_offset' '"disabled"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_image_offset_cycles' '"0"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_initial_scanline' '"0"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_initial_scanline_pal' '"0"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_internal_resolution' '"2x"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_last_scanline' '"239"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_last_scanline_pal' '"287"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_line_render' '"default"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_mdec_yuv' '"disabled"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_memcard_left_index' '"0"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_memcard_right_index' '"1"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_mouse_sensitivity' '"100%"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_msaa' '"1x"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_negcon_deadzone' '"0%"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_negcon_response' '"linear"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_override_bios' '"disabled"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_pal_video_timing_override' '"disabled"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_pgxp_2d_tol' '"disabled"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_pgxp_mode' '"disabled"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_pgxp_nclip' '"disabled"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_pgxp_texture' '"disabled"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_pgxp_vertex' '"disabled"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_renderer' '"hardware"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_renderer_software_fb' '"enabled"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_replace_textures' '"disabled"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_scaled_uv_offset' '"enabled"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_shared_memory_cards' '"disabled"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_skip_bios' '"disabled"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_super_sampling' '"disabled"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_track_textures' '"disabled"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_use_mednafen_memcard0_method' '"libretro"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_widescreen_hack' '"disabled"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_widescreen_hack_aspect_ratio' '"16:9"'
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_wireframe' '"disabled"'
}

RetroArch_Flycast_setUpCoreOpt(){
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_allow_service_buttons' '"disabled"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_alpha_sorting' '"per-triangle (normal)"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_analog_stick_deadzone' '"15%"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_anisotropic_filtering' '"4"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_auto_skip_frame' '"disabled"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_boot_to_bios' '"disabled"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_broadcast' '"NTSC"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_cable_type' '"TV'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_custom_textures' '"disabled"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_delay_frame_swapping' '"disabled"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_digital_triggers' '"disabled"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_dump_textures' '"disabled"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_enable_dsp' '"enabled"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_enable_purupuru' '"enabled"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_enable_rttb' '"disabled"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_fog' '"enabled"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_force_wince' '"disabled"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_frame_skipping' '"disabled"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_gdrom_fast_loading' '"disabled"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_hle_bios' '"disabled"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_internal_resolution' '"960x720"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_language' '"English"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_lightgun1_crosshair' '"disabled"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_lightgun2_crosshair' '"disabled"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_lightgun3_crosshair' '"disabled"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_lightgun4_crosshair' '"disabled"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_mipmapping' '"enabled"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_oit_abuffer_size' '"512MB"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_per_content_vmus' '"disabled"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_pvr2_filtering' '"disabled"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_region' '"USA"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_screen_rotation' '"horizontal"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_show_lightgun_settings' '"disabled"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_show_vmu_screen_settings' '"disabled"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_texupscale' '"1"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_texupscale_max_filtered_texture_size' '"256"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_threaded_rendering' '"enabled"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_trigger_deadzone' '"0%"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_vmu1_pixel_off_color' '"DEFAULT_OFF 01"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_vmu1_pixel_on_color' '"DEFAULT_ON 00"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_vmu1_screen_display' '"disabled"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_vmu1_screen_opacity' '"100%"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_vmu1_screen_position' '"Upper Left"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_vmu1_screen_size_mult' '"1x"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_vmu2_pixel_off_color' '"DEFAULT_OFF 01"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_vmu2_pixel_on_color' '"DEFAULT_ON 00"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_vmu2_screen_display' '"disabled"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_vmu2_screen_opacity' '"100%"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_vmu2_screen_position' '"Upper Left"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_vmu2_screen_size_mult' '"1x"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_vmu3_pixel_off_color' '"DEFAULT_OFF 01"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_vmu3_pixel_on_color' '"DEFAULT_ON 00"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_vmu3_screen_display' '"disabled"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_vmu3_screen_opacity' '"100%"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_vmu3_screen_position' '"Upper Left"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_vmu3_screen_size_mult' '"1x"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_vmu4_pixel_off_color' '"DEFAULT_OFF 01"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_vmu4_pixel_on_color' '"DEFAULT_ON 00"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_vmu4_screen_display' '"disabled"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_vmu4_screen_opacity' '"100%"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_vmu4_screen_position' '"Upper Left"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_vmu4_screen_size_mult' '"1x"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_volume_modifier_enable' '"enabled"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_widescreen_cheats' '"disabled"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_widescreen_hack' '"disabled"'
}

RetroArch_Gambatte_setUpCoreOpt(){
	RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_audio_resampler' '"sinc"'
	RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_dark_filter_level' '"0"'
	RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_gb_bootloader' '"enabled"'
	RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_gb_colorization' '"auto"'
	RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_gb_hwmode' '"Auto"'
	RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_gb_internal_palette' '"GB - DMG"'
	RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_gb_link_mode' '"Not Connected"'
	RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_gb_link_network_port' '"56400"'
	RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_gb_link_network_server_ip_1' '"0"'
	RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_gb_link_network_server_ip_10' '"0"'
	RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_gb_link_network_server_ip_11' '"0"'
	RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_gb_link_network_server_ip_12' '"0"'
	RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_gb_link_network_server_ip_2' '"0"'
	RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_gb_link_network_server_ip_3' '"0"'
	RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_gb_link_network_server_ip_4' '"0"'
	RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_gb_link_network_server_ip_5' '"0"'
	RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_gb_link_network_server_ip_6' '"0"'
	RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_gb_link_network_server_ip_7' '"0"'
	RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_gb_link_network_server_ip_8' '"0"'
	RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_gb_link_network_server_ip_9' '"0"'
	RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_gb_palette_pixelshift_1' '"PixelShift 01 - Arctic Green"'
	RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_gb_palette_twb64_1' '"WB64 001 - Aqours Blue"'
	RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_gb_palette_twb64_2' '"TWB64 101 - 765PRO Pink"'
	RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_gbc_color_correction' '"GBC only"'
	RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_gbc_color_correction_mode' '"accurate"'
	RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_gbc_frontlight_position' '"central"'
	RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_mix_frames' '"disabled"'
	RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_rumble_level' '"10"'
	RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_show_gb_link_settings' '"disabled"'
	RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_turbo_period' '"4"'
	RetroArch_setOverride 'Gambatte.opt' 'Gambatte'  'gambatte_up_down_allowed' '"disabled"'
}

RetroArch_Nestopia_setUpCoreOpt(){
	RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_arkanoid_device' '"mouse"'
	RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_aspect' '"auto"'
	RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_audio_vol_dpcm' '"100"'
	RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_audio_vol_fds' '"100"'
	RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_audio_vol_mmc5' '"100"'
	RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_audio_vol_n163' '"100"'
	RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_audio_vol_noise' '"100"'
	RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_audio_vol_s5b' '"100"'
	RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_audio_vol_sq1' '"100"'
	RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_audio_vol_sq2' '"100"'
	RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_audio_vol_tri' '"100"'
	RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_audio_vol_vrc6' '"100"'
	RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_audio_vol_vrc7' '"100"'
	RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_blargg_ntsc_filter' '"disabled"'
	RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_button_shift' '"disabled"'
	RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_favored_system' '"auto"'
	RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_fds_auto_insert' '"enabled"'
	RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_genie_distortion' '"disabled"'
	RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_nospritelimit' '"disabled"'
	RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_overclock' '"1x"'
	RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_overscan_h' '"disabled"'
	RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_overscan_v' '"enabled"'
	RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_palette' '"cxa2025as"'
	RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_ram_power_state' '"0x00"'
	RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_select_adapter' '"auto"'
	RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_show_advanced_av_settings' '"disabled"'
	RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_show_crosshair' '"enabled"'
	RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_turbo_pulse' '"2"'
	RetroArch_setOverride 'Nestopia.opt' 'Nestopia'  'nestopia_zapper_device' '"lightgun"'
}
RetroArch_bsnes_hd_beta_setUpCoreOpt(){
	RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_blur_emulation' '"OFF"'
	RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_coprocessor_delayed_sync' '"ON"'
	RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_coprocessor_prefer_hle' '"ON"'
	RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_cpu_fastmath' '"OFF"'
	RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_cpu_overclock' '"100"'
	RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_cpu_sa1_overclock' '"100"'
	RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_cpu_sfx_overclock' '"100"'
	RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_dsp_cubic' '"OFF"'
	RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_dsp_echo_shadow' '"OFF"'
	RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_dsp_fast' '"ON"'
	RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_entropy' '"Low"'
	RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_hotfixes' '"OFF"'
	RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_ips_headered' '"OFF"'
	RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_mode7_bgGrad' '"4"'
	RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_mode7_igwin' '"outside"'
	RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_mode7_igwinx' '"128"'
	RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_mode7_mosaic' '"1x scale"'
	RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_mode7_perspective' '"on'
	RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_mode7_scale' '"1x"'
	RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_mode7_strWin' '"OFF"'
	RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_mode7_supersample' '"none"'
	RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_mode7_widescreen' '"16:10"'
	RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_mode7_windRad' '"0"'
	RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_mode7_wsbg1' '"auto horz and vert"'
	RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_mode7_wsbg2' '"auto horz and vert"'
	RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_mode7_wsbg3' '"auto horz and vert"'
	RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_mode7_wsbg4' '"auto horz and vert"'
	RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_mode7_wsBgCol' '"auto"'
	RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_mode7_wsMarker' '"none"'
	RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_mode7_wsMarkerAlpha' '"1/1"'
	RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_mode7_wsMode' '"all"'
	RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_mode7_wsobj' '"safe"'
	RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_ppu_deinterlace' '"ON"'
	RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_ppu_fast' '"ON"'
	RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_ppu_no_sprite_limit' '"ON"'
	RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_ppu_no_vram_blocking' '"OFF"'
	RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_ppu_show_overscan' '"OFF"'
	RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_run_ahead_frames' '"OFF"'
	RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_sgb_bios' '"SGB1.sfc"'
	RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_video_aspectcorrection' '"OFF"'
	RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_video_gamma' '"100"'
	RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_video_luminance' '"100"'
	RetroArch_setOverride 'bsnes-hd beta.opt' 'bsnes-hd beta'  'bsnes_video_saturation' '"100"'
}

RetroArch_dos_box_setUpCoreOpt(){
	RetroArch_setOverride 'DOSBox-pure.opt' 'DOSBox-pure'  'dosbox_pure_conf' '"inside"'
}

RetroArch_setUpCoreOptAll(){

	for func in $(compgen -A 'function' | grep '\_setUpCoreOpt$')
		do echo  "$func" && "$func"
	done
}

RetroArch_setConfigAll(){

	for func in $(compgen -A 'function' | grep '\_setConfig$' | grep '^RetroArch_' )
		do echo  "$func" && "$func"
	done
}

RetroArch_Flycast_wideScreenOn(){
	RetroArch_setOverride 'Flycast.opt' 	'Flycast'  	'reicast_widescreen_cheats' 	'"enabled"'
	RetroArch_setOverride 'Flycast.opt' 	'Flycast'  	'reicast_widescreen_hack' 	'"enabled"'
	RetroArch_setOverride 'dreamcast.cfg' 	'Flycast'  	'aspect_ratio_index' 		'"1"'
	RetroArch_dreamcast_bezelOff
	RetroArch_dreamcast_3DCRTshaderOff
}

RetroArch_Flycast_wideScreenOff(){
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_widescreen_cheats' '"disabled"'
	RetroArch_setOverride 'Flycast.opt' 'Flycast'  'reicast_widescreen_hack' '"disabled"'
	RetroArch_setOverride 'dreamcast.cfg' 'Flycast'  'aspect_ratio_index' '"0"'
}

RetroArch_Beetle_PSX_HW_wideScreenOn(){
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_widescreen_hack' '"enabled"'
	RetroArch_setOverride 'Beetle PSX.opt' 'Beetle PSX'  'beetle_psx_hw_widescreen_hack' '"enabled"'
	RetroArch_psx_bezelOff
}

RetroArch_Beetle_PSX_HW_wideScreenOff(){
	RetroArch_setOverride 'Beetle PSX HW.opt' 'Beetle PSX HW'  'beetle_psx_hw_widescreen_hack' '"disabled"'
	RetroArch_setOverride 'Beetle PSX.opt' 'Beetle PSX'  'beetle_psx_hw_widescreen_hack' '"disabled"'
}


RetroArch_SwanStation_setConfig(){
	RetroArch_setOverride 'SwanStation.opt' 'SwanStation'  'duckstation_GPU.ResolutionScale' '"3"'
}

RetroArch_SwanStation_wideScreenOn(){
	RetroArch_setOverride 'SwanStation.opt' 'SwanStation'  'duckstation_GPU.WidescreenHack' '"true"'
	RetroArch_setOverride 'SwanStation.opt' 'SwanStation'  'duckstation_Display.AspectRatio' '"16:9"'
	RetroArch_setOverride 'psx.cfg' 'SwanStation'  'aspect_ratio_index' '"1"'
	RetroArch_psx_bezelOff
}

RetroArch_SwanStation_wideScreenOff(){
	RetroArch_setOverride 'SwanStation.opt' 'SwanStation'  'duckstation_GPU.WidescreenHack' '"false"'
	RetroArch_setOverride 'SwanStation.opt' 'SwanStation'  'duckstation_Display.AspectRatio' '"auto"'
	RetroArch_setOverride 'psx.cfg' 'SwanStation'  'aspect_ratio_index' '"0"'
}

RetroArch_psx_bezelOn(){
	RetroArch_setOverride 'psx.cfg' 'Beetle PSX HW' 'input_overlay_enable' '"true"'
	RetroArch_setOverride 'psx.cfg' 'Beetle PSX HW' 'aspect_ratio_index' '"0"'
	RetroArch_setOverride 'psx.cfg' 'Beetle PSX HW' 'input_overlay' "\"$RetroArch_overlaysPath/pegasus/psx.cfg\""
	RetroArch_setOverride 'psx.cfg' 'Beetle PSX HW' 'input_overlay_aspect_adjust_landscape' '"0.100000"'
	RetroArch_setOverride 'psx.cfg' 'Beetle PSX HW' 'input_overlay_enable' '"true"'
	RetroArch_setOverride 'psx.cfg' 'Beetle PSX HW' 'input_overlay_scale_landscape' '"1.060000"'
	RetroArch_setOverride 'psx.cfg' 'Beetle PSX' 'input_overlay_enable' '"true"'
	RetroArch_setOverride 'psx.cfg' 'Beetle PSX' 'aspect_ratio_index' '"0"'
	RetroArch_setOverride 'psx.cfg' 'Beetle PSX' 'input_overlay' "\"$RetroArch_overlaysPath/pegasus/psx.cfg\""
	RetroArch_setOverride 'psx.cfg' 'Beetle PSX' 'input_overlay_aspect_adjust_landscape' '"0.100000"'
	RetroArch_setOverride 'psx.cfg' 'Beetle PSX' 'input_overlay_enable' '"true"'
	RetroArch_setOverride 'psx.cfg' 'Beetle PSX' 'input_overlay_scale_landscape' '"1.060000"'
	RetroArch_setOverride 'psx.cfg' 'SwanStation' 'input_overlay_enable' '"true"'
	RetroArch_setOverride 'psx.cfg' 'SwanStation' 'aspect_ratio_index' '"0"'
	RetroArch_setOverride 'psx.cfg' 'SwanStation' 'input_overlay' "\"$RetroArch_overlaysPath/pegasus/psx.cfg\""
	RetroArch_setOverride 'psx.cfg' 'SwanStation' 'input_overlay_aspect_adjust_landscape' '"0.100000"'
	RetroArch_setOverride 'psx.cfg' 'SwanStation' 'input_overlay_enable' '"true"'
	RetroArch_setOverride 'psx.cfg' 'SwanStation' 'input_overlay_scale_landscape' '"1.060000"'
}


RetroArch_psx_bezelOff(){
	RetroArch_setOverride 'psx.cfg' 'Beetle PSX HW'  'input_overlay_enable' '"false"'
	RetroArch_setOverride 'psx.cfg' 'Beetle PSX'  'input_overlay_enable' '"false"'
	RetroArch_setOverride 'psx.cfg' 'SwanStation'  'input_overlay_enable' '"false"'
}

 RetroArch_psx_3DCRTshaderOn(){
	 RetroArch_setOverride 'psx.cfg' 'Beetle PSX HW'  'video_shader_enable' 'true'
	RetroArch_setOverride 'psx.cfg' 'Beetle PSX HW'	'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'psx.cfg' 'Beetle PSX HW'	'video_smooth' 'ED_RM_LINE'

	 RetroArch_setOverride 'psx.cfg' 'Beetle PSX'  'video_shader_enable' 'true'
	RetroArch_setOverride 'psx.cfg' 'Beetle PSX'	'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'psx.cfg' 'Beetle PSX'	'video_smooth' 'ED_RM_LINE'

	 RetroArch_setOverride 'psx.cfg' 'SwanStation'  'video_shader_enable' 'true'
	RetroArch_setOverride 'psx.cfg' 'SwanStation'	'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'psx.cfg' 'SwanStation'	'video_smooth' 'ED_RM_LINE'
 }

RetroArch_psx_3DCRTshaderOff(){
	RetroArch_setOverride 'psx.cfg' 'Beetle PSX HW'  'video_shader_enable' '"false"'
	RetroArch_setOverride 'psx.cfg' 'Beetle PSX HW'	'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'psx.cfg' 'Beetle PSX HW'	'video_smooth' 'ED_RM_LINE'

	RetroArch_setOverride 'psx.cfg' 'Beetle PSX'  'video_shader_enable' '"false"'
	RetroArch_setOverride 'psx.cfg' 'Beetle PSX'	'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'psx.cfg' 'Beetle PSX'	'video_smooth' 'ED_RM_LINE'

	RetroArch_setOverride 'psx.cfg' 'SwanStation'  'video_shader_enable' '"false"'
	RetroArch_setOverride 'psx.cfg' 'SwanStation'	'video_filter' 'ED_RM_LINE'
	RetroArch_setOverride 'psx.cfg' 'SwanStation'	'video_smooth' 'ED_RM_LINE'
}

RetroArch_psx_setConfig(){
	RetroArch_psx_3DCRTshaderOff
}

RetroArch_cdi_setConfig(){
	mkdir -p "${biosPath}/same_cdi/bios"
}

#BezelOn
RetroArch_bezelOnAll(){
	for func in $(compgen -A 'function' | grep '\_bezelOn$' | grep '^RetroArch_' | grep -v "RetroArch_bezelOn")
		do echo  "$func" && "$func"
	done
}

#BezelOff
RetroArch_bezelOffAll(){
	for func in $(compgen -A 'function' | grep '\_bezelOff$' | grep '^RetroArch_')
		do echo  "$func" && "$func"
	done
}

#shadersCRTOn
RetroArch_CRTshaderOnAll(){
	for func in $(compgen -A 'function' | grep '\_CRTshaderOn$' | grep '^RetroArch_' | grep -v "RetroArch_bezelOn")
		do echo  "$func" && "$func"
	done
}

#shadersCRTOff
RetroArch_CRTshaderOffAll(){
	for func in $(compgen -A 'function' | grep '\_CRTshaderOff$' | grep '^RetroArch_')
		do echo  "$func" && "$func"
	done
}

#shaders3DCRTOn
RetroArch_3DCRTshaderOnAll(){
	for func in $(compgen -A 'function' | grep '\_3DCRTshaderOn$' | grep '^RetroArch_' | grep -v "RetroArch_bezelOn")
		do echo  "$func" && "$func"
	done
}

#shaders3DCRTOff
RetroArch_3DCRTshaderOffAll(){
	for func in $(compgen -A 'function' | grep '\_3DCRTshaderOff$' | grep '^RetroArch_')
		do echo  "$func" && "$func"
	done
}
#shadersMATOn
RetroArch_MATshadersOnAll(){
	for func in $(compgen -A 'function' | grep '\_MATshaderOn$' | grep '^RetroArch_' | grep -v "RetroArch_bezelOn")
		do echo  "$func" && "$func"
	done
}

#shadersMATOff
RetroArch_MATshadersOffAll(){
	for func in $(compgen -A 'function' | grep '\_MATshaderOff$' | grep '^RetroArch_')
		do echo  "$func" && "$func"
	done
}


#finalExec - Extra stuff
RetroArch_finalize(){
	echo "NYI"
}

RetroArch_installCores(){

	#Requests for:
	#GP32
	#N-gage
	#Game.com


	mkdir -p "$RetroArch_cores"

	#This is all the cores combined, and dupes taken out.
	RAcores=(
				81_libretro \
				a5200_libretro \
				arduous_libretro \
				atari800_libretro \
				blastem_libretro \
				bluemsx_libretro \
				bsnes_hd_beta_libretro \
				bsnes_libretro \
				cap32_libretro \
				chailove_libretro \
				citra_libretro \
				desmume_libretro \
				dosbox_core_libretro \
				dosbox_pure_libretro \
				easyrpg_libretro \
				fbalpha2012_libretro \
				fbneo_libretro \
				flycast_libretro \
				freechaf_libretro \
				freeintv_libretro \
				fuse_libretro \
				gambatte_libretro \
				gearboy_libretro \
				gearsystem_libretro \
				genesis_plus_gx_libretro \
				genesis_plus_gx_wide_libretro \
				gw_libretro \
				handy_libretro \
				hatari_libretro \
				kronos_libretro \
				lutro_libretro \
				mame2003_plus_libretro \
				mame_libretro \
				mednafen_lynx_libretro \
				mednafen_ngp_libretro \
				mednafen_pce_fast_libretro \
				mednafen_pce_libretro \
				mednafen_pcfx_libretro \
				mednafen_psx_hw_libretro \
				mednafen_saturn_libretro \
				mednafen_supergrafx_libretro \
				mednafen_vb_libretro \
				mednafen_wswan_libretro \
				melonds_libretro \
				melondsds_libretro \
				mesen_libretro \
				mesen-s_libretro \
				mgba_libretro \
				minivmac_libretro \
				mu_libretro \
				mupen64plus_next_libretro \
				neocd_libretro \
				nestopia_libretro \
				np2kai_libretro \
				nxengine_libretro \
				o2em_libretro \
				opera_libretro \
				picodrive_libretro \
				pokemini_libretro \
				potator_libretro \
				ppsspp_libretro \
				prboom_libretro \
				prosystem_libretro \
				puae_libretro \
				px68k_libretro \
				quasi88_libretro \
				retro8_libretro \
				same_cdi_libretro \
				sameboy_libretro \
				sameduck_libretro \
				scummvm_libretro \
				snes9x_libretro \
				squirreljme_libretro \
				stella_libretro \
				swanstation_libretro \
				theodore_libretro \
				tic80_libretro \
				tyrquake_libretro \
				uzem_libretro \
				vbam_libretro \
				vecx_libretro \
				vice_x128_libretro \
				vice_x64sc_libretro \
				vice_xscpu64_libretro \
				vice_xvic_libretro \
				virtualjaguar_libretro \
				vitaquake2_libretro \
				vitaquake2-rogue_libretro \
				vitaquake2-xatrix_libretro \
				vitaquake2-zaero_libretro \
				vitaquake3_libretro \
				wasm4_libretro \
				x1_libretro \
			)
	setMSG "Downloading RetroArch Cores for EmuDeck"
	for i in "${RAcores[@]}"
	do
		FILE="${RetroArch_cores}/${i}.*"
		if [ -f "$FILE" ]; then
			echo "${i}...Already Downloaded"
		else
			curl "$RetroArch_coresURL$i.$RetroArch_coresExtension" --output "$RetroArch_cores/${i}.zip"

			#rm ~/.var/app/org.libretro.RetroArch/config/retroarch/cores/${i}.zip
			echo "${i}...Downloaded!"
		fi
	done


	for entry in "$RetroArch_cores"/*.zip
	do
		 unzip -q -o "$entry" -d "$RetroArch_cores"
	done

	for entry in "$RetroArch_cores"/*.zip

	do
		 rm -f "$entry"
	done



}

#RetroArch_dlAdditionalFiles

function RetroArch_dlAdditionalFiles(){
	#EasyRPG
	mkdir -p "$biosPath/rtp/2000"
	mkdir -p "$biosPath/rtp/2003"

	curl -L https://dl.degica.com/rpgmakerweb/run-time-packages/rpg2003_rtp_installer.zip --output "$biosPath/rtp/2003/rpg2003.zip.tmp" && mv "$biosPath/rtp/2003/rpg2003.zip.tmp" "$biosPath/rtp/2003/rpg2003.zip"
	curl -L https://dl.degica.com/rpgmakerweb/run-time-packages/rpg2000_rtp_installer.exe --output "$biosPath/rtp/2000/rpg2000.zip.tmp" && mv "$biosPath/rtp/2000/rpg2000.zip.tmp" "$biosPath/rtp/2000/rpg2000.zip"

	7z x "$biosPath/rtp/2003/rpg2003.zip" -o"$biosPath/rtp/2003" && rm "$biosPath/rtp/2003/rpg2003.zip"
	7z x "$biosPath/rtp/2003/rpg2003_rtp_installer.exe" -o"$biosPath/rtp/2003" && rm "$biosPath/rtp/2003/rpg2003_rtp_installer.exe"
	7z x "$biosPath/rtp/2000/rpg2000.zip" -o"$biosPath/rtp/2000" && rm "$biosPath/rtp/2000/rpg2000.zip"
}


function RetroArch_resetCoreConfigs(){

	find "$RetroArch_coreConfigFolders" -type f -iname "*.cfg" -o -type f -iname "*.opt"| while read -r file
		do
			mv "$file"  "$file".bak
		done
	RetroArch_init
	echo "true"
}

RetroArch_autoSaveOn(){
	RetroArch_setConfigOverride 'savestate_auto_load' '"true"' "$RetroArch_configFile"
	RetroArch_setConfigOverride 'savestate_auto_save' '"true"' "$RetroArch_configFile"
}
RetroArch_autoSaveOff(){
	RetroArch_setConfigOverride 'savestate_auto_load' '"false"' "$RetroArch_configFile"
	RetroArch_setConfigOverride 'savestate_auto_save' '"false"' "$RetroArch_configFile"
}
RetroArch_retroAchievementsOn(){
	iniFieldUpdate "$RetroArch_configFile" "" "cheevos_enable" "true"
	#Mame fix
	#RetroArch_setOverride 'mame.cfg' 'MAME 2003-Plus'  'cheevos_enable' '"false"'
	#RetroArch_setOverride 'mame.cfg' 'MAME'  'cheevos_enable' '"false"'
}
RetroArch_retroAchievementsOff(){
	iniFieldUpdate "$RetroArch_configFile" "" "cheevos_enable" "false"
	#Mame fix
	#RetroArch_setOverride 'mame.cfg' 'MAME 2003-Plus'  'cheevos_enable' '"false"'
	#RetroArch_setOverride 'mame.cfg' 'MAME'  'cheevos_enable' '"false"'
}

RetroArch_retroAchievementsHardCoreOn(){
	RetroArch_setConfigOverride 'cheevos_hardcore_mode_enable' '"true"' "$RetroArch_configFile"
	RetroArch_setOverride 'FinalBurn Neo.opt' 'FinalBurn Neo'  'fbneo-allow-patched-romsets' '"disabled"'

}
RetroArch_retroAchievementsHardCoreOff(){
	RetroArch_setConfigOverride 'cheevos_hardcore_mode_enable' '"false"' "$RetroArch_configFile"
	RetroArch_setOverride 'FinalBurn Neo.opt' 'FinalBurn Neo'  'fbneo-allow-patched-romsets' '"enabled"'
}

RetroArch_retroAchievementsPromptLogin(){
	text=$(printf "Do you want to use RetroAchievments on Retroarch?\n\n<b>You need to have an account on https://retroachievements.org</b>\n\nActivating RetroAchievments will disable save states unless you disable hardcore mode\n\n\n\nPress STEAM + X to get the onscreen Keyboard\n\n<b>Make sure your RetroAchievments account is validated on the website or RetroArch will crash</b>")
	RAInput=$(zenity --forms \
			--title="Retroachievements Sign in" \
			--text="$text" \
			--add-entry="Username: " \
			--add-password="Password: " \
			--separator="," 2>/dev/null)
			ans=$?
	if [ $ans -eq 0 ]; then
		echo "RetroAchievment Login"
		echo "$RAInput" | awk -F "," '{print $1}' > "$HOME/.config/EmuDeck/.rau"
		echo "$RAInput" | awk -F "," '{print $2}' > "$HOME/.config/EmuDeck/.rap"
	else
		echo "Cancel RetroAchievment Login"
	fi
}
RetroArch_retroAchievementsSetLogin(){
	rm -rf "$HOME/.config/EmuDeck/.rap"
	rau=$(cat "$HOME/.config/EmuDeck/.rau")
	rat=$(cat "$HOME/.config/EmuDeck/.rat")
	echo "Evaluate RetroAchievements Login."
	if [ ${#rat} -lt 1 ]; then
		echo "--No token."
	elif [ ${#rau} -lt 1 ]; then
		echo "--No username."
	else
		echo "Valid Retroachievements Username and Password length"
		RetroArch_setConfigOverride 'cheevos_username' '"'"${rau}"'"' "$RetroArch_configFile" &>/dev/null && echo 'RetroAchievements Username set.' || echo 'RetroAchievements Username not set.'
		RetroArch_setConfigOverride 'cheevos_token' '"'"${rat}"'"' "$RetroArch_configFile" &>/dev/null && echo 'RetroAchievements Token set.' || echo 'RetroAchievements Token not set.'

		RetroArch_retroAchievementsOn

		iniFieldUpdate "$RetroArch_configFile" "" "cheevos_username" "$rau"
		iniFieldUpdate "$RetroArch_configFile" "" "cheevos_token" "$rat"

	fi
}
RetroArch_setBezels(){
	if [ "$RABezels" == "true" ]; then
		RetroArch_bezelOnAll
	else
		RetroArch_bezelOffAll
	fi
}
RetroArch_setShadersCRT(){
	if [ "$RAHandClassic2D" == "true" ]; then
		RetroArch_CRTshaderOnAll
	else
		RetroArch_CRTshaderOffAll
	fi
}
RetroArch_setShaders3DCRT(){
	if [ "$RAHandClassic3D" == "true" ]; then
		RetroArch_3DCRTshaderOnAll
	else
		RetroArch_3DCRTshaderOffAll
	fi
}
RetroArch_setShadersMAT(){
	if [ "$RAHandHeldShader" == "true" ]; then
		RetroArch_MATshadersOnAll
	else
		RetroArch_MATshadersOffAll
	fi
}

RetroArch_autoSave(){
	if [ "$RAautoSave" == "true" ]; then
		RetroArch_autoSaveOn
	else
		RetroArch_autoSaveOff
	fi
}

RetroArch_melonDSDSMigration(){

local RetroArch_saves="$RetroArch_path/saves"
local melonDS_remaps="$RetroArch_path/config/remaps/melonDS"
local melonDSDS_remaps="$RetroArch_path/config/remaps/melonDS DS"

# Copying melonDS saves to melonDSDS
for file in "$RetroArch_saves"/*.sav; do

	cp -- "${file}" "${file/%sav/srm}";
	echo "melonDS saves copied to melonDSDS"
done

# Copying melonDS remaps to melonDSDS
if [ ! -d "$melonDSDS_remaps" ]; then
	mkdir -p "$melonDSDS_remaps"
fi

if [ -d "$melonDS_remaps" ]; then
	cp -r "$melonDS_remaps/." "$melonDSDS_remaps"
	echo "melonDS remaps copied to melonDSDS"
fi

}

RetroArch_IsInstalled(){
	isFpInstalled "$RetroArch_emuPath"
}

RetroArch_resetConfig(){
	RetroArch_resetCoreConfigs &>/dev/null && echo "true" || echo "false"
}

RetroArch_flushEmulatorLauncher(){


	flushEmulatorLaunchers "retroarch"

}
