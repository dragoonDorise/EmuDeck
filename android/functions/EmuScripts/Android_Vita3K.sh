#!/bin/bash

function Android_Vita3K_install(){
	temp_url="$(getLatestReleaseURLGH "Vita3K/Vita3K-Android" ".apk")"
	temp_emu="vita3k"
	Android_ADB_dl_installAPK $temp_emu $temp_url
}

function Android_Vita3K_init(){
	echo "NYI"
}