#!/bin/bash
appImageInit() {
	mkdir -p "$HOME/emudeck/logs"
	rm -rf "$toolsPath/launchers/esde/emulationstation-de.sh"
	SRM_migration
	ESDE_migration

	SRM_createDesktopShortcut
	ESDE_createDesktopShortcut
}
