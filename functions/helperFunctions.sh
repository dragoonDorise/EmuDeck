#!/bin/bash



function changeLine() {

    local KEYWORD=$1; shift
    local REPLACE=$1; shift
    local FILE=$1

    local OLD=$(escapeSedKeyword "$KEYWORD")
    local NEW=$(escapeSedValue "$REPLACE")

    sed -i "/${OLD}/c\\${NEW}" $FILE

}
function escapeSedKeyword(){
    local INPUT=$1;
    local OUTPUT=$(printf '%s\n' "$INPUT" | sed -e 's/[]\/$*.^[]/\\&/g')
    echo $OUTPUT
}

function escapeSedValue(){
    local INPUT=$1
    local OUTPUT=$(printf '%s\n' "$INPUT" | sed -e 's/[\/&]/\\&/g')
    echo $OUTPUT
}

function getSDPath(){
    if [ -b "/dev/mmcblk0p1" ]; then	    
		echo "$(findmnt -n --raw --evaluate --output=target -S /dev/mmcblk0p1)"
	fi
}

function testRealDeck(){
    case $(cat /sys/devices/virtual/dmi/id/product_name) in
	  Win600|Jupiter)
		isRealDeck=true
	;;
	  *)
		isRealDeck=false
	;;
	esac
}

function testLocationValid(){
    local locationName=$1
	local testLocation=$2
	local return=""

    touch $testLocation/testwrite
    
	if [ ! -f  $testLocation/testwrite ]; then
		return="Invalid: $locationName not Writable"
	else
		ln -s $testLocation/testwrite $testLocation/testwrite.link
		if [ ! -f  $testLocation/testwrite.link ]; then
			return="Invalid: $locationName not Linkable"
		else
			return="Valid: $testLocation"
		fi
	fi
	rm -f "$testLocation/testwrite" "$testLocation/testwrite.link"
	echo $return
}


function customLocation(){
    echo $(zenity --file-selection --directory --title="Select a destination for the Emulation directory." 2>/dev/null)
}