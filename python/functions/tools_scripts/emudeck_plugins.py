from core.all import *

DECKY_TEMP_PASSWORD = "EmuDecky!"


def plugins_sudo(password: str, *command: str) -> bool:
    return subprocess.run(["sudo", "-S", *command], input=f"{password}\n", text=True).returncode == 0


def plugins_set_user_password(password: str) -> bool:
    return subprocess.run(["passwd", getpass.getuser()], input=f"{password}\n{password}\n", text=True,
                          stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode == 0


def plugins_check_password(password: str = "") -> Optional[str]:
    distro = str(getattr(settings, "system", "")).lower()
    if password == DECKY_TEMP_PASSWORD:
        plugins_set_user_password(password)
    elif distro == "chimeraos":
        password = "gamer"
    elif distro == "bazzite":
        password = "bazzite"
    elif not password:
        status = subprocess.run(["passwd", "-S", getpass.getuser()], capture_output=True, text=True).stdout.split()
        if len(status) > 1 and status[1] == "P":
            entry = subprocess.run(["zenity", "--title=Decky Installer", "--width=300", "--height=100", "--entry", "--hide-text",
                                    "--text=Enter your sudo/admin password so we can install Decky with the best plugins for emulation"],
                                   capture_output=True, text=True)
            if entry.returncode != 0:
                return None
            password = entry.stdout.strip()
            if not plugins_sudo(password, "-k", "true"):
                subprocess.run(["zenity", "--title=Decky Installer", "--width=150", "--height=40", "--info", "--text=Incorrect Password"])
                return None
        else:
            password = DECKY_TEMP_PASSWORD
            plugins_set_user_password(password)
    return password


def plugins_install_cleanup(password: str) -> bool:
    if password == DECKY_TEMP_PASSWORD:
        return plugins_sudo(password, "-k", "passwd", "-d", getpass.getuser())
    return False


def plugins_install_plugin_loader(password: str = "") -> bool:
    set_msg("Installing Decky Loader")
    homebrew = home / "homebrew"
    homebrew.mkdir(parents=True, exist_ok=True)
    password = plugins_check_password(password)
    if password is None:
        return False
    user = getpass.getuser()
    plugins_sudo(password, "chown", "-R", f"{user}:{user}", str(homebrew))
    try:
        installer = requests.get("https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/install_release.sh", timeout=60)
        installer.raise_for_status()
        subprocess.run(["sh"], input=installer.text, text=True)
    except Exception as e:
        print(f"Decky Loader download failed: {e}")
    cef_flag = home / ".steam" / "steam" / ".cef-enable-remote-debugging"
    if cef_flag.parent.is_dir():
        cef_flag.touch()
        plugins_sudo(password, "chown", f"{user}:{user}", str(cef_flag))
    plugins_install_cleanup(password)
    return True


def plugins_install_decky_plugin(folder_name: str, repository: str, file_type: str, password: str = "") -> bool:
    plugins = home / "homebrew" / "plugins"
    plugins.mkdir(parents=True, exist_ok=True)
    password = plugins_check_password(password)
    if password is None:
        return False
    plugins_install_plugin_loader(password)

    url = get_latest_release_gh(repository, file_type, "")
    if not url:
        print(f"No {file_type} release found for {repository}")
        plugins_install_cleanup(password)
        return False

    destination = plugins / folder_name
    archive = Path(tempfile.gettempdir()) / f"{folder_name}{file_type}"
    user = getpass.getuser()
    plugins_sudo(password, "rm", "-rf", str(destination))
    try:
        response = requests.get(url, timeout=120)
        response.raise_for_status()
        archive.write_bytes(response.content)
    except Exception as e:
        print(f"{folder_name} download failed: {e}")
        plugins_install_cleanup(password)
        return False

    if file_type.endswith(".zip"):
        plugins_sudo(password, "unzip", "-o", str(archive), "-d", str(plugins))
    else:
        plugins_sudo(password, "tar", "-xf", str(archive), "-C", str(plugins))
    archive.unlink(missing_ok=True)
    plugins_sudo(password, "chown", "-R", f"{user}:{user}", str(destination))
    plugins_sudo(password, "chmod", "-R", "555", str(destination))
    plugins_install_cleanup(password)
    return destination.is_dir()


def plugins_install_emudecky(password: str = ""):
    set_msg("Installing EmuDecky")
    wrappers_install()
    return plugins_install_decky_plugin("EmuDecky", "EmuDeck/EmuDecky", ".zip", password)


def plugins_install_decky_rom_library(password: str = ""):
    """Builds the game lists and installs the Retro Library Decky plugin."""
    set_msg("Installing Retro Library")
    rl_init()
    return plugins_install_decky_plugin("decky-rom-library", "EmuDeck/decky-rom-library", ".zip", password)


def plugins_install_power_control(password: str = ""):
    """Installs the PowerControl Decky plugin."""
    print("Installing PowerControl")
    return plugins_install_decky_plugin("PowerControl", "mengmeet/PowerControl", ".tar.gz", password)


def plugins_install(password: str = ""):
    """Installs EmuDecky, Retro Library and SteamDeckGyroDSU."""
    plugins_install_emudecky(password)
    plugins_install_decky_rom_library(password)
    plugins_install_steamdeck_gyro_dsu()
    return True


def plugins_install_decky_controls(password: str = ""):
    """Installs the EmuDecky Decky plugin (old name kept for compatibility)."""
    return plugins_install_emudecky(password)

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
        #popup_show_info("Download Failed", f"Could not fetch installer:\n{e}")
        return False
    
    # write to temp file
    tmp = Path(tempfile.gettempdir()) / "sdgyro.sh"
    try:
        tmp.write_bytes(resp.content)
        # make executable
        tmp.chmod(tmp.stat().st_mode | stat.S_IXUSR)
    except Exception as e:
        #popup_show_info("Write Error", f"Failed to write installer:\n{e}")
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
        #popup_show_info("Installation Complete", completed.stdout or "GyroDSU installed successfully.")
    except subprocess.CalledProcessError as e:
        #popup_show_info("Installer Error", e.stderr or str(e))
        return False
    finally:
        try:
            tmp.unlink()
        except OSError:
            pass
    
    return True
    