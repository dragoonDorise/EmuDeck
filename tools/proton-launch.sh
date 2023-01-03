#!/usr/bin/bash

## proton-launch.sh

# Report Errors
reportError () {
    # Report error to logfile
    echo "${1}" >> "${LOGFILE}"
    # Open a Zenity dialog for the user
    if [ "${2}" == "true" ]; then
        zenity --error \
            --text="${1}"\
            --width=250
    fi
    # Exit the script
    if [ "${3}" == "true" ]; then
        exit 1
    fi
}

# Check for file
checkFile () {
    echo "Checking for file: ${1}" >> "${LOGFILE}"
    if [ ! -f "${1}" ]; then
        reportError "Error: Unable to find ${1##*/} in\n ${1%/*}" "true" "true"
    fi
}

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
}

# Report all current arguments to the LOGFILE
showArguments () {
    local arg
    for arg; do
        echo "Argument:  $arg" >> "${LOGFILE}"
    done
}

# Attempt to send a request to install Proton version
installProton () {
    # Known AppIDs for Proton versions
    declare -A protonVersions=(
        [3.7 Beta]="930400"
        [3.7]="858280"
        [3.16 Beta]="996510"
        [3.16]="961940"
        [4.2]="1054830"
        [4.11]="1113280"
        [5.0]="1245040"
        [5.13]="1420170"
        [6.3]="1580130"
        [7.0]="1887720"
        [- Experimental]="1493710"
        [Hotfix]="2180100"
        [EasyAntiCheat Runtime]="1826330"
        [BattlEye Runtime]="1161040"
    )

    # If Proton Version is known, attempt to prompt the user to install it
    if [ "${protonVersions[${1}]+x}" ]; then
        {
            reportError "Attempting to install Proton ${1}." "true"
            # Send install command to Steam
            steam steam://install/"${protonVersions[${1}]}"
            # Steam won't download until the script is closed.
            reportError "Please re-open after Proton ${1} has been installed." "true" "true"
        } >> "${LOGFILE}"
    else
        # Exit with error if the Proton version is unknown
        reportError "Error: Unknown Proton version ${1}." "true" "true"
    fi 
}

# Find Proton version
findProton () {
    # Cycle through steamPaths to find the requested Proton version
    for path in "${steamPaths[@]}"; do
        if [ -f "${path}/steamapps/common/Proton ${1}/proton" ]; then
            local proton="${path}/steamapps/common/Proton ${1}/proton"
            break
        elif [ -f "${path}/compatibilitytools.d/${1}/proton" ]; then
            local proton="${path}/compatibilitytools.d/${1}/proton"
            break
        fi
    done

    # Check if the proton variable was successfully set
    if [ -z ${proton+x} ]; then
        # Report to log but don't error to user
        reportError "Error: Unable to find Proton version ${1}."
        # Attempt to install Proton version
        installProton "${1}"
    else
        # Return found proton path
        echo "${proton}"
    fi
}

# Set environment variables
set_env () {
    echo "Setting environment variables." >> "${LOGFILE}"
    # Set default data path if it isn't set, then include an appID
    if [ -n "${PFX}" ]; then
        export STEAM_COMPAT_DATA_PATH="${PFX}"
    elif [ -z ${STEAM_COMPAT_DATA_PATH+x} ] && [ -z ${PFX+x} ]; then
        export STEAM_COMPAT_DATA_PATH="${COMPATDATA}/${SteamAppId:-${APPID}}"
    fi

    # Set SteamAppId
    if [ -z ${SteamAppId+x} ] || [ "${SteamAppId}" == 0 ]; then
        if  [ -n "${APPID}" ]; then
            export SteamAppId="${APPID}"
        elif [ -z ${SteamAppId+x} ]; then
            export SteamAppId=0
        fi
    fi

    # Set default Steam Client path if it isn't
    if [ -z ${STEAM_COMPAT_CLIENT_INSTALL_PATH+x} ]; then
        export STEAM_COMPAT_CLIENT_INSTALL_PATH="${STEAMPATH}"
    fi
    # Create prefix if it doesn't exist
    if ! [ -d "${STEAM_COMPAT_DATA_PATH}" ]; then
        installOutput="$( install -d "${STEAM_COMPAT_DATA_PATH}" )" || {
            {
                echo "Error: Failed to create STEAM_COMPAT_DATA_PATH: ${STEAM_COMPAT_DATA_PATH}"
                echo "Error: ${installOutput}"
            } >> "${LOGFILE}"
            exit 1
        }
    fi
    {
        echo "STEAM_COMPAT_DATA_PATH: ${STEAM_COMPAT_DATA_PATH}"
        echo "SteamAppId: ${SteamAppId}"
        echo "STEAM_COMPAT_CLIENT_INSTALL_PATH: ${STEAM_COMPAT_CLIENT_INSTALL_PATH}"
    } >> "${LOGFILE}"
}

# Main Start
main () {
    # Report all $@ to LOGFILE for troubleshooting
    showArguments "${@}"

    # Set main STEAMPATH
    if [ -d "${HOME}/.local/share/Steam" ]; then
        STEAMPATH="${HOME}/.local/share/Steam"
    else
        reportError "Error: ${STEAMPATH} does not exist." "true" "true"
    fi
    
    echo "STEAMPATH: ${STEAMPATH}" >> "${LOGFILE}"
    
    #Get all available Steam paths
    steamLibraryFolders="${STEAMPATH}/steamapps/libraryfolders.vdf"
    if [ -f "${steamLibraryFolders}" ]; then
        # shellcheck disable=SC2207
        steamPaths=()
        # Make sure all paths are valid directories
        for p in $( grep path "${steamLibraryFolders}" | awk '{print $2}' | sed 's|\"||g' ); do
            if [ -d "${p}" ]; then
                steamPaths+=("${p}")
            else
                echo "INFO: ${steamLibraryFolders} contains invalid directory ${p}." >> "${LOGFILE}"
            fi
        done
        
        # Exit if there are no paths found.
        if [[ "${#steamPaths[@]}" -eq 0 ]]; then
            reportError "Error: No Steam library paths found in ${steamLibraryFolders}." "true" "true"
        fi
        
        {
            echo "Steam Paths:"
            for path in "${steamPaths[@]}"; do
                echo "${path}"
            done
        } >> "${LOGFILE}"
    else
        reportError "Error: ${steamLibraryFolders} is not a file." "true" "true"
    fi

    # Check for options -h help -p Proton Version -i AppID
    while getopts "h:p:i:" option; do
        case ${option} in
            h) # display Help
                Help
                echo "Help flag was called." >> "${LOGFILE}"
                exit;;
            p) # Proton version
                PROTONVER="${OPTARG}";;
            i) # Proton AppID
                APPID="${OPTARG}"
                # Check for non-integer option arguments
                if [[ ! ${APPID} =~ ^[0-9]+$ ]]; then
                    echo "Error: -i ${APPID} invalid. -i requires an integer" >> "${LOGFILE}"
                    exit 1
                fi
                echo "AppID: ${APPID}" >> "${LOGFILE}";;
            \?) # Invalid option
                reportError "Error: Invalid option - ${OPTARG}" "true" "true"
        esac
    done

    # Remove opt arguments from $@ before --
    shift "$(( OPTIND - 1 ))"

    # Make sure there weren't any odd arguments in the options
    if [[ "${*}" == *"--"* ]]; then
        echo "Error: Invalid argument in options." >> "${LOGFILE}"
        exit 1
    fi

    # Check for mandatory target
    if [ -z ${1+x} ]; then
        reportError "Error: Target application must be set." "true" "true"
    elif ! [ -f "${1}" ]; then
        reportError "Target application not found. - ${1}" "true" "true"
    fi

    # Check if AppID is set, if not, set it to 0
    if [ -z ${APPID+x} ]; then
        APPID=0
        echo "AppID: ${APPID}" >> "${LOGFILE}"
    elif ! [[ ${APPID} =~ ^[0-9]+$ ]]; then # Make sure AppID is an integer
        reportError "Error: AppID must be an integer" "true" "true"
    fi

    # Check if Proton version is set, if not, set it to 7.0 by default
    if [ -z ${PROTONVER+x} ]; then
        PROTONVER="7.0"
    fi

    # Find set Proton version
    PROTON="$( findProton "${PROTONVER}" )"

    # Set COMPATDATA directory
    COMPATDATA="${STEAMPATH}/steamapps/compatdata"

    # Set PFX - should always be in the first path
    PFX="${COMPATDATA}/${APPID}"

    {
        echo "Proton: ${PROTON}"
        echo "PFX: ${PFX}"
        echo "COMPATDATA: ${COMPATDATA}"
    } >> "${LOGFILE}"
    
    # Call set_env function
    set_env

    # Start application with Proton
    echo "Running python ${PROTON} waitforexitandrun ${*}" >> "${LOGFILE}" # Send command to log just in case
    python "${PROTON}" waitforexitandrun "${@}"
}

# Only run if run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Set a LOGFILE to proton-launch.log in the same directory this script runs from
    LOGFILE="$(dirname "${BASH_SOURCE[0]}")/proton-launch.log"
    echo "$(date +'%m/%d/%Y - %H:%M:%S') - Started" > "${LOGFILE}"
    
    # Exit if there aren't any arguments
    if ! [[ "${1}" ]]; then
        Help
        reportError "Error: No arguments provided" "true" "true"
    fi

    # Continue to main()
    main "$@"
fi
