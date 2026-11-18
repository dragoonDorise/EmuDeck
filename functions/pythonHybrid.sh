#!/usr/bin/env bash

# Runs a python function through api.py printing true/false, or its result with --print, and returns its exit code
py_run(){
	local printResult=false
	if [ "$1" == "--print" ]; then
		printResult=true
		#We remove "--print"
		shift
	fi
	local fn=$1
	#We remove the function name so all we have now are the args
	shift
	local python="$pyVenv/bin/python"
	if [ ! -x "$python" ]; then
		python="python3"
	fi

	#Args to JSON
	local argsJson="[]"
	if [ $# -gt 0 ]; then
		argsJson=$(printf '%s\0' "$@" | jq -Rsc 'split("\u0000")[:-1]')
	fi

	#EMUDECK_PROGRESS so we can use the setMsg progress intercalating python + bash
	pyOutput=$(EMUDECK_PROGRESS="${progressBar:-0}" \
		"$python" "$pythonBackend/api.py" --hybrid "$fn" "$argsJson" 2>>"$emudeckLogs/python.log")
	status=$?

	progress=$(jq -r '.progress // empty' <<< "$pyOutput" 2>/dev/null)
	if [[ "$progress" =~ ^[0-9]+$ ]]; then
		progressBar=$progress
	fi
	
	#Differente outputs depending on how we call the function
	if [ "$printResult" == "true" ]; then
		jq -r 'if .result == null then empty elif (.result | type) == "string" then .result else (.result | tojson) end' <<< "$pyOutput" 2>/dev/null
	elif [ $status -eq 0 ]; then
		echo "true"
	else
		echo "false"
	fi
	return $status
}
