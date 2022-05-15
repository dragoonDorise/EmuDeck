#!/bin/bash

## proton-launch.sh

############################################################
# Help                                                     #
############################################################
Help () {
    # Display Help
    echo "This script will open a program via Proton"
    echo
    echo "Syntax: proton-launch [-h|p|i] -- <path-to-target> <target options>"
    echo "options:"
    echo "h     Print this Help."
    echo "p     Proton version"
    echo "i     Proton AppID"
    echo
    exit
}

# Set environment variables
set_env () {
    # Set default data path if it isn't set, then include an appID
    if [ -z ${STEAM_COMPAT_DATA_PATH+x} ]; then
        export STEAM_COMPAT_DATA_PATH="${PFX}"/${SteamAppId:-${APPID}}
    elif ! [ ${SteamGameId} -ge 0 ] 2>/dev/null && ! [ ${SteamAppId} -ge 0 ] 2>/dev/null && ! [ $(basename ${STEAM_COMPAT_DATA_PATH}) -ge 0 ] 2>/dev/null; then
        export SteamAppId=${APPID}
    fi
    # Set default Steam Client path if it isn't
    if [ -z ${STEAM_COMPAT_CLIENT_INSTALL_PATH+x} ]; then
        export STEAM_COMPAT_CLIENT_INSTALL_PATH="${STEAMPATH}"
    fi
    # Create prefix if it doesn't exist
    if ! [ -d ${STEAM_COMPAT_DATA_PATH} ]; then
        install -d ${STEAM_COMPAT_DATA_PATH} || exit 1
    fi
}

# Main
main () {
#for arg in "${@}"; do echo "${arg}"; done;exit
    # Steam Path
    STEAMPATH="${HOME}/.local/share/Steam"
    # Prefix
    PFX="${STEAMPATH}/steamapps/compatdata/pfx"
    # Check or options
    while getopts "h:p:i:" option; do
        case ${option} in
            h) # display Help
                Help
                exit;;
            p) # Proton version
                if [ -d "${STEAMPATH}/steamapps/common/Proton ${OPTARG}" ]; then
                    PROTONVER="${OPTARG}"
                else
                    echo "Proton version is not installed."
                    exit 1
                fi;;
            i) # Proton AppID
                APPID="${OPTARG}";;
            \?) # Invalid option
                echo "Error: Invalid option"
                exit;;
        esac
    done

    # Check if AppID is set, if not, set it to 0
    if [ -z ${APPID+x} ]; then
        APPID=0
    elif ! [[ ${APPID} =~ ^[0-9]+$ ]]; then # Make sure AppID is an integer
        echo "AppID must be an integer."
        exit 1
    fi

    # Check if ProtonVer is set, if not, set it to 7.0 by default
    if [ -z ${PROTONVER+x} ]; then
        PROTON="${STEAMPATH}/steamapps/common/Proton 7.0/proton"
    else
        PROTON="${STEAMPATH}/steamapps/common/Proton ${PROTONVER}/proton"
    fi

    # Reset arguments
    shift "$(( OPTIND - 1 ))"

    # Check for mandatory target
    if [ -z ${1+x} ]; then
        echo 'Target application must be set.'
        echo
        Help
        exit 1
    elif ! [ -f "${1}" ]; then
        echo 'Target application not found.'
        echo
        Help
    fi

    set_env
    python "${PROTON}" waitforexitandrun "${@}"
}

# Only run if run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if ! [[ "${1}" ]]; then
        Help
    fi
    main "$@"
fi