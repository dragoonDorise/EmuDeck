#!/bin/bash

function Android_Citra_install(){
	temp_url="$(getLatestReleaseURLGH "weihuoya/citra" ".apk")"
	temp_emu="citra"
	Android_ADB_dl_installAPK $temp_emu $temp_url
}

function Android_Citra_init(){
	echo "NYI"
}