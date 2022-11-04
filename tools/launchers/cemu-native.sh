#!/usr/bin/bash

## cemu-native.sh

# LogFile
LOGFILE="$( dirname "${BASH_SOURCE[0]}" )/cemu-native-launch.log"

# Report start time to log
echo "$(date +'%m/%d/%Y - %H:%M:%S') - Started" > "${LOGFILE}"

# Settings file
settingsFile="${HOME}/emudeck/settings.sh"
if [ -f "${settingsFile}" ]; then
    # Source the settings file
    # shellcheck disable=SC1091
    # shellcheck source="${HOME}/emudeck/settings.sh"
    . "${settingsFile}"
else
    reportError "Error: Unable to find ${settingsFile}." "true" "true"
fi

# launcherFunctions.sh
launcherFunctions="${toolsPath}/launcherFunctions.sh"
if [ -f "${launcherFunctions}" ]; then
    # Source the launcherFunctions.sh
    # shellcheck disable=SC1091
    # shellcheck source="${toolsPath}/launcherfunctions.sh"
    . "${launcherFunctions}"
else
    reportError "Error: Unable to find ${launcherFunctions}." "true" "true"
fi

# Set emu-launch.sh
launch="${toolsPath}/emu-launch.sh"
checkFile "${launch}"

# Set emulator name
EMU="Cemu"

# Launch emu-launch.sh
"${launch}" -e "${EMU}" -- "${@}"
