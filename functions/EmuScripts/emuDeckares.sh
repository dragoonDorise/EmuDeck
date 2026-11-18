#!/usr/bin/env bash
#variables
ares_emuName="ares"
ares_emuType="$emuDeckEmuTypeFlatpak"
ares_emuPath="dev.ares.ares"
ares_configFile="$HOME/.var/app/dev.ares.ares/data/ares/settings.bml"

#cleanupOlderThings
ares_cleanup(){
 echo "NYI"
}

#Install
ares_install() {
	statInstall "ares"
	setMSG "Installing $ares_emuName"

	installEmuFP "${ares_emuName}" "${ares_emuPath}" "emulator" ""
}

#ApplyInitialSettings

ares_init() {

  setMSG "Initializing $ares_emuName settings."

	configEmuFP "${ares_emuName}" "${ares_emuPath}" "true"
	ares_setupStorage
	ares_setEmulationFolder
	ares_setupSaves
	#ares_addSteamInputProfile
	ares_getDefaultShaders
  	ares_getQuarkShaders
	ares_addESConfig
	#SRM_createParsers
	ares_flushEmulatorLauncher
}

#ConfigurePaths
ares_setEmulationFolder(){
	setMSG "Setting $ares_emuName Emulation Folder"


  # ROM Paths
	UserROMsPath='/home/deck/Emulation/roms/'
	sed -i "s|$UserROMsPath|${romsPath}\/|g" "$ares_configFile"

	# BIOS Paths
	UserBIOSPath='/home/deck/Emulation/bios/'
	sed -i "s|$UserBIOSPath|${biosPath}\/|g" "$ares_configFile"

}

#SetupSaves
ares_setupSaves(){

  # Create saves folder
 	mkdir -p "${savesPath}/ares/"

	# Set saves path
	UserSavesPath='/home/deck/Emulation/saves'
	sed -i "s|$UserSavesPath|${savesPath}|g" "$ares_configFile"
}


#SetupStorage
ares_setupStorage(){

	# Create storage folder
	mkdir -p "${storagePath}/ares/"
	mkdir -p "${storagePath}/ares/screenshots"

	# Set Storage path
	UserStoragePath='/home/deck/Emulation/storage'
	sed -i "s|$UserStoragePath|${storagePath}|g" "$ares_configFile"
}

ares_addESConfig(){
	echo "NYI"
}

function ares_getDefaultShaders() {
	local systemShadersFolder="/var/lib/flatpak/app/dev.ares.ares/x86_64/stable/active/files/share/ares/Shaders"
	local userShadersFolder="$HOME/.local/share/flatpak/app/dev.ares.ares/current/active/files/share/ares/Shaders"
	local flatpakShadersFolder="$HOME/.var/app/$ares_emuPath/data/ares/Shaders"

	if [ ! -d "$flatpakShadersFolder" ]; then
	mkdir -p "$flatpakShadersFolder"
	fi

    if [ -d $systemShadersFolder ]; then
        cp -r $systemShadersFolder/* $flatpakShadersFolder
        echo "System install found"
        echo "ares shaders copied"
    elif [ -d $userShadersFolder ]; then
        cp -r $userShadersFolder/* $flatpakShadersFolder
        echo "User install found"
        echo "ares shaders copied"
    else
        echo "ares install not found"
    fi


}

function ares_getQuarkShaders() {
  local shaderfolders_dir="$HOME/.var/app/$ares_emuPath/data/ares/Shaders"
  local quarkshaders_repo="https://github.com/hizzlekizzle/quark-shaders.git"
  local shaders_branch="master"

  # Create the patches directory if it doesn't exist
  if [ ! -d "$shaderfolders_dir" ]; then
    mkdir -p "$shaderfolders_dir"
  fi

  # Initialize a new Git repository in the patches directory
  cd "$shaderfolders_dir" || exit
  if ! git rev-parse --git-dir > /dev/null 2>&1; then
    git init
  fi

  # Set up a remote origin for the repository
  if ! git remote get-url origin > /dev/null 2>&1; then
    git remote add origin "$quarkshaders_repo"
  fi

  # Configure Git to perform a sparse checkout of the patches folder
  if ! git config core.sparsecheckout > /dev/null 2>&1; then
    git config core.sparsecheckout true
  fi
  if ! grep -Fxq "/*" .git/info/sparse-checkout; then
    echo "/*" >> .git/info/sparse-checkout
  fi

  # Pull the latest changes from the remote repository
  git fetch --depth=1 origin "$shaders_branch"
  if git merge FETCH_HEAD > /dev/null 2>&1; then
    echo "Quark Shaders updated successfully"
  else
    # If the merge failed, reset the local changes and try again
    git reset --hard HEAD > /dev/null 2>&1
    git clean -fd > /dev/null 2>&1
    git fetch --depth=1 origin "$shaders_branch"
    if git merge FETCH_HEAD > /dev/null 2>&1; then
      echo "Quark Shaders updated successfully"
    else
      echo "Error: Failed to update Quark Shaders"
    fi
  fi
}

#WipeSettings
ares_wipe(){
	rm -rf "$HOME/.var/app/$ares_emuPath"
}

#Uninstall
ares_uninstall(){
    uninstallEmuFP "${ares_emuName}" "${ares_emuPath}" "emulator" ""
}

#setABXYstyle
ares_setABXYstyle(){
	echo "NYI"
}

#Migrate
ares_migrate(){
	echo "NYI"
}

#WideScreenOn
ares_wideScreenOn(){
	echo "NYI"
}

#WideScreenOff
ares_wideScreenOff(){
	echo "NYI"
}

#BezelOn
ares_bezelOn(){
echo "NYI"
}

#BezelOff
ares_bezelOff(){
echo "NYI"
}

ares_IsInstalled(){
	isFpInstalled "$ares_emuPath"
}

ares_resetConfig(){
	ares_init &>/dev/null && echo "true" || echo "false"
}

ares_addSteamInputProfile(){
	addSteamInputCustomIcons
	#setMSG "Adding $ares_emuName Steam Input Profile."
	#rsync -r "$emudeckBackend/configs/steam-input/ares_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
}

#finalExec - Extra stuff
ares_finalize(){
	echo "NYI"
}

ares_flushEmulatorLauncher(){


	flushEmulatorLaunchers "$ares_emuName"

}

ares_addToSteam(){
	setMSG "Adding ares to Steam"
	add_to_steam "ares" "ares" "$toolsPath/launchers/ares-emu.sh" "$HOME/Applications/" "" "Emulation"
}
