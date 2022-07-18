#!/bin/bash

getScreenAR(){
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

function changeLine() {

    local KEYWORD=$1; shift
    local REPLACE=$1; shift
    local FILE=$1

    local OLD=$(escapeSedKeyword "$KEYWORD")
    local NEW=$(escapeSedValue "$REPLACE")

    sed -i "/${OLD}/c\\${NEW}" "$FILE"

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
    case getProductName in
	  Win600|Jupiter)
		isRealDeck=true
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

	find "$HOME/emudeck/backend/configs/org.libretro.RetroArch/config/retroarch/" -maxdepth 1 -type f -iname "*.cfg" | while read file
		do
			
			folderOverride="$(basename "${file}")"
			foldername="$(dirname "${file}")"
			coreName="$(basename "${foldername}")"
			echo "RetroArch_mainConfig(){"
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

updateOrAppendConfigLine(){
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
		echo "updating $option in $configFile to $replacement"
		changeLine "$option" "$replacement" "$configFile"
	fi
}

getEnvironmentDetails(){
	local sdpath=$(getSDPath)
	local sdValid=$(testLocationValid "sd" $sdpath)
	if [ -f "$HOME/emudeck/.finished" ]; then
		firstRun="false"
	else
		firstRun="true"
	fi
	local uname=$(uname -a)
	local productName=$(getProductName)
	local aspectRatio=$(getScreenAR)
	local json="{ \"Home\": \"$HOME\", \"Hostname\": \"$HOSTNAME\", \"Username\": \"$USER\", \"SDPath\": \"$sdpath\", \"IsSDValid?\": \"$sdValid\", \"FirstRun?\": \"$firstRun\",\"ProductName\": \"$productName\",\"AspectRatio\": \"$aspectRatio\",\"UName\": \"$uname\" }"
	jq <<< "$json"
}