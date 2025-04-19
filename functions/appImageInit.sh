#!/bin/bash
appImageInit() {

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

}
