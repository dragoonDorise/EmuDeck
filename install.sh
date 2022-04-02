#!/bin/sh
NONE='\033[00m'
RED='\033[01;31m'
GREEN='\033[01;32m'
YELLOW='\033[01;33m'
PURPLE='\033[01;35m'
CYAN='\033[01;36m'
WHITE='\033[01;37m'
BOLD='\033[1m'
UNDERLINE='\033[4m'
BLINK='\x1b[5m'

destination=$1
romsPath="/home/deck/Emulation/roms/"
toolsPath="/home/deck/Emulation/tools/"
toolsPathSed="\/home\/deck\/Emulation\/tools\/"
romsPathSed="\/home\/deck\/Emulation\/roms\/"
biosPath="/home/deck/Emulation/bios/"
biosPathSed="\/home\/deck\/Emulation\/bios\/"
if [ $destination == "SD" ]; then
	#Get SD Card name
	sdCard=$(ls /run/media | grep -ve '^deck$' | head -n1)
	romsPath="/run/media/${sdCard}/Emulation/roms/"
	toolsPath="/run/media/${sdCard}/Emulation/tools/"
	toolsPathSed="\/run\/media\/${sdCard}\/Emulation\/tools\/"
	romsPathSed="\/run\/media\/${sdCard}\/Emulation\/roms\/"
	biosPath="/run/media/${sdCard}/Emulation/bios/"
	biosPathSed="\/run\/media\/${sdCard}\/Emulation\/bios\/"
fi
find $romsPath -name "readme.md" -type f -delete &>> ~/emudek.log
rm -rf ~/dragoonDoriseTools
echo -ne "${BOLD}Downloading files...${NONE}"
sleep 5
mkdir -p dragoonDoriseTools
mkdir -p dragoonDoriseTools/EmuDeck
cd dragoonDoriseTools
echo "" > ~/emudek.log

git clone https://github.com/dragoonDorise/EmuDeck.git ~/dragoonDoriseTools/EmuDeck &>> ~/emudek.log
FOLDER=~/dragoonDoriseTools/EmuDeck
if [ -d "$FOLDER" ]; then
	echo -e "${GREEN}OK!${NONE}"
else
	echo -e ""
	echo -e "${RED}We couldn't download the needed files, exiting in a few seconds${NONE}"
	echo -e "Please close this window and try again in a few minutes"
	sleep 999999
	exit
fi
clear
cat ~/dragoonDoriseTools/EmuDeck/logo.ans
version=$(cat ~/dragoonDoriseTools/EmuDeck/version.md)
echo -e "${BOLD}EmuDeck ${version}${NONE}"
echo -e ""

#echo -e "Installing Steam Rom Manager"
#curl https://github.com/SteamGridDB/steam-rom-manager/releases/download/v2.3.29/Steam-ROM-Manager-2.3.29.AppImage  --output /home/deck/Desktop/Steam-ROM-Manager-2.3.29.AppImage

echo -e "${BOLD}Installing EmulationStation Desktop Edition${NONE}"
curl https://gitlab.com/leonstyhre/emulationstation-de/-/package_files/33311338/download  --output $toolsPath/EmulationStation-DE-x64_SteamDeck.AppImage >> ~/emudek.log
chmod +x $toolsPath/EmulationStation-DE-x64_SteamDeck.AppImage

echo -e "Installing PCSX2"
flatpak install flathub net.pcsx2.PCSX2 -y  &>> ~/emudek.log
echo -e "Bad characters" &>> ~/emudek.log
echo -e "Installing PrimeHack"
flatpak install flathub io.github.shiiion.primehack -y &>> ~/emudek.log
#echo -e "Installing PrimeHack"
#flatpak install flathub net.kuribo64.melonDS -y &>> ~/emudek.log
echo -e "Installing RPCS3"
flatpak install flathub net.rpcs3.RPCS3 -y &>> ~/emudek.log
echo -e "Installing Citra"
flatpak install flathub org.citra_emu.citra -y &>> ~/emudek.log
echo -e "Installing dolphin"
flatpak install flathub org.DolphinEmu.dolphin-emu -y &>> ~/emudek.log
echo -e "Installing DuckStation"
flatpak install flathub org.duckstation.DuckStation -y &>> ~/emudek.log
echo -e "Installing RetroArch"
flatpak install flathub org.libretro.RetroArch -y &>> ~/emudek.log
echo -e "Installing PPSSPP"
flatpak install flathub org.ppsspp.PPSSPP -y &>> ~/emudek.log
#echo -e "Installing Ryujinx"
#flatpak install flathub org.ryujinx.Ryujinx -y &>> ~/emudek.log
echo -e "Installing Yuzu"
flatpak install flathub org.yuzu_emu.yuzu -y &>> ~/emudek.log

#Cemu
echo -e "Installing Cemu"
if [ $destination == "SD" ]; then
	FILE="/run/media/${sdCard}/Emulation/roms/wiiu/Cemu.exe"
else
	FILE="/home/deck/Emulation/roms/wiiu/Cemu.exe"
fi

if [ -f "$FILE" ]; then
	echo "" &>> /dev/null
	doCemu=true
else
	curl https://cemu.info/releases/cemu_1.26.2.zip --output $romsPath/wiiu/cemu_1.26.2.zip &>> ~/emudek.log
	unzip -o $romsPath/wiiu/cemu_1.26.2.zip -d $romsPath/wiiu/tmp &>> ~/emudek.log
	mv $romsPath/wiiu/tmp/*/* $romsPath/wiiu &>> ~/emudek.log
	rm -rf $romsPath/wiiu/tmp &>> ~/emudek.log
	rm -f $romsPath/wiiu/cemu_1.26.2.zip &>> ~/emudek.log
fi



##Generate rom folders
if [ $destination == "SD" ]; then
	echo -ne "${BOLD}Creating roms folder in your SD Card...${NONE}"
else
	echo -ne "${BOLD}Creating roms folder in your home folder...${NONE}"
fi
mkdir -p $romsPath
mkdir -p $toolsPath
mkdir -p $biosPath
mkdir -p $biosPath/yuzu/
sleep 3
rsync -r ~/dragoonDoriseTools/EmuDeck/roms/ $romsPath &>> ~/emudek.log
echo -e "${GREEN}OK!${NONE}"
#Steam RomManager
echo -e ""
echo -e ""
echo -ne "${BOLD}Configuring Steam Rom Manager...${NONE}"
mkdir -p ~/.config/steam-rom-manager/userData/
cp ~/dragoonDoriseTools/EmuDeck/configs/steam-rom-manager/userData/userConfigurations.json ~/.config/steam-rom-manager/userData/userConfigurations.json
sleep 3

sed -i "s/\/run\/media\/mmcblk0p1\/Emulation\/roms\//${romsPathSed}/g" ~/.config/steam-rom-manager/userData/userConfigurations.json

sed -i "s/\/run\/media\/mmcblk0p1\/Emulation\/tools\//${toolsPathSed}/g" ~/.config/steam-rom-manager/userData/userConfigurations.json

echo -e "${GREEN}OK!${NONE}"

echo -ne "${BOLD}Configuring Emulation Station...${NONE}"
mkdir -p ~/.emulationstation/
cp ~/dragoonDoriseTools/EmuDeck/configs/emulationstation/es_settings.xml ~/.emulationstation/es_settings.xml
sed -i "s/\/run\/media\/mmcblk0p1\/Emulation\/roms\//${romsPathSed}/g" ~/.emulationstation/es_settings.xml
#sed -i "s/name=\"ROMDirectory\" value=\"/name=\"ROMDirectory\" value=\"${romsPathSed}/g" ~/.emulationstation/es_settings.xml
echo -e "${GREEN}OK!${NONE}"

#Check for installed emulators
doRA=true
doDolphin=true
doPCSX2=true
doRPCS3=true
doYuzu=true
doCitra=true
doDuck=true
doCemu=false
doRyujinx=true
doPrimeHacks=true
doPPSSPP=true

	
#Emus config

echo -e ""
echo -e ""
echo -ne "${BOLD}Configuring Steam Input for emulators..${NONE}"
echo -e ""
rsync -r ~/dragoonDoriseTools/EmuDeck/configs/steam-input/ ~/.steam/steam/controller_base/templates/
echo -e "${GREEN}OK!${NONE}"

echo -e ""
echo -e ""
echo -e "${BOLD}Configuring emulators..${NONE}"
echo -e ""
if [ $doRA == true ]; then
	mkdir -p /home/deck/.var/app/org.libretro.RetroArch
	mkdir -p /home/deck/.var/app/org.libretro.RetroArch/config
	mkdir -p /home/deck/.var/app/org.libretro.RetroArch/config/retroarch
	mkdir -p /home/deck/.var/app/org.libretro.RetroArch/config/retroarch/cores
	raUrl="https://buildbot.libretro.com/nightly/linux/x86_64/latest/"
	raCorePath=""
	RAcores=(81_libretro.so atari800_libretro.so bluemsx_libretro.so chailove_libretro.so fbneo_libretro.so freechaf_libretro.so freeintv_libretro.so fuse_libretro.so gearsystem_libretro.so gw_libretro.so hatari_libretro.so lutro_libretro.so mednafen_pcfx_libretro.so mednafen_vb_libretro.so mednafen_wswan_libretro.so mu_libretro.so neocd_libretro.so nestopia_libretro.so nxengine_libretro.so o2em_libretro.so picodrive_libretro.so pokemini_libretro.so prboom_libretro.so prosystem_libretro.so px68k_libretro.so quasi88_libretro.so scummvm_libretro.so squirreljme_libretro.so theodore_libretro.so uzem_libretro.so vecx_libretro.so vice_xvic_libretro.so virtualjaguar_libretro.so x1_libretro.so mednafen_lynx_libretro.so mednafen_ngp_libretro.so mednafen_pce_libretro.so mednafen_pce_fast_libretro.so mednafen_psx_libretro.so mednafen_psx_hw_libretro.so mednafen_saturn_libretro.so mednafen_supafaust_libretro.so mednafen_supergrafx_libretro.so blastem_libretro.so bluemsx_libretro.so bsnes_libretro.so bsnes_mercury_accuracy_libretro.so cap32_libretro.so citra2018_libretro.so citra_libretro.so crocods_libretro.so desmume2015_libretro.so desmume_libretro.so dolphin_libretro.so dosbox_core_libretro.so dosbox_pure_libretro.so dosbox_svn_libretro.so fbalpha2012_cps1_libretro.so fbalpha2012_cps2_libretro.so fbalpha2012_cps3_libretro.so fbalpha2012_libretro.so fbalpha2012_neogeo_libretro.so fceumm_libretro.so fbneo_libretro.so flycast_libretro.so fmsx_libretro.so frodo_libretro.so gambatte_libretro.so gearboy_libretro.so gearsystem_libretro.so genesis_plus_gx_libretro.so genesis_plus_gx_wide_libretro.so gpsp_libretro.so handy_libretro.so kronos_libretro.so mame2000_libretro.so mame2003_plus_libretro.so mame2010_libretro.so mame_libretro.so melonds_libretro.so mesen_libretro.so mesen-s_libretro.so mgba_libretro.so mupen64plus_next_libretro.so nekop2_libretro.so np2kai_libretro.so nestopia_libretro.so parallel_n64_libretro.so pcsx2_libretro.so pcsx_rearmed_libretro.so picodrive_libretro.so ppsspp_libretro.so puae_libretro.so quicknes_libretro.so race_libretro.so sameboy_libretro.so smsplus_libretro.so snes9x2010_libretro.so snes9x_libretro.so stella2014_libretro.so stella_libretro.so tgbdual_libretro.so vbam_libretro.so vba_next_libretro.so vice_x128_libretro.so vice_x64_libretro.so vice_x64sc_libretro.so vice_xscpu64_libretro.so yabasanshiro_libretro.so yabause_libretro.so bsnes_hd_beta_libretro.so)
	echo -e "Downloading RetroArch Cores"
	for i in "${RAcores[@]}"
	do
		FILE=/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/cores/${i}
		if [ -f "$FILE" ]; then
			echo -e "${i}...${YELLOW}Already Downloaded${NONE}"	
		else
			curl $raUrl$i.zip --output /home/deck/.var/app/org.libretro.RetroArch/config/retroarch/cores/${i}.zip >> ~/emudek.log
			#rm /home/deck/.var/app/org.libretro.RetroArch/config/retroarch/cores/${i}.zip
			echo -e "${i}...${GREEN}Downloaded!${NONE}"	
		fi
	done
	
	for entry in /home/deck/.var/app/org.libretro.RetroArch/config/retroarch/cores/*.zip
	do
		 unzip -o $entry -d /home/deck/.var/app/org.libretro.RetroArch/config/retroarch/cores/ &>> ~/emudek.log
	done
	
	for entry in /home/deck/.var/app/org.libretro.RetroArch/config/retroarch/cores/*.zip
	do
		 rm -f $entry >> ~/emudek.log
	done
	
	raConfigFile="/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg"
	FILE=/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg.bak
	if [ -f "$FILE" ]; then
		echo -e "RetroArch is already backed up."
	else
		echo -ne "Backing up RA..."
		cp /home/deck/.var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg /home/deck/.var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg.bak &>> ~/emudek.log
		echo -e "${GREEN}OK!${NONE}"
	fi
	#mkdir -p /home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays
	rsync -r ~/dragoonDoriseTools/EmuDeck/configs/org.libretro.RetroArch/config/ ~/.var/app/org.libretro.RetroArch/config/
	#rsync -r ~/dragoonDoriseTools/EmuDeck/configs/org.libretro.RetroArch/config/retroarch/config/ ~/.var/app/org.libretro.RetroArch/config/retroarch/config
	
	sed -i "s/system_directory = \"~\/.var\/app\/org.libretro.RetroArch\/config\/retroarch\/system\"/system_directory = \"${biosPathSed}\"/g" $raConfigFile
	
fi
echo -e ""
echo -ne "Applying Emu configurations..."
if [ $doPrimeHacks == true ]; then
	FOLDER=~/.var/app/io.github.shiiion.primehack/config_bak
	if [ -d "$FOLDER" ]; then
		echo "" &>> ~/emudek.log
	else
		echo -ne "Backing up PrimeHacks..."
		cp -r ~/.var/app/io.github.shiiion.primehack/config ~/.var/app/io.github.shiiion.primehack/config_bak &>> ~/emudek.log
		echo -e "${GREEN}OK!${NONE}"
	fi
	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/io.github.shiiion.primehack/ ~/.var/app/io.github.shiiion.primehack/ &>> ~/emudek.log
fi
if [ $doDolphin == true ]; then
	FOLDER=~/.var/app/org.DolphinEmu.dolphin-emu/config_bak
	if [ -d "$FOLDER" ]; then
		echo "" &>> ~/emudek.log
	else
		echo -ne "Backing up Dolphin..."
		cp -r ~/.var/app/org.DolphinEmu.dolphin-emu/config ~/.var/app/org.DolphinEmu.dolphin-emu/config_bak &>> ~/emudek.log
		echo -e "${GREEN}OK!${NONE}"
	fi
	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/org.DolphinEmu.dolphin-emu/ ~/.var/app/org.DolphinEmu.dolphin-emu/ &>> ~/emudek.log
fi
if [ $doPCSX2 == true ]; then
	FOLDER=~/.var/app/net.pcsx2.PCSX2/config_bak
	if [ -d "$FOLDER" ]; then
		echo "" &>> ~/emudek.log
	else
		echo -ne "Backing up PCSX2..."
		cp -r ~/.var/app/net.pcsx2.PCSX2/config ~/.var/app/net.pcsx2.PCSX2/config_bak &>> ~/emudek.log
		echo -e "${GREEN}OK!${NONE}"
	fi
	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/net.pcsx2.PCSX2/ ~/.var/app/net.pcsx2.PCSX2/ &>> ~/emudek.log
	#Bios Fix
	sed -i "s/\/run\/media\/mmcblk0p1\/Emulation\/bios\//${biosPathSed}/g" ~/.var/app/net.pcsx2.PCSX2/config/PCSX2/inis/PCSX2_ui.ini &>> ~/emudek.log
fi
if [ $doRPCS3 == true ]; then
	FOLDER=~/.var/app/net.rpcs3.RPCS3/config_bak
	if [ -d "$FOLDER" ]; then
		echo "" &>> ~/emudek.log
	else
		echo -ne "Backing up RPCS3..."
		cp -r ~/.var/app/net.rpcs3.RPCS3/config ~/.var/app/net.rpcs3.RPCS3/config_bak &>> ~/emudek.log
		echo -e "${GREEN}OK!${NONE}"
	fi

	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/net.rpcs3.RPCS3/ ~/.var/app/net.rpcs3.RPCS3/ &>> ~/emudek.log
	echo "" > $toolsPath/RPCS3.txt
fi
if [ $doCitra == true ]; then
	FOLDER=~/.var/app/org.citra_emu.citra/config_bak
	if [ -d "$FOLDER" ]; then
		echo "" &>> ~/emudek.log
	else
		echo -ne "Backing up Citra..."
		cp -r ~/.var/app/org.citra_emu.citra/config ~/.var/app/org.citra_emu.citra/config_bak &>> ~/emudek.log
		echo -e "${GREEN}OK!${NONE}"
	fi

	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/org.citra_emu.citra/ ~/.var/app/org.citra_emu.citra/ &>> ~/emudek.log
fi
if [ $doDuck == true ]; then
	FOLDER=~/.var/app/org.duckstation.DuckStation/data_bak
	if [ -d "$FOLDER" ]; then
		echo "" &>> ~/emudek.log
	else
		echo -ne "Backing up DuckStation..."
		cp -r ~/.var/app/org.duckstation.DuckStation/data ~/.var/app/org.duckstation.DuckStation/data_bak &>> ~/emudek.log
		echo -e "${GREEN}OK!${NONE}"
	fi
	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/org.duckstation.DuckStation/ ~/.var/app/org.duckstation.DuckStation/ &>> ~/emudek.log
	sleep 3
	sed -i "s/\/run\/media\/mmcblk0p1\/Emulation\/bios\//${biosPathSed}/g" ~/.var/app/org.duckstation.DuckStation/data/duckstation/settings.ini
fi
if [ $doYuzu == true ]; then
	FOLDER=~/.var/app/org.yuzu_emu.yuzu/config
	if [ -d "$FOLDER" ]; then
		echo "" &>> ~/emudek.log
	else
		echo -ne "Backing up Yuzu..."
		cp -r ~/.var/app/org.yuzu_emu.yuzu/config ~/.var/app/org.yuzu_emu.yuzu/config_bak &>> ~/emudek.log
		echo -e "${GREEN}OK!${NONE}"
	fi
	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/org.yuzu_emu.yuzu/ ~/.var/app/org.yuzu_emu.yuzu/ &>> ~/emudek.log
fi
if [ $doCemu == true ]; then
	echo "" &>> ~/emudek.log
	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/cemu/ ${romsPath}/wiiu &>> ~/emudek.log
fi
if [ $doRyujinx == true ]; then
	echo "" &>> ~/emudek.log
	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/org.ryujinx.Ryujinx/ ~/.var/app/org.ryujinx.Ryujinx/ &>> ~/emudek.log
fi
if [ $doPPSSPP == true ]; then
	FOLDER=~/.var/app/org.ppsspp.PPSSPP/config_bak
	if [ -d "$FOLDER" ]; then
		echo "" &>> ~/emudek.log
	else
		echo -ne "Backing up PPSSPP..."
		cp -r ~/.var/app/org.ppsspp.PPSSPP/config ~/.var/app/org.ppsspp.PPSSPP/config_bak &>> ~/emudek.log
		echo -e "${GREEN}OK!${NONE}"
	fi
	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/org.ppsspp.PPSSPP/ ~/.var/app/org.ppsspp.PPSSPP/ &>> ~/emudek.log
fi
echo -e "${GREEN}OK!${NONE}"
echo -e ""
echo -ne "Cleaning up downloaded files..."	
rm -rf ~/dragoonDoriseTools	
echo -e "${GREEN}OK!${NONE}"
echo -e ""
echo -e ""
echo -e "Now to add your games copy them to this exact folder within the appropiate subfolder for each system:"
echo -e ""
echo -e ${BOLD}$romsPath${NONE}
echo -e ""
echo -e "Copy your BIOS and Yuzu Keys+Firmware in this folder:"
echo -e ""
echo -e ${BOLD}$biosPath${NONE}
echo -e ""
echo -e "When you are done copying your roms and BIOS do the following:"
echo -e "1: Right Click the Steam Icon in the taskbar and close it. If you are using the integrated trackpads, the left mouse button is now the R2 and the right mouse button is the L1 button"
echo -e "2: Open Steam Rom Manager"
echo -e "3: On Steam Rom Manager click on Preview"
echo -e "4: Now click on Generate app list"
echo -e "5: Wait for the images to finish (Marked as remaining providers on the top)"
echo -e "6: Click Save app list"
echo -e "7: Close Steam Rom Manager and this window and click on Return to Gaming Mode."
echo -e "8: Enjoy!"

echo -e "${RED}Cemu Special configuration${NONE}"
echo -e "Copy your games on wux or wud format to ${romsPath}/wiiu/roms"
echo -e "If your games are .rpx you need to load them using CEMU on the Emulation Collection"
echo -e "When you add a Wii U game to Steam"
echo -e "${BOLD}you need to go to that game Properties and activate Compatibility -> proton 7.0-1${NONE}"
#Symlinks
cd $(echo $romsPath | tr -d '\r')
ln -s segacd megacd &>> ~/emudek.log
ln -s gamecube gc &>> ~/emudek.log
ln -s genesis megadrive &>> ~/emudek.log
ln -s ~/.var/app/org.yuzu_emu.yuzu/data/yuzu/keys $biosPath/yuzu/keys &>> ~/emudek.log
ln -s ~/.var/app/org.yuzu_emu.yuzu/data/yuzu/nand/system/Contents/registered $biosPath/yuzu/firmware &>> ~/emudek.log
sleep 999999999