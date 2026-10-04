#!/usr/bin/env bash

appImageInit() {

	#We force the python Venv to get created for the future migration to python
	if [ ! -x "$pyVenv/bin/python" ]; then
		py_run get_product_name >/dev/null
	fi
	
	#Remove armada fix
	sed -i 's|env LD_LIBRARY_PATH=[^ ]* ||' "$(xdg-user-dir DESKTOP)/EmuDeck.desktop" "$HOME/.local/share/applications/EmuDeck.desktop"
	  2>/dev/null
	
	#EmuDeck icons now open the launcher script instead of the AppImage
	if ! grep -q "$emudeckFolder/emudeck.sh" "$HOME/.local/share/applications/EmuDeck.desktop" 2>/dev/null; then
		createDesktopIcons
		#Restart the app through the new launcher, detached so it survives the kill
		local sandbox=""
		if command -v apt-get >/dev/null; then
			sandbox="--no-sandbox"
		fi
		setsid bash -c 'sleep 2; pkill -f "[.]mount_EmuDec"; sleep 1; "$HOME/.config/EmuDeck/emudeck.sh" '"$sandbox" >/dev/null 2>&1 < /dev/null &
	else
		cp "$emudeckBackend/tools/launchers/emudeck.sh" "$emudeckFolder/emudeck.sh"
		chmod +x "$emudeckFolder/emudeck.sh"
	fi

	#Migrate Xenia
	# if [ -f "$Xenia_legacyPath/xenia.config.toml" ]; then
	# 	zenity --question --title "Xenia migration" --text "Xenia Proton detected, it's recommended to update to the new Native release" --cancel-label "Cancel" --ok-label "OK"
	# 	if [ $? = 0 ]; then
	# 		Xenia_migrate
	# 	else
	# 		echo "continue"
	# 	fi
	# fi	
	
	#AutoMap set for old trick	
	if [ "$autoMap" = "false" ]; then		
		setSetting autoMapDolphin false
		setSetting autoMapSwitch false
		setSetting autoMapCemu false
		setSetting autoMap "null"	
	fi

	#Migrate DuckStation
	if [ -d "$HOME/.var/app/org.duckstation.DuckStation/config/duckstation" ]; then

		zenity --question --title "DuckStation migration" --text "DuckStation flatpak detected, it's recommended to update to the new AppImage release" --cancel-label "Cancel" --ok-label "OK"
		if [ $? = 0 ]; then
			DuckStation_install
			zenity --info --width=400 --text="DuckStation migration complete"
		else
			echo "continue"
		fi

	fi

	#Ryujinx SDL3
	if [ "$(Ryujinx_IsInstalled)" == "true" ] \
	   && jq -e '[.input_config[]? | .backend? // ""] | any(startswith("GamepadSDL2"))' "$Ryujinx_configFile" >/dev/null 2>&1; then
		Ryujinx_migrateToSDL3
	fi

	#Migrate emudeck folder
	if [ -f "$HOME/emudeck/settings.sh" ] &&  [ ! -L "$HOME/emudeck/settings.sh" ]; then
		# We move good old emudeck folder to .config
		rsync -avh "$HOME/emudeck/" "$emudeckFolder" && rm -rf "$HOME/emudeck" && mkdir "$HOME/emudeck" && ln -s "$emudeckFolder/settings.sh" "$HOME/emudeck/settings.sh"

		#Add Emus launchers to ESDE
		#ESDE_refreshCustomEmus

	fi
	mkdir "$HOME/emudeck"
	ln -s "$emudeckFolder/settings.sh" "$HOME/emudeck/settings.sh"


	# Init functions
	mkdir -p "$emudeckLogs"
	mkdir -p "$emudeckFolder/feeds"

	#We force the regeneration of all the installed launchers

	update_launchers

	flatpakDesktopRegenerate

}
