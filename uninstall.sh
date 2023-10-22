#!/bin/bash
source "$HOME/.config/EmuDeck/backend/functions/all.sh"

doUninstall=false
doUninstallares=true
doUninstallCemu=true
doUninstallCemuNative=true
doUninstallCitra=true
doUninstallDolphin=true
doUninstallDuck=true
doUninstallESDE=true
doUninstallFlycast=true
doUninstallMame=true
doUninstallmelonDS=true
doUninstallMGBA=true
doUninstallRA=true
doUninstallPCSX2=true
doUninstallPPSSPP=true
doUninstallPrimeHacks=true
doUninstallRMG=true
doUninstallRPCS3=true
doUninstallRyujinx=true
doUninstallScummVM=true
doUninstallSRM=true
doUninstallVita3K=true
doUninstallXemu=true
doUninstallXenia=true
doUninstallYuzu=true




LOGFILE="$HOME/Desktop/emudeck-uninstall.log"
echo "${@}" > "${LOGFILE}" #might as well log out the parameters of the run
exec > >(tee "${LOGFILE}") 2>&1

#Wellcome
text="`printf "<b>Hi!</b>\nAre you sure you want to uninstall EmuDeck?\n\nIf you are having issues, visit the EmuDeck Discord or Reddit for support. For links, see: https://www.emudeck.com/#download"`"

zenity --question \
		 --title="EmuDeck" \
		 --width=250 \
		 --ok-label="I know what I am doing, I would like to uninstall EmuDeck" \
		 --cancel-label="Cancel uninstallation" \
		 --text="${text}" &>> /dev/null
ans=$?
if [ $ans -eq 0 ]; then
	doUninstall=true
else
	exit
fi

clear

if [ "$doUninstall" == true ]; then

	text="`printf "If you would like to delete all your ROM shortcuts in Steam, click the Launch Steam ROM Manager button below.\n\nOnce Steam ROM Manager is launched, go to Settings and select <b>Remove All added app entries</b>\n\n Exit Steam ROM Manager and click Continue to proceed with uninstalling EmuDeck."`"

	zenity --question \
		 --title="EmuDeck" \
		 --width=450 \
		 --ok-label="Launch Steam ROM Manager" \
		 --cancel-label="Continue" \
		 --text="${text}"
	ans=$?
	if [ $ans -eq 0 ]; then
		kill -15 "$(pidof steam)"
		$toolsPath/Steam ROM Manager.AppImage

	else
		echo -e "No"
	fi


	#Emulator selector
	text="`printf " <b>The Uninstallation Wizard will uninstall EmuDeck, selected emulators, configuration files, and saved games.</b>\n\n Select which emulators you would like to <b>keep</b> installed.\n\n If you do not select an emulator, everything will be uninstalled except your ROMs and BIOS ( Yuzu firmware will be deleted)."`"

	emusToUninstall=$(zenity --list \
				--title="EmuDeck" \
				--height=500 \
				--width=250 \
				--ok-label="OK" \
				--cancel-label="Exit" \
				--text="${text}" \
				--checklist \
				--column="" \
				--column="Select which emulators you would like to keep installed" \
				1 "ares"  \
				2 "Cemu" \
				3 "Cemu Native" \
				4 "Citra" \
				5 "Dolphin" \
				6 "Duckstation" \
				7 "Flycast" \
				8 "Mame"  \
				9 "melonDS"  \
				10 "mGBA"  \
				11 "PCSX2" \
				12 "PPSSPP" \
				13 "PrimeHack" \
				14 "RetroArch"\
				15 "RMG"  \
				16 "RPCS3" \
				17 "Ryujinx" \
				18 "ScummVM" \
				19 "Vita3K"  \
				20 "Xemu" \
				21 "Xenia"  \
				22 "Yuzu" )

	ans=$?
	if [ $ans -eq 0 ]; then

		if [[ "$emusToUninstall" == *"ares"* ]]; then
			doUninstallares=false
		fi
		if [[ "$emusToUninstall" == *"Cemu"* ]]; then
			doUninstallCemu=false
		fi
		if [[ "${emusToUninstall}" == *"Cemu Native"* ]]; then
			doUninstallCemuNative="false"
		fi
		if [[ "$emusToUninstall" == *"Citra"* ]]; then
			doUninstallCitra=false
		fi
		if [[ "$emusToUninstall" == *"Dolphin"* ]]; then
			doUninstallDolphin=false
		fi
		if [[ "$emusToUninstall" == *"Duckstation"* ]]; then
			doUninstallDuck=false
		fi
		if [[ "$emusToUninstall" == *"Flycast"* ]]; then
			doUninstallFlycast=false
		fi
		if [[ "$emusToUninstall" == *"Mame"* ]]; then
			doUninstallMame=false
		fi
		if [[ "$emusToUninstall" == *"melonDS"* ]]; then
			doUninstallmelonDS=false
		fi
		if [[ "$emusToUninstall" == *"mGBA"* ]]; then
			doUninstallMGBA=false
		fi
		if [[ "$emusToUninstall" == *"PrimeHack"* ]]; then
			doUninstallPrimeHacks=false
		fi
		if [[ "$emusToUninstall" == *"PCSX2"* ]]; then
			doUninstallPCSX2=false
		fi
		if [[ "$emusToUninstall" == *"PPSSPP"* ]]; then
			doUninstallPPSSPP=false
		fi
		if [[ "$emusToUninstall" == *"RetroArch"* ]]; then
			doUninstallRA=false
		fi
		if [[ "$emusToUninstall" == *"RPCS3"* ]]; then
			doUninstallRPCS3=false
		fi
		if [[ "$emusToUninstall" == *"RMG"* ]]; then
			doUninstallRMG=false
		fi
		if [[ "$emusToUninstall" == *"Ryujinx"* ]]; then
			doUninstallRyujinx=false
		fi
		if [[ "$emusToUninstall" == *"ScummVM"* ]]; then
			doUninstallScummVM=false
		fi
		if [[ "$emusToUninstall" == *"Vita3K"* ]]; then
			doUninstallVita3K=false
		fi
		if [[ "$emusToUninstall" == *"Yuzu"* ]]; then
			doUninstallYuzu=false
		fi
		if [[ "$emusToUninstall" == *"Xemu"* ]]; then
			doUninstallXemu=false
		fi
		if [[ "$emusToUninstall" == *"Xenia"* ]]; then
			doUninstallXenia=false
		fi

	else
		exit
	fi

	#Uninstalling

	(

		echo "10"
		echo "# Removing selected Emulators" ;

	if [[ "$doUninstallares" == true ]]; then
		flatpak uninstall dev.ares.ares -y
		rm -rf $HOME/.var/app/dev.ares.ares &>> /dev/null
	fi
	if [[ "$doUninstallCemu" == true ]]; then
		find ${romsPath}/wiiu -mindepth 1 -name roms -prune -o -exec rm -rf '{}' \;
		rm -f "$HOME/.local/share/applications/Cemu (Proton).desktop" &>> /dev/null
	fi
	if [[ "${doUninstallCemuNative}" == "true" ]]; then
		rm -rf $HOME/Applications/Cemu*.AppImage &>> /dev/null
		rm -rf $HOME/.config/Cemu &>> /dev/null
		rm -rf $HOME/.local/share/Cemu &>> /dev/null
		rm -rf $HOME/.cache/Cemu &>> /dev/null
		rm -rf $HOME/.local/share/applications/Cemu.desktop &>> /dev/null
	fi
	if [[ "$doUninstallCitra" == true ]]; then
		flatpak uninstall org.citra_emu.citra -y
		rm -rf $HOME/.var/app/org.citra_emu.citra &>> /dev/null
	fi
	if [[ "$doUninstallDolphin" == true ]]; then
		flatpak uninstall org.DolphinEmu.dolphin-emu -y
		rm -rf $HOME/.var/app/org.DolphinEmu.dolphin-emu &>> /dev/null
	fi
	if [[ "$doUninstallDuck" == true ]]; then
		flatpak uninstall org.duckstation.DuckStation -y
		rm -rf $HOME/.var/app/org.duckstation.DuckStation &>> /dev/null
	fi
	if [[ "$doUninstallFlycast" == true ]]; then
		flatpak uninstall org.flycast.Flycast -y
		rm -rf $HOME/.var/app/org.flycast.Flycast &>> /dev/null
	fi
	if [[ "$doUninstallMame" == true ]]; then
		flatpak uninstall org.mamedev.MAME -y
		rm -rf $HOME/.var/app/org.mamedev.MAME &>> /dev/null
	fi
	if [[ "$doUninstallmelonDS" == true ]]; then
		flatpak uninstall net.kuribo64.melonDS -y
		rm -rf $HOME/.var/app/net.kuribo64.melonDS &>> /dev/null
	fi
	if [[ "$doUninstallMGBA" == true ]]; then
		rm -rf $HOME/Applications/mGBA.AppImage &>> /dev/null
		rm -rf $HOME/.config/mgba &>> /dev/null
		rm -rf $HOME/.local/share/applications/mGBA.desktop &>> /dev/null
	fi
	if [[ "$doUninstallPCSX2" == true ]]; then
		rm -rf $HOME/Applications/pcsx2-Qt.AppImage &>> /dev/null
		rm -rf $HOME/.config/PCSX2 &>> /dev/null
		rm -rf $HOME/.local/share/applications/pcsx2-Qt.desktop &>> /dev/null
		rm -rf $HOME/.local/share/applications/PCSX2-Qt.desktop &>> /dev/null
	fi
	if [[ "$doUninstallPPSSPP" == true ]]; then
		flatpak uninstall org.ppsspp.PPSSPP -y
		rm -rf $HOME/.var/app/org.ppsspp.PPSSPP &>> /dev/null
	fi
	if [[ "$doUninstallPrimeHacks" == true ]]; then
		flatpak uninstall io.github.shiiion.primehack -y
		rm -rf $HOME/.var/app/io.github.shiiion.primehack &>> /dev/null
	fi
	if [[ "$doUninstallRA" == true ]]; then
		flatpak uninstall org.libretro.RetroArch -y
		rm -rf $HOME/.var/app/org.libretro.RetroArch &>> /dev/null
	fi
	if [[ "$doUninstallRMG" == true ]]; then
		flatpak uninstall com.github.Rosalie241.RMG -y
		rm -rf $HOME/.var/app/com.github.Rosalie241.RMG &>> /dev/null
	fi
	if [[ "$doUninstallRPCS3" == true ]]; then
		# Flatpak
		flatpak uninstall net.rpcs3.RPCS3 -y
		rm -rf $HOME/.var/app/net.rpcs3.RPCS3 &>> /dev/null
		# AppImage
		rm -rf "$HOME/.config/rpcs3" &>> /dev/null
		rm -rf "$HOME/.cache/rpcs3" &>> /dev/null
		rm -rf $HOME/.local/share/applications/RPCS3.desktop &>> /dev/null
	fi
	if [[ "$doUninstallRyujinx" == true ]]; then
		rm -rf $HOME/.config/Ryujinx &>> /dev/null
		rm -rf $HOME/Applications/publish &>> /dev/null
		rm -rf $HOME/.local/share/applications/Ryujinx.desktop &>> /dev/null
	fi
	if [[ "$doUninstallScummVM" == true ]]; then
		flatpak uninstall org.scummvm.ScummVM -y
		rm -rf $HOME/.var/app/org.scummvm.ScummVM &>> /dev/null
	fi
	if [[ "$doUninstallVita3K" == true ]]; then
		rm -rf $HOME/Applications/Vita3K &>> /dev/null
		rm -rf $HOME/.local/share/Vita3K &>> /dev/null
		rm -rf $HOME/.local/share/applications/Vita3K.desktop &>> /dev/null
	fi
	if [[ "$doUninstallXemu" == true ]]; then
		flatpak uninstall app.xemu.xemu -y
		rm -rf $HOME/.var/app/app.xemu.xemu &>> /dev/null
	fi
	if [[ "$doUninstallXenia" == true ]]; then
		find ${romsPath}/xbox360 -mindepth 1 -name roms -prune -o -exec rm -rf '{}' \; &>> /dev/null
	 	rm -rf $HOME/.local/share/applications/xenia.desktop &>> /dev/null
	fi
	if [[ "$doUninstallYuzu" == true ]]; then
		#flatpak uninstall org.yuzu_emu.yuzu --system -y
		#rm -rf $HOME/.var/app/org.yuzu_emu.yuzu &>> /dev/null
		rm -rf $HOME/Applications/yuzu.AppImage &>> /dev/null
		rm -rf $HOME/.config/yuzu &>> /dev/null
		rm -rf $HOME/.local/share/yuzu &>> /dev/null
		rm -rf $HOME/.cache/yuzu &>> /dev/null
		rm -rf $HOME/.local/share/applications/yuzu.desktop &>> /dev/null
	fi

	echo "55"
	echo "# Removing Cloud Backup";

	#Backup Service
	systemctl --user disable emudeck_saveBackup.timer && rm "$HOME/.config/systemd/user/emudeck_saveBackup.timer" && rm "$HOME/.config/systemd/user/emudeck_saveBackup.service"
	rm -rf "$HOME/Desktop/SaveBackup.desktop" &>> /dev/null
	#Emudeck's files


	echo "60"
	echo "# Removing Steam Input files";

	rm -rf $HOME/.steam/steam/controller_base/templates/ares_controller_config.vdf  &>> /dev/null
	rm -rf $HOME/.steam/steam/controller_base/templates/cemu_controller_config.vdf  &>> /dev/null
	rm -rf $HOME/.steam/steam/controller_base/templates/citra_controller_config.vdf  &>> /dev/null
	rm -rf $HOME/.steam/steam/controller_base/templates/duckstation_controller_config.vdf  &>> /dev/null
	rm -rf $HOME/.steam/steam/controller_base/templates/emudeck_cloud_controller_config.vdf  &>> /dev/null
	rm -rf $HOME/.steam/steam/controller_base/templates/emulationstation-de_controller_config.vdf  &>> /dev/null
	rm -rf $HOME/.steam/steam/controller_base/templates/melonds_controller_config.vdf  &>> /dev/null
	rm -rf $HOME/.steam/steam/controller_base/templates/mGBA_controller_config.vdf  &>> /dev/null
	rm -rf $HOME/.steam/steam/controller_base/templates/pcsx2_controller_config.vdf  &>> /dev/null
	rm -rf $HOME/.steam/steam/controller_base/templates/ppsspp_controller_config.vdf  &>> /dev/null
	rm -rf $HOME/.steam/steam/controller_base/templates/rmg_controller_config.vdf  &>> /dev/null
	find  "$HOME/.steam/steam/tenfoot/resource/images/library/controller/binding_icons" -name 'EmuDeck*' -exec rm {} \;

	echo "65"
	echo "# Removing EmuDeck AppImage";
	rm -rf $HOME/emudeck &>> /dev/null
	rm -rf $HOME/Desktop/EmuDeckCHD.desktop &>> /dev/null
	rm -rf $HOME/Desktop/EmuDeckUninstall.desktop &>> /dev/null
	rm -rf $HOME/Desktop/EmuDeck.desktop &>> /dev/null
	rm -rf $HOME/Desktop/EmuDeckSD.desktop &>> /dev/null
	rm -rf $HOME/Desktop/EmuDeckBinUpdate.desktop &>> /dev/null
	rm -rf $HOME/Desktop/SteamRomManager.desktop &>> /dev/null
	rm -rf $HOME/Applications/EmuDeck.AppImage &>> /dev/null
	rm -rf $HOME/Applications/EmuDeck_SaveSync.AppImage &>> /dev/null
	rm -rf $HOME/Applications/RemotePlayWhatever.AppImage &>> /dev/null
	rm -rf $HOME/.config/EmuDeck

	echo "70"
	echo "# Removing Emulators Custom Shortcuts";
	rm -rf $HOME/.local/share/applications/EmuDeck.desktop &>> /dev/null

	echo "80"
	echo "# Removing Steam ROM Manager and EmulationStation-DE";
	# Steam ROM Manager
	rm -rf $HOME/.config/steam-rom-manager
	rm -rf "$toolsPath/Steam ROM Manager.AppImage"
	rm -rf $HOME/.local/share/applications/SRM.desktop &>> /dev/null
	# EmulationStation-DE
	rm -rf $HOME/.emulationstation
	rm -rf "$toolsPath/EmulationStation-DE.AppImage"
	rm -rf "$toolsPath/EmulationStation-DE.AppImage"

	echo "90"
	echo "# Removing EmuDeck folders";
	rm -rf $toolsPath
	#rm -rf $biosPath
	rm -rf $savesPath
	rm -rf $storagePath
	rm -rf $ESDEscrapData
	rm -rf "$emulationPath/hdpacks"
	rm -rf "$emulationPath/storage"

	echo "100"
	echo "# Done";
	) |
	zenity --progress \
	  --title="Uninstalling EmuDeck..." \
	  --text="..." \
	  --percentage=0
	  --auto-close
	  --width="250"

	if [ "$?" = -1 ] ; then
			zenity --error \
			  --text="Uninstall canceled."
	fi


	 text="`printf " <b>Done!</b>\n\n Thank you for trying EmuDeck out!\n\nYou will find your ROMs in your Emulation folder. Close the EmuDeck application to complete the uninstallation process"`"
		 zenity --info \
				 --title="EmuDeck" \
				 --width="450" \
				 --text="${text}"

	exit

fi
