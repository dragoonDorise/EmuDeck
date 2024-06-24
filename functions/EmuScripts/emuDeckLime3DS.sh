#!/bin/bash
#variables
Lime3DS_emuName="Lime3DS"
Lime3DS_emuType="$emuDeckEmuTypeAppImage"
Lime3DS_emuPath="$HOME/Applications/lime3ds-gui.AppImage"
Lime3DS_releaseURL=""
Lime3DS_configFile="$HOME/.config/citra-emu/qt-config.ini"
Lime3DS_configPath="$HOME/.config/citra-emu"
Lime3DS_texturesPath="$HOME/.config/citra-emu/load/textures"

#cleanupOlderThings
Lime3DS_finalize(){
 echo "NYI"
}

#Install
Lime3DS_install(){
	setMSG "Installing $Lime3DS_emuName"
	local success="false"

	if safeDownload "$Lime3DS_emuName" "$(getReleaseURLGH "Lime3DS/Lime3DS" "appimage.tar.gz")" "$HOME/Applications/lime3ds.tar.gz" "$showProgress"; then
		tar -xvf "$HOME/Applications/lime3ds.tar.gz" -C "$HOME/Applications"
		rm -rf "$HOME/Applications/lime3ds.tar.gz"
		app_dir="$HOME/Applications"
		old_name=$(find "$app_dir" -maxdepth 1 -type d -name "lime3ds-*-linux-appimage" | head -n 1)

		if [ -n "$old_name" ]; then
		  new_name="${app_dir}/lime3ds"
		  mv "$old_name" "$new_name"
		fi
	   mv "$HOME/Applications/lime3ds/lime3ds-gui.AppImage" "$HOME/Applications/"
	   chmod +x "$HOME/Applications/lime3ds-gui.AppImage"
	   rm -rf "$HOME/Applications/lime3ds/"
	else
		return 1
	fi

}

#ApplyInitialSettings
Lime3DS_init(){
	setMSG "Initializing $Lime3DS_emuName settings."
	Lime3DS_migrateFromCitra
	Lime3DS_setEmulationFolder
	Lime3DS_setupSaves
	Lime3DS_addSteamInputProfile
	Lime3DS_flushEmulatorLauncher
	cp "$EMUDECKGIT/tools/launchers/Lime3DS.sh" "$toolsPath/launchers/Lime3DS.sh"
	chmod +x "$toolsPath/launchers/Lime3DS.sh"

  	createDesktopShortcut   "$HOME/.local/share/applications/Lime3DS.desktop" \
							"Lime3DS (AppImage)" \
							"${toolsPath}/launchers/lime3ds.sh"  \
							"False"

	#ESDE Temp FIX
	ln -s "$HOME/Applications/lime3ds-gui.AppImage" "$HOME/Applications/lime-qt.AppImage"

}

Lime3DS_migrateFromCitra(){
	if [ -d "$savesPath/citra" ]; then
		mkdir -p "$savesPath/lime3ds/"
		rsync -av --ignore-existing "$savesPath/citra/" "$savesPath/lime3ds/"
	fi
}

#update
Lime3DS_update(){
	setMSG "Updating $Lime3DS_emuName settings."
	Lime3DS_init
}

#ConfigurePaths
Lime3DS_setEmulationFolder(){
	setMSG "Setting $Lime3DS_emuName Emulation Folder"


	if [ -e "$Lime3DS_emuPath" ]; then

		echo "AppImage found. Setting configurations."

		mkdir -p "$Lime3DS_configPath"
		rsync -avhp "$EMUDECKGIT/configs/lime3ds/config/citra-emu/qt-config.ini" "$Lime3DS_configPath/qt-config.ini" --backup --suffix=.bak
		gameDirOpt='Paths\\gamedirs\\3\\path='
		newGameDirOpt='Paths\\gamedirs\\3\\path='"${romsPath}/n3ds"
		sed -i "/${gameDirOpt}/c\\${newGameDirOpt}" "$Lime3DS_configFile"

		nandDirOpt='nand_directory='
		newnandDirOpt='nand_directory='"$HOME/.local/share/citra-emu/nand/"
		sed -i "/${nandDirOpt}/c\\${newnandDirOpt}" "$Lime3DS_configFile"

		sdmcDirOpt='sdmc_directory='
		newsdmcDirOpt='sdmc_directory='"$HOME/.local/share/citra-emu/sdmc/"
		sed -i "/${sdmcDirOpt}/c\\${newsdmcDirOpt}" "$Lime3DS_configFile"

		screenshotsDirOpt='Paths\\screenshotPath='
		newscreenshotDirOpt='Paths\\screenshotPath='"$HOME/.local/share/citra-emu/screenshots/"
		sed -i "/${screenshotsDirOpt}/c\\${newscreenshotDirOpt}" "$Lime3DS_configFile"

		#Setup symlink for AES keys
		mkdir -p "${biosPath}/Lime3DS/"
		mkdir -p "$HOME/.local/share/citra-emu/sysdata"
		ln -sn "$HOME/.local/share/citra-emu/sysdata" "${biosPath}/Lime3DS/keys"

	else
		echo "AppImage not found."
	fi


}

#SetupSaves
Lime3DS_setupSaves(){
	linkToSaveFolder lime3ds saves "$HOME/.local/share/citra-emu/sdmc"
	linkToSaveFolder lime3ds states "$HOME/.local/share/citra-emu/states"
}



#WipeSettings
Lime3DS_wipe(){
	setMSG "Wiping $Lime3DS_emuName config directory. (factory reset)"
	rm -rf "$HOME/.config/citra-emu"
}


#Uninstall
Lime3DS_uninstall(){
	setMSG "Uninstalling $Lime3DS_emuName."
	cd $HOME/.Lime3DS && ./maintenancetool purge
}

#setABXYstyle
Lime3DS_setABXYstyle(){
		echo "NYI"
}

#WideScreenOn
Lime3DS_wideScreenOn(){
echo "NYI"
}

#WideScreenOff
Lime3DS_wideScreenOff(){
echo "NYI"
}

#BezelOn
Lime3DS_bezelOn(){
echo "NYI"
}

#BezelOff
Lime3DS_bezelOff(){
echo "NYI"
}

#finalExec - Extra stuff
Lime3DS_finalize(){
	echo "NYI"
}

Lime3DS_IsInstalled(){
	if [ -e "$Lime3DS_emuPath" ]; then
		echo "true"
	else
		echo "false"
	fi
}

Lime3DS_resetConfig(){
	Lime3DS_init &>/dev/null && echo "true" || echo "false"
}

Lime3DS_addSteamInputProfile(){
	addSteamInputCustomIcons
	setMSG "Adding $Lime3DS_emuName Steam Input Profile."
	#rsync -r "$EMUDECKGIT/configs/steam-input/Lime3DS_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
	rsync -r --exclude='*/' "$EMUDECKGIT/configs/steam-input/" "$HOME/.steam/steam/controller_base/templates/"
}

Lime3DS_setResolution(){
	case $Lime3DSResolution in
		"720P") multiplier=3;;
		"1080P") multiplier=5;;
		"1440P") multiplier=6;;
		"4K") multiplier=9;;
		*) echo "Error"; return 1;;
	esac

	setConfig "resolution_factor" $multiplier "$Lime3DS_configFile"
}

Lime3DS_flushEmulatorLauncher(){
	flushEmulatorLaunchers "Lime3DS"
}