#!/bin/bash

function AetherSX2_install(){
	temp_url="https://www.aethersx2.com/archive/android/14026-v1.4-3064.apk"
	temp_emu="aethersx2"
	Android_ADB_dl_installAPK $temp_emu $temp_url
}

function AetherSX2_init(){
	echo "NYI"
}