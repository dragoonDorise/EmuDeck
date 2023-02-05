#!/bin/bash

# GIT URL for downloads
EMUDECKGIT=https://github.com/dragoonDorise/EmuDeck.git
EMUDECKGITBRANCH=main #Add-cloud-gaming
LOCALCLOUDFILES="$HOME/.config/EmuDeck/backend/tools/cloud"

manageServices() {
	# Download all cloud service scripts
	#sparseCheckoutLocal
	
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
        git remote add -f origin $EMUDECKGIT
        git config core.sparseCheckout true
        echo "tools/cloud" >> .git/info/sparse-checkout
        git pull origin $EMUDECKGITBRANCH
    ) 	|	zenity --progress \
            --title="Cloud Services" \
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
	menuText=$(printf "<b>Main Menu</b>\n Currently Set Browser: $FILEFORWARDING\n")
	CHOICE=$(zenity --list \
		--title="Cloud Services Manager" --text="$menuText" \
        --width=300  --height=300 \
		--column="" --column="Select an option:" --radiolist \
			"" "Manage Cloud Services" \
			"" "Change Settings" \
			"" "Quit")
    if [ $? != 0 ]; then
        cleanUp
    fi

	if [[ $CHOICE == 'Manage Cloud Services' ]]; then
		manageServices
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
source $HOME/emudeck/settings.sh

# Check for exsisting cloud.conf or download fresh
mkdir -p "$romsPath/cloud"
if [ ! -f "$romsPath/cloud/cloud.conf" ]; then
	#sparseCheckoutLocal
	cp "$HOME/.config/EmuDeck/backend/tools/cloud/cloud.conf" "$romsPath/cloud"
fi
CLOUDSETTINGSFILE="$romsPath/cloud/cloud.conf"

# Show current browser
source "$romsPath/cloud/cloud.conf"
#showCurrentBrowser

# Load Menu
mainMenu
