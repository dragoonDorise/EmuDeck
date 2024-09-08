#!/bin/bash

# Variables
Warehouse_emuName="Warehouse"
Warehouse_emuType="$emuDeckEmuTypeFlatpak"
Warehouse_emuPath="io.github.flattool.Warehouse"
Warehouse_releaseURL=""

# Install
Warehouse_install() {
	setMSG "Installing $Warehouse_emuName."
	installEmuFP "${Warehouse_emuName}" "${Warehouse_emuPath}" "genericapplication" ""
}

# ApplyInitialSettings
Warehouse_init() {
	setMSG "Initializing $Warehouse_emuName settings."	
	configEmuFP "$Warehouse_emuName" "$Warehouse_emuPath" "true"
}

# Update flatpak & launcher script
Warehouse_update() {
	setMSG "Updating $Warehouse_emuName settings."
	updateEmuFP "${Warehouse_emuName}" "${Warehouse_emuPath}" "genericapplication" ""
}

# Uninstall
Warehouse_uninstall() {
	setMSG "Uninstalling $Warehouse_emuName."
    uninstallEmuFP "$Warehouse_emuName" "$Warehouse_emuPath" "genericapplication" ""
}

# Check if installed
Warehouse_IsInstalled() {
	if [ "$(flatpak --columns=app list | grep "$Warehouse_emuPath")" == "$Warehouse_emuPath" ]; then
		echo true
		return 1
	else
		echo false
		return 0
	fi
}

# Import steam profile
Warehouse_addSteamInputProfile() {
	echo "NYI"
}
