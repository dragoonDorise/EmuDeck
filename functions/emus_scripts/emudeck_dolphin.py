from core.all import *

def dolphin_download_url():
    # Solo se usa en Windows/macOS
    resp = requests.get("https://dolphin-emu.org/download/", timeout=10)
    resp.raise_for_status()
    html = resp.text

    ids = re.findall(r"/download/release/(\d+)/", html)
    if not ids:
        print("Error: could not find any release IDs on Dolphin download page")
        return None

    latest_id = max(int(x) for x in ids)

    if system.startswith("win"):
        return f"https://dl.dolphin-emu.org/releases/{latest_id}/dolphin-{latest_id}-x64.7z"

    if system == "darwin":
        return f"https://dl.dolphin-emu.org/releases/{latest_id}/dolphin-{latest_id}-universal.dmg"

    return None

def dolphin_install():
    set_msg("Installing dolphin")

    # LINUX (Flatpak)
    if system == "linux":
        app_id = "org.DolphinEmu.dolphin-emu"
        dolphin_remote_name = "dolphin-releases"
        dolphin_remote_repo = "https://flatpak.dolphin-emu.org/releases.flatpakrepo"
        flathub_name = "flathub"
        flathub_repo = "https://flathub.org/repo/flathub.flatpakrepo"

        def run(cmd):
            return subprocess.run(
                cmd,
                check=False,
                text=True,
                stdin=subprocess.DEVNULL,
            ).returncode == 0

        run(["flatpak", "remote-add", "--if-not-exists", "--user", flathub_name, flathub_repo])
        run(["flatpak", "remote-add", "--if-not-exists", "--user", dolphin_remote_name, dolphin_remote_repo])

        ok = run(["flatpak", "install", "-y", "--noninteractive", "--user", dolphin_remote_name, app_id])
        if ok:
            return True

        run(["flatpak", "install", "-y", "--noninteractive", "--user", flathub_name, "org.kde.Platform//6.8"])

        ok = run(["flatpak", "install", "-y", "--noninteractive", "--user", dolphin_remote_name, app_id])
        return ok

    # WINDOWS 
    if system.startswith("win"):
        try:
            url = dolphin_download_url()
            if not url:
                return False

            install_emu("Dolphin", url, "7z", f"{emus_folder}/Dolphin-x64")
            return True

        except Exception as e:
            print(f"Error during Windows Dolphin install: {e}")
            return False

    # macOS
    if system == "darwin":
        try:
            url = dolphin_download_url()
            if not url:
                return False

            install_emu("Dolphin", url, "dmg", emus_folder)
            return True

        except Exception as e:
            print(f"Error during macOS Dolphin install: {e}")
            return False

    return False


def dolphin_uninstall():
    try:
        if system == "linux":
            uninstall_emu("org.DolphinEmu.dolphin-emu", "flatpak")
        if system.startswith("win"):
          uninstall_emu("Dolphin-x64", "dir")
        if system == "darwin":
          uninstall_emu("Dolphin", "app")
        return True
    except Exception as e:
        print(f"Error during uninstall: {e}")
        return False

def dolphin_is_installed():
    if system == "linux":
        return is_flatpak_installed("org.DolphinEmu.dolphin-emu")
    if system.startswith("win"):
      return (emus_folder / "Dolphin-x64" / "dolphin.exe").exists()
    if system == "darwin":
      return (emus_folder / "Dolphin.app").exists()


def dolphin_init():
    set_msg(f"Setting up dolphin")
    if system == "linux":
        destination=f"{home}/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/"
    if system.startswith("win"):
        destination=f"{emus_folder}/Dolphin-x64/"
    if system == "darwin":
        destination=f"{home}/Library/Application Support/Dolphin/Config"

    copy_setting_dir(f"{system}/dolphin-emu/",destination)

    if system == "linux":
        copy_and_set_settings_file(f"{system}/dolphin-emu/Dolphin.ini", f"{destination}")
    if system.startswith("win"):
        copy_and_set_settings_file(f"{system}/dolphin-emu/User/Config/Dolphin.ini", f"{destination}/User/Config/")
    if system == "darwin":
        copy_and_set_settings_file(f"{system}/dolphin-emu/Dolphin.ini", destination)

    dolphin_setup_saves()
    dolphin_set_resolution()
    dolphin_set_controller_style()
    dolphin_widescreen()

def dolphin_install_init():
    dolphin_install()
    dolphin_init()

def dolphin_setup_saves():
    if system == "linux":
        origin_saves_gc=f"{home}/.var/app/org.DolphinEmu.dolphin-emu/data/dolphin-emu/GC"
        origin_saves_wii=f"{home}/.var/app/org.DolphinEmu.dolphin-emu/data/dolphin-emu/Wii"
        origin_states=f"{home}/.var/app/org.DolphinEmu.dolphin-emu/data/dolphin-emu/StateSaves"
    if system.startswith("win"):
        origin_saves_gc=f"{emus_folder}/Dolphin-x64/User/GC"
        origin_saves_wii=f"{emus_folder}/Dolphin-x64/User/Wii"
        origin_states=f"{emus_folder}/Dolphin-x64/User/StateSaves"
    if system == "darwin":
        origin_saves_gc=f"{home}/Library/Application Support/Dolphin/GC"
        origin_saves_wii=f"{home}/Library/Application Support/Dolphin/Wii"
        origin_states=f"{home}/Library/Application Support/Dolphin/StateSaves"

    move_contents_and_link(origin_saves_gc,f"{saves_path}/dolphin/saves/GC")
    move_contents_and_link(origin_saves_wii,f"{saves_path}/dolphin/saves/Wii")
    move_contents_and_link(origin_states,f"{saves_path}/dolphin/StateSaves")


def dolphin_set_resolution():
    if system == "linux":
        dolphin_config_file=f"{home}/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/GFX.ini"
    if system.startswith("win"):
        dolphin_config_file=f"{emus_folder}/Dolphin-x64/User/Config/GFX.ini"
    if system == "darwin":
        dolphin_config_file=f"{home}/Library/Application Support/Dolphin/Config/GFX.ini"

    resolution_map = {
        "720P": 2,
        "1080P": 3,
        "1440P": 4,
        "4K": 6,
    }

    # Normalize config file path
    config_path = Path(dolphin_config_file)

    # Find the multiplier
    multiplier = resolution_map.get(settings.resolutions.dolphin)
    if multiplier is None:
        print(f"Error: unsupported resolution '{settings.resolutions.dolphin}'")
        return False

    set_config("InternalResolution", multiplier, config_path)

    return True


def dolphin_set_abxy_style():
    print("NYI")

def dolphin_set_bayx_style():
    print("NYI")

def dolphin_set_controller_style():
    if settings.controllerLayout == "bayx":
        dolphin_set_bayx_style()
    else:
        dolphin_set_bayx_style()

def dolphin_widescreen_on():
    if system == "linux":
        dolphin_config_file=f"{home}/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/GFX.ini"
    if system.startswith("win"):
        dolphin_config_file=f"{emus_folder}/Dolphin-x64/User/Config/GFX.ini"
    if system == "darwin":
        dolphin_config_file=f"{home}/Library/Application Support/Dolphin/Config/GFX.ini"
    config_path = Path(dolphin_config_file)

    set_config("wideScreenHack", "True", config_path)
    set_config("AspectRatio", "1", config_path)

def dolphin_widescreen_off():
    if system == "linux":
        dolphin_config_file=f"{home}/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/GFX.ini"
    if system.startswith("win"):
        dolphin_config_file=f"{emus_folder}/Dolphin-x64/User/Config/GFX.ini"
    if system == "darwin":
        dolphin_config_file=f"{home}/Library/Application Support/Dolphin/Config/GFX.ini"
    config_path = Path(dolphin_config_file)

    set_config("wideScreenHack", "False", config_path)
    set_config("AspectRatio", "0", config_path)


def dolphin_widescreen():
    if settings.ar.dolphin == "169":
        dolphin_widescreen_on()
    else:
        dolphin_widescreen_off()


def dolphin_cheevos_config_file():
    if system == "linux":
        return f"{home}/.var/app/org.DolphinEmu.dolphin-emu/config/dolphin-emu/RetroAchievements.ini"
    if system.startswith("win"):
        return f"{emus_folder}/Dolphin-x64/User/Config/RetroAchievements.ini"
    if system == "darwin":
        return f"{home}/Library/Application Support/Dolphin/Config/RetroAchievements.ini"


def dolphin_ensure_cheevos_config():
    # Dolphin guarda los logros en RetroAchievements.ini. Si no existe lo creamos por defecto.
    config_path = Path(dolphin_cheevos_config_file())
    if not config_path.exists():
        config_path.parent.mkdir(parents=True, exist_ok=True)
        config_path.write_text(
            "[Achievements]\n"
            "ChallengeIndicatorsEnabled = True\n"
            "DiscordPresenceEnabled = False\n"
            "Enabled = False\n"
            "EncoreEnabled = False\n"
            "HardcoreEnabled = False\n"
            "LeaderboardTrackerEnabled = True\n"
            "ProgressEnabled = False\n"
            "SpectatorEnabled = False\n"
            "UnofficialEnabled = False\n"
            "Username = \n"
            "ApiToken = \n",
            encoding="utf-8")


def dolphin_retro_achievements():
    if settings.achievements.user == '':
        dolphin_retro_achievements_off()
    else:
        dolphin_retro_achievements_on()


def dolphin_retro_achievements_on():
    dolphin_ensure_cheevos_config()
    config_path = dolphin_cheevos_config_file()
    # Dolphin usa booleanos capitalizados (True/False) y el token en plano (ApiToken)
    set_ini_value(config_path, "Achievements", "Enabled", "True")
    set_ini_value(config_path, "Achievements", "Username", f"{achievements_user}")
    set_ini_value(config_path, "Achievements", "ApiToken", f"{achievements_token}")
    if achievements_hardcore:
        set_ini_value(config_path, "Achievements", "HardcoreEnabled", "True")
    else:
        set_ini_value(config_path, "Achievements", "HardcoreEnabled", "False")


def dolphin_retro_achievements_off():
    dolphin_ensure_cheevos_config()
    config_path = dolphin_cheevos_config_file()
    set_ini_value(config_path, "Achievements", "Enabled", "False")
    set_ini_value(config_path, "Achievements", "HardcoreEnabled", "False")