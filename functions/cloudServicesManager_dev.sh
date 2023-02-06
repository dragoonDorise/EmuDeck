#!/bin/bash
source ./all.sh #dev

# GIT URL for downloads
EMUDECKGITURL=https://github.com/dragoonDorise/EmuDeck.git #dev
EMUDECKGITBRANCH=main #dev
#LOCALCLOUDFILES="$HOME/.config/EmuDeck/backend/tools/cloud"
LOCALCLOUDFILES=~/Downloads/EmuDeck_temp/tools/cloud #dev

manageServices() {
	# Download all cloud service scripts
	sparseCheckoutLocal #dev
	
	# Create array of files
	cd $LOCALCLOUDFILES
	declare -a arrAll
	declare -a arrServ
	for file in *.sh; do
    	arrAll+=("$file")
		if [ -f "$romsPath/cloud/$file" ]; then
    		arrServ+=(true "$file")
		else
    		arrServ+=(false "$file")
		fi
	done

	# Dynamically build list of scripts
	local SERVICES=$(zenity --list \
	--title="Cloud Services Manager" \
    --width=300 --height=600 --text="Select Services to Install:" \
	--column="" --column="Description" --checklist "${arrServ[@]}")
	
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
	#cd "$EMUDECKGIT/functions/RemotePlayClientScripts"
	cd "$HOME/github/EmuDeck/functions/RemotePlayClientScripts" #dev
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

	local BROWSER=$(zenity --list \
	--title="Cloud Services Manager" \
    --width=400 --height=300 --text="Set default web browser:" \
	--column="" --column="Application" --column="Installed" \
	--radiolist "${arrBrowsOpts[@]}")

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
				setCloudSetting FILEFORWARDING "$BROWSER"
				flatpak --user override --filesystem=/run/udev:ro "$BROWSER"
			elif [[ $BROWSER == 'com.microsoft.Edge' ]]; then
				isInstalled "$BROWSER"
				ans=$?
				if [ "$ans" == "0" ]; then
					installFP "$BROWSER"
				fi
				setCloudSetting COMMAND "/app/bin/edge"
				setCloudSetting FILEFORWARDING "$BROWSER"
				flatpak --user override --filesystem=/run/udev:ro "$BROWSER"
			elif [[ $BROWSER == 'org.mozilla.firefox' ]]; then
				isInstalled "$BROWSER"
				ans=$?
				if [ "$ans" == "0" ]; then
					installFP "$BROWSER"
				fi
				setCloudSetting COMMAND "firefox"
				setCloudSetting FILEFORWARDING "$BROWSER"
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

# Create a temp folder in the Downloads folder and only pull "tools/cloud" directory. #dev
sparseCheckoutLocal() {
    (
        cd ~/Downloads
        git init EmuDeck_temp
        cd EmuDeck_temp
        git remote add -f origin $EMUDECKGITURL
        git config core.sparseCheckout true
        echo "tools/cloud" >> .git/info/sparse-checkout
        git pull origin $EMUDECKGITBRANCH
    ) 	|	zenity --progress \
            --title="Cloud Services Manager" \
            --text="Downloading scripts..." \
            --percentage=0 \
            --no-cancel \
            --pulsate \
            --auto-close \
            --width=300
        
    if [ "$?" = -1 ] ; then
        zenity --error --text="Update canceled."
    fi
}

mainMenu() {
	# Update values
	source "$CLOUDSETTINGSFILE"

	# Ask to install new services or change settings
	menuText=$(printf "<b>Main Menu</b>\n\n Currently Set Browser: $FILEFORWARDING\n")
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
	exit
}

##################
# Initialization #
##################

# Check for exsisting cloud.conf or download fresh
mkdir -p "$romsPath/cloud"
if [ ! -f "$romsPath/cloud/cloud.conf" ]; then
	cp "$HOME/.config/EmuDeck/backend/tools/cloud/cloud.conf" "$romsPath/cloud"
fi
CLOUDSETTINGSFILE="$romsPath/cloud/cloud.conf"
source "$romsPath/cloud/cloud.conf"

# Load Menu
mainMenu
