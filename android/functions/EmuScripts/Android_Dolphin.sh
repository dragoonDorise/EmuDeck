#!/bin/bash

function Android_Dolphin_install(){
	temp_url="$(getLatestReleaseURLGH "Medard22/Dolphin-MMJR2-VBI" ".apk")"
	temp_emu="dolphinmmjr2"
	Android_ADB_dl_installAPK $temp_emu $temp_url
}

function Android_Dolphin_init(){
	echo "NYI"
}