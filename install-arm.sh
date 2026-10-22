#!/usr/bin/env bash

DEBIAN_DEPS=(jq zenity flatpak unzip git rsync curl python3 python-is-python3 p7zip-full libfuse2 libsdl2-2.0-0)
ARCH_DEPS=(jq zenity flatpak unzip git rsync curl python 7zip fuse2 sdl2-compat)
FEDORA_DEPS=(jq zenity flatpak unzip git rsync curl python3 python-unversioned-command 7zip fuse-libs SDL2)
SUSE_DEPS=(jq zenity flatpak unzip git rsync curl python3 7zip libfuse2 libSDL2-2_0-0)
VOID_DEPS=(jq zenity flatpak unzip git rsync curl python3 7zip fuse SDL2)
NIX_DEPS=(jq zenity unzip git rsync curl python3 p7zip)
GENTOO_DEPS=(app-misc/jq gnome-extra/zenity sys-apps/flatpak app-arch/unzip dev-vcs/git net-misc/rsync net-misc/curl dev-lang/python app-arch/7zip sys-fs/fuse:0 media-libs/libsdl2)

RELEASE=""

checkCmd(){ command -v "$1" >/dev/null 2>&1; }

isReadonlyOs(){
    [ "$linuxID" == "SteamOS" ] || [ "$linuxID" == "PlaynixOS" ] || [ "$linuxID" == "ArmadaOS" ] || [ "$linuxID" == "Anatase" ] && return 0
    awk '($2 == "/" || $2 == "/usr") && $4 ~ /(^|,)ro(,|$)/ { found = 1 } END { exit !found }' /proc/mounts 2>/dev/null
}

notify(){
    if checkCmd zenity; then
        zenity --info --title="EmuDeck" --width=450 --text="$1" 2>/dev/null
    else
        echo "$1"
    fi
}

if checkCmd curl; then
    RATE_LIMIT=$(curl -s --max-time 15 https://api.github.com/rate_limit)
    if [ -z "$RATE_LIMIT" ]; then
        notify "EmuDeck can't reach GitHub.\nCheck your internet connection. If it keeps failing, change your DNS to 1.1.1.1 (Cloudflare) and try again."
        exit 1
    fi
    REMAINING=$(echo "$RATE_LIMIT" | grep -o '"remaining": *[0-9]*' | head -n 1 | tr -cd '0-9')
    RESET=$(echo "$RATE_LIMIT" | grep -o '"reset": *[0-9]*' | head -n 1 | tr -cd '0-9')
    if [ "${REMAINING:-1}" -eq 0 ]; then
        WAIT=$(( (RESET - $(date +%s) + 59) / 60 ))
        notify "The GitHub API limit for your IP has been reached, so EmuDeck can't be downloaded right now.\nPlease try again in about $WAIT minutes."
        exit 1
    fi
fi

CPU_ARCH="x86"
if [ "$(uname -m)" = "aarch64" ] || [ "$(uname -m)" = "arm64" ]; then
    CPU_ARCH="arm"
fi


if [ -r /etc/os-release ] && grep -Eq '^ID="?armada"?$' /etc/os-release; then
    linuxID="ArmadaOS"
elif [ -e /usr/lib/armada/version ]; then
    linuxID="ArmadaOS"
elif [ "$(cat /etc/hostname)" = "playnix" ]; then
    linuxID="PlaynixOS"
else
    if command -v lsb_release >/dev/null 2>&1; then
        linuxID=$(lsb_release -si)
    elif [ -r /etc/os-release ]; then
        linuxID=$(. /etc/os-release && printf '%s' "${NAME%% *}")
    else
        linuxID="Unknown"
    fi
fi

sandbox=""

if [ "$linuxID" = "Ubuntu" ]; then
    sandbox="--no-sandbox"
fi

if command -v apt-get >/dev/null; then
    PKG_MGR="apt"
    if apt-cache show libfuse2t64 >/dev/null 2>&1; then
        DEBIAN_DEPS=("${DEBIAN_DEPS[@]/libfuse2/libfuse2t64}")
    fi
    DEPS=("${DEBIAN_DEPS[@]}")
    isInstalled(){ dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q "install ok installed"; }
    installPkg(){ sudo apt-get -y install "$1"; }
elif command -v pacman >/dev/null; then
    PKG_MGR="pacman"
    DEPS=("${ARCH_DEPS[@]}")
    isInstalled(){ pacman -Qq "$1" >/dev/null 2>&1; }
    installPkg(){ sudo pacman --noconfirm -S --needed "$1"; }
elif command -v rpm-ostree >/dev/null; then
    PKG_MGR="rpm-ostree"
    DEPS=("${FEDORA_DEPS[@]}")
    isInstalled(){ rpm -q "$1" >/dev/null 2>&1; }
    installPkg(){ sudo rpm-ostree install --idempotent "$1"; }
elif command -v dnf >/dev/null; then
    PKG_MGR="dnf"
    DEPS=("${FEDORA_DEPS[@]}")
    isInstalled(){ rpm -q "$1" >/dev/null 2>&1; }
    installPkg(){ sudo dnf -y install "$1"; }
elif command -v zypper >/dev/null; then
    PKG_MGR="zypper"
    DEPS=("${SUSE_DEPS[@]}")
    isInstalled(){ rpm -q "$1" >/dev/null 2>&1; }
    installPkg(){ sudo zypper --non-interactive install "$1"; }
elif command -v xbps-install >/dev/null; then
    PKG_MGR="xbps"
    DEPS=("${VOID_DEPS[@]}")
    isInstalled(){ xbps-query "$1" >/dev/null 2>&1; }
    installPkg(){ sudo xbps-install -y "$1"; }
elif command -v emerge >/dev/null; then
    PKG_MGR="emerge"
    DEPS=("${GENTOO_DEPS[@]}")
    isInstalled(){ ls -d "/var/db/pkg/${1%%:*}"-[0-9]* >/dev/null 2>&1; }
    installPkg(){ sudo emerge -n "$1"; }
elif [ -e /etc/NIXOS ] || command -v nix-env >/dev/null; then
    PKG_MGR="nix"
    DEPS=("${NIX_DEPS[@]}")
    isInstalled(){ case "$1" in p7zip) checkCmd 7z ;; *) checkCmd "$1" ;; esac; }
    installPkg(){ nix-env -iA "nixos.$1" 2>/dev/null || nix-env -iA "nixpkgs.$1"; }
else
    PKG_MGR=""
    DEPS=()
fi

MISSING=()
for pkg in "${DEPS[@]}"; do
    isInstalled "$pkg" || MISSING+=("$pkg")
done

if [ -z "$PKG_MGR" ]; then
    echo "Package manager not detected on $linuxID, skipping dependency check. Make sure you have: ${DEBIAN_DEPS[*]}"
elif [ "${#MISSING[@]}" -eq 0 ]; then
    echo "All dependencies are already installed"
elif [ "$PKG_MGR" != "rpm-ostree" ] && isReadonlyOs; then
    echo "Missing dependencies on $linuxID (read-only system, skipping): ${MISSING[*]}"
else
    echo "Missing dependencies: ${MISSING[*]}"

    if [ "$PKG_MGR" == "nix" ]; then
        :
    elif checkCmd zenity; then
        read -r PASSWD <<< "$(zenity --password --title="Password Entry" --text="EmuDeck needs to install: ${MISSING[*]}\nEnter your sudo password" 2>/dev/null)"
        echo "$PASSWD" | sudo -v -S
        if [ $? -ne 0 ]; then
            read -r PASSWD <<< "$(zenity --password --title="Password Entry" --text="Password was incorrect. Try again. (Did you remember to set a password for linux before running this?)" 2>/dev/null)"
            echo "$PASSWD" | sudo -v -S
        fi
    else
        sudo -v
    fi

    case "$PKG_MGR" in
        apt)    sudo apt-get -y update ;;
        pacman) sudo pacman --noconfirm -Sy ;;
        xbps)   sudo xbps-install -S ;;
    esac

    for pkg in "${MISSING[@]}"; do
        echo "Installing $pkg"
        installPkg "$pkg" || echo "Could not install $pkg"
    done

    MISSING=()
    for pkg in "${DEPS[@]}"; do
        isInstalled "$pkg" || MISSING+=("$pkg")
    done
    if [ "${#MISSING[@]}" -gt 0 ]; then
        notify "These dependencies could not be installed: ${MISSING[*]}\nEmuDeck will continue, but some features may not work until you install them."
    else
        echo "All dependencies installed"
    fi
fi

if [ "$PKG_MGR" == "nix" ]; then
    NIX_MISSING=""
    checkCmd steam   || NIX_MISSING="$NIX_MISSING\n  programs.steam.enable = true;"
    checkCmd flatpak || NIX_MISSING="$NIX_MISSING\n  services.flatpak.enable = true;"
    if [ -z "$NIX_LD" ] && [ ! -e /run/current-system/sw/share/nix-ld/lib/ld.so ]; then
        NIX_MISSING="$NIX_MISSING\n  programs.nix-ld.enable = true;"
    fi
    if [ -n "$NIX_MISSING" ]; then
        notify "EmuDeck needs these options in your /etc/nixos/configuration.nix:\n$NIX_MISSING\n\nAdd them, run 'sudo nixos-rebuild switch', reboot and launch this installer again."
        exit 1
    fi
elif ! checkCmd steam; then
    notify "Steam was not found on this system.\nEmuDeck needs the native Steam client (the Flatpak version is not supported) to add games and emulators to your library, please install it."
fi

set -eo pipefail

reportError() {
    FAILURE="$(caller): ${BASH_COMMAND}"
    echo "Something went wrong!"
    echo "Error at ${FAILURE}"
}

trap reportError ERR

EMUDECK_GITHUB_URL="https://api.github.com/repos/EmuDeck/emudeck-electron${RELEASE}/releases/latest"
if [ "$CPU_ARCH" == "arm" ]; then
    EMUDECK_URL="$(curl -s "$EMUDECK_GITHUB_URL" | grep -E 'browser_download_url.*arm64\.AppImage' | cut -d '"' -f 4)" || true
else
    EMUDECK_URL="$(curl -s "$EMUDECK_GITHUB_URL" | grep -E 'browser_download_url.*\.AppImage' | grep -v 'arm64' | cut -d '"' -f 4)" || true
fi

if [ -z "$EMUDECK_URL" ]; then
    notify "Could not get the EmuDeck download link from GitHub.\nCheck your internet connection. If it keeps failing, change your DNS to 1.1.1.1 (Cloudflare) and try again."
    exit 1
fi

mkdir -p ~/Applications
rm -f ~/Applications/EmuDeck.AppImage.part
curl -fL "${EMUDECK_URL}" -o ~/Applications/EmuDeck.AppImage.part 2>&1 | stdbuf -oL tr '\r' '\n' | sed -u 's/^ *\([0-9][0-9]*\).*\( [0-9].*$\)/\1\n#Download Speed\:\2/' | zenity --progress --title "Downloading EmuDeck" --width 600 --auto-close --no-cancel 2>/dev/null || true
if [ ! -s ~/Applications/EmuDeck.AppImage.part ]; then
    rm -f ~/Applications/EmuDeck.AppImage.part
    notify "The EmuDeck download failed.\nCheck your internet connection. If it keeps failing, change your DNS to 1.1.1.1 (Cloudflare) and try again."
    exit 1
fi
mv -f ~/Applications/EmuDeck.AppImage.part ~/Applications/EmuDeck.AppImage
chmod +x ~/Applications/EmuDeck.AppImage
ozone=""
if [ "$XDG_SESSION_TYPE" = "wayland" ] || [ -n "$WAYLAND_DISPLAY" ]; then
    ozone="--ozone-platform=x11"
fi
~/Applications/EmuDeck.AppImage $sandbox $ozone
exit
