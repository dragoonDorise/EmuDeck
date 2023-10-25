#!/bin/bash
clear
source "$HOME/.config/EmuDeck/backend/functions/all.sh"

NONE='\033[00m'
RED='\033[01;31m'
GREEN='\033[01;32m'
YELLOW='\033[01;33m'
PURPLE='\033[01;35m'
CYAN='\033[01;36m'
WHITE='\033[01;37m'
BOLD='\033[1m'
UNDERLINE='\033[4m'
BLINK='\x1b[5m'
cloud_sync_upload_test(){
	local emuName=$1

	if [ ! -d $savesPath/$emuName ];then
		return 2
	fi

	echo "test" > "$savesPath/$emuName/.temp"
	filePath="$savesPath/$emuName/.temp"
	"$cloud_sync_bin"  -q  copyto --fast-list --checkers=50 --transfers=50 --low-level-retries 1 --retries 1 "$filePath" "$cloud_sync_provider":Emudeck/saves/$emuName/.temp  && rm -rf "$savesPath/$emuName/.temp" && return 0 || return 1
}

cloud_sync_dowload_test(){
	local emuName=$1

	if [ ! -d $savesPath/$emuName ];then
		return 2
	fi

	echo "test" > "$savesPath/$emuName/.temp"
	filePath="$savesPath/$emuName/.temp"
	"$cloud_sync_bin"  -q  copyto --fast-list --checkers=50 --transfers=50 --low-level-retries 1 --retries 1 "$cloud_sync_provider":Emudeck/saves/$emuName/.temp "$filePath" && rm -rf "$savesPath/$emuName/.temp" && return 0 || return 1

}

echo -e "${CYAN}CloudSync Status Report${NONE}"
echo ""

miArray=("Cemu" "citra" "dolphin" "duckstation" "MAME" "melonds" "mgba" "pcsx2" "ppsspp" "primehack" "retroarch" "rpcs3" "scummvm" "Vita3K" "yuzu" "ryujinx" )

upload="true"
download="true"
launchers="true"
echo -e "${YELLOW}Checking launchers${NONE}"
for entry in "$toolsPath/launchers/"*.sh
do
	if [ -f "$entry" ]; then
		if grep -q "cloud_sync_startService" $entry; then
			echo -e "$entry: ${GREEN}Success${NONE}"
		else
			echo -e "$entry: ${RED}Failure${NONE}"
			launchers="false"
		fi
	fi
done

if grep -q "cloud_sync_startService" "$toolsPath/launchers/esde/emulationstationde.sh"; then
	echo -e "$toolsPath/launchers/esde/emulationstationde.sh: ${GREEN}Success${NONE}"
else
	echo -e "$toolsPath/launchers/esde/emulationstationde.sh: ${RED}Failure${NONE}"
fi

echo -e "${YELLOW}Checking for Windows old .lnk files${NONE}"
find "$savesPath" -type f -name "*.lnk" | while read -r entry
do
	rm -rf $entry
	echo "found and deleted: $entry"
done

found_files="false"

for entry in "$savesPath"/**/*.lnk
do
	if [ -f "$entry" ]; then
		rm -rf $entry
		echo "found and deleted: $entry"
		found_files="true"
	fi
done

if [ "$found_files" = "false" ]; then
	echo "No files with the '.lnk' extension found."
fi

echo -e ""
echo -e "${YELLOW}Testing uploading${NONE}"
# Recorrer el array y ejecutar la función cloud_sync_upload_test para cada elemento
for elemento in "${miArray[@]}"; do
	echo -ne "Testing $elemento upload..."
	if cloud_sync_upload_test $elemento;then
		echo -e "${GREEN}Success${NONE}"
	elif [ $? = 2 ]; then
		echo -e "${YELLOW}Save folder not found${NONE}"
	else
		echo -e "${RED}Failure${NONE}"
		upload="false"
	fi
done
echo ""
echo -e "${YELLOW}Testing downloading${NONE}"
# Recorrer el array y ejecutar la función cloud_sync_upload_test para cada elemento
for elemento in "${miArray[@]}"; do
	echo -ne "Testing $elemento download..."
	if cloud_sync_dowload_test $elemento;then
		echo -e "${GREEN}Success${NONE}"
	elif [ $? = 2 ]; then
		echo -e "${YELLOW}Save folder not found${NONE}"
	else
		echo -e "${RED}Failure${NONE}"
		download="false"
	fi
done
echo -e ""
echo -e "${CYAN}Recommendations${NONE}"



if [ $download = "true" ] && [ $upload = "true" ] && [ $launchers = "true" ]; then
	echo -e "${YELLOW}Everything seems to be in proper order, at least on Linux${NONE}"
else
	echo -e "${YELLOW}Open EmuDeck, go to Manage Emulators and reset SteamRomManager Configuration. Then test some games and if it keeps failing open Steam Rom Manager and parse all your games again to get the proper launchers${NONE}"
fi


sleep 100000