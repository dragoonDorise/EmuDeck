#!/bin/bash

function import_emudeck(){
	#We make sure the ESDE artwork files and gamelists are in the same place as windows, at least as a symlink...
	ln -sfn "$ESDEscrapData/" "$storagePath/downloaded_media"
	ESDE_symlinkGamelists
	emulationPath="$emulationPath" python3 "$emudeckBackend/tools/importExport.py" import_emudeck "$1" "$2"
}

function export_emudeck(){
	#We make sure the ESDE artwork files and gamelists are in the same place as windows, at least as a symlink...
	ln -sfn "$ESDEscrapData/" "$storagePath/downloaded_media"
	ESDE_symlinkGamelists
	emulationPath="$emulationPath" python3 "$emudeckBackend/tools/importExport.py" export_emudeck "$1" "$2"
}

function get_locations(){
	generate_pythonEnv &> /dev/null
	python3 "$emudeckBackend/tools/importExport.py" get_locations
}
