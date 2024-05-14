#!/bin/bash
RetroArch_install(){
	darwin_installEmuDMG "${RetroArch_emuName}" "https://buildbot.libretro.com/nightly/apple/osx/universal/RetroArch_Metal.dmg"
}

RetroArch_IsInstalled(){
	if [ -f '/Applications/RetroArch.app' ]; then
		echo "true"
	else
		echo "false"
	fi
}