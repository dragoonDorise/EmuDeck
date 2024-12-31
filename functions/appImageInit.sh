#!/bin/bash
appImageInit() {

	#Migrate emudeck folder
	if [ -d "$HOME/emudeck/logs" ]; then

		# We move good old emudeck folder to .config
		rsync -avh "$HOME/emudeck" "$HOME/.config/EmuDeck" && rm -rf "$HOME/emudeck" && mkdir "$HOME/emudeck" && ln -s "$HOME/.config/EmuDeck/settings.sh" "$HOME/emudeck/settings.sh"


		#Migrate AppImages to .config
		mkdir -p $HOME/.config/Emulators
		move $HOME/Applications/publish $HOME/.config/Emulators/publish
		move $HOME/Applications/Vita3K $HOME/.config/Emulators/Vita3K
		move $HOME/Applications/Cemu.AppImage $HOME/.config/Emulators/Cemu.AppImage
		move $HOME/Applications/citra-qt.AppImage $HOME/.config/Emulators/citra-qt.AppImage
		move $HOME/Applications/EmuDeck.AppImage $HOME/.config/Emulators/EmuDeck.AppImage
		move $HOME/Applications/ES-DE.AppImage $HOME/.config/Emulators/ES-DE.AppImage
		move $HOME/Applications/pcsx2-Qt.AppImage $HOME/.config/Emulators/pcsx2-Qt.AppImage
		move $HOME/Applications/pegasus-fe $HOME/.config/Emulators/pegasus-fe
		move $HOME/Applications/rpcs3.AppImage $HOME/.config/Emulators/rpcs3.AppImage
		move $HOME/Applications/Shadps4-qt.AppImage $HOME/.config/Emulators/Shadps4-qt.AppImage

		#Fix paths shortcuts
		if [ $doInstallESDE == "true" ]; then
			ESDE_flushToolLauncher
		fi
		if [ $doInstallPegasus == "true" ]; then
			pegasus_flushToolLauncher
		fi
		if [ $doInstallSRM == "true" ]; then
			SRM_flushToolLauncher
		fi
		if [ "$doInstallPCSX2QT" == "true" ]; then
			PCSX2QT_flushEmulatorLauncher
		fi
		if [ $doInstallPrimeHack == "true" ]; then
			Primehack_flushEmulatorLauncher
		fi
		if [ $doInstallRPCS3 == "true" ]; then
			RPCS3_flushEmulatorLauncher
		fi
		if [ $doInstallCitra == "true" ]; then
			Citra_flushEmulatorLauncher
		fi
		if [ $doInstallLime3DS == "true" ]; then
			Lime3DS_flushEmulatorLauncher
		fi
		if [ $doInstallDolphin == "true" ]; then
			Dolphin_flushEmulatorLauncher
		fi
		if [ $doInstallDuck == "true" ]; then
			DuckStation_flushEmulatorLauncher
		fi
		if [ $doInstallRA == "true" ]; then
			RetroArch_flushEmulatorLauncher
		fi
		if [ $doInstallRMG == "true" ]; then
			RMG_flushEmulatorLauncher
		fi
		if [ $doInstallares == "true" ]; then
			ares_flushEmulatorLauncher
		fi
		if [ $doInstallPPSSPP == "true" ]; then
			PPSSPP_flushEmulatorLauncher
		fi
		if [ $doInstallYuzu == "true" ]; then
			Yuzu_flushEmulatorLauncher
		fi
		if [ $doInstallSuyu == "true" ]; then
			suyu_flushEmulatorLauncher
		fi
		if [ $doInstallRyujinx == "true" ]; then
			Ryujinx_flushEmulatorLauncher
		fi
		if [ $doInstallMAME == "true" ]; then
			MAME_flushEmulatorLauncher
		fi
		if [ $doInstallXemu == "true" ]; then
			Xemu_flushEmulatorLauncher
		fi
		if [ $doInstallCemu == "true" ]; then
			Cemu_flushEmulatorLauncher
		fi
		if [ "${doInstallCemuNative}" == "true" ]; then
			CemuNative_flushEmulatorLauncher
		fi
		if [ $doInstallScummVM == "true" ]; then
			ScummVM_flushEmulatorLauncher
		fi
		if [ $doInstallVita3K == "true" ]; then
			Vita3K_flushEmulatorLauncher
		fi
		if [ $doInstallMGBA == "true" ]; then
			mGBA_flushEmulatorLauncher
		fi
		if [ $doInstallFlycast == "true" ]; then
			Flycast_flushEmulatorLauncher
		fi
		if [ $doInstallRMG == "true" ]; then
			RMG_flushEmulatorLauncher
		fi
		if [ $doInstallares == "true" ]; then
			ares_flushEmulatorLauncher
		fi
		if [ $doInstallmelonDS == "true" ]; then
			melonDS_flushEmulatorLauncher
		fi
		if [ $doInstallBigPEmu == "true" ]; then
			BigPEmu_flushEmulatorLauncher
		fi
		if [ $doInstallSupermodel == "true" ]; then
			Supermodel_flushEmulatorLauncher
		fi
		if [ "$doInstallXenia" == "true" ]; then
			Xenia_flushEmulatorLauncher
		fi
		if [ "$doInstallModel2" == "true" ]; then
			Model2_flushEmulatorLauncher
		fi

		if [ "$doInstallShadPS4" == "true" ]; then
			ShadPS4_flushEmulatorLauncher
		fi

		#Add Emus launchers to ESDE
		rsync -avhp --mkpath "$EMUDECKGIT/chimeraOS/configs/emulationstation/custom_systems/es_find_rules.xml" "$(dirname "$es_rulesFile")" --backup --suffix=.bak
		sed -i "s|/run/media/mmcblk0p1/Emulation|${emulationPath}|g" "$es_rulesFile"


	fi


	# Init functions
	mkdir -p "$HOME/.config/EmuDeck/logs"
	mkdir -p "$HOME/.config/EmuDeck/feeds"

}
