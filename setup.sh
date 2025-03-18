#!/usr/bin/env bash

# shellcheck disable=2154

#
##
## set backend location
##
# I think this should just be in the source, so there's one spot for initialization. hrm, no i'm wrong. Here is best.

emudeckBackend="$HOME/.config/EmuDeck/backend/"
# shellcheck disable=1091
. "$emudeckBackend/vars.sh"
MSG="${emudeckLogs}/msg.log"
echo "0" > "${MSG}"

#Darwin
appleChip=$(uname -m)
if [ "$(uname)" != "Linux" ]; then
	if [ "${appleChip}" = 'arm64' ]; then
		PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:${PATH}"
	else
		PATH="/usr/local/opt/gnu-sed/libexec/gnubin:${PATH}"
	fi
fi

#
##
## Pid Lock...
##
#

mkdir -p "${HOME}/.config/EmuDeck"
mkdir -p "${emudeckLogs}"
PIDFILE="${emudeckFolder}/install.pid"


if [ -f "${PIDFILE}" ]; then
  PID=$(cat "${PIDFILE}")

  if ! ps -p "${PID}" > /dev/null 2>&1; then
    echo "Process already running"
    exit 1
  else
    ## Process not found assume not running
    
    if ! echo $$ > "${PIDFILE}"; then
      echo "Could not create PID file"
      exit 1
    fi
  fi
else
  if ! echo $$ > "${PIDFILE}"; then
    echo "Could not create PID file"
    exit 1
  fi
fi

function finish {
  echo "Script terminating. Exit code $?"
  finished=true
  rm "${MSG}"

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

#Creating log file
LOGFILE="${emudeckLogs}/emudeckSetup.log"

mkdir -p "${HOME}/.config/EmuDeck"

#Custom Scripts
mkdir -p "${emudeckFolder}/custom_scripts"
echo $'#!/bin/bash\nemudeckBackend="$HOME/.config/EmuDeck/backend/"\nsource "$emudeckBackend/functions/all.sh"' > "${emudeckFolder}/custom_scripts/example.sh"

echo "Press the button to start..." > "${LOGFILE}"

mv "${LOGFILE}" "${emudeckLogs}/emudeckSetup.last.log" #backup last log

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
FOLDER="${emudeckFolder}"
if [ -d "${FOLDER}" ]; then
	echo "" > "${emudeckFolder}/.finished"
fi
sleep 1
# shellcheck disable=2034
SECONDTIME="${emudeckFolder}/.finished"

#Lets log github API limits just in case
echo 'Github API limits:'
curl -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28"  "https://api.github.com/rate_limit"


#
##
## Start of installation
##
#

# shellcheck disable=1091
source "${emudeckBackend}"/functions/helperFunctions.sh
# shellcheck disable=1091
source "${emudeckBackend}"/functions/jsonToBashVars.sh
jsonToBashVars "${emudeckFolder}/settings.json"
# shellcheck disable=1091
source "${emudeckBackend}/functions/all.sh"


#after sourcing functins, check if path is empty.
# [[ -z "$emulationPath" ]] && { echo "emulationPath is Empty!"; setMSG "There's been an issue, please restart the app"; exit 1; }



echo "Current Settings: "
grep -vi pass "${emuDecksettingsFile}"


#
#Environment Check
#
echo ""
echo "Env Details: "
getEnvironmentDetails
testRealDeck

#this sets up the settings file with defaults, in case they don't have a new setting we've added.
#also echos them all out so they are in the log.
#echo "Setup Settings File: "
#createUpdateSettingsFile

#create folders after tests!
createFolders

#setup Proton-Launch.sh
#because this path gets updated by sed, we really should be installing it every and allowing it to be updated every time. In case the user changes their path.
cp "${emudeckBackend}/tools/proton-launch.sh" "${toolsPath}/proton-launch.sh"
chmod +x "${toolsPath}/proton-launch.sh"
cp "${emudeckBackend}/tools/appID.py" "${toolsPath}/appID.py"

# Setup emu-launch.sh
cp "${emudeckBackend}/tools/emu-launch.sh" "${toolsPath}/emu-launch.sh"
chmod +x "${toolsPath}/emu-launch.sh"


max_jobs=5
current_jobs=0

for install_command in \
	"${doInstallESDE} ESDE_install" \
	"${doInstallPegasus} pegasus_install" \
	"${doInstallSRM} SRM_install" \
	"${doInstallRetroLibrary} Plugins_installDeckyRomLibrary" \
	"${doInstallPCSX2QT} PCSX2QT_install" \
	"${doInstallPrimeHack} Primehack_install" \
	"${doInstallRPCS3} RPCS3_install" \
	"${doInstallCitra} Citra_install" \
	"${doInstallLime3DS} Lime3DS_install" \
	"${doInstallDolphin} Dolphin_install" \
	"${doInstallDuck} DuckStation_install" \
	"${doInstallRA} RetroArch_install" \
	"${doInstallRMG} RMG_install" \
	"${doInstallares} ares_install" \
	"${doInstallPPSSPP} PPSSPP_install" \
	"${doInstallYuzu} Yuzu_install" \
	"${doInstallSuyu} suyu_install" \
	"${doInstallRyujinx} Ryujinx_install" \
	"${doInstallMAME} MAME_install" \
	"${doInstallXemu} Xemu_install" \
	"${doInstallCemu} Cemu_install" \
	"${doInstallCemuNative} CemuNative_install" \
	"${doInstallScummVM} ScummVM_install" \
	"${doInstallVita3K} Vita3K_install" \
	"${doInstallMGBA} mGBA_install" \
	"${doInstallFlycast} Flycast_install" \
	"${doInstallmelonDS} melonDS_install" \
	"${doInstallBigPEmu} BigPEmu_install" \
	"${doInstallSupermodel} Supermodel_install" \
	"${doInstallXenia} Xenia_install" \
	"${doInstallModel2} Model2_install" \
	"${doInstallShadPS4} ShadPS4_install"; do

	condition=$(echo "${install_command}" | awk '{print $1}')
	command=$(echo "${install_command}" | cut -d' ' -f2-)

	if [ "${condition}" == "true" ]; then
		echo "Executing ${command}"
		$command &
		current_jobs=$((current_jobs + 1))
	fi

	if [ $current_jobs -ge $max_jobs ]; then
		wait
		current_jobs=0
	fi
done
setMSG "Waiting for installation tasks to finish.."
wait # Wait for any remaining jobs to finish

setMSG "Configuring emulators & tools.."

max_jobs=5
current_jobs=0

for setup_command in \
	"${doSetupSRM} SRM_init" \
	"${doSetupESDE} ESDE_init" \
	"${doSetupPegasus} pegasus_init" \
	"${doSetupRA} RetroArch_init" \
	"${doSetupPrimehack} Primehack_init" \
	"${doSetupDolphin} Dolphin_init" \
	"${doSetupPCSX2QT} PCSX2QT_init" \
	"${doSetupRPCS3} RPCS3_init" \
	"${doSetupCitra} Citra_init" \
	"${doSetupLime3DS} Lime3DS_init" \
	"${doSetupDuck} DuckStation_init" \
	"${doSetupYuzu} Yuzu_init" \
	"${doSetupCitron} Citron_init" \
	"${doSetupRyujinx} Ryujinx_init" \
	"${doSetupShadPS4} ShadPS4_init" \
	"${doSetupPPSSPP} PPSSPP_init" \
	"${doSetupXemu} Xemu_init" \
	"${doSetupMAME} MAME_init" \
	"${doSetupScummVM} ScummVM_init" \
	"${doSetupVita3K} Vita3K_init" \
	"${doSetupRMG} RMG_init" \
	"${doSetupares} ares_init" \
	"${doSetupmelonDS} melonDS_init" \
	"${doSetupMGBA} mGBA_init" \
	"${doSetupCemuNative} CemuNative_init" \
	"${doSetupFlycast} Flycast_init" \
	"${doSetupSupermodel} Supermodel_init" \
	"${doSetupModel2} Model2_init" \
	"${doSetupCemu} Cemu_init" \
	"${doSetupBigPEmu} BigPEmu_init" \
	"${doSetupXenia} Xenia_init"; do

	condition=$(echo "${setup_command}" | awk '{print $1}')
	command=$(echo "${setup_command}" | awk '{print $2}')

	if [ "${condition}" == "true" ]; then
		echo "Executing ${command}"
		$command &
		current_jobs=$((current_jobs + 1))
	fi

	if [ $current_jobs -ge $max_jobs ]; then
		wait
		current_jobs=0
	fi
done

wait # Wait for any remaining jobs to finish

#
##
##End of installation
##
#


#Always install
BINUP_install &
AutoCopy_install &
server_install &
FlatpakUP_install &
CHD_install &

#
##
## Overrides for non Steam hardware...
##
#


#
#Fixes for 16:9 Screens
#
if [ "${doSetupRA}" == "true" ]; then
	if [ "$(getScreenAR)" == 169 ];then
		nonDeck_169Screen
	fi

	#Anbernic Win600 Special configuration
	if [ "$(getProductName)" == "Win600" ];then
		nonDeck_win600
	fi
fi

if [ "$system" == "chimeraos" ]; then
	mkdir -p "${HOME}/Applications"

	downloads_dir="${HOME}/Downloads"
	destination_dir="${HOME}/Applications"
	file_name="EmuDeck"

	mkdir -p "${destination_dir}"

	find "${downloads_dir}" -type f -name "*${file_name}*.AppImage" -exec mv {} "${destination_dir}/${file_name}.AppImage" \;

	chmod +x "${destination_dir}/EmuDeck.AppImage"

fi


createDesktopIcons &


if [ "${controllerLayout}" == "bayx" ] || [ "${controllerLayout}" == "baxy" ] ; then
	controllerLayout_BAYX &
else
	controllerLayout_ABXY &
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
#cp -v "$emudeckBackend/tools/updater/emudeck-updater.sh" "${toolsPath}/updater/"
#chmod +x "${toolsPath}/updater/emudeck-updater.sh"

#RemotePlayWhatever
# if [[ ! $branch == "main" ]]; then
# 	RemotePlayWhatever_install
# fi

#
# We mark the script as finished
#
setMSG "Waiting for setup tasks to finish.."
wait
echo "" > "${emudeckFolder}/.finished"
echo "" > "${emudeckFolder}/.ui-finished"
echo "100" > "${emudeckLogs}/msg.log"
echo "# Installation Complete" >> "${emudeckLogs}/msg.log"
# shellcheck disable=2034
finished=true
rm "${PIDFILE}"

#
## We check all the selected emulators are installed
#



checkInstalledEmus


#
# Run custom scripts... shhh for now ;)
#

for entry in "${emudeckFolder}"/custom_scripts/*.sh
do
	 bash "${entry}"
done
} | tee "${LOGFILE}" 2>&1
