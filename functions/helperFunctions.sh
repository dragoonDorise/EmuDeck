#!/bin/bash

#Global variables
emuDecksettingsFile="$HOME/emudeck/settings.sh"

function getScreenAR(){
	local productName
	productName=$(getProductName)
	case $productName in
		Win600)			return=169		;;
		Jupiter)		return=1610 	;;
		*)				resolution=$(xrandr --current | grep 'primary' | uniq | awk '{print $4}'| cut -d '+' -f1)
						Xaxis=$(echo "$resolution" | awk '{print $1}' | cut -d 'x' -f2)
						Yaxis=$(echo "$resolution" | awk '{print $1}' | cut -d 'x' -f1)		

						screenWidth=$Xaxis
						screenHeight=$Yaxis


						##Is rotated?
						if [[ $Yaxis > $Xaxis ]]; then
							screenWidth=$Yaxis
							screenHeight=$Xaxis		
						fi

						aspectRatio=$(awk -v screenWidth="$screenWidth" -v screenHeight="$screenHeight" 'BEGIN{printf "%.2f\n", (screenWidth/screenHeight)}')
						if [ "$aspectRatio" == 1.60 ]; then
							ar=1610
						elif [ "$aspectRatio" == 1.78 ]; then
							ar=169
						else
							ar=0	
						fi
						return=$ar 		;;
	esac

	echo $return
}

function pause(){
   read -rp "$*"
}

# keyword replacement file. Only matches start of word
function changeLine() {
    local KEYWORD=$1; shift
    local REPLACE=$1; shift
    local FILE=$1

    local OLD=$(escapeSedKeyword "$KEYWORD")
    local NEW=$(escapeSedValue "$REPLACE")

	echo "Updating: $FILE"
	echo "Old: "$(cat "$FILE" | grep "^$OLD")
    sed -i "/^${OLD}/c\\${NEW}" "$FILE"
	echo "New: "$(cat "$FILE" | grep "^$OLD")

}
function escapeSedKeyword(){
    local INPUT=$1;
	printf '%s\n' "$INPUT" | sed -e 's/[]\/$*.^[]/\\&/g'
}

function escapeSedValue(){
    local INPUT=$1
    printf '%s\n' "$INPUT" | sed -e 's/[\/&]/\\&/g'
}

function getSDPath(){
    if [ -b "/dev/mmcblk0p1" ]; then	    
		findmnt -n --raw --evaluate --output=target -S /dev/mmcblk0p1
	fi
}

function getProductName(){
	cat /sys/devices/virtual/dmi/id/product_name
}

function testRealDeck(){
    case $(getProductName) in
	  'Win600'|'Jupiter') 	isRealDeck=true
	;;
	  *)
		isRealDeck=false
	;;
	esac
}

function testLocationValid(){
    local locationName=$1
	local testLocation=$2
	local return=""

    touch "$testLocation/testwrite"
    
	if [ ! -f  "$testLocation/testwrite" ]; then
		return="Invalid: $locationName not Writable"
	else
		ln -s "$testLocation/testwrite" "$testLocation/testwrite.link"
		if [ ! -f  "$testLocation/testwrite.link" ]; then
			return="Invalid: $locationName not Linkable"
		else
			return="Valid"
		fi
	fi
	rm -f "$testLocation/testwrite" "$testLocation/testwrite.link"
	echo $return
}

function makeFunction(){

	find "$HOME/emudeck/backend/configs/org.libretro.RetroArch/config/retroarch/config" -type f -iname "*.cfg" | while read file
		do
			
			folderOverride="$(basename "${file}")"
			foldername="$(dirname "${file}")"
			coreName="$(basename "${foldername}")"
			echo "RetroArch_${folderOverride%.*}_bezelOn(){"
			IFS=$'\n'
			for line in $(cat "$file")
			do
				local option=$(echo "$line" | awk '{print $1}')
				local value=$(echo "$line" | awk '{print $3}')
				echo "RetroArch_setOverride '$folderOverride' '$coreName'  '$option' '$value'"
			done
			echo '}'
		done
}

function deleteConfigs(){

	find "$HOME/emudeck/backend/configs/org.libretro.RetroArch/config/retroarch/config" -type f -iname "*.opt" -o -type f -iname "*.cfg"| while read file
		do
			rm "$file"
		done
}


function customLocation(){
    zenity --file-selection --directory --title="Select a destination for the Emulation directory." 2>/dev/null
}

function refreshSource(){
	source "$EMUDECKGIT/functions/all.sh"
}

function setAllEmuPaths(){
	for func in $(compgen -A 'function' | grep '_setEmulationFolder')
		 do  $func
	done
}

function setSetting () {
	local var=$1
	local new_val=$2

	settingExists=$(grep -rw "$emuDecksettingsFile" -e "$var")
	if [[ $settingExists == '' ]]; then
		#insert setting to end
		echo "variable not found in settings. Adding $var=$new_val to $emuDecksettingsFile"
		sed -i -e '$a\'"$var=$new_val" "$emuDecksettingsFile"
	elif [[ ! $settingExists == '' ]]; then
		echo "Old value $settingExists"
			if [[ $settingExists == "$var=$new_val" ]]; then
				echo "Setting unchanged, skipping"
			else
				changeLine "$var=" "$var=$new_val" "$emuDecksettingsFile"
			fi
	fi
	#Update values
	# shellcheck source=settings.sh
	source "$emuDecksettingsFile"
}

function installAll(){
	for func in $(compgen -A 'function' | grep '\_install$')
		 do  $func
	done
}


function initAll(){
	for func in $(compgen -A 'function' | grep '\_init$')
		 do  $func
	done
}

function updateOrAppendConfigLine(){
	local configFile=$1
	local option=$2
	local replacement=$3

	local fullPath=$(dirname "$configFile")
	mkdir -p "$fullPath"
	touch "$configFile"
	
	local optionFound=$(grep -rnw  "$configFile" -e "$option")
	if [[ "$optionFound" == '' ]]; then
		echo "appending: $replacement to $configFile"
		echo "$replacement" >> "$configFile"
	else
		changeLine "$option" "$replacement" "$configFile"
	fi
}

function getEnvironmentDetails(){
	local sdpath=$(getSDPath)
	local sdValid=$(testLocationValid "sd" "$sdpath")
	if [ -f "$HOME/emudeck/.finished" ]; then
		firstRun="false"
	else
		firstRun="true"
	fi
	local uname=$(uname -a)
	local productName=$(getProductName)
	local aspectRatio=$(getScreenAR)
	local json="{ \"Home\": \"$HOME\", \"Hostname\": \"$HOSTNAME\", \"Username\": \"$USER\", \"SDPath\": \"$sdpath\", \"IsSDValid?\": \"$sdValid\", \"FirstRun?\": \"$firstRun\",\"ProductName\": \"$productName\",\"AspectRatio\": \"$aspectRatio\",\"UName\": \"$uname\" }"
	jq -r <<< "$json"
}

function getSetting(){
	local setting=$1
	cut -d "=" -f2 <<< "$(grep -r "^${setting}=" "$emuDecksettingsFile")"
}

function createUpdateSettingsFile(){
	#!/bin/bash

	if [ ! -e "$emuDecksettingsFile" ]; then
		echo "#!/bin/bash"> "$emuDecksettingsFile"
	fi
	local defaultSettingsList=()
	defaultSettingsList+=("expert=false")
	defaultSettingsList+=("doSetupRA=true")
	defaultSettingsList+=("doSetupDolphin=true")
	defaultSettingsList+=("doSetupPCSX2=true")
	defaultSettingsList+=("doSetupRPCS3=true")
	defaultSettingsList+=("doSetupYuzu=true")
	defaultSettingsList+=("doSetupCitra=true")
	defaultSettingsList+=("doSetupDuck=true")
	defaultSettingsList+=("doSetupCemu=true")
	defaultSettingsList+=("doSetupXenia=false")
	defaultSettingsList+=("doSetupRyujinx=true")
	defaultSettingsList+=("doSetupMAME=true")
	defaultSettingsList+=("doSetupPrimeHacks=true")
	defaultSettingsList+=("doSetupPPSSPP=true")
	defaultSettingsList+=("doSetupXemu=true")
	defaultSettingsList+=("doSetupESDE=true")
	defaultSettingsList+=("doSetupSRM=true")
	defaultSettingsList+=("doSetupPCSX2QT=true")
	#defaultSettingsList+=("doSetupMelon=true")
	defaultSettingsList+=("doInstallSRM=true")
	defaultSettingsList+=("doInstallESDE=true")
	defaultSettingsList+=("doInstallRA=true")
	defaultSettingsList+=("doInstallDolphin=true")
	defaultSettingsList+=("doInstallPCSX2=true")
	defaultSettingsList+=("doInstallMAME=true")
	defaultSettingsList+=("doInstallRyujinx=true")
	defaultSettingsList+=("doInstallRPCS3=true")
	defaultSettingsList+=("doInstallYuzu=true")
	defaultSettingsList+=("doInstallCitra=true")
	defaultSettingsList+=("doInstallDuck=true")
	defaultSettingsList+=("doInstallCemu=true")
	defaultSettingsList+=("doInstallXenia=true")
	defaultSettingsList+=("doInstallPrimeHacks=true")
	defaultSettingsList+=("doInstallPPSSPP=true")
	defaultSettingsList+=("doInstallXemu=true")
	defaultSettingsList+=("doInstallPCSX2QT=true")
	#defaultSettingsList+=("doInstallMelon=false")
	defaultSettingsList+=("doInstallCHD=true")
	defaultSettingsList+=("doInstallPowertools=false")
	defaultSettingsList+=("doInstallGyro=false")
	defaultSettingsList+=("installString='Installing'")
	defaultSettingsList+=("RABezels=true")
	defaultSettingsList+=("RAautoSave=false")
	defaultSettingsList+=("SNESAR=43")
	defaultSettingsList+=("duckWide=false")
	defaultSettingsList+=("DolphinWide=false")
	defaultSettingsList+=("DreamcastWide=false")
	defaultSettingsList+=("BeetleWide=false")
	defaultSettingsList+=("pcsx2QTWide=false")
	defaultSettingsList+=("emulationPath=$HOME/Emulation")
	defaultSettingsList+=("romsPath=$HOME/Emulation/roms")
	defaultSettingsList+=("toolsPath=$HOME/Emulation/tools")
	defaultSettingsList+=("biosPath=$HOME/Emulation/bios")
	defaultSettingsList+=("savesPath=$HOME/Emulation/saves")
	defaultSettingsList+=("storagePath=$HOME/Emulation/storage")
	defaultSettingsList+=("ESDEscrapData=$HOME/Emulation/tools/downloaded_media")
	defaultSettingsList+=("esdeTheme=EPICNOIR")
	defaultSettingsList+=("doSelectWideScreen=false")
	defaultSettingsList+=("doRASignIn=false")
	defaultSettingsList+=("doRAEnable=false")
	defaultSettingsList+=("doESDEThemePicker=false")
	defaultSettingsList+=("doSelectEmulators=false")
	defaultSettingsList+=("doResetEmulators=false")
	defaultSettingsList+=("XemuWide=false")
	defaultSettingsList+=("achievementsPass=false")
	defaultSettingsList+=("achievementsUser=false")
	defaultSettingsList+=("arClassic3D=43")
	defaultSettingsList+=("arDolphin=43")
	defaultSettingsList+=("arSega=43")
	defaultSettingsList+=("arSnes=43")
	defaultSettingsList+=("RAHandClassic2D=false")
	defaultSettingsList+=("RAHandHeldShader=false")

	tmp=$(mktemp)
	#sort "$emuDecksettingsFile" | uniq -u > "$tmp" && mv "$tmp" "$emuDecksettingsFile"
	
	cat "$emuDecksettingsFile" | awk '!unique[$0]++' > "$tmp" && mv "$tmp" "$emuDecksettingsFile"
	for setting in "${defaultSettingsList[@]}"
		do
			local settingName=$(cut -d "=" -f1 <<< "$setting")
			local settingVal=$(cut -d "=" -f2 <<< "$setting")
			if grep -r "^${settingName}=" "$emuDecksettingsFile" &>/dev/null; then
				echo "Setting: $settingName found. CurrentValue: $(getSetting "$settingName")"
			else
				echo "Setting: $settingName NOT found. adding to $emuDecksettingsFile with default value: $settingVal"
				setSetting "$settingName" "$settingVal"
			fi
		done


}

function checkForFile(){
	local file=$1
	local delete=$2
	local finished=false	
	while [ $finished == false ]
	do 		 
		test=$(test -f "$file" && echo true)			
	  	if [[ $test == true ]]; then
	  	  	finished=true;
		  	clear			  	
			if [[ $delete == 'delete' ]]; then  
		  		rm "$file"
			fi
			echo 'true';			
			break
	  	fi							  
	done
}


function getLatestReleaseURLGH(){	
    local repository=$1
    local fileType=$2
	local url

    if [ "$url" == "" ]; then
        url="https://api.github.com/repos/${repository}/releases/latest"
    fi

    url="$(curl -sL $url | jq -r ".assets[].browser_download_url" | grep -ve 'i386' | grep .${fileType}\$)"
    echo "$url"
}

function getReleaseURLGH(){	
    local repository=$1
    local fileType=$2
	local url

    if [ "$url" == "" ]; then
        url="https://api.github.com/repos/$repository/releases"
    fi
    curl -fSs "$url" | \
    jq -r '[ .[].assets[] | select(.name | endswith("'"$fileType"'")).browser_download_url ][0]'
    
}


function linkToSaveFolder(){	
    local emu=$1
    local folderName=$2
    local path=$3

	if [ ! -d "$savesPath/$emu/$folderName" ]; then		
		mkdir -p $savesPath/$emu
		setMSG "Linking $emu $folderName to the Emulation/saves folder"			
		mkdir -p $path 
		ln -sn $path $savesPath/$emu/$folderName 
	fi

}

function moveSaveFolder(){	
    local emu=$1
    local folderName=$2
    local path=$3

	local linkedTarget=$(readlink -f "$savesPath/$emu/$folderName")

	unlink "$savesPath/$emu/$folderName"

	if [[ ! -e "$savesPath/$emu/$folderName" ]]; then
		mkdir -p "$savesPath/$emu/$folderName"
		if [[ "$linkedTarget" == "$path" ]]; then		
			setMSG "Moving $emu $folderName to the Emulation/saves/$emu/$folderName folder"	
			rsync -avh "$path/" "$savesPath/$emu/$folderName" && rm -rf "${path:?}"
			ln -sn  "$savesPath/$emu/$folderName" "$path"
		fi
	fi
	
}


#
#	local Shortcutlocation=$1
#	local name=$2
#	local exec=$3
#	local terminal=$4 #Optional
#	
#
function createDesktopShortcut(){

	
	local Shortcutlocation=$1
	local name=$2
	local exec=$3
	local terminal=$4
	local icon
	
	mkdir -p "$HOME/.local/share/icons/emudeck/"
	cp -v "$EMUDECKGIT/icons/$(cut -d " " -f1 <<< "$name")."{svg,jpg,png} "$HOME/.local/share/icons/emudeck/" 2>/dev/null
	icon=$(find "$HOME/.local/share/icons/emudeck/" -type f -iname "$(cut -d " " -f1 <<< "$name").*")

	if [ -z "$icon" ]; then
		icon="steamdeck-gaming-return"
	fi

	if [ -z "$terminal" ]; then
		terminal="False"
	fi

	echo "#!/usr/bin/env xdg-open
	[Desktop Entry]
	Name=$name
	Exec=$exec
	Icon=$icon
	Terminal=$terminal
	Type=Application
	Categories=Game;
	StartupNotify=false" > "$Shortcutlocation"
	chmod +x "$Shortcutlocation"

	echo "$Shortcutlocation created"
}