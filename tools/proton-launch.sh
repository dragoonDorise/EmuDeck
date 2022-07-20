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
    echo "Setting environment variables." >> "${LOGFILE}"
    # Set default data path if it isn't set, then include an appID
    if [ -z ${STEAM_COMPAT_DATA_PATH+x} ] && ! [ -z ${PFX+x} ]; then
        export STEAM_COMPAT_DATA_PATH="${PFX}"
    elif [ -z ${STEAM_COMPAT_DATA_PATH+x} ]; then
        export STEAM_COMPAT_DATA_PATH="${COMPATDATA}/${SteamAppId:-${APPID}}"
    fi

    # Set SteamAppId
    if [ -z ${SteamAppId+x} ] && ! [ -z ${APPID+x} ]; then
        export SteamAppId=${APPID}
    elif [ -z ${SteamAppId+x} ]; then
        export SteamAppId=0
    fi

    # Set default Steam Client path if it isn't
    if [ -z ${STEAM_COMPAT_CLIENT_INSTALL_PATH+x} ]; then
        export STEAM_COMPAT_CLIENT_INSTALL_PATH="${STEAMPATH}"
    fi
    # Create prefix if it doesn't exist
    if ! [ -d ${STEAM_COMPAT_DATA_PATH} ]; then
        install -d ${STEAM_COMPAT_DATA_PATH} || exit 1
    fi
    {
        echo "STEAM_COMPAT_DATA_PATH: ${STEAM_COMPAT_DATA_PATH}"
        echo "SteamAppId: ${SteamAppId}"
        echo "STEAM_COMPAT_CLIENT_INSTALL_PATH: ${STEAM_COMPAT_CLIENT_INSTALL_PATH}"
    } >> "${LOGFILE}"
}

# Main Start
main () {
    # Steam Application Path
    if [ -d "$HOME/.local/share/Steam" ]; then
        STEAMPATH="$HOME/.local/share/Steam"
        echo "STEAMPATH: ${STEAMPATH}" >> "${LOGFILE}"
    else # Fail if Steam path isn't a directory
        echo "Steam path not found." >> "${LOGFILE}"; exit 1
    fi

    # Alt steamapps path - need a way to pull all available steamapps directories own by Steam
    if [ -d "/run/media/mmcblk0p1/steamapps" ]; then
        ALTSTEAM="/run/media/mmcblk0p1/steamapps"
        echo "ALTSTEAM: ${ALTSTEAM}" >> "${LOGFILE}"
    fi

    # Check for options -h help -p Proton Version -i AppID
    while getopts "h:p:i:" option; do
        case ${option} in
            h) # display Help
                Help
                echo "Help flag was called." >> "${LOGFILE}"
                exit;;
            p) # Proton version
                PROTONVER="${OPTARG}"
                # Check for Proton paths
                if [ -f "${STEAMPATH}/steamapps/common/Proton ${PROTONVER}/proton" ]; then
                    PROTON="${STEAMPATH}/steamapps/common/Proton ${PROTONVER}/proton"
                    COMPATDATA="${STEAMPATH}/steamapps/compatdata"
                    {
                        echo "Proton Version: ${PROTONVER}"
                        echo "Proton Path: ${PROTON}" 
                        echo "COMPATDATA: ${COMPATDATA}" 
                    } >> "${LOGFILE}"
                # Check for Custom Proton paths
                elif [ -f "${STEAMPATH}/compatibilitytools.d/${PROTONVER}/proton" ]; then
                    PROTON="${STEAMPATH}/compatibilitytools.d/${PROTONVER}/proton"
                    COMPATDATA="${STEAMPATH}/steamapps/compatdata"
                    {
                        echo "Proton Version: ${PROTONVER}"
                        echo "Proton Path: ${PROTON}" 
                        echo "COMPATDATA: ${COMPATDATA}" 
                    } >> "${LOGFILE}"
                # If we can't find the default path, try the alternate one - loop here through all Steamapps?
                elif [ -n "${ALTSTEAM+x}" ] && [ -f "${ALTSTEAM}/common/Proton ${PROTONVER}/proton" ]; then
                    PROTON="${ALTSTEAM}/common/Proton ${PROTONVER}/proton"
                    COMPATDATA="${ALTSTEAM}/compatdata"
                    {
                        echo "Proton Version: ${PROTONVER}"
                        echo "Proton Path: ${PROTON}" 
                        echo "COMPATDATA: ${COMPATDATA}" 
                    } >> "${LOGFILE}"
                # Couldn't find either path
                else
                    echo "Proton version is not installed." >> "${LOGFILE}"
                    exit 1
                fi;;
            i) # Proton AppID
                APPID="${OPTARG}"
                echo "AppID: ${APPID}" >> "${LOGFILE}";;
            \?) # Invalid option
                echo "Error: Invalid option - ${OPTARG}" >> "${LOGFILE}"
                exit;;
        esac
    done

    # Check if AppID is set, if not, set it to 0
    if [ -z ${APPID+x} ]; then
        APPID=0
        echo "AppID: ${APPID}" >> "${LOGFILE}"
    elif ! [[ ${APPID} =~ ^[0-9]+$ ]]; then # Make sure AppID is an integer
        echo "AppID must be an integer." >> "${LOGFILE}"
        exit 1
    fi

    # Check if Proton is set, if not, set it to 7.0 by default
    if [ -z ${PROTON+x} ] && [ -f "${STEAMPATH}/steamapps/common/Proton 7.0/proton" ]; then
        PROTON="${STEAMPATH}/steamapps/common/Proton 7.0/proton"
        PFX="${STEAMPATH}/steamapps/compatdata/${APPID}"
        echo "Proton: ${PROTON}" >> "${LOGFILE}"
        echo "PFX: ${PFX}" >> "${LOGFILE}"
    # Try the Alt directory - loop here?
    elif [ -z ${PROTON+x} ] && [ ! -z ${ALTSTEAM+x} ] && [ -f "${ALTSTEAM}/common/Proton 7.0/proton" ]; then
        PROTON="${ALTSTEAM}/common/Proton 7.0/proton"
        PFX="${ALTSTEAM}/compatdata/${APPID}"
        echo "Proton: ${PROTON}" >> "${LOGFILE}"
        echo "PFX: ${PFX}" >> "${LOGFILE}"
    fi

    # Cancel if PROTON is still not set.
    if [ -z ${PROTON+x} ]; then
        echo "Proton is not set." >> "${LOGFILE}"
        exit 1
    fi

    # Set PFX if not set
    if [ -z ${PFX+x} ] && ! [ -z ${COMPATDATA+x} ]; then
        PFX="${COMPATDATA}/${APPID}"
        echo "PFX: ${PFX}" >> "${LOGFILE}"
    elif [ -z ${PFX+x} ]; then
        echo "No PFX." >> "${LOGFILE}"
    fi

    # Remove opt arguments from $@ before --
    shift "$(( OPTIND - 1 ))"

    # Check for mandatory target
    if [ -z ${1+x} ]; then
        echo "Target application must be set." >> "${LOGFILE}"
        echo
        Help
        exit 1
    elif ! [ -f "${1}" ]; then
        echo "Target application not found. - ${1}" >> "${LOGFILE}"
        echo
        Help
        exit 1
    fi
    
    # Call set_env function
    set_env

    # Start application with Proton
    echo "Running python ${PROTON} waitforexitandrun $*" >> "${LOGFILE}" # Send command to log just in case
    python "${PROTON}" waitforexitandrun "${@}"
}

# Only run if run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Set a LOGFILE to proton-launch.log in the same directory this script runs from
    LOGFILE="$(dirname "${BASH_SOURCE[0]}")/proton-launch.log"
    echo "$(date +'%m/%d/%Y - %H:%I:%S') - Started" > "${LOGFILE}"
    
    # Exit if there aren't any arguments
    if ! [[ "${1}" ]]; then
        Help
        echo "No arguments provided." >> "${LOGFILE}"
        exit 1
    fi

    # Continue to main()
    main "$@"
fi
