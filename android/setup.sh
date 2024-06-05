#!/bin/bash
MSG=$HOME/emudeck/logs/msg.log
echo "0" > "$MSG"

#
##
## Pid Lock...
##
#

#mkdir -p "$HOME/.config/EmuDeck"
#mkdir -p "$HOME/emudeck/logs"
PIDFILE="$HOME/.config/EmuDeck/install.pid"


if [ -f "$PIDFILE" ]; then
  PID=$(cat "$PIDFILE")
  ps -p "$PID" > /dev/null 2>&1
  if [ $? -eq 0 ]; then
	echo "Process already running"
	exit 1
  else
	## Process not found assume not running
	echo $$ > "$PIDFILE"
	if [ $? -ne 0 ]; then
	  echo "Could not create PID file"
	  exit 1
	fi
  fi
else
  echo $$ > "$PIDFILE"
  if [ $? -ne 0 ]; then
	echo "Could not create PID file"
	exit 1
  fi
fi

function finish {
  echo "Script terminating. Exit code $?"
  finished=true
  rm "$MSG"

}
trap finish EXIT


#
##
## Init...
##
#

#Creating log file
LOGFILE="$HOME/emudeck/logs/emudeckAndroidSetup.log"

mv "${LOGFILE}" "$HOME/emudeck/logs/emudeckAndroidSetup.last.log" #backup last log

if echo "${@}" > "${LOGFILE}" ; then
	echo "Log created"
else
	exit
fi

{
date "+%Y.%m.%d-%H:%M:%S %Z"

#Lets log github API limits just in case
echo 'Github API limits:'
curl -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28"  "https://api.github.com/rate_limit"

#
##
## set backend location
##
#
if [[ "$EMUDECKGIT" == "" ]]; then
	EMUDECKGIT="$HOME/.config/EmuDeck/backend"
fi
#
##
## Start of installation
##
#
source "$EMUDECKGIT"/functions/helperFunctions.sh
jsonToBashVars "$HOME/.config/EmuDeck/settings.json"
source "$EMUDECKGIT/functions/all.sh"


#Roms folders
if [[ "$androidStoragePath" == *-* ]]; then
	Android_cond_path="$Android_temp_external"
else
	Android_cond_path="$Android_temp_internal"
fi

setMSG "Creating rom folders in $androidStoragePath..."

mkdir -p "$Android_cond_path/Emulation/roms/"
rsync -r --ignore-existing "$EMUDECKGIT/roms/" "$Android_cond_path/Emulation/roms/"

setMSG "Copying BIOS"
rsync -r --ignore-existing "$biosPath" "$Android_cond_path/Emulation/bios"

if [ $copySavedGames == "true" ]; then
	setMSG "Copying Saves & States"
	#RA
	rsync -r --ignore-existing "$savesPath/RetroArch" "$Android_cond_path/Emulation/saves/RetroArch/"
	#PPSSPP
	rsync -r  "$savesPath/ppsspp/saves"  "$Android_temp_internal/Emulation/saves/PSP/SAVEDATA"
	rsync -r  "$savesPath/ppsspp/states" "$Android_temp_internal/Emulation/saves/PSP/PPSSPP_STATE"
fi



#
## Installation
#

if [ $(Android_ADB_isInstalled) == "false" ]; then
	Android_ADB_install
fi

#Pegasus Installation
if [ $androidInstallPegasus == "true" ]; then
	Android_Pegasus_install
fi
if [ "$androidInstallAetherSX2" == "true" ]; then
	Android_AetherSX2_install
	Android_AetherSX2_init
fi
if [ $androidInstallCitra == "true" ]; then
	Android_Citra_install
	Android_Citra_init
fi
if [ $androidInstallDolphin == "true" ]; then
	Android_Dolphin_install
	Android_Dolphin_init
fi
if [ $androidInstallRA == "true" ]; then
	Android_RetroArch_install
	Android_RetroArch_init
fi
if [ $androidInstallPPSSPP == "true" ]; then
	Android_PPSSPP_install
	Android_PPSSPP_init
fi
if [ $androidInstallYuzu == "true" ]; then
	Android_Yuzu_install
	Android_Yuzu_init
fi
if [ $androidInstallScummVM == "true" ]; then
	Android_ScummVM_install
	Android_ScummVM_init
fi
if [ $androidInstallVita3K == "true" ]; then
	Android_Vita3K_install
	Android_Vita3K_init
fi


#MTP
echo "NYI"

#Bring your own APK
downloadPath="$HOME/Downloads"

# Find all .apk files in the download path
apkFiles=$(find "$downloadPath" -type f -name "*.apk")

# Loop through each .apk file
for file in $apkFiles; do
	filePath="$file"
	echo "Installing $filePath..."
	Android_ADB_installAPK "$filePath"
done

# Check the success of the installations
if [ "$success" = "false" ]; then
	echo "500 #ANDROID"
else
	if [ "$androidInstallCitraMMJ" = "true" ]; then
		Android_Citra_setup
	fi
	if [ "$androidInstallPegasus" = "true" ]; then
		Android_Pegasus_setup
	fi
	if [ "$androidInstallDolphin" = "true" ]; then
		Android_Dolphin_setup
	fi
	if [ "$androidInstallScummVM" = "true" ]; then
		Android_ScummVM_setup
	fi
fi


#
# We mark the script as finished
#
echo "100" > "$HOME/emudeck/logs/msg.log"
echo "# Installation Complete" >> "$HOME/emudeck/logs/msg.log"

} | tee "${LOGFILE}" 2>&1

