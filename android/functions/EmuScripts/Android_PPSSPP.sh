#!/bin/bash

function Android_PPSSPP_install(){
	temp_url="https://www.ppsspp.org/files/1_16_6/ppsspp.apk"
	temp_emu="ppsspp"
	Android_ADB_dl_installAPK $temp_emu $temp_url
}

function Android_PPSSPP_init(){
	echo "NYI"
}