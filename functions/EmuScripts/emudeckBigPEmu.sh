#!/bin/bash
#variables
BigPEmu_emuName="BigPEmu (proton)"
BigPEmu_emuType="windows"
BigPEmu_emuPath="${romsPath}/atarijaguar/BigPEmu.exe"
BigPEmu_BigPEmuSettings="${romsPath}/atarijaguar/settings.xml"

#cleanupOlderThings
BigPEmu_cleanup(){
	echo "NYI"
}

#Install
BigPEmu_install(){
	setMSG "Installing $BigPEmu_emuName"

	local showProgress="$1"
	BigPEmu_releaseURL="$(getReleaseURLGH "BigPEmu-project/BigPEmu" "windows-x64.zip")"
	#curl $BigPEmu_releaseURL --output "$romsPath"/atarijaguar/BigPEmu.zip
	if safeDownload "BigPEmu" "$BigPEmu_releaseURL" "$romsPath/atarijaguar/BigPEmu.zip" "$showProgress"; then
		mkdir -p "$romsPath/atarijaguar/tmp"
		unzip -o "$romsPath/atarijaguar/BigPEmu.zip" -d "$romsPath/atarijaguar/tmp"
		mv "$romsPath"/atarijaguar/tmp/[Cc]emu_*/ "$romsPath/atarijaguar/tmp/BigPEmu/" #don't quote the *
		rsync -avzh "$romsPath/atarijaguar/tmp/BigPEmu/" "$romsPath/atarijaguar/"
		rm -rf "$romsPath/atarijaguar/tmp"
		rm -f "$romsPath/atarijaguar/BigPEmu.zip"
	else
		return 1
	fi


#	if  [ -e "${toolsPath}/launchers/BigPEmu.sh" ]; then #retain launch settings
#		local launchLine=$( tail -n 1 "${toolsPath}/launchers/BigPEmu.sh" )
#		echo "BigPEmu launch line found: $launchLine"
#	fi
	

	cp "$EMUDECKGIT/tools/launchers/BigPEmu.sh" "${toolsPath}/launchers/BigPEmu.sh"
	sed -i "s|/run/media/mmcblk0p1/Emulation/tools|${toolsPath}|g" "${toolsPath}/launchers/BigPEmu.sh"
	sed -i "s|/run/media/mmcblk0p1/Emulation/roms|${romsPath}|" "${toolsPath}/launchers/BigPEmu.sh"

#	if [[ "$launchLine"  == *"PROTONLAUNCH"* ]]; then
#		changeLine '"${PROTONLAUNCH}"' "$launchLine" "${toolsPath}/launchers/BigPEmu.sh"
#	fi
	chmod +x "${toolsPath}/launchers/BigPEmu.sh"
	

	createDesktopShortcut   "$HOME/.local/share/applications/BigPEmu (Proton).desktop" \
							"BigPEmu (Proton)" \
							"${toolsPath}/launchers/BigPEmu.sh -w"  \
							"False"
	}

#ApplyInitialSettings
BigPEmu_init(){
	setMSG "Initializing $BigPEmu_emuName settings."	
	rsync -avhp "$EMUDECKGIT/configs/info.BigPEmu.BigPEmu/data/BigPEmu/" "${romsPath}/atarijaguar" --backup --suffix=.bak
	if [ -e "$BigPEmu_BigPEmuSettings.bak" ]; then
		mv -f "$BigPEmu_BigPEmuSettings.bak" "$BigPEmu_BigPEmuSettings" #retain BigPEmuSettings
	fi
	BigPEmu_setEmulationFolder
	BigPEmu_setupSaves
	BigPEmu_addSteamInputProfile

	if [ -e "${romsPath}/atarijaguar/controllerProfiles/controller1.xml" ];then
		mv "${romsPath}/atarijaguar/controllerProfiles/controller1.xml" "${romsPath}/atarijaguar/controllerProfiles/controller1.xml.bak"
	fi
	if [ -e "${romsPath}/atarijaguar/controllerProfiles/controller2.xml" ];then
		mv "${romsPath}/atarijaguar/controllerProfiles/controller2.xml" "${romsPath}/atarijaguar/controllerProfiles/controller2.xml.bak"
	fi
	if [ -e "${romsPath}/atarijaguar/controllerProfiles/controller3.xml" ];then
		mv "${romsPath}/atarijaguar/controllerProfiles/controller3.xml" "${romsPath}/atarijaguar/controllerProfiles/controller3.xml.bak"
	fi
}

#update
BigPEmu_update(){
	setMSG "Updating $BigPEmu_emuName settings."	
	rsync -avhp "$EMUDECKGIT/configs/info.BigPEmu.BigPEmu/data/BigPEmu/" "${romsPath}/atarijaguar" --ignore-existing
	BigPEmu_setEmulationFolder
	BigPEmu_setupSaves
	BigPEmu_addSteamInputProfile
}


#ConfigurePaths
BigPEmu_setEmulationFolder(){
	setMSG "Setting $BigPEmu_emuName Emulation Folder"	
	
	if [[ -f "${BigPEmu_BigPEmuSettings}" ]]; then
	#Correct Folder seperators to windows based ones
		#WindowsRomPath=${echo "z:${romsPath}/atarijaguar/roms" | sed 's/\//\\/g'}
		#gamePathEntryFound=$(grep -rnw "$BigPEmu_BigPEmuSettings" -e "${WindowsRomPath}")
		gamePathEntryFound=$(grep -rnw "$BigPEmu_BigPEmuSettings" -e "z:${romsPath}/atarijaguar/roms")
		if [[ $gamePathEntryFound == '' ]]; then
			#xmlstarlet ed --inplace  --subnode "content/GamePaths" --type elem -n Entry -v "${WindowsRomPath}" "$BigPEmu_BigPEmuSettings"
			xmlstarlet ed --inplace  --subnode "content/GamePaths" --type elem -n Entry -v "z:${romsPath}/atarijaguar/roms" "$BigPEmu_BigPEmuSettings"
		fi
	fi
}

#SetupSaves
BigPEmu_setupSaves(){
	unlink "${savesPath}/BigPEmu/saves" # Fix for previous bad symlink
	linkToSaveFolder BigPEmu saves "${romsPath}/atarijaguar/mlc01/usr/save"
}


#SetupStorage
BigPEmu_setupStorage(){
	echo "NYI"
}


#WipeSettings
BigPEmu_wipeSettings(){
	echo "NYI"
	#rm -rf "${romPath}atarijaguar/"
	# prob not cause roms are here
}


#Uninstall
BigPEmu_uninstall(){
	setMSG "Uninstalling $BigPEmu_emuName."
	rm -rf "${BigPEmu_emuPath}"
}

#setABXYstyle
BigPEmu_setABXYstyle(){
		echo "NYI"
}

#Migrate
BigPEmu_migrate(){
	   echo "NYI"
}

#WideScreenOn
BigPEmu_wideScreenOn(){
echo "NYI"
}

#WideScreenOff
BigPEmu_wideScreenOff(){
echo "NYI"
}

#BezelOn
BigPEmu_bezelOn(){
echo "NYI"
}

#BezelOff
BigPEmu_bezelOff(){
	echo "NYI"
}

#finalExec - Extra stuff
BigPEmu_finalize(){
	BigPEmu_cleanup
}

BigPEmu_IsInstalled(){
	if [ -e "$BigPEmu_emuPath" ]; then
		echo "true"
	else
		echo "false"
	fi
}

BigPEmu_resetConfig(){
	mv  "$BigPEmu_BigPEmuSettings" "$BigPEmu_BigPEmuSettings.bak" &>/dev/null
	BigPEmu_init &>/dev/null && echo "true" || echo "false"
}

BigPEmu_addSteamInputProfile(){
	addSteamInputCustomIcons
	setMSG "Adding $BigPEmu_emuName Steam Input Profile."
	rsync -r "$EMUDECKGIT/configs/steam-input/BigPEmu_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
}
