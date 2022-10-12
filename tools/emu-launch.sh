#!/usr/bin/bash

showArguments () {
    local arg
    for arg; do
        echo "Argument:  $arg" >> "${LOGFILE}"
    done
}

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
                    exit 1
                fi
                ;;
            \?) # Invalid option
                echo "Error: Invalid option - ${OPTARG}" >> "${LOGFILE}"
                exit
                ;;
        esac
    done
    shift "$(( OPTIND - 1 ))"

    # Make sure both AppImage and Flatpak aren't selected
    if [ "${ISAPPIMAGE}" = "true" ] && [ "${ISFLATPAK}" = "true" ]; then
        echo "Error: Can't select both -a and -f" >> "${LOGFILE}"
        exit 1
    fi

    # Check if EMUNAME is set
    if [ -z ${EMUNAME+x} ]; then
        echo "Error: -e flag not set. Please set an emulator name." >> "${EMU}"
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
                    echo "Error: Could not find either an AppImage nor a Flatpak." >> "${LOGFILE}"
                    exit 1
                fi
            fi
        elif [ "${ISAPPIMAGE}" = "true" ] && ! getAppImage; then
            echo "Error: AppImage not found." >> "${LOGFILE}"
            exit 1
        elif [ "${ISFLATPAK}" = "true" ] && ! getFlatpak; then
            echo "Error: Flatpak not found." >> "${LOGFILE}"
            exit 1
        fi
    fi

    echo "EMUPATH: ${EMUPATH[*]}" >> "${LOGFILE}"

    # Last check to make sure there's an EMUPATH
    if [ "${EMUPATH}" = "false" ] || [ -z "${EMUPATH}" ]; then
        echo "Error: Unable to resolve a path to the emulator." >> "${LOGFILE}"
        exit 1
    fi

    # Make sure EXE is executable, if it is a file
    if [ -f "${EMUPATH}" ] && [[ ! -x "${EMUPATH}" ]]; then
        chmod +x "${EMUPATH}"
    fi

    # Check for single quotes around the last argument
    if [[ "${*:$#}" =~ ^\'.*\'$ ]]; then
        ARGS=("${@}")
        LASTARG="${ARGS[-1]#\'}"
        ARGS[-1]="${LASTARG%\'}"
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
