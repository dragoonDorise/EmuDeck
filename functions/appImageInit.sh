#!/bin/bash
appImageInit() {

	#Autofixes, put here functions that make under the hood fixes.
	autofix_duplicateESDE
	#autofix_raSavesFolders
	autofix_lnk
	SRM_migration
	ESDE_migration
	SRM_createDesktopShortcut
	ESDE_createDesktopShortcut
	autofix_dynamicParsers

	# Init functions
	mkdir -p "$HOME/emudeck/logs"

}
