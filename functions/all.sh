#!/bin/bash
appleChip=$(uname -m)
if [ appleChip != "Linux" ]; then
    PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
fi

if [[ "$EMUDECKGIT" == "" ]]; then
    EMUDECKGIT="$HOME/.config/EmuDeck/backend"
fi

#load helpers first, just in case
source "$EMUDECKGIT"/functions/helperFunctions.sh

SETTINGSFILE="$HOME/emudeck/settings.sh"
if [ -f "$SETTINGSFILE" ]; then
    # shellcheck source=./settings.sh
    source "$SETTINGSFILE"
else
    cp "$EMUDECKGIT/settings.sh" "$SETTINGSFILE"
fi

if [ "$system" != "darwin" ]; then
    export PATH="${EMUDECKGIT}/tools/binaries/:$PATH"
fi
chmod +x "${EMUDECKGIT}/tools/binaries/xmlstarlet"

source "$EMUDECKGIT"/functions/checkBIOS.sh
source "$EMUDECKGIT"/functions/checkInstalledEmus.sh
#source "$EMUDECKGIT"/functions/cloudServicesManager.sh
source "$EMUDECKGIT"/functions/configEmuAI.sh
source "$EMUDECKGIT"/functions/configEmuFP.sh
source "$EMUDECKGIT"/functions/createDesktopIcons.sh
source "$EMUDECKGIT"/functions/installEmuFP.sh
source "$EMUDECKGIT"/functions/uninstallEmuFP.sh
source "$EMUDECKGIT"/functions/setMSG.sh
source "$EMUDECKGIT"/functions/emuDeckPrereqs.sh
source "$EMUDECKGIT"/functions/installEmuAI.sh
source "$EMUDECKGIT"/functions/installEmuBI.sh
source "$EMUDECKGIT"/functions/installToolAI.sh
source "$EMUDECKGIT"/functions/migrateAndLinkConfig.sh
source "$EMUDECKGIT"/functions/nonDeck.sh
source "$EMUDECKGIT"/functions/dialogBox.sh
source "$EMUDECKGIT"/functions/updateEmuFP.sh
source "$EMUDECKGIT"/functions/createFolders.sh
source "$EMUDECKGIT"/functions/runSRM.sh
source "$EMUDECKGIT"/functions/appImageInit.sh
source "$EMUDECKGIT"/functions/autofix.sh

#toolScripts
source "$EMUDECKGIT"/functions/ToolScripts/emuDeckESDE.sh
source "$EMUDECKGIT"/functions/ToolScripts/emuDeckPegasus.sh
source "$EMUDECKGIT"/functions/ToolScripts/emuDeckPlugins.sh
source "$EMUDECKGIT"/functions/ToolScripts/emuDeckSRM.sh
source "$EMUDECKGIT"/functions/ToolScripts/emuDeckCHD.sh
source "$EMUDECKGIT"/functions/ToolScripts/emuDeckBINUP.sh
source "$EMUDECKGIT"/functions/ToolScripts/emuDeckCloudBackup.sh
source "$EMUDECKGIT"/functions/ToolScripts/emuDeckCloudSync.sh
source "$EMUDECKGIT"/functions/ToolScripts/emuDeckRemotePlayWhatever.sh
source "$EMUDECKGIT"/functions/ToolScripts/emuDeckInstallHomebrewGames.sh
source "$EMUDECKGIT"/functions/ToolScripts/emuDeckMigration.sh
source "$EMUDECKGIT"/functions/ToolScripts/emuDeckCopyGames.sh
source "$EMUDECKGIT"/functions/ToolScripts/emuDecky.sh


#emuscripts
source "$EMUDECKGIT"/functions/EmuScripts/emuDeckYuzu.sh
source "$EMUDECKGIT"/functions/EmuScripts/emuDeckCemu.sh
source "$EMUDECKGIT"/functions/EmuScripts/emuDeckCemuNative.sh
source "$EMUDECKGIT"/functions/EmuScripts/emuDeckPCSX2.sh
source "$EMUDECKGIT"/functions/EmuScripts/emuDeckRPCS3Legacy.sh
source "$EMUDECKGIT"/functions/EmuScripts/emuDeckCitraLegacy.sh
source "$EMUDECKGIT"/functions/EmuScripts/emuDeckDolphin.sh
source "$EMUDECKGIT"/functions/EmuScripts/emuDeckPrimehack.sh
source "$EMUDECKGIT"/functions/EmuScripts/emuDeckRetroArch.sh
source "$EMUDECKGIT"/functions/EmuScripts/emuDeckRyujinx.sh
source "$EMUDECKGIT"/functions/EmuScripts/emuDeckPPSSPP.sh
source "$EMUDECKGIT"/functions/EmuScripts/emuDeckDuckStation.sh
source "$EMUDECKGIT"/functions/EmuScripts/emuDeckXemu.sh
source "$EMUDECKGIT"/functions/EmuScripts/emuDeckXenia.sh
source "$EMUDECKGIT"/functions/EmuScripts/emuDeckPCSX2QT.sh
source "$EMUDECKGIT"/functions/EmuScripts/emuDeckMAME.sh
source "$EMUDECKGIT"/functions/EmuScripts/emuDeckScummVM.sh
source "$EMUDECKGIT"/functions/EmuScripts/emuDeckVita3K.sh
source "$EMUDECKGIT"/functions/EmuScripts/emuDeckMGBA.sh
source "$EMUDECKGIT"/functions/EmuScripts/emuDeckRMG.sh
source "$EMUDECKGIT"/functions/EmuScripts/emuDeckMelonDS.sh
source "$EMUDECKGIT"/functions/EmuScripts/emuDeckares.sh
source "$EMUDECKGIT"/functions/EmuScripts/emuDeckFlycast.sh

#remoteplayclientscripts
source "$EMUDECKGIT"/functions/RemotePlayClientScripts/remotePlayChiaki.sh
source "$EMUDECKGIT"/functions/RemotePlayClientScripts/remotePlayParsec.sh
source "$EMUDECKGIT"/functions/RemotePlayClientScripts/remotePlayMoonlight.sh
source "$EMUDECKGIT"/functions/RemotePlayClientScripts/remotePlayGreenlight.sh
source "$EMUDECKGIT"/functions/cloudSyncHealth.sh


#Soon
#source "$EMUDECKGIT"/EmuScripts/emuDeckRedream.sh
#source "$EMUDECKGIT"/EmuScripts/emuDeckMAMEProton.sh

# Darwin ovewrites

if [ "$system" = "darwin" ]; then

    source "$EMUDECKGIT/darwin/functions/helperFunctions.sh"
    source "$EMUDECKGIT/darwin/functions/overrides.sh"

fi
