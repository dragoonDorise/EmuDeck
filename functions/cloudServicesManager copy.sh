#!/bin/bash
source ./all.sh
source ./setMSG.sh #dev
source ./RemotePlayClientScripts/remotePlayChiaki.sh #dev
source ./RemotePlayClientScripts/remotePlayParsec.sh #dev
source ./RemotePlayClientScripts/remotePlayMoonlight.sh #dev

# GIT Variables
EMUDECKGITURL=https://github.com/dragoonDorise/EmuDeck.git
EMUDECKGITBRANCH=main #Add-cloud-gaming

manageServices() {
	# Download all cloud service scripts
	sparseCheckoutLocal
	
	# Create array of files
	cd ~/Downloads/EmuDeck_temp/tools/cloud
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
    cd ~/Downloads/EmuDeck_temp/tools/cloud
	for i in "${arrChosen[@]}"; do
		chmod +x "./$i"
		cp "./$i" "$romsPath/cloud"
	done

	# Return to menu
	mainMenu
}

manageRPS() {
	# Create array of all Remote Play clients
	#cd "${EMUDECKGIT}"/functions/RemotePlayClientScripts/
	cd "$HOME/github/EmuDeck/functions/RemotePlayClientScripts" #(dev)
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

	# Setup progress bar and perform install/update/uninstall of selected items
	progressStarted="false"

    (
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
			Chiaki_IsInstalled
			ans=$?
			if [ "$ans" == "1" ]; then
				Chiaki_uninstall
			fi
		elif [[ ! "${arrChosen[*]}" =~ "Moonlight" ]]; then
			Moonlight_IsInstalled
			ans=$?
			if [ "$ans" == "1" ]; then
				Moonlight_uninstall
			fi
		elif [[ ! "${arrChosen[*]}" =~ "Parsec" ]]; then
				zenity --info --width=200 --text="Attempting to uninstall Parsec" #dev
			Parsec_IsInstalled
			ans=$?
			if [ "$ans" == "1" ]; then
				Parsec_uninstall
			fi
		else
			zenity --info --width=200 --text="checking" #dev
		fi
	) 	|	(zenity --progress \
            --title="Cloud Services Manager" \
            --text="Processing..." \
            --percentage=0 \
            --no-cancel \
            --pulsate \
            --auto-close \
            --width=300 && progressStarted="true")
			
	zenity --info --width=200 --text="$progressStarted"
	
	if [[ $progressStarted == 'true' ]]; then
		# Return to Manager RP Services selection
		manageRPS
	else
		# Return to menu
		mainMenu
	fi
}

showCurrentBrowser() {
	zenity --info --width=200 --text="Currently Set Browser: $FILEFORWARDING"
}

changeSettings() {
	local BROWSER=$(zenity --list \
	--title="Cloud Services Manager" \
    --width=300 --height=300 --text="Set default web browser:" \
	--column="" --column="Description" --radiolist \
		"" "Google Chrome" \
		"" "Microsoft Edge" \
		"" "Mozilla Firefox")
	
	if [[ $BROWSER == 'Google Chrome' ]]; then
		setCloudSetting COMMAND "/app/bin/chrome"
		setCloudSetting FILEFORWARDING "com.google.Chrome"
	elif [[ $BROWSER == 'Microsoft Edge' ]]; then
		setCloudSetting COMMAND "/app/bin/edge"
		setCloudSetting FILEFORWARDING "com.microsoft.Edge"
	elif [[ $BROWSER == 'Mozilla Firefox' ]]; then
		setCloudSetting COMMAND "firefox"
		setCloudSetting FILEFORWARDING "org.mozilla.firefox"
	fi
    
	showCurrentBrowser

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

# Create a temp folder in the Downloads folder and only pull "tools/cloud" directory.
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

cleanUp() {
	rm -fdr ~/Downloads/EmuDeck_temp
    exit
}

mainMenu() {
	# Ask to install new services or change settings
	CHOICE=$(zenity --list \
		--title="Cloud Services Manager" --text="Main Menu" \
        --width=300  --height=300 \
		--column="" --column="Select an option:" --radiolist \
			"" "Manage Cloud Services" \
			"" "Manage Remote Play Clients" \
			"" "Change Settings" \
			"" "Quit")
    if [ $? != 0 ]; then
        cleanUp
    fi

	if [[ $CHOICE == 'Manage Cloud Services' ]]; then
		manageServices
	elif [[ $CHOICE == 'Manage Remote Play Clients' ]]; then
		manageRPS
	elif [[ $CHOICE == 'Change Settings' ]]; then
		changeSettings
	elif [[ $CHOICE == 'Quit' ]]; then
		cleanUp
	fi
	exit
}

##################
# Initialization #
##################

# Check for exsisting cloud.conf or download fresh
mkdir -p "$romsPath/cloud"
if [ ! -f "$romsPath/cloud/cloud.conf" ]; then
	sparseCheckoutLocal
	cp ~/Downloads/EmuDeck_temp/tools/cloud/cloud.conf "$romsPath/cloud"
fi
CLOUDSETTINGSFILE="$romsPath/cloud/cloud.conf"
source "$CLOUDSETTINGSFILE"

# Show current browser
showCurrentBrowser

# Load Menu
mainMenu
