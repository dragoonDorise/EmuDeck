import sys, subprocess, venv
from pathlib import Path
from core.vars import *

def install_pip(name):
    venv_dir = Path(emudeck_folder) / "python_virtual_env_3_0_0"
    pip_exe = venv_dir / "bin" / "pip"
    if system.startswith("win"):
        pip_exe = venv_dir / "Scripts" / "pip.exe"
    subprocess.run([str(pip_exe), "install", "--upgrade", name], check=True)

def generate_python_env():

    venv_dir = Path(emudeck_folder) / "python_virtual_env_3_0_0"
    if system == "linux" or system == "darwin":
        python_venv = venv_dir / "bin" / "python"
    if system.startswith("win"):
        python_venv = venv_dir / "Scripts" / "python.exe"


    if not venv_dir.exists():
        #print(f"[EmuDeck] Creando entorno virtual en {venv_dir}")
        venv.EnvBuilder(with_pip=True).create(str(venv_dir))

        install_pip("vdf")
        install_pip("requests")
        install_pip("screeninfo")
        install_pip("PySide6")
        install_pip("pygame")
        if system.startswith("win"):
            install_pip("pywin32")
            install_pip("wmi")
            install_pip("py7zr")


    try:
        current_py = Path(sys.executable).resolve()
        target_py  = python_venv.resolve()
    except Exception:
        current_py = Path(sys.executable)
        target_py  = python_venv

    if current_py != target_py:
        # print(f"[EmuDeck] Reiniciando con {target_py}")
        os.execv(str(target_py), [str(target_py)] + sys.argv)

