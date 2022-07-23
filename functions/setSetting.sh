#!/bin/bash
setSetting () {
	var=$1
	new_val=$2	
	file="$HOME/emudeck/settings.sh"
	settingExists=$(grep -rw "$file" -e "$var")
	if [[ $settingExists == '' ]]; then
		#insert setting to end
		sed -i -e '$a\'"$var=$new_val" $FILE
	elif [[ ! $settingExists == '' ]]; then
		echo "Old value $settingExists"
			if [[ $settingExists == "$var=$new_val" ]]; then
				echo "Setting unchanged, skipping"
			else
				changeLine "$var" "$var=$new_val" "$file"
			fi
	fi
	#Update values

	source "$HOME/emudeck/settings.sh"
}