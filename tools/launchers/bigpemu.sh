#!/usr/bin/bash
source $HOME/.config/EmuDeck/backend/functions/all.sh
rclone_downloadEmu bigpemu
# bigpemu.sh

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

# Main
main () {
    source ~/emudeck/settings.sh

    # NAME - BigPEmu
    NAME="BigPEmu"

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

    # BigPEmu.exe location
    BIGPEMU="$HOME/Applications/BigPEmu/BigPEmu.exe"
    checkFile "${BIGPEMU}"

    # APPID
    APPID=$( /usr/bin/python "${APPIDPY}" "${EXE}" "${NAME}" )
    echo "APPID: ${APPID}"
    if [ -z "${APPID}" ]; then
        reportError "Unable to calculate AppID" "true" "true"
    fi

    # PROTONVER
    PROTONVER="8.0"
    echo "PROTONVER: ${PROTONVER}"

    # Call the Proton launcher script and give the arguments
    echo "${PROTONLAUNCH}" -p "${PROTONVER}" -i "${APPID}" -- "${BIGPEMU}" "${@}"
    "${PROTONLAUNCH}" -p "${PROTONVER}" -i "${APPID}" -- "${BIGPEMU}" "${@}"

}

# Only run if run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Set a LOGFILE to proton-launch.log in the same directory this script runs from
    # LogFile
    LOGFILE="$( dirname "${BASH_SOURCE[0]}" )/bigpemu-launch.log"

    # Report start time to log
    echo "$( date +'%m/%d/%Y - %H:%M:%S' ) - Started" > "${LOGFILE}"

    # All output should go to LOGFILE after here.
    exec > >(tee "${LOGFILE}")

    # Continue to main()
    main "${@}"
fi
rclone_uploadEmu bigpemu