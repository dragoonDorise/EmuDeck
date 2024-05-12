#!/bin/bash
appImageInit() {

	if [ "$system" == "chimeraos" ]; then
		ESDE_chimeraOS
		mkdir -p $HOME/Applications

		downloads_dir="$HOME/Downloads"
		destination_dir="$HOME/Applications"
		file_name="EmuDeck"

		find "$downloads_dir" -type f -name "*$file_name*.AppImage" -exec mv {} "$destination_dir/$file_name.AppImage" \;

	fi

	#Autofixes, put here functions that make under the hood fixes.
	autofix_duplicateESDE
	autofix_lnk
	SRM_migration # 2.2 Changes

	if [ ! -f "$HOME/.config/EmuDeck/.launcherupdate" ]; then

		zenity --question \
		--text="A hotfix was pushed to fix ROMs launching into the emulator instead of the ROM directly.\nApplying this hotfix will reset any modifications you have made to the launchers in Emulation/tools/launchers. If you say no to this prompt, you may also apply this fix at any time by resetting an emulator on the Manage Emulators page.\nWould you like to apply this hotfix?" \
		--title="Launcher updates" \
		--width=400 \
		--height=300

		if [ $? = 0 ]; then
			if [ "$(ares_IsInstalled)" == "true" ]; then
				#echo "NYI"
				ares_flushEmulatorLauncher
			fi

			if [ "$(BigPEmu_IsInstalled)" == "true" ]; then
				#echo "NYI"
				BigPEmu_flushEmulatorLauncher
			fi

			if [ "$(Cemu_IsInstalled)" == "true" ]; then
				#echo "NYI"
				Cemu_flushEmulatorLauncher
			fi

			if [ "$(CemuProton_IsInstalled)" == "true" ]; then
				#echo "NYI"
				CemuProton_flushEmulatorLauncher
			fi

			if [ "$(Citra_IsInstalled)" == "true" ]; then
				#echo "NYI"
				Citra_flushEmulatorLauncher
			fi

			if [ "$(Dolphin_IsInstalled)" == "true" ]; then
				#echo "NYI"
				Dolphin_flushEmulatorLauncher
			fi

			if [ "$(DuckStation_IsInstalled)" == "true" ]; then
				#echo "NYI"
				DuckStation_flushEmulatorLauncher
			fi

			if [ "$(Flycast_IsInstalled)" == "true" ]; then
				#echo "NYI"
				Flycast_flushEmulatorLauncher
			fi

			if [ "$(MAME_IsInstalled)" == "true" ]; then
				#echo "NYI"
				MAME_flushEmulatorLauncher
			fi

			if [ "$(melonDS_IsInstalled)" == "true" ]; then
				#echo "NYI"
				melonDS_flushEmulatorLauncher
			fi

			if [ "$(mGBA_IsInstalled)" == "true" ]; then
				#echo "NYI"
				mGBA_flushEmulatorLauncher
			fi

			if [ "$(Model2_IsInstalled)" == "true" ]; then
				#echo "NYI"
				Model2_flushEmulatorLauncher
			fi

			if [ "$(PCSX2QT_IsInstalled)" == "true" ]; then
				#echo "NYI"
				PCSX2QT_flushEmulatorLauncher
			fi

			if [ "$(PPSSPP_IsInstalled)" == "true" ]; then
				#echo "NYI"
				PPSSPP_flushEmulatorLauncher
			fi

			if [ "$(Primehack_IsInstalled)" == "true" ]; then
				#echo "NYI"
				Primehack_flushEmulatorLauncher
			fi

			if [ "$(RetroArch_IsInstalled)" == "true" ]; then
				#echo "NYI"
				RetroArch_flushEmulatorLauncher
			fi

			if [ "$(RMG_IsInstalled)" == "true" ]; then
				#echo "NYI"
				RMG_flushEmulatorLauncher
			fi

			if [ "$(RPCS3_IsInstalled)" == "true" ]; then
				#echo "NYI"
				RPCS3_flushEmulatorLauncher
			fi

			if [ "$(Supermodel_IsInstalled)" == "true" ]; then
				#echo "NYI"
				Supermodel_flushEmulatorLauncher
			fi

			if [ "$(Vita3K_IsInstalled)" == "true" ]; then
				#echo "NYI"
				Vita3K_flushEmulatorLauncher
			fi

			if [ "$(Xemu_IsInstalled)" == "true" ]; then
				#echo "NYI"
				Xemu_flushEmulatorLauncher
			fi

			#Xenia temp fix
			if [ "$(Xenia_IsInstalled)" == "true" ]; then
				#echo "NYI"
				Xenia_flushEmulatorLauncher
			fi

			if [ "$(Yuzu_IsInstalled)" == "true" ]; then
				#echo "NYI"
				Yuzu_flushEmulatorLauncher
			fi
		else 
			echo "Do not apply hotfix."
		fi	
	touch "$HOME/.config/EmuDeck/.launcherupdate"
	fi

	if [ ! -f "$HOME/.config/EmuDeck/.esdeupdateyuzu" ]; then

		zenity --question \
		--text="An upcoming ES-DE update will be removing Yuzu support. This means that you will no longer be able to launch Nintendo Switch games using Yuzu in ES-DE. \nHowever, EmuDeck has pushed a hotfix to add back Yuzu support for ES-DE. \nIf you say no to this prompt, you may also apply this fix at any time by resetting ES-DE or Yuzu on the Manage Emulators page. \nWould you like to apply this hotfix?" \
		--title="ES-DE Update" \
		--width=400 \
		--height=300

		if [ $? = 0 ]; then

			if [ -e "$ESDE_toolPath" ]; then
				ESDE_junksettingsFile
				ESDE_addCustomSystemsFile
				Yuzu_addESConfig
			else
				echo "ES-DE not found. Skipped adding custom system."
			fi
			
		else 
			echo "Do not apply hotfix."
		fi
	touch "$HOME/.config/EmuDeck/.esdeupdateyuzu"
	fi

	if [ ! -f "$HOME/.config/EmuDeck/.esdefixupdateyuzu" ] && [ -f "$HOME/ES-DE/custom_systems" ]; then

		zenity --info --text="If you are seeing this pop-up, that means the ES-DE hotfix for Yuzu did not properly apply to your system. Press OK below to proceed to the next pop-up so you may re-apply the hotfix."
		--title="ES-DE" \
		--width=400 \
		--height=300
		
		zenity --question \
		--text="An upcoming ES-DE update will be removing Yuzu support. This means that you will no longer be able to launch Nintendo Switch games using Yuzu in ES-DE. \nHowever, EmuDeck has pushed a hotfix to add back Yuzu support for ES-DE. \nIf you say no to this prompt, you may also apply this fix at any time by resetting ES-DE or Yuzu on the Manage Emulators page. \nWould you like to apply this hotfix?" \
		--title="ES-DE Update" \
		--width=400 \
		--height=300

		if [ $? = 0 ]; then

			if [ -e "$ESDE_toolPath" ]; then
				ESDE_junksettingsFile
				ESDE_addCustomSystemsFile
				Yuzu_addESConfig
			else
				echo "ES-DE not found. Skipped adding custom system."
			fi
			
		else 
			echo "Do not apply hotfix."
		fi
	touch "$HOME/.config/EmuDeck/.esdefixupdateyuzu"
	fi

	# This is intended so users can get the latest launcher with proper fall-back detection. This does not reset any of Steam ROM Manager's configs and only updates the launcher once. 
	if [ ! -f "$HOME/.config/EmuDeck/.srmlauncherupdate" ]; then
		SRM_flushToolLauncher
		touch "$HOME/.config/EmuDeck/.srmlauncherupdate"
	fi 


	# Init functions
	mkdir -p "$HOME/emudeck/logs"
	mkdir -p "$HOME/emudeck/feeds"

}
