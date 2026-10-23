#!/usr/bin/env bash

checkInstalledEmus(){

	#Add Emulators that are supposed to be installed
	if [ "$doInstallRA" == "true" ]; then
		emuList+=("RetroArch")
	fi
	if [ "$doInstallDolphin" == "true" ]; then
		emuList+=("Dolphin")
	fi
	if [ "$doInstallRPCS3" == "true" ]; then
		emuList+=("RPCS3")
	fi
	if [ "$doInstallDuck" == "true" ]; then
		emuList+=("DuckStation")
	fi
	if [ "$doInstallCemu" == "true" ]; then
		emuList+=("Cemu")
	fi
	if [ "$doInstallRyujinx" == "true" ]; then
		emuList+=("Ryujinx")
	fi
	if [ "$doInstallPrimeHack" == "true" ]; then
		emuList+=("Primehack")
	fi
	if [ "$doInstallPPSSPP" == "true" ]; then
		emuList+=("PPSSPP")
	fi
	if [ "$doInstallXemu" == "true" ]; then
		emuList+=("Xemu")
	fi
	if [ "$doInstallPCSX2QT" == "true" ]; then
		emuList+=("PCSX2QT")
	fi
	if [ "$doInstallMAME" == "true" ]; then
		emuList+=("MAME")
	fi
	if [ "$doInstallAzahar" == "true" ]; then
		emuList+=("Azahar")
	fi
	if [ "$doInstallRMG" == "true" ]; then
		emuList+=("RMG")
	fi
	if [ "$doInstallScummVM" == "true" ]; then
		emuList+=("ScummVM")
	fi
	if [ "$doInstallVita3K" == "true" ]; then
		emuList+=("Vita3K")
	fi
	if [ "$doInstallMGBA" == "true" ]; then
		emuList+=("mGBA")
	fi
	if [ "$doInstallFlycast" == "true" ]; then
		emuList+=("Flycast")
	fi
	if [ "$doInstallmelonDS" == "true" ]; then
		emuList+=("melonDS")
	fi
	if [ "$doInstallBigPEmu" == "true" ]; then
		emuList+=("BigPEmu")
	fi
	if [ "$doInstallSupermodel" == "true" ]; then
		emuList+=("Supermodel")
	fi
	if [ "$doInstallXenia" == "true" ]; then
		emuList+=("Xenia")
	fi
	if [ "$doInstallModel2" == "true" ]; then
		emuList+=("Model2")
	fi
	if [ "$doInstallShadPS4" == "true" ]; then
		emuList+=("ShadPS4")
	fi



	errorOnInstall=false
	errosOnInstallDetailed=""

	for emu in "${emuList[@]}"
	do
		# _IsInstalled prints true/false and always returns 0
		if [ "$(${emu}_IsInstalled)" != "true" ]; then
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
