#!/bin/bash
#variables
Supermodel_emuName="Supermodel"
Supermodel_emuType="$emuDeckEmuTypeFlatpak"
Supermodel_emuPath="com.supermodel3.Supermodel"
Supermodel_releaseURL=""
Supermodel_configFile="$HOME/.local/share/flatpak/app/com.supermodel3.Supermodel/current/active/files/bin/Config/Supermodel.ini"

#cleanupOlderThings
Supermodel_cleanup(){
 echo "NYI"
}

#Install
Supermodel_install(){
	installEmuFP "${Supermodel_emuName}" "${Supermodel_emuPath}"
	flatpak override "${Supermodel_emuPath}" --filesystem=host --user
	flatpak override "${Supermodel_emuPath}" --share=network --user
}

#ApplyInitialSettings
Supermodel_init(){
	configEmuFP "${Supermodel_emuName}" "${Supermodel_emuPath}" "true"
	Supermodel_setupStorage
	Supermodel_setEmulationFolder
	Supermodel_setupSaves
}

#update
Supermodel_update(){
	configEmuFP "${Supermodel_emuName}" "${Supermodel_emuPath}"
	Supermodel_setupStorage
	Supermodel_setEmulationFolder
	Supermodel_setupSaves
}

#ConfigurePaths
Supermodel_setEmulationFolder(){
	setMSG "Setting $Supermodel_emuName Emulation Folder"
	
	mkdir -p $HOME/.supermodel/Analysis $HOME/.supermodel/Log $HOME/.supermodel/NVRAM
	cp -r $HOME/.local/share/flatpak/app/com.supermodel3.Supermodel/current/active/files/bin/Config $HOME/.supermodel
	cp -r $HOME/.local/share/flatpak/app/com.supermodel3.Supermodel/current/active/files/bin/Assets $HOME/.supermodel
	cp -r $HOME/.local/share/flatpak/app/com.supermodel3.Supermodel/current/active/files/bin/Docs $HOME/.supermodel
}

#SetupSaves
Supermodel_setupSaves(){
	savepath_directoryOpt='savepath='
	newsavepath_directoryOpt="$savepath_directoryOpt""$savesPath/Supermodel/saves"
	changeLine "$savepath_directoryOpt" "$newsavepath_directoryOpt" "$Supermodel_configFile"

	moveSaveFolder Supermodel saves "$HOME/.var/app/org.Supermodel.Supermodel/data/Supermodel/saves"
}


#SetupStorage
Supermodel_setupStorage(){
	echo "NYI"
}


#WipeSettings
Supermodel_wipe(){
	echo "NYI"
}


#Uninstall
Supermodel_uninstall(){
    flatpak uninstall "$Supermodel_emuPath" --user -y
}

#setABXYstyle
Supermodel_setABXYstyle(){
	echo "NYI"
}

#Migrate
Supermodel_migrate(){
	echo "NYI"
}

#WideScreenOn
Supermodel_wideScreenOn(){
	echo "NYI"
}

#WideScreenOff
Supermodel_wideScreenOff(){
	echo "NYI"
}

#BezelOn
Supermodel_bezelOn(){
echo "NYI"
}

#BezelOff
Supermodel_bezelOff(){
echo "NYI"
}

#finalExec - Extra stuff
Supermodel_finalize(){
	echo "NYI"
}

Supermodel_IsInstalled(){
	isFpInstalled "$Supermodel_emuPath"
}

Supermodel_resetConfig(){
	Supermodel_init &>/dev/null && echo "true" || echo "false"
}