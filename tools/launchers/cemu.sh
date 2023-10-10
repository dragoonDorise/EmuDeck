#!/usr/bin/bash
source $HOME/.config/EmuDeck/backend/functions/all.sh
cloud_sync_downloadEmu "Cemu" && cloud_sync_startService
# cemu.sh

# Report Errors
reportError () {
    echo "${1}"
    if [ "${2}" == "true" ]; then
        zenity --error \
            --text="${1}" \
            --width=250
    fi
    if [ "${3}" == "true" ]; then
        exit 1
    fi
}

# Check for file
checkFile () {
    echo "Checking for file: ${1}"
    if [ ! -f "${1}" ]; then
        reportError "Error: Unable to find ${1##*/} in\n ${1%/*}" "true" "true"
    fi
}

# Report all current arguments to the LOGFILE
showArguments () {
    local arg
    echo "Arguments -"
    for arg; do
        echo "Argument:  $arg"
    done
}

# Attempt to find the given program as an AppImage
getAppImage () {
    local EMUDIR="${HOME}/Applications"

    # Check for AppImage
    local APPIMAGE
    APPIMAGE="$( find "${EMUDIR}" -type f -iname "${NAME}*.AppImage" | sort -n | cut -d ' ' -f 2- | tail -n 1 2>/dev/null )"

    # Check if APPIMAGE is unset or empty, and that the file exists
    if [ -z ${APPIMAGE+x} ] || [ ! -f "${APPIMAGE}" ]; then
        echo "Error: AppImage not found."
        return 1
    elif [ -f "${APPIMAGE}" ]; then
        EMUPATH="${APPIMAGE}"
    fi
}

# Attempt to find the given program as a Flatpak
getFlatpak () {
    # Set Flatpak
    local FLATPAK
    FLATPAK="$( flatpak list --app --columns=application | grep -i "${NAME}" )"
    if [ -z "${FLATPAK}" ]; then
        echo "Error: Flatpak not found."
        return 1
    else
        EMUPATH=("/usr/bin/flatpak" "run" "${FLATPAK}")
    fi
}

# Main
main () {
    source ~/emudeck/settings.sh

    # NAME - Cemu
    NAME="Cemu"

    # EMUPATH
    EMUPATH="false"

    # doProton
    doProton="false"

    # Check for -W Flag override to windows version
    if [ "$1" == "-w" ]; then
        doProton="true"
        shift
    fi

    # Check for an AppImage or Flatpak, and run through Proton if neither
    echo "Checking for AppImage."
    if ! getAppImage; then
        echo "Checking for Flatpak."
        if ! getFlatpak; then
            echo "Attempting to run Cemu.exe through Proton."
            doProton="true"
        fi
    fi

    # Check for single quotes around the last argument
    if [[ "${*:$#}" =~ ^\'.*\'$ ]]; then
        ARGS=("${@}")
        LASTARG="${ARGS[-1]#\'}"
        ARGS[-1]="${LASTARG%\'}"
        set -- "${ARGS[@]}"
    fi

    # Report arguments
    showArguments "${@}"

    # Run Emulator
    if [[ "${doProton}" == "false" ]]; then
        #If doProton is false, check that EMUPATH was set correctly
        if [[ "${EMUPATH}" == "false" ]] || [[ -z "${EMUPATH}" ]]; then
            echo "Error: Unable to emulator path."
            reportError "Error: Unable to emulator path." "true" "true"
        fi

        # If doProton is false, check that EMUPATH is executable
        if [ -f "${EMUPATH}" ] && [[ ! -x "${EMUPATH}" ]]; then
            chmod +x "${EMUPATH}" || reportError "Error: ${EMUPATH} cannot be made executable" "true" "true"
        fi
        # Check for "z:" or "Z:" in the last argument and remove it
        if [[ "${*:$#}" =~ ^[zZ]: ]]; then
            ARGS=("${@}")
            ARGS[-1]="${ARGS[-1]#[zZ]:}"
            set -- "${ARGS[@]}"
        fi

        echo "${EMUPATH[@]}" "${@}"
        "${EMUPATH[@]}" "${@}"
    else
        # Get SELFPATH
        SELFPATH="$( realpath "${BASH_SOURCE[0]}" )"

        if [ -z "${SELFPATH}" ]; then
            reportError "Error: Unable to get own path" "true" "true"
        else
            echo "SELFPATH: ${SELFPATH}" 
        fi

        # Get EXE
        EXE="\"/usr/bin/bash\" \"${SELFPATH}\""
        echo "EXE: ${EXE}"

        # AppID.py
        APPIDPY="$emulationPath/tools/appID.py"
        checkFile "${APPIDPY}"

        # Proton Launcher Script
        PROTONLAUNCH="$emulationPath/tools/proton-launch.sh"
        checkFile "${PROTONLAUNCH}"

        # Cemu.exe location
        CEMU="$emulationPath/roms/wiiu/Cemu.exe"
        checkFile "${CEMU}"

        # APPID
        APPID=$( /usr/bin/python "${APPIDPY}" "${EXE}" "${NAME}" )
        echo "APPID: ${APPID}"
        if [ -z "${APPID}" ]; then
            reportError "Unable to calculate AppID" "true" "true"
        fi

        # PROTONVER
        PROTONVER="7.0"
        echo "PROTONVER: ${PROTONVER}"

        # Call the Proton launcher script and give the arguments
        echo "${PROTONLAUNCH}" -p "${PROTONVER}" -i "${APPID}" -- "${CEMU}" "${@}"
        "${PROTONLAUNCH}" -p "${PROTONVER}" -i "${APPID}" -- "${CEMU}" "${@}"
    fi

}

# Only run if run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Set a LOGFILE to proton-launch.log in the same directory this script runs from
    # LogFile
    LOGFILE="$( dirname "${BASH_SOURCE[0]}" )/cemu-launch.log"

    # Report start time to log
    echo "$( date +'%m/%d/%Y - %H:%M:%S' ) - Started" > "${LOGFILE}"

    # All output should go to LOGFILE after here.
    exec > >(tee "${LOGFILE}")

    # Continue to main()
    main "${@}"
fi

rm -rf "$savesPath/.gaming"