#!/bin/bash

# Dev variables (normally commented out)
# HOME="/home/deck" #dev
  EMUDECKGIT="$HOME/.config/EmuDeck/backend" #dev
  source "$EMUDECKGIT/functions/all.sh" #dev

manageServices() {
	cd $LOCALCLOUDFILES
	declare -a arrAll # All supported services (excludes user-created scripts based on file name)
	declare -a arrServ # Services with install state for zenity
	for file in *.sh; do
    	arrAll+=("$file")
		if [ -f "$romsPath/cloud/$file" ]; then
    		arrServ+=(true "$file")
		else
    		arrServ+=(false "$file")
		fi
	done

	# Dynamically build list of scripts
	menuText=$(printf "Select Services to Install/Update: \n\n Uncheck to uninstall\n")
	SERVICES=$(zenity --list \
	--title="Cloud Services Manager" \
    --width=350 --height=600 --text="$menuText" \
	--column="" --column="Description" --checklist "${arrServ[@]}")
    if [ $? != 0 ]; then
        mainMenu
    fi
	
	# Delete all old scripts that match file names from the github repo
	cd "$romsPath/cloud"
	for i in "${arrAll[@]}"; do
		rm "./$i" 
	done

	# Setup selected scripts
	IFS='|' read -r -a arrChosen <<< "$SERVICES"
    cd $LOCALCLOUDFILES
	for i in "${arrChosen[@]}"; do
		chmod +x "./$i"
		cp "./$i" "$romsPath/cloud"
	done
	fixCloudScripts

	# Import steam profile
	rsync -r "$EMUDECKGIT/configs/steam-input/emudeck_cloud_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"

	# Return to menu
	mainMenu
}

# Check if installed
isInstalled() {
	local ID="$1"
	if [ "$(flatpak --columns=app list | grep "$1")" == "$1" ]; then
		return 1
	else
		return 0
	fi
}

# Install Flatpak
installFP(){
	local ID="$1"
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo --user
	flatpak install flathub "$ID" -y --user
	flatpak override "$ID" --filesystem=host --user
	flatpak override "$ID" --share=network --user
}

manageRPS() {
	# Create array of all Remote Play clients
	cd "$EMUDECKGIT/functions/RemotePlayClientScripts"
	declare -a arrAllRP
	Chiaki_IsInstalled
	ans=$?
	if [ "$ans" == "1" ]; then
		arrAllRP+=(true "Chiaki")
	else
		arrAllRP+=(false "Chiaki")
	fi

	Moonlight_IsInstalled
	ans=$?
	if [ "$ans" == "1" ]; then
		arrAllRP+=(true "Moonlight")
	else
		arrAllRP+=(false "Moonlight")
	fi

	Parsec_IsInstalled
	ans=$?
	if [ "$ans" == "1" ]; then
		arrAllRP+=(true "Parsec")
	else
		arrAllRP+=(false "Parsec")
	fi

	# Dynamically build list of scripts
	RP=$(zenity --list  \
	--title="Cloud Services Manager" \
    --text="Select clients to install/update:" \
	--ok-label="Start" --cancel-label="Return to Main Menu" \
	--column="" --column="Disable to uninstall" \
    --width=300 --height=300 --checklist "${arrAllRP[@]}")
    if [ $? != 0 ]; then
        mainMenu
    fi

	# Setup progress bar and perform install/update/uninstall of selected items
    (
		arrChosen=()
		IFS='|' read -r -a arrChosen <<< "$RP"
		for i in "${arrChosen[@]}"; do
			# Install/Update selected
			if [ "$i" == "Chiaki" ]; then
				Chiaki_IsInstalled
				ans=$?
				if [ "$ans" == "1" ]; then
					Chiaki_update
				else
					Chiaki_install
				fi
			elif [ "$i" == "Moonlight" ]; then
				Moonlight_IsInstalled
				ans=$?
				if [ "$ans" == "1" ]; then
					Moonlight_update
				else
					Moonlight_install
				fi
			elif [ "$i" == "Parsec" ]; then
				Parsec_IsInstalled
				ans=$?
				if [ "$ans" == "1" ]; then
					Parsec_update
				else
					Parsec_install
				fi
			fi
		done

		# Uninstall those not selected
		if [[ ! "${arrChosen[*]}" =~ "Chiaki" ]]; then
			Chiaki_uninstall
		fi
		if [[ ! "${arrChosen[*]}" =~ "Moonlight" ]]; then
			Moonlight_uninstall
		fi
		if [[ ! "${arrChosen[*]}" =~ "Parsec" ]]; then
			Parsec_uninstall
		fi
	)	|	zenity --progress \
            --title="Cloud Services Manager" \
            --text="Processing..." \
            --percentage=0 \
            --no-cancel \
            --pulsate \
            --auto-close \
            --width=300
	
	# Return to RPS Manager
	manageRPS
}

changeSettings() {
	# Supported browsers:
	declare -a arrSupBrows=("com.google.Chrome" "com.microsoft.Edge" "org.mozilla.firefox")
	declare -a arrBrowsOpts
	for brows in "${arrSupBrows[@]}"; do
		if [ "$(flatpak --columns=app list | grep "$brows")" == "$brows" ]; then
			arrBrowsOpts+=(false "$brows" true)
		else
			arrBrowsOpts+=(false "$brows" false)
		fi
	done

	BROWSER=$(zenity --list \
	--title="Cloud Services Manager" \
    --width=400 --height=300 --text="Set default web browser:" \
	--column="" --column="Application" --column="Installed" \
	--radiolist "${arrBrowsOpts[@]}")
    if [ $? != 0 ]; then
        mainMenu
    fi

	# Setup progress bar and perform install & setup
    (
		arrChosen=()
		IFS='|' read -r -a arrChosen <<< "$BROWSER"
		for BROWSER in "${arrChosen[@]}"; do
			if [[ $BROWSER == 'com.google.Chrome' ]]; then
				isInstalled "$BROWSER"
				ans=$?
				if [ "$ans" == "0" ]; then
					installFP "$BROWSER"
				fi
				setCloudSetting COMMAND "/app/bin/chrome"
				setCloudSetting BROWSERAPP "$BROWSER"
				flatpak --user override --filesystem=/run/udev:ro "$BROWSER"
			elif [[ $BROWSER == 'com.microsoft.Edge' ]]; then
				isInstalled "$BROWSER"
				ans=$?
				if [ "$ans" == "0" ]; then
					installFP "$BROWSER"
				fi
				setCloudSetting COMMAND "/app/bin/edge"
				setCloudSetting BROWSERAPP "$BROWSER"
				flatpak --user override --filesystem=/run/udev:ro "$BROWSER"
			elif [[ $BROWSER == 'org.mozilla.firefox' ]]; then
				isInstalled "$BROWSER"
				ans=$?
				if [ "$ans" == "0" ]; then
					installFP "$BROWSER"
				fi
				setCloudSetting COMMAND "firefox"
				setCloudSetting BROWSERAPP "$BROWSER"
				flatpak --user override --filesystem=/run/udev:ro "$BROWSER"
			fi
		done
	)	|	zenity --progress \
            --title="Cloud Services Manager" \
            --text="Installing..." \
            --percentage=0 \
            --no-cancel \
            --pulsate \
            --auto-close \
            --width=300

	# Return to menu
	mainMenu
}

# Keyword replacement file. Only matches start of word
changeLine() {
    local KEYWORD=$1
    local REPLACE=$2
    local FILE=$3

    local OLD=$(printf '%s\n' "$KEYWORD" | sed -e 's/[]\/$*.^[]/\\&/g')
    local NEW=$(printf '%s\n' "$REPLACE" | sed -e 's/[]\/$*.^[]/\\&/g')
    
    sed -i "/^${OLD}/c\\${NEW}" "$FILE"
}

setCloudSetting() {
	local var=$1
	local new_val=$2

	changeLine "$var=" "$var=$new_val" "$CLOUDSETTINGSFILE"

	# Update values
	source "$CLOUDSETTINGSFILE"
}

mainMenu() {
	# Update values
	source "$CLOUDSETTINGSFILE"

	# Ask to install new services or change settings
	menuText=$(printf "<b>Main Menu</b>\n\n Currently Set Browser: $BROWSERAPP\n")
	CHOICE=$(zenity --list \
		--title="Cloud Services Manager" --text="$menuText" \
        --width=300  --height=300 \
		--column="" --column="Select an option:" --radiolist \
			"" "Manage Cloud Services" \
			"" "Manage Remote Play Clients" \
			"" "Change Settings" \
			"" "Quit")
    if [ $? != 0 ]; then
        exit
    fi

	if [[ $CHOICE == 'Manage Cloud Services' ]]; then
		manageServices
	elif [[ $CHOICE == 'Manage Remote Play Clients' ]]; then
		manageRPS
	elif [[ $CHOICE == 'Change Settings' ]]; then
		changeSettings
	elif [[ $CHOICE == 'Quit' ]]; then
		exit
	fi
}

fixCloudScripts() {
	# Substitute "BROWSERAPP" for "BROWSERAPP" in cloud scripts and cloud.conf
	cd "$romsPath/cloud"
	for file in ./*.sh; do
		sed -i 's/FILEFORWARDING/BROWSERAPP/g' "$file"
	done

	sed -i 's/FILEFORWARDING/BROWSERAPP/g' "$CLOUDSETTINGSFILE"
}

##################
# Initialization #
##################

LOCALCLOUDFILES="$HOME/.config/EmuDeck/backend/tools/cloud"

# Check for exsisting cloud.conf or download fresh
mkdir -p "$romsPath/cloud"
mkdir -p "$romsPath/remoteplay"
if [ ! -f "$romsPath/cloud/cloud.conf" ]; then
	cp "$LOCALCLOUDFILES/cloud.conf" "$romsPath/cloud"
fi
CLOUDSETTINGSFILE="$romsPath/cloud/cloud.conf"
source "$romsPath/cloud/cloud.conf"

# Fix old scripts
fixCloudScripts

# Load Menu
mainMenu
