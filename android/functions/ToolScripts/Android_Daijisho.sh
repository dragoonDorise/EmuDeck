#!/bin/bash

function Android_Daijisho_install(){
	temp_url="$(getLatestReleaseURLGH "TapiocaFox/Daijishou" ".apk")"
	temp_emu="daijishou"
	Android_ADB_dl_installAPK $temp_emu $temp_url
}

function Android_Daijisho_init(){
	echo "NYI"
}