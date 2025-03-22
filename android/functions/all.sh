#!/bin/bash

# SETTINGSFILEANDROID="$emudeckFolder/android_settings.sh"
# if [ -f "$SETTINGSFILEANDROID" ]; then
# 	# shellcheck source=./settings.sh
# 	source "$SETTINGSFILEANDROID"
# else
# 	cp "$emudeckBackend/android/android_settings.sh" "$SETTINGSFILEANDROID"
# 	source "$emudeckFolder/android_settings.sh"
# fi
source "$emudeckBackend/vars.sh"
source "$emudeckBackend/android/vars.sh"

source "$emudeckBackend"/android/functions/EmuScripts/Android_Yuzu.sh
source "$emudeckBackend"/android/functions/EmuScripts/Android_NetherSX2.sh
source "$emudeckBackend"/android/functions/EmuScripts/Android_Azahar.sh
source "$emudeckBackend"/android/functions/EmuScripts/Android_Dolphin.sh
source "$emudeckBackend"/android/functions/EmuScripts/Android_RetroArch.sh
source "$emudeckBackend"/android/functions/EmuScripts/Android_PPSSPP.sh
source "$emudeckBackend"/android/functions/EmuScripts/Android_ScummVM.sh
source "$emudeckBackend"/android/functions/EmuScripts/Android_Vita3K.sh

source "$emudeckBackend"/android/functions/ToolScripts/Android_ADB.sh
source "$emudeckBackend"/android/functions/ToolScripts/Android_Daijisho.sh
source "$emudeckBackend"/android/functions/ToolScripts/Android_Pegasus.sh

Android_ADB_setPath