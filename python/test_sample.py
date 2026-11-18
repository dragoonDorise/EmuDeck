import sys
import os
import shutil
from core.vars import emudeck_backend
# Copy repo to backend
src = os.path.dirname(os.path.abspath(__file__))
if os.path.exists(emudeck_backend):
    shutil.rmtree(emudeck_backend)
shutil.copytree(src, emudeck_backend, ignore=shutil.ignore_patterns('.git', '__pycache__', '*.pyc'))

sys.path.insert(0, emudeck_backend)

from functions.env import generate_python_env
generate_python_env()

from core.all import *

print("hey")