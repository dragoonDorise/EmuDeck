#!/bin/sh
## Config
PROTONVERSION='Proton - Experimental'
# App Path
APPPATH="/run/media/mmcblk0p1/Emulation/roms/xbox360"
# Steam Path
STEAMPATH="${HOME}/.local/share/Steam"
# Proton Path
PROTON="${STEAMPATH}/steamapps/common/${PROTONVERSION}/proton"
# Prefix
PFX="${STEAMPATH}/steamapps/compatdata/pfx"
# AppID
APPID=0

# Set environment variables
set_env() {
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
cd $apppath
# Main
set_env
python "${PROTON}" waitforexitandrun "${APPPATH}/xenia.exe" "${@}"
