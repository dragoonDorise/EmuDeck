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
EMUDECKGIT="$HOME/.config/EmuDeck/backend/android"


#
##
## Start of installation
##
#

source "$EMUDECKGIT/functions/all.sh"



#
## Installation
#

if [ $(Android_ADB_isInstalled) == "false" ]; then
	Android_ADB_install
fi

#Pegasus Installation
if [ $android_doInstallPegasus == "true" ]; then
	Android_Pegasus_install
fi
if [ "$android_doInstallAetherSX2" == "true" ]; then
	Android_AetherSX2_install
fi
if [ $android_doInstallCitra == "true" ]; then
	Android_Citra_install
fi
if [ $android_doInstallDolphin == "true" ]; then
	Android_Dolphin_install
fi
if [ $android_doInstallRA == "true" ]; then
	Android_RetroArch_install
fi
if [ $android_doInstallPPSSPP == "true" ]; then
	Android_PPSSPP_install
fi
if [ $android_doInstallYuzu == "true" ]; then
	Android_Yuzu_install
fi
if [ $android_doInstallScummVM == "true" ]; then
	Android_ScummVM_install
fi
if [ $android_doInstallVita3K == "true" ]; then
	Android_Vita3K_install
fi

#
## Configuration
#


if [ "$android_doSetupRA" == "true" ]; then
	Android_RetroArch_init
fi
if [ "$android_doSetupDolphin" == "true" ]; then
	Android_Dolphin_init
fi
if [ "$android_doSetupAetherSX2" == "true" ]; then
	Android_AetherSX2_install
fi
if [ "$android_doSetupCitra" == "true" ]; then
	Android_Citra_init
fi
if [ "$android_doSetupYuzu" == "true" ]; then
	Android_Yuzu_init
fi
if [ "$android_doSetupPPSSPP" == "true" ]; then
	Android_PPSSPP_init
fi
if [ "$android_doSetupScummVM" == "true" ]; then
	Android_ScummVM_init
fi
if [ "$android_doSetupVita3K" == "true" ]; then
	Android_Vita3K_init
fi

#Play Store emulators
adb shell am start -a android.intent.action.VIEW -d "https://android.emudeck.com"

#
# We mark the script as finished
#
echo "100" > "$HOME/emudeck/logs/msg.log"
echo "# Installation Complete" >> "$HOME/emudeck/logs/msg.log"

} | tee "${LOGFILE}" 2>&1

