#!/bin/bash
appImageInit() {

	#Autofixes, put here functions that make under the hood fixes.
	autofix_duplicateESDE
	autofix_lnk
	SRM_migration # 2.2 Changes
	ESDE_migration # 2.2 Changes
	autofix_dynamicParsers # 2.2 Changes

	# Init functions
	mkdir -p "$HOME/emudeck/logs"
	mkdir -p "$HOME/emudeck/feeds"

}
