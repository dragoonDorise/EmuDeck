#!/bin/bash

function Android_Pegasus_install(){
	temp_url="https://github.com/mmatyas/pegasus-frontend/releases/download/continuous/pegasus-fe_alpha16-75-gc78a6851_android64.apk"
	temp_emu="yuzu"
	Android_ADB_dl_installAPK $temp_emu $temp_url
}

function Android_Pegasus_init(){
	echo "NYI"
}