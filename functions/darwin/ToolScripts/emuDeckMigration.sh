#!/usr/bin/env bash
Migration_init(){ py_run migration_init "$1" >/dev/null && py_run migration_update_emus >/dev/null && echo "Valid"; }
