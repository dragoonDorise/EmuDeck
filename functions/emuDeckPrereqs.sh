#!/bin/bash
OS_setupPrereqsArch(){		

	#Ensure the dependencies are installed before proceeding.
	for package in packagekit-qt5 flatpak rsync unzip jq bash curl 
	do
		pacman -Q ${package}  || sudo pacman -Sy --noconfirm ${package} 
	done
	
	#The user must be in the wheel group to install flatpaks successfully.
	wheel=$(awk '/'"${USER}"'/ {if ($1 ~ /wheel/) print}' /etc/group)
	if [[ ! "${wheel}" =~ ${USER} ]]; then
		text="$(printf "Hey! This is not an SteamDeck. EmuDeck can work just fine, but you need to have a valid user account\n\nThe script will ask for your password to make sure everything works as expected.")"
		zenity --info \
		--title="EmuDeck" \
		--width=450 \
		--text="${text}" 2>/dev/null
		sudo usermod -a -G wheel "${USER}" 
		newgrp wheel
	fi
	
	#Ensure the Desktop directory isn't owned by root
	if [[ "$(stat -c %U "${HOME}"/Desktop)" =~ root ]]; then
		sudo chown -R "${USER}":"${USER}" ~/Desktop 
	fi	
}