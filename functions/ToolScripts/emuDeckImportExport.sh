#!/bin/bash

function import_emudeck(){
	emulationPath="$emulationPath" ESDEscrapData="$ESDEscrapData" python3 "$emudeckBackend/tools/importExport.py" import_emudeck "$1" "$2"
}

function export_emudeck(){
	emulationPath="$emulationPath" ESDEscrapData="$ESDEscrapData" python3 "$emudeckBackend/tools/importExport.py" export_emudeck "$1" "$2"
}

function get_locations(){
	generate_pythonEnv &> /dev/null
	python3 "$emudeckBackend/tools/importExport.py" get_locations
}
