#!/bin/bash
if [[ "$EMUDECKGIT" == "" ]]; then
    EMUDECKGIT="$HOME/dragoonDoriseTools/EmuDeck"
fi

if [[ -f "$HOME/emudeck/settings.sh" ]]; then
    source "$HOME/emudeck/settings.sh"
fi

source "$EMUDECKGIT"/functions/checkPSBIOS.sh
source "$EMUDECKGIT"/functions/configEmuAI.sh
source "$EMUDECKGIT"/functions/configEmuFP.sh
source "$EMUDECKGIT"/functions/createDesktopIcons.sh
source "$EMUDECKGIT"/functions/changeLine.sh
source "$EMUDECKGIT"/functions/installEmuFP.sh
source "$EMUDECKGIT"/functions/RAAchievment.sh
source "$EMUDECKGIT"/functions/RAautoSave.sh
source "$EMUDECKGIT"/functions/RABezels.sh
source "$EMUDECKGIT"/functions/RASNES.sh
source "$EMUDECKGIT"/functions/setESDEEmus.sh
source "$EMUDECKGIT"/functions/setMSG.sh
source "$EMUDECKGIT"/functions/setUpHolo.sh
source "$EMUDECKGIT"/functions/setWide.sh
source "$EMUDECKGIT"/functions/testLocationValid.sh
source "$EMUDECKGIT"/functions/setSetting.sh
source "$EMUDECKGIT"/functions/linkToSaveFolder.sh
source "$EMUDECKGIT"/functions/installEmuAI.sh
source "$EMUDECKGIT"/functions/getLatestReleaseURLGH.sh
source "$EMUDECKGIT"/functions/migrateAndLinkConfig.sh

#toolScripts
source "$EMUDECKGIT"/functions/ToolScripts/emuDeckESDE.sh
source "$EMUDECKGIT"/functions/ToolScripts/installPowerTools.sh
source "$EMUDECKGIT"/functions/ToolScripts/emuDeckSRM.sh
source "$EMUDECKGIT"/functions/ToolScripts/installBinUp.sh
source "$EMUDECKGIT"/functions/ToolScripts/installCHD.sh

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



#Soon
#source "$EMUDECKGIT"/EmuScripts/emuDeckXenia.sh
#source "$EMUDECKGIT"/EmuScripts/emuDeckMelonDS.sh
#source "$EMUDECKGIT"/EmuScripts/emuDeckMgba.sh
#source "$EMUDECKGIT"/EmuScripts/emuDeckRedream.sh
#source "$EMUDECKGIT"/EmuScripts/emuDeckMAMEProton.sh

