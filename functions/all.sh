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

if [[ -z "$emudeckBackend" ]]; then
    emudeckBackend="$HOME/.config/EmuDeck/backend/"
fi

#Vars
source "$emudeckBackend"/vars.sh

#load helpers first, just in case
source "$emudeckBackend"/functions/helperFunctions.sh



SETTINGSFILE="$emudeckFolder/settings.sh"
if [ -f "$SETTINGSFILE" ] &&  [ ! -L "$SETTINGSFILE" ]; then
    # shellcheck source=./settings.sh
    source "$SETTINGSFILE"
else
    source "$HOME/emudeck/settings.sh"
fi

if [ "$system" != "darwin" ]; then
    export PATH="$emudeckBackend/tools/binaries/:$PATH"
    chmod +x "$emudeckBackend/tools/binaries/xmlstarlet"
fi

source "$emudeckBackend"/functions/checkBIOS.sh
source "$emudeckBackend"/functions/checkInstalledEmus.sh
#source "$emudeckBackend"/functions/cloudServicesManager.sh
source "$emudeckBackend"/functions/configEmuAI.sh
source "$emudeckBackend"/functions/configEmuFP.sh
source "$emudeckBackend"/functions/createDesktopIcons.sh
source "$emudeckBackend"/functions/installEmuFP.sh
source "$emudeckBackend"/functions/uninstallEmuFP.sh
source "$emudeckBackend"/functions/setMSG.sh
source "$emudeckBackend"/functions/emuDeckPrereqs.sh
source "$emudeckBackend"/functions/installEmuAI.sh
source "$emudeckBackend"/functions/uninstallEmuAI.sh
source "$emudeckBackend"/functions/installEmuBI.sh
source "$emudeckBackend"/functions/uninstallGeneric.sh
source "$emudeckBackend"/functions/installToolAI.sh
source "$emudeckBackend"/functions/migrateAndLinkConfig.sh
source "$emudeckBackend"/functions/nonDeck.sh
source "$emudeckBackend"/functions/dialogBox.sh
source "$emudeckBackend"/functions/updateEmuFP.sh
source "$emudeckBackend"/functions/createFolders.sh
source "$emudeckBackend"/functions/runSRM.sh
source "$emudeckBackend"/functions/appImageInit.sh
source "$emudeckBackend"/functions/autofix.sh
source "$emudeckBackend"/functions/generateGameLists.sh
source "$emudeckBackend"/functions/jsonToBashVars.sh

#toolScripts
source "$emudeckBackend"/functions/ToolScripts/emuDeckESDE.sh
source "$emudeckBackend"/functions/ToolScripts/emuDeckPegasus.sh
source "$emudeckBackend"/functions/ToolScripts/emuDeckPlugins.sh
source "$emudeckBackend"/functions/ToolScripts/emuDeckSRM.sh
source "$emudeckBackend"/functions/ToolScripts/emuDeckCHD.sh
source "$emudeckBackend"/functions/ToolScripts/emuDeckBINUP.sh
source "$emudeckBackend"/functions/ToolScripts/emuDeckFlatpakUP.sh
source "$emudeckBackend"/functions/ToolScripts/emuDeckCloudBackup.sh
source "$emudeckBackend"/functions/ToolScripts/emuDeckCloudSync.sh
source "$emudeckBackend"/functions/ToolScripts/emuDeckRemotePlayWhatever.sh
source "$emudeckBackend"/functions/ToolScripts/emuDeckInstallHomebrewGames.sh
source "$emudeckBackend"/functions/ToolScripts/emuDeckMigration.sh
source "$emudeckBackend"/functions/ToolScripts/emuDeckCopyGames.sh
source "$emudeckBackend"/functions/ToolScripts/emuDecky.sh
source "$emudeckBackend"/functions/ToolScripts/emuDeckNetPlay.sh
source "$emudeckBackend"/functions/ToolScripts/emuDeckStore.sh

#emuscripts
#source "$emudeckBackend"/functions/EmuScripts/emuDeckSuyu.sh
source "$emudeckBackend"/functions/EmuScripts/emuDeckCitron.sh
source "$emudeckBackend"/functions/EmuScripts/emuDeckYuzu.sh
source "$emudeckBackend"/functions/EmuScripts/emuDeckCemu.sh
source "$emudeckBackend"/functions/EmuScripts/emuDeckCemuProton.sh
source "$emudeckBackend"/functions/EmuScripts/emuDeckRPCS3.sh
source "$emudeckBackend"/functions/EmuScripts/emuDeckCitra.sh
source "$emudeckBackend"/functions/EmuScripts/emuDeckLime3DS.sh
source "$emudeckBackend"/functions/EmuScripts/emuDeckDolphin.sh
source "$emudeckBackend"/functions/EmuScripts/emuDeckPrimehack.sh
source "$emudeckBackend"/functions/EmuScripts/emuDeckRetroArch.sh
source "$emudeckBackend"/functions/EmuScripts/emuDeckRyujinx.sh
source "$emudeckBackend"/functions/EmuScripts/emuDeckShadPS4.sh
source "$emudeckBackend"/functions/EmuScripts/emuDeckPPSSPP.sh
source "$emudeckBackend"/functions/EmuScripts/emuDeckDuckStation.sh
source "$emudeckBackend"/functions/EmuScripts/emuDeckXemu.sh
source "$emudeckBackend"/functions/EmuScripts/emuDeckXenia.sh
source "$emudeckBackend"/functions/EmuScripts/emuDeckPCSX2QT.sh
source "$emudeckBackend"/functions/EmuScripts/emuDeckMAME.sh
source "$emudeckBackend"/functions/EmuScripts/emuDeckScummVM.sh
source "$emudeckBackend"/functions/EmuScripts/emuDeckVita3K.sh
source "$emudeckBackend"/functions/EmuScripts/emuDeckMGBA.sh
source "$emudeckBackend"/functions/EmuScripts/emuDeckRMG.sh
source "$emudeckBackend"/functions/EmuScripts/emuDeckMelonDS.sh
source "$emudeckBackend"/functions/EmuScripts/emuDeckBigPEmu.sh
source "$emudeckBackend"/functions/EmuScripts/emuDeckares.sh
source "$emudeckBackend"/functions/EmuScripts/emuDeckFlycast.sh
source "$emudeckBackend"/functions/EmuScripts/emuDeckSupermodel.sh
source "$emudeckBackend"/functions/EmuScripts/emuDeckModel2.sh


# Generic Application scripts
source "$emudeckBackend"/functions/GenericApplicationsScripts/genericApplicationBottles.sh
source "$emudeckBackend"/functions/GenericApplicationsScripts/genericApplicationCider.sh
source "$emudeckBackend"/functions/GenericApplicationsScripts/genericApplicationFlatseal.sh
source "$emudeckBackend"/functions/GenericApplicationsScripts/genericApplicationHeroic.sh
source "$emudeckBackend"/functions/GenericApplicationsScripts/genericApplicationLutris.sh
source "$emudeckBackend"/functions/GenericApplicationsScripts/genericApplicationPlexamp.sh
source "$emudeckBackend"/functions/GenericApplicationsScripts/genericApplicationSpotify.sh
source "$emudeckBackend"/functions/GenericApplicationsScripts/genericApplicationTidal.sh
source "$emudeckBackend"/functions/GenericApplicationsScripts/genericApplicationWarehouse.sh

#remoteplayclientscripts
source "$emudeckBackend"/functions/RemotePlayClientScripts/remotePlayChiaki.sh
source "$emudeckBackend"/functions/RemotePlayClientScripts/remotePlayChiaking.sh
source "$emudeckBackend"/functions/RemotePlayClientScripts/remotePlayGreenlight.sh
source "$emudeckBackend"/functions/RemotePlayClientScripts/remotePlayMoonlight.sh
source "$emudeckBackend"/functions/RemotePlayClientScripts/remotePlayParsec.sh
source "$emudeckBackend"/functions/RemotePlayClientScripts/remotePlayShadow.sh
source "$emudeckBackend"/functions/RemotePlayClientScripts/remotePlaySteamLink.sh


source "$emudeckBackend"/functions/cloudSyncHealth.sh

source "$emudeckBackend"/android/functions/all.sh

# Darwin overrides
if [ "$system" = "darwin" ]; then
    source "$emudeckBackend/darwin/functions/varsOverrides.sh"
	source "$emudeckBackend/darwin/functions/all.sh"
fi