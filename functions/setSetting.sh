#!/bin/bash
setSetting () {
	local var=$1
	local new_val=$2	
	settingsFile="$HOME/emudeck/settings.sh"
	settingExists=$(grep -rw "$settingsFile" -e "$var")
	if [[ $settingExists == '' ]]; then
		#insert setting to end
		echo "variable not found in settings. Adding $var=$new_val to $settingsFile"
		sed -i -e '$a\'"$var=$new_val" "$settingsFile"
	elif [[ ! $settingExists == '' ]]; then
		echo "Old value $settingExists"
			if [[ $settingExists == "$var=$new_val" ]]; then
				echo "Setting unchanged, skipping"
			else
				changeLine "$var" "$var=$new_val" "$settingsFile"
			fi
	fi
	#Update values
	# shellcheck source=settings.sh
	source "$HOME/emudeck/settings.sh"
}