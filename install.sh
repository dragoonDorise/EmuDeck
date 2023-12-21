#!/bin/bash

linuxID=$(lsb_release -si)

if [ $linuxID != "ChimeraOS" ]; then

echo "installing EmuDeck"

elif [ $linuxID != "SteamOS" ]; then


    zenityAvailable=$(command -v zenity &> /dev/null  && echo true)

    if [[ $zenityAvailable = true ]];then
        PASSWD="$(zenity --password --title="Password Entry" --text="Enter you user sudo password to install required depencies" 2>/dev/null)"
        echo "$PASSWD" | sudo -v -S
        ans=$?
        if [[ $ans == 1 ]]; then
            #incorrect password
            PASSWD="$(zenity --password --title="Password Entry" --text="Password was incorrect. Try again. (Did you remember to set a password for linux before running this?)" 2>/dev/null)"
            echo "$PASSWD" | sudo -v -S
            ans=$?
            if [[ $ans == 1 ]]; then
                    text="$(printf "<b>Password not accepted.</b>\n Expert mode tools which require a password will not work. Disabling them.")"
                    zenity --error \
                    --title="EmuDeck" \
                    --width=400 \
                    --text="${text}" 2>/dev/null
                    setSetting doInstallPowertools false
                    setSetting doInstallGyro false
            fi
        fi
    fi

    SCRIPT_DIR=$( cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

    function log_err {
      echo "$@" >&2
    }

    function script_failure {
      log_err "An error occurred:$([ -z "$1" ] && " on line $1" || "(unknown)")."
      log_err "Installation failed!"
      exit
    }

    #trap 'script_failure $LINENO' ERR

    echo "Installing EmuDeck dependencies..."


    if command -v apt-get >/dev/null; then
        echo "Installing packages with apt..."
        DEBIAN_DEPS="jq zenity flatpak unzip bash libfuse2 git rsync whiptail"

        sudo killall apt apt-get
        sudo apt-get -y update
        sudo apt-get -y install $DEBIAN_DEPS
    elif command -v pacman >/dev/null; then
        echo "Installing packages with pacman..."
        ARCH_DEPS="steam jq zenity flatpak unzip bash fuse2 git rsync whiptail"

        sudo pacman --noconfirm -Syu
        sudo pacman --noconfirm -S $ARCH_DEPS
    elif command -v dnf >/dev/null; then
        echo "Installing packages with dnf..."
        FEDORA_DEPS="jq zenity flatpak unzip bash fuse git rsync newt"

        sudo dnf -y upgrade
        sudo dnf -y install $FEDORA_DEPS
    elif command -v zypper >/dev/null; then
        echo "Installing packages with zypper..."
        SUSE_DEPS="steam jq zenity flatpak unzip bash libfuse2 git rsync whiptail"

        sudo zypper --non-interactive up
        sudo zypper --non-interactive install $SUSE_DEPS
    elif command -v xbps-install >/dev/null; then
        echo "Installing packages with xbps..."
        VOID_DEPS="steam jq zenity flatpak unzip bash fuse git rsync whiptail"

        sudo xbps-install -Syu
        sudo xbps-install -Sy $VOID_DEPS
    else
        log_err "Your Linux distro $linuxID is not supported by this script. We invite to open a PR or help us with adding your OS to this script. https://github.com/dragoonDorise/EmuDeck/issues"
        exit 1
    fi


    # this could be replaced to immediately start the EmuDeck setup script

    echo "All prerequisite packages have been installed. EmuDeck will be installed now!"

fi

set -eo pipefail

report_error() {
    FAILURE="$(caller): ${BASH_COMMAND}"
    echo "Something went wrong!"
    echo "Error at ${FAILURE}"
}

trap report_error ERR

EMUDECK_GITHUB_URL="https://api.github.com/repos/EmuDeck/emudeck-electron-early/releases/latest"
EMUDECK_URL="$(curl -s ${EMUDECK_GITHUB_URL} | grep -E 'browser_download_url.*AppImage' | cut -d '"' -f 4)"

mkdir -p ~/Applications
curl -L "${EMUDECK_URL}" -o ~/Applications/EmuDeck.AppImage 2>&1 | stdbuf -oL tr '\r' '\n' | sed -u 's/^ *\([0-9][0-9]*\).*\( [0-9].*$\)/\1\n#Download Speed\:\2/' | zenity --progress --title "Downloading EmuDeck" --width 600 --auto-close --no-cancel 2>/dev/null
chmod +x ~/Applications/EmuDeck.AppImage
~/Applications/EmuDeck.AppImage
