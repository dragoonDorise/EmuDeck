#!/usr/bin/env bash
#variables
BigPEmu_emuName="BigPEmu"
BigPEmu_emuType="$emuDeckEmuTypeWindows"
BigPEmu_emuPath="$emusFolder/BigPEmu/bigpemu"
BigPEmu_appData="$emusFolder/BigPEmu/UserData"
BigPEmu_BigPEmuSettings="$emusFolder/BigPEmu/UserData/BigPEmuConfig.bigpcfg"


#cleanupOlderThings
BigPEmu_cleanup(){
	echo "NYI"
}

#Install
BigPEmu_install(){
	setMSG "Installing $BigPEmu_emuName"

	mkdir -p $BigPEmu_appData

	BigPEmudownloadLink=$(curl -s "https://www.richwhitehouse.com/jaguar/index.php?content=download" | grep -o 'https://www\.richwhitehouse\.com/jaguar/builds/BigPEmu_Linux64_v[0-9]*\.tar.gz' | grep -v "BigPEmu_*-DEV.tar.gz" | head -n 1)
	
	if [ $CPUarch == "arm" ]; then
		BigPEmudownloadLink=$(curl -s "https://www.richwhitehouse.com/jaguar/index.php?content=download" | grep -o 'https://www\.richwhitehouse\.com/jaguar/builds/BigPEmu_LinuxARM64_v[0-9]*\.tar.gz' | grep -v "BigPEmu_*-DEV.tar.gz" | head -n 1)
	fi

	if safeDownload "BigPEmu" "$BigPEmudownloadLink" "$emusFolder/BigPEmu/BigPEmu.tar.gz" "$showProgress"; then

		tar -xvzf "$emusFolder/BigPEmu/BigPEmu.tar.gz" -C "$emusFolder/BigPEmu" --strip-components 1

		rm -f "$emusFolder/BigPEmu/BigPEmu.tar.gz"

	else
		return 1
	fi

	cp "$emudeckBackend/tools/launchers/bigpemu.sh" "$toolsPath/launchers/bigpemu.sh"
	# So users can still open BigPEmu from the ~/Applications folder.
	#cp "$emudeckBackend/tools/launchers/bigpemu.sh" "$emusFolder/BigPEmu/bigpemu.sh"
	cp "$emudeckBackend/tools/launchers/bigpemu.sh" "$romsPath/emulators/bigpemu.sh"

	chmod +x "${toolsPath}/launchers/bigpemu.sh"
	#chmod +x "$emusFolder/BigPEmu/bigpemu.sh"
	chmod +x "$romsPath/emulators/bigpemu.sh"

	rm -rf "$HOME/.local/share/applications/BigPEmu (Proton).desktop"
	rm -rf "$emusFolder/BigPEmu/bigpemu.sh"

	createDesktopShortcut   "$HOME/.local/share/applications/BigPEmu.desktop" \
							"BigPEmu" \
							"${toolsPath}/launchers/bigpemu.sh -w"  \
							"False"
}

#ApplyInitialSettings
BigPEmu_init(){
	setMSG "Initializing $BigPEmu_emuName settings."
	rsync -avhp "$emudeckBackend/configs/bigpemu/" "$BigPEmu_appData" --backup --suffix=.bak
	sed -E -i "s|/run/media/mmcblk0p1/Emulation|$emulationPath|g" "$BigPEmu_BigPEmuSettings"
	BigPEmu_setEmulationFolder
	BigPEmu_setupSaves
	BigPEmu_flushEmulatorLauncher
	BigPEmu_addParser
	if [ -e "$ESDE_toolPath" ] || [ -f "${toolsPath}/$ESDE_downloadedToolName" ] || [ -f "${toolsPath}/$ESDE_oldtoolName.AppImage" ]; then
		BigPEmu_addESConfig
	else
		echo "ES-DE not found. Skipped adding custom system."
	fi

}

#update
BigPEmu_update(){
	setMSG "Updating $BigPEmu_emuName settings."
	rsync -avhp "$emudeckBackend/configs/bigpemu/" "$BigPEmu_appData" --ignore-existing
	sed -E -i "s|/run/media/mmcblk0p1/Emulation|$emulationPath|g" "$BigPEmu_BigPEmuSettings"
	BigPEmu_setEmulationFolder
	BigPEmu_setupSaves
	BigPEmu_flushEmulatorLauncher
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
	removeParser "atari_jaguar_bigpemu.json"
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
	# rsync -r "$emudeckBackend/configs/steam-input/BigPEmu_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
}

BigPEmu_flushEmulatorLauncher(){
	flushEmulatorLaunchers "bigpemu"
}

BigPEmu_addParser(){
	addParser "atari_jaguar_bigpemu.json"
}

BigPEmu_addToSteam(){
	setMSG "Adding BigPEmu to Steam"
	add_to_steam "bigpemu" "BigPEmu" "$toolsPath/launchers/bigpemu.sh" "$HOME/Applications/" "$emudeckBackend/icons/BigPEmu.png" "Emulation"
}
