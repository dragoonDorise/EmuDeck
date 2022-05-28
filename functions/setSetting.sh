#!/bin/bash
setSetting () {
	var=$1
	new_val=$2
	file=~/emudeck/settings.sh
	sed -i "s/^$var *= *.*/$var = $new_val/; s/^$var [^=]*$/$var $new_val/" "$file" | grep $var 
}