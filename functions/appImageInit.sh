#!/bin/bash
appImageInit() {

	#Migrate emudeck folder

	if [ -f "$HOME/emudeck/settings.sh" ] &&  [ ! -L "$HOME/emudeck/settings.sh" ]; then
		# We move good old emudeck folder to .config
		rsync -avh "$HOME/emudeck/" "$emudeckFolder" && rm -rf "$HOME/emudeck" && mkdir "$HOME/emudeck" && ln -s "$emudeckFolder/settings.sh" "$HOME/emudeck/settings.sh"

		#Add Emus launchers to ESDE
		rsync -avhp --mkpath "$emudeckBackend/chimeraOS/configs/emulationstation/custom_systems/es_find_rules.xml" "$(dirname "$es_rulesFile")" --backup --suffix=.bak
		sed -i "s|/run/media/mmcblk0p1/Emulation|${emulationPath}|g" "$es_rulesFile"

	fi


	# Init functions
	mkdir -p "$emudeckLogs"
	mkdir -p "$emudeckFolder/feeds"

}
