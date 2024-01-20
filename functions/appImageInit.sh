#!/bin/bash
appImageInit() {

	#Autofixes, put here functions that make under the hood fixes.
	autofix_duplicateESDE
	autofix_lnk
	SRM_migration # 2.2 Changes
	ESDE_migration # 2.2 Changes
	autofix_dynamicParsers # 2.2 Changes


	#Force SRM appimage move in case the migration fails
	mv "${toolsPath}/srm/Steam-ROM-Manager.AppImage" "${toolsPath}/Steam ROM Manager.AppImage" &>> /dev/null

	#Xenia temp fix
	if [ "$(Xenia_IsInstalled)" == "true" ]; then
		 setSetting doInstallXenia "true"
	  fi

	# Init functions
	mkdir -p "$HOME/emudeck/logs"
	mkdir -p "$HOME/emudeck/feeds"

}
