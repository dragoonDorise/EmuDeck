#!/bin/bash
pegasus_install(){

	local PegasusURL="$(getLatestReleaseURLGH "mmatyas/pegasus-frontend" "macos-static.zip")"
	local showProgress=false

	installEmuZip "{$pegasus_toolName}" "${PegasusURL}" "pegasus"

	pegasus_init

}
