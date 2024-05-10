#!/bin/bash
# bigpemu.sh

# Set up cloud save
source "${HOME}/.config/EmuDeck/backend/functions/all.sh"
emulatorInit "bigpemu"

emuName="bigpemu" #parameterize me
emufolder="$HOME/Applications/BigPEmu"
exe=$(find "$emufolder" -type f -iname "${emuName}" ! -name "*.*" | sort -n | cut -d' ' -f 2- | tail -n 1 2>/dev/null)

echo "Executable: $exe"


#if binary doesn't exist fall back to windows executable.
if [[ $exe == '' ]]; then
    echo "Binary not found. Looking for the Windows executable instead."
    # Get SELFPATH
    SELFPATH="$( realpath "${BASH_SOURCE[0]}" )"

    # Get EXE
    EXE="\"/usr/bin/bash\" \"${SELFPATH}\""
    echo "EXE: ${EXE}"

    # NAME
    NAME="BigPEmu"

    # AppID.py
    APPIDPY="$emulationPath/tools/appID.py"

    # Proton Launcher Script
    PROTONLAUNCH="$emulationPath/tools/proton-launch.sh"

    # BigPEmu location
    BIGPEMU="$HOME/Applications/BigPEmu/BigPEmu.exe"

    # APPID
    if [ -e "/usr/bin/python" ]; then
        APPID=$( /usr/bin/python "${APPIDPY}" "${EXE}" "${NAME}" )
    elif [ -e "/usr/bin/python3" ]; then
        APPID=$( /usr/bin/python3 "${APPIDPY}" "${EXE}" "${NAME}" )
    else
        echo "Python not found."
    fi

    echo "APPID: ${APPID}"

    # Proton Version
    PROTONVER="8.0"

    # Call the Proton launcher script and give the arguments

    if [ -z "${@}" ]; then
        echo "Launching BigPEmu directly"
        echo "${PROTONLAUNCH}" -p "${PROTONVER}" -i "${APPID}" -- "${BIGPEMU}" "*" -localdata >> "${LOGFILE}"
        "${PROTONLAUNCH}" -p "${PROTONVER}" -i "${APPID}" -- "${BIGPEMU}" "*" -localdata


    else
        echo "ROM found, launching game"
        echo "${PROTONLAUNCH}" -p "${PROTONVER}" -i "${APPID}" -- "${BIGPEMU}" "${@}" -localdata >> "${LOGFILE}"
        "${PROTONLAUNCH}" -p "${PROTONVER}" -i "${APPID}" -- "${BIGPEMU}" "${@}" -localdata

    fi
else
#make sure that file is executable
	chmod +x $exe
    echo "Binary found."
fi

#run the executable with the params.
launch_args=()
for rom in "${@}"; do
	# Parsers previously had single quotes ("'/path/to/rom'" ), this allows those shortcuts to continue working.
	removedLegacySingleQuotes=$(echo "$rom" | sed "s/^'//; s/'$//")
	launch_args+=("$removedLegacySingleQuotes")
done

echo "Launching: "${exe}" "${launch_args[*]}""

if [[ -z "${*}" ]]; then
    echo "ROM not found. Launching $emuName directly"
    "${exe}" "*" -localdata
else
    echo "ROM found, launching game"
    "${exe}" "${launch_args[@]}" -localdata
fi

rm -rf "$savesPath/.gaming"