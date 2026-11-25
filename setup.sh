#!/usr/bin/env bash
#
##
## set backend location
##
# I think this should just be in the source, so there's one spot for initialization. hrm, no i'm wrong. Here is best.
emudeckBackend="$HOME/.config/EmuDeck/backend/"
. "$emudeckBackend/vars.sh"

##
## Command line
##
## A launcher (RommDeck, another frontend) can install one emulator instead of
## everything settings.json selects: setup.sh --only duckstation. The ids are
## the ones settings.json's installEmus and overwriteConfigEmus use.
##
##   id:name:the variable that installs it:the variable that sets it up
## (empty when setup.sh has no step for it, as suyu has no setup).
##
EMUDECK_TARGETS=(
	"ra:RetroArch:doInstallRA:doSetupRA"
	"duckstation:DuckStation:doInstallDuck:doSetupDuck"
	"pcsx2:PCSX2:doInstallPCSX2QT:doSetupPCSX2QT"
	"armsx2:ARMSX2:doInstallARMSX2:doSetupARMSX2"
	"rpcs3:RPCS3:doInstallRPCS3:doSetupRPCS3"
	"dolphin:Dolphin:doInstallDolphin:doSetupDolphin"
	"primehack:PrimeHack:doInstallPrimeHack:doSetupPrimehack"
	"ppsspp:PPSSPP:doInstallPPSSPP:doSetupPPSSPP"
	"azahar:Azahar:doInstallAzahar:doSetupAzahar"
	"melonds:melonDS:doInstallmelonDS:doSetupmelonDS"
	"mgba:mGBA:doInstallMGBA:doSetupMGBA"
	"flycast:Flycast:doInstallFlycast:doSetupFlycast"
	"mame:MAME:doInstallMAME:doSetupMAME"
	"xemu:xemu:doInstallXemu:doSetupXemu"
	"cemu:Cemu:doInstallCemu:doSetupCemu"
	"cemu-native:Cemu (native Linux):doInstallCemuNative:doSetupCemuNative"
	"vita3k:Vita3K:doInstallVita3K:doSetupVita3K"
	"rmg:RMG:doInstallRMG:doSetupRMG"
	"ares:ares:doInstallares:doSetupares"
	"scummvm:ScummVM:doInstallScummVM:doSetupScummVM"
	"supermodel:Supermodel:doInstallSupermodel:doSetupSupermodel"
	"model2:Model 2 Emulator:doInstallModel2:doSetupModel2"
	"bigpemu:BigPEmu:doInstallBigPEmu:doSetupBigPEmu"
	"shadps4:shadPS4:doInstallShadPS4:doSetupShadPS4"
	"xenia:Xenia:doInstallXenia:doSetupXenia"
	"ryujinx:Ryujinx:doInstallRyujinx:doSetupRyujinx"
	"yuzu:yuzu:doInstallYuzu:doSetupYuzu"
	"suyu:suyu:doInstallSuyu:"
	"citron:Citron::doSetupCitron"
	"esde:ES-DE:doInstallESDE:doSetupESDE"
	"pegasus:Pegasus:doInstallPegasus:doSetupPegasus"
	"steam:Steam ROM Manager:doInstallSRM:doSetupSRM"
	"deckyromlauncher:Decky ROM Library:doInstallRetroLibrary:"
)

# The row for an id, or nothing.
emudeck_target() {
	local row
	for row in "${EMUDECK_TARGETS[@]}"; do
		if [ "${row%%:*}" == "$1" ]; then
			echo "$row"
			return 0
		fi
	done
	return 1
}

emudeck_usage() {
	cat <<EOF
Usage: setup.sh [--only <id>]... [--list] [--help]

  --only <id>  Install and set up just this emulator (or frontend), and
               nothing else. Repeat it for more than one.
  --list       The ids --only takes, with their names.
  --help       This.

Without --only, setup.sh installs and sets up everything settings.json
selects, as the app does. Exit code 2 means bad usage or an unknown id.
EOF
}

# --only: every step off, then just the ones asked for on.
apply_only_selection() {
	local row id name install_var setup_var
	for row in "${EMUDECK_TARGETS[@]}"; do
		IFS=: read -r id name install_var setup_var <<<"$row"
		[ -z "$install_var" ] || eval "$install_var=false"
		[ -z "$setup_var" ] || eval "$setup_var=false"
	done
	for id in "${ONLY_IDS[@]}"; do
		row=$(emudeck_target "$id") || continue
		IFS=: read -r _ name install_var setup_var <<<"$row"
		[ -z "$install_var" ] || eval "$install_var=true"
		[ -z "$setup_var" ] || eval "$setup_var=true"
		echo "Installing only $name ($id)"
	done
}

ONLY_IDS=()
while [ $# -gt 0 ]; do
	case "$1" in
	--only)
		shift
		if [ $# -eq 0 ]; then
			echo "setup.sh: --only needs an emulator id, see --list" >&2
			exit 2
		fi
		ONLY_IDS+=("$1")
		;;
	--only=*)
		ONLY_IDS+=("${1#--only=}")
		;;
	--list)
		for row in "${EMUDECK_TARGETS[@]}"; do
			IFS=: read -r id name _ _ <<<"$row"
			printf '%-18s %s\n' "$id" "$name"
		done
		exit 0
		;;
	-h | --help)
		emudeck_usage
		exit 0
		;;
	*)
		echo "setup.sh: unknown argument: $1 (see --help)" >&2
		exit 2
		;;
	esac
	shift
done
for id in "${ONLY_IDS[@]}"; do
	if ! emudeck_target "$id" >/dev/null; then
		echo "setup.sh: unknown emulator: $id (see --list)" >&2
		exit 2
	fi
done

MSG=$emudeckLogs/msg.log
echo "0" > "$MSG"

#
##
## Pid Lock...
##
#

mkdir -p "$HOME/.config/EmuDeck"
mkdir -p "$emudeckLogs"
PIDFILE="$emudeckFolder/install.pid"


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

#Creating log file
LOGFILE="$emudeckLogs/emudeckSetup.log"

mkdir -p "$HOME/.config/EmuDeck"

#Custom Scripts
mkdir -p "$emudeckFolder/custom_scripts"
echo $'#!/usr/bin/env bash\nemudeckBackend="$HOME/.config/EmuDeck/backend/"\nsource "$emudeckBackend/functions/all.sh"' > "$emudeckFolder/custom_scripts/example.sh"

echo "Press the button to start..." > "$LOGFILE"

mv "${LOGFILE}" "$emudeckLogs/emudeckSetup.last.log" #backup last log

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
FOLDER="$emudeckFolder"
if [ -d "$FOLDER" ]; then
	echo "" > "$emudeckFolder/.finished"
fi
sleep 1
SECONDTIME="$emudeckFolder/.finished"

#Lets log github API limits just in case
echo 'Github API limits:'
curl -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28"  "https://api.github.com/rate_limit"


#
##
## Start of installation
##
#



source "$emudeckBackend"/functions/helperFunctions.sh
source "$emudeckBackend"/functions/jsonToBashVars.sh
if [ "$(uname)" == "Darwin" ]; then
	source "$emudeckBackend"/functions/darwin/helperFunctions.sh
fi
jsonToBashVars "$emudeckFolder/settings.json"
source "$emudeckBackend/functions/all.sh"
statInstall "system"
if isEarlyBranch; then
	statInstall "early"
fi
if [ ${#ONLY_IDS[@]} -gt 0 ]; then
	apply_only_selection
fi


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
#echo "Setup Settings File: "
#createUpdateSettingsFile

#create folders after tests!
createFolders

#setup Proton-Launch.sh
#because this path gets updated by sed, we really should be installing it every and allowing it to be updated every time. In case the user changes their path.
cp "$emudeckBackend/tools/proton-launch.sh" "${toolsPath}/proton-launch.sh"
chmod +x "${toolsPath}/proton-launch.sh"
cp "$emudeckBackend/tools/appID.py" "${toolsPath}/appID.py"

# Setup emu-launch.sh
cp "$emudeckBackend/tools/emu-launch.sh" "${toolsPath}/emu-launch.sh"
chmod +x "${toolsPath}/emu-launch.sh"

#Forced SRM so the App won't fail
SRM_flushToolLauncher


max_jobs=5
current_jobs=0

for install_command in \
	"$doInstallESDE ESDE_install" \
	"$doInstallPegasus pegasus_install" \
	"$doInstallSRM SRM_install" \
	"$doInstallRetroLibrary Plugins_installDeckyRomLibrary" \
	"$doInstallPCSX2QT PCSX2QT_install" \
	"$doInstallARMSX2 ARMSX2_install" \
	"$doInstallPrimeHack Primehack_install" \
	"$doInstallRPCS3 RPCS3_install" \
	"$doInstallAzahar Azahar_install" \
	"$doInstallDolphin Dolphin_install" \
	"$doInstallDuck DuckStation_install" \
	"$doInstallRA RetroArch_install" \
	"$doInstallRMG RMG_install" \
	"$doInstallares ares_install" \
	"$doInstallPPSSPP PPSSPP_install" \
	"$doInstallYuzu Yuzu_install" \
	"$doInstallSuyu suyu_install" \
	"$doInstallRyujinx Ryujinx_install" \
	"$doInstallMAME MAME_install" \
	"$doInstallXemu Xemu_install" \
	"$doInstallCemu Cemu_install" \
	"$doInstallCemuNative CemuNative_install" \
	"$doInstallScummVM ScummVM_install" \
	"$doInstallVita3K Vita3K_install" \
	"$doInstallMGBA mGBA_install" \
	"$doInstallFlycast Flycast_install" \
	"$doInstallmelonDS melonDS_install" \
	"$doInstallBigPEmu BigPEmu_install" \
	"$doInstallSupermodel Supermodel_install" \
	"$doInstallXenia Xenia_install" \
	"$doInstallModel2 Model2_install" \
	"$doInstallShadPS4 ShadPS4_install"; do

	condition=$(echo "$install_command" | awk '{print $1}')
	command=$(echo "$install_command" | cut -d' ' -f2-)

	if [ "$condition" == "true" ]; then
		echo "Executing $command"
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
	"$doSetupSRM SRM_init" \
	"$doSetupESDE ESDE_init" \
	"$doSetupPegasus pegasus_init" \
	"$doSetupRA RetroArch_init" \
	"$doSetupPrimehack Primehack_init" \
	"$doSetupDolphin Dolphin_init" \
	"$doSetupPCSX2QT PCSX2QT_init" \
	"$doSetupARMSX2 ARMSX2_init" \
	"$doSetupRPCS3 RPCS3_init" \
	"$doSetupAzahar Azahar_init" \
	"$doSetupDuck DuckStation_init" \
	"$doSetupYuzu Yuzu_init" \
	"$doSetupCitron Citron_init" \
	"$doSetupRyujinx Ryujinx_init" \
	"$doSetupShadPS4 ShadPS4_init" \
	"$doSetupPPSSPP PPSSPP_init" \
	"$doSetupXemu Xemu_init" \
	"$doSetupMAME MAME_init" \
	"$doSetupScummVM ScummVM_init" \
	"$doSetupVita3K Vita3K_init" \
	"$doSetupRMG RMG_init" \
	"$doSetupares ares_init" \
	"$doSetupmelonDS melonDS_init" \
	"$doSetupMGBA mGBA_init" \
	"$doSetupCemuNative CemuNative_init" \
	"$doSetupFlycast Flycast_init" \
	"$doSetupSupermodel Supermodel_init" \
	"$doSetupModel2 Model2_init" \
	"$doSetupCemu Cemu_init" \
	"$doSetupBigPEmu BigPEmu_init" \
	"$doSetupXenia Xenia_init"; do

	condition=$(echo "$setup_command" | awk '{print $1}')
	command=$(echo "$setup_command" | awk '{print $2}')

	if [ "$condition" == "true" ]; then
		echo "Executing $command"
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


#Always install (not when --only: a launcher asked for one emulator, not the
#housekeeping every full run does)
if [ ${#ONLY_IDS[@]} -eq 0 ]; then
	BINUP_install &
	AutoCopy_install &
	server_install &
	FlatpakUP_install &
	CHD_install &
fi

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

	mkdir -p $destination_dir

	find "$downloads_dir" -type f -name "*$file_name*.AppImage" -exec mv {} "$destination_dir/$file_name.AppImage" \;

	chmod +x "$destination_dir/EmuDeck.AppImage"

fi


createDesktopIcons &


if [ "$controllerLayout" == "bayx" ] || [ "$controllerLayout" == "baxy" ] ; then
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
echo "" > "$emudeckFolder/.finished"
echo "" > "$emudeckFolder/.ui-finished"
echo "100" > "$emudeckLogs/msg.log"
echo "# Installation Complete" >> "$emudeckLogs/msg.log"
finished=true
rm "$PIDFILE"

#
## We check all the selected emulators are installed
#



checkInstalledEmus


#
# Run custom scripts... shhh for now ;)
#

for entry in "$emudeckFolder"/custom_scripts/*.sh
do
	 bash $entry
done
} | tee "${LOGFILE}" 2>&1
