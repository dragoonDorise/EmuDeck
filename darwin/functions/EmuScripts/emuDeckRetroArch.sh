#!/bin/bash
RetroArch_install(){
	darwin_installEmuDMG "${RetroArch_emuName}" "https://buildbot.libretro.com/nightly/apple/osx/universal/RetroArch_Metal.dmg"
}

RetroArch_IsInstalled(){
	[ -d '/Applications/RetroArch.app' ] && echo "true" || echo "false"
}