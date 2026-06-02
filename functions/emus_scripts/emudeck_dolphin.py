from core.all import *

def dolphin_download_url():
    resp = requests.get(
        "https://dolphin-emu.org/update/latest/beta/",
        headers={"User-Agent": "EmuDeck/2.0"},
        timeout=20,
    )
    resp.raise_for_status()

    data = resp.json()
    artifacts = data.get("artifacts", [])

    if system.startswith("win"):
        target_system = "Windows x64"
    elif system == "linux":
        target_system = "Linux x86_64 (Flatpak)"
    elif system == "darwin":
        target_system = "macOS (ARM/Intel Universal)"
    else:
        return None

    for artifact in artifacts:
        if artifact.get("system") == target_system:
            return artifact.get("url")

    print(f"Error: could not find Dolphin artifact for {target_system}")
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

        def is_installed():
            for cmd in (
                ["flatpak", "info", "--user", app_id],
                ["flatpak", "info", app_id],
            ):
                result = subprocess.run(
                    cmd,
                    check=False,
                    stdin=subprocess.DEVNULL,
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                )
                if result.returncode == 0:
                    return True

            return False

        if is_installed():
            return True

        run(["flatpak", "remote-add", "--if-not-exists", "--user", flathub_name, flathub_repo])
        run(["flatpak", "remote-add", "--if-not-exists", "--user", dolphin_remote_name, dolphin_remote_repo])

        ok = run(["flatpak", "install", "-y", "--noninteractive", "--user", dolphin_remote_name, app_id])
        if ok or is_installed():
            return True

        ok = run(["flatpak", "install", "-y", "--noninteractive", "--user", flathub_name, app_id])
        return ok or is_installed()

    # WINDOWS
    if system.startswith("win"):
        try:
            url = dolphin_download_url()
            if not url:
                return False

            install_emu("Dolphin", url, "7z", emus_folder)
            return dolphin_is_installed()

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
        return (Path(emus_folder) / "Dolphin-x64" / "Dolphin.exe").exists()
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
        for origin, destination in [
            (Path(f"{emus_folder}/Dolphin-x64/User/GC"), Path(f"{saves_path}/dolphin/saves/GC")),
            (Path(f"{emus_folder}/Dolphin-x64/User/Wii"), Path(f"{saves_path}/dolphin/saves/Wii")),
            (Path(f"{emus_folder}/Dolphin-x64/User/StateSaves"), Path(f"{saves_path}/dolphin/StateSaves")),
        ]:
            if origin.is_symlink() or origin.is_junction():
                continue

            destination.mkdir(parents=True, exist_ok=True)

            if origin.exists():
                shutil.copytree(origin, destination, dirs_exist_ok=True)
                shutil.rmtree(origin, ignore_errors=True)

            origin.parent.mkdir(parents=True, exist_ok=True)

            try:
                os.symlink(str(destination), str(origin), target_is_directory=True)
            except OSError:
                subprocess.run(
                    ["cmd", "/c", "mklink", "/J", str(origin), str(destination)],
                    shell=True,
                    check=True
                )

        return

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