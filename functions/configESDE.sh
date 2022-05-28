#!/bin/bash
configESDE(){			
	setMSG "Configuring EmulationStation DE..."
	mkdir -p ~/.emulationstation/
	#Cemu (Proton) commented until we get it right
	mkdir -p ~/.emulationstation/custom_systems/
	cp ~/dragoonDoriseTools/EmuDeck/configs/emulationstation/custom_systems/es_systems.xml ~/.emulationstation/custom_systems/es_systems.xml
	sed -i "s|/run/media/mmcblk0p1/Emulation/tools/launchers/cemu.sh|${toolsPath}launchers/cemu.sh|" ~/.emulationstation/custom_systems/es_systems.xml
	#Commented until we get CEMU flatpak working
	#rsync -r ~/dragoonDoriseTools/EmuDeck/configs/emulationstation/ ~/.emulationstation/
	cp ~/dragoonDoriseTools/EmuDeck/configs/emulationstation/es_settings.xml ~/.emulationstation/es_settings.xml
	sed -i "s|/run/media/mmcblk0p1/Emulation/roms/|${romsPath}|g" ~/.emulationstation/es_settings.xml
	
	#Configure Downloaded_media folder
	esDE_MediaDir="<string name=\"MediaDirectory\" value=\""${ESDEscrapData}"\" />"
	#search for media dir in xml, if not found, change to ours.
	mediaDirFound=$(grep -rnw  ~/.emulationstation/es_settings.xml -e 'MediaDirectory')
	if [[ $mediaDirFound == '' ]]; then
		sed -i -e '$a'"${esDE_MediaDir}"  ~/.emulationstation/es_settings.xml # use config file instead of link
	fi
	#sed -i "s|name=\"ROMDirectory\" value=\"/name=\"ROMDirectory\" value=\"${romsPathSed}/g" ~/.emulationstation/es_settings.xml
	mkdir -p ~/.emulationstation/themes/
	git clone https://github.com/dragoonDorise/es-theme-epicnoir.git ~/.emulationstation/themes/es-epicnoir &>> /dev/null
	cd ~/.emulationstation/themes/es-epicnoir && git pull
	echo -e "OK!"
	
	#Do this properly with wildcards
	if [[ "$esdeTheme" == *"EPICNOIR"* ]]; then
		sed -i "s|rbsimple-DE|es-epicnoir|" ~/.emulationstation/es_settings.xml 
		sed -i "s|modern-DE|es-epicnoir|" ~/.emulationstation/es_settings.xml 
		sed -i "s|es-epicnoir|es-epicnoir|" ~/.emulationstation/es_settings.xml 
	fi
	if [[ "$esdeTheme" == *"MODERN-DE"* ]]; then
		sed -i "s|rbsimple-DE|modern-DE|" ~/.emulationstation/es_settings.xml 
		sed -i "s|modern-DE|modern-DE|" ~/.emulationstation/es_settings.xml 
		sed -i "s|es-epicnoir|modern-DE|" ~/.emulationstation/es_settings.xml 
	fi
	if [[ "$esdeTheme" == *"RBSIMPLE-DE"* ]]; then
		sed -i "s|rbsimple-DE|rbsimple-DE|" ~/.emulationstation/es_settings.xml 
		sed -i "s|modern-DE|rbsimple-DE|" ~/.emulationstation/es_settings.xml 
		sed -i "s|es-epicnoir|rbsimple-DE|" ~/.emulationstation/es_settings.xml 
	fi
	
	
	#ESDE default emulators
	mkdir -p  ~/.emulationstation/gamelists/
	setESDEEmus 'Genesis Plus GX' gamegear
	setESDEEmus 'Gambatte' gb
	setESDEEmus 'Gambatte' gbc
	setESDEEmus 'Dolphin (Standalone)' gc
	setESDEEmus 'PPSSPP (Standalone)' psp
	setESDEEmus 'Dolphin (Standalone)' wii
	setESDEEmus 'Mesen' nes
	setESDEEmus 'DOSBox-Pure' dos
	setESDEEmus 'PCSX2 (Standalone)' ps2
	setESDEEmus 'melonDS' nds
	setESDEEmus 'Citra (Standalone)' n3ds

	#Symlinks for ESDE compatibility
	cd $(echo $romsPath | tr -d '\r') 
	ln -sn gamecube gc 
	ln -sn 3ds n3ds 
	ln -sn arcade mamecurrent 
	ln -sn mame mame2003 
	ln -sn lynx atarilynx 

}