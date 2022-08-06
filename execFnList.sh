#!/bin/bash
source "$HOME/emudeck/backend/functions/all.sh"
for var in "$@"
do
    "$var"
done