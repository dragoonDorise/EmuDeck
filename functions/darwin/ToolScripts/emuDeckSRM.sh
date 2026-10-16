#!/usr/bin/env bash
SRM_install(){ py_run srm_install; }
SRM_init(){ py_run srm_init; }
SRM_resetConfig(){ py_run srm_init; }
SRM_uninstall(){ py_run srm_uninstall; }
SRM_IsInstalled(){ py_run srm_is_installed; }
SRM_deleteCache(){ py_run srm_delete_cache; }
