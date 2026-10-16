#!/usr/bin/env bash
import_emudeck(){ py_run import_emudeck "$1" "$2"; }
export_emudeck(){ py_run export_emudeck "$1" "$2"; }
get_locations(){ py_run --print get_locations; }
