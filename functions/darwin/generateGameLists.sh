#!/bin/bash

generateGameLists(){ py_run rl_init && py_run rl_generate_missing_artwork_lists "$@" && (py_run rl_get_artwork "$@" >/dev/null 2>&1 &); }
