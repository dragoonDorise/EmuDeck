#!/usr/bin/env bash
launcherInit() {
	
	#Update launchers	
	update_launchers
	
	#Enable autoMap only on Non Steam Deck but only if autoMap doesn't exist.	
	if [ "$(getProductName)" == "Jupiter" ] || [ "$(getProductName)" == "Galileo" ]; then
		echo "SteamDeck, we do nothing, let the user decide."
	else
		if [ -z "${autoMap}" ]; then
			autoMapOn
		fi
	fi
		

}
