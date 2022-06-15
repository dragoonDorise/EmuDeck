#!/bin/bash
setSetting () {
	var=$1
	new_val=$2	
	file=~/emudeck/settings.sh
	settingExists=$(grep -rnw $file -e $var)
	if [[ $settingExists == '' ]]; then
		#insert setting to end
		sed -i -e '$a\'"$var=$new_val" $FILE
	elif [[ ! $settingExists == '' ]]; then
		#update setting
		sed -i "s|^$var *= *.*|$var=$new_val|; s|^$var [^=]*$|$var $new_val|" "$file"
	fi
	#Update values
	source ~/emudeck/settings.sh
}