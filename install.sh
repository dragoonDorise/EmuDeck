#!/usr/bin/env bash

DEBIAN_DEPS=(jq zenity flatpak unzip bash libfuse2 git rsync whiptail python)
ARCH_DEPS=(steam jq zenity flatpak unzip bash fuse2 git rsync libnewt python)
FEDORA_DEPS=(jq zenity flatpak unzip bash fuse git rsync newt python)
SUSE_DEPS=(steam jq zenity flatpak unzip bash libfuse2 git rsync whiptail python)
VOID_DEPS=(steam jq zenity flatpak unzip bash fuse git rsync newt python)
GENTOO_DEPS=(app-misc/jq gnome-extra/zenity sys-apps/flatpak app-arch/unzip app-shells/bash sys-fs/fuse:0 dev-vcs/git net-misc/rsync dev-libs/newt dev-lang/python app-text/xmlstarlet)

linuxID=$(lsb_release -si)
sandbox=""

if [ "$linuxID" = "Ubuntu" ]; then
    sandbox="--no-sandbox"
fi
clear

if [ "$linuxID" == "SteamOS" ]; then
    echo "Installing EmuDeck"
else
    zenityAvailable=$(command -v zenity &> /dev/null  && echo true)

    if [[ $zenityAvailable = true ]];then
        read -r PASSWD <<< "$(zenity --password --title="Password Entry" --text="Enter you user sudo password to install required depencies" 2>/dev/null)"
        echo "$PASSWD" | sudo -v -S
        ans=$?
        if [[ $ans == 1 ]]; then
            #incorrect password
            read -r PASSWD <<< "$(zenity --password --title="Password Entry" --text="Password was incorrect. Try again. (Did you remember to set a password for linux before running this?)" 2>/dev/null)"
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

        sudo killall apt apt-get
        sudo apt-get -y update
        sudo apt-get -y install "${DEBIAN_DEPS[@]}"
    elif command -v pacman >/dev/null; then
        echo "Installing packages with pacman..."

        sudo pacman --noconfirm -Syu
        sudo pacman --noconfirm -S "${ARCH_DEPS[@]}"
    elif command -v rpm-ostree >/dev/null; then
        echo "Installing packages with rpm-ostree..."

        sudo rpm-ostree install "${FEDORA_DEPS[@]}"
    elif command -v dnf >/dev/null; then
        echo "Installing packages with dnf..."

        sudo dnf -y upgrade
        sudo dnf -y install "${FEDORA_DEPS[@]}"
    elif command -v zypper >/dev/null; then
        echo "Installing packages with zypper..."

        sudo zypper --non-interactive up
        sudo zypper --non-interactive install "${SUSE_DEPS[@]}"
    elif command -v xbps-install >/dev/null; then
        echo "Installing packages with xbps..."

        sudo xbps-install -Syu
        sudo xbps-install -Sy "${VOID_DEPS[@]}"
    elif command -v emerge >/dev/null; then
        echo "Installing packages with emerge..."

        sudo emerge --sync
        sudo emerge -n "${GENTOO_DEPS[@]}"
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

EMUDECK_GITHUB_URL="https://api.github.com/repos/EmuDeck/emudeck-electron/releases/latest"
EMUDECK_URL="$(curl -s ${EMUDECK_GITHUB_URL} | grep -E 'browser_download_url.*AppImage' | cut -d '"' -f 4)"

mkdir -p ~/Applications
curl -L "${EMUDECK_URL}" -o ~/Applications/EmuDeck.AppImage 2>&1 | stdbuf -oL tr '\r' '\n' | sed -u 's/^ *\([0-9][0-9]*\).*\( [0-9].*$\)/\1\n#Download Speed\:\2/' | zenity --progress --title "Downloading EmuDeck" --width 600 --auto-close --no-cancel 2>/dev/null
chmod +x ~/Applications/EmuDeck.AppImage
~/Applications/EmuDeck.AppImage $sandbox
exit
