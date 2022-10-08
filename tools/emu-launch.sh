#!/usr/bin/bash

getEmuPath () {
    EMUDIR="${HOME}/Applications"
    EMU="${1}"

    # Check for AppImage
    APPIMAGE="$( find "${EMUDIR}" -type f -iname "${EMU}*.AppImage" | sort -n | cut -d ' ' -f 2- | tail -n 1 2>/dev/null )"

    # Check if APPIMAGE is unset or empty, and that the file exists
    if [ -z ${APPIMAGE+x} ] || ! [ -f "${APPIMAGE}" ]; then
        # Set Flatpak
        FLATPAK="$( flatpak list --app --columns=application | grep "${EMU}" )"
        EMUPATH="/usr/bin/flatpak run ${FLATPAK}"
    elif [ -f "${APPIMAGE}" ]; then
        EMUPATH="${APPIMAGE}"
    else
        echo "Can't find emulator: ${EMU}" >> "${LOGFILE}"; exit 1
    fi

    echo "${EMUPATH}"
}

main () {
    # Set EMU to the first argument, and shift to clear it
    EMU="${1}"
    shift
    echo "Emulator: ${EMU}" >> "${LOGFILE}"

    # Get the full emulator path, if possible (either AppImage or Flatpak)
    EMUPATH=$( getEmuPath "${EMU}" )
    echo "Emulator Path: ${EMUPATH}" >> "${LOGFILE}"

    # Make sure EXE is executable
    if ! [[ -x "${EMUPATH}" ]]; then
        chmod +x "${EMUPATH}"
    fi

    # Remove single quotes from ARGS
    ARGS="${*//\'/\"}"

    # Run Emulator, remove single quotes from ARGS
    echo "Running eval ${EMUPATH} ${ARGS}" >> "${LOGFILE}"
    eval "${EMUPATH}" "${ARGS}"
}

# Only run if run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Set a LOGFILE to proton-launch.log in the same directory this script runs from
    LOGFILE="$(dirname "${BASH_SOURCE[0]}")/emu-launch.log"
    echo "$(date +'%m/%d/%Y - %H:%M:%S') - Started" > "${LOGFILE}"
    
    # Exit if there aren't any arguments
    if ! [[ "${1}" ]]; then
        echo "No arguments provided." >> "${LOGFILE}"
        exit 1
    fi

    # Continue to main()
    main "$@"
fi