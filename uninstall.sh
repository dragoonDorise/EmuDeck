#!/usr/bin/env bash

# shellcheck disable=1091
. "${HOME}/.config/EmuDeck/backend/functions/all.sh"

doUninstall=false
doUninstallares=true
doUninstallBigPEmu=true
doUninstallCemu=true
doUninstallCemuNative=true
doUninstallCitra=true
doUninstallDolphin=true
doUninstallDuck=true
# shellcheck disable=2034
doUninstallESDE=true
doUninstallFlycast=true
doUninstallAzahar=true
doUninstallMame=true
doUninstallmelonDS=true
doUninstallMGBA=true
doUninstallModel2=true
doUninstallRA=true
doUninstallPCSX2=true
doUninstallPPSSPP=true
doUninstallPrimeHacks=true
doUninstallRMG=true
doUninstallRPCS3=true
doUninstallShadPS4=true
doUninstallRyujinx=true
doUninstallScummVM=true
# shellcheck disable=2034
doUninstallSRM=true
doUninstallSupermodel=true
doUninstallVita3K=true
doUninstallXemu=true
doUninstallXenia=true
doUninstallYuzu=true

LOGFILE="${HOME}/Desktop/emudeck-uninstall.log"
echo "${@}" > "${LOGFILE}" #might as well log out the parameters of the run
exec > >(tee "${LOGFILE}") 2>&1

#Wellcome
text="$( printf "<b>Hi!</b>\nAre you sure you want to uninstall EmuDeck?\n\nIf you are having issues, visit the EmuDeck Discord or Reddit for support. For links, see: https://emudeck.github.io/" )"

zenity --question \
		 --title="EmuDeck" \
		 --width=250 \
		 --ok-label="I know what I am doing, I would like to uninstall EmuDeck" \
		 --cancel-label="Cancel uninstallation" \
		 --text="${text}" &> /dev/null
ans=$?
if [ $ans -eq 0 ]; then
	doUninstall=true
else
	exit
fi

clear

if [ "${doUninstall}" == true ]; then

	text="$( printf "If you would like to delete all your ROM shortcuts in Steam, click the Launch Steam ROM Manager button below.\n\nOnce Steam ROM Manager is launched, go to Settings and select <b>Remove All added app entries</b>\n\n Exit Steam ROM Manager and click Continue to proceed with uninstalling EmuDeck." )"

	zenity --question \
		 --title="EmuDeck" \
		 --width=450 \
		 --ok-label="Launch Steam ROM Manager" \
		 --cancel-label="Continue" \
		 --text="${text}"
	ans=$?
	if [ $ans -eq 0 ]; then
		kill -15 "$(pidof steam)"
		# shellcheck disable=2154
		"${toolsPath}/Steam ROM Manager.AppImage"

	else
		echo -e "No"
	fi

	# Decky Loader

	if [[ -f "${HOME}/homebrew/services/PluginLoader" ]] ; then

		text="$( printf "An installation of Decky Loader was found on your system. Would you like to open the Decky Loader Uninstallation Tool?" )"

		zenity --question \
			--title="Decky Loader" \
			--width=450 \
			--ok-label="Launch the Decky Loader Uninstallation Tool" \
			--cancel-label="No, continue with uninstalling EmuDeck" \
			--text="${text}"
		ans=$?
		if [ $ans -eq 0 ]; then
			curl -S -s -L -O --output-dir "${HOME}/.config/EmuDeck" --connect-timeout 30 https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/user_install_script.sh
			# shellcheck disable=2154
			chmod +x "${emudeckFolder}/user_install_script.sh"
			"${emudeckFolder}/user_install_script.sh"

		else
			echo -e "No"
		fi
	fi


	text="$( printf "Do you want the EmuDeck Uninstallation Tool to back up your saves? Your saves will be zipped and placed in your Emulation folder after the uninstallation is complete." )"

	zenity --question \
			--title="Back Up Saves" \
			--width=450 \
			--ok-label="Yes, back up my saves" \
			--cancel-label="No, continue with uninstalling EmuDeck" \
			--text="${text}"
	ans=$?
	if [ $ans -eq 0 ]; then
		# shellcheck disable=2154
		mkdir -p "${emulationPath}/EmuDeckSavesBackUp"
		# shellcheck disable=2154
		rsync -avh --copy-links "${savesPath}" "${emulationPath}/EmuDeckSavesBackUp"
		# shellcheck disable=2154
		cd "${emulationPath}"
		zip -r "EmuDeckSavesBackUp.zip" "EmuDeckSavesBackUp"
		rm -rf "${emulationPath}/EmuDeckSavesBackUp" &> /dev/null
	else
		echo -e "No"
	fi

	text="$( printf "Do you want the EmuDeck Uninstallation Tool to back up your BIOS? Your BIOS will be zipped and placed in your Emulation folder after the uninstallation is complete." )"

	zenity --question \
			--title="Back Up BIOS" \
			--width=450 \
			--ok-label="Yes, back up my BIOS" \
			--cancel-label="No, continue with uninstalling EmuDeck" \
			--text="${text}"
	ans=$?
	if [ $ans -eq 0 ]; then
		mkdir -p "${emulationPath}/EmuDeckBIOSBackUp"
		# shellcheck disable=2154
		rsync -avh --copy-links "${biosPath}" "${emulationPath}/EmuDeckBIOSBackUp"
		cd "${emulationPath}"
		zip -r "EmuDeckBIOSBackUp.zip" "EmuDeckBIOSBackUp"
		rm -rf "${emulationPath}/EmuDeckBIOSBackUp" &> /dev/null
	else
		echo -e "No"
	fi

	# shellcheck disable=2154
	if find "${romsPath}/remoteplay" -type f -name "*.sh" | grep -q .; then

		RPUninstall=$(zenity --list  \
			--title="Remote Play Clients" \
			--text="The EmuDeck uninstaller has detected you have installed Remote Play Clients using the Cloud Services Manager. \n\n Any checked items on this list will remain installed. \n\nAny unchecked items will be uninstalled. \n\nSelect which remote play clients you would like to keep installed." \
			--ok-label="OK" --cancel-label="Exit" \
			--column="" --column="Leave unchecked to uninstall." \
			--width=500 --height=500 --checklist \
			1 "Chiaki Remote Play Client"  \
			2 "chiaki-ng" \
			3 "Greenlight" \
			4 "Moonlight Game Streaming" \
			5 "Parsec" \
			6 "ShadowPC" \
			7 "Steam Link" )

		if [[ "${RPUninstall}" != *"Chiaki Remote Play Client"* ]]; then
			flatpak uninstall re.chiaki.Chiaki -y
			rm -f "${romsPath}/remoteplay/Chiaki Remote Play Client.sh" &> /dev/null
			rm -rf "${HOME}/.var/app/re.chiaki.Chiaki" &> /dev/null
		fi

		if [[ "${RPUninstall}" != *"chiaki-ng"* ]]; then
			rm -f "${emusFolder}/chiaki-ng.AppImage" &> /dev/null
			rm -rf "${HOME}/.config/Chiaki/" &> /dev/null
			rm -rf "${HOME}/.cache/Chiaki/" &> /dev/null
			rm -f "${romsPath}/remoteplay/chiaki-ng.sh" &> /dev/null
			rm -rf "${HOME}/.local/share/applications/chiaki-ng.desktop" &> /dev/null
		fi

		if [[ "${RPUninstall}" != *"Greenlight"* ]]; then
			rm -f "${emusFolder}/Greenlight.AppImage" &> /dev/null
			rm -f "${romsPath}/remoteplay/Greenlight.sh" &> /dev/null
			rm -rf "${HOME}/.config/greenlight/" &> /dev/null
			rm -rf "${HOME}/.local/share/applications/Greenlight.desktop" &> /dev/null
		fi

		if [[ "${RPUninstall}" != *"Moonlight Game Streaming"* ]]; then
			flatpak uninstall com.moonlight_stream.Moonlight -y
			rm -f "$romsPath/remoteplay/Moonlight Game Streaming.sh" &> /dev/null
			rm -rf "$HOME/.var/app/com.moonlight_stream.Moonlight" &> /dev/null
		fi

		if [[ "${RPUninstall}" != *"Parsec"* ]]; then
			flatpak uninstall com.parsecgaming.parsec -y
			rm -f "${romsPath}/remoteplay/Parsec.sh" &> /dev/null
			rm -rf "${HOME}/.var/app/com.parsecgaming.parsec" &> /dev/null
		fi

		if [[ "${RPUninstall}" != *"ShadowPC"* ]]; then
			rm -f "${emusFolder}/ShadowPC.AppImage" &> /dev/null
			rm -f "${romsPath}/remoteplay/ShadowPC.sh" &> /dev/null
			rm -rf "${HOME}/.config/shadow/" &> /dev/null
			rm -rf "${HOME}/.local/share/applications/ShadowPC.desktop" &> /dev/null
		fi

		if [[ "${RPUninstall}" != *"Steam Link"* ]]; then
			flatpak uninstall com.valvesoftware.SteamLink -y
			rm -f "${romsPath}/remoteplay/SteamLink.sh" &> /dev/null
			rm -rf "${HOME}/.var/app/com.valvesoftware.SteamLink" &> /dev/null
		fi

	fi

	if find "${romsPath}/generic-applications" -type f -name "*.sh" | grep -q .; then

		GAUninstall=$(zenity --list  \
			--title="Generic Applications" \
			--text="The EmuDeck uninstaller has detected you have installed Generic Applications using the Cloud Services Manager. \n\n Any checked items on this list will remain installed. \n\nAny unchecked items will be uninstalled. \n\nSelect which remote play clients you would like to keep installed." \
			--ok-label="OK" --cancel-label="Exit" \
			--column="" --column="Leave unchecked to uninstall." \
			--width=500 --height=500 --checklist \
			1 "Bottles" \
			2 "Cider"  \
			3 "Flatseal" \
			4 "Heroic Games Launcher" \
			5 "Lutris" \
			6 "Plexamp" \
			7 "Spotify" \
			8 "Tidal" \
			9 "Warehouse" )

		if [[ "${GAUninstall}" != *"Bottles"* ]]; then
			flatpak uninstall com.usebottles.bottles -y
			rm -f "${romsPath}/generic-applications/Bottles.sh" &> /dev/null
			rm -rf "${HOME}/.var/app/com.usebottles.bottles" &> /dev/null
		fi

		if [[ "${GAUninstall}" != *"Cider"* ]]; then
			flatpak uninstall sh.cider.Cider -y
			rm -f "${romsPath}/generic-applications/Cider.sh" &> /dev/null
			rm -rf "${HOME}/.var/app/sh.cider.Cider" &> /dev/null
		fi

		if [[ "${GAUninstall}" != *"Flatseal"* ]]; then
			flatpak uninstall com.github.tchx84.Flatseal -y
			rm -f "${romsPath}/generic-applications/Flatseal.sh" &> /dev/null
			rm -rf "${HOME}/.var/app/com.github.tchx84.Flatseal" &> /dev/null
		fi

		if [[ "${GAUninstall}" != *"Heroic Games Launcher"* ]]; then
			rm -f "${emusFolder}/Heroic-Games-Launcher.AppImage" &> /dev/null
			rm -f "${romsPath}/generic-applications/Heroic-Games-Launcher.sh" &> /dev/null
			rm -rf "${HOME}/.config/heroic/" &> /dev/null
			rm -rf "${HOME}/.local/share/applications/Heroic-Games-Launcher.desktop" &> /dev/null
		fi

		if [[ "${GAUninstall}" != *"Lutris"* ]]; then
			flatpak uninstall net.lutris.Lutris -y
			rm -f "${romsPath}/generic-applications/Lutris.sh" &> /dev/null
			rm -rf "${HOME}/.var/app/net.lutris.Lutris" &> /dev/null
		fi

		if [[ "${GAUninstall}" != *"Plexamp"* ]]; then
			flatpak uninstall com.plexamp.Plexamp -y
			rm -f "${romsPath}/generic-applications/Plexamp.sh" &> /dev/null
			rm -rf "${HOME}/.var/app/com.plexamp.Plexamp" &> /dev/null
		fi

		if [[ "${GAUninstall}" != *"Spotify"* ]]; then
			flatpak uninstall com.spotify.Client -y
			rm -f "${romsPath}/generic-applications/Spotify.sh" &> /dev/null
			rm -rf "${HOME}/.var/app/com.spotify.Client" &> /dev/null
		fi

		if [[ "${GAUninstall}" != *"Tidal"* ]]; then
			flatpak uninstall com.mastermindzh.tidal-hifi -y
			rm -f "${romsPath}/generic-applications/Tidal.sh" &> /dev/null
			rm -rf "${HOME}/.var/app/com.mastermindzh.tidal-hifi" &> /dev/null
		fi

		if [[ "${GAUninstall}" != *"Warehouse"* ]]; then
			flatpak uninstall io.github.flattool.Warehouse -y
			rm -f "${romsPath}/generic-applications/Warehouse.sh" &> /dev/null
			rm -rf "${HOME}/.var/app/io.github.flattool.Warehouse" &> /dev/null
		fi

	fi


	#Emulator selector
	text="$( printf " <b>The Uninstallation Wizard will uninstall EmuDeck, selected emulators, configuration files, and saved games.</b>\n\n Select which emulators you would like to <b>keep</b> installed.\n\n If you do not select an emulator, everything will be uninstalled except your ROMs and BIOS ( Yuzu firmware will be deleted)." )"

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
				2 "BigPEmu" \
				3 "Cemu" \
				4 "Cemu Native" \
				5 "Citra" \
				6 "Dolphin" \
				7 "Duckstation" \
				8 "Flycast" \
				9 "Azahar" \
				10 "Mame"  \
				11 "melonDS"  \
				12 "mGBA"  \
				13 "Model2" \
				14 "PCSX2" \
				15 "PPSSPP" \
				16 "PrimeHack" \
				17 "RetroArch"\
				18 "RMG"  \
				19 "RPCS3" \
				20 "Ryujinx" \
				21 "ScummVM" \
				22 "ShadPS4" \
				23 "Supermodel" \
				24 "Vita3K"  \
				25 "Xemu" \
				26 "Xenia"  \
				27 "Yuzu" )

	ans=$?

	if [ $ans -eq 0 ]; then

		if [[ "${emusToUninstall}" == *"ares"* ]]; then
			doUninstallares=false
		fi
		if [[ "${emusToUninstall}" == *"BigPEmu"* ]]; then
			doUninstallBigPEmu=false
		fi
		if [[ "${emusToUninstall}" == *"Cemu"* ]]; then
			doUninstallCemu=false
		fi
		if [[ "${emusToUninstall}" == *"Cemu Native"* ]]; then
			doUninstallCemuNative="false"
		fi
		if [[ "${emusToUninstall}" == *"Citra"* ]]; then
			doUninstallCitra=false
		fi
		if [[ "${emusToUninstall}" == *"Dolphin"* ]]; then
			doUninstallDolphin=false
		fi
		if [[ "${emusToUninstall}" == *"Duckstation"* ]]; then
			doUninstallDuck=false
		fi
		if [[ "${emusToUninstall}" == *"Flycast"* ]]; then
			doUninstallFlycast=false
		fi
		if [[ "${emusToUninstall}" == *"Azahar"* ]]; then
			doUninstallAzahar=false
		fi
		if [[ "${emusToUninstall}" == *"Mame"* ]]; then
			doUninstallMame=false
		fi
		if [[ "${emusToUninstall}" == *"melonDS"* ]]; then
			doUninstallmelonDS=false
		fi
		if [[ "${emusToUninstall}" == *"mGBA"* ]]; then
			doUninstallMGBA=false
		fi
		if [[ "${emusToUninstall}" == *"Model2"* ]]; then
			doUninstallModel2=false
		fi
		if [[ "${emusToUninstall}" == *"PrimeHack"* ]]; then
			doUninstallPrimeHacks=false
		fi
		if [[ "${emusToUninstall}" == *"PCSX2"* ]]; then
			doUninstallPCSX2=false
		fi
		if [[ "${emusToUninstall}" == *"PPSSPP"* ]]; then
			doUninstallPPSSPP=false
		fi
		if [[ "${emusToUninstall}" == *"RetroArch"* ]]; then
			doUninstallRA=false
		fi
		if [[ "${emusToUninstall}" == *"RPCS3"* ]]; then
			doUninstallRPCS3=false
		fi
		if [[ "${emusToUninstall}" == *"ShadPS4"* ]]; then
			doUninstallShadPS4=false
		fi
		if [[ "${emusToUninstall}" == *"RMG"* ]]; then
			doUninstallRMG=false
		fi
		if [[ "${emusToUninstall}" == *"Ryujinx"* ]]; then
			doUninstallRyujinx=false
		fi
		if [[ "${emusToUninstall}" == *"ScummVM"* ]]; then
			doUninstallScummVM=false
		fi
		if [[ "${emusToUninstall}" == *"Supermodel"* ]]; then
			doUninstallSupermodel=false
		fi
		if [[ "${emusToUninstall}" == *"Vita3K"* ]]; then
			doUninstallVita3K=false
		fi
		if [[ "${emusToUninstall}" == *"Yuzu"* ]]; then
			doUninstallYuzu=false
		fi
		if [[ "${emusToUninstall}" == *"Xemu"* ]]; then
			doUninstallXemu=false
		fi
		if [[ "${emusToUninstall}" == *"Xenia"* ]]; then
			doUninstallXenia=false
		fi
	else
		exit
	fi

	#Uninstalling

	(

		echo "10"
		echo "# Removing selected Emulators" ;

	if [[ "${doUninstallares}" == true ]]; then
		flatpak uninstall dev.ares.ares -y
		rm -rf "${HOME}/.var/app/dev.ares.ares" &> /dev/null
	fi
	if [[ "${doUninstallBigPEmu}" == true ]]; then
		{
			rm -rf "${emusFolder}/BigPEmu"
			rm -rf "${HOME}/.local/share/applications/BigPEmu.desktop"
			rm -rf "${HOME}/.local/share/applications/BigPEmu (Proton).desktop"
		} &> /dev/null
	fi
	if [[ "${doUninstallCemu}" == true ]]; then
		find "${romsPath}/wiiu" -mindepth 1 -name roms -prune -o -exec rm -rf '{}' \;
		rm -f "${HOME}/.local/share/applications/Cemu (Proton).desktop" &> /dev/null
	fi
	if [[ "${doUninstallCemuNative}" == "true" ]]; then
		{
			rm -rf "${emusFolder}"/Cemu*.AppImage
			rm -rf "${HOME}/.config/Cemu"
			rm -rf "${HOME}/.local/share/Cemu"
			rm -rf "${HOME}/.cache/Cemu"
			rm -rf "${HOME}/.local/share/applications/Cemu.desktop"
		} &> /dev/null
	fi
	if [[ "${doUninstallCitra}" == true ]]; then
		flatpak uninstall org.citra_emu.citra -y
		{
			rm -rf "${HOME}/.var/app/org.citra_emu.citra"
			rm -rf "${HOME}/.local/share/applications/Citra.desktop"
			rm -rf "${emusFolder}/citra-qt*.AppImage"
			rm -rf "${HOME}/.local/share/citra-emu"
			rm -rf "${HOME}/.config/citra-emu"
		} &> /dev/null
	fi
	if [[ "${doUninstallDolphin}" == true ]]; then
		flatpak uninstall org.DolphinEmu.dolphin-emu -y
		rm -rf "${HOME}/.var/app/org.DolphinEmu.dolphin-emu" &> /dev/null
	fi
	if [[ "${doUninstallDuck}" == true ]]; then
		flatpak uninstall org.duckstation.DuckStation -y
		rm -rf "${HOME}/.var/app/org.duckstation.DuckStation" &> /dev/null
	fi
	if [[ "${doUninstallFlycast}" == true ]]; then
		flatpak uninstall org.flycast.Flycast -y
		rm -rf "${HOME}/.var/app/org.flycast.Flycast" &> /dev/null
	fi
	if [[ "${doUninstallAzahar}" == true ]]; then
		{
			rm -rf "${HOME}/.config/azahar-emu"
			rm -rf "${HOME}/.local/share/azahar-emu"
			rm -rf "${HOME}/.local/share/applications/Azahar.desktop"
			rm -rf "${emusFolder}/azahar-gui*.AppImage"
		} &> /dev/null
	fi
	if [[ "${doUninstallMame}" == true ]]; then
		flatpak uninstall org.mamedev.MAME -y
		# MAME creates both of these folders but only uses ~/.mame
		{
			rm -rf "${HOME}/.var/app/org.mamedev.MAME"
			rm -rf "${HOME}/.mame"
		} &> /dev/null
	fi
	if [[ "${doUninstallmelonDS}" == true ]]; then
		flatpak uninstall net.kuribo64.melonDS -y
		rm -rf "${HOME}/.var/app/net.kuribo64.melonDS" &> /dev/null
	fi
	if [[ "${doUninstallMGBA}" == true ]]; then
		{
			rm -rf "${emusFolder}/mGBA.AppImage"
			rm -rf "${HOME}/.config/mgba"
			rm -rf "${HOME}/.local/share/applications/mGBA.desktop"
		} &> /dev/null
	fi
	if [[ "${doUninstallModel2}" == true ]]; then
		{
			find "${romsPath}/model2" -mindepth 1 -name roms -prune -o -exec rm -rf '{}' \;
			# Leaving this here for Patreon users stuck with the old name.
			rm -f "${HOME}/.local/share/applications/Model 2 (Proton).desktop"
			# Current name.
			rm -f "${HOME}/.local/share/applications/Model 2 Emulator (Proton).desktop"
			rm -rf "${HOME}/.steam/steam/compatibilitytools.d/ULWGL-Proton-8.0-5-3"
		} &> /dev/null
	fi
	if [[ "${doUninstallPCSX2}" == true ]]; then
		{
			rm -rf "${emusFolder}/pcsx2-Qt.AppImage"
			rm -rf "${HOME}/.config/PCSX2"
			# Has the PCSX2 desktop file name changed over time? As of February 2024, it's PCSX2-QT.desktop
			rm -rf "${HOME}/.local/share/applications/pcsx2-Qt.desktop"
			rm -rf "${HOME}/.local/share/applications/PCSX2-Qt.desktop"
			rm -rf "${HOME}/.local/share/applications/PCSX2-QT.desktop"
		} &> /dev/null
	fi
	if [[ "${doUninstallPPSSPP}" == true ]]; then
		flatpak uninstall org.ppsspp.PPSSPP -y
		rm -rf "${HOME}/.var/app/org.ppsspp.PPSSPP" &> /dev/null
	fi
	if [[ "${doUninstallPrimeHacks}" == true ]]; then
		flatpak uninstall io.github.shiiion.primehack -y
		rm -rf "${HOME}/.var/app/io.github.shiiion.primehack" &> /dev/null
	fi
	if [[ "${doUninstallRA}" == true ]]; then
		flatpak uninstall org.libretro.RetroArch -y
		rm -rf "${HOME}/.var/app/org.libretro.RetroArch" &> /dev/null
	fi
	if [[ "${doUninstallRMG}" == true ]]; then
		flatpak uninstall com.github.Rosalie241.RMG -y
		rm -rf "${HOME}/.var/app/com.github.Rosalie241.RMG" &> /dev/null
	fi
	if [[ "${doUninstallRPCS3}" == true ]]; then
		# Flatpak
		flatpak uninstall net.rpcs3.RPCS3 -y
		{
			rm -rf "${HOME}/.var/app/net.rpcs3.RPCS3"
			# AppImage
			rm -rf "${HOME}/.config/rpcs3"
			rm -rf "${HOME}/.cache/rpcs3"
			rm -rf "${HOME}/.local/share/applications/RPCS3.desktop"
			rm -rf "${emusFolder}/rpcs3.AppImage"
		} &> /dev/null
	fi
	if [[ "${doUninstallShadPS4}" == true ]]; then
		{
			# Flatpak
			rm -rf "${HOME}/.config/shadps4"
			# AppImage
			rm -rf "${HOME}/.local/share/shadps4"
			# AppImage
			rm -rf "${HOME}/.local/share/applications/ShadPS4.desktop"
			rm -rf "${emusFolder}/shadPS4-qt.AppImage"
		} &> /dev/null
	fi
	if [[ "${doUninstallRyujinx}" == true ]]; then
		{
			rm -rf "${HOME}/.config/Ryujinx"
			rm -rf "${emusFolder}/publish"
			rm -rf "}${HOME}/.local/share/applications/Ryujinx.desktop"
		} &> /dev/null
	fi
	if [[ "${doUninstallShadPS4}" == true ]]; then
		{
			# Flatpak
			flatpak uninstall net.shadps4.ShadPS4 -y
			rm -rf "${HOME}/.var/app/net.shadps4.ShadPS4"
			# AppImage
			rm -rf "${HOME}/.config/shadps4" &> /dev/null
			rm -rf "${HOME}/.cache/shadps4" &> /dev/null
			rm -rf "${HOME}/.local/share/applications/ShadPS4.desktop"
			rm -rf "${emusFolder}/shadps4.AppImage"
		} &> /dev/null
	fi
	if [[ "${doUninstallScummVM}" == true ]]; then
		flatpak uninstall org.scummvm.ScummVM -y
		rm -rf "${HOME}/.var/app/org.scummvm.ScummVM" &> /dev/null
	fi
	if [[ "${doUninstallSupermodel}" == true ]]; then
		flatpak uninstall com.supermodel3.Supermodel -y
		{
			rm -rf "${HOME}/.var/app/com.supermodel3.Supermodel"
			rm -rf "${HOME}/.config/supermodel"
			rm -rf "${HOME}/.supermodel"
			rm -rf "${HOME}/.local/share/supermodel"
		} &> /dev/null
	fi
	if [[ "${doUninstallVita3K}" == true ]]; then
		{
			rm -rf "${emusFolder}/Vita3K"
			rm -rf "${HOME}/.cache/Vita3K"
			rm -rf "${HOME}/.config/Vita3K" 
			rm -rf "${HOME}/.local/share/Vita3K"
			rm -rf "${HOME}/.local/share/applications/Vita3K.desktop"
		} &> /dev/null
	fi
	if [[ "${doUninstallXemu}" == true ]]; then
		flatpak uninstall app.xemu.xemu -y
		rm -rf "${HOME}/.var/app/app.xemu.xemu" &> /dev/null
	fi
	if [[ "${doUninstallXenia}" == true ]]; then
		{
			find "${romsPath}/xbox360" -mindepth 1 -name roms -prune -o -exec rm -rf '{}' \;
	 		rm -rf "${HOME}/.local/share/applications/xenia.desktop"
		} &> /dev/null
	fi
	if [[ "${doUninstallYuzu}" == true ]]; then
		#flatpak uninstall org.yuzu_emu.yuzu --system -y
		#rm -rf $HOME/.var/app/org.yuzu_emu.yuzu &> /dev/null
		{
			rm -rf "${emusFolder}/yuzu.AppImage"
			rm -rf "${HOME}/.config/yuzu"
			rm -rf "${HOME}/.local/share/yuzu"
			rm -rf "${HOME}/.cache/yuzu"
			rm -rf "${HOME}/.local/share/applications/yuzu.desktop"
		} &> /dev/null
	fi

	echo "55"
	echo "# Removing Cloud Backup";

	#Backup Service
	systemctl --user disable emudeck_saveBackup.timer && rm "${HOME}/.config/systemd/user/emudeck_saveBackup.timer" && rm "${HOME}/.config/systemd/user/emudeck_saveBackup.service"
	rm -rf "${HOME}/Desktop/SaveBackup.desktop" &> /dev/null
	#CloudSync
	systemctl --user stop "EmuDeckCloudSync.service"
	rm -rf rm -rf "${HOME}/.config/systemd/user/EmuDeckCloudSync.service" > /dev/null
	#Emudeck's files


	echo "60"
	echo "# Removing Steam Input files";
	{
		rm -rf "${HOME}/.steam/steam/controller_base/templates/ares_controller_config.vdf"
		rm -rf "${HOME}/.steam/steam/controller_base/templates/cemu_controller_config.vdf"
		rm -rf "${HOME}/.steam/steam/controller_base/templates/citra_controller_config.vdf"
		rm -rf "${HOME}/.steam/steam/controller_base/templates/duckstation_controller_config.vdf"
		rm -rf "${HOME}/.steam/steam/controller_base/templates/emudeck_cloud_controller_config.vdf"
		rm -rf "${HOME}/.steam/steam/controller_base/templates/emulationstation-de_controller_config.vdf"
		rm -rf "${HOME}/.steam/steam/controller_base/templates/melonds_controller_config.vdf"
		rm -rf "${HOME}/.steam/steam/controller_base/templates/mGBA_controller_config.vdf"
		rm -rf "${HOME}/.steam/steam/controller_base/templates/pcsx2_controller_config.vdf"
		rm -rf "${HOME}/.steam/steam/controller_base/templates/ppsspp_controller_config.vdf"
		rm -rf "${HOME}/.steam/steam/controller_base/templates/rmg_controller_config.vdf"

		rm -rf "${HOME}/.steam/steam/controller_base/templates/emudeck_cloud_controller_config.vdf"
		rm -rf "${HOME}/.steam/steam/controller_base/templates/emudeck_controller_generic.vdf"
		rm -rf "${HOME}/.steam/steam/controller_base/templates/emudeck_controller_ps4.vdf"
		rm -rf "${HOME}/.steam/steam/controller_base/templates/emudeck_controller_ps5.vdf"
		rm -rf "${HOME}/.steam/steam/controller_base/templates/emudeck_controller_steamdeck_nintendo.vdf"
		rm -rf "${HOME}/.steam/steam/controller_base/templates/emudeck_controller_steamdeck_proton.vdf"
		rm -rf "${HOME}/.steam/steam/controller_base/templates/emudeck_controller_steamdeck.vdf"
		rm -rf "${HOME}/.steam/steam/controller_base/templates/emudeck_controller_switch_pro.vdf"
		rm -rf "${HOME}/.steam/steam/controller_base/templates/emudeck_controller_xbox360.vdf"
		rm -rf "${HOME}/.steam/steam/controller_base/templates/emudeck_controller_xboxone.vdf"
		rm -rf "${HOME}/.steam/steam/controller_base/templates/emudeck_controller_steamdeck-xl_radial-menus.vdf"
		rm -rf "${HOME}/.steam/steam/controller_base/templates/emudeck_controller_ps5_dualsense_edge.vdf"
		rm -rf "${HOME}/.steam/steam/controller_base/templates/emudeck_controller_steamdeck_radial_menus.vdf"
		rm -rf "${HOME}/.steam/steam/controller_base/templates/emudeck_frontend_controller_generic.vdf"
		rm -rf "${HOME}/.steam/steam/controller_base/templates/emudeck_frontend_controller_ps4.vdf"
		rm -rf "${HOME}/.steam/steam/controller_base/templates/emudeck_frontend_controller_ps5_dualsense_edge.vdf"
		rm -rf "${HOME}/.steam/steam/controller_base/templates/emudeck_frontend_controller_ps5.vdf"
		rm -rf "${HOME}/.steam/steam/controller_base/templates/emudeck_frontend_controller_steamdeck.vdf"
		rm -rf "${HOME}/.steam/steam/controller_base/templates/emudeck_frontend_controller_switch_pro.vdf"
		rm -rf "${HOME}/.steam/steam/controller_base/templates/emudeck_frontend_controller_xbox360.vdf"
		rm -rf "${HOME}/.steam/steam/controller_base/templates/emudeck_frontend_controller_xboxone.vdf"
		rm -rf "${HOME}/.steam/steam/controller_base/templates/emudeck_frontend_controller_xboxelite.vdf"
		rm -rf "${HOME}/.steam/steam/controller_base/templates/emudeck_controller_xboxelite.vdf"
		rm -rf "${HOME}/.steam/steam/controller_base/templates/emudeck_frontend_controller_steamcontroller.vdf"
		rm -rf "${HOME}/.steam/steam/controller_base/templates/emudeck_controller_steamcontroller.vdf"

		rm -rf "${HOME}/.steam/steam/controller_base/templates/emudeck_steam_deck_light_gun_controls.vdf"
	} &> /dev/null

	find  "$HOME/.steam/steam/tenfoot/resource/images/library/controller/binding_icons" -name 'EmuDeck*' -exec rm {} \;

	echo "65"
	echo "# Removing EmuDeck AppImage";
	{
		rm -rf "${HOME}/.config/EmuDeck"
		rm -rf "${HOME}/Desktop/EmuDeckCHD.desktop"
		rm -rf "${HOME}/Desktop/EmuDeckUninstall.desktop"
		rm -rf "${HOME}/Desktop/EmuDeck.desktop"
		rm -rf "${HOME}/Desktop/EmuDeckSD.desktop"
		rm -rf "${HOME}/Desktop/EmuDeckBinUpdate.desktop"
		rm -rf "${HOME}/Desktop/SteamRomManager.desktop"
		rm -rf "${HOME}/Desktop/uninstall-sdgyrodsu.desktop"
		rm -rf "${HOME}/Desktop/update-sdgyrodsu.desktop"
		rm -rf "${emusFolder}/EmuDeck.AppImage"
		rm -rf "${emusFolder}/EmuDeck_SaveSync.AppImage"
		rm -rf "${emusFolder}/RemotePlayWhatever.AppImage"
		rm -rf "${HOME}/.config/EmuDeck"
	} &> /dev/null

	echo "70"
	echo "# Removing Emulators Custom Shortcuts";
	rm -rf "${HOME}/.local/share/applications/EmuDeck.desktop" &> /dev/null

	echo "80"
	echo "# Removing EmuDeck installed tools: Steam ROM Manager, EmulationStation-DE, ULWGL, and Pegasus";
	{
        # Steam ROM Manager
        rm -rf "${HOME}/.config/steam-rom-manager"
        rm -rf "${toolsPath}/Steam ROM Manager.AppImage"
        # Not sure if this was named differently in the past, but Steam ROM Manager.desktop is the current name, leaving both in case.
        rm -rf "${HOME}/.local/share/applications/SRM.desktop"
        rm -rf "${HOME}/.local/share/applications/Steam ROM Manager.desktop"
        # EmulationStation-DE
        rm -rf "${HOME}/.emulationstation"
        rm -rf "${HOME}/ES-DE"
        rm -rf "${toolsPath}/EmulationStation-DE.AppImage"
        rm -rf "${emusFolder}/EmulationStation-DE.AppImage"
        rm -rf "${emusFolder}/ES-DE.AppImage"
        rm -rf "${HOME}/.local/share/applications/EmulationStation-DE.desktop"
        rm -rf "${HOME}/.local/share/applications/ES-DE.desktop"
        # ULWGL
        rm -rf "${HOME}/.local/share/ULWGL"
        # SteamDeckGyroDSU
        rm -rf "${HOME}/sdgyrodsu"
        # Pegasus
        flatpak uninstall org.pegasus_frontend.Pegasus -y
        rm -rf "${HOME}/.var/app/org.pegasus_frontend.Pegasus/"
        rm -rf "${emusFolder}/pegasus-fe"
        rm -rf "${HOME}/.config/pegasus-frontend"
        rm -rf "${HOME}/.local/share/applications/Pegasus.desktop"
    } &> /dev/null

	echo "90"
	echo "# Removing EmuDeck folders";
	rm -rf "${toolsPath}"
	#rm -rf $biosPath
	rm -rf "${savesPath}"
	# shellcheck disable=2154
	rm -rf "${storagePath}"
	# shellcheck disable=2154
	rm -rf "${ESDEscrapData}"
	rm -rf "${emulationPath}/hdpacks"
	rm -rf "${emulationPath}/storage"




	echo "100"
	echo "# Done";
	) |
	zenity --progress \
	  --title="Uninstalling EmuDeck..." \
	  --text="..." \
	  --percentage=0 \
	  --auto-close \
	  --width="250"

	if [ "$?" = -1 ] ; then
			zenity --error \
			  --text="Uninstall canceled."
	fi


	 text="$( printf " <b>Done!</b>\n\n Thank you for trying EmuDeck out!\n\nYou will find your ROMs in your Emulation folder. Close the EmuDeck application to complete the uninstallation process" )"
		 zenity --info \
				 --title="EmuDeck" \
				 --width="450" \
				 --text="${text}"

	exit

fi
