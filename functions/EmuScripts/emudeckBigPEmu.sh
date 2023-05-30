#!/bin/bash
#variables
BigPEmu_emuName="BigPEmu (proton)"
BigPEmu_emuType="windows"
BigPEmu_emuPath="${romsPath}/Applications/BigPEmu/BigPEmu.exe"
BigPEmu_appData="${HOME}/.steam/steam/steamapps/compatdata/4158790633/pfx/drive_c/users/steamuser/AppData/Roaming/BigPEmu"
BigPEmu_BigPEmuSettings="${BigPEmu_appData}/BigPEmuConfig.bigpcfg"

#cleanupOlderThings
BigPEmu_cleanup(){
	echo "NYI"
}

#Install
BigPEmu_install(){
	setMSG "Installing $BigPEmu_emuName"

	local showProgress="$1"
    if wget -m -nd -A "BigPEmu_*.zip" -O "$HOME/Applications/BigPEmu.zip" "https://www.richwhitehouse.com/jaguar/index.php?content=download"; then
		mkdir -p "$HOME/Applications/BigPEmu"
		unzip -o "$HOME/Applications/BigPEmu.zip" -d "$HOME/Applications/BigPEmu"
		rm -f "$HOME/Applications/BigPEmu.zip"
	else
		return 1
	fi

	cp "$EMUDECKGIT/tools/launchers/bigpemu.sh" "${toolsPath}/launchers/bigpemu.sh"
	sed -i "s|/run/media/mmcblk0p1/Emulation/tools|${toolsPath}|g" "${toolsPath}/launchers/bigpemu.sh"
	sed -i "s|/run/media/mmcblk0p1/Emulation/roms|${romsPath}|" "${toolsPath}/launchers/bigpemu.sh"

	chmod +x "${toolsPath}/launchers/bigpemu.sh"

	createDesktopShortcut   "$HOME/.local/share/applications/BigPEmu (Proton).desktop" \
							"BigPEmu (Proton)" \
							"${toolsPath}/launchers/bigpemu.sh -w"  \
							"False"
}

#ApplyInitialSettings
BigPEmu_init(){
	setMSG "Initializing $BigPEmu_emuName settings."	
	rsync -avhp "$EMUDECKGIT/configs/bigpemu/" "$BigPEmu_appData" --backup --suffix=.bak
	if [ -e "$BigPEmu_BigPEmuSettings.bak" ]; then
		mv -f "$BigPEmu_BigPEmuSettings.bak" "$BigPEmu_BigPEmuSettings" #retain BigPEmuSettings
	fi
	BigPEmu_setEmulationFolder
	BigPEmu_setupSaves
	BigPEmu_addSteamInputProfile
}

#update
BigPEmu_update(){
	setMSG "Updating $BigPEmu_emuName settings."	
	rsync -avhp "$EMUDECKGIT/configs/bigpemu/" "$BigPEmu_appData" --ignore-existing
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
	rm -rf $BigPEmu_BigPEmuSettings
}


#Uninstall
BigPEmu_uninstall(){
	setMSG "Uninstalling $BigPEmu_emuName."
	rm -rf "${BigPEmu_emuPath}"
    BigPEmu_wipeSettings
}

#setABXYstyle
BigPEmu_setABXYstyle(){
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
    echo "NYI"
	# addSteamInputCustomIcons
	# setMSG "Adding $BigPEmu_emuName Steam Input Profile."
	# rsync -r "$EMUDECKGIT/configs/steam-input/BigPEmu_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
}
