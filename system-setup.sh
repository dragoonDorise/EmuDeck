#!/bin/bash
set -e

SCRIPT_DIR=$( cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

function log_err {
  echo "$@" >&2
}

function script_failure {
  log_err "An error occurred:$([ -z "$1" ] && " on line $1" || "(unknown)")."
  log_err "Installation failed!"
}

trap 'script_failure $LINENO' ERR

echo "Installing EmuDeck prerequisites..."
echo
if [[ "$OSTYPE" == "linux-gnu"* ]]; then 
  if command -v apt-get >/dev/null; then
    echo "Installing packages with apt..."
    DEBIAN_DEPS="steam jq zenity flatpak unzip bash"

    sudo apt-get -y update
    sudo apt-get -y install $DEBIAN_DEPS
  elif command -v pacman >/dev/null; then
    echo "Installing packages with pacman..."
    ARCH_DEPS="steam jq zenity flatpak unzip bash"
    
    sudo pacman -Syu 
    sudo pacman -S $ARCH_DEPS
  else
    log_err "Your Linux distro '$(lsb_release -s -d)' is not supported by this script. We invite to open a PR or help us with adding your OS to this script. https://github.com/dragoonDorise/EmuDeck/issues"
    exit 1
  fi
else 
  log_err "Your operating system '$(OSTYPE)' is not supported by this script. We invite to open a PR or help us with adding your OS to this script. https://github.com/dragoonDorise/EmuDeck/issues"
  exit 1
fi

# this could be replaced to immediately start the EmuDeck setup script

echo "All prerequisite packages have been installed. You're free to install EmuDeck!"
