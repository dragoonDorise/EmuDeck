#!/bin/bash

checkInstalledEmus(){	

	#Add Emulators that are supposed to be installed 
	if $doInstallRA; then
		emuList+=("RetroArch")
	fi
	if $doInstallDolphin; then
		emuList+=("Dolphin")
	fi
	if $doInstallRPCS3; then
		emuList+=("RPCS3")
	fi
	if $doInstallYuzu; then
		emuList+=("Yuzu")
	fi
	if $doInstallCitra; then
		emuList+=("Citra")
	fi
	if $doInstallDuck; then
		emuList+=("DuckStation")
	fi
	if $doInstallCemu; then
		emuList+=("Cemu")
	fi
	if $doInstallRyujinx; then
		emuList+=("Ryujinx")
	fi
	if $doInstallPrimeHack; then
		emuList+=("Primehack")
	fi
	if $doInstallPPSSPP; then
		emuList+=("PPSSPP")
	fi
	if $doInstallXemu; then
		emuList+=("Xemu")
	fi
	if $doInstallPCSX2QT; then
		emuList+=("PCSX2QT")
	fi
	if $doInstallMAME; then
		emuList+=("MAME")
	fi	
	

	
	errorOnInstall=false
	errosOnInstallDetailed=""
	
	for emu in "${emuList[@]}"
	do
		if ! ${emu}_IsInstalled; then 
			errorOnInstall=true	
			errosOnInstallDetailed+="${emu}\n"
		fi
	done
	
	if $errorOnInstall; then
		text="$(printf "<b>We have found the following emulators were not installed:</b>\n\n ${errosOnInstallDetailed}\n\n You may try again, make sure your Internet Connection is working properly")"
		zenity --error \
		--title="EmuDeck" \
		--width=400 \
		--text="${text}" 2>/dev/null
	fi
}
