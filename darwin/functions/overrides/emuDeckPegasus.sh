#!/bin/bash
Pegasus_install(){

	local PegasusURL="$(getLatestReleaseURLGH "mmatyas/pegasus-frontend" "macos-static.zip")"
	local showProgress=false

	installEmuZip "{$Pegasus_toolName}" "${PegasusURL}" "pegasus"

	Pegasus_init

}
