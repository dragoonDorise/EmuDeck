#!/bin/bash

# Dev variables (normally commented out)
#EMUDECKGIT="$HOME/github/EmuDeck" #dev

CloudScripts_update() {
	fixCloudScripts

	### Refresh cloud scripts
	cd $LOCALCLOUDFILES
	arrAll=() # All supported scripts
	for file in *.sh; do
    	arrAll+=("$file")
	done
	cd "$romsPath/cloud"
	arrExisting=() # Existing user selected scripts
	for file in *.sh; do
    	arrExisting+=("$file")
	done
	# Remove old scripts, excluding user renamed scripts
	for i in "${arrAll[@]}"; do
		rm "$romsPath/cloud/$i"
	done
	# Install updated scripts
	for i in "${arrExisting[@]}"; do
		cp "$LOCALCLOUDFILES/$i" "$romsPath/cloud"
		chmod +x "$romsPath/cloud/$i"
	done

	### Refresh remoteplay scripts
	cd $LOCALRPFILES
	arrAll=() # All supported scripts
	for file in *.sh; do
    	arrAll+=("$file")
	done
	cd "$romsPath/remoteplay"
	arrExisting=() # Existing user selected scripts
	for file in *.sh; do
    	arrExisting+=("$file")
	done
	# Remove old scripts, excluding user renamed scripts
	for i in "${arrAll[@]}"; do
		rm "$romsPath/remoteplay/$i"
	done
	# Install updated scripts
	for i in "${arrExisting[@]}"; do
		cp "$LOCALRPFILES/$i" "$romsPath/remoteplay"
		chmod +x "$romsPath/remoteplay/$i"
	done
}

csmSRMNotification() {
	TEXT=$(printf "<b>ATTENTION:</b>\nYou must update and run 'Steam ROM Manager' (the same as you would when adding or removing ROMS) for changes to take effect in Steam.\n")
	zenity --info --width=400 --text="$TEXT"
}

manageServicesMenu() {
	cd $LOCALCLOUDFILES
	declare -a arrAll=() # All supported services (excludes user-created scripts based on file name)
	declare -a arrServ=() # Services with install state for zenity
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
        csmMainMenu
    fi
	
	# Delete all old scripts that match file names from the github repo
	for i in "${arrAll[@]}"; do
		rm "$romsPath/cloud/$i" 
	done

	# Setup selected scripts
	IFS='|' read -r -a arrChosen <<< "$SERVICES"
	for i in "${arrChosen[@]}"; do
		cp "$LOCALCLOUDFILES/$i" "$romsPath/cloud"
		chmod +x "$romsPath/cloud/$i"
	done

	# Import steam profile
	rsync -r "$EMUDECKGIT/configs/steam-input/emudeck_cloud_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
	
	# Notify to update & run SRM
	csmSRMNotification

	# Return to menu
	csmMainMenu
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
installFP() {
	local ID="$1"
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo --user
	flatpak install flathub "$ID" -y --user
	flatpak override "$ID" --filesystem=host --user
	flatpak override "$ID" --share=network --user
}

manageRPSMenu() {
	# Create array of all Remote Play clients
	cd "$EMUDECKGIT/functions/RemotePlayClientScripts"
	declare -a arrAllRP=()
	
	Chiaki_IsInstalled
	ans=$?
	if [ "$ans" == "1" ]; then
		arrAllRP+=(true "Chiaki")
	else
		arrAllRP+=(false "Chiaki")
	fi

	Greenlight_IsInstalled
	ans=$?
	if [ "$ans" == "1" ]; then
		arrAllRP+=(true "Greenlight")
	else
		arrAllRP+=(false "Greenlight")
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


	Spotify_IsInstalled
	ans=$?
	if [ "$ans" == "1" ]; then
		arrAllRP+=(true "Spotify")
	else
		arrAllRP+=(false "Spotify")
	fi
	
	SteamLink_IsInstalled
	ans=$?
	if [ "$ans" == "1" ]; then
		arrAllRP+=(true "SteamLink")
	else
		arrAllRP+=(false "SteamLink")
	fi

	ShadowPC_IsInstalled
	ans=$?
	if [ "$ans" == "1" ]; then
		arrAllRP+=(true "ShadowPC")
	else
		arrAllRP+=(false "ShadowPC")
	fi


	# Dynamically build list of scripts
	RP=$(zenity --list  \
	--title="Cloud Services Manager" \
    --text="Select clients to install/update:" \
	--ok-label="Start" --cancel-label="Return to Main Menu" \
	--column="" --column="Disable to uninstall" \
    --width=300 --height=300 --checklist "${arrAllRP[@]}")
    if [ $? != 0 ]; then
        csmMainMenu
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
			elif [ "$i" == "Greenlight" ]; then
				Greenlight_IsInstalled
				ans=$?
				if [ "$ans" == "1" ]; then
					Greenlight_update
				else
					Greenlight_install
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
			elif [ "$i" == "Spotify" ]; then
				Spotify_IsInstalled
				ans=$?
				if [ "$ans" == "1" ]; then
					Spotify_update
				else
					Spotify_install
				fi 			
			elif [ "$i" == "SteamLink" ]; then
				SteamLink_IsInstalled
				ans=$?
				if [ "$ans" == "1" ]; then
					SteamLink_update
				else
					SteamLink_install
				fi
			elif [ "$i" == "ShadowPC" ]; then
				ShadowPC_IsInstalled
				ans=$?
				if [ "$ans" == "1" ]; then
					ShadowPC_update
				else
					ShadowPC_install
				fi

			fi
		done

		# Uninstall those not selected
		if [[ ! "${arrChosen[*]}" =~ "Chiaki" ]]; then
			Chiaki_uninstall
		fi
		if [[ ! "${arrChosen[*]}" =~ "Greenlight" ]]; then
			Greenlight_uninstall
		fi
		if [[ ! "${arrChosen[*]}" =~ "Moonlight" ]]; then
			Moonlight_uninstall
		fi
		if [[ ! "${arrChosen[*]}" =~ "Parsec" ]]; then
			Parsec_uninstall
		fi
		if [[ ! "${arrChosen[*]}" =~ "Spotify" ]]; then
			Spotify_uninstall
		fi
		if [[ ! "${arrChosen[*]}" =~ "SteamLink" ]]; then
			SteamLink_uninstall
   		fi
		if [[ ! "${arrChosen[*]}" =~ "ShadowPC" ]]; then
			ShadowPC_uninstall
		fi
	)	|	zenity --progress \
            --title="Cloud Services Manager" \
            --text="Processing..." \
            --percentage=0 \
            --no-cancel \
            --pulsate \
            --auto-close \
            --width=300
	
	# Notify to update & run SRM
	csmSRMNotification

	# Return to RPS Manager
	manageRPSMenu
}

changeSettingsMenu() {
	declare -a arrSupBrows=("com.google.Chrome" "com.microsoft.Edge"  "org.mozilla.firefox" "com.brave.Browser" "org.chromium.Chromium")
	declare -a arrBrowsOpts=()

	# Include system default browser and verify it is is installed
	defaultBrowser=$(
       	APP=$(xdg-settings get default-web-browser)
       	EXT=".desktop"
		# Exclude extension
       	echo "${APP%"$EXT"}"
    )
	isInstalled "$defaultBrowser"
	ans=$?
	if [ "$ans" == "1" ]; then
		arrBrowsOpts+=(false "System Default: $defaultBrowser" true)
	else
		arrBrowsOpts+=(false "System Default: $defaultBrowser" false)
	fi
	
	# Add supported browsers to selection list
	for brows in "${arrSupBrows[@]}"; do
		if [[ "$(flatpak --columns=app list | grep "${brows}")" == *"${brows}"* ]]; then
			arrBrowsOpts+=(false "$brows" true)
		else
			arrBrowsOpts+=(false "$brows" false)
		fi
	done

	BROWSER=$(zenity --list \
	--title="Cloud Services Manager" \
    --width=420 --height=320 --text="Select web browser:" \
	--column="" --column="Application" --column="Installed" \
	--radiolist "${arrBrowsOpts[@]}")
    if [ $? != 0 ]; then
        csmMainMenu
    fi

	# Setup progress bar and perform install & setup
    (
		arrChosen=()
		IFS='|' read -r -a arrChosen <<< "$BROWSER"
		for BROWSER in "${arrChosen[@]}"; do
			if [ "$BROWSER" == "System Default: $defaultBrowser" ]; then
				isInstalled "$defaultBrowser"
				ans=$?
				if [ "$ans" == "0" ]; then
					installFP "$defaultBrowser"
				fi
				setCloudSetting BROWSERAPP "$defaultBrowser"
				flatpak --user override --filesystem=/run/udev:ro "$defaultBrowser"
			else
				isInstalled "$BROWSER"
				ans=$?
				if [ "$ans" == "0" ]; then
					installFP "$BROWSER"
				fi
				setCloudSetting BROWSERAPP "$BROWSER"
				flatpak --user override --filesystem=/run/udev:ro "$BROWSER"
			fi
		done
	)	|	zenity --progress \
            --title="Cloud Services Manager" \
            --text="Processing..." \
            --percentage=0 \
            --no-cancel \
            --pulsate \
            --auto-close \
            --width=300

	# Return to menu
	csmMainMenu
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

csmMainMenu() {
	# Update values
	source "$CLOUDSETTINGSFILE"

	# Ask to install new services or change settings
	menuText=$(printf "<b>Main Menu</b>\n\n Currently Set Browser: $BROWSERAPP\n")
	CHOICE=$(zenity --list \
		--title="Cloud Services Manager" --text="$menuText" \
        --width=400  --height=400 \
		--ok-label="Select" \
		--cancel-label="Exit" \
		--column="" --column="Select an option:" --radiolist \
			"" "Manage Cloud Services" \
			"" "Manage Remote Play Clients" \
			"" "Add to ES-DE and Pegasus" \
			"" "Change Settings" \
			"" "Quit")
    if [ $? != 0 ]; then
        exit
    fi

	if [ "$CHOICE" == "Manage Cloud Services" ]; then
		manageServicesMenu
	elif [ "$CHOICE" == "Manage Remote Play Clients" ]; then
		manageRPSMenu
	elif [ "$CHOICE" == "Change Settings" ]; then
		changeSettingsMenu
	elif [ "$CHOICE" == "Add to ES-DE and Pegasus" ]; then
		addESDEPegasus
	elif [ "$CHOICE" == "Quit" ]; then
		exit
	fi
}

fixCloudScripts() {
	###v1.0 Fixes
	if [ "$cloudconfversion" == "" ]; then
		### Substitute "BROWSERAPP" for "FILEFORWARDING" in cloud scripts and cloud.conf
		cd "$romsPath/cloud"
		for file in ./*.sh; do
			sed -i 's/FILEFORWARDING/BROWSERAPP/g' "$file"
		done
		sed -i 's/FILEFORWARDING/BROWSERAPP/g' "$CLOUDSETTINGSFILE"

		### Removed "COMMAND" variable and reworked conf file
		# Refresh scripts
		cd $LOCALCLOUDFILES
		arrAll=() # All supported scripts
		for file in *.sh; do
    		arrAll+=("$file")
		done
		cd "$romsPath/cloud"
		arrExisting=() # Existing user selected scripts
		for file in *.sh; do
    		arrExisting+=("$file")
		done
		# Remove old scripts, excluding user renamed scripts
		for i in "${arrAll[@]}"; do
			rm "$romsPath/cloud/$i"
		done
		# Install updated scripts
		for i in "${arrExisting[@]}"; do
			cp "$LOCALCLOUDFILES/$i" "$romsPath/cloud"
			chmod +x "$romsPath/cloud/$i"
		done

		# Recreate conf file while preserving existing settings
		BROWSERAPP_temp="$BROWSERAPP"
		WINDOWSIZE_temp="$WINDOWSIZE"
		DEVICESCALEFACTOR_temp="$DEVICESCALEFACTOR"
		rm "$romsPath/cloud/cloud.conf"
		cp "$LOCALCLOUDFILES/cloud.conf" "$romsPath/cloud"
		CLOUDSETTINGSFILE="$romsPath/cloud/cloud.conf"
		source "$CLOUDSETTINGSFILE"
		setCloudSetting BROWSERAPP "$BROWSERAPP_temp"
		setCloudSetting WINDOWSIZE "$WINDOWSIZE_temp"
		setCloudSetting DEVICESCALEFACTOR "$DEVICESCALEFACTOR_temp"
	fi
}

addESDEPegasus(){


	# Ask to install new services or change settings
	esdepegasusmenuText=$(printf "<b>ES-DE and Pegasus</b>\n\n Would you like to add your selected cloud services and remote play clients to ES-DE and Pegasus?\n\n This will copy your cloud services and remote play clients to the Emulation/roms/desktop folder.\n\n When using ES-DE, your cloud services and remote play clients will show up under the Desktop system.\n\n When using Pegasus, your cloud services and remote play clients will show up under the Cloud Services and Remote Play Clients system respectively.\n\n This will have no impact on Steam ROM Manager or any shortcuts you may have added to Steam using Steam ROM Manager.\n\n ")
	ESDEPEGASUSCHOICE=$(zenity --list \
		--title="Cloud Services Manager" --text="$esdepegasusmenuText" \
        --width=350  --height=450 \
		--ok-label="Select" \
		--cancel-label="Return to Main Menu" \
		--column="" --column="Select an option:" --radiolist \
			"" "Add to ES-DE and Pegasus" \
			"" "Remove from ES-DE and Pegasus" )

    if [ $? != 0 ]; then
        csmMainMenu
    fi

	if [ "$ESDEPEGASUSCHOICE" == "Add to ES-DE and Pegasus" ]; then
		mkdir -p "$romsPath/desktop/cloud"
		mkdir -p "$romsPath/desktop/remoteplay"
		rsync -av --include='*.sh' --exclude='*' "$romsPath/cloud/" "$romsPath/desktop/cloud"
		rsync -av --include='*.sh' --exclude='*' "$romsPath/remoteplay/" "$romsPath/desktop/remoteplay"

		
		# Pegasus
		local pegasusDirectoriesFile="$HOME/.config/pegasus-frontend/game_dirs.txt"
		cp "$HOME/.config/EmuDeck/backend/roms/desktop/cloud/metadata.txt" "$romsPath/desktop/cloud"
		cp "$HOME/.config/EmuDeck/backend/roms/desktop/remoteplay/metadata.txt" "$romsPath/desktop/remoteplay"
		cp "$HOME/.config/EmuDeck/backend/roms/desktop/cloud/metadata.txt" "$romsPath/desktop/cloud"
		
		if ! grep -Fxq "$romsPath/desktop/cloud" "$pegasusDirectoriesFile"; then
			echo "$romsPath/desktop/cloud" >> "$pegasusDirectoriesFile"
		fi

		if ! grep -Fxq "$romsPath/desktop/remoteplay" "$pegasusDirectoriesFile"; then
			echo "$romsPath/desktop/remoteplay" >> "$pegasusDirectoriesFile"
		fi

		if [ -f "$romsPath/remoteplay/metadata.txt" ]; then 
			rm -f "$romsPath/remoteplay/metadata.txt"
		fi 

		if [ -f "$romsPath/cloud/metadata.txt" ]; then 
			rm -f "$romsPath/cloud/metadata.txt"
		fi 

		# Pegasus end
		
		zenity --info --text="Cloud services and remote play clients added to ES-DE and Pegasus." \
		--width=250 
		csmMainMenu
	elif [ "$ESDEPEGASUSCHOICE" == "Remove from ES-DE and Pegasus" ]; then
		find "$romsPath/desktop/cloud" -name "*.sh" -type f -delete
		find "$romsPath/desktop/remoteplay" -name "*.sh" -type f -delete
		zenity --info --text="Cloud services and remote play clients removed from ES-DE and Pegasus." \
		--width=250 
		csmMainMenu
	fi

}

##################
# Initialization #
##################

if [[ "$EMUDECKGIT" == "" ]]; then
    EMUDECKGIT="$HOME/.config/EmuDeck/backend"
fi
LOCALCLOUDFILES="$EMUDECKGIT/tools/cloud"
LOCALRPFILES="$EMUDECKGIT/tools/remoteplayclients"

source "$EMUDECKGIT/functions/all.sh"

# Check for existing cloud.conf or install & setup
mkdir -p "$romsPath/cloud"
mkdir -p "$romsPath/remoteplay"

if [ ! -f "$romsPath/cloud/cloud.conf" ]; then
	cp "$LOCALCLOUDFILES/cloud.conf" "$romsPath/cloud"
	CLOUDSETTINGSFILE="$romsPath/cloud/cloud.conf"
	source "$CLOUDSETTINGSFILE"

	# Set web browser to system default browser
	defaultBrowser=$(
        APP=$(xdg-settings get default-web-browser)
        EXT=".desktop"
		# Exclude extension
        echo "${APP%"$EXT"}"
    )
	setCloudSetting BROWSERAPP "$defaultBrowser"
	flatpak --user override --filesystem=/run/udev:ro "$defaultBrowser"
fi

# Update cloud.conf with latest config.
if ! grep -q "browsercommand()" "$romsPath/cloud/cloud.conf"; then
	cp "$LOCALCLOUDFILES/cloud.conf" "$romsPath/cloud"
	CLOUDSETTINGSFILE="$romsPath/cloud/cloud.conf"
	source "$CLOUDSETTINGSFILE"

	# Set web browser to system default browser
	defaultBrowser=$(
        APP=$(xdg-settings get default-web-browser)
        EXT=".desktop"
		# Exclude extension
        echo "${APP%"$EXT"}"
    )
	setCloudSetting BROWSERAPP "$defaultBrowser"
	flatpak --user override --filesystem=/run/udev:ro "$defaultBrowser"
fi 

CLOUDSETTINGSFILE="$romsPath/cloud/cloud.conf"
source "$CLOUDSETTINGSFILE"

# Fix old scripts & update
CloudScripts_update

# Load Menu
csmMainMenu
