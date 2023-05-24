#!/bin/bash
appImageInit() {
	if ! declare -p variable &>/dev/null; then
		setSetting cloud_sync_status "true"
	fi
}