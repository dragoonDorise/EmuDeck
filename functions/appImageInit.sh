#!/bin/bash
appImageInit() {

	if [ "$system" == "chimeraos" ]; then
		ESDE_chimeraOS
		mkdir -p $HOME/Applications

		downloads_dir="$HOME/Downloads"
		destination_dir="$HOME/Applications"
		file_name="EmuDeck"

		find "$downloads_dir" -type f -name "*$file_name*.AppImage" -exec mv {} "$destination_dir/$file_name.AppImage" \;

	fi

	#Autofixes, put here functions that make under the hood fixes.
	autofix_duplicateESDE
	autofix_lnk
	SRM_migration # 2.2 Changes
	ESDE_migration # 2.2 Changes
	autofix_dynamicParsers # 2.2 Changes
	mkdir -p "$toolsPath/launchers/esde/"
	ln -s "${toolsPath}/launchers/es-de/es-de.sh" "$toolsPath/launchers/esde/emulationstationde.sh"

	#Force SRM appimage move in case the migration fails
	mv "${toolsPath}/srm/Steam-ROM-Manager.AppImage" "${toolsPath}/Steam ROM Manager.AppImage" &> /dev/null

	#Fix parsers
	if grep -q "mmcblk0p1" "$SRM_userData_configDir/userConfigurations.json"; then
		SRM_init
	fi

	#Fix Pegasus path
	if find "$romsPath" -type f -name "metadata.txt" -exec grep -q "mmcblk0p1" {} \; -print | grep -q .; then
		pegasus_init
	fi

	if [ -d "$HOME/.config/pegasus-frontend/config" ]; then
	  rsync -avz $HOME/.config/pegasus-frontend/config/  $HOME/.config/pegasus-frontend/
	fi

	if [ -d "$romsPath/3ds" ]; then
	  rsync -avz  $romsPath/3ds/ $romsPath/n3ds/ --ignore-existing-files
	fi

	if [ -d "$romsPath/gamecube" ]; then
		ln -s "${romsPath}/gamecube" "${romsPath}/gc"
	fi

	if [ ! -f "$HOME/.config/EmuDeck/.srm2211" ]; then
	  SRM_init
	  touch $HOME/.config/EmuDeck/.srm2211
	fi

	#Xenia temp fix
	if [ "$(Xenia_IsInstalled)" == "true" ]; then
		 setSetting doInstallXenia "true"
	  fi

	# Init functions
	mkdir -p "$HOME/emudeck/logs"
	mkdir -p "$HOME/emudeck/feeds"

}
