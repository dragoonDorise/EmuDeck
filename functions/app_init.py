from functions.env import generate_python_env
generate_python_env()

def app_init():
    install_pip("vdf")
    install_pip("requests")
    install_pip("screeninfo")
    install_pip("py7zr")
    install_pip("PySide6")
    install_pip("pygame")
