#!/bin/bash
MSG=$HOME/emudeck/logs/msg.log
echo "0" > "$MSG"

#Darwin
appleChip=$(uname -m)
if [ $(uname) != "Linux" ]; then
	if [ $appleChip = 'arm64' ]; then
		PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
	else
		PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"
	fi
fi

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
time curl -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28"  "https://api.github.com/rate_limit"

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



source "$EMUDECKGIT"/functions/helperFunctions.sh
source "$EMUDECKGIT"/functions/jsonToBashVars.sh
time jsonToBashVars "$HOME/.config/EmuDeck/settings.json"
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
time getEnvironmentDetails
time testRealDeck

#this sets up the settings file with defaults, in case they don't have a new setting we've added.
#also echos them all out so they are in the log.
#echo "Setup Settings File: "
#createUpdateSettingsFile

#create folders after tests!
time createFolders

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
	time ESDE_install
fi
#Pegasus Installation
if [ $doInstallPegasus == "true" ]; then
	echo "install Pegasus"
	time pegasus_install
fi
#SRM Installation
if [ $doInstallSRM == "true" ]; then
	echo "install srm"
	time SRM_install
fi
if [ "$doInstallPCSX2QT" == "true" ]; then
	echo "install pcsx2Qt"
	time PCSX2QT_install
fi
if [ $doInstallPrimeHack == "true" ]; then
	echo "install primehack"
	time Primehack_install
fi
if [ $doInstallRPCS3 == "true" ]; then
	echo "install rpcs3"
	time RPCS3_install
fi
if [ $doInstallCitra == "true" ]; then
	echo "install Citra"
	time Citra_install
fi
if [ $doInstallLime3DS == "true" ]; then
	echo "install Lime3DS"
	time Lime3DS_install
fi
if [ $doInstallDolphin == "true" ]; then
	echo "install Dolphin"
	time Dolphin_install
fi
if [ $doInstallDuck == "true" ]; then
	echo "DuckStation_install"
	time DuckStation_install
fi
if [ $doInstallRA == "true" ]; then
	echo "RetroArch_install"
	time RetroArch_install
fi
if [ $doInstallRMG == "true" ]; then
	echo "RMG_install"
	time RMG_install
fi
if [ $doInstallares == "true" ]; then
	echo "ares_install"
	time ares_install
fi
if [ $doInstallPPSSPP == "true" ]; then
	echo "PPSSPP_install"
	time PPSSPP_install
fi
if [ $doInstallYuzu == "true" ]; then
	echo "Yuzu_install"
	time Yuzu_install
fi
if [ $doInstallSuyu == "true" ]; then
	echo "suyu_install"
	time suyu_install
fi
if [ $doInstallRyujinx == "true" ]; then
	echo "Ryujinx_install"
	time Ryujinx_install
fi
if [ $doInstallMAME == "true" ]; then
	echo "MAME_install"
	time MAME_install
fi
if [ $doInstallXemu == "true" ]; then
	echo "Xemu_install"
	time Xemu_install
fi
if [ $doInstallCemu == "true" ]; then
	echo "Cemu_install"
	time Cemu_install
fi
if [ "${doInstallCemuNative}" == "true" ]; then
	echo "CemuNative_install"
	time CemuNative_install
fi
if [ $doInstallScummVM == "true" ]; then
	echo "ScummVM_install"
	time ScummVM_install
fi
if [ $doInstallVita3K == "true" ]; then
	echo "Vita3K_install"
	time Vita3K_install
fi
if [ $doInstallMGBA == "true" ]; then
	echo "mGBA_install"
	time mGBA_install
fi
if [ $doInstallFlycast == "true" ]; then
	echo "Flycast_install"
	time Flycast_install
fi
if [ $doInstallRMG == "true" ]; then
	echo "RMG_install"
	time RMG_install
fi
if [ $doInstallares == "true" ]; then
	echo "ares_install"
	time ares_install
fi
if [ $doInstallmelonDS == "true" ]; then
	echo "melonDS_install"
	time melonDS_install
fi
if [ $doInstallBigPEmu == "true" ]; then
	echo "BigPEmu_install"
	time BigPEmu_install
fi
if [ $doInstallSupermodel == "true" ]; then
	echo "Supermodel_install"
	time Supermodel_install
fi
#Xenia - We need to install Xenia after creating the Roms folders!
if [ "$doInstallXenia" == "true" ]; then
	echo "Xenia_install"
	time Xenia_install
fi
if [ "$doInstallModel2" == "true" ]; then
	echo "Model2_install"
	time Model2_install
fi

if [ "$doInstallShadPS4" == "true" ]; then
	echo "ShadPS4_install"
	time ShadPS4_install
fi

#Steam RomManager Config

if [ "$doSetupSRM" == "true" ]; then
	echo "SRM_init"
	time SRM_init
fi

#ESDE Config
if [ "$doSetupESDE" == "true" ]; then
	echo "ESDE_init"
	time ESDE_update
fi

#Pegasus Config
#if [ $doSetupPegasus == "true" ]; then
#	echo "pegasus_init"
#	pegasus_init
#fi

#Emus config
#setMSG "Configuring Steam Input for emulators.." moved to emu install


setMSG "Configuring emulators.."

if [ "$doSetupRA" == "true" ]; then
	echo "RetroArch_init"
	time RetroArch_init
fi
if [ "$doSetupPrimehack" == "true" ]; then
	echo "Primehack_init"
	time Primehack_init
fi
if [ "$doSetupDolphin" == "true" ]; then
	echo "Dolphin_init"
	time Dolphin_init
fi
if [ "$doSetupPCSX2QT" == "true" ]; then
	echo "PCSX2QT_init"
	time PCSX2QT_init
fi
if [ "$doSetupRPCS3" == "true" ]; then
	echo "RPCS3_init"
	time RPCS3_init
fi
if [ "$doSetupCitra" == "true" ]; then
	echo "Citra_init"
	time Citra_init
fi
if [ $doSetupLime3DS == "true" ]; then
	echo "Lime3DS_init"
	time Lime3DS_init
fi
if [ "$doSetupDuck" == "true" ]; then
	echo "DuckStation_init"
	time DuckStation_init
fi
if [ "$doSetupYuzu" == "true" ]; then
	echo "Yuzu_init"
	time Yuzu_init
fi
if [ "$doSetupRyujinx" == "true" ]; then
	echo "Ryujinx_init"
	time Ryujinx_init
fi
if [ "$doSetupShadPS4" == "true" ]; then
	echo "ShadPS4_init"
	time ShadPS4_init
fi
if [ "$doSetupPPSSPP" == "true" ]; then
	echo "PPSSPP_init"
	time PPSSPP_init
fi
if [ "$doSetupXemu" == "true" ]; then
	echo "Xemu_init"
	time Xemu_init
fi
if [ "$doSetupMAME" == "true" ]; then
	echo "MAME_init"
	time MAME_init
fi
if [ "$doSetupScummVM" == "true" ]; then
	echo "ScummVM_init"
	time ScummVM_init
fi
if [ "$doSetupVita3K" == "true" ]; then
	echo "Vita3K_init"
	time Vita3K_init
fi
if [ "$doSetupRMG" == "true" ]; then
	echo "RMG_init"
	time RMG_init
fi
if [ "$doSetupares" == "true" ]; then
	echo "ares_init"
	time ares_init
fi
if [ "$doSetupmelonDS" == "true" ]; then
	echo "melonDS_init"
	time melonDS_init
fi
if [ "$doSetupMGBA" == "true" ]; then
	echo "mGBA_init"
	time mGBA_init
fi
if [ "${doSetupCemuNative}" == "true" ]; then
	echo "CemuNative_init"
	time CemuNative_init
fi
if [ "$doSetupFlycast" == "true" ]; then
	echo "Flycast_init"
	time Flycast_init
fi
if [ "$doSetupSupermodel" == "true" ]; then
	echo "Supermodel_init"
	time Supermodel_init
fi
if [ "$doSetupModel2" == "true" ]; then
	echo "model2_init"
	time Model2_init
fi
#Proton Emus
if [ "$doSetupCemu" == "true" ]; then
	echo "Cemu_init"
	time Cemu_init
fi
if [ "$doSetupBigPEmu" == "true" ]; then
	echo "BigPEmu_init"
	time BigPEmu_init
fi
if [ "$doSetupXenia" == "true" ]; then
	echo "Xenia_init"
	time Xenia_init
fi


#
##
##End of installation
##
#


#Always install
time BINUP_install
time AutoCopy_install
time server_install
time FlatpakUP_install
time CHD_install

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
		time nonDeck_169Screen
	fi

	#Anbernic Win600 Special configuration
	if [ "$(getProductName)" == "Win600" ];then
		time nonDeck_win600
	fi
fi

if [ "$system" == "chimeraos" ]; then
	mkdir -p $HOME/Applications

	downloads_dir="$HOME/Downloads"
	destination_dir="$HOME/Applications"
	file_name="EmuDeck"

	mkdir -p $destination_dir

	find "$downloads_dir" -type f -name "*$file_name*.AppImage" -exec mv {} "$destination_dir/$file_name.AppImage" \;

	chmod +x "$destination_dir/EmuDeck.AppImage"

fi


time createDesktopIcons


if [ "$controllerLayout" == "bayx" ] || [ "$controllerLayout" == "baxy" ] ; then
	time controllerLayout_BAYX
else
	time controllerLayout_ABXY
fi

#
##
##Plugins
##
#

#GyroDSU
#Plugins_installSteamDeckGyroDSU

#EmuDeck updater on gaming Mode
#mkdir -p "${toolsPath}/updater"
#cp -v "$EMUDECKGIT/tools/updater/emudeck-updater.sh" "${toolsPath}/updater/"
#chmod +x "${toolsPath}/updater/emudeck-updater.sh"

#RemotePlayWhatever
# if [[ ! $branch == "main" ]]; then
# 	RemotePlayWhatever_install
# fi

#
# We mark the script as finished
#
echo "" > "$HOME/.config/EmuDeck/.finished"
echo "" > "$HOME/.config/EmuDeck/.ui-finished"
echo "100" > "$HOME/emudeck/logs/msg.log"
echo "# Installation Complete" >> "$HOME/emudeck/logs/msg.log"
finished=true
rm "$PIDFILE"

#
## We check all the selected emulators are installed
#

time checkInstalledEmus


#
# Run custom scripts... shhh for now ;)
#

for entry in "$HOME"/emudeck/custom_scripts/*.sh
do
	 bash $entry
done
} | tee "${LOGFILE}" 2>&1
