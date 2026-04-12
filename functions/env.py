import os, sys, subprocess, venv, importlib
from pathlib import Path
from core.vars import *

REQUIRED_PACKAGES = [
    ("vdf", "vdf"),
    ("requests", "requests"),
    ("screeninfo", "screeninfo"),
    ("PySide6", "PySide6"),
    ("inputs", "inputs"),
]

WIN_REQUIRED_PACKAGES = [
    ("pywin32", "win32api"),
    ("wmi", "wmi"),
    ("py7zr", "py7zr"),
]

def install_pip(name):
    venv_dir = Path(emudeck_folder) / "python_virtual_env_3_0_0"
    pip_exe = venv_dir / "bin" / "pip"
    if system.startswith("win"):
        pip_exe = venv_dir / "Scripts" / "pip.exe"
    env = {**os.environ, "PIP_DISABLE_PIP_VERSION_CHECK": "1"}
    subprocess.run([str(pip_exe), "install", "--upgrade", name], check=True, env=env)

def ensure_packages():
    venv_dir = Path(emudeck_folder) / "python_virtual_env_3_0_0"
    if system in ("linux", "darwin"):
        site_packages = venv_dir / "lib"
        candidates = list(site_packages.glob("python3.*/site-packages")) if site_packages.exists() else []
    else:
        candidates = [venv_dir / "Lib" / "site-packages"]

    venv_site = str(candidates[0]) if candidates else None

    packages = list(REQUIRED_PACKAGES)
    if system.startswith("win"):
        packages += WIN_REQUIRED_PACKAGES

    for pip_name, import_name in packages:
        installed = False
        if venv_site:
            finder = importlib.machinery.FileFinder(
                venv_site,
                (importlib.machinery.SourceFileLoader, [".py"]),
                (importlib.machinery.ExtensionFileLoader, importlib.machinery.EXTENSION_SUFFIXES),
            )
            installed = finder.find_spec(import_name) is not None

        if not installed:
            install_pip(pip_name)

def generate_python_env():
    venv_dir = Path(emudeck_folder) / "python_virtual_env_3_0_0"
    if system in ("linux", "darwin"):
        python_venv = venv_dir / "bin" / "python"
    if system.startswith("win"):
        python_venv = venv_dir / "Scripts" / "python.exe"

    if not venv_dir.exists():
        venv.EnvBuilder(with_pip=True).create(str(venv_dir))

    if Path(sys.prefix).resolve() != venv_dir.resolve():
        os.execv(str(python_venv), [str(python_venv)] + sys.argv)

    ensure_packages()