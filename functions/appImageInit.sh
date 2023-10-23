#!/bin/bash
appImageInit() {
	mkdir -p "$HOME/emudeck/logs"
	SRM_migration
	ESDE_migration
}
