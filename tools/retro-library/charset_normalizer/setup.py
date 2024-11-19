#!/usr/bin/env python

from __future__ import annotations

import os
import sys

from setuptools import setup

USE_MYPYC = False

if len(sys.argv) > 1 and sys.argv[1] == "--use-mypyc":
    sys.argv.pop(1)
    USE_MYPYC = True
if os.getenv("CHARSET_NORMALIZER_USE_MYPYC", None) == "1":
    USE_MYPYC = True

if USE_MYPYC:
    from mypyc.build import mypycify

    MYPYC_MODULES = mypycify(
        [
            "charset_normalizer/md.py",
        ],
        debug_level="0",
    )
else:
    MYPYC_MODULES = None

setup(name="charset-normalizer", ext_modules=MYPYC_MODULES)
