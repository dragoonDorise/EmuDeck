#!/bin/bash
#variables
RetroArch_emuName="RetroArch"
RetroArch_emuType="FlatPak"
RetroArch_emuPath="org.libretro.RetroArch"
RetroArch_releaseURL=""
RetroArch_configFile="$HOME/.var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg"

#cleanupOlderThings
RetroArch.cleanup(){
	echo "NYI"
}

#Install
RetroArch.install(){

	installEmuFP "${RetroArch_emuName}" "${RetroArch_emuPath}"
	flatpak override "${RetroArch_emuPath}" --filesystem=host --user

}

#ApplyInitialSettings
RetroArch.init(){

	configEmuFP "${RetroArch_emuName}" "${RetroArch_emuPath}" "true"
	RetroArch.setEmulationFolder
	RetroArch.setupSaves
	RetroArch.installCores

}

#update
RetroArch.update(){

	configEmuFP "${RetroArch_emuName}" "${RetroArch_emuPath}"
	RetroArch.setEmulationFolder
	RetroArch.setupSaves
	RetroArch.installCores

}

#ConfigurePaths
RetroArch.setEmulationFolder(){

	system_directory='system_directory = '
	system_directorySetting="${system_directory}""\"${biosPath}\""
	sed -i "/${system_directory}/c\\${system_directorySetting}" $configFile

}

#SetupSaves
RetroArch.setupSaves(){
	linkToSaveFolder retroarch states "$HOME/.var/app/org.libretro.RetroArch/config/retroarch/states"
	linkToSaveFolder retroarch saves "$HOME/.var/app/org.libretro.RetroArch/config/retroarch/saves"
}


#SetupStorage
RetroArch.setupStorage(){
	echo "NYI"
}


#WipeSettings
RetroArch.wipe(){
   rm -rf "$HOME/.var/app/$RetroArch_emuPath"
   # prob not cause roms are here
}


#Uninstall
RetroArch.uninstall(){
    flatpak uninstall "$RetroArch_emuPath" -y
}

#setABXYstyle
RetroArch.setABXYstyle(){
	echo "NYI"    
}

#Migrate
RetroArch.migrate(){
	echo "NYI"    
}

#WideScreenOn
RetroArch.wideScreenOn(){
echo "NYI"
}

#WideScreenOff
RetroArch.wideScreenOff(){
echo "NYI"
}

#BezelOn
RetroArch.bezelOn(){
echo "NYI"
}

#BezelOff
RetroArch.bezelOff(){
echo "NYI"
}

#finalExec - Extra stuff
RetroArch.finalize(){
	echo "NYI"
}

RetroArch.installCores(){

	#Requests for:
	#GP32
	#N-gage
	#Game.com

	mkdir -p "$HOME/.var/app/org.libretro.RetroArch/config/retroarch/cores"
	raUrl="https://buildbot.libretro.com/nightly/linux/x86_64/latest/"
	RAcores=(bsnes_hd_beta_libretro.so flycast_libretro.so gambatte_libretro.so genesis_plus_gx_libretro.so genesis_plus_gx_wide_libretro.so mednafen_lynx_libretro.so mednafen_ngp_libretro.so mednafen_wswan_libretro.so melonds_libretro.so mesen_libretro.so mgba_libretro.so mupen64plus_next_libretro.so nestopia_libretro.so picodrive_libretro.so ppsspp_libretro.so snes9x_libretro.so stella_libretro.so yabasanshiro_libretro.so yabause_libretro.so yabause_libretro.so mame2003_plus_libretro.so mame2010_libretro.so mame_libretro.so melonds_libretro.so fbneo_libretro.so bluemsx_libretro.so desmume_libretro.so sameboy_libretro.so gearsystem_libretro.so mednafen_saturn_libretro.so opera_libretro.so dosbox_core_libretro.so dosbox_pure_libretro.so dosbox_svn_libretro.so puae_libretro.so)
	setMSG "Downloading RetroArch Cores for EmuDeck"
	for i in "${RAcores[@]}"
	do
		FILE=~/.var/app/org.libretro.RetroArch/config/retroarch/cores/${i}
		if [ -f "$FILE" ]; then
			echo "${i}...Already Downloaded"
		else
			curl $raUrl$i.zip --output ~/.var/app/org.libretro.RetroArch/config/retroarch/cores/${i}.zip 
			#rm ~/.var/app/org.libretro.RetroArch/config/retroarch/cores/${i}.zip
			echo "${i}...Downloaded!"
		fi
	done	
	

	RAcores=(a5200_libretro.so 81_libretro.so atari800_libretro.so bluemsx_libretro.so chailove_libretro.so fbneo_libretro.so freechaf_libretro.so freeintv_libretro.so fuse_libretro.so gearsystem_libretro.so gw_libretro.so hatari_libretro.so lutro_libretro.so mednafen_pcfx_libretro.so mednafen_vb_libretro.so mednafen_wswan_libretro.so mu_libretro.so neocd_libretro.so nestopia_libretro.so nxengine_libretro.so o2em_libretro.so picodrive_libretro.so pokemini_libretro.so prboom_libretro.so prosystem_libretro.so px68k_libretro.so quasi88_libretro.so scummvm_libretro.so squirreljme_libretro.so theodore_libretro.so uzem_libretro.so vecx_libretro.so vice_xvic_libretro.so virtualjaguar_libretro.so x1_libretro.so mednafen_lynx_libretro.so mednafen_ngp_libretro.so mednafen_pce_libretro.so mednafen_pce_fast_libretro.so mednafen_psx_libretro.so mednafen_psx_hw_libretro.so mednafen_saturn_libretro.so mednafen_supafaust_libretro.so mednafen_supergrafx_libretro.so blastem_libretro.so bluemsx_libretro.so bsnes_libretro.so bsnes_mercury_accuracy_libretro.so cap32_libretro.so citra2018_libretro.so citra_libretro.so crocods_libretro.so desmume2015_libretro.so desmume_libretro.so dolphin_libretro.so dosbox_core_libretro.so dosbox_pure_libretro.so dosbox_svn_libretro.so fbalpha2012_cps1_libretro.so fbalpha2012_cps2_libretro.so fbalpha2012_cps3_libretro.so fbalpha2012_libretro.so fbalpha2012_neogeo_libretro.so fceumm_libretro.so fbneo_libretro.so flycast_libretro.so fmsx_libretro.so frodo_libretro.so gambatte_libretro.so gearboy_libretro.so gearsystem_libretro.so genesis_plus_gx_libretro.so genesis_plus_gx_wide_libretro.so gpsp_libretro.so handy_libretro.so kronos_libretro.so mame2000_libretro.so mame2003_plus_libretro.so mame2010_libretro.so mame_libretro.so melonds_libretro.so mesen_libretro.so mesen-s_libretro.so mgba_libretro.so mupen64plus_next_libretro.so nekop2_libretro.so np2kai_libretro.so nestopia_libretro.so parallel_n64_libretro.so pcsx2_libretro.so pcsx_rearmed_libretro.so picodrive_libretro.so ppsspp_libretro.so puae_libretro.so quicknes_libretro.so race_libretro.so sameboy_libretro.so smsplus_libretro.so snes9x2010_libretro.so snes9x_libretro.so stella2014_libretro.so stella_libretro.so tgbdual_libretro.so vbam_libretro.so vba_next_libretro.so vice_x128_libretro.so vice_x64_libretro.so vice_x64sc_libretro.so vice_xscpu64_libretro.so yabasanshiro_libretro.so yabause_libretro.so bsnes_hd_beta_libretro.so swanstation_libretro.so)
	setMSG "Downloading RetroArch Cores for EmulationStation DE"
	for i in "${RAcores[@]}"
	do
		FILE=~/.var/app/org.libretro.RetroArch/config/retroarch/cores/${i}
		if [ -f "$FILE" ]; then
			echo "${i}...Already Downloaded"
		else
			curl $raUrl$i.zip --output ~/.var/app/org.libretro.RetroArch/config/retroarch/cores/${i}.zip 
			#rm ~/.var/app/org.libretro.RetroArch/config/retroarch/cores/${i}.zip
			echo "${i}...Downloaded!"
		fi
	done

	
	for entry in ~/.var/app/org.libretro.RetroArch/config/retroarch/cores/*.zip
	do
		 unzip -o "$entry" -d ~/.var/app/org.libretro.RetroArch/config/retroarch/cores/ 
	done
	
	for entry in ~/.var/app/org.libretro.RetroArch/config/retroarch/cores/*.zip
	do
		 rm -f "$entry" 
	done


}

RetroArch.autoSaveOn(){
	changeLine 'savestate_auto_load = ' 'savestate_auto_load = "true"' "$RetroArch_configFile"
	changeLine 'savestate_auto_save = ' 'savestate_auto_save = "true"' "$RetroArch_configFile"
}
RetroArch.autoSaveOn(){
	changeLine 'savestate_auto_load = ' 'savestate_auto_load = "false"' "$RetroArch_configFile"
	changeLine 'savestate_auto_save = ' 'savestate_auto_save = "false"' "$RetroArch_configFile"
}
RetroArch.retroAchievementsOn(){
	changeLine 'cheevos_enable = ' 'cheevos_enable = "true"' "$RetroArch_configFile"
}
RetroArch.retroAchievementsOff(){
	changeLine 'cheevos_enable = ' 'cheevos_enable = "false"' "$RetroArch_configFile"
}
RetroArch.retroAchievementsPromptLogin(){
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
		echo $RAInput | awk -F "," '{print $1}' > "$HOME/emudeck/.rau"
		echo $RAInput | awk -F "," '{print $2}' > "$HOME/emudeck/.rap"
	else
		echo "Cancel RetroAchievment Login" 
	fi
}
RetroArch.retroAchievementsSetLogin(){
	rap=$(cat ~/emudeck/.rap)
	rau=$(cat ~/emudeck/.rau)
	echo "Evaluate RetroAchievements Login."
	if [ ${#rap} -lt 1 ]; then
		echo "--No password."
	elif [ ${#rau} -lt 1 ]; then
		echo "--No username."
	else
		echo "Valid Retroachievements Username and Password length"
		changeLine 'cheevos_username = ' 'cheevos_username = "'${rau}'"' "$RetroArch_configFile"
		changeLine 'cheevos_password = ' 'cheevos_password = "'${rap}'"' "$RetroArch_configFile"
	fi
}
RetroArch.setSNESAR(){
	AR=$1
	if [ $SNESAR == 43 ]; then	
		cp ~/.var/app/org.libretro.RetroArch/config/retroarch/config/Snes9x/snes43.cfg ~/.var/app/org.libretro.RetroArch/config/retroarch/config/Snes9x/snes.cfg	
	else
		cp ~/.var/app/org.libretro.RetroArch/config/retroarch/config/Snes9x/snes87.cfg ~/.var/app/org.libretro.RetroArch/config/retroarch/config/Snes9x/snes.cfg	
	fi	
}
RetroArch.bezelOn(){
	if [ $RABezels == true ]; then	
		find ~/.var/app/org.libretro.RetroArch/config/retroarch/config/ -type f -name "*.bak" | while read f; do mv -v "$f" "${f%.*}.cfg"; done 
	else
		find ~/.var/app/org.libretro.RetroArch/config/retroarch/config/ -type f -name "*.cfg" | while read f; do mv -v "$f" "${f%.*}.bak"; done 
	fi	
}
