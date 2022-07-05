#!/bin/bash
testLocationValid() {
	testLocation=$2
	touch "$testLocation/testwrite"
	return=""
	if [ ! -f "$testLocation/testwrite" ]; then
		#echo "$testLocation not writeable"
		return="invalid"
	else
		#echo "$testLocation writable"

		ln -s "$testLocation/testwrite" "$testLocation/testwrite.link"
		if [ ! -f "$testLocation/testwrite.link" ]; then
			#echo "Symlink creation failed in $testLocation"
			return="invalid"
		else
			return="valid"
			#doesn't work? scope issue?
			#locationTable+=(FALSE "$1" "$testLocation") #valid only if location is writable and linkable
		fi
	fi
	rm -f "$testLocation/testwrite" "$testLocation/testwrite.link"
	echo $return
}
