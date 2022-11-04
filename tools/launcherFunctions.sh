#!/usr/bin/bash

## launcherFunctions.sh

### Functions

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

# Report all current arguments to the LOGFILE
showArguments () {
    local arg
    for arg; do
        echo "Argument:  $arg" >> "${LOGFILE}"
    done
}
