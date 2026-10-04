from core.all import *

def game_mode_enable():
    import winreg
    appdata = os.environ.get("APPDATA")
    if not appdata:
        print("No se encontró la variable APPDATA", file=sys.stderr)
        return False

    new_shell = os.path.join(appdata, "EmuDeck", "backend", "tools", "gamemode", "login.bat")

    try:
        # Abre la rama Winlogon en HKLM
        key = winreg.OpenKey(
            winreg.HKEY_LOCAL_MACHINE,
            r"SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon",
            0,
            winreg.KEY_SET_VALUE
        )
        # Escribe el valor
        winreg.SetValueEx(key, "Shell", 0, winreg.REG_SZ, new_shell)
        winreg.CloseKey(key)
        print(f"Shell cambiado a: {new_shell}")
        return True

    except PermissionError:
        print("Error: necesitas privilegios de administrador para modificar HKLM.", file=sys.stderr)
        return False
    except OSError as e:
        print(f"Error al acceder al registro: {e}", file=sys.stderr)
        return False

def game_mode_disable():
    import winreg
    appdata = os.environ.get("APPDATA")
    if not appdata:
        print("No se encontró la variable APPDATA", file=sys.stderr)
        return False

    new_shell = "explorer.exe"

    try:
        # Abre la rama Winlogon en HKLM
        key = winreg.OpenKey(
            winreg.HKEY_LOCAL_MACHINE,
            r"SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon",
            0,
            winreg.KEY_SET_VALUE
        )
        # Escribe el valor
        winreg.SetValueEx(key, "Shell", 0, winreg.REG_SZ, new_shell)
        winreg.CloseKey(key)
        print(f"Shell cambiado a: {new_shell}")
        return True

    except PermissionError:
        print("Error: necesitas privilegios de administrador para modificar HKLM.", file=sys.stderr)
        return False
    except OSError as e:
        print(f"Error al acceder al registro: {e}", file=sys.stderr)
        return False
