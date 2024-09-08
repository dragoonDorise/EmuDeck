#!/bin/bash
#variables
BigPEmu_emuName="BigPEmu (Proton)"
BigPEmu_emuType="$emuDeckEmuTypeWindows"
BigPEmu_emuPath="$HOME/Applications/BigPEmu/BigPEmu.exe"
BigPEmu_appData="$HOME/Applications/BigPEmu/UserData"
BigPEmu_BigPEmuSettings="$HOME/Applications/BigPEmu/UserData/BigPEmuConfig.bigpcfg"

#cleanupOlderThings
BigPEmu_cleanup(){
	echo "NYI"
}

#Install
BigPEmu_install(){
	setMSG "Installing $BigPEmu_emuName"

	mkdir -p $BigPEmu_appData

	BigPEmudownloadLink=$(curl -s "https://www.richwhitehouse.com/jaguar/index.php?content=download" | grep -o 'https://www\.richwhitehouse\.com/jaguar/builds/BigPEmu_v[0-9]*\.zip' | grep -v "BigPEmu_*-DEV.zip" | head -n 1)

	if safeDownload "BigPEmu" "$BigPEmudownloadLink" "$HOME/Applications/BigPEmu/BigPEmu.zip" "$showProgress"; then

		unzip -o "$HOME/Applications/BigPEmu/BigPEmu.zip" -d "$HOME/Applications/BigPEmu"
		rm -f "$HOME/Applications/BigPEmu/BigPEmu.zip"

	else
		return 1
	fi

	cp "$EMUDECKGIT/tools/launchers/bigpemu.sh" "$toolsPath/launchers/bigpemu.sh"
	# So users can still open BigPEmu from the ~/Applications folder.
	cp "$EMUDECKGIT/tools/launchers/bigpemu.sh" "$HOME/Applications/BigPEmu/bigpemu.sh"
	cp "$EMUDECKGIT/tools/launchers/bigpemu.sh" "$romsPath/emulators/bigpemu.sh"

	chmod +x "${toolsPath}/launchers/bigpemu.sh"
	chmod +x "$HOME/Applications/BigPEmu/bigpemu.sh"
	chmod +x "$romsPath/emulators/bigpemu.sh"

	createDesktopShortcut   "$HOME/.local/share/applications/BigPEmu (Proton).desktop" \
							"BigPEmu (Proton)" \
							"${toolsPath}/launchers/bigpemu.sh -w"  \
							"False"
}

#ApplyInitialSettings
BigPEmu_init(){
	setMSG "Initializing $BigPEmu_emuName settings."
	rsync -avhp "$EMUDECKGIT/configs/bigpemu/" "$BigPEmu_appData" --backup --suffix=.bak
	BigPEmu_setEmulationFolder
	BigPEmu_setupSaves
	BigPEmu_flushEmulatorLauncher
	addProtonLaunch
	#SRM_createParsers
	if [ -e "$ESDE_toolPath" ] || [ -f "${toolsPath}/$ESDE_downloadedToolName" ] || [ -f "${toolsPath}/$ESDE_oldtoolName.AppImage" ]; then
		BigPEmu_addESConfig
	else
		echo "ES-DE not found. Skipped adding custom system."
	fi

}

#update
BigPEmu_update(){
	setMSG "Updating $BigPEmu_emuName settings."
	rsync -avhp "$EMUDECKGIT/configs/bigpemu/" "$BigPEmu_appData" --ignore-existing
	BigPEmu_setEmulationFolder
	BigPEmu_setupSaves
	BigPEmu_flushEmulatorLauncher
	addProtonLaunch
	if [ -e "$ESDE_toolPath" ] || [ -f "${toolsPath}/$ESDE_downloadedToolName" ] || [ -f "${toolsPath}/$ESDE_oldtoolName.AppImage" ]; then
		BigPEmu_addESConfig
	else
		echo "ES-DE not found. Skipped adding custom system."
	fi
}

BigPEmu_addESConfig(){

	ESDE_junksettingsFile
	ESDE_addCustomSystemsFile
	ESDE_setEmulationFolder
	
	# Atari Jaguar
	if [[ $(grep -rnw "$es_systemsFile" -e 'atarijaguar') == "" ]]; then
		xmlstarlet ed -S --inplace --subnode '/systemList' --type elem --name 'system' \
		--var newSystem '$prev' \
		--subnode '$newSystem' --type elem --name 'name' -v 'atarijaguar' \
		--subnode '$newSystem' --type elem --name 'fullname' -v 'Atari Jaguar' \
		--subnode '$newSystem' --type elem --name 'path' -v '%ROMPATH%/atarijaguar' \
		--subnode '$newSystem' --type elem --name 'extension' -v '.abs .ABS .bin .BIN .cdi .CDI .cof .COF .cue .CUE .j64 .J64 .jag .JAG .prg .PRG .rom .ROM .7z .7Z .zip .ZIP' \
		--subnode '$newSystem' --type elem --name 'commandB' -v "/usr/bin/bash ${toolsPath}/launchers/bigpemu.sh %ROM%" \
		--insert '$newSystem/commandB' --type attr --name 'label' --value "BigPEmu (Proton)" \
		--subnode '$newSystem' --type elem --name 'commandV' -v "%EMULATOR_RETROARCH% -L %CORE_RETROARCH%/virtualjaguar_libretro.so %ROM%" \
		--insert '$newSystem/commandV' --type attr --name 'label' --value "Virtual Jaguar" \
		--subnode '$newSystem' --type elem --name 'commandM' -v "%STARTDIR%=~/.mame %EMULATOR_MAME% -rompath %GAMEDIR%\;%ROMPATH%/atarijaguar jaguar -cart %ROM%" \
		--insert '$newSystem/commandM' --type attr --name 'label' --value "MAME (Standalone)" \
		--subnode '$newSystem' --type elem --name 'platform' -v 'atarijaguar' \
		--subnode '$newSystem' --type elem --name 'theme' -v 'atarijaguar' \
		-r 'systemList/system/commandB' -v 'command' \
		-r 'systemList/system/commandV' -v 'command' \
		-r 'systemList/system/commandM' -v 'command' \
		"$es_systemsFile"

		#format doc to make it look nice
		xmlstarlet fo "$es_systemsFile" > "$es_systemsFile".tmp && mv "$es_systemsFile".tmp "$es_systemsFile"
	fi

	# Atari Jaguar CD
	if [[ $(grep -rnw "$es_systemsFile" -e 'atarijaguarcd') == "" ]]; then
		xmlstarlet ed -S --inplace --subnode '/systemList' --type elem --name 'system' \
		--var newSystem '$prev' \
		--subnode '$newSystem' --type elem --name 'name' -v 'atarijaguarcd' \
		--subnode '$newSystem' --type elem --name 'fullname' -v 'Atari Jaguar CD' \
		--subnode '$newSystem' --type elem --name 'path' -v '%ROMPATH%/atarijaguarcd' \
		--subnode '$newSystem' --type elem --name 'extension' -v '.abs .ABS .bin .BIN .cdi .CDI .cof .COF .cue .CUE .j64 .J64 .jag .JAG .prg .PRG .rom .ROM .7z .7Z .zip .ZIP' \
		--subnode '$newSystem' --type elem --name 'commandB' -v "/usr/bin/bash ${toolsPath}/launchers/bigpemu.sh %ROM%" \
		--insert '$newSystem/commandB' --type attr --name 'label' --value "BigPEmu (Proton)" \
		--subnode '$newSystem' --type elem --name 'platform' -v 'atarijaguarcd' \
		--subnode '$newSystem' --type elem --name 'theme' -v 'atarijaguarcd' \
		-r 'systemList/system/commandB' -v 'command' \
		"$es_systemsFile"

		#format doc to make it look nice
		xmlstarlet fo "$es_systemsFile" > "$es_systemsFile".tmp && mv "$es_systemsFile".tmp "$es_systemsFile"
	fi


	#Custom Systems config end
}


#ConfigurePaths
BigPEmu_setEmulationFolder(){
	setMSG "Setting $BigPEmu_emuName Emulation Folder"

	echo "NYI"
}

#SetupSaves
BigPEmu_setupSaves(){
	if [ -e "${savesPath}/BigPEmu/saves" ]; then
		unlink "${savesPath}/BigPEmu/saves"
	fi
	linkToSaveFolder BigPEmu saves "${BigPEmu_appData}"

	if [ -e "${savesPath}/BigPEmu/states" ]; then
		unlink "${savesPath}/BigPEmu/states"
	fi
	linkToSaveFolder BigPEmu states "${BigPEmu_appData}"
}


#SetupStorage
BigPEmu_setupStorage(){
	unlink "${storagePath}/BigPEmu/screenshots"
	linkToStorageFolder BigPEmu screenshots "${BigPEmu_appData}"
}


#WipeSettings
BigPEmu_wipeSettings(){
	rm -rf $BigPEmu_BigPEmuSettings
}


#Uninstall
BigPEmu_uninstall(){
    uninstallGeneric $BigPEmu_emuName $BigPEmu_emuPath "" "emulator" 
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


BigPemu_resetConfig(){
	BigPEmu_resetConfig
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

BigPEmu_flushEmulatorLauncher(){


	flushEmulatorLaunchers "bigpemu"

}