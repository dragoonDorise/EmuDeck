#!/bin/bash
#variables
Model2_emuName="Model 2 (Proton)"
Model2_emuType="$emuDeckEmuTypeWindows"
Model2_emuPath="${romsPath}/model2/EMULATOR.EXE"
Model2_configFile="${romsPath}/model2/EMULATOR.INI"
ULWGL_toolPath="${toolsPath}/ULWGL"
ULWGL_githubRepo="https://github.com/Open-Wine-Components/ULWGL-launcher.git" 
ULWGL_githubBranch="main"

#cleanupOlderThings
Model2_cleanup(){
	echo "NYI"
}

#Install
Model2_install(){
	setMSG "Installing $Model2_emuName"

	downloadModel2=$(wget -m -nd -A "1.1a.7z" -O "$romsPath/model2/Model2.7z" "https://github.com/PhoenixInteractiveNL/edc-repo0004/raw/master/m2emulator/1.1a.7z")

	local showProgress="$1"
    if $downloadModel2; then
		7za e -y "$romsPath/model2/Model2.7z" -o"$romsPath/model2"
		rm -f "$romsPath/model2/Model2.7z"
	else
		return 1
	fi

  # Create the ROMs directory if it doesn't exist
  if [ ! -d "$romsPath/model2/roms" ]; then
    mkdir -p "$romsPath/model2/roms"
  fi

  # Create the pfx directory if it doesn't exist
  if [ ! -d "$romsPath/model2/roms/pfx" ]; then
    mkdir -p "$romsPath/model2/roms/pfx"
  fi


}

#ApplyInitialSettings
Model2_init(){
	setMSG "Initializing $Model2_emuName settings."	
	rsync -avhp "$EMUDECKGIT/configs/model2/" "${romsPath}/model2" --backup --suffix=.bak
	if [ -e "$Model2_configFile.bak" ]; then
		mv -f "$Model2_configFile.bak" "$Model2_configFile" #retain Model 2 settings
	fi
	Model2_addESConfig
	Model2_downloadProtonGE
	Model2_createDesktopShortcut
	Model2ULWGL_install	

}


Model2_createDesktopShortcut(){

	createDesktopShortcut   "$HOME/.local/share/applications/Model 2 (Proton).desktop" \
							"Model 2 Emulator (Proton)" \
							"${toolsPath}/launchers/model2.sh"  \
							"False"

}

Model2_addESConfig(){
	if [[ $(grep -rnw "$es_systemsFile" -e 'model2') == "" ]]; then
		xmlstarlet ed -S --inplace --subnode '/systemList' --type elem --name 'system' \
		--var newSystem '$prev' \
		--subnode '$newSystem' --type elem --name 'name' -v 'model2' \
		--subnode '$newSystem' --type elem --name 'fullname' -v 'Sega Model 2' \
		--subnode '$newSystem' --type elem --name 'path' -v '%ROMPATH%/model2/roms' \
		--subnode '$newSystem' --type elem --name 'extension' -v '.zip .ZIP' \
		--subnode '$newSystem' --type elem --name 'commandP' -v "/usr/bin/bash ${toolsPath}/launchers/model2.sh %BASENAME%" \
		--insert '$newSystem/commandP' --type attr --name 'label' --value "Model 2 Emulator (Proton)" \
		--subnode '$newSystem' --type elem --name 'platform' -v 'model2' \
		--subnode '$newSystem' --type elem --name 'theme' -v 'model2' \
		-r 'systemList/system/commandP' -v 'command' \
		"$es_systemsFile"

		#format doc to make it look nice
		xmlstarlet fo "$es_systemsFile" > "$es_systemsFile".tmp && mv "$es_systemsFile".tmp "$es_systemsFile"
		echo "Model 2 added to EmulationStation-DE custom_systems"
	fi
}

#update
Model2_update(){
	setMSG "Updating $Model2_emuName settings."	
	rsync -avhp "$EMUDECKGIT/configs/model2/" "${romsPath}/model2" --ignore-existing
	Model2ULWGL_install	
}


#ConfigurePaths
Model2_setEmulationFolder(){
	setMSG "Setting $Model2_emuName Emulation Folder"	
	
	echo "NYI"
}

#WipeSettings
Model2_wipeSettings(){
	rm -rf $Model2_Settings
}


#Uninstall
Model2_uninstall(){
	setMSG "Uninstalling $Model2_emuName."
	rm -rf "${Model2_emuPath}"
    rm -rf "$HOME/.local/share/applications/Model 2 (Proton).desktop"
    Model2_wipeSettings
}

#setABXYstyle
Model2_setABXYstyle(){
		echo "NYI"
}

#finalExec - Extra stuff
Model2_finalize(){
	Model2_cleanup
}

Model2_IsInstalled(){
	if [ -e "$Model2_emuPath" ]; then
		echo "true"
	else
		echo "false"
	fi
}

Model2_resetConfig(){
	mv  "$Model2_configFile" "$Model2_configFile.bak" &>/dev/null
	Model2_init &>/dev/null && echo "true" || echo "false"
}

Model2_downloadProtonGE(){

	if [ -d "${HOME}/.local/share/Steam" ]; then
		STEAMPATH="${HOME}/.local/share/Steam"
	elif [ -d "${HOME}/.steam/steam" ]; then
		STEAMPATH="${HOME}/.steam/steam"
	else
		echo "Steam install not found"
	fi

	if [ ! -d "$STEAMPATH/compatibilitytools.d/GE-Proton8-27/" ]; then
		echo "Installing GE-Proton8-27"
		downloadProtonGE=$(wget -m -nd -A "GE-Proton8-27.tar.gz" -O "$STEAMPATH/compatibilitytools.d/GE-Proton8-27.tar.gz" "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton8-27/GE-Proton8-27.tar.gz")
			local showProgress="$1"

		if $downloadProtonGE; then
			tar -xvzf "$STEAMPATH/compatibilitytools.d/GE-Proton8-27.tar.gz" -C "$STEAMPATH/compatibilitytools.d"
			rm -f "$STEAMPATH/compatibilitytools.d/GE-Proton8-27.tar.gz"
		else
			return 1
		fi
	else
		echo "GE-Proton8-27 already installed"
		return 1
	fi

	if [ ! -f "$STEAMPATH/compatibilitytools.d/GE-Proton8-27/protonfixes/gamefixes/3965123026.py" ]; then
		echo "Downloading Model 2 gamefixes.py"
		rsync -avhp "$EMUDECKGIT/configs/ULWGL/ulwgl-model2.py" "$STEAMPATH/compatibilitytools.d/GE-Proton8-27/protonfixes/gamefixes" --ignore-existing
	else
		echo "Model 2 gamefixes.py already downloaded"
		return 1
	fi
}

function Model2ULWGL_install() {

  # Create the ULWGL directory if it doesn't exist
  if [ ! -d "$ULWGL_toolPath" ]; then
    mkdir -p "$ULWGL_toolPath"
  fi

  # Initialize a new Git repository in the ULWGL directory
  cd "$ULWGL_toolPath" || exit
  if ! git rev-parse --git-dir > /dev/null 2>&1; then
    git init
  fi

  # Set up a remote origin for the repository
  if ! git remote get-url origin > /dev/null 2>&1; then
    git remote add origin "$ULWGL_githubRepo"
  fi

  # Configure Git to perform a sparse checkout of the ULWGL folder
  if ! git config core.sparsecheckout > /dev/null 2>&1; then
    git config core.sparsecheckout true
  fi
  if ! grep -Fxq "/*" .git/info/sparse-checkout; then
    echo "/*" >> .git/info/sparse-checkout
  fi

  # Pull the latest changes from the remote repository
  git fetch --depth=1 origin "$ULWGL_githubBranch"
  if git merge FETCH_HEAD > /dev/null 2>&1; then
    echo "ULWGL updated successfully"
  else
    # If the merge failed, reset the local changes and try again
    git reset --hard origin/master > /dev/null 2>&1
    git clean -fd > /dev/null 2>&1
    git fetch --depth=1 origin "$ULWGL_githubBranch"
    if git merge FETCH_HEAD > /dev/null 2>&1; then
      echo "ULWGL updated successfully"
    else
      echo "Error: Failed to update ULWGL"
    fi
  fi
}


