#!/bin/bash

function Android_Yuzu_install(){
	temp_url="$(getLatestReleaseURLGH "yuzu-emu/yuzu-android" ".apk")"
	temp_emu="yuzu"
	Android_ADB_dl_installAPK $temp_emu $temp_url
}

function Android_Yuzu_init(){
	echo "NYI"
}