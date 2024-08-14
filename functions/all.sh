#!/bin/bash
appleChip=$(uname -m)
if [ $(uname) != "Linux" ]; then
    system="darwin"
    if [ $appleChip = 'arm64' ]; then
        PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
    else
        PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"
    fi
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
fi

if [ "$system" != "darwin" ]; then
    export PATH="${EMUDECKGIT}/tools/binaries/:$PATH"
    chmod +x "${EMUDECKGIT}/tools/binaries/xmlstarlet"
fi

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
source "$EMUDECKGIT"/functions/uninstallEmuAI.sh
source "$EMUDECKGIT"/functions/installEmuBI.sh
source "$EMUDECKGIT"/functions/uninstallGeneric.sh
source "$EMUDECKGIT"/functions/installToolAI.sh
source "$EMUDECKGIT"/functions/migrateAndLinkConfig.sh
source "$EMUDECKGIT"/functions/nonDeck.sh
source "$EMUDECKGIT"/functions/dialogBox.sh
source "$EMUDECKGIT"/functions/updateEmuFP.sh
source "$EMUDECKGIT"/functions/createFolders.sh
source "$EMUDECKGIT"/functions/runSRM.sh
source "$EMUDECKGIT"/functions/appImageInit.sh
source "$EMUDECKGIT"/functions/autofix.sh
source "$EMUDECKGIT"/functions/generateGameLists.sh
source "$EMUDECKGIT"/functions/jsonToBashVars.sh

#toolScripts
source "$EMUDECKGIT"/functions/ToolScripts/emuDeckESDE.sh
source "$EMUDECKGIT"/functions/ToolScripts/emuDeckPegasus.sh
source "$EMUDECKGIT"/functions/ToolScripts/emuDeckPlugins.sh
source "$EMUDECKGIT"/functions/ToolScripts/emuDeckSRM.sh
source "$EMUDECKGIT"/functions/ToolScripts/emuDeckCHD.sh
source "$EMUDECKGIT"/functions/ToolScripts/emuDeckBINUP.sh
source "$EMUDECKGIT"/functions/ToolScripts/emuDeckFlatpakUP.sh
source "$EMUDECKGIT"/functions/ToolScripts/emuDeckCloudBackup.sh
source "$EMUDECKGIT"/functions/ToolScripts/emuDeckCloudSync.sh
source "$EMUDECKGIT"/functions/ToolScripts/emuDeckRemotePlayWhatever.sh
source "$EMUDECKGIT"/functions/ToolScripts/emuDeckInstallHomebrewGames.sh
source "$EMUDECKGIT"/functions/ToolScripts/emuDeckMigration.sh
source "$EMUDECKGIT"/functions/ToolScripts/emuDeckCopyGames.sh
source "$EMUDECKGIT"/functions/ToolScripts/emuDecky.sh
source "$EMUDECKGIT"/functions/ToolScripts/emuDeckNetPlay.sh


#emuscripts
#source "$EMUDECKGIT"/functions/EmuScripts/emuDeckSuyu.sh
source "$EMUDECKGIT"/functions/EmuScripts/emuDeckYuzu.sh
source "$EMUDECKGIT"/functions/EmuScripts/emuDeckCemu.sh
source "$EMUDECKGIT"/functions/EmuScripts/emuDeckCemuProton.sh
source "$EMUDECKGIT"/functions/EmuScripts/emuDeckRPCS3.sh
source "$EMUDECKGIT"/functions/EmuScripts/emuDeckCitra.sh
source "$EMUDECKGIT"/functions/EmuScripts/emuDeckLime3DS.sh
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
source "$EMUDECKGIT"/functions/EmuScripts/emuDeckBigPEmu.sh
source "$EMUDECKGIT"/functions/EmuScripts/emuDeckares.sh
source "$EMUDECKGIT"/functions/EmuScripts/emuDeckFlycast.sh
source "$EMUDECKGIT"/functions/EmuScripts/emuDeckSupermodel.sh
source "$EMUDECKGIT"/functions/EmuScripts/emuDeckModel2.sh

# Generic Application scripts
source "$EMUDECKGIT"/functions/GenericApplicationsScripts/genericApplicationBottles.sh
source "$EMUDECKGIT"/functions/GenericApplicationsScripts/genericApplicationCider.sh
source "$EMUDECKGIT"/functions/GenericApplicationsScripts/genericApplicationFlatseal.sh
source "$EMUDECKGIT"/functions/GenericApplicationsScripts/genericApplicationHeroic.sh
source "$EMUDECKGIT"/functions/GenericApplicationsScripts/genericApplicationLutris.sh
source "$EMUDECKGIT"/functions/GenericApplicationsScripts/genericApplicationPlexamp.sh
source "$EMUDECKGIT"/functions/GenericApplicationsScripts/genericApplicationSpotify.sh
source "$EMUDECKGIT"/functions/GenericApplicationsScripts/genericApplicationTidal.sh
source "$EMUDECKGIT"/functions/GenericApplicationsScripts/genericApplicationWarehouse.sh

#remoteplayclientscripts
source "$EMUDECKGIT"/functions/RemotePlayClientScripts/remotePlayChiaki.sh
source "$EMUDECKGIT"/functions/RemotePlayClientScripts/remotePlayChiaking.sh
source "$EMUDECKGIT"/functions/RemotePlayClientScripts/remotePlayGreenlight.sh
source "$EMUDECKGIT"/functions/RemotePlayClientScripts/remotePlayMoonlight.sh
source "$EMUDECKGIT"/functions/RemotePlayClientScripts/remotePlayParsec.sh
source "$EMUDECKGIT"/functions/RemotePlayClientScripts/remotePlayShadow.sh
source "$EMUDECKGIT"/functions/RemotePlayClientScripts/remotePlaySteamLink.sh


source "$EMUDECKGIT"/functions/cloudSyncHealth.sh

source "$EMUDECKGIT"/android/functions/all.sh

# Darwin overrides
if [ "$system" = "darwin" ]; then
    source "$EMUDECKGIT/darwin/functions/varsOverrides.sh"
	source "$EMUDECKGIT/darwin/functions/all.sh"
fi