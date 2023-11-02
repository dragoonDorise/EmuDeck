#!/bin/bash
appImageInit() {

	if [ "$system" == "chimeraos" ]; then
		ESDE_chimeraOS
		mkdir -p $HOME/Applications

		downloads_dir="$HOME/Downloads"
		destination_dir="$HOME/Applications"
		file_name="EmuDeck"

		find "$downloads_dir" -type f -name "*$file_name*.AppImage" -exec mv {} "$destination_dir/$file_name.AppImage" \;

	fi

	#Autofixes, put here functions that make under the hood fixes.
	autofix_duplicateESDE
	#autofix_raSavesFolders
	autofix_lnk
	SRM_migration
	ESDE_migration
	SRM_createDesktopShortcut
	ESDE_createDesktopShortcut

	# Init functions
	mkdir -p "$HOME/emudeck/logs"

}
