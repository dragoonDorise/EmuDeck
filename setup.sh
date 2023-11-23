#!/bin/bash
MSG=$HOME/.config/EmuDeck/msg.log
echo "0" > "$MSG"

#
##
## Pid Lock...
##
#

mkdir -p "$HOME/.config/EmuDeck"
mkdir -p "$HOME/emudeck/logs"
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


#Clean up previous installations
rm ~/emudek.log 2>/dev/null # This is emudeck's old log file, it's not a typo!
rm -rf ~/dragoonDoriseTools
rm -rf ~/emudeck/backend

#Creating log file
LOGFILE="$HOME/emudeck/logs/emudeckSetup.log"

mkdir -p "$HOME/emudeck"

#Custom Scripts
mkdir -p "$HOME/emudeck/custom_scripts"
echo $'#!/bin/bash\nEMUDECKGIT="$HOME/.config/EmuDeck/backend"\nsource "$EMUDECKGIT/functions/all.sh"' > "$HOME/emudeck/custom_scripts/example.sh"

echo "Press the button to start..." > "$LOGFILE"

mv "${LOGFILE}" "$HOME/emudeck/logs/emudeckSetup.last.log" #backup last log

if echo "${@}" > "${LOGFILE}" ; then
	echo "Log created"
else
	exit
fi

#exec > >(tee "${LOGFILE}") 2>&1
#Installation log
{
date "+%Y.%m.%d-%H:%M:%S %Z"
#Mark if this not a fresh install
FOLDER="$HOME/.config/EmuDeck/"
if [ -d "$FOLDER" ]; then
	echo "" > "$HOME/.config/EmuDeck/.finished"
fi
sleep 1
SECONDTIME="$HOME/.config/EmuDeck/.finished"

#Lets log github API limits just in case
echo 'Github API limits:'
curl -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28"  "https://api.github.com/rate_limit"

#
##
## set backend location
##
# I think this should just be in the source, so there's one spot for initialization. hrm, no i'm wrong. Here is best.
EMUDECKGIT="$HOME/.config/EmuDeck/backend"


#
##
## Start of installation
##
#




source "$EMUDECKGIT/functions/all.sh"


#after sourcing functins, check if path is empty.
# [[ -z "$emulationPath" ]] && { echo "emulationPath is Empty!"; setMSG "There's been an issue, please restart the app"; exit 1; }



echo "Current Settings: "
grep -vi pass "$emuDecksettingsFile"


#
#Environment Check
#
echo ""
echo "Env Details: "
getEnvironmentDetails
testRealDeck

#this sets up the settings file with defaults, in case they don't have a new setting we've added.
#also echos them all out so they are in the log.
echo "Setup Settings File: "
createUpdateSettingsFile

#create folders after tests!
createFolders

#setup Proton-Launch.sh
#because this path gets updated by sed, we really should be installing it every time and allowing it to be updated every time. In case the user changes their path.
cp "$EMUDECKGIT/tools/proton-launch.sh" "${toolsPath}/proton-launch.sh"
chmod +x "${toolsPath}/proton-launch.sh"
cp "$EMUDECKGIT/tools/appID.py" "${toolsPath}/appID.py"

# Setup emu-launch.sh
cp "${EMUDECKGIT}/tools/emu-launch.sh" "${toolsPath}/emu-launch.sh"
chmod +x "${toolsPath}/emu-launch.sh"

#ESDE Installation
if [ $doInstallESDE == "true" ]; then
	echo "install esde"
	ESDE_install
fi
#Pegasus Installation
if [ $doInstallPegasus == "true" ]; then
	echo "install Pegasus"
	Pegasus_install
fi
#SRM Installation
if [ $doInstallSRM == "true" ]; then
	echo "install srm"
	SRM_install
fi
if [ "$doInstallPCSX2QT" == "true" ]; then
	echo "install pcsx2Qt"
	PCSX2QT_install
fi
if [ $doInstallPrimeHack == "true" ]; then
	echo "install primehack"
	Primehack_install
fi
if [ $doInstallRPCS3 == "true" ]; then
	echo "install rpcs3"
	RPCS3_install
fi
if [ $doInstallCitra == "true" ]; then
	echo "install Citra"
	Citra_install
fi
if [ $doInstallDolphin == "true" ]; then
	echo "install Dolphin"
	Dolphin_install
fi
if [ $doInstallDuck == "true" ]; then
	echo "DuckStation_install"
	DuckStation_install
fi
if [ $doInstallRA == "true" ]; then
	echo "RetroArch_install"
	RetroArch_install
fi
if [ $doInstallRMG == "true" ]; then
	echo "RMG_install"
	RMG_install
fi
if [ $doInstallares == "true" ]; then
	echo "ares_install"
	ares_install
fi
if [ $doInstallPPSSPP == "true" ]; then
	echo "PPSSPP_install"
	PPSSPP_install
fi
if [ $doInstallYuzu == "true" ]; then
	echo "Yuzu_install"
	Yuzu_install
fi
if [ $doInstallRyujinx == "true" ]; then
	echo "Ryujinx_install"
	Ryujinx_install
fi
if [ $doInstallMAME == "true" ]; then
	echo "MAME_install"
	MAME_install
fi
if [ $doInstallXemu == "true" ]; then
	echo "Xemu_install"
	Xemu_install
fi
if [ $doInstallCemu == "true" ]; then
	echo "Cemu_install"
	Cemu_install
fi
if [ "${doInstallCemuNative}" == "true" ]; then
	echo "CemuNative_install"
	CemuNative_install
fi
if [ $doInstallScummVM == "true" ]; then
	echo "ScummVM_install"
	ScummVM_install
fi
if [ $doInstallVita3K == "true" ]; then
	echo "Vita3K_install"
	Vita3K_install
fi
if [ $doInstallMGBA == "true" ]; then
	echo "mGBA_install"
	mGBA_install
fi
if [ $doInstallFlycast == "true" ]; then
	echo "Flycast_install"
	Flycast_install
fi
if [ $doInstallRMG == "true" ]; then
	echo "RMG_install"
	RMG_install
fi
if [ $doInstallares == "true" ]; then
	echo "ares_install"
	ares_install
fi
if [ $doInstallmelonDS == "true" ]; then
	echo "melonDS_install"
	melonDS_install
fi
#Xenia - We need to install Xenia after creating the Roms folders!
if [ "$doInstallXenia" == "true" ]; then
	echo "Xenia_install"
	Xenia_install
fi

#Steam RomManager Config

if [ "$doSetupSRM" == "true" ]; then
	echo "SRM_init"
	SRM_init
fi

#ESDE Config
if [ "$doSetupESDE" == "true" ]; then
	echo "ESDE_init"
	ESDE_update
fi

#Pegasus Config
#if [ $doSetupPegasus == "true" ]; then
#	echo "Pegasus_init"
#	Pegasus_init
#fi

#Emus config
#setMSG "Configuring Steam Input for emulators.." moved to emu install


setMSG "Configuring emulators.."

if [ "$doSetupRA" == "true" ]; then
	echo "RetroArch_init"
	RetroArch_init
fi
if [ "$doSetupPrimehack" == "true" ]; then
	echo "Primehack_init"
	Primehack_init
fi
if [ "$doSetupDolphin" == "true" ]; then
	echo "Dolphin_init"
	Dolphin_init
fi
if [ "$doSetupPCSX2QT" == "true" ]; then
	echo "PCSX2QT_init"
	PCSX2QT_init
fi
if [ "$doSetupRPCS3" == "true" ]; then
	echo "RPCS3_init"
	RPCS3_init
fi
if [ "$doSetupCitra" == "true" ]; then
	echo "Citra_init"
	Citra_init
fi
if [ "$doSetupDuck" == "true" ]; then
	echo "DuckStation_init"
	DuckStation_init
fi
if [ "$doSetupYuzu" == "true" ]; then
	echo "Yuzu_init"
	Yuzu_init
fi
if [ "$doSetupRyujinx" == "true" ]; then
	echo "Ryujinx_init"
	Ryujinx_init
fi
if [ "$doSetupPPSSPP" == "true" ]; then
	echo "PPSSPP_init"
	PPSSPP_init
fi
if [ "$doSetupXemu" == "true" ]; then
	echo "Xemu_init"
	Xemu_init
fi
if [ "$doSetupMAME" == "true" ]; then
	echo "MAME_init"
	MAME_init
fi
if [ "$doSetupScummVM" == "true" ]; then
	echo "ScummVM_init"
	ScummVM_init
fi
if [ "$doSetupVita3K" == "true" ]; then
	echo "Vita3K_init"
	Vita3K_init
fi
if [ "$doSetupRMG" == "true" ]; then
	echo "RMG_init"
	RMG_init
fi
if [ "$doSetupares" == "true" ]; then
	echo "ares_init"
	ares_init
fi
if [ "$doSetupmelonDS" == "true" ]; then
	echo "melonDS_init"
	melonDS_init
fi
if [ "$doSetupMGBA" == "true" ]; then
	echo "mGBA_init"
	mGBA_init
fi
if [ "${doSetupCemuNative}" == "true" ]; then
	echo "CemuNative_init"
	CemuNative_init
fi
if [ "$doSetupFlycast" == "true" ]; then
	echo "Flycast_init"
	Flycast_init
fi
#Proton Emus
if [ "$doSetupCemu" == "true" ]; then
	echo "Cemu_init"
	Cemu_init
fi
if [ "$doSetupXenia" == "true" ]; then
	echo "Xenia_init"
	Xenia_init
fi



#Fixes repeated Symlink for older installations
# Yuzu_finalize move into update / init to clean up install script



#
##
##End of installation
##
#



#Sudo Required!
# if [ -n "$PASSWD" ]; then
# 	pwstatus=0
# 	echo "$PASSWD" | sudo -v -S &>/dev/null && pwstatus=1 || echo "sudo password was incorrect" #refresh sudo cache
# 	if [ $pwstatus == 1 ]; then
# 		if [ "$doInstallGyro" == "true" ]; then
# 			Plugins_installSteamDeckGyroDSU
# 		fi
#
# 		if [ "$doInstallPowertools" == "true" ]; then
# 			Plugins_installPluginLoader
# 			Plugins_installPowerTools
# 		fi
# 	fi
# else
# 	echo "no password supplied. Skipping gyro / powertools."
# fi

#Always install
Plugins_install
BINUP_install
CHD_install

#
##
## Overrides for non Steam hardware...
##
#


#
#Fixes for 16:9 Screens
#
if [ "$doSetupRA" == "true" ]; then
	if [ "$(getScreenAR)" == 169 ];then
		nonDeck_169Screen
	fi

	#Anbernic Win600 Special configuration
	if [ "$(getProductName)" == "Win600" ];then
		nonDeck_win600
	fi
fi

if [ "$system" == "chimeraos" ]; then
	mkdir -p $HOME/Applications

	downloads_dir="$HOME/Downloads"
	destination_dir="$HOME/Applications"
	file_name="EmuDeck"

	find "$downloads_dir" -type f -name "*$file_name*.AppImage" -exec mv {} "$destination_dir/$file_name.AppImage" \;

fi

createDesktopIcons



if [ "$doInstallHomeBrewGames" == "true" ]; then
	emuDeckInstallHomebrewGames
fi

#
##
##Validations
##
#
if [ "system" != "darwin" ]; then
	#Decky Plugins
	if [ "$system" == "chimeraos" ]; then
		defaultPass="gamer"
	else
		defaultPass="Decky!"
	fi

 	if ( echo "$defaultPass" | sudo -S -k true ); then
		echo "true"
  	else
	  	PASS=$(zenity --title="Decky Installer" --width=300 --height=100 --entry --hide-text --text="Enter your sudo/admin password so we can install Decky with the best plugins for emulation")
	  	if [[ $? -eq 1 ]] || [[ $? -eq 5 ]]; then
		  	exit 1
	  	fi
	  	if ( echo "$PASS" | sudo -S -k true ); then
		  	defaultPass=$PASS
	  	else
		  	zenity --title="Decky Installer" --width=150 --height=40 --info --text "Incorrect Password"
	  	fi
		fi

	echo $defaultPass | sudo -v -S && {
		Plugins_installEmuDecky $defaultPass
		if [ "$system" == "chimeraos" ]; then
			Plugins_installPowerControl $defaultPass
		else
			Plugins_installPowerTools $defaultPass
		fi
		Plugins_installSteamDeckGyroDSU $defaultPass
		Plugins_installPluginLoader $defaultPass
	}

fi

#EmuDeck updater on gaming Mode
mkdir -p "${toolsPath}/updater"
cp -v "$EMUDECKGIT/tools/updater/emudeck-updater.sh" "${toolsPath}/updater/"
chmod +x "${toolsPath}/updater/emudeck-updater.sh"

#RemotePlayWhatever
# if [[ ! $branch == "main" ]]; then
# 	RemotePlayWhatever_install
# fi

#
# We mark the script as finished
#
echo "" > "$HOME/.config/EmuDeck/.finished"
echo "" > "$HOME/.config/EmuDeck/.ui-finished"
echo "100" > "$HOME/.config/EmuDeck/msg.log"
echo "# Installation Complete" >> "$HOME/.config/EmuDeck/msg.log"
finished=true
rm "$PIDFILE"

#
## We check all the selected emulators are installed
#

checkInstalledEmus


#
# Run custom scripts... shhh for now ;)
#

for entry in "$HOME"/emudeck/custom_scripts/*.sh
do
	 bash $entry
done
} | tee "${LOGFILE}" 2>&1
