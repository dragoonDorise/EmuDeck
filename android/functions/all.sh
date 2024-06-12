#!/bin/bash

# SETTINGSFILEANDROID="$HOME/emudeck/android_settings.sh"
# if [ -f "$SETTINGSFILEANDROID" ]; then
# 	# shellcheck source=./settings.sh
# 	source "$SETTINGSFILEANDROID"
# else
# 	cp "$EMUDECKGIT/android/android_settings.sh" "$SETTINGSFILEANDROID"
# 	source "$HOME/emudeck/android_settings.sh"
# fi
source "$EMUDECKGIT/android/vars.sh"

source "$EMUDECKGIT"/android/functions/EmuScripts/Android_Yuzu.sh
source "$EMUDECKGIT"/android/functions/EmuScripts/Android_NetherSX2.sh
source "$EMUDECKGIT"/android/functions/EmuScripts/Android_Lime3DS.sh
source "$EMUDECKGIT"/android/functions/EmuScripts/Android_Dolphin.sh
source "$EMUDECKGIT"/android/functions/EmuScripts/Android_RetroArch.sh
source "$EMUDECKGIT"/android/functions/EmuScripts/Android_PPSSPP.sh
source "$EMUDECKGIT"/android/functions/EmuScripts/Android_ScummVM.sh
source "$EMUDECKGIT"/android/functions/EmuScripts/Android_Vita3K.sh

source "$EMUDECKGIT"/android/functions/ToolScripts/Android_ADB.sh
source "$EMUDECKGIT"/android/functions/ToolScripts/Android_Daijisho.sh
source "$EMUDECKGIT"/android/functions/ToolScripts/Android_Pegasus.sh

Android_ADB_setPath