from core.all import *

def plugins_install_retro_library():
    return True

def plugins_install_emudecky(arg):
    wrappers_install()
    return True

def plugins_install_plugin_loader(arg):
    return True

def plugins_install_powertools():
    return True

def win_game_mode_enable():
    return True

def win_game_mode_disable():
    return True

def plugins_install_steamdeck_gyro_dsu():
    system = platform.system()
    if system.startswith("Win"):
        return False

    url = "https://github.com/kmicki/SteamDeckGyroDSU/raw/master/pkg/update.sh"
    try:
        #popup_show_info("GyroDSU Installer", "Downloading installer…")
        resp = requests.get(url, timeout=30)
        resp.raise_for_status()
    except Exception as e:
        popup_show_info("Download Failed", f"Could not fetch installer:\n{e}")
        return False

    # write to temp file
    tmp = Path(tempfile.gettempdir()) / "sdgyro.sh"
    try:
        tmp.write_bytes(resp.content)
        # make executable
        tmp.chmod(tmp.stat().st_mode | stat.S_IXUSR)
    except Exception as e:
        popup_show_info("Write Error", f"Failed to write installer:\n{e}")
        return False

    # run it
    try:
        #popup_show_info("GyroDSU Installer", "Running installer…")
        completed = subprocess.run(
            ["/bin/bash", str(tmp)],
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
        popup_show_info("Installation Complete", completed.stdout or "GyroDSU installed successfully.")
    except subprocess.CalledProcessError as e:
        popup_show_info("Installer Error", e.stderr or str(e))
        return False
    finally:
        try:
            tmp.unlink()
        except OSError:
            pass

    return True