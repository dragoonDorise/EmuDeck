#!/bin/bash

function import_emudeck(){
	emulationPath="$emulationPath" ESDEscrapData="$ESDEscrapData" python3 "$emudeckBackend/tools/importExport.py" import_emudeck "$1" "$2"
}

function export_emudeck(){
	#We make sure the ESDE artwork files are in the same place as windows, at least as a symlink...
	ln -s "$ESDEscrapData" "$storagePath/downloaded_media"
	emulationPath="$emulationPath" ESDEscrapData="$ESDEscrapData" python3 "$emudeckBackend/tools/importExport.py" export_emudeck "$1" "$2"
}

function get_locations(){
	generate_pythonEnv &> /dev/null
	python3 "$emudeckBackend/tools/importExport.py" get_locations
}
