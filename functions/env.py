import os, sys, subprocess, venv, importlib.util, platform
from pathlib import Path
from core.vars import *

REQUIRED_PACKAGES = [
    ("vdf", "vdf"),
    ("requests", "requests"),
    ("screeninfo", "screeninfo"),
    ("PySide6", "PySide6"),
    ("pygame-ce", "pygame"),
]

WIN_REQUIRED_PACKAGES = [
    ("pywin32", "win32api"),
    ("wmi", "wmi"),
    ("py7zr", "py7zr"),
]

# Brotli 1.2.x lacks a prebuilt win_arm64 wheel, so py7zr's install fails
# trying to build it from source. Pin 1.1.0 (which does ship ARM wheels)
# before py7zr gets a chance to pull the latest. On every other arch we
# let py7zr resolve brotli normally.
WIN_ARM_EXTRA_PACKAGES = [
    ("brotli==1.1.0", "brotli"),
]

def install_pip(name):
    venv_dir = Path(emudeck_folder) / "python_virtual_env_3_0_0"
    pip_exe = venv_dir / "bin" / "pip"
    if system.startswith("win"):
        pip_exe = venv_dir / "Scripts" / "pip.exe"
    env = {**os.environ, "PIP_DISABLE_PIP_VERSION_CHECK": "1"}
    subprocess.run(
        [str(pip_exe), "install", "--upgrade", name],
        check=True,
        env=env,
        stdout=sys.stderr,
        stderr=sys.stderr,
    )

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
        if platform.machine().upper() == "ARM64":
            packages += WIN_ARM_EXTRA_PACKAGES
        packages += WIN_REQUIRED_PACKAGES

    for pip_name, import_name in packages:
        try:
            spec = importlib.util.find_spec(import_name)
            installed = spec is not None
        except (ModuleNotFoundError, ValueError):
            installed = False

        if not installed:
            print(f"[EmuDeck] Módulo '{pip_name}' no encontrado en venv, instalando...", file=sys.stderr)
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

    # Solo llegamos aquí si ya estamos dentro del venv
    ensure_packages()