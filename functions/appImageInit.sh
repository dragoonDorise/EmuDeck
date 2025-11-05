#!/bin/bash
appImageInit() {


	#Migrate DuckStation

	if [ -d "$HOME/.var/app/org.duckstation.DuckStation/config/duckstation" ]; then

		zenity --question --title "DuckStation migration" --text "DuckStation flatpak detected, it's recommended to update to the new AppImage release" --cancel-label "Cancel" --ok-label "OK"
		if [ $? = 0 ]; then
			Duckstation_install
			zenity --info --width=400 --text="DuckStation migration complete"
		else
			echo "continue"
		fi

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

}
