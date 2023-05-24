#!/bin/bash
appImageInit() {
	if ! declare -p cloud_sync_status &>/dev/null; then
		setSetting cloud_sync_status true
	fi
}