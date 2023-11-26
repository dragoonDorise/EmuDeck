#!/bin/bash

#Global variables
emuDecksettingsFile="$HOME/emudeck/settings.sh"


function startLog() {
	funcName="$1"
	mkdir -p "$HOME/emudeck/logs"
	logFile="$HOME/emudeck/logs/$funcName.log"

	touch "$logFile"

	exec &> >(tee -a "$logFile")

}

function stopLog(){
	echo "NYI"
}

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

	echo "Updating: $FILE - $OLD to $NEW"
	#echo "Old: ""$(cat "$FILE" | grep "^$OLD")"
	sed -i "/^${OLD}/c\\${NEW}" "$FILE"
	#echo "New: ""$(cat "$FILE" | grep "^$OLD")"

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
	local result=""

	if [[ "$testLocation" == *" "* ]]; then
		result="Invalid: $locationName contains spaces"
	else
		touch "$testLocation/testwrite"
		if [ ! -f  "$testLocation/testwrite" ]; then
			result="Invalid: $locationName not Writable"
		else
			ln -s "$testLocation/testwrite" "$testLocation/testwrite.link"
			if [ ! -f  "$testLocation/testwrite.link" ]; then
				result="Invalid: $locationName not Linkable"
			else
				result="Valid"
			fi
			rm -f "$testLocation/testwrite.link"
		fi
		rm -f "$testLocation/testwrite"
	fi
	echo "$result"
}


function testLocationValidRelaxed(){
	local locationName=$1
	local testLocation=$2
	local return=""

	touch "$testLocation/testwrite"

	if [ ! -f  "$testLocation/testwrite" ]; then
		result="Invalid: $locationName not Writable"
	else
		result="Valid"
	fi
	rm -f "$testLocation/testwrite"
	echo $result
}

function makeFunction(){

	find "$1" -type f -iname "$2" | while read -r file
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

	find "$HOME/.config/EmuDeck/backend/configs/org.libretro.RetroArch/config/retroarch/config" -type f -iname "*.opt" -o -type f -iname "*.cfg"| while read file
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
	if [ -f "$HOME/.config/EmuDeck/.finished" ]; then
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
	#defaultSettingsList+=("doSetupPCSX2=true")
	defaultSettingsList+=("doSetupRPCS3=true")
	defaultSettingsList+=("doSetupYuzu=true")
	defaultSettingsList+=("doSetupCitra=true")
	defaultSettingsList+=("doSetupDuck=true")
	defaultSettingsList+=("doSetupCemu=true")
	defaultSettingsList+=("doSetupXenia=false")
	defaultSettingsList+=("doSetupRyujinx=true")
	defaultSettingsList+=("doSetupMAME=true")
	defaultSettingsList+=("doSetupPrimehack=true")
	defaultSettingsList+=("doSetupPPSSPP=true")
	defaultSettingsList+=("doSetupXemu=true")
	defaultSettingsList+=("doSetupESDE=true")
	defaultSettingsList+=("doSetupPegasus=false")
	defaultSettingsList+=("doSetupSRM=true")
	defaultSettingsList+=("doSetupPCSX2QT=true")
	defaultSettingsList+=("doSetupScummVM=true")
	defaultSettingsList+=("doSetupVita3K=true")
	defaultSettingsList+=("doSetupRMG=true")
	#defaultSettingsList+=("doSetupMelon=true")
	defaultSettingsList+=("doSetupMGBA=true")
	defaultSettingsList+=("doSetupFlycast=true")
	defaultSettingsList+=("doInstallSRM=true")
	defaultSettingsList+=("doInstallESDE=true")
	defaultSettingsList+=("doInstallPegasus=false")
	defaultSettingsList+=("doInstallRA=true")
	defaultSettingsList+=("doInstallDolphin=true")
	#defaultSettingsList+=("doInstallPCSX2=true")
	defaultSettingsList+=("doInstallMAME=true")
	defaultSettingsList+=("doInstallRyujinx=true")
	defaultSettingsList+=("doInstallRPCS3=true")
	defaultSettingsList+=("doInstallYuzu=true")
	defaultSettingsList+=("doInstallCitra=true")
	defaultSettingsList+=("doInstallDuck=true")
	defaultSettingsList+=("doInstallCemu=true")
	defaultSettingsList+=("doInstallXenia=true")
	defaultSettingsList+=("doInstallPrimeHack=true")
	defaultSettingsList+=("doInstallPPSSPP=true")
	defaultSettingsList+=("doInstallXemu=true")
	defaultSettingsList+=("doInstallPCSX2QT=true")
	defaultSettingsList+=("doInstallScummVM=true")
	defaultSettingsList+=("doInstallVita3K=true")
	#defaultSettingsList+=("doInstallMelon=false")
	defaultSettingsList+=("doInstallMGBA=false")
	defaultSettingsList+=("doInstallFlycast=true")
	defaultSettingsList+=("doInstallCHD=true")
	defaultSettingsList+=("doInstallPowertools=false")
	defaultSettingsList+=("doInstallGyro=false")
	defaultSettingsList+=("doInstallHomeBrewGames=false")
	defaultSettingsList+=("installString='Installing'")
	defaultSettingsList+=("RABezels=true")
	defaultSettingsList+=("RAautoSave=false")
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
	#defaultSettingsList+=("achievementsPass=false")
	#defaultSettingsList+=("achievementsUser=false")
	defaultSettingsList+=("arClassic3D=43")
	defaultSettingsList+=("arDolphin=43")
	defaultSettingsList+=("arSega=43")
	defaultSettingsList+=("arSnes=43")
	defaultSettingsList+=("RAHandClassic2D=false")
	defaultSettingsList+=("RAHandClassic3D=false")
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
	local fileNameContains=$3
	local url
	#local token=$(tokenGenerator)

	if [ "$url" == "" ]; then
		url="https://api.github.com/repos/${repository}/releases/latest"
	fi

	curl -fSs "$url" | \
		jq -r '[ .assets[] | select(.name | contains("'"$fileNameContains"'") and endswith("'"$fileType"'")).browser_download_url ][0] // empty'
}

function getReleaseURLGH(){
	local repository=$1
	local fileType=$2
	local url
	local fileNameContains=$3
	#local token=$(tokenGenerator)

	if [ $system == "darwin" ]; then
		fileType="dmg"
	fi

	if [ $system == "darwin" ]; then
		fileType="dmg"
	fi

	if [ "$url" == "" ]; then
		url="https://api.github.com/repos/$repository/releases"
	fi

	curl -fSs "$url" | \
		jq -r '[ .[].assets[] | select(.name | contains("'"$fileNameContains"'") and endswith("'"$fileType"'")).browser_download_url ][0] // empty'
}

function linkToSaveFolder(){
	local emu=$1
	local folderName=$2
	local path=$3

	if [ ! -d "$savesPath/$emu/$folderName" ]; then
		if [ ! -L "$savesPath/$emu/$folderName" ]; then
			mkdir -p "$savesPath/$emu"
			setMSG "Linking $emu $folderName to the Emulation/saves folder"
			mkdir -p "$path"
			ln -snv "$path" "$savesPath/$emu/$folderName"
		fi
	else
		if [ ! -L "$savesPath/$emu/$folderName" ]; then
			echo "$savesPath/$emu/$folderName is not a link. Please check it."
		else
			if [ $(readlink $savesPath/$emu/$folderName) == $path ]; then
				echo "$savesPath/$emu/$folderName is already linked."
				echo "     Target: $(readlink $savesPath/$emu/$folderName)"
			else
				echo "$savesPath/$emu/$folderName not linked correctly."
				unlink "$savesPath/$emu/$folderName"
				linkToSaveFolder "$emu" "$folderName" "$path"
			fi
		 fi
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
			rsync -avh "$path/" "$savesPath/$emu/$folderName" && mv "$path" "${path}.bak"
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

	rm -f "$Shortcutlocation"

	balooctl check

	mkdir -p "$HOME/.local/share/applications/"

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

	balooctl check

	echo "$Shortcutlocation created"
}

#desktopShortcutFieldUpdate "$shortcutFile" "Field" "NewValue"
function desktopShortcutFieldUpdate(){
	local shortcutFile=$1
	local shortcutKey=$2
	local shortcutValue=$3
	local name
	local icon

	if [ -f "$shortcutFile" ]; then
		# update icon if name is updated
		if [ "$shortcutKey" == "Name" ]; then
			name=$shortcutValue
			cp -v "$EMUDECKGIT/icons/$(cut -d " " -f1 <<< "$name").{svg,jpg,png}" "$HOME/.local/share/icons/emudeck/" 2>/dev/null
			icon=$(find "$HOME/.local/share/icons/emudeck/" -type f \( -iname "$(cut -d " " -f1 <<< "$name").svg" -o -iname "$(cut -d " " -f1 <<< "$name").jpg" -o -iname "$(cut -d " " -f1 <<< "$name").png" \) -print -quit)
			echo "Icon Found: $icon"
			if [ -n "$icon" ]; then
				#desktopShortcutFieldUpdate "$shortcutFile" "Icon" "$icon"
				sed -i "s#Icon\\s*=\\s*.*#Icon=$icon#g" "$shortcutFile"
				sed -E -i "s|Icon\\s*=\\s*.*|Icon=$icon|g" "$shortcutFile"
			fi
		fi
		sed -E -i "s|$shortcutKey\\s*=\\s*.*|$shortcutKey=$shortcutValue|g" "$shortcutFile"
		balooctl check
	fi
}


#iniFieldUpdate "$iniFilePath" "General" "LoadPath" "$storagePath/$emuName/Load" "separator!"
function iniFieldUpdate() {
	local iniFile="$1"
	local iniSection="${2:-}"
	local iniKey="$3"
	local iniValue="$4"
	local separator="${5:- = }"

	if [ -f "$iniFile" ]; then
		# Create the section if it doesn't exist.
		if [ -n "$iniSection" ] && ! grep -q "\[$iniSection\]" "$iniFile"; then
			echo "Creating Header [$iniSection]"
			if [ "$(wc -l < "$iniFile")" -gt 0 ]; then
				# Append a newline before adding the new section
				echo >> "$iniFile"
			fi
			# Escape special characters in the section header
			escapedSection=$(echo "$iniSection" | sed 's/[&/\]/\\&/g')
			echo "[$escapedSection]" >> "$iniFile"
			echo "Creating [$iniSection] key $iniKey$separator$iniValue"
			echo "$iniKey$separator$iniValue" >> "$iniFile"
		else
			# If the key doesn't exist in the section, create it one line below the section.
			# Otherwise, update the value.
			local startLineNumber=''
			local endLineNumber=''
			if [ -n "$iniSection" ]; then
				# Escape special characters in the section header
				escapedSection=$(echo "$iniSection" | sed 's/[&/\]/\\&/g')
				startLineNumber=$(awk -v section="$escapedSection" 'BEGIN{FS=OFS="|"} $0=="["section"]"{print NR; exit}' "$iniFile")
				if [ -n "$startLineNumber" ]; then
					endLineNumber=$(awk -v start="$startLineNumber" -F ']' 'NR > start && /^\[/ {print NR-1; exit}' "$iniFile")
				fi
			fi

			if [ -n "$startLineNumber" ] && [ -n "$endLineNumber" ]; then
				if ! grep -q "^$iniKey$separator" <(sed -n "${startLineNumber},${endLineNumber}p" "$iniFile"); then
					echo "Creating [$iniSection] key $iniKey$separator$iniValue"
					sed -i "${startLineNumber}a$iniKey$separator$iniValue" "$iniFile"
				else
					echo "Updating [$iniSection] key $iniKey$separator$iniValue"
					sed -i "/^\[$escapedSection\]/,/^\[/ s|^$iniKey$separator.*|$iniKey$separator$iniValue|" "$iniFile"
				fi
			elif ! grep -q "^$iniKey$separator" "$iniFile"; then
				echo "Creating key $iniKey$separator$iniValue"
				echo "$iniKey$separator$iniValue" >> "$iniFile"
			else
				echo "Updating key $iniKey$separator$iniValue"
				sed -i "s|^$iniKey$separator.*|$iniKey$separator$iniValue|" "$iniFile"
			fi
		fi
	else
		echo "Can't update missing INI file: $iniFile"
	fi
}


function iniSectionUpdate() {
	local file="$1"
	local section_name="$2"
	local new_content="$3"
	local tmp_file=$(mktemp)

	local inside_section=0

	while IFS= read -r line; do

		if [[ "$line" =~ ^\[$section_name\] ]]; then
			inside_section=1
			echo "$line"
			echo "$new_content"
			continue
		fi

		if [[ "$line" =~ ^\[ ]] && [[ ! "$line" =~ ^\[$section_name\] ]] && [[ $inside_section -eq 1 ]]; then
			echo "$old_content"
			inside_section=0
		fi

		if [[ $inside_section -eq 1 ]]; then
			continue
		fi

		echo "$line"

	local old_content="$line"

	done < "$file" > "$tmp_file"

	if [[ $inside_section -eq 1 ]]; then
		echo "$old_content"
	fi

	mv "$tmp_file" "$file"
}


safeDownload() {
	local name="$1"
	local url="$2"
	local outFile="$3"
	local showProgress="$4"
	local headers="$5"

	echo "safeDownload()"
	echo "- $name"
	echo "- $url"
	echo "- $outFile"
	echo "- $showProgress"
	echo "- $headers"


	if [ "$showProgress" == "true" ] || [[ $showProgress -eq 1 ]]; then
		request=$(curl -w $'\1'"%{response_code}" --fail -L "$url" -H "$headers" -o "$outFile.temp" 2>&1 | tee >(stdbuf -oL tr '\r' '\n' | sed -u 's/^ *\([0-9][0-9]*\).*\( [0-9].*$\)/\1\n#Download Speed\:\2/' | zenity --progress --title "Downloading $name" --width 600 --auto-close --no-cancel 2>/dev/null) && echo $'\2'${PIPESTATUS[0]})
	else
		request=$(curl -w $'\1'"%{response_code}" --fail -L "$url" -H "$headers" -o "$outFile.temp" 2>&1 && echo $'\2'0 || echo $'\2'$?)
	fi
	requestInfo=$(sed -z s/.$// <<< "${request%$'\1'*}")
	returnCodes="${request#*$'\1'}"
	httpCode="${returnCodes%$'\2'*}"
	exitCode="${returnCodes#*$'\2'}"
	echo "$requestInfo"
	echo "HTTP response code: $httpCode"
	echo "CURL exit code: $exitCode"
	if [ "$httpCode" = "200" ] && [ "$exitCode" == "0" ]; then
		echo "$name downloaded successfully";
		mv -v "$outFile.temp" "$outFile"
		return 0
	else
		echo "$name download failed"
		rm -f "$outFile.temp"
		return 1
	fi
}

addSteamInputCustomIcons() {
	rsync -av "$EMUDECKGIT/configs/steam-input/Icons/" "$HOME/.steam/steam/tenfoot/resource/images/library/controller/binding_icons"
}

getEmuInstallStatus() {
	emuArray=(	"$@")
	installStatus=()
	for emu in "${emuArray[@]}"; do
		installStatus+=($("${emu}_IsInstalled"))
	done

	paste <(printf "%s\n" "${emuArray[@]}") <(printf "%s\n" "${installStatus[@]}") |
	jq -nR '{ Emulators: [inputs] | map(split("\t") | { Name: .[0], Installed: .[1] }) }'
}

isFpInstalled(){
	flatPakID=$1
	if (flatpak --columns=app list --user | grep -q "^$flatPakID$") || (flatpak --columns=app list --system | grep -q "^$flatPakID$"); then
		echo "true"
	else
		echo "false"
	fi
}

check_internet_connection(){
  ping -q -c 1 -W 1 8.8.8.8 > /dev/null 2>&1 && echo true || echo false
}

zipLogs() {
	logsFolder="$HOME/emudeck/logs"
	settingsFile="$HOME/emudeck/settings.sh"
	zipOutput="$HOME/Desktop/emudeck_logs.zip"

	# Comprime los archivos en un archivo zip
	zip -rj "$zipOutput" "$logsFolder" "$settingsFile"

	if [ $? -eq 0 ]; then
		echo "true"
	else
		echo "false"
	fi
}

setResolutions(){
	Cemu_setResolution
	Citra_setResolution
	Dolphin_setResolution
	DuckStation_setResolution
	Flycast_setResolution
	MAME_setResolution
	melonDS_setResolution
	mGBA_setResolution
	PCSX2QT_setResolution
	PPSSPP_setResolution
	Primehack_setResolution
	RPCS3_setResolution
	Ryujinx_setResolution
	ScummVM_setResolution
	Vita3K_setResolution
	Xemu_setResolution
	Xenia_setResolution
	Yuzu_setResolution
}

# get variable value from kvp-style config file
# VAR1=VALUE1
# VAR2="VALUE 2"
# ...
scriptConfigFileGetVar() {
    local configFile=$1
    local configVar=$2
    local configVarDefaultValue=$3

    local configVarValue="$( (grep -E "^${configVar}=" -m 1 "${configFile}" 2>/dev/null || echo "_=__UNDEFINED__") | head -n 1 | cut -d '=' -f 2- | xargs )"
    if [ "${configVarValue}" = "__UNDEFINED__" ]; then
        configVarValue="${configVarDefaultValue}"
    fi

    printf -- "%s" "${configVarValue}"
}
