#!/bin/bash

#load helpers first, just in case
source "$EMUDECKGIT/functions/helperFunctions.sh"
source "$EMUDECKGIT/darwin/functions/helperFunctionsOverrides.sh"


source "$EMUDECKGIT/darwin/functions/configEmuFP.sh"
source "$EMUDECKGIT/darwin/functions/helperFunctions.sh"
source "$EMUDECKGIT/darwin/functions/installEmuAI.sh"
source "$EMUDECKGIT/darwin/functions/installToolAI.sh"
source "$EMUDECKGIT/darwin/functions/varsOverrides.sh"

#emuscripts
source "$EMUDECKGIT/darwin/functions/EmuScripts/emuDeckRetroArch.sh"


#toolScripts
source "$EMUDECKGIT/darwin/functions/ToolsScripts/emuDeckCloudSync.sh"
source "$EMUDECKGIT/darwin/functions/ToolsScripts/emuDeckESDE.sh"
source "$EMUDECKGIT/darwin/functions/ToolsScripts/emuDeckPegasus.sh"
source "$EMUDECKGIT/darwin/functions/ToolsScripts/emuDeckSRM.sh"