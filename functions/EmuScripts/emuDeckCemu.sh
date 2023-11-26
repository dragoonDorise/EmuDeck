#!/bin/bash
#variables
Cemu_emuName="Cemu (proton)"
Cemu_emuType="windows"
Cemu_emuPath="${romsPath}/wiiu/Cemu.exe"
Cemu_cemuSettings="${romsPath}/wiiu/settings.xml"

#cleanupOlderThings
Cemu_cleanup(){
	echo "NYI"
}

#Install
Cemu_install(){
	setMSG "Installing $Cemu_emuName"

	local showProgress="$1"
	Cemu_releaseURL="$(getReleaseURLGH "cemu-project/Cemu" "windows-x64.zip")"
	#curl $Cemu_releaseURL --output "$romsPath"/wiiu/cemu.zip
	if safeDownload "cemu" "$Cemu_releaseURL" "$romsPath/wiiu/cemu.zip" "$showProgress"; then
		mkdir -p "$romsPath/wiiu/tmp"
		unzip -o "$romsPath/wiiu/cemu.zip" -d "$romsPath/wiiu/tmp"
		mv "$romsPath"/wiiu/tmp/[Cc]emu_*/ "$romsPath/wiiu/tmp/cemu/" #don't quote the *
		rsync -avzh "$romsPath/wiiu/tmp/cemu/" "$romsPath/wiiu/"
		rm -rf "$romsPath/wiiu/tmp"
		rm -f "$romsPath/wiiu/cemu.zip"
	else
		return 1
	fi


#	if  [ -e "${toolsPath}/launchers/cemu.sh" ]; then #retain launch settings
#		local launchLine=$( tail -n 1 "${toolsPath}/launchers/cemu.sh" )
#		echo "cemu launch line found: $launchLine"
#	fi


	cp "$EMUDECKGIT/tools/launchers/cemu.sh" "${toolsPath}/launchers/cemu.sh"
	sed -i "s|/run/media/mmcblk0p1/Emulation/tools|${toolsPath}|g" "${toolsPath}/launchers/cemu.sh"
	sed -i "s|/run/media/mmcblk0p1/Emulation/roms|${romsPath}|" "${toolsPath}/launchers/cemu.sh"

#	if [[ "$launchLine"  == *"PROTONLAUNCH"* ]]; then
#		changeLine '"${PROTONLAUNCH}"' "$launchLine" "${toolsPath}/launchers/cemu.sh"
#	fi
	chmod +x "${toolsPath}/launchers/cemu.sh"


	createDesktopShortcut   "$HOME/.local/share/applications/Cemu (Proton).desktop" \
							"Cemu (Proton)" \
							"${toolsPath}/launchers/cemu.sh -w"  \
							"False"
	}

#ApplyInitialSettings
Cemu_init(){
	setMSG "Initializing $Cemu_emuName settings."
	rsync -avhp "$EMUDECKGIT/configs/info.cemu.Cemu/data/cemu/" "${romsPath}/wiiu" --backup --suffix=.bak
	if [ -e "$Cemu_cemuSettings.bak" ]; then
		mv -f "$Cemu_cemuSettings.bak" "$Cemu_cemuSettings" #retain cemuSettings
	fi
	Cemu_setEmulationFolder
	Cemu_setupSaves
	Cemu_addSteamInputProfile

	if [ -e "${romsPath}/wiiu/controllerProfiles/controller1.xml" ];then
		mv "${romsPath}/wiiu/controllerProfiles/controller1.xml" "${romsPath}/wiiu/controllerProfiles/controller1.xml.bak"
	fi
	if [ -e "${romsPath}/wiiu/controllerProfiles/controller2.xml" ];then
		mv "${romsPath}/wiiu/controllerProfiles/controller2.xml" "${romsPath}/wiiu/controllerProfiles/controller2.xml.bak"
	fi
	if [ -e "${romsPath}/wiiu/controllerProfiles/controller3.xml" ];then
		mv "${romsPath}/wiiu/controllerProfiles/controller3.xml" "${romsPath}/wiiu/controllerProfiles/controller3.xml.bak"
	fi
}

#update
Cemu_update(){
	setMSG "Updating $Cemu_emuName settings."
	rsync -avhp "$EMUDECKGIT/configs/info.cemu.Cemu/data/cemu/" "${romsPath}/wiiu" --ignore-existing
	Cemu_setEmulationFolder
	Cemu_setupSaves
	Cemu_addSteamInputProfile
}


#ConfigurePaths
Cemu_setEmulationFolder(){
	setMSG "Setting $Cemu_emuName Emulation Folder"

	if [[ -f "${Cemu_cemuSettings}" ]]; then
	#Correct Folder seperators to windows based ones
		#WindowsRomPath=${echo "z:${romsPath}/wiiu/roms" | sed 's/\//\\/g'}
		#gamePathEntryFound=$(grep -rnw "$Cemu_cemuSettings" -e "${WindowsRomPath}")
		gamePathEntryFound=$(grep -rnw "$Cemu_cemuSettings" -e "z:${romsPath}/wiiu/roms")
		if [[ $gamePathEntryFound == '' ]]; then
			#xmlstarlet ed --inplace  --subnode "content/GamePaths" --type elem -n Entry -v "${WindowsRomPath}" "$Cemu_cemuSettings"
			xmlstarlet ed --inplace  --subnode "content/GamePaths" --type elem -n Entry -v "z:${romsPath}/wiiu/roms" "$Cemu_cemuSettings"
		fi
	fi
}

#SetupSaves
Cemu_setupSaves(){
	unlink "${savesPath}/Cemu/saves" # Fix for previous bad symlink
	linkToSaveFolder Cemu saves "${romsPath}/wiiu/mlc01/usr/save"
}


#SetupStorage
Cemu_setupStorage(){
	echo "NYI"
}


#WipeSettings
Cemu_wipeSettings(){
	echo "NYI"
	#rm -rf "${romPath}wiiu/"
	# prob not cause roms are here
}


#Uninstall
Cemu_uninstall(){
	setMSG "Uninstalling $Cemu_emuName."
	rm -rf "${Cemu_emuPath}"
}

#setABXYstyle
Cemu_setABXYstyle(){
		echo "NYI"
}

#Migrate
Cemu_migrate(){
	   echo "NYI"
}

#WideScreenOn
Cemu_wideScreenOn(){
echo "NYI"
}

#WideScreenOff
Cemu_wideScreenOff(){
echo "NYI"
}

#BezelOn
Cemu_bezelOn(){
echo "NYI"
}

#BezelOff
Cemu_bezelOff(){
	echo "NYI"
}

#finalExec - Extra stuff
Cemu_finalize(){
	Cemu_cleanup
}

Cemu_IsInstalled(){
	if [ -e "$Cemu_emuPath" ]; then
		echo "true"
	else
		echo "false"
	fi
}

Cemu_resetConfig(){
	mv  "$Cemu_cemuSettings" "$Cemu_cemuSettings.bak" &>/dev/null
	Cemu_init &>/dev/null && echo "true" || echo "false"
}

Cemu_addSteamInputProfile(){
	addSteamInputCustomIcons
	#setMSG "Adding $Cemu_emuName Steam Input Profile."
	#rsync -r "$EMUDECKGIT/configs/steam-input/cemu_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
}

Cemu_setResolution(){
	echo "NYI"
}