#!/bin/bash
pegasus_install(){

	local PegasusURL="$(getLatestReleaseURLGH "mmatyas/pegasus-frontend" "macos-static.zip")"
	local showProgress=false

	darwin_installEmuZip "{$pegasus_toolName}" "${PegasusURL}" "pegasus"

	pegasus_init

}
