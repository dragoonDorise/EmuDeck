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

runRPSSettings()
{
	echo $progresspct
	# Install/Update/uninstall selected
	if [[ "${arrChosen[*]}" =~ "Chiaki" ]]; then
		if [[ $(Chiaki_IsInstalled) == "true" ]]; then
			echo "# Updating Chiaki"
			Chiaki_update &>/dev/null
		else
			echo "# Installing Chiaki"
			Chiaki_install &>/dev/null
			echo "ok"
		fi
	else
		echo "# Uninstalling Chiaki"
		Chiaki_uninstall &>/dev/null
	fi
	((progresspct += pct)) || true
	echo "$progresspct"

	if [[ "${arrChosen[*]}" =~ "Chiaking" ]]; then
		if [[ $(Chiaking_IsInstalled) == "true" ]]; then
			echo "# Updating Chiaking"
			Chiaking_update &>/dev/null
		else
			echo "# Installing Chiaking"
			Chiaking_install &>/dev/null
			echo "ok"
		fi
	else
		echo "# Uninstalling Chiaking"
		Chiaking_uninstall &>/dev/null
	fi
	((progresspct += pct)) || true
	echo "$progresspct"

	if [[ "${arrChosen[*]}" =~ "Greenlight" ]]; then
		if [[ $(Greenlight_IsInstalled) == "true" ]]; then
			echo "# Updating Greenlight"
			Greenlight_update &>/dev/null
		else
			echo "# Installing Greenlight"
			Greenlight_install &>/dev/null
			echo "ok"
		fi
	else
		echo "# Uninstalling Greenlight"
		Greenlight_uninstall &>/dev/null
	fi
	((progresspct += pct)) || true
	echo "$progresspct"

	if [[ "${arrChosen[*]}" =~ "Moonlight" ]]; then
		if [[ $(Moonlight_IsInstalled) == "true" ]]; then
			echo "# Updating Moonlight"
			Moonlight_update &>/dev/null
		else
			echo "# Installing Moonlight"
			Moonlight_install &>/dev/null
			echo "ok"
		fi
	else
		echo "# Uninstalling Moonlight"
		Moonlight_uninstall &>/dev/null
	fi
	((progresspct += pct)) || true
	echo "$progresspct"

	if [[ "${arrChosen[*]}" =~ "Parsec" ]]; then
		if [[ $(Parsec_IsInstalled) == "true" ]]; then
			echo "# Updating Parsec"
			Parsec_update &>/dev/null
		else
			echo "# Installing Parsec"
			Parsec_install &>/dev/null
			echo "ok"
		fi
	else
		echo "# Uninstalling Parsec"
		Parsec_uninstall &>/dev/null
	fi
	((progresspct += pct)) || true
	echo "$progresspct"

	if [[ "${arrChosen[*]}" =~ "SteamLink" ]]; then
		if [[ $(SteamLink_IsInstalled) == "true" ]]; then
			echo "# Updating SteamLink"
			SteamLink_update &>/dev/null
		else
			echo "# Installing SteamLink"
			SteamLink_install &>/dev/null
			echo "ok"
		fi
	else
		echo "# Uninstalling SteamLink"
		SteamLink_uninstall &>/dev/null
	fi
	((progresspct += pct)) || true
	echo "$progresspct"

	if [[ "${arrChosen[*]}" =~ "ShadowPC" ]]; then
		if [[ $(ShadowPC_IsInstalled) == "true" ]]; then
			echo "# Updating ShadowPC"
			ShadowPC_update &>/dev/null
		else
			echo "# Installing ShadowPC"
			ShadowPC_install &>/dev/null
			echo "ok"
		fi
	else
		echo "# Uninstalling ShadowPC"
		ShadowPC_uninstall &>/dev/null
	fi

	echo "# Complete!"
	echo "100" #exits the zenity with auto-close, sets the progress bar to 100%

}

runGASettings()
{
	echo $progresspct
	# Install/Update/uninstall selected

	if [[ "${arrChosen[*]}" =~ "Bottles" ]]; then
		if [[ $(Bottles_IsInstalled) == "true" ]]; then
			echo "# Updating Bottles"
			Bottles_update &>/dev/null
		else
			echo "# Installing Bottles"
			Bottles_install &>/dev/null
			echo "ok"
		fi
	else
		echo "# Uninstalling Bottles"
		Bottles_uninstall &>/dev/null
	fi
	((progresspct += pct)) || true
	echo "$progresspct"

	if [[ "${arrChosen[*]}" =~ "Cider" ]]; then
		if [[ $(Cider_IsInstalled) == "true" ]]; then
			echo "# Updating Cider"
			Cider_update &>/dev/null
		else
			echo "# Installing Cider"
			Cider_install &>/dev/null
			echo "ok"
		fi
	else
		echo "# Uninstalling Cider"
		Cider_uninstall &>/dev/null
	fi
	((progresspct += pct)) || true
	echo "$progresspct"

	if [[ "${arrChosen[*]}" =~ "Flatseal" ]]; then
		if [[ $(Flatseal_IsInstalled) == "true" ]]; then
			echo "# Updating Flatseal"
			Flatseal_update &>/dev/null
		else
			echo "# Installing Flatseal"
			Flatseal_install &>/dev/null
			echo "ok"
		fi
	else
		echo "# Uninstalling Flatseal"
		Flatseal_uninstall &>/dev/null
	fi
	((progresspct += pct)) || true
	echo "$progresspct"

	if [[ "${arrChosen[*]}" =~ "Heroic Games Launcher" ]]; then
		if [[ $(Heroic_IsInstalled) == "true" ]]; then
			echo "# Updating Heroic"
			Heroic_update &>/dev/null
		else
			echo "# Installing Heroic"
			Heroic_install &>/dev/null
			echo "ok"
		fi
	else
		echo "# Uninstalling Heroic"
		Heroic_uninstall &>/dev/null
	fi
	((progresspct += pct)) || true
	echo "$progresspct"

	if [[ "${arrChosen[*]}" =~ "Lutris" ]]; then
		if [[ $(Lutris_IsInstalled) == "true" ]]; then
			echo "# Updating Lutris"
			Lutris_update &>/dev/null
		else
			echo "# Installing Lutris"
			Lutris_install &>/dev/null
			echo "ok"
		fi
	else
		echo "# Uninstalling Lutris"
		Lutris_uninstall &>/dev/null
	fi
	((progresspct += pct)) || true
	echo "$progresspct"

	if [[ "${arrChosen[*]}" =~ "Plexamp" ]]; then
		if [[ $(Plexamp_IsInstalled) == "true" ]]; then
			echo "# Updating Plexamp"
			Plexamp_update &>/dev/null
		else
			echo "# Installing Plexamp"
			Plexamp_install &>/dev/null
			echo "ok"
		fi
	else
		echo "# Uninstalling Plexamp"
		Plexamp_uninstall &>/dev/null
	fi
	((progresspct += pct)) || true
	echo "$progresspct"

	if [[ "${arrChosen[*]}" =~ "Spotify" ]]; then
		if [[ $(Spotify_IsInstalled) == "true" ]]; then
			echo "# Updating Spotify"
			Spotify_update &>/dev/null
		else
			echo "# Installing Spotify"
			Spotify_install &>/dev/null
			echo "ok"
		fi
	else
		echo "# Uninstalling Spotify"
		Spotify_uninstall &>/dev/null
	fi
	((progresspct += pct)) || true
	echo "$progresspct"

	if [[ "${arrChosen[*]}" =~ "Tidal" ]]; then
		if [[ $(Tidal_IsInstalled) == "true" ]]; then
			echo "# Updating Tidal"
			Tidal_update &>/dev/null
		else
			echo "# Installing Tidal"
			Tidal_install &>/dev/null
			echo "ok"
		fi
	else
		echo "# Uninstalling Tidal"
		Tidal_uninstall &>/dev/null
	fi
	((progresspct += pct)) || true
	echo "$progresspct"

	if [[ "${arrChosen[*]}" =~ "Warehouse" ]]; then
		if [[ $(Warehouse_IsInstalled) == "true" ]]; then
			echo "# Updating Warehouse"
			Warehouse_update &>/dev/null
		else
			echo "# Installing Warehouse"
			Warehouse_install &>/dev/null
			echo "ok"
		fi
	else
		echo "# Uninstalling Warehouse"
		Warehouse_uninstall &>/dev/null
	fi
	((progresspct += pct)) || true
	echo "$progresspct"

	echo "# Complete!"
	echo "100" #exits the zenity with auto-close, sets the progress bar to 100%

}

manageRPSMenu() {
	# Create array of all Remote Play clients
	cd "$EMUDECKGIT/functions/RemotePlayClientScripts" || return
	declare -a arrAllRP=()

	arrAllRP+=( $(Chiaki_IsInstalled) "Chiaki")
	arrAllRP+=( $(Chiaking_IsInstalled) "Chiaking")
	arrAllRP+=( $(Greenlight_IsInstalled) "Greenlight")
	arrAllRP+=( $(Moonlight_IsInstalled) "Moonlight")
	arrAllRP+=( $(Parsec_IsInstalled) "Parsec")
	arrAllRP+=( $(SteamLink_IsInstalled) "SteamLink")
	arrAllRP+=( $(ShadowPC_IsInstalled) "ShadowPC")
	echo "list: ${arrAllRP[*]}"

	# Dynamically build list of scripts
	RP=$(zenity --list  \
	--title="Cloud Services Manager" \
    --text="Select clients to install/update:" \
	--ok-label="Start" --cancel-label="Return to Main Menu" \
	--column="" --column="Disable to uninstall" \
    --width=300 --height=350 --checklist "${arrAllRP[@]}")
    if [ $? != 0 ]; then
        csmMainMenu
    fi

	arrChosen=()
	IFS='|' read -r -a arrChosen <<< "$RP"
	progresspct=0

	pct=$((100 / ((${#arrAllRP[@]} + 1) / 2)))

	echo "User selected: ${arrChosen[*]}"
	echo "percentage for progress: $pct"

	# Setup progress bar and perform install/update/uninstall of selected items
   	runRPSSettings | zenity --progress \
            --title="Cloud Services Manager" \
            --text="Processing..." \
            --no-cancel \
			--percentage=0 \
            --width=600 \
			--height=250 2>/dev/null

	# Notify to update & run SRM
	csmSRMNotification

	# Return to RPS Manager
	manageRPSMenu
}

manageGAMenu() {
	# Create array of all Generic Applications
	cd "$EMUDECKGIT/functions/GenericApplicationsScripts" || return
	declare -a arrAllGA=()

	arrAllGA+=( $(Bottles_IsInstalled) "Bottles")
	arrAllGA+=( $(Cider_IsInstalled) "Cider")
	arrAllGA+=( $(Flatseal_IsInstalled) "Flatseal")
	arrAllGA+=( $(Heroic_IsInstalled) "Heroic Games Launcher")
	arrAllGA+=( $(Lutris_IsInstalled) "Lutris")
	arrAllGA+=( $(Plexamp_IsInstalled) "Plexamp")
	arrAllGA+=( $(Spotify_IsInstalled) "Spotify")
	arrAllGA+=( $(Tidal_IsInstalled) "Tidal")
	arrAllGA+=( $(Warehouse_IsInstalled) "Warehouse")
	echo "list: ${arrAllGA[*]}"

	# Dynamically build list of scripts
	GA=$(zenity --list  \
	--title="Cloud Services Manager" \
    --text="Select clients to install/update:" \
	--ok-label="Start" --cancel-label="Return to Main Menu" \
	--column="" --column="Disable to uninstall" \
    --width=300 --height=350 --checklist "${arrAllGA[@]}")
    if [ $? != 0 ]; then
        csmMainMenu
    fi

	arrChosen=()
	IFS='|' read -r -a arrChosen <<< "$GA"
	progresspct=0

	pct=$((100 / ((${#arrAllGA[@]} + 1) / 2)))

	echo "User selected: ${arrChosen[*]}"
	echo "percentage for progress: $pct"

	# Setup progress bar and perform install/update/uninstall of selected items
   	runGASettings | zenity --progress \
            --title="Cloud Services Manager" \
            --text="Processing..." \
            --no-cancel \
			--percentage=0 \
            --width=600 \
			--height=250 2>/dev/null

	# Notify to update & run SRM
	csmSRMNotification

	# Return to GA Manager
	manageGAMenu
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
			"" "Manage Generic Applications" \
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
	elif [ "$CHOICE" == "Manage Generic Applications" ]; then
		manageGAMenu 
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
	esdepegasusmenuText=$(printf "<b>ES-DE and Pegasus</b>\n\n Would you like to add your selected cloud services, generic applications, and remote play clients to ES-DE and Pegasus?\n\n This will copy your cloud services, generic applications, and remote play clients to the Emulation/roms/desktop folder.\n\n When using ES-DE, your cloud services, generic applications, and remote play clients will show up under the Desktop system.\n\n When using Pegasus, your cloud services and remote play clients will show up under the Cloud Services, Generic Applications, and Remote Play Clients system respectively.\n\n This will have no impact on Steam ROM Manager or any shortcuts you may have added to Steam using Steam ROM Manager.\n\n ")
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
		mkdir -p "$romsPath/desktop/generic-applications"
		mkdir -p "$romsPath/desktop/remoteplay"
		rsync -av --include='*.sh' --exclude='*' "$romsPath/cloud/" "$romsPath/desktop/cloud"
		rsync -av --include='*.sh' --exclude='*' "$romsPath/remoteplay/" "$romsPath/desktop/remoteplay"
		rsync -av --include='*.sh' --exclude='*' "$romsPath/generic-applications/" "$romsPath/desktop/generic-applications"


		# Pegasus
		local pegasusDirectoriesFile="$HOME/.config/pegasus-frontend/game_dirs.txt"
		cp "$HOME/.config/EmuDeck/backend/roms/desktop/cloud/metadata.txt" "$romsPath/desktop/cloud"
		cp "$HOME/.config/EmuDeck/backend/roms/desktop/remoteplay/metadata.txt" "$romsPath/desktop/remoteplay"
		cp "$HOME/.config/EmuDeck/backend/roms/desktop/generic-applications/metadata.txt" "$romsPath/desktop/generic-applications"

		if ! grep -Fxq "$romsPath/desktop/cloud" "$pegasusDirectoriesFile"; then
			echo "$romsPath/desktop/cloud" >> "$pegasusDirectoriesFile"
		fi

		if ! grep -Fxq "$romsPath/desktop/generic-applications" "$pegasusDirectoriesFile"; then
			echo "$romsPath/desktop/generic-applications" >> "$pegasusDirectoriesFile"
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

		zenity --info --text="Cloud services, generic applications, and remote play clients added to ES-DE and Pegasus." \
		--width=250
		csmMainMenu
	elif [ "$ESDEPEGASUSCHOICE" == "Remove from ES-DE and Pegasus" ]; then
		find "$romsPath/desktop/cloud" -name "*.sh" -type f -delete
		find "$romsPath/desktop/remoteplay" -name "*.sh" -type f -delete
		find "$romsPath/desktop/generic-applications" -name "*.sh" -type f -delete
		zenity --info --text="Cloud services, generic applications, and remote play clients removed from ES-DE and Pegasus." \
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
mkdir -p "$romsPath/generic-applications"
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
