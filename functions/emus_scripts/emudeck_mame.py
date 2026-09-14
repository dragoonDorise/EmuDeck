from core.all import *

def mame_install():
    set_msg(f"Installing mame")

    if system == "linux":
        name="MAME"
        type="flatpak"
        look_for=""
        destination = f"{emus_folder}"

    if system.startswith("win"):
        name = "mame"
        url = get_latest_release_gh("mamedev/mame", "exe", "x64.exe")
        dest_dir = Path(emus_folder) / "mame"
        dest_dir.mkdir(parents=True, exist_ok=True)

        temp_dir = Path(tempfile.mkdtemp())
        sfx_path = temp_dir / "mame_sfx.exe"

        headers = {
            "User-Agent": "Mozilla/5.0",
            "Accept": "*/*",
        }
        r = requests.get(url, stream=True, headers=headers, timeout=60)
        r.raise_for_status()
        with open(sfx_path, "wb") as f:
            for chunk in r.iter_content(chunk_size=8192):
                f.write(chunk)

        subprocess.run([str(sfx_path), "-y", f"-o{dest_dir}"], check=True)
        real_exe = dest_dir / "mame.exe"
        if not real_exe.exists():
            raise RuntimeError(f"No se encontró {real_exe} tras extraer el SFX")

        create_app_shortcut("mame")
        shutil.rmtree(temp_dir, ignore_errors=True)
        return True

    if system == "darwin":
        return False

    try:
         if system == "linux":
             repo="org.mamedev.MAME"
         else:
             repo=get_latest_release_gh("mamedev/mame",type,look_for)
         install_emu(name, repo, type, destination)
    except Exception as e:
        print(f"Error during install: {e}")
        return False


def mame_uninstall():
    try:
        if system == "linux":
            uninstall_emu("org.mamedev.MAME", "flatpak")
        if system.startswith("win"):
          uninstall_emu("mame", "dir")
        if system == "darwin":
          uninstall_emu("mame", "app")
        return True
    except Exception as e:
        print(f"Error during uninstall: {e}")
        return False

def mame_is_installed():
    if system == "linux":
        return is_flatpak_installed("org.mamedev.MAME")
    if system.startswith("win"):
      return (emus_folder / "mame" / "mame.exe").exists()
    if system == "darwin":
      return (emus_folder / "mame.app").exists()


def mame_set_emulation_folder():
    unix_tails = {
        "samplepath": "$HOME/.mame/samples;/app/share/mame/samples",
        "artpath": "$HOME/.mame/artwork;/app/share/mame/artwork",
        "ctrlrpath": "$HOME/.mame/ctrlr;/app/share/mame/ctrlr",
        "inipath": "$HOME/.mame/ini;$HOME/.mame;/app/share/mame/ini",
        "cheatpath": "$HOME/.mame/cheat;/app/share/mame/cheat",
        "pluginspath": "$HOME/.mame/plugins;/app/share/mame/plugins",
    }

    if system == "linux":
        config_file = f"{home}/.mame/mame.ini"
        tails = unix_tails
    elif system.startswith("win"):
        config_file = f"{emus_folder}/mame/mame.ini"
        tails = {
            "samplepath": "samples",
            "artpath": "artwork",
            "ctrlrpath": "ctrlr",
            "inipath": ".;ini;ini\\presets;",
            "cheatpath": "cheat",
            "pluginspath": "plugins",
        }
    elif system == "darwin":
        config_file = f"{home}/Library/Application Support/mame/mame.ini"
        tails = unix_tails
    else:
        return

    path = Path(config_file)
    if not path.is_file():
        return

    subfolders = {
        "samplepath": "samples", "artpath": "artwork", "ctrlrpath": "ctrlr",
        "inipath": "ini", "cheatpath": "cheat", "pluginspath": "plugins",
    }

    values = {"rompath": f"{roms_path}/arcade;{bios_path};{bios_path}/mame"}
    for key, sub in subfolders.items():
        values[key] = f"{storage_path}/mame/{sub};{tails[key]}"

    for key, value in values.items():
        set_config(key, value, path, separator=" " * (26 - len(key)))


def mame_init():
    set_msg(f"Setting up mame")
    flush_emulator_launchers("mame")
    if system == "linux":
        destination=f"{home}/.mame/"
    if system.startswith("win"):
        destination=f"{emus_folder}/mame/"
    if system == "darwin":
        destination=f"{home}/Library/Application Support/mame"

    copy_setting_dir(f"{system}/mame/",destination)
    copy_and_set_settings_file(f"{system}/mame/mame.ini", destination)

    mame_set_emulation_folder()



   # move_contents_and_link(bios,f"{bios_path}/mame")

    mame_setup_saves()
    #mame_setup_storage()
    mame_set_resolution()
    mame_set_controller_style()
    mame_widescreen()
    esde_set_emu("MAME (Standalone)","arcade")
    mame_add_custom_parser()

def mame_install_init():
    mame_install()
    mame_init()


def mame_add_custom_parser():
    if mame_is_installed():
        add_parser("arcade_mame")


def mame_setup_saves():
    if system == "linux":
        config_file = f"{home}/.mame/mame.ini"
    elif system.startswith("win"):
        config_file = f"{emus_folder}/mame/mame.ini"
    elif system == "darwin":
        config_file = f"{home}/Library/Application Support/mame/mame.ini"
    else:
        return

    path = Path(config_file)
    if not path.is_file():
        return

    for key, sub in (("nvram_directory", "saves"), ("state_directory", "states")):
        set_config(key, f"{saves_path}/mame/{sub}", path, separator=" " * (26 - len(key)))

def mame_set_resolution():
    print("NYI")

def mame_set_abxy_style():
    print("NYI")

def mame_set_bayx_style():
    print("NYI")

def mame_set_controller_style():
    if settings.controllerLayout == "bayx":
        mame_set_bayx_style()
    else:
        mame_set_bayx_style()

def mame_widescreen():
    print("NYI")

def mame_widescreen_on():
    print("NYI")

def mame_widescreen_off():
    print("NYI")
