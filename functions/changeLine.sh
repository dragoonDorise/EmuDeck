#!/bin/bash



function changeLine {

    local KEYWORD=$1; shift
    local REPLACE=$1; shift
    local FILE=$1

    local OLD=$(printf '%s\n' "$KEYWORD" | sed -e 's/[]\/$*.^[]/\\&/g');
    local NEW=$(printf '%s\n' "$REPLACE" | sed -e 's/[\/&]/\\&/g')



    sed --debug -i "/${OLD}/c\\${NEW}" $FILE
}