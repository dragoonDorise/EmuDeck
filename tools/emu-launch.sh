#!/usr/bin/bash

## emu-launch.sh

# Attempt to find the given program as an AppImage
getAppImage () {
    local EMUDIR="${HOME}/Applications"

    # Check for AppImage
    local APPIMAGE
    APPIMAGE="$( find "${EMUDIR}" -type f -iname "${EMUNAME}*.AppImage" | sort -n | cut -d ' ' -f 2- | tail -n 1 2>/dev/null )"

    # Check if APPIMAGE is unset or empty, and that the file exists
    if [ -z ${APPIMAGE+x} ] || [ ! -f "${APPIMAGE}" ]; then
        echo "Error: AppImage not found." >> "${LOGFILE}"
        return 1
    elif [ -f "${APPIMAGE}" ]; then
        EMUPATH="${APPIMAGE}"
    fi
}

# Attempt to find the given program as a Flatpak
getFlatpak () {
    # Set Flatpak
    local FLATPAK
    FLATPAK="$( flatpak list --app --columns=application | grep -i "${EMUNAME}" )"
    if [ -z "${FLATPAK}" ]; then
        echo "Error: Flatpak not found." >> "${LOGFILE}"
        return 1
    else
        EMUPATH=("/usr/bin/flatpak" "run" "${FLATPAK}")
    fi
}

# Main
main () {
    ISAPPIMAGE="false"
    ISFLATPAK="false"
    EMUPATH="false"

    # Check for options -h help -p Proton Version -i AppID
    while getopts "e:afp:" option; do
        case ${option} in
            e) # Emulator Name
                EMUNAME="${OPTARG}"
                ;;
            a) # AppImage
                ISAPPIMAGE="true"
                ;;
            f) # FlatPak
                ISFLATPAK="true"
                ;;
            p) # Full path
                EMUPATH="${OPTARG}"
                if ! [ -f "${EMUPATH}" ]; then
                    echo "Error: ${EMUPATH} is not a valid file." >> "${LOGFILE}"
                    reportError "Error: ${EMUPATH} is not a valid file." "true" "true"
                fi
                ;;
            \?) # Invalid option
                echo "Error: Invalid option - ${OPTARG}" >> "${LOGFILE}"
                reportError "Error: Invalid option - ${OPTARG}" "true" "true"
                ;;
        esac
    done
    shift "$(( OPTIND - 1 ))"

    # Make sure both AppImage and Flatpak aren't selected
    if [ "${ISAPPIMAGE}" = "true" ] && [ "${ISFLATPAK}" = "true" ]; then
        echo "Error: Can't select both -a and -f" >> "${LOGFILE}"
        reportError "Error: Can't select both -a and -f" "true" "true"
    fi

    # Check if EMUNAME is set
    if [ -z ${EMUNAME+x} ]; then
        echo "Error: -e flag not set. Please set an emulator name." >> "${LOGFILE}"
        reportError "Error: -e flag not set. Please set an emulator name." "true" "true"
    fi

    {
        echo "Emulator: ${EMUNAME}"
        echo "Is AppImage: ${ISAPPIMAGE}"
        echo "Is Flatpak: ${ISFLATPAK}"
        echo "Emu Path: ${EMUPATH[*]}"
    } >> "${LOGFILE}"

    # Get the full emulator path, if it is not set (either AppImage or Flatpak)
    if [ "${EMUPATH}" = "false" ]; then
        if [ "${ISAPPIMAGE}" = "false" ] && [ "${ISFLATPAK}" = "false" ]; then
            if ! getAppImage; then
                if ! getFlatpak; then
                    echo "Error: Could not find either an AppImage nor a Flatpak with the name ${EMUNAME}." >> "${LOGFILE}"
                    reportError "Error: Could not find either an AppImage nor a Flatpak with the name ${EMUNAME}." "true" "true"
                fi
            fi
        elif [ "${ISAPPIMAGE}" = "true" ] && ! getAppImage; then
            echo "Error: AppImage not found." >> "${LOGFILE}"
            reportError "Error: AppImage not found." "true" "true"
        elif [ "${ISFLATPAK}" = "true" ] && ! getFlatpak; then
            echo "Error: Flatpak not found." >> "${LOGFILE}"
            reportError "Error: Flatpak not found." "true" "true"
        fi
    fi

    echo "EMUPATH: ${EMUPATH[*]}" >> "${LOGFILE}"

    # Last check to make sure there's an EMUPATH
    if [ "${EMUPATH}" = "false" ] || [ -z "${EMUPATH}" ]; then
        echo "Error: Unable to resolve a path to the emulator." >> "${LOGFILE}"
        reportError "Error: Unable to resolve a path to the emulator." "true" "true"
    fi

    # Make sure EXE is executable, if it is a file
    if [ -f "${EMUPATH}" ] && [[ ! -x "${EMUPATH}" ]]; then
        chmod +x "${EMUPATH}" || reportError "Error: ${EMUPATH} cannot be made executable" "true" "true"
    fi

    # Check for single quotes around the last argument
    if [[ "${*:$#}" =~ ^\'.*\'$ ]]; then
        ARGS=("${@}")
        LASTARG="${ARGS[-1]#\'}"
        ARGS[-1]="${LASTARG%\'}"
        set -- "${ARGS[@]}"
    fi

    # Check for "z:" or "Z:" in the last argument
    if [[ "${*:$#}" =~ ^[zZ]: ]]; then
        ARGS=("${@}")
        ARGS[-1]="${ARGS[-1]#[zZ]:}"
        set -- "${ARGS[@]}"
    fi

    # Report arguments
    echo "Arguments -" >> "${LOGFILE}"
    showArguments "${@}"

    # Run Emulator
    echo "${EMUPATH[@]}" "${@}" >> "${LOGFILE}"
    "${EMUPATH[@]}" "${@}"
}

# Only run if run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Get own directory
    selfDir="$( dirname "${BASH_SOURCE[0]}" )"

    # Source the launcherFunctions.sh
    # shellcheck disable=SC1091
    . "${selfDir}/launcherFunctions.sh"

    # Set a LOGFILE to proton-launch.log in the same directory this script runs from
    LOGFILE="${selfDir}/emu-launch.log"
    echo "$(date +'%m/%d/%Y - %H:%M:%S') - Started" > "${LOGFILE}"
    
    # Exit if there aren't any arguments
    if ! [[ "${1}" ]]; then
        echo "Error: No arguments provided." >> "${LOGFILE}"
        reportError "Error: No arguments provided." "true" "true"
    fi

    # Continue to main()
    main "$@"
fi
