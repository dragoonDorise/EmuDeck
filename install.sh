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
rm ~/emudek.log &>> /dev/null
mkdir -p ~/emudeck
echo "" > ~/emudeck/emudeck.log

#Mark as second time for previous users
FOLDER=~/.var/app/io.github.shiiion.primehack/config_bak
if [ -d "$FOLDER" ]; then
	echo "" > ~/emudeck/.finished
fi
sleep 1
SECONDTIME=~/emudeck/.finished




#Vars
doRA=true
doDolphin=true
doPCSX2=true
doRPCS3=true
doYuzu=true
doCitra=true
doDuck=true
doCemu=true
doCxbxReloaded=true
doRyujinx=true
doPrimeHacks=true
doPPSSPP=true
doESDE=true
fsWhitelist=("ext4" "btrfs")
clear
rm -rf ~/dragoonDoriseTools
echo -ne "${BOLD}Downloading files...${NONE}"
sleep 5
mkdir -p dragoonDoriseTools
mkdir -p dragoonDoriseTools/EmuDeck
cd dragoonDoriseTools


git clone https://github.com/dragoonDorise/EmuDeck.git ~/dragoonDoriseTools/EmuDeck &>> ~/emudeck/emudeck.log
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


text="Do you want to install your roms on your SD Card or on your Internal Storage?"
zenity --question \
	   --title="EmuDeck" \
	   --width=250 \
	   --ok-label="SD Card" \
	   --cancel-label="Internal Storage" \
	   --text="${text}" &>> /dev/null
ans=$?
if [ $ans -eq 0 ]; then
	echo "Storage: SD" &>> ~/emudeck/emudeck.log
	destination="SD"
	echo "" > ~/emudeck/.SD
else
	echo "Storage: INTERAL" &>> ~/emudeck/emudeck.log
	destination="INTERNAL"
fi

emulationPath="/home/deck/Emulation/"
romsPath="/home/deck/Emulation/roms/"
toolsPath="/home/deck/Emulation/tools/"
biosPath="/home/deck/Emulation/bios/"

if [ $destination == "SD" ]; then
	#check if sd card exists
	if [ -b "/dev/mmcblk0p1" ]; then
		echo "SD Card is installed" > ~/emudeck/emudeck.log
		
		sdFSType=$(findmnt -n --raw --evaluate --output=fstype -S /dev/mmcblk0p1)
		echo "SD Card formatted as $sdFSType" > ~/emudeck/emudeck.log
		#test if card filesystem is in whitelist
		if [[ " ${fsWhitelist[*]} " =~ " ${sdFSType} " ]] ; then
			#Get SD Card name. use findmnt to explicitly find the first sd card
			sdCardFull=$(findmnt -n --raw --evaluate --output=target -S /dev/mmcblk0p1)
			echo "SD Card found; installing to /dev/mmcblk0p1 mounted on $sdCardFull"
			sdCard=$(ls /run/media | grep -ve '^deck$' | head -n1)
		else
			text="SD Card must be formatted as EXT4"
			zenity --error \
			   --title="SD Card ERROR" \
			   --width=250 \	   
			   --text="${text}" &>> /dev/null
			exit
		fi
	else
		text="SD Card not found"
		zenity --error \
			   --title="SD Card ERROR" \
			   --width=250 \	   
			   --text="${text}" &>> /dev/null
		exit
	fi

	emulationPath="${sdCardFull}/Emulation/"
	romsPath="${sdCardFull}/Emulation/roms/"
	toolsPath="${sdCardFull}/Emulation/tools/"
	biosPath="${sdCardFull}/Emulation/bios/"

fi

mkdir -p $emulationPath
mkdir -p $toolsPath
find $romsPath -name "readme.md" -type f -delete &>> ~/emudeck/emudeck.log

#SECONDTIME
if [ -f "$SECONDTIME" ]; then
		
	text="`printf "<b>EmuDeck will overwrite the following Emulators</b> \nWhich systems do you want me to keep its current configuration <b>untouched</b>?\nWe recomend to keep all of them unchecked so everything gets updated so any possible bug can be fixed.\n If you want to mantain any custom configuration on some emulator select its name on this list"`"
	emusToReset=$(zenity --list \
						--title="EmuDeck" \
						--height=500 \
						--width=250 \
						--ok-label="OK" \
						--cancel-label="Exit" \
						--text="${text}" \
						--checklist \
						--column="" \
						--column="Emulator" \
						1 "RetroArch"\
						2 "PrimeHack" \
						3 "PCSX2" \
						4 "RPCS3" \
						5 "Citra" \
						6 "Dolphin" \
						7 "Duckstation" \
						8 "PPSSPP" \
						9 "Yuzu" \
						10 "Cemu" \
						11 "Cxbx-Reloaded") &>> /dev/null
	clear
	cat ~/dragoonDoriseTools/EmuDeck/logo.ans
	echo -e "${BOLD}EmuDeck ${version}${NONE}"
	ans=$?
	if [ $ans -eq 0 ]; then
		
		if [[ "$emusToReset" == *"RetroArch"* ]]; then
			doRA=false
		fi
		if [[ "$emusToReset" == *"PrimeHack"* ]]; then
			doPrimeHacks=false
		fi
		if [[ "$emusToReset" == *"PCSX2"* ]]; then
			doPCSX2=false
		fi
		if [[ "$emusToReset" == *"RPCS3"* ]]; then
			doRPCS3=false
		fi
		if [[ "$emusToReset" == *"Citra"* ]]; then
			doCitra=false
		fi
		if [[ "$emusToReset" == *"Dolphin"* ]]; then
			doDolphin=false
		fi
		if [[ "$emusToReset" == *"Duckstation"* ]]; then
			doDuck=false
		fi
		if [[ "$emusToReset" == *"PPSSPP"* ]]; then
			doPPSSPP=false
		fi
		if [[ "$emusToReset" == *"Yuzu"* ]]; then
			doYuzu=false
		fi
		if [[ "$emusToReset" == *"Cemu"* ]]; then
			doCemu=false
		fi
		if [[ "$emusToReset" == *"Cxbx-Reloaded"* ]]; then
			doCxbxReloaded=false
		fi
		
	else
		exit
	fi

fi

FILE=~/Desktop/Steam-ROM-Manager-2.3.29.AppImage
if [ -f "$FILE" ]; then
	echo "" &>> /dev/null
else
	echo -e "${BOLD}Installing Steam Rom Manager${NONE}"
	curl -L https://github.com/SteamGridDB/steam-rom-manager/releases/download/v2.3.29/Steam-ROM-Manager-2.3.29.AppImage > ~/Desktop/Steam-ROM-Manager-2.3.29.AppImage
	chmod +x ~/Desktop/Steam-ROM-Manager-2.3.29.AppImage
fi


FILE=$toolsPath/EmulationStation-DE-x64_SteamDeck.AppImage
if [ -f "$FILE" ]; then
	echo "" &>> /dev/null
	doESDE=true
	#for entry in ~/.emulationstation/themes/*
	# do
	#	 
	#	 
	#	 if if [ -d "$entry" ]; then
	#		 cd ~/.emulationstation/$entry &>> /dev/null
	#		 git pull &>> /dev/null
	#	 fi
	#	 cd ~ 
	# done
else
	text="Do you want to install <span weight=\"bold\" foreground=\"red\">EmulationStation DE</span> and all of its RetroArch cores?"
	zenity --question \
		   --title="EmuDeck" \
		   --width=250 \
		   --ok-label="Yes" \
		   --cancel-label="No" \
		   --text="${text}" &>> /dev/null
	ans=$?
	if [ $ans -eq 0 ]; then
		$doESDE=true
		echo "ESDE: Yes" &>> ~/emudeck/emudeck.log
		echo -e "${BOLD}Installing EmulationStation Desktop Edition${NONE}"
		
		curl https://gitlab.com/leonstyhre/emulationstation-de/-/package_files/34287334/download  --output $toolsPath/EmulationStation-DE-x64_SteamDeck.AppImage >> ~/emudeck/emudeck.log
		chmod +x $toolsPath/EmulationStation-DE-x64_SteamDeck.AppImage	
		
		#text="Do you want to install a selection of themes for <span weight=\"bold\" foreground=\"red\">EmulationStation DE</span>?"
		#zenity --question \
		#	   --title="EmuDeck" \
		#	   --width=250 \
		#	   --ok-label="Yes" \
		#	   --cancel-label="No" \
		#	   --text="${text}" &>> /dev/null
		#ans=$?
		#if [ $ans -eq 0 ]; then
		#	echo "ESDE themes: Yes" &>> ~/emudeck/emudeck.log
		#	cd ~/.emulationstation/themes && git clone https://github.com/aitorciki/nostalgia-pure-DE.git ./nostalgia-pure &>> /dev/null
		#	cd ~
		#else
		#	echo "ESDE themes: No" &>> ~/emudeck/emudeck.log
		#fi
					
	else
		echo "ESDE: No" &>> ~/emudeck/emudeck.log
	fi
		
fi

echo -e "Installing PCSX2"
flatpak install flathub net.pcsx2.PCSX2 -y  &>> ~/emudeck/emudeck.log
echo -e "Bad characters" &>> ~/emudeck/emudeck.log
echo -e "Installing PrimeHack"
flatpak install flathub io.github.shiiion.primehack -y &>> ~/emudeck/emudeck.log
#echo -e "Installing melonDS"
#flatpak install flathub net.kuribo64.melonDS -y &>> ~/emudeck/emudeck.log
echo -e "Installing RPCS3"
flatpak install flathub net.rpcs3.RPCS3 -y &>> ~/emudeck/emudeck.log
echo -e "Installing Citra"
flatpak install flathub org.citra_emu.citra -y &>> ~/emudeck/emudeck.log
echo -e "Installing dolphin"
flatpak install flathub org.DolphinEmu.dolphin-emu -y &>> ~/emudeck/emudeck.log
echo -e "Installing DuckStation"
flatpak install flathub org.duckstation.DuckStation -y &>> ~/emudeck/emudeck.log
echo -e "Installing RetroArch"
flatpak install flathub org.libretro.RetroArch -y &>> ~/emudeck/emudeck.log
echo -e "Installing PPSSPP"
flatpak install flathub org.ppsspp.PPSSPP -y &>> ~/emudeck/emudeck.log
#echo -e "Installing Ryujinx"
#flatpak install flathub org.ryujinx.Ryujinx -y &>> ~/emudeck/emudeck.log
echo -e "Installing Yuzu"
flatpak install flathub org.yuzu_emu.yuzu -y &>> ~/emudeck/emudeck.log
echo -e "Installing Flatseal (RPCS3 FIX)"
flatpak install flathub com.github.tchx84.Flatseal -y &>> ~/emudeck/emudeck.log
echo -e "Installing Bottles"
flatpak install flathub com.usebottles.bottles -y &>> ~/emudeck/emudeck.log

#Cemu
echo -e "Installing Cemu"
flatpak remote-add --if-not-exists withertech https://repo.withertech.com/flatpak/withertech.flatpakrepo
flatpak install withertech info.cemu.Cemu -y &>> ~/emudeck/emudeck.log
flatpak install flathub org.winehq.Wine -y &>> ~/emudeck/emudeck.log

# if [ $destination == "SD" ]; then
# 	FILE="/run/media/${sdCard}/Emulation/roms/wiiu/Cemu.exe"
# else
# 	FILE="/home/deck/Emulation/roms/wiiu/Cemu.exe"
# fi
#
# if [ -f "$FILE" ]; then
# 	echo "" &>> /dev/null
# else
# 	curl https://cemu.info/releases/cemu_1.26.2.zip --output $romsPath/wiiu/cemu_1.26.2.zip &>> ~/emudeck/emudeck.log
# 	unzip -o $romsPath/wiiu/cemu_1.26.2.zip -d $romsPath/wiiu/tmp &>> ~/emudeck/emudeck.log
# 	mv $romsPath/wiiu/tmp/*/* $romsPath/wiiu &>> ~/emudeck/emudeck.log
# 	rm -rf $romsPath/wiiu/tmp &>> ~/emudeck/emudeck.log
# 	rm -f $romsPath/wiiu/cemu_1.26.2.zip &>> ~/emudeck/emudeck.log
# fi

echo -e ""

#Cxbx-Reloaded
echo -e "Installing Cxbx-Reloaded"
# Add flatpak permissions
flatpak override --user \
	--filesystem="$toolsPath/Cxbx-Reloaded" \
	--filesystem="$romsPath/xbox" \
	com.usebottles.bottles &>> ~/emudeck/emudeck.log

cxbx_reloaded_version_file="$toolsPath/Cxbx-Reloaded/version"
cxbx_reloaded_version_current=""
cxbx_reloaded_resp="$(curl -sSL \
	-H 'Accept: application/vnd.github.v3+json' \
	'https://api.github.com/repos/Cxbx-Reloaded/Cxbx-Reloaded/releases?per_page=1' | \
	jq -r '.[0].assets[0].browser_download_url,.[0].tag_name')"
cxbx_reloaded_dl_url="$(echo "$cxbx_reloaded_resp" | head -n 1)"
cxbx_reloaded_version="$(echo "$cxbx_reloaded_resp" | tail -n 1)"
if [ -f "$cxbx_reloaded_version_file" ]; then
	cxbx_reloaded_version_current="$(head -n 1 "$cxbx_reloaded_version_file")"
fi
if [ "$cxbx_reloaded_version" != "$cxbx_reloaded_version_current" ]; then
	echo -e "Downloading newer Cxbx-Reloaded release $cxbx_reloaded_version"
	curl -sSLo "$toolsPath/Cxbx-Reloaded.zip" "$cxbx_reloaded_dl_url" &>> ~/emudeck/emudeck.log
	unzip -o "$toolsPath/Cxbx-Reloaded.zip" -d "$toolsPath/Cxbx-Reloaded" &>> ~/emudeck/emudeck.log
	echo "$cxbx_reloaded_version" > "$cxbx_reloaded_version_file"
	rm -f "$toolsPath/Cxbx-Reloaded.zip" &>> ~/emudeck/emudeck.log
fi

# Use a bottle because proton fails to run the emulator
if ! flatpak run --command="bottles-cli" com.usebottles.bottles -j list bottles | \
	jq -e '[.[].Name == "cxbx-reloaded"] | any' &>> /dev/null; then
	echo -e "Setting up bottle for Cxbx-Reloaded, please be patient"
	flatpak run --command="bottles-cli" com.usebottles.bottles new \
		--bottle-name cxbx-reloaded \
		--environment gaming &>> ~/emudeck/emudeck.log
	flatpak run --command="bottles-cli" com.usebottles.bottles edit \
		--bottle cxbx-reloaded --params sync:futex2 &>> ~/emudeck/emudeck.log
fi

echo -e ""

##Generate rom folders
if [ $destination == "SD" ]; then
	echo -ne "${BOLD}Creating roms folder in your SD Card...${NONE}"
else
	echo -ne "${BOLD}Creating roms folder in your home folder...${NONE}"
fi
mkdir -p $romsPath
mkdir -p $biosPath
mkdir -p $biosPath/yuzu/
sleep 3
rsync -r ~/dragoonDoriseTools/EmuDeck/roms/ $romsPath &>> ~/emudeck/emudeck.log
echo -e "${GREEN}OK!${NONE}"
#Steam RomManager
echo -ne "${BOLD}Configuring Steam Rom Manager...${NONE}"
mkdir -p ~/.config/steam-rom-manager/userData/
cp ~/dragoonDoriseTools/EmuDeck/configs/steam-rom-manager/userData/userConfigurations.json ~/.config/steam-rom-manager/userData/userConfigurations.json
sleep 3

sed -i "s|/run/media/mmcblk0p1/Emulation/roms/|${romsPath}|g" ~/.config/steam-rom-manager/userData/userConfigurations.json

sed -i "s|/run/media/mmcblk0p1/Emulation/tools/|${toolsPath}|g" ~/.config/steam-rom-manager/userData/userConfigurations.json

echo -e "${GREEN}OK!${NONE}"

echo -ne "${BOLD}Configuring EmulationStation DE...${NONE}"
mkdir -p ~/.emulationstation/

cp ~/dragoonDoriseTools/EmuDeck/configs/emulationstation/es_settings.xml ~/.emulationstation/es_settings.xml
sed -i "s|/run/media/mmcblk0p1/Emulation/roms/|${romsPath}|g" ~/.emulationstation/es_settings.xml
#sed -i "s|name=\"ROMDirectory\" value=\"/name=\"ROMDirectory\" value=\"${romsPathSed}/g" ~/.emulationstation/es_settings.xml
echo -e "${GREEN}OK!${NONE}"


	
#Emus config
echo -ne "${BOLD}Configuring Steam Input for emulators..${NONE}"
rsync -r ~/dragoonDoriseTools/EmuDeck/configs/steam-input/ ~/.steam/steam/controller_base/templates/
echo -e "${GREEN}OK!${NONE}"
echo -e "${BOLD}Configuring emulators..${NONE}"
echo -e ""
if [ $doRA == true ]; then
	mkdir -p /home/deck/.var/app/org.libretro.RetroArch
	mkdir -p /home/deck/.var/app/org.libretro.RetroArch/config
	mkdir -p /home/deck/.var/app/org.libretro.RetroArch/config/retroarch
	mkdir -p /home/deck/.var/app/org.libretro.RetroArch/config/retroarch/cores
	raUrl="https://buildbot.libretro.com/nightly/linux/x86_64/latest/"
	raCorePath=""
	RAcores=(bsnes_hd_beta_libretro.so flycast_libretro.so gambatte_libretro.so genesis_plus_gx_libretro.so genesis_plus_gx_wide_libretro.so mednafen_lynx_libretro.so mednafen_ngp_libretro.so mednafen_wswan_libretro.so melonds_libretro.so mesen_libretro.so mgba_libretro.so mupen64plus_next_libretro.so nestopia_libretro.so picodrive_libretro.so ppsspp_libretro.so snes9x_libretro.so stella_libretro.so yabasanshiro_libretro.so yabause_libretro.so yabause_libretro.so mame2003_plus_libretro.so mame2010_libretro.so mame_libretro.so melonds_libretro.so fbneo_libretro.so bluemsx_libretro.so desmume_libretro.so sameboy_libretro.so gearsystem_libretro.so mednafen_saturn_libretro.so)
	echo -e "${BOLD}Downloading RetroArch Cores for EmuDeck${NONE}"
	for i in "${RAcores[@]}"
	do
		FILE=/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/cores/${i}
		if [ -f "$FILE" ]; then
			echo -e "${i}...${YELLOW}Already Downloaded${NONE}"	
		else
			curl $raUrl$i.zip --output /home/deck/.var/app/org.libretro.RetroArch/config/retroarch/cores/${i}.zip >> ~/emudeck/emudeck.log
			#rm /home/deck/.var/app/org.libretro.RetroArch/config/retroarch/cores/${i}.zip
			echo -e "${i}...${GREEN}Downloaded!${NONE}"	
		fi
	done
	echo $doESDE;
	if [ $doESDE == true ]; then
		RAcores=(a5200_libretro.so 81_libretro.so atari800_libretro.so bluemsx_libretro.so chailove_libretro.so fbneo_libretro.so freechaf_libretro.so freeintv_libretro.so fuse_libretro.so gearsystem_libretro.so gw_libretro.so hatari_libretro.so lutro_libretro.so mednafen_pcfx_libretro.so mednafen_vb_libretro.so mednafen_wswan_libretro.so mu_libretro.so neocd_libretro.so nestopia_libretro.so nxengine_libretro.so o2em_libretro.so picodrive_libretro.so pokemini_libretro.so prboom_libretro.so prosystem_libretro.so px68k_libretro.so quasi88_libretro.so scummvm_libretro.so squirreljme_libretro.so theodore_libretro.so uzem_libretro.so vecx_libretro.so vice_xvic_libretro.so virtualjaguar_libretro.so x1_libretro.so mednafen_lynx_libretro.so mednafen_ngp_libretro.so mednafen_pce_libretro.so mednafen_pce_fast_libretro.so mednafen_psx_libretro.so mednafen_psx_hw_libretro.so mednafen_saturn_libretro.so mednafen_supafaust_libretro.so mednafen_supergrafx_libretro.so blastem_libretro.so bluemsx_libretro.so bsnes_libretro.so bsnes_mercury_accuracy_libretro.so cap32_libretro.so citra2018_libretro.so citra_libretro.so crocods_libretro.so desmume2015_libretro.so desmume_libretro.so dolphin_libretro.so dosbox_core_libretro.so dosbox_pure_libretro.so dosbox_svn_libretro.so fbalpha2012_cps1_libretro.so fbalpha2012_cps2_libretro.so fbalpha2012_cps3_libretro.so fbalpha2012_libretro.so fbalpha2012_neogeo_libretro.so fceumm_libretro.so fbneo_libretro.so flycast_libretro.so fmsx_libretro.so frodo_libretro.so gambatte_libretro.so gearboy_libretro.so gearsystem_libretro.so genesis_plus_gx_libretro.so genesis_plus_gx_wide_libretro.so gpsp_libretro.so handy_libretro.so kronos_libretro.so mame2000_libretro.so mame2003_plus_libretro.so mame2010_libretro.so mame_libretro.so melonds_libretro.so mesen_libretro.so mesen-s_libretro.so mgba_libretro.so mupen64plus_next_libretro.so nekop2_libretro.so np2kai_libretro.so nestopia_libretro.so parallel_n64_libretro.so pcsx2_libretro.so pcsx_rearmed_libretro.so picodrive_libretro.so ppsspp_libretro.so puae_libretro.so quicknes_libretro.so race_libretro.so sameboy_libretro.so smsplus_libretro.so snes9x2010_libretro.so snes9x_libretro.so stella2014_libretro.so stella_libretro.so tgbdual_libretro.so vbam_libretro.so vba_next_libretro.so vice_x128_libretro.so vice_x64_libretro.so vice_x64sc_libretro.so vice_xscpu64_libretro.so yabasanshiro_libretro.so yabause_libretro.so bsnes_hd_beta_libretro.so swanstation_libretro.so)
		echo -e "${BOLD}Downloading RetroArch Cores for EmulationStation DE${NONE}"
		for i in "${RAcores[@]}"
		do
			FILE=/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/cores/${i}
			if [ -f "$FILE" ]; then
				echo -e "${i}...${YELLOW}Already Downloaded${NONE}"	
			else
				curl $raUrl$i.zip --output /home/deck/.var/app/org.libretro.RetroArch/config/retroarch/cores/${i}.zip >> ~/emudeck/emudeck.log
				#rm /home/deck/.var/app/org.libretro.RetroArch/config/retroarch/cores/${i}.zip
				echo -e "${i}...${GREEN}Downloaded!${NONE}"	
			fi
		done
	fi	
	
	for entry in /home/deck/.var/app/org.libretro.RetroArch/config/retroarch/cores/*.zip
	do
		 unzip -o $entry -d /home/deck/.var/app/org.libretro.RetroArch/config/retroarch/cores/ &>> ~/emudeck/emudeck.log
	done
	
	for entry in /home/deck/.var/app/org.libretro.RetroArch/config/retroarch/cores/*.zip
	do
		 rm -f $entry >> ~/emudeck/emudeck.log
	done
	
	raConfigFile="/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg"
	FILE=/home/deck/.var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg.bak
	if [ -f "$FILE" ]; then
		echo -e "" &>> /dev/null
	else
		echo -ne "Backing up RA..."
		cp /home/deck/.var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg /home/deck/.var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg.bak &>> ~/emudeck/emudeck.log
		echo -e "${GREEN}OK!${NONE}"
	fi
	#mkdir -p /home/deck/.var/app/org.libretro.RetroArch/config/retroarch/overlays
	rsync -r ~/dragoonDoriseTools/EmuDeck/configs/org.libretro.RetroArch/config/ ~/.var/app/org.libretro.RetroArch/config/
	#rsync -r ~/dragoonDoriseTools/EmuDeck/configs/org.libretro.RetroArch/config/retroarch/config/ ~/.var/app/org.libretro.RetroArch/config/retroarch/config
	
	sed -i "s|system_directory = \"~/.var/app/org.libretro.RetroArch/config/retroarch/system\"/system_directory = \"${biosPath}\"/g" $raConfigFile
	
fi
echo -e ""
echo -ne "${BOLD}Applying Emu configurations...${NONE}"
if [ $doPrimeHacks == true ]; then
	FOLDER=~/.var/app/io.github.shiiion.primehack/config_bak
	if [ -d "$FOLDER" ]; then
		echo "" &>> ~/emudeck/emudeck.log
	else
		echo -ne "Backing up PrimeHacks..."
		cp -r ~/.var/app/io.github.shiiion.primehack/config ~/.var/app/io.github.shiiion.primehack/config_bak &>> ~/emudeck/emudeck.log
		echo -e "${GREEN}OK!${NONE}"
	fi
	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/io.github.shiiion.primehack/ ~/.var/app/io.github.shiiion.primehack/ &>> ~/emudeck/emudeck.log
fi
if [ $doDolphin == true ]; then
	FOLDER=~/.var/app/org.DolphinEmu.dolphin-emu/config_bak
	if [ -d "$FOLDER" ]; then
		echo "" &>> ~/emudeck/emudeck.log
	else
		echo -ne "Backing up Dolphin..."
		cp -r ~/.var/app/org.DolphinEmu.dolphin-emu/config ~/.var/app/org.DolphinEmu.dolphin-emu/config_bak &>> ~/emudeck/emudeck.log
		echo -e "${GREEN}OK!${NONE}"
	fi
	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/org.DolphinEmu.dolphin-emu/ ~/.var/app/org.DolphinEmu.dolphin-emu/ &>> ~/emudeck/emudeck.log
fi
if [ $doPCSX2 == true ]; then
	FOLDER=~/.var/app/net.pcsx2.PCSX2/config_bak
	if [ -d "$FOLDER" ]; then
		echo "" &>> ~/emudeck/emudeck.log
	else
		echo -ne "Backing up PCSX2..."
		cp -r ~/.var/app/net.pcsx2.PCSX2/config ~/.var/app/net.pcsx2.PCSX2/config_bak &>> ~/emudeck/emudeck.log
		echo -e "${GREEN}OK!${NONE}"
	fi
	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/net.pcsx2.PCSX2/ ~/.var/app/net.pcsx2.PCSX2/ &>> ~/emudeck/emudeck.log
	#Bios Fix
	sed -i "s|/run/media/mmcblk0p1/Emulation/bios/|${biosPath}|g" ~/.var/app/net.pcsx2.PCSX2/config/PCSX2/inis/PCSX2_ui.ini &>> ~/emudeck/emudeck.log
fi
if [ $doRPCS3 == true ]; then
	FOLDER=~/.var/app/net.rpcs3.RPCS3/config_bak
	if [ -d "$FOLDER" ]; then
		echo "" &>> ~/emudeck/emudeck.log
	else
		echo -ne "Backing up RPCS3..."
		cp -r ~/.var/app/net.rpcs3.RPCS3/config ~/.var/app/net.rpcs3.RPCS3/config_bak &>> ~/emudeck/emudeck.log
		echo -e "${GREEN}OK!${NONE}"
	fi

	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/net.rpcs3.RPCS3/ ~/.var/app/net.rpcs3.RPCS3/ &>> ~/emudeck/emudeck.log
	echo "" > $toolsPath/RPCS3.txt
fi
if [ $doCitra == true ]; then
	FOLDER=~/.var/app/org.citra_emu.citra/config_bak
	if [ -d "$FOLDER" ]; then
		echo "" &>> ~/emudeck/emudeck.log
	else
		echo -ne "Backing up Citra..."
		cp -r ~/.var/app/org.citra_emu.citra/config ~/.var/app/org.citra_emu.citra/config_bak &>> ~/emudeck/emudeck.log
		echo -e "${GREEN}OK!${NONE}"
	fi

	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/org.citra_emu.citra/ ~/.var/app/org.citra_emu.citra/ &>> ~/emudeck/emudeck.log
fi
if [ $doDuck == true ]; then
	FOLDER=~/.var/app/org.duckstation.DuckStation/data_bak
	if [ -d "$FOLDER" ]; then
		echo "" &>> ~/emudeck/emudeck.log
	else
		echo -ne "Backing up DuckStation..."
		cp -r ~/.var/app/org.duckstation.DuckStation/data ~/.var/app/org.duckstation.DuckStation/data_bak &>> ~/emudeck/emudeck.log
		echo -e "${GREEN}OK!${NONE}"
	fi
	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/org.duckstation.DuckStation/ ~/.var/app/org.duckstation.DuckStation/ &>> ~/emudeck/emudeck.log
	sleep 3
	sed -i "s|/run/media/mmcblk0p1/Emulation/bios/|${biosPath}|g" ~/.var/app/org.duckstation.DuckStation/data/duckstation/settings.ini
fi
if [ $doYuzu == true ]; then
	FOLDER=~/.var/app/org.yuzu_emu.yuzu/config
	if [ -d "$FOLDER" ]; then
		echo "" &>> ~/emudeck/emudeck.log
	else
		echo -ne "Backing up Yuzu..."
		cp -r ~/.var/app/org.yuzu_emu.yuzu/config ~/.var/app/org.yuzu_emu.yuzu/config_bak &>> ~/emudeck/emudeck.log
		echo -e "${GREEN}OK!${NONE}"
	fi
	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/org.yuzu_emu.yuzu/ ~/.var/app/org.yuzu_emu.yuzu/ &>> ~/emudeck/emudeck.log
fi
if [ $doCemu == true ]; then
	FOLDER=~/.var/app/info.cemu.Cemu/data
	if [ -d "$FOLDER" ]; then
		echo "" &>> ~/emudeck/emudeck.log
	else
		echo -ne "Backing up Cemu..."
		cp -r ~/.var/app/info.cemu.Cemu/data ~/.var/app/info.cemu.Cemu/data_bak &>> ~/emudeck/emudeck.log
		echo -e "${GREEN}OK!${NONE}"
	fi
	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/info.cemu.Cemu/ ~/.var/app/info.cemu.Cemu/ &>> ~/emudeck/emudeck.log
fi
if [ $doCxbxReloaded == true ]; then
	echo "" &>> ~/emudeck/emudeck.log
	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/Cxbx-Reloaded/ "$toolsPath/Cxbx-Reloaded/" &>> ~/emudeck/emudeck.log
fi
if [ $doRyujinx == true ]; then
	echo "" &>> ~/emudeck/emudeck.log
	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/org.ryujinx.Ryujinx/ ~/.var/app/org.ryujinx.Ryujinx/ &>> ~/emudeck/emudeck.log
fi
if [ $doPPSSPP == true ]; then
	FOLDER=~/.var/app/org.ppsspp.PPSSPP/config_bak
	if [ -d "$FOLDER" ]; then
		echo "" &>> ~/emudeck/emudeck.log
	else
		echo -ne "Backing up PPSSPP..."
		cp -r ~/.var/app/org.ppsspp.PPSSPP/config ~/.var/app/org.ppsspp.PPSSPP/config_bak &>> ~/emudeck/emudeck.log
		echo -e "${GREEN}OK!${NONE}"
	fi
	rsync -avhp ~/dragoonDoriseTools/EmuDeck/configs/org.ppsspp.PPSSPP/ ~/.var/app/org.ppsspp.PPSSPP/ &>> ~/emudeck/emudeck.log
fi

echo -e "${GREEN}OK!${NONE}"

#Symlinks
cd $(echo $romsPath | tr -d '\r')
ln -s segacd megacd &>> ~/emudeck/emudeck.log
ln -s gamecube gc &>> ~/emudeck/emudeck.log
ln -s genesis megadrive &>> ~/emudeck/emudeck.log
ln -s 3ds n3ds &>> ~/emudeck/emudeck.log
ln -s arcade mamecurrent &>> ~/emudeck/emudeck.log
ln -s mame mame2003 &>> ~/emudeck/emudeck.log

cd $(echo $biosPath | tr -d '\r')
cd yuzu
ln -s ~/.var/app/org.yuzu_emu.yuzu/data/yuzu/keys/ ./keys &>> ~/emudeck/emudeck.log
ln -s ~/.var/app/org.yuzu_emu.yuzu/data/yuzu/nand/system/Contents/registered/ ./firmware &>> ~/emudeck/emudeck.log

echo -ne "Cleaning up downloaded files..."	
rm -rf ~/dragoonDoriseTools	

##Validations

#PS1 Bios
PSBios=(SCPH7502 SCPH101 SCPH1000 SCPH1001 SCPH1002 SCPH3000 SCPH3500 SCPH5000 SCPH5500 SCPH5502 SCPH5552 SCPH7000 SCPH7001 SCPH7003 scph7502 scph101 scph1000 scph1001 scph1002 scph3000 scph3500 scph5000 scph5500 scph5502 scph5552 scph7000 scph7001 scph7003)
for i in "${PSBios[@]}"
do
	FILE=${biosPath}${i}.bin
	
	if [ -f "$FILE" ]; then
		PSXBIOS=true			
		break
	else
		PSXBIOS=false
	fi
done	
	
if [ $PSXBIOS == false ]; then
	#text="`printf "<b>PS1 bios not detected</b>\nYou need to copy your BIOS to: ${biosPath}"`"
	text="`printf "<b>PS1 bios not detected</b>\nYou need to copy your BIOS to: \n${biosPath}\nSCPH7502.bin\nSCPH101.bin\nSCPH1000.bin\nSCPH1001.bin\nSCPH1002.bin\nSCPH3000.bin\nSCPH3500.bin\nSCPH5000.bin\nSCPH5500.bin\nSCPH5502.bin\nSCPH5552.bin\nSCPH7000.bin\nSCPH7001.bin\nSCPH7003.bin"`"
	zenity --error \
		  --title="EmuDeck" \
		  --width=400 \
		  --text="${text}" &>> /dev/null
fi

#PS2 Bios - TBD

#Yuzu Keys & Firmware
FILE=~/.var/app/org.yuzu_emu.yuzu/data/yuzu/keys/prod.keys
if [ -f "$FILE" ]; then
	echo -e "" &>> /dev/null
else
		
	text="`printf "<b>Yuzu is not configured</b>\nYou need to copy your Keys and firmware to: \n${biosPath}yuzu/keys\n${biosPath}yuzu/firmware"`"
	zenity --error \
		  --title="EmuDeck" \
		  --width=400 \
		  --text="${text}" &>> /dev/null			   
fi

#PS3 permissions?
RPCS3fixed=$(flatpak info --show-permissions net.rpcs3.RPCS3)
SUB='host'
if [[ "$RPCS3fixed" == *"$SUB"* ]]; then
	echo -e "" &>> /dev/null
else
		
	text="`printf "<b>RPCS3 is not configured</b>\nYou need to open the app Flatseal.\nLook for RPCS3 and there, scroll down to Fylesystem and make sure 'All system files' is <b>checked</b>.\nYou need to do this in order to fix PS3 Games"`"
	zenity --question \
		  --title="EmuDeck" \
		  --width=250 \
		  --ok-label="Open Flatseal" \
		  --cancel-label="Ignore" \
		  --text="${text}" &>> /dev/null
	ans=$?
	if [ $ans -eq 0 ]; then
	   flatpak run com.github.tchx84.Flatseal &>> /dev/null
	else
	   echo "ESDE: No" &>> ~/emudeck/emudeck.log
	fi
		   
fi

##Customizations
FILE=~/emudeck/.custom
if [ -f "$FILE" ]; then
	
	text="Do you want to use your previous customization?"
	zenity --question \
		   --title="EmuDeck" \
		   --width=250 \
		   --ok-label="Yes" \
		   --cancel-label="No" \
		   --text="${text}" &>> /dev/null
	ans=$?
	if [ $ans -eq 0 ]; then
		echo "CustomRemain: Yes" &>> ~/emudeck/emudeck.log
		#find ~/.var/app/org.libretro.RetroArch/config/retroarch/config/ -type f -name "*.cfg" -exec sed -i -e 's/input_overlay_enable = "false"/input_overlay_enable = "true"/g' {} \;	
	else
		echo "CustomRemain: No" &>> ~/emudeck/emudeck.log
		rm ~/emudeck/.custom
		rm ~/emudeck/.bezels
		rm ~/emudeck/.autosave
		
	fi
fi

CUSTOM=~/emudeck/.custom

FILEBEZELS=~/emudeck/.bezels
if [ ! -f "$CUSTOM" ] && [ ! -f "$FILEBEZELS" ]; then
	
	text="Do you want to use Bezels (Overlays) on RetroArch systems?"
	zenity --question \
		   --title="EmuDeck" \
		   --width=250 \
		   --ok-label="Yes" \
		   --cancel-label="No" \
		   --text="${text}" &>> /dev/null
	ans=$?
	if [ $ans -eq 0 ]; then
		echo "Overlays: Yes" &>> ~/emudeck/emudeck.log
		#find ~/.var/app/org.libretro.RetroArch/config/retroarch/config/ -type f -name "*.cfg" -exec sed -i -e 's/input_overlay_enable = "false"/input_overlay_enable = "true"/g' {} \;	
	else
		echo "Overlays: No" &>> ~/emudeck/emudeck.log
		find ~/.var/app/org.libretro.RetroArch/config/retroarch/config/ -type f -name "*.cfg" -exec sed -i -e 's|input_overlay_enable = "true"|input_overlay_enable = "false"|g' {} \;
	fi
	echo "" > ~/emudeck/.bezels
fi
FILESAVE=~/emudeck/.autosave
if [ ! -f "$CUSTOM" ] && [ ! -f "$FILESAVE" ]; then	
	
	text="Do you want to use auto save and auto load for RetroArch systems?"
	zenity --question \
		   --title="EmuDeck" \
		   --width=250 \
		   --ok-label="Yes" \
		   --cancel-label="No" \
		   --text="${text}" &>> /dev/null
	ans=$?
	if [ $ans -eq 0 ]; then
		echo "AutoSaveLoad: Yes" &>> ~/emudeck/emudeck.log
		#sed -i 's/config_save_on_exit = "true"/config_save_on_exit = "false"/g' ~/.var/app/org.libretro.RetroArch/config/retroarch/config/retroarch.cfg &>> ~/emudeck/emudeck.log
		echo "" > ~/emudeck/.autosave
	else
		echo "AutoSaveLoad: No" &>> ~/emudeck/emudeck.log
		sed -i 's|savestate_auto_load = "true"|savestate_auto_load = "save"|g' ~/.var/app/org.libretro.RetroArch/config/retroarch/config/retroarch.cfg &>> ~/emudeck/emudeck.log
		sed -i 's|savestate_auto_save = "true"|savestate_auto_save = "save"|g' ~/.var/app/org.libretro.RetroArch/config/retroarch/config/retroarch.cfg &>> ~/emudeck/emudeck.log
	fi
	echo "" > ~/emudeck/.autosave
fi

echo "" > ~/emudeck/.custom
echo "" > ~/emudeck/.finished

echo -e "${GREEN}OK!${NONE}"
clear

text="`printf "<b>Done!</b>\nRemember to add your games here:\n<b>${romsPath}</b>\nAnd your Bios (PS1, PS2, Yuzu) here:\n<b>${biosPath}</b>\nOpen Steam Rom Manager to add your games to your SteamUI Interface\n/n/nIf you encounter any problem please visit our Discord\n<b>https://discord.gg/b9F7GpXtFP</b>\nTo Update EmuDeck in the future, just run this App again.\nEnjoy!"`"
zenity --question \
	   --title="EmuDeck" \
	   --width=450 \
	   --ok-label="Open Steam Rom Manager" \
	   --cancel-label="Exit" \
	   --text="${text}" &>> /dev/null
ans=$?
if [ $ans -eq 0 ]; then
	cd ~/Desktop/
	./Steam-ROM-Manager-2.3.29.AppImage
	exit
else
	echo -e "Exit" &>> /dev/null
fi
