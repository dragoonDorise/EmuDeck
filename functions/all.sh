#!/bin/bash
if [[ "$EMUDECKGIT" == "" ]]; then
    EMUDECKGIT="$HOME/emudeck/backend"
fi

SETTINGSFILE="$HOME/emudeck/settings.sh"
if [ -f "$SETTINGSFILE" ]; then
    # shellcheck source=./settings.sh
    source "$SETTINGSFILE"
else
    cp "$EMUDECKGIT/settings.sh" "$SETTINGSFILE"
fi

export PATH="${EMUDECKGIT}/tools/binaries/:$PATH"
chmod +x "${EMUDECKGIT}/tools/binaries/xmlstarlet"

source "$EMUDECKGIT"/functions/checkPSBIOS.sh
source "$EMUDECKGIT"/functions/configEmuAI.sh
source "$EMUDECKGIT"/functions/configEmuFP.sh
source "$EMUDECKGIT"/functions/createDesktopIcons.sh
source "$EMUDECKGIT"/functions/helperFunctions.sh
source "$EMUDECKGIT"/functions/installEmuFP.sh
source "$EMUDECKGIT"/functions/setMSG.sh
source "$EMUDECKGIT"/functions/emuDeckPrereqs.sh
source "$EMUDECKGIT"/functions/setSetting.sh
source "$EMUDECKGIT"/functions/linkToSaveFolder.sh
source "$EMUDECKGIT"/functions/installEmuAI.sh
source "$EMUDECKGIT"/functions/getLatestReleaseURLGH.sh
source "$EMUDECKGIT"/functions/migrateAndLinkConfig.sh
source "$EMUDECKGIT"/functions/nonDeck.sh

#toolScripts
source "$EMUDECKGIT"/functions/ToolScripts/emuDeckESDE.sh
source "$EMUDECKGIT"/functions/ToolScripts/emuDeckPlugins.sh
source "$EMUDECKGIT"/functions/ToolScripts/emuDeckSRM.sh
source "$EMUDECKGIT"/functions/ToolScripts/emuDeckCHD.sh
source "$EMUDECKGIT"/functions/ToolScripts/emuDeckBINUP.sh

#emuscripts
source "$EMUDECKGIT"/functions/EmuScripts/emuDeckYuzu.sh
source "$EMUDECKGIT"/functions/EmuScripts/emuDeckCemu.sh
source "$EMUDECKGIT"/functions/EmuScripts/emuDeckPCSX2.sh
source "$EMUDECKGIT"/functions/EmuScripts/emuDeckRPCS3.sh
source "$EMUDECKGIT"/functions/EmuScripts/emuDeckCitra.sh
source "$EMUDECKGIT"/functions/EmuScripts/emuDeckDolphin.sh 
source "$EMUDECKGIT"/functions/EmuScripts/emuDeckPrimehack.sh
source "$EMUDECKGIT"/functions/EmuScripts/emuDeckRetroArch.sh
source "$EMUDECKGIT"/functions/EmuScripts/emuDeckPPSSPP.sh
source "$EMUDECKGIT"/functions/EmuScripts/emuDeckDuckStation.sh
source "$EMUDECKGIT"/functions/EmuScripts/emuDeckXemu.sh
source "$EMUDECKGIT"/functions/EmuScripts/emuDeckXenia.sh

#Soon
#source "$EMUDECKGIT"/EmuScripts/emuDeckMelonDS.sh
#source "$EMUDECKGIT"/EmuScripts/emuDeckMgba.sh
#source "$EMUDECKGIT"/EmuScripts/emuDeckRedream.sh
#source "$EMUDECKGIT"/EmuScripts/emuDeckMAMEProton.sh

