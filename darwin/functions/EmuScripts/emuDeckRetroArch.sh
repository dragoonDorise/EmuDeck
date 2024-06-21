#!/bin/bash
RetroArch_install(){
	darwin_installEmuDMG "${RetroArch_emuName}" "https://buildbot.libretro.com/nightly/apple/osx/universal/RetroArch_Metal.dmg"
	RetroArch_installCores
}

RetroArch_IsInstalled(){
	[ -e '/Applications/RetroArch.app' ] && echo "true" || echo "false"
}

RetroArch_uninstall(){
	rm -rf '/Applications/RetroArch.app'
	rm -rf "$HOME/Applications/EmuDeck/RetroArch.app"
	rm -rf "$toolsPath/launchers/retroarch.sh"
}