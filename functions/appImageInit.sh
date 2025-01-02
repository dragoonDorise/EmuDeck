#!/bin/bash
appImageInit() {

	#Migrate emudeck folder

	if [ -f "$HOME/emudeck/settings.sh" ] &&  [ ! -L "$HOME/emudeck/settings.sh" ]; then
		# We move good old emudeck folder to .config
		rsync -avh "$HOME/emudeck/" "$emudeckFolder" && rm -rf "$HOME/emudeck" && mkdir "$HOME/emudeck" && ln -s "$emudeckFolder/settings.sh" "$HOME/emudeck/settings.sh"


		#Migrate AppImages to .config
# 		mkdir -p $emusFolder
# 		mv -f $HOME/Applications/publish $emusFolder/publish
# 		mv -f $HOME/Applications/Vita3K $emusFolder/Vita3K
# 		mv -f $HOME/Applications/BigPEmu $emusFolder/BigPEmu
# 		mv -f $HOME/Applications/Cemu.AppImage $emusFolder/Cemu.AppImage
# 		mv -f $HOME/Applications/citra-qt.AppImage $emusFolder/citra-qt.AppImage
# 		mv -f $HOME/Applications/EmuDeck.AppImage $emusFolder/EmuDeck.AppImage
# 		mv -f $HOME/Applications/lime3ds-gui.AppImage $emusFolder/lime3ds-gui.AppImage
#
# 		mv -f $HOME/Applications/pcsx2-Qt.AppImage $emusFolder/pcsx2-Qt.AppImage
# 		mv -f $HOME/Applications/pegasus-fe $emusFolder/pegasus-fe
# 		mv -f $HOME/Applications/rpcs3.AppImage $emusFolder/rpcs3.AppImage
# 		mv -f $HOME/Applications/Shadps4-qt.AppImage $emusFolder/Shadps4-qt.AppImage
#
# 		mkdir -p $esdeFolder
# 		mv -f $HOME/Applications/ES-DE.AppImage $esdeFolder/ES-DE.AppImage
#
# 		mkdir -p $pegasusPath
# 		mv -f $HOME/Applications/pegasus-fe $pegasusFolder/pegasus-fe

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
		rsync -avhp --mkpath "$emudeckBackend/chimeraOS/configs/emulationstation/custom_systems/es_find_rules.xml" "$(dirname "$es_rulesFile")" --backup --suffix=.bak
		sed -i "s|/run/media/mmcblk0p1/Emulation|${emulationPath}|g" "$es_rulesFile"


	fi


	# Init functions
	mkdir -p "$emudeckLogs"
	mkdir -p "$emudeckFolder/feeds"

}
