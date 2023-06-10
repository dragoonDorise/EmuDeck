#!/bin/bash
#variables
Xenia_emuName="Xenia"
Xenia_emuType="windows"
Xenia_emuPath="${romsPath}/xbox360/xenia_canary.exe"
Xenia_releaseURL_master="https://github.com/xenia-project/release-builds-windows/releases/latest/download/xenia_master.zip"
Xenia_releaseURL_canary="https://github.com/xenia-canary/xenia-canary/releases/latest/download/xenia_canary.zip"
Xenia_XeniaSettings="${romsPath}/xbox360/xenia-canary.config.toml"

#cleanupOlderThings
Xenia_cleanup(){
	echo "NYI"
}

#Install
Xenia_install(){
	local version
	version=$1
	local showProgress="$2"

	if [[ "$version" == "master" ]]; then
		Xenia_releaseURL="$Xenia_releaseURL_master"
	else
		Xenia_releaseURL="$Xenia_releaseURL_canary"
	fi
	local name="$Xenia_emuName-$version"

	setMSG "Installing Xenia $version"		

	#need to look at standardizing exe name; or download both?  let the user choose at runtime?
	#curl -L "$Xenia_releaseURL" --output "$romsPath"/xbox360/xenia.zip
	if safeDownload "$name" "$Xenia_releaseURL" "$romsPath/xbox360/xenia.zip" "$showProgress"; then
		mkdir -p "$romsPath"/xbox360/tmp
		unzip -o "$romsPath"/xbox360/xenia.zip -d "$romsPath"/xbox360/tmp
		rsync -avzh "$romsPath"/xbox360/tmp/ "$romsPath"/xbox360/
		rm -rf "$romsPath"/xbox360/tmp
		rm -f "$romsPath"/xbox360/xenia.zip
	else
		return 1
	fi

	cp "$EMUDECKGIT/tools/launchers/xenia.sh" "${toolsPath}/launchers/xenia.sh"
	sed -i "s|/run/media/mmcblk0p1/Emulation/tools|${toolsPath}|g" "${toolsPath}/launchers/xenia.sh"
	sed -i "s|/run/media/mmcblk0p1/Emulation/roms|${romsPath}|" "${toolsPath}/launchers/xenia.sh"
	mkdir -p "$romsPath/xbox360/roms/xbla"

#	if [[ "$launchLine"  == *"PROTONLAUNCH"* ]]; then
#		changeLine '"${PROTONLAUNCH}"' "$launchLine" "${toolsPath}/launchers/xenia.sh"
#	fi
	chmod +x "${toolsPath}/launchers/xenia.sh"	

    Xenia_getPatches

	createDesktopShortcut   "$HOME/.local/share/applications/xenia.desktop" \
							"Xenia (Proton)" \
							"${toolsPath}/launchers/xenia.sh" \
							"False"
}

#ApplyInitialSettings
Xenia_init(){
	setMSG "Initializing Xenia Config"
	rsync -avhp "$EMUDECKGIT/configs/xenia/" "$romsPath/xbox360"
	mkdir -p "$romsPath/xbox360/roms/xbla"
	Xenia_addESConfig
}

Xenia_addESConfig(){
	if [[ $(grep -rnw "$es_systemsFile" -e 'xbox360') == "" ]]; then
		xmlstarlet ed -S --inplace --subnode '/systemList' --type elem --name 'system' \
		--var newSystem '$prev' \
		--subnode '$newSystem' --type elem --name 'name' -v 'xbox360' \
		--subnode '$newSystem' --type elem --name 'fullname' -v 'Microsoft Xbox 360' \
		--subnode '$newSystem' --type elem --name 'path' -v '%ROMPATH%/xbox360/roms' \
		--subnode '$newSystem' --type elem --name 'extension' -v '.iso .ISO . .xex .XEX' \
		--subnode '$newSystem' --type elem --name 'commandP' -v "/usr/bin/bash ${toolsPath}/launchers/xenia.sh z:%ROM%" \
		--insert '$newSystem/commandP' --type attr --name 'label' --value "Xenia (Proton)" \
		--subnode '$newSystem' --type elem --name 'platform' -v 'xbox360' \
		--subnode '$newSystem' --type elem --name 'theme' -v 'xbox360' \
		-r 'systemList/system/commandP' -v 'command' \
		"$es_systemsFile"

		#format doc to make it look nice
		xmlstarlet fo "$es_systemsFile" > "$es_systemsFile".tmp && mv "$es_systemsFile".tmp "$es_systemsFile"
	fi
	#Custom Systems config end
}

function Xenia_getPatches() {
  local patches_dir="${romsPath}/xbox360/"
  local patches_repo="https://github.com/xenia-canary/game-patches.git"
  local patches_branch="main"

  # Create the patches directory if it doesn't exist
  if [ ! -d "$patches_dir" ]; then
    mkdir -p "$patches_dir"
  fi

  # Initialize a new Git repository in the patches directory
  cd "$patches_dir" || exit
  if ! git rev-parse --git-dir > /dev/null 2>&1; then
    git init
  fi

  # Set up a remote origin for the repository
  if ! git remote get-url origin > /dev/null 2>&1; then
    git remote add origin "$patches_repo"
  fi

  # Configure Git to perform a sparse checkout of the patches folder
  if ! git config core.sparsecheckout > /dev/null 2>&1; then
    git config core.sparsecheckout true
  fi
  if ! grep -Fxq "patches/*" .git/info/sparse-checkout; then
    echo "patches/*" >> .git/info/sparse-checkout
  fi

  # Pull the latest changes from the remote repository
  git fetch --depth=1 origin "$patches_branch"
  if git merge FETCH_HEAD > /dev/null 2>&1; then
    echo "Patches updated successfully"
  else
    # If the merge failed, reset the local changes and try again
    git reset --hard HEAD > /dev/null 2>&1
    git clean -fd > /dev/null 2>&1
    git fetch --depth=1 origin "$patches_branch"
    if git merge FETCH_HEAD > /dev/null 2>&1; then
      echo "Patches updated successfully"
    else
      echo "Error: Failed to update patches"
    fi
  fi
}


#update
Xenia_update(){
	echo "NYI"
}

#ConfigurePaths
Xenia_setEmulationFolder(){
	echo "NYI"
}

#SetupSaves
Xenia_setupSaves(){
	echo "NYI"
}


#SetupStorage
Xenia_setupStorage(){
	echo "NYI"
}


#WipeSettings
Xenia_wipeSettings(){
	echo "NYI"
}


#Uninstall
Xenia_uninstall(){
	rm -rf "${Xenia_emuPath}"
}

#setABXYstyle
Xenia_setABXYstyle(){
	echo "NYI"
}

#Migrate
Xenia_migrate(){
	echo "NYI"
}

#WideScreenOn
Xenia_wideScreenOn(){
	echo "NYI"
}

#WideScreenOff
Xenia_wideScreenOff(){
	echo "NYI"
}

#BezelOn
Xenia_bezelOn(){
	echo "NYI"
}

#BezelOff
Xenia_bezelOff(){
	echo "NYI"
}

#finalExec - Extra stuff
Xenia_finalize(){
	Xenia_cleanup
}

Xenia_IsInstalled(){
	if [ -e "$Xenia_emuPath" ]; then
		echo "true"
	else
		echo "false"
	fi
}

Xenia_resetConfig(){
	mv  "$Xenia_XeniaSettings" "$Xenia_XeniaSettings.bak" &>/dev/null
	Xenia_init &>/dev/null && echo "true" || echo "false"
}