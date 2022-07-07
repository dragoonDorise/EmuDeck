#!/bin/bash
if [[ "$EMUDECKGIT" == "" ]]; then
    EMUDECKGIT="$HOME/dragoonDoriseTools/Emudeck"
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
source "$EMUDECKGIT"/ToolScripts/emuDeckESDE.sh
source "$EMUDECKGIT"/ToolScripts/configSRM.sh
source "$EMUDECKGIT"/ToolScripts/installPowerTools.sh
source "$EMUDECKGIT"/ToolScripts/installSRM.sh
source "$EMUDECKGIT"/ToolScripts/installBinUp.sh
source "$EMUDECKGIT"/ToolScripts/installCHD.sh

#emuscripts
source "$EMUDECKGIT"/EmuScripts/emuDeckYuzu.sh
source "$EMUDECKGIT"/EmuScripts/emuDeckCemu.sh
source "$EMUDECKGIT"/EmuScripts/emuDeckPCSX2.sh
source "$EMUDECKGIT"/EmuScripts/emuDeckRPCS3.sh
source "$EMUDECKGIT"/EmuScripts/emuDeckCitra.sh
source "$EMUDECKGIT"/EmuScripts/emuDeckDolphin.sh 
source "$EMUDECKGIT"/EmuScripts/emuDeckPrimehack.sh
source "$EMUDECKGIT"/EmuScripts/emuDeckRetroArch.sh
source "$EMUDECKGIT"/EmuScripts/emuDeckPPSSPP.sh
source "$EMUDECKGIT"/EmuScripts/emuDeckDuckStation.sh
source "$EMUDECKGIT"/EmuScripts/emuDeckXemu.sh



#Soon
#source "$EMUDECKGIT"/EmuScripts/emuDeckXenia.sh
#source "$EMUDECKGIT"/EmuScripts/emuDeckMelonDS.sh
#source "$EMUDECKGIT"/EmuScripts/emuDeckMgba.sh
#source "$EMUDECKGIT"/EmuScripts/emuDeckRedream.sh
#source "$EMUDECKGIT"/EmuScripts/emuDeckMAMEProton.sh

