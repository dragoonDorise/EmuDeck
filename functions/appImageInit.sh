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

	if [ -L "${romsPath}/gc/gamecube" ]; then
		rm "${romsPath}/gc/gamecube"
	fi	

	if [ -L "${romsPath}/n3ds/3ds" ]; then
		rm "${romsPath}/3ds/3ds"
	fi	

	if [ ! -d "$romsPath/3ds" ]; then
	  ln -s "$romsPath/n3ds/"  "$romsPath/3ds/"
	fi

	if [ ! -d "$romsPath/gamecube" ]; then
		ln -s "${romsPath}/gc" "${romsPath}/gamecube" 
	fi



	if [ ! -f "$HOME/.config/EmuDeck/.srm2211" ]; then
	  SRM_init
	  touch $HOME/.config/EmuDeck/.srm2211
	fi

	if [ "$(ares_IsInstalled)" == "true" ]; then
		#echo "NYI"
		ares_flushEmulatorLauncher
	fi

	if [ "$(BigPEmu_IsInstalled)" == "true" ]; then
		#echo "NYI"
		BigPEmu_flushEmulatorLauncher
	fi

	if [ "$(Cemu_IsInstalled)" == "true" ]; then
		#echo "NYI"
		Cemu_flushEmulatorLauncher
	fi

	if [ "$(CemuProton_IsInstalled)" == "true" ]; then
		#echo "NYI"
		CemuProton_flushEmulatorLauncher
	fi

	if [ "$(Citra_IsInstalled)" == "true" ]; then
		#echo "NYI"
		Citra_flushEmulatorLauncher
	fi

	if [ "$(Dolphin_IsInstalled)" == "true" ]; then
		#echo "NYI"
		Dolphin_flushEmulatorLauncher
	fi

	if [ "$(DuckStation_IsInstalled)" == "true" ]; then
		#echo "NYI"
		DuckStation_flushEmulatorLauncher
	fi

	if [ "$(Flycast_IsInstalled)" == "true" ]; then
		#echo "NYI"
		Flycast_flushEmulatorLauncher
	fi

	if [ "$(MAME_IsInstalled)" == "true" ]; then
		#echo "NYI"
		MAME_flushEmulatorLauncher
	fi

	if [ "$(melonDS_IsInstalled)" == "true" ]; then
		#echo "NYI"
		melonDS_flushEmulatorLauncher
	fi

	if [ "$(mGBA_IsInstalled)" == "true" ]; then
		#echo "NYI"
		mGBA_flushEmulatorLauncher
	fi

	if [ "$(Model2_IsInstalled)" == "true" ]; then
		#echo "NYI"
		Model2_flushEmulatorLauncher
	fi

	if [ "$(PCSX2QT_IsInstalled)" == "true" ]; then
		#echo "NYI"
		PCSX2QT_flushEmulatorLauncher
	fi

	if [ "$(PPSSPP_IsInstalled)" == "true" ]; then
		#echo "NYI"
		PPSSPP_flushEmulatorLauncher
	fi

	if [ "$(Primehack_IsInstalled)" == "true" ]; then
		#echo "NYI"
		Primehack_flushEmulatorLauncher
	fi

	if [ "$(RetroArch_IsInstalled)" == "true" ]; then
		#echo "NYI"
		RetroArch_flushEmulatorLauncher
	fi

	if [ "$(RMG_IsInstalled)" == "true" ]; then
		#echo "NYI"
		RMG_flushEmulatorLauncher
	fi

	if [ "$(RPCS3_IsInstalled)" == "true" ]; then
		#echo "NYI"
		RPCS3_flushEmulatorLauncher
	fi

	if [ "$(Supermodel_IsInstalled)" == "true" ]; then
		#echo "NYI"
		Supermodel_flushEmulatorLauncher
	fi

	if [ "$(Vita3K_IsInstalled)" == "true" ]; then
		#echo "NYI"
		Vita3K_flushEmulatorLauncher
	fi

	if [ "$(Xemu_IsInstalled)" == "true" ]; then
		#echo "NYI"
		Xemu_flushEmulatorLauncher
	fi

	#Xenia temp fix
	if [ "$(Xenia_IsInstalled)" == "true" ]; then
		#echo "NYI"
		setSetting doInstallXenia "true"
		Xenia_flushEmulatorLauncher
	fi

	if [ "$(Yuzu_IsInstalled)" == "true" ]; then
		#echo "NYI"
		Yuzu_flushEmulatorLauncher
	fi

	#pcsx2 fix
	if [ ! -f "$HOME/.config/EmuDeck/.pcsx2211" ]; then
		cp "$HOME/.config/EmuDeck/backend/tools/launchers/pcsx2-qt.sh" "$toolsPath/launchers/pcsx2-qt.sh"
		touch "$HOME/.config/EmuDeck/.pcsx2211"
	fi

	# Init functions
	mkdir -p "$HOME/emudeck/logs"
	mkdir -p "$HOME/emudeck/feeds"

}
