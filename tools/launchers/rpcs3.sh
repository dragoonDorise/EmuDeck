source $HOME/.config/EmuDeck/backend/functions/all.sh
cloud_sync_downloadEmu "rpcs3" && cloud_sync_startService
/usr/bin/flatpak run net.rpcs3.RPCS3 "${@}"
rm -rf "$savesPath/.gaming"